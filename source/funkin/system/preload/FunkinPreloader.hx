package funkin.system.preload;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flixel.system.FlxBasePreloader;

import lime.system.System;

import openfl.Lib;
import openfl.display.Shape;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Future;

/**
 * The crewmate bitmap.
 */
@:bitmap('assets/embed/images/loading-mini-crewmate.png')
private class MiniCrewmateSprite extends BitmapData {}

class FunkinPreloader extends FlxBasePreloader
{
	final BASE_WIDTH:Int = 1280;
	final PRELOADER_FONT:String = '_sans';

	var curState:PreloaderState = NotStarted;
	var completedStates:Int = 0;
	final totalStates:Int = 3;

	var statesProgressText:TextField;
	var loadingText:TextField;
	var loadingBar:Shape;
	var percentText:TextField;
	var miniCrewmate:Bitmap;

	/**
	 * Whether the mini crewmate can play its animation.
	 *
	 * This check is added due to HTML5 targets loading images asyncronously.
	 * So to prevent errors, we only update the Bitmap once its ready.
	 */
	var canUpdateMiniCrewmate:Bool = false;

	var miniCrewmateTimer:Float = 0;
	var miniCrewmateTotalFrames:Int = 10;
	var miniCrewmateFrameCount:Int = 0;
	var miniCrewmateFrameRate:Float = 18;

	var downloadingPercent:Float = 0;
	var downloaded:Bool = false;
	var precacheImagesPercent:Float = 0;
	var precacheSoundsPercent:Float = 0;
	var precacheMusicPercent:Float = 0;

	var scaleRatio:Float = 0;

	public function new()
	{
		super();
	}

	override function create()
	{
		// doesnt really matter where we put this since the base preloader doesn't do anything in create.
		super.create();

		this._width = Lib.current.stage.stageWidth;
		this._height = Lib.current.stage.stageHeight;

		#if mobile
		var display = System.getDisplay(0);
		var dpiScale:Float = display.dpi / 160;
		var normalizedWidth:Float = this._width / dpiScale;
		scaleRatio = normalizedWidth / BASE_WIDTH;
		#else
		scaleRatio = 1;
		#end

		statesProgressText = new TextField();
		statesProgressText.selectable = false;
		statesProgressText.mouseEnabled = false;
		statesProgressText.defaultTextFormat = new TextFormat(PRELOADER_FONT, 28, 0xFFFFFFFF);
		statesProgressText.y = 580;
		statesProgressText.autoSize = LEFT;
		statesProgressText.text = '$completedStates / $totalStates';
		addChild(statesProgressText);

		loadingText = new TextField();
		loadingText.selectable = false;
		loadingText.mouseEnabled = false;
		loadingText.defaultTextFormat = new TextFormat(PRELOADER_FONT, 40, 0xFFFFFFFF);
		loadingText.y = 520;
		loadingText.autoSize = LEFT;
		loadingText.text = 'Downloading Assets';
		addChild(loadingText);

		miniCrewmate = createBitmap(MiniCrewmateSprite, function(bitmap:Bitmap)
		{
			bitmap.scrollRect = new Rectangle(0, 0, 32, 32);

			bitmap.scaleX = bitmap.scaleY = scaleRatio * 4;
			bitmap.x = (this._width - (bitmap.width / miniCrewmateTotalFrames)) / 2;
			bitmap.y = (this._height - bitmap.height) / 2;

			canUpdateMiniCrewmate = true;
		});
		addChild(miniCrewmate);

		loadingBar = new Shape();
		loadingBar.graphics.beginFill(0xFF23BBA4);
		loadingBar.graphics.drawRoundRect(0, 0, 720 * scaleRatio, 40 * scaleRatio, 50);
		loadingBar.graphics.endFill();
		loadingBar.x = (this._width - loadingBar.width) / 2;
		loadingBar.y = (this._height - loadingBar.height) / 2 + 100;
		loadingBar.scrollRect = new Rectangle(0, 0, loadingBar.width, loadingBar.height);
		addChild(loadingBar);

		var loadingBarBorders:Shape = new Shape();
		loadingBarBorders.graphics.lineStyle(6, 0xFFFFFFFF);
		loadingBarBorders.graphics.beginFill(0x00000000, 0);
		loadingBarBorders.graphics.drawRoundRect(0, 0, loadingBar.width, loadingBar.height, 50);
		loadingBarBorders.graphics.endFill();
		loadingBarBorders.x = loadingBar.x;
		loadingBarBorders.y = loadingBar.y;
		addChild(loadingBarBorders);

		percentText = new TextField();
		percentText.selectable = false;
		percentText.mouseEnabled = false;
		percentText.defaultTextFormat = new TextFormat(PRELOADER_FONT, 32, 0xFFFFFFFF);
		percentText.autoSize = LEFT;
		percentText.x = loadingBar.x + (loadingBar.width - percentText.width) / 2;
		percentText.y = loadingBar.y + (loadingBar.height - percentText.height) / 2;
		percentText.text = '0%';
		addChild(percentText);
	}

	var lastTimeElapsed:Float = 0;

	override function update(percent:Float)
	{
		var timeElapsed:Float = (Date.now().getTime() - this._startTime) / 1000;
		var deltaTime:Float = timeElapsed - lastTimeElapsed;

		downloadingPercent = percent;

		updateMiniCrewmate(deltaTime);
		var statePercent:Float = updateProgress(percent);
		updateDisplay(statePercent);
		super.update(statePercent);

		lastTimeElapsed = timeElapsed;
	}

	function updateMiniCrewmate(deltaTime:Float)
	{
		if (canUpdateMiniCrewmate)
		{
			miniCrewmateTimer += deltaTime;
			if (miniCrewmateTimer >= (1.0 / miniCrewmateFrameRate))
			{
				miniCrewmateTimer -= 1.0 / miniCrewmateFrameRate;
				miniCrewmateFrameCount = (miniCrewmateFrameCount + 1) % miniCrewmateTotalFrames;

				var rect:Rectangle = miniCrewmate.scrollRect;
				rect.x = miniCrewmateFrameCount * 32;
				miniCrewmate.scrollRect = rect;
			}
		}
	}

	var precacheImagesFuture:Future<lime.utils.AssetLibrary> = null;

	function updateProgress(percent:Float):Float
	{
		switch (curState)
		{
			case NotStarted:
				curState = DownloadingAssets;
				return percent;

			case DownloadingAssets:
				loadingText.text = 'Downloading Assets';
				completedStates = 0;

				if (downloadingPercent >= 1 || downloaded)
				{
					curState = PreloadingAssets;
				}

				return percent;

			case PreloadingAssets:
				loadingText.text = 'Preloading Assets';
				completedStates = 1;

				if (precacheImagesFuture == null)
				{
					precacheImagesFuture = Assets.loadLibrary('default');
					precacheImagesFuture.onProgress(function(bytes:Int, total:Int)
					{
						trace('$bytes / $total');
						precacheImagesPercent = bytes / total;
					});
					precacheImagesFuture.onError(function(error:Dynamic)
					{
						trace('Error preloading assets: $error');
						precacheImagesPercent = 1;
					});
					precacheImagesFuture.onComplete(function(_)
					{
						precacheImagesPercent = 1;
					});
				}

				if (precacheImagesPercent >= 1)
				{
					curState = CachingAssets;
				}

				return precacheImagesPercent;

			case CachingAssets:
				loadingText.text = 'Caching Assets';
				completedStates = 2;

				curState = Done;
				return 1;
			case Done:
				loadingText.text = 'Starting Game';
				completedStates = 3;

				loadGame();
				return 1;

			default:
				// do nothing
		}
		return 0;
	}

	function updateDisplay(percent:Float)
	{
		var rect:Rectangle = loadingBar.scrollRect;
		rect.width = loadingBar.width * percent;
		loadingBar.scrollRect = rect;

		var percentage:Int = Math.floor(percent * 100);
		percentText.defaultTextFormat = new TextFormat(PRELOADER_FONT, 32, 0xFFFFFFFF);
		percentText.x = loadingBar.x + (loadingBar.width - percentText.width) / 2;
		percentText.y = loadingBar.y + (loadingBar.height - percentText.height) / 2;
		percentText.text = '$percentage%';

		loadingText.defaultTextFormat = new TextFormat(PRELOADER_FONT, 40, 0xFFFFFFFF);
		loadingText.x = loadingBar.x + (loadingBar.width - loadingText.width) / 2;

		statesProgressText.defaultTextFormat = new TextFormat(PRELOADER_FONT, 28, 0xFFFFFFFF);
		statesProgressText.x = loadingBar.x + (loadingBar.width - statesProgressText.width) / 2;
		statesProgressText.text = '$completedStates / $totalStates';
	}

	function loadGame()
	{
		_loaded = true;
	}

	override function onLoaded()
	{
		super.onLoaded();

		_loaded = false;
		downloaded = true;
	}

	override function destroy()
	{
		super.destroy();

		precacheImagesFuture = null;
	}
}

/**
 * The states of the preloader.
 */
enum abstract PreloaderState(String) to String
{
	/**
	 * The preloader hasn't started.
	 */
	var NotStarted;

	/**
	 * The preloader is downloading the game assets.
	 */
	var DownloadingAssets;

	/**
	 * The preloader is preloading the game assets.
	 */
	var PreloadingAssets;

	/**
	 * The preloader is caching the game assets, for smoother gameplay and menu navigation.
	 */
	var CachingAssets;

	/**
	 * The preloader is done.
	 */
	var Done;
}
