package funkin.ui.debug;

import openfl.display.Sprite;

class DebugOverlay extends Sprite
{
	/**
	 * What the overlay displays.
	 */
	public var displayMode(default, null):DebugDisplayMode = NONE;

	public var simple(default, null):SimpleDisplay;

	public var advanced(default, null):AdvancedDisplay;

	var displayModeInt:Int = 0;
	var updateTimer:Float = 0;

	public function new()
	{
		super();

		simple = new SimpleDisplay(8, 3);
		addChild(simple);

		advanced = new AdvancedDisplay(8, 3);
		addChild(advanced);

		updateDisplayMode();
	}

	/**
	 * Cycles through the display modes of the overlay.
	 */
	public function cycleDisplayMode()
	{
		displayModeInt++;

		if (displayModeInt > DebugDisplayMode.ADVANCED.toInt())
		{
			displayModeInt = DebugDisplayMode.NONE.toInt();
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
		advanced.visible = displayMode == ADVANCED;
	}

	override function __enterFrame(deltaTime:Int)
	{
		if (#if html5 FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.THREE #else FlxG.keys.justPressed.F3 #end)
		{
			cycleDisplayMode();
		}

		super.__enterFrame(deltaTime);
	}
}

/**
 * The different modes the overlay can be displayed.
 */
enum abstract DebugDisplayMode(Int) from Int to Int
{
	/**
	 * The overlay will be hidden.
	 */
	var NONE = 0;

	/**
	 * The overlay will only show the FPS counter and the Garbage Collector memory.
	 */
	var SIMPLE = 1;

	/**
	 * The overlay will show important information about the engine.
	 */
	var ADVANCED = 2;

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

	public function toInt():Int
	{
		return switch (this)
		{
			case NONE: 0;
			case SIMPLE: 1;
			case ADVANCED: 2;
			case _: 0;
		};
	}
}
