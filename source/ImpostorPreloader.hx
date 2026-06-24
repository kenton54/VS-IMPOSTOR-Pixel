package;

import flixel.system.FlxBasePreloader;
import flixel.util.FlxStringUtil;

import funkin.Constants;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * The walking crewmate bitmap.
 */
@:bitmap('assets/embed/images/preloader-mini-crewmate.png')
private class MiniCrewmateBitmap extends flash.display.BitmapData {}

/**
 * The logo bitmap.
 */
@:bitmap('assets/embed/images/preloader-logo.png')
private class VsImpostorPixelLogo extends flash.display.BitmapData {}

final class ImpostorPreloader extends FlxBasePreloader
{
	final BASE_WIDTH:Float = 1280;
	final BASE_HEIGHT:Float = 720;

	final FADE_TIME:Float = 0.25;

	var logo:Bitmap;
	var miniCrewmate:Bitmap;
	var downloadingText:TextField;

	var scaleRatio:Float = 1;

	public function new()
	{
		super(1, [
			FlxBasePreloader.LOCAL, // testing URL
			'https://kenton54.itch.io/vs-impostor-pixel',
			'https://gamejolt.com/games/vsimpostorpixel/1079175'
		]);

		this.siteLockTitleText = 'Uh oh!';
		this.siteLockBodyText = "Looks like you're playing the mod from a shaddy website!\nIt may contain stuff the developer didn't intend to have, or cause unwanted harm!\nThanks for playing the mod tho, but try to play it from authorized websites.\nLike this one down below!";
		this.siteLockURLIndex = 1;
	}

	var _isMiniCrewReady:Bool = false;
	var _isLogoReady:Bool = false;
	var _isFading:Bool = false;
	var _hasFaded:Bool = false;

	var _completeTime:Float = 0;

	override function create()
	{
		updateSize();
		super.create();

		miniCrewmate = createBitmap(MiniCrewmateBitmap, function(bitmap:Bitmap)
		{
			bitmap.scrollRect = new Rectangle(0, 0, 32, 32);

			bitmap.scaleX = bitmap.scaleY = 4 * scaleRatio;

			bitmap.x = this._width;
			bitmap.y = this._height - bitmap.height - (4 * scaleRatio);

			bitmap.smoothing = false;

			_isMiniCrewReady = true;
		});
		addChild(miniCrewmate);

		var format:TextFormat = new TextFormat(Constants.DEFAULT_FONT, Std.int(32 * scaleRatio), 0xFFFFFFFF);
		format.align = RIGHT;

		downloadingText = new TextField();
		downloadingText.embedFonts = true;
		downloadingText.defaultTextFormat = format;
		downloadingText.text = 'Downloading (0%)';
		downloadingText.x = 100 * scaleRatio;
		downloadingText.width = this._width - 200 * scaleRatio;
		downloadingText.y = this._height * 0.85 - getTextHeight(downloadingText);
		downloadingText.selectable = false;
		downloadingText.mouseEnabled = false;
		addChild(downloadingText);

		logo = createBitmap(VsImpostorPixelLogo, function(bitmap:Bitmap)
		{
			bitmap.scaleX = bitmap.scaleY = 2 * scaleRatio;

			bitmap.x = downloadingText.x + downloadingText.width - bitmap.width;
			bitmap.y = downloadingText.y - bitmap.height - (8 * scaleRatio);

			bitmap.smoothing = false;

			_isLogoReady = true;
		});
		addChild(logo);

		stage.addEventListener(Event.RESIZE, onResize);
	}

	var lastElapsed:Float = 0;

	override function update(percent:Float)
	{
		var elapsed:Float = (#if hl Sys.time() * 1000 #else Date.now().getTime() #end - this._startTime) / 1000;
		var deltaTime:Float = elapsed - lastElapsed;

		if (_isMiniCrewReady)
		{
			miniCrewmateAnimationHandler(deltaTime);
			miniCrewmateMovementHandler(deltaTime);
		}

		updateDisplay(percent, elapsed);
		super.update(percent);

		// yes, there IS a difference between the two percent variables
		if (_percent >= 1 && percent >= 1 && !_isFading)
		{
			_isFading = true;
			_completeTime = elapsed;
		}

		lastElapsed = elapsed;
	}

	var _miniCrewTimer:Float = 0;
	var _miniCrewFrameIndex:Int = 0;
	final _miniCrewFrameRate:Float = 18;

	function miniCrewmateAnimationHandler(deltaTime:Float)
	{
		_miniCrewTimer += deltaTime;

		if (_miniCrewTimer >= (1 / _miniCrewFrameRate))
		{
			_miniCrewTimer -= 1 / _miniCrewFrameRate;
			_miniCrewFrameIndex = (_miniCrewFrameIndex + 1) % 10;

			var scrollRect:Rectangle = miniCrewmate.scrollRect;
			scrollRect.x = 32 * _miniCrewFrameIndex;
			miniCrewmate.scrollRect = scrollRect;
		}
	}

	final _miniCrewSpeed:Float = -500;

	function miniCrewmateMovementHandler(deltaTime:Float)
	{
		miniCrewmate.x += _miniCrewSpeed * deltaTime * scaleRatio;

		if (miniCrewmate.x < -(128 * scaleRatio + 20))
		{
			miniCrewmate.x = this._width + 20;
		}
	}

	function updateDisplay(percent:Float, elapsed:Float)
	{
		if (_isFading && percent >= 1)
		{
			var fadeTime:Float = elapsed - _completeTime;
			if (fadeTime > FADE_TIME)
			{
				startGame();
			}
			else
			{
				var alphaValue:Float = 1 - (fadeTime / FADE_TIME);

				miniCrewmate.alpha = alphaValue;
				downloadingText.alpha = alphaValue;
				logo.alpha = alphaValue;
			}
		}

		var percentReadable:Int = Math.floor(percent * 100);
		var text:String = 'Downloading ($percentReadable%)';

		if (downloadingText.text != text)
		{
			var format:TextFormat = new TextFormat(Constants.DEFAULT_FONT, Std.int(32 * scaleRatio), 0xFFFFFFFF);
			format.align = RIGHT;

			downloadingText.defaultTextFormat = format;
			downloadingText.text = text;
		}
	}

	function onResize(event:Event)
	{
		var lastWidth:Int = this._width;

		updateSize();

		downloadingText.x = 100 * scaleRatio;
		downloadingText.width = this._width - 200 * scaleRatio;
		downloadingText.y = this._height * 0.85 - getTextHeight(downloadingText);

		if (_isMiniCrewReady)
		{
			miniCrewmate.scaleX = miniCrewmate.scaleY = 4 * scaleRatio;

			var walkProgress:Float = 1 - (miniCrewmate.x / lastWidth);
			miniCrewmate.x = this._width * (walkProgress * scaleRatio);
			miniCrewmate.y = this._height - miniCrewmate.height - (4 * scaleRatio);
		}

		if (_isLogoReady)
		{
			logo.scaleX = logo.scaleY = 2 * scaleRatio;

			logo.x = downloadingText.x + downloadingText.width - logo.width;
			logo.y = downloadingText.y - logo.height - (8 * scaleRatio);
		}
	}

	function updateSize()
	{
		this._width = Lib.current.stage.stageWidth;
		this._height = Lib.current.stage.stageHeight;

		#if mobile
		var display = Lib.current.stage.window.display;
		var dpiScale:Float = display.dpi / 160;
		var normalizedWidth:Float = this._width / dpiScale;
		scaleRatio = normalizedWidth / BASE_WIDTH;
		#else
		scaleRatio = this._width / BASE_WIDTH;
		#end
	}

	override function onLoaded()
	{
		super.onLoaded();
		_loaded = false;
	}

	function startGame()
	{
		_loaded = true;
	}

	@:access(flixel.text.FlxText)
	inline function getTextHeight(textField:TextField):Float
	{
		return textField.textHeight + flixel.text.FlxText.VERTICAL_GUTTER;
	}

	#if web
	override function isHostUrlAllowed():Bool
	{
		if (allowedURLs.length < 1)
		{
			return true;
		}

		var websiteHost:String = FlxStringUtil.getHost(js.Browser.location.href);
		for (url in allowedURLs)
		{
			var urlHost:String = FlxStringUtil.getHost(url);
			if (url == FlxBasePreloader.LOCAL)
			{
				return true;
			}
			else if (urlHost == websiteHost)
			{
				return true;
			}
		}

		return false;
	}
	#end
}
