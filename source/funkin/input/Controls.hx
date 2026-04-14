package funkin.input;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class Controls extends FlxActionSet
{
	static function init()
	{
		FlxG.inputs.addUniqueType(new FlxActionManager());
	}

	// gameplay controls
	var note_left:FlxActionDigital = new FlxActionDigital(Action.NOTE_LEFT);
	var note_left_p:FlxActionDigital = new FlxActionDigital(Action.NOTE_LEFT_PRESSED);
	var note_left_r:FlxActionDigital = new FlxActionDigital(Action.NOTE_LEFT_RELEASED);
	var note_down:FlxActionDigital = new FlxActionDigital(Action.NOTE_DOWN);
	var note_down_p:FlxActionDigital = new FlxActionDigital(Action.NOTE_DOWN_PRESSED);
	var note_down_r:FlxActionDigital = new FlxActionDigital(Action.NOTE_DOWN_RELEASED);
	var note_up:FlxActionDigital = new FlxActionDigital(Action.NOTE_UP);
	var note_up_p:FlxActionDigital = new FlxActionDigital(Action.NOTE_UP_PRESSED);
	var note_up_r:FlxActionDigital = new FlxActionDigital(Action.NOTE_UP_RELEASED);
	var note_right:FlxActionDigital = new FlxActionDigital(Action.NOTE_RIGHT);
	var note_right_p:FlxActionDigital = new FlxActionDigital(Action.NOTE_RIGHT_PRESSED);
	var note_right_r:FlxActionDigital = new FlxActionDigital(Action.NOTE_RIGHT_RELEASED);
	var dodge:FlxActionDigital = new FlxActionDigital(Action.DODGE);
	var dodge_p:FlxActionDigital = new FlxActionDigital(Action.DODGE_PRESSED);
	var dodge_r:FlxActionDigital = new FlxActionDigital(Action.DODGE_RELEASED);
	var reset:FlxActionDigital = new FlxActionDigital(Action.RESET);

	// ui and overworld controls
	var ui_left:FlxActionDigital = new FlxActionDigital(Action.UI_LEFT);
	var ui_left_p:FlxActionDigital = new FlxActionDigital(Action.UI_LEFT_PRESSED);
	var ui_left_r:FlxActionDigital = new FlxActionDigital(Action.UI_LEFT_RELEASED);
	var ui_right:FlxActionDigital = new FlxActionDigital(Action.UI_RIGHT);
	var ui_right_p:FlxActionDigital = new FlxActionDigital(Action.UI_RIGHT_PRESSED);
	var ui_right_r:FlxActionDigital = new FlxActionDigital(Action.UI_RIGHT_RELEASED);
	var ui_up:FlxActionDigital = new FlxActionDigital(Action.UI_UP);
	var ui_up_p:FlxActionDigital = new FlxActionDigital(Action.UI_UP_PRESSED);
	var ui_up_r:FlxActionDigital = new FlxActionDigital(Action.UI_UP_RELEASED);
	var ui_down:FlxActionDigital = new FlxActionDigital(Action.UI_DOWN);
	var ui_down_p:FlxActionDigital = new FlxActionDigital(Action.UI_DOWN_PRESSED);
	var ui_down_r:FlxActionDigital = new FlxActionDigital(Action.UI_DOWN_RELEASED);
	var accept:FlxActionDigital = new FlxActionDigital(Action.ACCEPT);
	var back:FlxActionDigital = new FlxActionDigital(Action.BACK);
	var pause:FlxActionDigital = new FlxActionDigital(Action.PAUSE);
	var fullscreen:FlxActionDigital = new FlxActionDigital(Action.FULLSCREEN);
	var interact:FlxActionDigital = new FlxActionDigital(Action.INTERACT);
	var interact_p:FlxActionDigital = new FlxActionDigital(Action.INTERACT_PRESSED);
	var interact_r:FlxActionDigital = new FlxActionDigital(Action.INTERACT_RELEASED);
	var map:FlxActionDigital = new FlxActionDigital(Action.MAP);
	var map_p:FlxActionDigital = new FlxActionDigital(Action.MAP_PRESSED);
	var map_r:FlxActionDigital = new FlxActionDigital(Action.MAP_RELEASED);
	var chat:FlxActionDigital = new FlxActionDigital(Action.CHAT);

	// volume controls
	var volume_up:FlxActionDigital = new FlxActionDigital(Action.VOLUME_UP);
	var volume_up_p:FlxActionDigital = new FlxActionDigital(Action.VOLUME_UP_PRESSED);
	var volume_up_r:FlxActionDigital = new FlxActionDigital(Action.VOLUME_UP_RELEASED);
	var volume_down:FlxActionDigital = new FlxActionDigital(Action.VOLUME_DOWN);
	var volume_down_p:FlxActionDigital = new FlxActionDigital(Action.VOLUME_DOWN_PRESSED);
	var volume_down_r:FlxActionDigital = new FlxActionDigital(Action.VOLUME_DOWN_RELEASED);
	var volume_mute:FlxActionDigital = new FlxActionDigital(Action.VOLUME_MUTE);

	public var UI_LEFT(get, never):Bool;

	public var UI_LEFT_P(get, never):Bool;

	public var UI_LEFT_R(get, never):Bool;

	public var UI_DOWN(get, never):Bool;

	public var UI_DOWN_P(get, never):Bool;

	public var UI_DOWN_R(get, never):Bool;

	public var UI_UP(get, never):Bool;

	public var UI_UP_P(get, never):Bool;

	public var UI_UP_R(get, never):Bool;

	public var UI_RIGHT(get, never):Bool;

	public var UI_RIGHT_P(get, never):Bool;

	public var UI_RIGHT_R(get, never):Bool;

	public var ACCEPT(get, never):Bool;

	public var BACK(get, never):Bool;

	public var PAUSE(get, never):Bool;

	public var FULLSCREEN(get, never):Bool;

	public var VOLUME_UP(get, never):Bool;

	public var VOLUME_UP_P(get, never):Bool;

	public var VOLUME_UP_R(get, never):Bool;

	public var VOLUME_DOWN(get, never):Bool;

	public var VOLUME_DOWN_P(get, never):Bool;

	public var VOLUME_DOWN_R(get, never):Bool;

	public var VOLUME_MUTE(get, never):Bool;

	/**
	 * The current keyboard scheme.
	 */
	public var keyboardScheme(default, null):KeyboardScheme;

	/**
	 * Whether the controls has a gamepad connected.
	 */
	public var hasGamepadConnected(default, null):Bool = false;

	public function new(name:String, ?keyboardScheme:KeyboardScheme)
	{
		super(name);

		add(note_left);
		add(note_left_p);
		add(note_left_r);
		add(note_down);
		add(note_down_p);
		add(note_down_r);
		add(note_up);
		add(note_up_p);
		add(note_up_r);
		add(note_right);
		add(note_right_p);
		add(note_right_r);
		add(dodge);
		add(dodge_p);
		add(dodge_r);

		add(ui_left);
		add(ui_left_p);
		add(ui_left_r);
		add(ui_down);
		add(ui_down_p);
		add(ui_down_r);
		add(ui_up);
		add(ui_up_p);
		add(ui_up_r);
		add(ui_right);
		add(ui_right_p);
		add(ui_right_r);
		add(accept);
		add(back);
		add(pause);
		add(fullscreen);
		add(reset);
		add(interact);
		add(interact_p);
		add(interact_r);
		add(map);
		add(map_p);
		add(map_r);
		add(chat);

		add(volume_up);
		add(volume_up_p);
		add(volume_up_r);
		add(volume_down);
		add(volume_down_p);
		add(volume_down_r);
		add(volume_mute);

		setKeyboardScheme(keyboardScheme ?? None, false);
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset:Bool = true)
	{
		if (reset)
		{
			removeKeyboardBinds();
		}

		bindKeys(Control.NOTE_LEFT, getDefaultKeybinds(scheme, Control.NOTE_LEFT));
		bindKeys(Control.NOTE_DOWN, getDefaultKeybinds(scheme, Control.NOTE_DOWN));
		bindKeys(Control.NOTE_UP, getDefaultKeybinds(scheme, Control.NOTE_UP));
		bindKeys(Control.NOTE_RIGHT, getDefaultKeybinds(scheme, Control.NOTE_RIGHT));
		bindKeys(Control.DODGE, getDefaultKeybinds(scheme, Control.DODGE));
		bindKeys(Control.RESET, getDefaultKeybinds(scheme, Control.RESET));

		bindKeys(Control.UI_LEFT, getDefaultKeybinds(scheme, Control.UI_LEFT));
		bindKeys(Control.UI_DOWN, getDefaultKeybinds(scheme, Control.UI_DOWN));
		bindKeys(Control.UI_UP, getDefaultKeybinds(scheme, Control.UI_UP));
		bindKeys(Control.UI_RIGHT, getDefaultKeybinds(scheme, Control.UI_RIGHT));

		bindKeys(Control.ACCEPT, getDefaultKeybinds(scheme, Control.ACCEPT));
		bindKeys(Control.BACK, getDefaultKeybinds(scheme, Control.BACK));
		bindKeys(Control.PAUSE, getDefaultKeybinds(scheme, Control.PAUSE));
		bindKeys(Control.FULLSCREEN, getDefaultKeybinds(scheme, Control.FULLSCREEN));

		bindKeys(Control.INTERACT, getDefaultKeybinds(scheme, Control.INTERACT));
		bindKeys(Control.MAP, getDefaultKeybinds(scheme, Control.MAP));

		bindKeys(Control.CHAT, getDefaultKeybinds(scheme, Control.CHAT));

		bindKeys(Control.VOLUME_UP, getDefaultKeybinds(scheme, Control.VOLUME_UP));
		bindKeys(Control.VOLUME_DOWN, getDefaultKeybinds(scheme, Control.VOLUME_DOWN));
		bindKeys(Control.VOLUME_MUTE, getDefaultKeybinds(scheme, Control.VOLUME_MUTE));

		this.keyboardScheme = scheme;
	}

	/**
	 * @param control The type of action to retrieve the keybinds from.
	 * @return The default keybinds of said action.
	 */
	public function getDefaultKeybinds(scheme:KeyboardScheme, control:Control):Array<FlxKey>
	{
		switch (scheme)
		{
			case Solo:
				switch (control)
				{
					case Control.NOTE_LEFT: return [A, LEFT];
					case Control.NOTE_DOWN: return [S, DOWN];
					case Control.NOTE_UP: return [W, UP];
					case Control.NOTE_RIGHT: return [D, RIGHT];
					case Control.DODGE: return [SPACE, SHIFT];
					case Control.RESET: return [R];

					case Control.UI_LEFT: return [A, LEFT];
					case Control.UI_DOWN: return [S, DOWN];
					case Control.UI_UP: return [W, UP];
					case Control.UI_RIGHT: return [D, RIGHT];

					case Control.ACCEPT: return [ENTER, SPACE];
					case Control.BACK: return [BACKSPACE, ESCAPE];
					case Control.PAUSE: return [ENTER, ESCAPE];
					case Control.FULLSCREEN: return [F11];

					case Control.INTERACT: return [E, SPACE];
					case Control.MAP: return [TAB];

					case Control.CHAT: return [T];

					case Control.VOLUME_UP: return [PLUS, NUMPADPLUS];
					case Control.VOLUME_DOWN: return [MINUS, NUMPADMINUS];
					case Control.VOLUME_MUTE: return [ZERO, NUMPADZERO];
				}

			case Duo(true):
				switch (control)
				{
					case Control.NOTE_LEFT: return [A];
					case Control.NOTE_DOWN: return [S];
					case Control.NOTE_UP: return [W];
					case Control.NOTE_RIGHT: return [D];
					case Control.DODGE: return [SPACE];
					case Control.RESET: return [R];

					case Control.UI_LEFT: return [A];
					case Control.UI_DOWN: return [S];
					case Control.UI_UP: return [W];
					case Control.UI_RIGHT: return [D];

					case Control.ACCEPT: return [ENTER];
					case Control.BACK: return [BACKSPACE];
					case Control.PAUSE: return [ENTER];
					case Control.FULLSCREEN: return [F11];

					case Control.INTERACT: return [E];
					case Control.MAP: return [TAB];

					case Control.CHAT: return [T];

					case Control.VOLUME_UP: return [PLUS];
					case Control.VOLUME_DOWN: return [MINUS];
					case Control.VOLUME_MUTE: return [ZERO];
				}

			case Duo(false):
				switch (control)
				{
					case Control.NOTE_LEFT: return [LEFT];
					case Control.NOTE_DOWN: return [DOWN];
					case Control.NOTE_UP: return [UP];
					case Control.NOTE_RIGHT: return [RIGHT];
					case Control.DODGE: return [SHIFT];
					case Control.RESET: return [];

					case Control.UI_LEFT: return [LEFT];
					case Control.UI_DOWN: return [DOWN];
					case Control.UI_UP: return [UP];
					case Control.UI_RIGHT: return [RIGHT];

					case Control.ACCEPT: return [SPACE];
					case Control.BACK: return [ESCAPE];
					case Control.PAUSE: return [ESCAPE];
					case Control.FULLSCREEN: return [];

					case Control.INTERACT: return [SPACE];
					case Control.MAP: return [];

					case Control.CHAT: return [];

					case Control.VOLUME_UP: return [NUMPADPLUS];
					case Control.VOLUME_DOWN: return [NUMPADMINUS];
					case Control.VOLUME_MUTE: return [NUMPADZERO];
				}

			default:
		}

		return [];
	}

	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		forEachBound(control, function(action:FlxActionDigital, state:FlxInputState)
		{
			addKeys(action, keys, state);
		});
	}

	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		forEachBound(control, function(action:FlxActionDigital, _)
		{
			removeKeys(action, keys);
		});
	}

	/**
	 * Adds the keys to the specified action.
	 *
	 * @param action 	The action to add the keys.
	 * @param keys 		The `FlxKey`s to add.
	 * @param state 	What state should the keys trigger when pressed or released.
	 */
	public function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
		{
			if (key == NONE)
			{
				continue;
			}

			action.addKey(key, state);
		}
	}

	/**
	 * Removes the keys from the specified action.
	 *
	 * @param action 	The action to remove the keys.
	 * @param keys 		The `FlxKey`s to remove.
	 */
	public function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		for (input in action.inputs)
		{
			if (input.device == KEYBOARD && keys.indexOf(input.deviceID) != -1)
			{
				action.remove(input);
			}
		}
	}

	// TODO
	public function addGamepad(id:Int) {}

	public function getDefaultButtons(control:Control):Array<FlxGamepadInputID>
	{
		switch (control)
		{
			case Control.NOTE_LEFT:
				return [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT];
			case Control.NOTE_DOWN:
				return [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN];
			case Control.NOTE_UP:
				return [DPAD_UP, LEFT_STICK_DIGITAL_UP];
			case Control.NOTE_RIGHT:
				return [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT];
			case Control.DODGE:
				return [LEFT_SHOULDER, RIGHT_SHOULDER];
			case Control.RESET:
				return [];

			case Control.UI_LEFT:
				return [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT];
			case Control.UI_DOWN:
				return [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN];
			case Control.UI_UP:
				return [DPAD_UP, LEFT_STICK_DIGITAL_UP];
			case Control.UI_RIGHT:
				return [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT];

			case Control.ACCEPT:
				return [A];
			case Control.BACK:
				return [B];
			case Control.PAUSE:
				return [START];
			case Control.FULLSCREEN:
				return [];

			case Control.INTERACT:
				return [A];
			case Control.MAP:
				return [LEFT_SHOULDER, RIGHT_SHOULDER];

			case Control.CHAT:
				return [];

			case Control.VOLUME_UP:
				return [];
			case Control.VOLUME_DOWN:
				return [];
			case Control.VOLUME_MUTE:
				return [];
		}
	}

	public function bindButtons(control:Control, id:Int, buttons:Array<FlxGamepadInputID>)
	{
		forEachBound(control, function(action:FlxActionDigital, state:FlxInputState)
		{
			addButtons(action, id, buttons, state);
		});
	}

	/**
	 * Adds the buttons to the specified action.
	 *
	 * @param action 	The action to add the keys.
	 * @param buttons The `FlxGamepadInputID`s to add.
	 * @param id			The connected gamepad ID.
	 * @param state 	What state should the keys trigger when pressed or released.
	 */
	public function addButtons(action:FlxActionDigital, id:Int, buttons:Array<FlxGamepadInputID>, state:FlxInputState)
	{
		for (button in buttons)
		{
			if (button == NONE)
			{
				continue;
			}

			action.addGamepad(button, state, id);
		}
	}

	function isGamepad(input:FlxActionInput, id:Int):Bool
	{
		return input.device == GAMEPAD && (input.deviceID == FlxInputDeviceID.ALL || input.deviceID == id);
	}

	function forEachBound(control:Control, func:FlxActionDigital -> FlxInputState -> Void)
	{
		switch (control)
		{
			case Control.NOTE_LEFT:
				func(note_left, JUST_PRESSED);
				func(note_left_p, PRESSED);
				func(note_left_r, JUST_RELEASED);

			case Control.NOTE_DOWN:
				func(note_down, JUST_PRESSED);
				func(note_down_p, PRESSED);
				func(note_down_r, JUST_RELEASED);

			case Control.NOTE_UP:
				func(note_up, JUST_PRESSED);
				func(note_up_p, PRESSED);
				func(note_up_r, JUST_RELEASED);

			case Control.NOTE_RIGHT:
				func(note_right, JUST_PRESSED);
				func(note_right_p, PRESSED);
				func(note_right_r, JUST_RELEASED);

			case Control.DODGE:
				func(dodge, JUST_PRESSED);
				func(dodge_p, PRESSED);
				func(dodge_r, JUST_RELEASED);

			case Control.RESET:
				func(reset, JUST_PRESSED);

			case Control.UI_LEFT:
				func(ui_left, JUST_PRESSED);
				func(ui_left_p, PRESSED);
				func(ui_left_r, JUST_RELEASED);

			case Control.UI_DOWN:
				func(ui_down, JUST_PRESSED);
				func(ui_down_p, PRESSED);
				func(ui_down_r, JUST_RELEASED);

			case Control.UI_UP:
				func(ui_up, JUST_PRESSED);
				func(ui_up_p, PRESSED);
				func(ui_up_r, JUST_RELEASED);

			case Control.UI_RIGHT:
				func(ui_right, JUST_PRESSED);
				func(ui_right_p, PRESSED);
				func(ui_right_r, JUST_RELEASED);

			case Control.ACCEPT:
				func(accept, JUST_PRESSED);

			case Control.BACK:
				func(back, JUST_PRESSED);

			case Control.PAUSE:
				func(pause, JUST_PRESSED);

			case Control.FULLSCREEN:
				func(fullscreen, JUST_PRESSED);

			case Control.INTERACT:
				func(interact, JUST_PRESSED);
				func(interact_p, PRESSED);
				func(interact_r, JUST_RELEASED);

			case Control.MAP:
				func(map, JUST_PRESSED);
				func(map_p, PRESSED);
				func(map_r, JUST_RELEASED);

			case Control.CHAT:
				func(chat, JUST_PRESSED);

			case Control.VOLUME_UP:
				func(volume_up, JUST_PRESSED);
				func(volume_up_p, PRESSED);
				func(volume_up_r, JUST_RELEASED);

			case Control.VOLUME_DOWN:
				func(volume_down, JUST_PRESSED);
				func(volume_down_p, PRESSED);
				func(volume_down_r, JUST_RELEASED);

			case Control.VOLUME_MUTE:
				func(volume_mute, JUST_PRESSED);
		}
	}

	function removeKeyboardBinds()
	{
		for (action in digitalActions)
		{
			for (input in action.inputs)
			{
				if (input.device == KEYBOARD)
				{
					action.remove(input);
				}
			}
		}
	}

	function removeGamepadBinds()
	{
		for (action in digitalActions)
		{
			for (input in action.inputs)
			{
				if (input.device == GAMEPAD)
				{
					action.remove(input);
				}
			}
		}
	}

	function get_UI_LEFT():Bool
	{
		return ui_left.check();
	}

	function get_UI_LEFT_P():Bool
	{
		return ui_left_p.check();
	}

	function get_UI_LEFT_R():Bool
	{
		return ui_left_r.check();
	}

	function get_UI_DOWN():Bool
	{
		return ui_down.check();
	}

	function get_UI_DOWN_P():Bool
	{
		return ui_down_p.check();
	}

	function get_UI_DOWN_R():Bool
	{
		return ui_down_r.check();
	}

	function get_UI_UP():Bool
	{
		return ui_up.check();
	}

	function get_UI_UP_P():Bool
	{
		return ui_up_p.check();
	}

	function get_UI_UP_R():Bool
	{
		return ui_up_r.check();
	}

	function get_UI_RIGHT():Bool
	{
		return ui_right.check();
	}

	function get_UI_RIGHT_P():Bool
	{
		return ui_right_p.check();
	}

	function get_UI_RIGHT_R():Bool
	{
		return ui_right_r.check();
	}

	function get_ACCEPT():Bool
	{
		return accept.check();
	}

	function get_BACK():Bool
	{
		return back.check();
	}

	function get_PAUSE():Bool
	{
		return pause.check();
	}

	function get_FULLSCREEN():Bool
	{
		return fullscreen.check();
	}

	function get_VOLUME_UP():Bool
	{
		return volume_up.check();
	}

	function get_VOLUME_UP_P():Bool
	{
		return volume_up_p.check();
	}

	function get_VOLUME_UP_R():Bool
	{
		return volume_up_r.check();
	}

	function get_VOLUME_DOWN():Bool
	{
		return volume_down.check();
	}

	function get_VOLUME_DOWN_P():Bool
	{
		return volume_down_p.check();
	}

	function get_VOLUME_DOWN_R():Bool
	{
		return volume_down_r.check();
	}

	function get_VOLUME_MUTE():Bool
	{
		return volume_mute.check();
	}
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
}

enum abstract Action(String) to String from String
{
	var NOTE_LEFT = 'note_left';

	var NOTE_LEFT_PRESSED = 'note_left_p';

	var NOTE_LEFT_RELEASED = 'note_left_r';

	var NOTE_DOWN = 'note_down';

	var NOTE_DOWN_PRESSED = 'note_down_p';

	var NOTE_DOWN_RELEASED = 'note_down_r';

	var NOTE_UP = 'note_up';

	var NOTE_UP_PRESSED = 'note_up_p';

	var NOTE_UP_RELEASED = 'note_up_r';

	var NOTE_RIGHT = 'note_right';

	var NOTE_RIGHT_PRESSED = 'note_right_p';

	var NOTE_RIGHT_RELEASED = 'note_right_r';

	var DODGE = 'dodge';

	var DODGE_PRESSED = 'dodge_p';

	var DODGE_RELEASED = 'dodge_r';

	var RESET = 'reset';

	var UI_LEFT = 'ui_left';

	var UI_LEFT_PRESSED = 'ui_left_p';

	var UI_LEFT_RELEASED = 'ui_left_r';

	var UI_RIGHT = 'ui_right';

	var UI_RIGHT_PRESSED = 'ui_right_p';

	var UI_RIGHT_RELEASED = 'ui_right_r';

	var UI_UP = 'ui_up';

	var UI_UP_PRESSED = 'ui_up_p';

	var UI_UP_RELEASED = 'ui_up_r';

	var UI_DOWN = 'ui_down';

	var UI_DOWN_PRESSED = 'ui_down_p';

	var UI_DOWN_RELEASED = 'ui_down_r';

	var ACCEPT = 'accept';

	var BACK = 'back';

	var PAUSE = 'pause';

	var FULLSCREEN = 'fullscreen';

	var INTERACT = 'interact';

	var INTERACT_PRESSED = 'interact_p';

	var INTERACT_RELEASED = 'interact_r';

	var MAP = 'map';

	var MAP_PRESSED = 'map_p';

	var MAP_RELEASED = 'map_r';

	var CHAT = 'chat';

	var VOLUME_UP = 'volume_up';

	var VOLUME_UP_PRESSED = 'volume_up_p';

	var VOLUME_UP_RELEASED = 'volume_up_r';

	var VOLUME_DOWN = 'volume_down';

	var VOLUME_DOWN_PRESSED = 'volume_down_p';

	var VOLUME_DOWN_RELEASED = 'volume_down_r';

	var VOLUME_MUTE = 'volume_mute';
}

enum Control
{
	NOTE_LEFT;
	NOTE_DOWN;
	NOTE_UP;
	NOTE_RIGHT;
	DODGE;
	RESET;

	UI_LEFT;
	UI_RIGHT;
	UI_UP;
	UI_DOWN;
	ACCEPT;
	BACK;
	PAUSE;
	FULLSCREEN;
	INTERACT;
	MAP;
	CHAT;

	VOLUME_UP;
	VOLUME_DOWN;
	VOLUME_MUTE;
}
