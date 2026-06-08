package funkin.utils;

import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxStringUtil;

class InputUtil
{
	/**
	 * @param key The key.
	 * @return The readable name of the key.
	 */
	public static function getKeyName(key:FlxKey):String
	{
		return switch (key)
		{
			case ZERO: '0';
			case ONE: '1';
			case TWO: '2';
			case THREE: '3';
			case FOUR: '4';
			case FIVE: '5';
			case SIX: '6';
			case SEVEN: '7';
			case EIGHT: '8';
			case NINE: '9';
			case PAGEUP: 'PgUp';
			case PAGEDOWN: 'PgDown';
			case ESCAPE: 'Esc';
			case MINUS: '-';
			case PLUS: '+';
			case BACKSPACE: 'BackSpace';
			case LBRACKET: '[';
			case RBRACKET: ']';
			case SLASH: '/';
			case BACKSLASH: '\\';
			case PERIOD: '.';
			case COMMA: ',';
			case SEMICOLON: ';';
			case QUOTE: "'";
			case GRAVEACCENT: '`';
			case CONTROL: 'Ctrl';
			case ALT: 'Alt';
			case PRINTSCREEN: 'PrtScrn';
			case CAPSLOCK: 'Caps';
			case NUMLOCK: 'NumLock';
			case SCROLL_LOCK: 'ScrollLock';
			case NUMPADZERO: '#0';
			case NUMPADONE: '#1';
			case NUMPADTWO: '#2';
			case NUMPADTHREE: '#3';
			case NUMPADFOUR: '#4';
			case NUMPADFIVE: '#5';
			case NUMPADSIX: '#6';
			case NUMPADSEVEN: '#7';
			case NUMPADEIGHT: '#8';
			case NUMPADNINE: '#9';
			case NUMPADMINUS: '#-';
			case NUMPADPLUS: '#+';
			case NUMPADSLASH: '#/';
			case NUMPADMULTIPLY: '#*';
			case NUMPADPERIOD: '#.';
			default: FlxStringUtil.toTitleCase(FlxKey.toStringMap[key] ?? '?');
		}
	}

	/**
	 * @param action 			The action.
	 * @param fromIndex 	Whether to get the input of a specified index.
	 * @return The readable name of the indexed input from the action.
	 */
	public static function getActionName(action:FlxActionDigital, fromIndex:Int = 0):String
	{
		var actionInput:FlxActionInput = action.inputs[fromIndex];

		if (actionInput == null)
		{
			return '?';
		}

		return switch (actionInput.device)
		{
			case KEYBOARD | ANDROID | MOUSE | MOUSE_WHEEL: getKeyName(actionInput.inputID);
			case GAMEPAD | STEAM_CONTROLLER: getGamepadName(FlxG.gamepads.lastActive, actionInput.inputID);
			default: getKeyName(actionInput.inputID);
		}
	}

	/**
	 * @param gamepad The gamepad.
	 * @param button 	The button.
	 * @return The readable name of the button.
	 */
	public static function getGamepadName(gamepad:FlxGamepad, button:FlxGamepadInputID):String
	{
		if (gamepad == null)
		{
			return '?';
		}

		var model:FlxGamepadModel = gamepad.detectedModel ?? UNKNOWN;

		return switch (button)
		{
			case LEFT_STICK_DIGITAL_LEFT: 'Left';
			case LEFT_STICK_DIGITAL_RIGHT: 'Right';
			case LEFT_STICK_DIGITAL_UP: 'Up';
			case LEFT_STICK_DIGITAL_DOWN: 'Down';
			case LEFT_STICK_CLICK: getGamepadModelButtonName(gamepad, LEFT_STICK_CLICK, model);

			case RIGHT_STICK_DIGITAL_LEFT: 'C. Left';
			case RIGHT_STICK_DIGITAL_RIGHT: 'C. Right';
			case RIGHT_STICK_DIGITAL_UP: 'C. Up';
			case RIGHT_STICK_DIGITAL_DOWN: 'C. Down';
			case RIGHT_STICK_CLICK: getGamepadModelButtonName(gamepad, RIGHT_STICK_CLICK, model);

			case DPAD_LEFT: 'D. Left';
			case DPAD_RIGHT: 'D. Right';
			case DPAD_UP: 'D. Up';
			case DPAD_DOWN: 'D. Down';

			case LEFT_SHOULDER: getGamepadModelButtonName(gamepad, LEFT_SHOULDER, model);
			case RIGHT_SHOULDER: getGamepadModelButtonName(gamepad, RIGHT_SHOULDER, model);

			case LEFT_TRIGGER: getGamepadModelButtonName(gamepad, LEFT_TRIGGER, model);
			case RIGHT_TRIGGER: getGamepadModelButtonName(gamepad, RIGHT_TRIGGER, model);

			case LEFT_TRIGGER_BUTTON: getGamepadModelButtonName(gamepad, LEFT_TRIGGER_BUTTON, model);
			case RIGHT_TRIGGER_BUTTON: getGamepadModelButtonName(gamepad, RIGHT_TRIGGER_BUTTON, model);

			case A: getGamepadModelButtonName(gamepad, A, model);
			case B: getGamepadModelButtonName(gamepad, B, model);
			case X: getGamepadModelButtonName(gamepad, X, model);
			case Y: getGamepadModelButtonName(gamepad, Y, model);

			case START: getGamepadModelButtonName(gamepad, START, model);
			case BACK: getGamepadModelButtonName(gamepad, BACK, model);
			case GUIDE: getGamepadModelButtonName(gamepad, GUIDE, model);

			default: '?';
		}
	}

	/**
	 * @param gamepad The gamepad.
	 * @param button 	The button.
	 * @param model 	The gamepad model.
	 * @return The readable name of the button from the specific gamepad model.
	 */
	public static function getGamepadModelButtonName(gamepad:FlxGamepad, button:FlxGamepadInputID, model:FlxGamepadModel):String
	{
		if (gamepad == null)
		{
			return '?';
		}

		var attachment:FlxGamepadAttachment = gamepad.attachment ?? NONE;

		return switch (button)
		{
			case LEFT_STICK_CLICK:
				switch (model)
				{
					case PS4 | PS5 | PSVITA | OUYA: 'L3';
					case SWITCH_PRO: 'L. Stick Click';
					case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: 'Stick Click';
					case XINPUT: 'LS';
					default: 'L. Analog Click';
				}

			case RIGHT_STICK_CLICK:
				switch (model)
				{
					case PS4 | PS5 | PSVITA | OUYA: 'R3';
					case SWITCH_PRO: 'R. Stick Click';
					case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: 'Stick Click';
					case XINPUT: 'RS';
					default: 'R. Analog Click';
				}

			case A:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: 'A';
							case WII_CLASSIC_CONTROLLER: 'Classic Controller B';
						}
					case PS4 | PS5 | PSVITA: 'Cross';
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT: 'B';
					case SWITCH_JOYCON_LEFT: 'D. Down';
					case XINPUT: 'A';
					case OUYA: 'O';
					default: 'Action Down';
				}

			case B:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: 'B';
							case WII_CLASSIC_CONTROLLER: 'Classic Controller A';
						}
					case PS4 | PS5 | PSVITA: 'Circle';
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT | OUYA: 'A';
					case SWITCH_JOYCON_LEFT: 'D. Right';
					case XINPUT: 'B';
					default: 'Action Right';
				}

			case X:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: '1';
							case WII_CLASSIC_CONTROLLER: 'Classic Controller Y';
						}
					case PS4 | PS5 | PSVITA: 'Square';
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT: 'Y';
					case SWITCH_JOYCON_LEFT: 'D. Right';
					case XINPUT: 'X';
					case OUYA: 'U';
					default: 'Action Left';
				}

			case Y:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: '2';
							case WII_CLASSIC_CONTROLLER: 'Classic Controller X';
						}
					case PS4 | PS5 | PSVITA: 'Triangle';
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT: 'X';
					case SWITCH_JOYCON_LEFT: 'D. Up';
					case XINPUT | OUYA: 'Y';
					default: 'Action Up';
				}

			case LEFT_SHOULDER:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK: 'C';
							case WII_CLASSIC_CONTROLLER: 'Classic Controller ZL';
							default: '?';
						}
					case PS4 | PS5 | OUYA: 'L1';
					case SWITCH_PRO | PSVITA: 'L';
					case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: 'SL';
					case XINPUT: 'LB';
					default: 'L. Bumper';
				}

			case RIGHT_SHOULDER:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_CLASSIC_CONTROLLER: 'Classic Controller ZR';
							default: '?';
						}
					case PS4 | PS5 | OUYA: 'R1';
					case SWITCH_PRO | PSVITA: 'R';
					case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: 'SR';
					case XINPUT: 'RB';
					default: 'R. Bumper';
				}

			case LEFT_TRIGGER | LEFT_TRIGGER_BUTTON:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK: 'Z';
							case WII_CLASSIC_CONTROLLER: 'Classic Controller L';
							default: '?';
						}
					case PS4 | PS5 | OUYA: 'L2';
					case SWITCH_PRO | SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: 'ZL';
					case XINPUT: 'LT';
					default: 'L. Trigger';
				}

			case RIGHT_TRIGGER | RIGHT_TRIGGER_BUTTON:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_CLASSIC_CONTROLLER: 'Classic Controller R';
							default: '?';
						}
					case PS4 | PS5 | OUYA: 'R2';
					case SWITCH_PRO | SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: 'ZR';
					case XINPUT: 'RT';
					default: 'R. Trigger';
				}

			case START:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: 'Plus';
							case WII_CLASSIC_CONTROLLER: 'Start';
						}
					case PS4 | PS5: 'Options';
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT: 'Plus';
					case SWITCH_JOYCON_LEFT: 'Minus';
					default: 'Start';
				}

			case BACK:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: 'Minus';
							case WII_CLASSIC_CONTROLLER: 'Select';
						}
					case PS4 | PS5: 'Share';
					case SWITCH_PRO: 'Minus';
					default: 'Select';
				}

			case GUIDE:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | WII_CLASSIC_CONTROLLER | NONE: 'Home';
						}
					case PS4 | PS5: 'PS';
					case SWITCH_PRO | OUYA: 'Home';
					default: 'Guide';
				}

			case EXTRA_0:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_CLASSIC_CONTROLLER: '1';
							default: 'Extra #1';
						}
					case SWITCH_PRO: 'Capture';
					default: 'Extra #1';
				}

			case EXTRA_1:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_CLASSIC_CONTROLLER: '2';
							default: 'Extra #2';
						}
					default: 'Extra #2';
				}

			default: '?';
		}
	}

	/**
	 * @param gamepad The gamepad.
	 * @return The readable name of the gamepad's model.
	 */
	public static function getGamepadModelName(gamepad:FlxGamepad):String
	{
		if (gamepad == null)
		{
			return '?';
		}

		var model:FlxGamepadModel = gamepad.detectedModel ?? UNKNOWN;

		return switch (model)
		{
			case LOGITECH: 'Logitech';
			case OUYA: 'Ouya';
			case PS4: 'DualShock 4';
			case PS5: 'DualShock 5';
			case PSVITA: 'PSVita';
			case XINPUT: 'XBox';
			case MAYFLASH_WII_REMOTE: 'Wii Remote';
			case WII_REMOTE: 'Wii Remote';
			case MFI: 'Apple MFi';
			case SWITCH_PRO: 'Switch Pro Controller';
			case SWITCH_JOYCON_LEFT: 'Switch Left Joycon';
			case SWITCH_JOYCON_RIGHT: 'Switch Right Joycon';
			default: 'Unknown';
		}
	}

	/**
	 * @param gamepad The gamepad.
	 * @return The readable name of the gamepad's attachment.
	 */
	public static function getGamepadAttachmentName(gamepad:FlxGamepad):String
	{
		if (gamepad == null)
		{
			return '?';
		}

		var attachment:FlxGamepadAttachment = gamepad.attachment ?? NONE;

		return switch (attachment)
		{
			case WII_NUNCHUCK: 'Wii Nunchuck';
			case WII_CLASSIC_CONTROLLER: 'Wii Classic Controller';
			default: '?';
		}
	}
}
