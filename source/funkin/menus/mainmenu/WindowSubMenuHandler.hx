package funkin.menus.mainmenu;

import flixel.FlxBasic;
import flixel.math.FlxRect;
import flixel.util.FlxSignal;

class WindowSubMenuHandler extends FlxBasic
{
	/**
	 * Whether the submenu is open or not.
	 */
	public var isOpen(default, null):Bool;

	/**
	 * The title of the submenu.
	 */
	public var titleObject(default, null):FunkinText;

	/**
	 * The button that closes any open submenu.
	 */
	public var closeButton(default, null):StaticButton;

	/**
	 * The current active submenu.
	 */
	public var curSubMenu(default, null):WindowSubMenu;

	public var enabled:Bool = true;

	public var onOpen:FlxSignal = new FlxSignal();

	public var onClose:FlxSignal = new FlxSignal();

	var background:FunkinSprite;
	var line:FunkinSprite;

	@:allow(funkin.menus.mainmenu.WindowSubMenu)
	var windowCamera:FlxCamera;

	var _mainRect:FlxRect;
	var _subMenuRect:FlxRect;

	public function new(camera:FlxCamera, area:FlxRect, scale:Float = 5)
	{
		super();

		this.camera = camera;

		background = new FunkinSprite().makeGraphic(this.camera.width, this.camera.height, 0xFF505050);
		background.scrollFactor.set();
		background.alpha = 0.7;
		background.camera = this.camera;

		closeButton = new StaticButton(scale, scale, Paths.image('ui/x'), () ->
		{
			FunkinSound.playMenuSound(CANCEL);
			close(true);
		});
		closeButton.scaleSprite(scale);
		closeButton.camera = this.camera;

		line = new FunkinSprite(0, closeButton.y + closeButton.height + scale).makeGraphic(Std.int(background.width), Std.int(scale), 0xFFFFFFFF);
		line.scrollFactor.set();
		line.camera = this.camera;

		var titlePos:Float = 2 * scale;
		titleObject = new FunkinText(titlePos, closeButton.y + closeButton.height / 2, background.width - titlePos * 2, '', 56);
		titleObject.y -= titleObject.height / 2;
		titleObject.scrollFactor.set();
		titleObject.alignment = RIGHT;
		titleObject.camera = this.camera;

		_mainRect = new FlxRect(0, 0, this.camera.width, line.y + line.height);
		_subMenuRect = new FlxRect(0, _mainRect.height, _mainRect.width, MathUtil.distanceBetweenFloats(_mainRect.y + _mainRect.height, this.camera.height));

		windowCamera = new FlxCamera(this.camera.x, this.camera.y + _subMenuRect.y, this.camera.width, Std.int(_subMenuRect.height));
		windowCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.insert(windowCamera, FlxG.cameras.list.indexOf(this.camera) + 1, false);

		kill();
		isOpen = false;
	}

	/**
	 * Opens a window submenu.
	 *
	 * @param subMenu The `WindowSubMenu` to open.
	 */
	public function open(subMenu:WindowSubMenu)
	{
		curSubMenu?.destroy();

		revive();

		curSubMenu = subMenu;
		curSubMenu.preciseAngle = false;
		curSubMenu.preciseScale = false;
		curSubMenu.camera = windowCamera;
		curSubMenu.create();
		curSubMenu.init(this);
		titleObject.translationData = {id: curSubMenu.nameTranslationID};

		onOpen.dispatch();

		isOpen = true;
	}

	/**
	 * Closes any window submenu that's currently open.
	 *
	 * @param trigger Whether to trigger the `onClose` signal.
	 */
	public function close(trigger:Bool = false)
	{
		if (!isOpen)
		{
			return;
		}

		if (curSubMenu != null)
		{
			curSubMenu.destroy();
			curSubMenu = null;
		}

		windowCamera.scroll.set();
		windowCamera.minScrollX = null;
		windowCamera.minScrollY = null;
		windowCamera.maxScrollX = null;
		windowCamera.maxScrollY = null;

		if (trigger)
		{
			onClose.dispatch();
		}

		kill();

		isOpen = false;
	}

	override function update(elapsed:Float)
	{
		if (!enabled || !isOpen)
		{
			return;
		}

		super.update(elapsed);

		background.update(elapsed);
		line.update(elapsed);
		titleObject.update(elapsed);
		closeButton.update(elapsed);

		curSubMenu?.update(elapsed);
	}

	override function draw()
	{
		if (!isOpen)
		{
			return;
		}

		super.draw();

		background.draw();
		line.draw();
		titleObject.draw();
		closeButton.draw();

		curSubMenu?.draw();
	}

	/**
	 * Gets called whenever the system's language changes.
	 * @param language The new language.
	 */
	public function onLanguageUpdate(language:String)
	{
		titleObject.text = '';
		curSubMenu?.onLanguageUpdate(language);
	}

	override public function revive()
	{
		background.revive();
		closeButton.revive();
		line.revive();
		titleObject.revive();

		super.revive();
	}

	override public function kill()
	{
		background.kill();
		closeButton.kill();
		line.kill();
		titleObject.kill();

		super.kill();
	}

	override public function destroy()
	{
		super.destroy();

		background.destroy();
		closeButton.destroy();
		line.destroy();
		titleObject.destroy();

		curSubMenu?.destroy();
	}
}
