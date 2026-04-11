package funkin.ui.debug;

import funkin.ui.debug.advanced.*;

import openfl.display.DisplayObject;
import openfl.display.Sprite;

class DebugOverlay extends Sprite
{
	/**
	 * How frequently the overlay updates, in seconds.
	 */
	public static final UPDATE_FREQUENCY:Float = 0.5;

	public var displayMode(default, null):DebugDisplayMode = NONE;

	var displayModeInt:Int = DebugDisplayMode.NONE;

	public var simple(default, null):SimpleDisplay;

	var project:ProjectDebug;

	var updateTimer:Float = 0;

	public function new(backgroundColor:Int = 0x7F7F7F)
	{
		super();

		simple = new SimpleDisplay();
		addChild(simple);

		updateDisplayMode();
	}

	/**
	 * Cycles through the display modes of the overlay.
	 */
	public function cycleDisplayMode()
	{
		displayModeInt++;

		if (displayModeInt > DebugDisplayMode.ADVANCED)
		{
			displayModeInt = DebugDisplayMode.NONE;
		}

		displayMode = DebugDisplayMode.fromInt(displayModeInt);

		updateDisplayMode();
	}

	/**
	 * Updates the overlay's visibility based on the current display mode.
	 */
	public function updateDisplayMode()
	{
		visible = displayMode != NONE;
		simple.visible = displayMode == SIMPLE;
	}

	override function __enterFrame(deltaTime:Int)
	{
		if (#if html5 FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.THREE #else FlxG.keys.justPressed.F3 #end)
		{
			cycleDisplayMode();
		}

		var dt:Float = deltaTime / 1000;

		if (displayMode == SIMPLE)
		{
			simple.update(dt);
			return;
		}

		for (i in 0...numChildren)
		{
			var child:DisplayObject = getChildAt(i);
			if (Std.isOfType(child, DebugCategory))
			{
				cast(child, DebugCategory).updatePosition();
				cast(child, DebugCategory).update(dt);
			}
		}

		if (updateTimer < UPDATE_FREQUENCY)
		{
			updateTimer += dt;
			return;
		}

		for (i in 0...numChildren)
		{
			var child:DisplayObject = getChildAt(i);
			if (Std.isOfType(child, DebugCategory))
			{
				cast(child, DebugCategory).postUpdate();
			}
		}

		updateTimer = 0;
	}
}

/**
 * The modes the overlay can be displayed.
 */
enum abstract DebugDisplayMode(Int) from Int to Int
{
	/**
	 * The overlay will be hidden.
	 */
	var NONE:Int = 0;

	/**
	 * The overlay will only show the FPS counter and the Garbage Collector memory.
	 */
	var SIMPLE:Int = 1;

	/**
	 * The overlay will show everything.
	 */
	var ADVANCED:Int = 2;

	public static function fromInt(int:Int):DebugDisplayMode
	{
		return switch (int)
		{
			case 0: NONE;
			case 1: SIMPLE;
			case 2: ADVANCED;
			case _: NONE;
		};
	}

	public function toInt(mode:DebugDisplayMode):Int
	{
		return switch (mode)
		{
			case NONE: 0;
			case SIMPLE: 1;
			case ADVANCED: 2;
		};
	}
}
