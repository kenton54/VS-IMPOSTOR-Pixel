package funkin.menus.mainmenu;

import flixel.FlxSprite;

class MainMenuButton extends FlxTypedSpriteGroup<FlxSprite>
{
	/**
	 * The index position of the button inside the menu.
	 */
	public var index(default, null):Int;

	/**
	 * The main button.
	 */
	public var button(default, null):FunkinSprite;

	/**
	 * The button's label.
	 */
	public var label(default, null):FunkinText;

	/**
	 * The button's icon.
	 */
	public var icon(default, null):FunkinSprite;

	/**
	 * The type of button this one is.
	 */
	public var type(default, null):MainMenuButtonType;

	/**
	 * Whether the button can be interacted with or not.
	 */
	public var available(default, set):Bool;

	/**
	 * Whether the button is being hovered or not.
	 */
	public var hovered(default, null):Bool = false;

	var _idleColor:FlxColor;
	var _hoverColor:FlxColor;

	public function new(index:Int, x:Float = 0, y:Float = 0, data:MainMenuButtonsData, scale:Float = 5)
	{
		super(x, y, 3);

		this.index = index;

		type = data.type;

		var colors:Array<FlxColor> = getSelectionColorsFromType(type);
		_idleColor = colors[0];
		_hoverColor = colors[1];

		var buttonDimentions:Array<Int> = getDimentionsFromType(type);
		button = new FunkinSprite().loadGraphic(getImageFromType(type), true, buttonDimentions[0], buttonDimentions[1]);
		button.addAnimationByFrameList('idle', [0], 0);
		button.addAnimationByFrameList('hover', [1], 0);
		button.addAnimationByFrameList('locked', [2], 0);
		button.scaleSprite(scale);
		button.cursorMode = Hover;
		add(button);

		var labelPosition:Float = 4 * scale;
		label = new FunkinText(labelPosition, button.height / 2, button.width - labelPosition * 2, '', getTextSizeFromType(type));
		label.translationData = {id: data.translationID};
		label.color = _idleColor;
		label.alignment = RIGHT;
		label.y -= label.height / 2;
		add(label);

		icon = new FunkinSprite(8 * scale);
		add(icon);

		if (data.icon != null)
		{
			icon.loadGraphic(data.icon);
			icon.scaleSprite(scale);

			if (data.iconOffsets != null)
			{
				icon.x -= data.iconOffsets[0] * scale;
				icon.y += data.iconOffsets[1] * scale;
			}
		}
		else
		{
			icon.visible = false;
		}

		available = data.available;
	}

	/**
	 * Stops the button from being highlighted.
	 */
	public function idle()
	{
		button.playAnimation('idle');
		label.color = _idleColor;

		hovered = false;
	}

	/**
	 * Highlights the button.
	 */
	public function hover()
	{
		button.playAnimation('hover');
		label.color = _hoverColor;

		hovered = true;
	}

	function getSelectionColorsFromType(buttonType:MainMenuButtonType):Array<FlxColor>
	{
		return switch (buttonType)
		{
			case MAIN: [0xFF0A3C33, 0xFF105848];
			case EXTRA: [0xFFAAE2DC, 0xFFFFFFFF];
			case OTHER: [0xFFFFFFFF, 0xFFFFFFFF];
		};
	}

	function getImageFromType(buttonType:MainMenuButtonType):String
	{
		return switch (buttonType)
		{
			case MAIN: Paths.image('menus/mainmenu/mainButton');
			case EXTRA: Paths.image('menus/mainmenu/extraButton');
			case OTHER: Paths.image('menus/mainmenu/otherButton');
		};
	}

	function getDimentionsFromType(buttonType:MainMenuButtonType):Array<Int>
	{
		return switch (buttonType)
		{
			case MAIN: [90, 12];
			case EXTRA: [90, 9];
			case OTHER: [44, 6];
		};
	}

	function getTextSizeFromType(buttonType:MainMenuButtonType):Int
	{
		return switch (buttonType)
		{
			case MAIN: 32;
			case EXTRA: 25;
			case OTHER: 18;
		};
	}

	function set_available(value:Bool):Bool
	{
		available = value;

		if (!available)
		{
			button.playAnimation('locked');
			label.color = FlxColor.BLACK;
			icon.color = FlxColor.BLACK;
		}
		else
		{
			button.playAnimation('idle');
			label.color = _idleColor;
			icon.color = FlxColor.WHITE;
		}

		return value;
	}
}

/**
 * The type of button.
 */
enum MainMenuButtonType
{
	MAIN;
	EXTRA;
	OTHER;
}

typedef MainMenuButtonsData =
{
	/**
	 * The translation ID the button uses.
	 */
	var translationID:String;

	/**
	 * Whether the button can be interacted with or not.
	 */
	var available:Bool;

	/**
	 * The icon graphic to load into the button.
	 */
	var ?icon:String;

	/**
	 * The offsets of the icon.
	 */
	var ?iconOffsets:Array<Float>;

	/**
	 * The type of button to load.
	 */
	var type:MainMenuButtonType;

	/**
	 * The type of action that gets triggered when the button is selected.
	 */
	var triggerType:MainMenuButtonTriggerType;

	/**
	 * Function to trigger when the button is selected.
	 *
	 * Requires `MainMenuState` as one of its parameters.
	 */
	var onSelect:MainMenuState -> Dynamic;
}

/**
 * The trigger types of the `MainMenuButton`.
 */
enum MainMenuButtonTriggerType
{
	/**
	 * Opens a window submenu when the button is selected.
	 */
	OPEN_WINDOW;

	/**
	 * Switches to a new state when the button is selected.
	 */
	SWITCH_STATE;

	/**
	 * Opens a substate when the button is selected.
	 */
	OPEN_SUBSTATE;
}
