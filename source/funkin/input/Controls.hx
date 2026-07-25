package funkin.input;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

import funkin.system.FunkinSave;

class Controls extends FlxActionSet
{
	@:noCompletion static function init()
	{
		FlxG.inputs.addUniqueType(new FlxActionManager());
	}

	// gameplay controls
	var note_left:FunkinAction = new FunkinAction(Action.NOTE_LEFT);
	var note_down:FunkinAction = new FunkinAction(Action.NOTE_DOWN);
	var note_up:FunkinAction = new FunkinAction(Action.NOTE_UP);
	var note_right:FunkinAction = new FunkinAction(Action.NOTE_RIGHT);
	var dodge:FunkinAction = new FunkinAction(Action.DODGE);
	var reset:FunkinAction = new FunkinAction(Action.RESET);

	// ui and overworld controls
	var ui_left:FunkinAction = new FunkinAction(Action.UI_LEFT);
	var ui_right:FunkinAction = new FunkinAction(Action.UI_RIGHT);
	var ui_up:FunkinAction = new FunkinAction(Action.UI_UP);
	var ui_down:FunkinAction = new FunkinAction(Action.UI_DOWN);
	var accept:FunkinAction = new FunkinAction(Action.ACCEPT);
	var back:FunkinAction = new FunkinAction(Action.BACK);
	var pause:FunkinAction = new FunkinAction(Action.PAUSE);
	var fullscreen:FunkinAction = new FunkinAction(Action.FULLSCREEN);
	var interact:FunkinAction = new FunkinAction(Action.INTERACT);
	var map:FunkinAction = new FunkinAction(Action.MAP);
	var chat:FunkinAction = new FunkinAction(Action.CHAT);

	// volume controls
	var volume_up:FunkinAction = new FunkinAction(Action.VOLUME_UP);
	var volume_down:FunkinAction = new FunkinAction(Action.VOLUME_DOWN);
	var volume_mute:FunkinAction = new FunkinAction(Action.VOLUME_MUTE);

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

	public var ACCEPT_P(get, never):Bool;

	public var ACCEPT_R(get, never):Bool;

	public var BACK(get, never):Bool;

	public var PAUSE(get, never):Bool;

	public var FULLSCREEN(get, never):Bool;

	public var INTERACT(get, never):Bool;

	public var INTERACT_P(get, never):Bool;

	public var INTERACT_R(get, never):Bool;

	public var MAP(get, never):Bool;

	public var MAP_P(get, never):Bool;

	public var MAP_R(get, never):Bool;

	public var CHAT(get, never):Bool;

	public var VOLUME_UP(get, never):Bool;

	public var VOLUME_UP_P(get, never):Bool;

	public var VOLUME_UP_R(get, never):Bool;

	public var VOLUME_DOWN(get, never):Bool;

	public var VOLUME_DOWN_P(get, never):Bool;

	public var VOLUME_DOWN_R(get, never):Bool;

	public var VOLUME_MUTE(get, never):Bool;

	/**
	 * The controls's ID.
	 */
	public var ID(default, null):Int;

	/**
	 * The current keyboard scheme.
	 */
	public var keyboardScheme(default, null):KeyboardScheme;

	/**
	 * Whether the controls has a gamepad connected.
	 */
	public var hasGamepadConnected(default, null):Bool = false;

	/**
	 * The ID of the gamepad connected to this `Controls` instance.
	 */
	var activeGamepad:Int = -1;

	public function new(id:Int, name:String, ?keyboardScheme:KeyboardScheme)
	{
		this.ID = id;

		super(name);

		add(note_left);
		add(note_down);
		add(note_up);
		add(note_right);
		add(dodge);
		add(reset);

		add(ui_left);
		add(ui_down);
		add(ui_up);
		add(ui_right);
		add(accept);
		add(back);
		add(pause);
		add(fullscreen);
		add(interact);
		add(map);
		add(chat);

		add(volume_up);
		add(volume_down);
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
	 * @param scheme 	The keyboard scheme.
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

	public function addGamepad(gamepad:FlxGamepad)
	{
		if (FunkinSave.hasControls(this.ID, Gamepad(gamepad.id)))
		{
			var controlsData:Null<ControlBindsSaveData> = FunkinSave.getControls(this.ID, Gamepad(gamepad.id));
			addGamepadFromSaveData(Gamepad(gamepad.id), controlsData);
		}
		else
		{
			addGamepadFromDefaults(this.ID);
		}

		hasGamepadConnected = true;
		activeGamepad = gamepad.id;
	}

	function addGamepadFromSaveData(device:InputDevice, data:ControlBindsSaveData)
	{
		for (control in Control.createAll())
		{
			var inputs:Array<Int> = Reflect.field(data, control.getName());

			if (inputs != null)
			{
				if (inputs.length == 0)
				{
					switch (device)
					{
						case Keyboard:
							bindKeys(control, getDefaultKeybinds(Solo, control));

						case Gamepad(id):
							bindButtons(control, id, getDefaultButtons(control));
					}
				}
				else if (inputs == [FlxKey.NONE])
				{
					// control is unbound, just do nothing
				}
				else
				{
					switch (device)
					{
						case Keyboard:
							bindKeys(control, inputs.copy());

						case Gamepad(id):
							bindButtons(control, id, inputs.copy());
					}
				}
			}
			else
			{
				switch (device)
				{
					case Keyboard:
						bindKeys(control, getDefaultKeybinds(Solo, control));

					case Gamepad(id):
						bindButtons(control, id, getDefaultButtons(control));
				}
			}
		}
	}

	function addGamepadFromDefaults(id:Int)
	{
		for (control in Control.createAll())
		{
			bindButtons(control, id, getDefaultButtons(control));
		}
	}

	public function removeGamepad(gamepad:FlxGamepad)
	{
		if (FlxG.gamepads.getByID(activeGamepad) != gamepad)
		{
			return;
		}

		for (action in digitalActions)
		{
			for (input in action.inputs)
			{
				if (isGamepad(input, activeGamepad))
				{
					action.remove(input);
				}
			}
		}

		hasGamepadConnected = false;
		activeGamepad = -1;
	}

	public function createSaveData(device:InputDevice):Null<ControlBindsSaveData>
	{
		var isEmpty:Bool = true;
		var data = {};

		for (control in Control.createAll())
		{
			var inputs:Array<Int> = getInputsFor(control, device);
			isEmpty = isEmpty && inputs.length == 0;

			if (inputs.length == 0)
			{
				inputs = [FlxKey.NONE];
			}
			else
			{
				inputs = inputs.distinct();
			}

			Reflect.setField(data, control.getName(), inputs);
		}

		return isEmpty ? null : data;
	}

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
	 * @param id			The connected gamepad ID.
	 * @param buttons The `FlxGamepadInputID`s to add.
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

	public function getInputsFor(control:Control, device:InputDevice):Array<Int>
	{
		var list:Array<Int> = [];

		switch (device)
		{
			case Keyboard:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
					{
						list.push(input.inputID);
					}
				}

			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (isGamepad(input, id))
					{
						list.push(input.inputID);
					}
				}
		}

		return list;
	}

	/**
	 * @param control The control type.
	 * @return The matching `FunkinAction`.
	 */
	public function getActionFromControl(control:Control):FunkinAction
	{
		return switch (control)
		{
			case NOTE_LEFT: note_left;
			case NOTE_DOWN: note_down;
			case NOTE_UP: note_up;
			case NOTE_RIGHT: note_right;
			case DODGE: dodge;
			case RESET: reset;

			case UI_LEFT: ui_left;
			case UI_DOWN: ui_down;
			case UI_UP: ui_up;
			case UI_RIGHT: ui_right;

			case ACCEPT: accept;
			case BACK: back;
			case PAUSE: pause;
			case FULLSCREEN: fullscreen;

			case INTERACT: interact;
			case MAP: map;
			case CHAT: chat;

			case VOLUME_UP: volume_up;
			case VOLUME_DOWN: volume_down;
			case VOLUME_MUTE: volume_mute;
		}
	}

	function forEachBound(control:Control, func:FlxActionDigital -> FlxInputState -> Void)
	{
		switch (control)
		{
			case Control.NOTE_LEFT:
				func(note_left, JUST_PRESSED);
				func(note_left, PRESSED);
				func(note_left, JUST_RELEASED);

			case Control.NOTE_DOWN:
				func(note_down, JUST_PRESSED);
				func(note_down, PRESSED);
				func(note_down, JUST_RELEASED);

			case Control.NOTE_UP:
				func(note_up, JUST_PRESSED);
				func(note_up, PRESSED);
				func(note_up, JUST_RELEASED);

			case Control.NOTE_RIGHT:
				func(note_right, JUST_PRESSED);
				func(note_right, PRESSED);
				func(note_right, JUST_RELEASED);

			case Control.DODGE:
				func(dodge, JUST_PRESSED);
				func(dodge, PRESSED);
				func(dodge, JUST_RELEASED);

			case Control.RESET:
				func(reset, JUST_PRESSED);

			case Control.UI_LEFT:
				func(ui_left, JUST_PRESSED);
				func(ui_left, PRESSED);
				func(ui_left, JUST_RELEASED);

			case Control.UI_DOWN:
				func(ui_down, JUST_PRESSED);
				func(ui_down, PRESSED);
				func(ui_down, JUST_RELEASED);

			case Control.UI_UP:
				func(ui_up, JUST_PRESSED);
				func(ui_up, PRESSED);
				func(ui_up, JUST_RELEASED);

			case Control.UI_RIGHT:
				func(ui_right, JUST_PRESSED);
				func(ui_right, PRESSED);
				func(ui_right, JUST_RELEASED);

			case Control.ACCEPT:
				func(accept, JUST_PRESSED);
				func(accept, PRESSED);
				func(accept, JUST_RELEASED);

			case Control.BACK:
				func(back, JUST_PRESSED);

			case Control.PAUSE:
				func(pause, JUST_PRESSED);

			case Control.FULLSCREEN:
				func(fullscreen, JUST_PRESSED);

			case Control.INTERACT:
				func(interact, JUST_PRESSED);
				func(interact, PRESSED);
				func(interact, JUST_RELEASED);

			case Control.MAP:
				func(map, JUST_PRESSED);
				func(map, PRESSED);
				func(map, JUST_RELEASED);

			case Control.CHAT:
				func(chat, JUST_PRESSED);

			case Control.VOLUME_UP:
				func(volume_up, JUST_PRESSED);
				func(volume_up, PRESSED);
				func(volume_up, JUST_RELEASED);

			case Control.VOLUME_DOWN:
				func(volume_down, JUST_PRESSED);
				func(volume_down, PRESSED);
				func(volume_down, JUST_RELEASED);

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
		return ui_left.checkJustPressed();
	}

	function get_UI_LEFT_P():Bool
	{
		return ui_left.checkPressed();
	}

	function get_UI_LEFT_R():Bool
	{
		return ui_left.checkJustReleased();
	}

	function get_UI_DOWN():Bool
	{
		return ui_down.checkJustPressed();
	}

	function get_UI_DOWN_P():Bool
	{
		return ui_down.checkPressed();
	}

	function get_UI_DOWN_R():Bool
	{
		return ui_down.checkJustReleased();
	}

	function get_UI_UP():Bool
	{
		return ui_up.checkJustPressed();
	}

	function get_UI_UP_P():Bool
	{
		return ui_up.checkPressed();
	}

	function get_UI_UP_R():Bool
	{
		return ui_up.checkJustReleased();
	}

	function get_UI_RIGHT():Bool
	{
		return ui_right.checkJustPressed();
	}

	function get_UI_RIGHT_P():Bool
	{
		return ui_right.checkPressed();
	}

	function get_UI_RIGHT_R():Bool
	{
		return ui_right.checkJustReleased();
	}

	function get_ACCEPT():Bool
	{
		return accept.checkJustPressed();
	}

	function get_ACCEPT_P():Bool
	{
		return accept.checkPressed();
	}

	function get_ACCEPT_R():Bool
	{
		return accept.checkJustReleased();
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

	function get_INTERACT():Bool
	{
		return interact.checkJustPressed();
	}

	function get_INTERACT_P():Bool
	{
		return interact.checkPressed();
	}

	function get_INTERACT_R():Bool
	{
		return interact.checkJustReleased();
	}

	function get_MAP():Bool
	{
		return map.checkJustPressed();
	}

	function get_MAP_P():Bool
	{
		return map.checkPressed();
	}

	function get_MAP_R():Bool
	{
		return map.checkJustReleased();
	}

	function get_CHAT():Bool
	{
		return chat.check();
	}

	function get_VOLUME_UP():Bool
	{
		return volume_up.checkJustPressed();
	}

	function get_VOLUME_UP_P():Bool
	{
		return volume_up.checkPressed();
	}

	function get_VOLUME_UP_R():Bool
	{
		return volume_up.checkJustReleased();
	}

	function get_VOLUME_DOWN():Bool
	{
		return volume_down.checkJustPressed();
	}

	function get_VOLUME_DOWN_P():Bool
	{
		return volume_down.checkPressed();
	}

	function get_VOLUME_DOWN_R():Bool
	{
		return volume_down.checkJustReleased();
	}

	function get_VOLUME_MUTE():Bool
	{
		return volume_mute.check();
	}
}

enum abstract Action(String) to String from String
{
	var NOTE_LEFT = 'note_left';

	var NOTE_DOWN = 'note_down';

	var NOTE_UP = 'note_up';

	var NOTE_RIGHT = 'note_right';

	var DODGE = 'dodge';

	var RESET = 'reset';

	var UI_LEFT = 'ui_left';

	var UI_RIGHT = 'ui_right';

	var UI_UP = 'ui_up';

	var UI_DOWN = 'ui_down';

	var ACCEPT = 'accept';

	var BACK = 'back';

	var PAUSE = 'pause';

	var FULLSCREEN = 'fullscreen';

	var INTERACT = 'interact';

	var MAP = 'map';

	var CHAT = 'chat';

	var VOLUME_UP = 'volume_up';

	var VOLUME_DOWN = 'volume_down';

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

enum InputDevice
{
	Keyboard;
	Gamepad(id:Int);
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
}
