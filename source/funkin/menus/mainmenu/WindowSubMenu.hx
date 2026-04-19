package funkin.menus.mainmenu;

class WindowSubMenu extends FunkinGroup<WindowButton>
{
	public var nameTranslationID(default, null):String;

	var controls(get, never):funkin.input.Controls;

	var _menuInstance:MainMenuState;
	var _parent:WindowSubMenuHandler;

	public function new(instance:MainMenuState, translationID:String)
	{
		super();

		_menuInstance = instance;
		nameTranslationID = translationID;
	}

	override function destroy()
	{
		super.destroy();

		_menuInstance = null;
		_parent = null;
	}

	public function create() {}

	public function init(parent:WindowSubMenuHandler)
	{
		_parent = parent;
	}

	public function onLanguageUpdate(language:String)
	{
		for (child in children)
		{
			child.label.text = '';
		}
	}

	function get_controls():funkin.input.Controls
	{
		return funkin.input.InputManager.controlsP1;
	}
}

class WindowButton extends FunkinSpriteGroup
{
	public var available(default, set):Bool = true;
	public var onSelect:Void -> Void = null;

	public var button:FunkinSprite;
	public var label:FunkinText;

	public var idleColor(default, set):FlxColor = FlxColor.BLACK;
	public var hoverColor(default, set):FlxColor = FlxColor.WHITE;

	var hovering(default, set):Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		button = new FunkinSprite();
		add(button);

		label = new FunkinText();
		add(label);
	}

	function set_available(value:Bool):Bool
	{
		available = value;

		if (available)
		{
			if (hovering)
			{
				button.playAnimation('hover');
				label.color = hoverColor;
			}
			else
			{
				button.playAnimation('idle');
				label.color = idleColor;
			}
		}
		else
		{
			button.playAnimation('locked');
			label.color = FlxColor.BLACK;
		}

		return available;
	}

	function set_hovering(value:Bool):Bool
	{
		hovering = value && available;

		if (hovering)
		{
			button.playAnimation('hover');
			label.color = hoverColor;
		}
		else if (available)
		{
			button.playAnimation('idle');
			label.color = idleColor;
		}

		return hovering;
	}

	function set_idleColor(value:FlxColor):FlxColor
	{
		idleColor = value;

		if (!hovering && available)
		{
			label.color = idleColor;
		}

		return idleColor;
	}

	function set_hoverColor(value:FlxColor):FlxColor
	{
		hoverColor = value;

		if (hovering && available)
		{
			label.color = hoverColor;
		}

		return hoverColor;
	}
}
