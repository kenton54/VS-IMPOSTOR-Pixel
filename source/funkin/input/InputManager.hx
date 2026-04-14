package funkin.input;

import flixel.input.gamepad.FlxGamepad;

import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
 * Handles all inputs.
 */
class InputManager
{
	/**
	 * Whether the manager is enabled or not.
	 *
	 * When disabled, the game won't read any input coming from the user.
	 */
	public static var enabled(default, null):Bool = true;

	/**
	 * Whether the user is navigating through the mod using their mouse or a touch.
	 */
	public static var isUsingPointer(default, null):Bool = false;

	/**
	 * Player 1's controls.
	 */
	public static var controlsP1(default, null):Controls;

	/**
	 * Player 2's controls.
	 */
	public static var controlsP2(default, null):Controls;

	/**
	 * Enables recieving input from keyboard, gamepads, mouse and touchs.
	 */
	public static function enable()
	{
		Pointer.enabled = controlsP1.active = controlsP2.active = enabled = true;
	}

	/**
	 * Disables recieving input from keyboard, gamepads, mouse and touchs.
	 */
	public static function disable()
	{
		Pointer.enabled = controlsP1.active = controlsP2.active = enabled = false;
	}

	@:allow(funkin.InitState)
	static function init()
	{
		controlsP1 = new Controls('player1', Solo);
		controlsP2 = new Controls('player2', None);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (_) -> isUsingPointer = false);
		FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, (_) -> isUsingPointer = true);
		FlxG.stage.addEventListener(TouchEvent.TOUCH_BEGIN, (_) -> isUsingPointer = true);

		FlxG.gamepads.deviceConnected.add(onGamepadAdded);

		for (i in 0...FlxG.gamepads.numActiveGamepads)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
			if (gamepad != null)
			{
				onGamepadAdded(gamepad);
			}
		}
	}

	static function onGamepadAdded(gamepad:FlxGamepad)
	{
		for (controls in [controlsP1, controlsP2])
		{
			if (!controls.hasGamepadConnected)
			{
				controls.addGamepad(gamepad.id);
			}
		}
	}
}
