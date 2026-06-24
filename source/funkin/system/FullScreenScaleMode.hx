package funkin.system;

import flixel.math.FlxPoint;
import flixel.util.FlxAxes;

import funkin.utils.DeviceUtil;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

class FullScreenScaleMode extends flixel.system.scaleModes.BaseScaleMode
{
	/**
	 * The size of the screen cutout (e.g. for notches or camera cutouts).
	 */
	public static var cutoutSize:FlxPoint = FlxPoint.get();

	/**
	 * The position of the notch on the screen.
	 */
	public static var notchPosition:FlxPoint = FlxPoint.get();

	/**
	 * The size of the notch on the screen.
	 */
	public static var notchSize:FlxPoint = FlxPoint.get();

	/**
	 * The size of the game in screen resolution relativly to the initial size.
	 *
	 * e.g.: If the screen's resolution is 1080p and the initial size of the game is 1280x720 then this is 1920x1080.
	 */
	public static var logicalSize:FlxPoint = FlxPoint.get();

	/**
	 * The maximum aspect ratio the screen can have.
	 */
	public static var maxAspectRatio:FlxPoint = FlxPoint.get(21, 9);

	/**
	 * The maximum ratio axis indicating on which axis the black bar will be added.
	 */
	public static var maxRatioAxis:FlxAxes = X;

	/**
	 * The aspect ratio of the game screen.
	 */
	public static var gameRatio:Float = -1;

	/**
	 * The size of the game cutout.
	 */
	public static var gameCutoutSize:FlxPoint = FlxPoint.get();

	/**
	 * The position of the notch, in game coordinates.
	 */
	public static var gameNotchPosition:FlxPoint = FlxPoint.get();

	/**
	 * The size of the notch, in game coordinates.
	 */
	public static var gameNotchSize:FlxPoint = FlxPoint.get();

	/**
	 * The aspect ratio of the window.
	 */
	public static var screenRatio:Float = -1;

	/**
	 * The scale factor for the window.
	 */
	public static var wideScale:FlxPoint = FlxPoint.get(1, 1);

	/**
	 * Axis used to determine the ratio (X or Y).
	 */
	public static var ratioAxis:FlxAxes = X;

	/**
	 * The active instance of the `FullScreenScaleMode`.
	 */
	public static var instance:FullScreenScaleMode = null;

	/**
	 * Whether fullscreen scaling is enabled.
	 */
	public static var enabled(default, set):Bool;

	/**
	 * Whether to add fake cutouts to the screen.
	 */
	public static var hasFakeCutouts:Bool = false;

	@:noCompletion static var cutoutBitmaps:Array<Null<Bitmap>> = [null, null];

	@:noCompletion static var mustAwait:Bool = false;

	@:noCompletion static var awaitedSize:FlxPoint = FlxPoint.get();

	@:noCompletion static var finishingAwait:Bool = false;

	/**
	 * @param enable Whether fullscreen scaling should be enabled by default.
	 */
	public function new(enable:Bool = true)
	{
		super();

		instance = this;

		if (FlxG.stage != null)
		{
			updateGameSize(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
		}

		enabled = enable;
	}

	/**
	 * Measures and adjusts the game layout based on the provided screen width and height.
	 *
	 * @param width 	The width of the screen.
	 * @param height 	The height of the screen.
	 */
	override function onMeasure(width:Int, height:Int)
	{
		#if desktop
		if (mustAwait && enabled)
		{
			onMeasureAwait(width, height);
		}
		else
		{
			onMeasureInstant(width, height);
			mustAwait = true;
		}
		#else
		onMeasureInstant(width, height);
		#end
	}

	/**
	 * Locks the game to the current aspect ratio and assignes the requested resolution as awaited for later.
	 *
	 * @param width The width of the screen.
	 * @param height The height of the screen.
	 */
	public function onMeasureAwait(width:Int, height:Int)
	{
		horizontalAlign = CENTER;
		verticalAlign = CENTER;

		updateGameSize(FlxG.width, FlxG.height);
		updateDeviceSize(width, height);

		#if mobile
		updateDeviceNotch(DeviceUtil.getNotchRect());
		#end

		updateScaleOffset();
		updateGamePosition();

		awaitedSize.set(width, height);
	}

	/**
	 * Unlocks the game resolution and swap into the awaited one.
	 */
	public function onMeasurePostAwait()
	{
		#if desktop
		if (awaitedSize.x == 0 && awaitedSize.y == 0)
		{
			return;
		}

		horizontalAlign = enabled ? LEFT : CENTER;
		verticalAlign = enabled ? TOP : CENTER;
		onMeasureInstant(Math.ceil(awaitedSize.x), Math.ceil(awaitedSize.y));

		awaitedSize.set(0, 0);
		#end
	}

	/**
	 * Instantly applies the measured resolution to the game.
	 *
	 * @param width 	The width of the screen.
	 * @param height 	The height of the screen.
	 */
	public function onMeasureInstant(width:Int, height:Int)
	{
		finishingAwait = true;

		untyped FlxG.width = FlxG.initialWidth;
		untyped FlxG.height = FlxG.initialHeight;

		updateGameSize(width, height);
		updateDeviceSize(width, height);
		updateDeviceCutout(width, height);

		#if mobile
		updateDeviceNotch(DeviceUtil.getNotchRect());
		#end

		updateScaleOffset();
		updateGamePosition();

		adjustGameSize();

		finishingAwait = false;
	}

	/**
	 * Adds fake cutouts into the screen.
	 *
	 * Useful for when switching from wide display into 16:9 seamlessly and directly is needed.
	 *
	 * @param tweenDuration The duration of the tweens that adds the cutout bars. Using 0 will instantly put them on screen.
	 * @param ease 					The function that's used for the tween.
	 */
	public static function addCutouts(tweenDuration:Float = 0, ?ease:EaseFunction)
	{
		if (cutoutSize.x == 0 && ratioAxis == X || cutoutSize.y == 0 && ratioAxis == Y)
		{
			return;
		}

		for (i => bitmap in cutoutBitmaps)
		{
			if (bitmap == null)
			{
				var bitmapWidth:Int = (ratioAxis == X ? Math.ceil(cutoutSize.x / 2) : Math.ceil(FlxG.scaleMode.gameSize.x)) + 1;
				var bitmapHeight:Int = (ratioAxis == Y ? Math.ceil(cutoutSize.y / 2) : Math.ceil(FlxG.scaleMode.gameSize.y)) + 1;
				cutoutBitmaps[i] = bitmap = new Bitmap(new BitmapData(bitmapWidth, bitmapHeight, true, 0xFF000000));
				FlxG.game.parent.addChildAt(bitmap, FlxG.game.parent.getChildIndex(FlxG.game) + 1);
			}

			var targetX:Float = 0;
			var targetY:Float = 0;

			if (ratioAxis == X)
			{
				bitmap.x = instance.offset.x + ((i == 0) ? -bitmap.width - 1 : FlxG.scaleMode.gameSize.x + 1);
				targetX = instance.offset.x + ((i == 0) ? -1 : FlxG.scaleMode.gameSize.x - bitmap.width + 1);
				bitmap.y = 0;
				targetY = 0;
			}
			else
			{
				bitmap.x = 0;
				targetX = 0;
				bitmap.y = instance.offset.y + ((i == 0) ? -bitmap.height - 1 : FlxG.scaleMode.gameSize.y + 1);
				targetY = instance.offset.y + ((i == 0) ? -1 : FlxG.scaleMode.gameSize.y - bitmap.height + 1);
			}

			bitmap.alpha = 0;

			if (tweenDuration > 0)
			{
				FlxTween.tween(bitmap, {x: targetX, y: targetY, alpha: 1}, tweenDuration, {ease: ease ?? FlxEase.linear});
			}
			else
			{
				bitmap.x = targetX;
				bitmap.y = targetY;
				bitmap.alpha = 1;
			}
		}

		hasFakeCutouts = true;
	}

	/**
	 * Remove the fake cutouts from the screen.
	 * Used to go back from 16:9 into widescreen seamlessly and directly when needed.
	 * @param tweenDuration The duration of the tweens that remove the cutout bars. Using 0 will instantly put them off screen.
	 * @param ease The function that's used for the tween.
	 */
	public static function removeCutouts(tweenDuration:Float = 0, ?ease:Float -> Float)
	{
		for (i => bitmap in cutoutBitmaps)
		{
			if (bitmap == null)
			{
				FlxG.log.warn("Tried to remove a cutout bar but there don't seem to be any.");
				continue;
			}

			final targetX:Float = (ratioAxis == Y) ? -1 : instance.offset.x + ((i == 0) ? -bitmap.width - 1 : FlxG.scaleMode.gameSize.x + 1);
			final targetY:Float = (ratioAxis == X) ? -1 : instance.offset.y + ((i == 0) ? -bitmap.height - 1 : FlxG.scaleMode.gameSize.y + 1);

			if (tweenDuration > 0)
			{
				FlxTween.tween(bitmap, {x: targetX, y: targetY, alpha: 0}, tweenDuration, {ease: ease ?? FlxEase.linear});
			}
			else
			{
				bitmap.x = targetX;
				bitmap.y = targetY;
				bitmap.alpha = 0;
			}
		}
		hasFakeCutouts = false;
	}

	function updateDeviceCutout(width:Int, height:Int)
	{
		if (enabled)
		{
			cutoutSize.x = ratioAxis == X ? Math.ceil(width - logicalSize.x) : 0;
			cutoutSize.y = ratioAxis == Y ? Math.ceil(height - logicalSize.y) : 0;
			gameCutoutSize.copyFrom(cutoutSize);
			gameCutoutSize /= logicalSize.x / FlxG.initialWidth;
		}
		else
		{
			cutoutSize.set(0, 0);
			gameCutoutSize.set(0, 0);
		}
	}

	override function updateGameSize(width:Int, height:Int)
	{
		gameRatio = FlxG.width / FlxG.height;
		screenRatio = width / height;
		ratioAxis = screenRatio < gameRatio ? FlxAxes.Y : FlxAxes.X;

		logicalSize.set(width, height);

		if (ratioAxis == FlxAxes.Y)
		{
			gameSize.x = width;
			logicalSize.y = Math.ceil(gameSize.x / gameRatio);
			gameSize.y = enabled ? height : logicalSize.y;
		}
		else
		{
			gameSize.y = height;
			logicalSize.x = Math.ceil(gameSize.y * gameRatio);
			gameSize.x = enabled ? width : logicalSize.x;
		}
	}

	override function updateScaleOffset()
	{
		if (finishingAwait)
		{
			scale.x = ratioAxis == X ? logicalSize.x / FlxG.width : deviceSize.x / FlxG.width;
			scale.y = ratioAxis == Y ? logicalSize.y / FlxG.height : deviceSize.y / FlxG.height;
		}
		else
		{
			scale.x = deviceSize.x / FlxG.width;
			scale.y = deviceSize.y / FlxG.height;

			if (scale.x > scale.y)
			{
				scale.x = scale.y;
			}
			else
			{
				scale.y = scale.x;
			}
		}

		updateOffsetX();
		updateOffsetY();
	}

	override function updateOffsetX()
	{
		offset.x = switch (horizontalAlign)
		{
			case LEFT: 0;
			case CENTER: Math.ceil((finishingAwait && enabled) ? (deviceSize.x - gameSize.x) : (deviceSize.x - (gameSize.x #if desktop * (enabled ? scale.x : 1) #end)) * 0.5);
			case RIGHT: deviceSize.x - gameSize.x;
		}
	}

	override function updateOffsetY()
	{
		offset.y = switch (verticalAlign)
		{
			case TOP: 0;
			case CENTER: Math.ceil((finishingAwait && enabled) ? (deviceSize.y - gameSize.y) : (deviceSize.y - (gameSize.y #if desktop * (enabled ? scale.y : 1) #end)) * 0.5);
			case BOTTOM: deviceSize.y - gameSize.y;
		}
	}

	#if mobile
	private function updateDeviceNotch(notch:openfl.geom.Rectangle)
	{
		notchPosition.set(enabled ? notch.x : 0, enabled ? notch.y : 0);
		notchSize.set(enabled ? notch.width : 0, enabled ? notch.height : 0);
		gameNotchPosition.copyFrom(notchPosition);
		gameNotchSize.copyFrom(notchSize);

		final scale:Float = logicalSize.x / FlxG.initialWidth;
		if (Math.ceil(logicalSize.x) > FlxG.initialWidth)
		{
			gameNotchPosition /= scale;
			gameNotchSize /= scale;
		}
		else
		{
			gameNotchPosition *= scale;
			gameNotchSize *= scale;
		}
	}
	#end

	public function reset()
	{
		cutoutSize.set();
		gameCutoutSize.set();
		notchSize.set();
		gameNotchSize.set();
		notchPosition.set();
		gameNotchPosition.set();
	}

	function adjustGameSize()
	{
		if ((cutoutSize.x > 0 || cutoutSize.y > 0) && enabled)
		{
			wideScale.set(1, 1);

			if (ratioAxis == Y)
			{
				var gameHeight:Float = gameSize.y / scale.y;

				#if desktop
				if (MathUtil.gcd(FlxG.width, Math.ceil(gameHeight)) == 1 || maxRatioAxis != ratioAxis)
				{
					gameSize.y -= cutoutSize.y;
					offset.y = Math.ceil((deviceSize.y - gameSize.y) * 0.5);
					updateGamePosition();
					reset();
					return;
				}
				#end

				if (gameHeight / FlxG.width > maxAspectRatio.y / maxAspectRatio.x && maxRatioAxis.y)
				{
					final oldGameHeight = gameSize.y;
					gameHeight = ((gameSize.x / scale.x) / maxAspectRatio.x) * maxAspectRatio.y;
					gameSize.y = gameHeight * scale.y;

					final sizeDifference:Float = oldGameHeight - gameSize.y;
					final scale:Float = logicalSize.y / FlxG.initialHeight;
					cutoutSize.set(0, cutoutSize.y - sizeDifference);
					gameCutoutSize.copyFrom(cutoutSize);
					gameCutoutSize /= scale;

					notchSize.y = Math.max(0, notchSize.y - sizeDifference);
					gameNotchSize.y = notchSize.y / scale;

					offset.y = Math.ceil((deviceSize.y - gameSize.y) * 0.5);
					updateGamePosition();
				}

				untyped FlxG.height = Math.ceil(gameHeight);

				wideScale.y = FlxG.height / FlxG.initialHeight;
			}
			else
			{
				var gameWidth:Float = gameSize.x / scale.x;

				#if desktop
				if (MathUtil.gcd(Math.ceil(gameWidth), FlxG.height) == 1 || maxRatioAxis != ratioAxis)
				{
					gameSize.x -= cutoutSize.x;
					offset.x = Math.ceil((deviceSize.x - gameSize.x) * 0.5);
					updateGamePosition();
					reset();
					return;
				}
				#end

				if (gameWidth / FlxG.height > maxAspectRatio.x / maxAspectRatio.y && maxRatioAxis.x)
				{
					final oldGameWidth = gameSize.x;
					gameWidth = ((gameSize.y / scale.y) / maxAspectRatio.y) * maxAspectRatio.x;
					gameSize.x = gameWidth * scale.x;

					final sizeDifference:Float = oldGameWidth - gameSize.x;
					final scale:Float = logicalSize.x / FlxG.initialWidth;
					cutoutSize.set(cutoutSize.x - sizeDifference, 0);
					gameCutoutSize.copyFrom(cutoutSize);
					gameCutoutSize /= scale;

					notchSize.x = Math.max(0, notchSize.x - sizeDifference);
					gameNotchSize.x = notchSize.x / scale;

					offset.x = Math.ceil((deviceSize.x - gameSize.x) * 0.5);
					updateGamePosition();
				}

				untyped FlxG.width = Math.ceil(gameWidth);

				wideScale.x = FlxG.width / FlxG.initialWidth;
			}
		}
	}

	@:noCompletion static function set_enabled(value:Bool):Bool
	{
		if (ratioAxis == X #if android
			&& (extension.androidtools.os.Build.VERSION.SDK_INT >= extension.androidtools.os.Build.VERSION_CODES.P
				|| extension.androidtools.Tools.isTablet()) #end)
		{
			enabled = value;
		}
		else
		{
			enabled = false;
		}

		if (instance != null)
		{
			mustAwait = false;
			instance.horizontalAlign = enabled ? LEFT : CENTER;
			instance.verticalAlign = enabled ? TOP : CENTER;
			instance.onMeasure(FlxG.stage.stageWidth, FlxG.stage.stageHeight);

			FlxG.signals.gameResized.dispatch(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
		}

		return enabled;
	}
}
