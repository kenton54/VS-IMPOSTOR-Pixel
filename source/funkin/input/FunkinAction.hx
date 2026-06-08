package funkin.input;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput;

class FunkinAction extends FlxActionDigital
{
	/**
	 * The latest device used globally.
	 */
	public static var lastDeviceUsed(default, null):FlxInputDevice = NONE;

	/**
	 * Checks what was the last device that was used globally.
	 */
	public static function updateLastDevice()
	{
		if (FlxG.keys.pressed.ANY)
		{
			lastDeviceUsed = KEYBOARD;
		}
		else if (FlxG.gamepads.lastActive != null)
		{
			lastDeviceUsed = GAMEPAD;
		}
		else
		{
			lastDeviceUsed = NONE;
		}
	}

	/**
	 * The name of the action, when being held.
	 */
	public var namePressed:String;

	/**
	 * The name of the action, when released.
	 */
	public var nameReleased:String;

	var cache:Map<String, {timestamp:Float, value:Bool}> = [];

	public function new(name:String = '', ?namePressed:String, ?nameReleased:String)
	{
		super(name);

		this.namePressed = namePressed;
		this.nameReleased = nameReleased;

		updateLastDevice();
	}

	override function check():Bool
	{
		return checkFiltered(JUST_PRESSED);
	}

	/**
	 * @return Whether this action was just pressed.
	 */
	public function checkJustPressed():Bool
	{
		var trigger:Bool = checkFiltered(JUST_PRESSED);

		if (trigger)
		{
			updateLastDevice();
		}

		return trigger;
	}

	/**
	 * @return Whether this action is being held.
	 */
	public function checkPressed():Bool
	{
		var trigger:Bool = checkFiltered(PRESSED);

		if (trigger)
		{
			updateLastDevice();
		}

		return trigger;
	}

	/**
	 * @return Whether this action was just released.
	 */
	public function checkJustReleased():Bool
	{
		var trigger:Bool = checkFiltered(JUST_RELEASED);

		if (trigger)
		{
			updateLastDevice();
		}

		return trigger;
	}

	/**
	 * @return Whether this action is not being held.
	 */
	public function checkReleased():Bool
	{
		var trigger:Bool = checkFiltered(RELEASED);

		if (trigger)
		{
			updateLastDevice();
		}

		return trigger;
	}

	/**
	 * See if this action was triggered, with optional filters.
	 		*
	 * @param triggerState  The trigger state to check for.
	 * @param device        The device to check for (keyboard or gamepad).
	 * @return If the action was triggered or not.
	 */
	public function checkFiltered(?triggerState:FlxInputState, ?device:FlxInputDevice):Bool
	{
		var key:String = '${triggerState}:${device}';
		var cacheEntry = cache.get(key);

		if (cacheEntry != null && cacheEntry.timestamp == FlxG.game.ticks)
		{
			return cacheEntry.value;
		}

		_x = null;
		_y = null;

		_timestamp = FlxG.game.ticks;
		triggered = false;

		var i:Int = inputs.length;
		while (i-- > 0)
		{
			var input:FlxActionInput = inputs[i];

			if (input.destroyed)
			{
				inputs.remove(input);
				continue;
			}

			input.update();

			if (triggerState != null && input.trigger != triggerState)
			{
				continue;
			}

			if (device != null && input.device != device)
			{
				continue;
			}

			if (input.check(this))
			{
				triggered = true;
			}
		}

		cache.set(key, {timestamp: FlxG.game.ticks, value: triggered});

		return triggered;
	}
}
