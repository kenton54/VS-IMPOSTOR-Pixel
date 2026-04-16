package funkin.menus.mainmenu;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

import funkin.menus.debug.DebugState;
import funkin.menus.mainmenu.MainMenuButton;

class MainMenuState extends MusicBeatState
{
	/**
	 * The base scale of the menu.
	 */
	public static final BASE_SCALE:Float = 5;

	/**
	 * The types of button the user is currently targeting or selecting.
	 *
	 * Mouse and Touch controls can bypass this.
	 */
	public var curSelectionMode:SelectionMode = Main;

	/**
	 * Where all the sprites for the back wall are stored.
	 */
	public var backgroundGroup:FlxTypedGroup<FunkinSprite>;

	/**
	 * Where all the sprites for the top bar are stored.
	 */
	public var topBarGroup:FlxTypedGroup<FunkinSprite>;

	/**
	 * Where all the sprites for the window's borders are stored.
	 */
	public var windowBordersGroup:FlxTypedGroup<FunkinSprite>;

	/**
	 * Where all the menu's main buttons are stored.
	 */
	public var mainButtonsGroup:FlxTypedGroup<MainMenuButton>;

	public var floatingCrewGroup:FlxTypedGroup<FunkinSprite>;

	public var backButton:BackButton;

	public var windowArea:FlxRect;

	/**
	 * Handles everything that happens inside a Window Sub-Menu.
	 */
	public var windowMenu:WindowSubMenuHandler;

	/**
	 * The camera where the main objects of the menu are rendered.
	 */
	public var mainCamera:FlxCamera;

	var mainMenuButtons:Array<MainMenuButtonsData> = [
		{
			translationID: 'generic.play',
			available: true,
			icon: getImage('icons/play'),
			type: MAIN,
			triggerType: OPEN_WINDOW,
			onSelect: function(state:MainMenuState)
			{
				var window:WindowSubMenu = new WindowSubMenu('generic.play');

				var worldmapButton:WindowButton = new WindowButton(state.windowArea.width / 2, 3 * BASE_SCALE, {
					position: [0, 0],
					image: getImage('windowButtons/worldmap'),
					width: 56,
					height: 55,
					idleColor: 0xFF0A3C33,
					hoverColor: 0xFF10584B
				});
				worldmapButton.x -= Math.round(worldmapButton.width + 0.5 * BASE_SCALE);
				worldmapButton.addLabel('mainMenu.worldMap', FlxPoint.get(0, 44), 30, CENTER);
				window.add(worldmapButton);

				var freeplayButton:WindowButton = new WindowButton(state.windowArea.width / 2, 3 * BASE_SCALE, {
					position: [1, 0],
					image: getImage('windowButtons/freeplay'),
					width: 56,
					height: 55,
					idleColor: 0xFF0A3C33,
					hoverColor: 0xFF10584B
				});
				freeplayButton.x += Math.round(0.5 * BASE_SCALE);
				freeplayButton.addLabel('generic.freeplay', FlxPoint.get(0, 44), 30, CENTER);
				window.add(freeplayButton);

				var tutorialButton:WindowButton = new WindowButton(state.windowArea.width / 2, worldmapButton.y + worldmapButton.height + BASE_SCALE, {
					position: [0, 1],
					image: getImage('windowButtons/tutorial'),
					width: 72,
					height: 12,
					idleColor: 0xFFAAE2DC,
					hoverColor: 0xFFFFFFFF
				});
				tutorialButton.x -= tutorialButton.width / 2;
				tutorialButton.addLabel('mainMenu.tutorial', FlxPoint.get(0, 2), 28, CENTER);
				window.add(tutorialButton);

				return window;
			}
		},
		{
			translationID: 'generic.achievements',
			available: true,
			icon: getImage('icons/achievements'),
			iconOffsets: [4, 0],
			type: MAIN,
			triggerType: SWITCH_STATE,
			onSelect: function(state:MainMenuState)
			{
				return null;
			}
		},
		{
			translationID: 'generic.shop',
			available: true,
			icon: getImage('icons/shop'),
			iconOffsets: [1, 1],
			type: MAIN,
			triggerType: SWITCH_STATE,
			onSelect: function(state:MainMenuState)
			{
				return null;
			}
		},
		{
			translationID: 'generic.options',
			available: true,
			icon: getImage('icons/options'),
			type: EXTRA,
			triggerType: OPEN_SUBSTATE,
			onSelect: function(state:MainMenuState)
			{
				return null;
			}
		},
		{
			translationID: 'generic.extras',
			available: true,
			icon: getImage('icons/extras'),
			type: EXTRA,
			triggerType: OPEN_WINDOW,
			onSelect: function(state:MainMenuState)
			{
				var window:WindowSubMenu = new WindowSubMenu('generic.extras');

				return window;
			}
		},
		{
			translationID: 'generic.exit',
			available: true,
			type: OTHER,
			triggerType: OPEN_SUBSTATE,
			onSelect: function(state:MainMenuState)
			{
				return null;
			}
		}
	];

	var comingFromTitleState:Bool = false;

	inline function getImage(path:String):String
	{
		return Paths.image('menus/mainmenu/$path');
	}

	public function new(?fromTitleState:Bool = false)
	{
		super();
		comingFromTitleState = fromTitleState;
	}

	override public function create()
	{
		super.create();

		#if FEATURE_DISCORD_API
		DiscordClient.changePresence({
			state: 'Navigating Menus',
			details: 'Main Menu'
		});
		#end

		FunkinSound.playMenuMusic();

		FlxG.camera.bgColor = FlxColor.TRANSPARENT;

		mainCamera = new FlxCamera();
		mainCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(mainCamera);

		var starField:StarsBackdrop = new StarsBackdrop(-5);
		starField.scale = 1.2;
		starField.scrollFactor = 0;
		starField.camera = FlxG.camera;
		add(starField);

		var transBG:FunkinSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, 0xFF45706D);
		transBG.y -= transBG.height;
		transBG.camera = mainCamera;
		add(transBG);

		backgroundGroup = new FlxTypedGroup<FunkinSprite>();
		backgroundGroup.camera = mainCamera;
		add(backgroundGroup);

		var bgLeft:FunkinSprite = new FunkinSprite().loadGraphic(getImage('bg-left'));
		bgLeft.scaleSprite(BASE_SCALE);
		backgroundGroup.add(bgLeft);

		var bgRight:FunkinSprite = new FunkinSprite(FlxG.width).loadGraphic(getImage('bg-right'));
		bgRight.scaleSprite(BASE_SCALE);
		bgRight.x -= bgRight.width;
		backgroundGroup.add(bgRight);

		var bgBordersDistance:Float = MathUtil.distanceBetweenFloats(bgLeft.x + bgLeft.width, bgRight.x);
		var bgMiddle:FunkinSprite = new FunkinSprite(bgLeft.x + bgLeft.width).loadGraphic(getImage('bg-middle'));
		bgMiddle.setGraphicSize(bgBordersDistance, bgMiddle.frameHeight * BASE_SCALE);
		bgMiddle.updateHitbox();
		backgroundGroup.add(bgMiddle);

		topBarGroup = new FlxTypedGroup<FunkinSprite>();
		topBarGroup.camera = mainCamera;

		var topLeft:FunkinSprite = new FunkinSprite(1 * BASE_SCALE, 2 * BASE_SCALE).loadGraphic(getImage('top-left'));
		topLeft.scaleSprite(BASE_SCALE);

		var topRight:FunkinSprite = new FunkinSprite(FlxG.width - 1 * BASE_SCALE, 2 * BASE_SCALE).loadGraphic(getImage('top-right'));
		topRight.scaleSprite(BASE_SCALE);
		topRight.x -= topRight.width;

		var topBordersDistance:Float = MathUtil.distanceBetweenFloats(topLeft.x + topLeft.width, topRight.x);
		var topMiddle:FunkinSprite = new FunkinSprite(topLeft.x + topLeft.width, topLeft.y).makeGraphic(1, 18, 0xFF282828);

		for (position in [0, 17])
		{
			topMiddle.pixels.setPixel(0, position, 0x111111);
		}

		topMiddle.setGraphicSize(topBordersDistance, topMiddle.frameHeight * BASE_SCALE);
		topMiddle.updateHitbox();

		var topShadowLeft:FunkinSprite = new FunkinSprite(topLeft.x, topLeft.y + topLeft.height - 2 * BASE_SCALE).loadGraphic(getImage('top-shadow'));
		topShadowLeft.scaleSprite(BASE_SCALE);
		topShadowLeft.blend = MULTIPLY;
		topBarGroup.add(topShadowLeft);

		var topShadowRight:FunkinSprite = topShadowLeft.clone();
		topShadowRight.scaleSprite(BASE_SCALE);
		topShadowRight.setPosition(FlxG.width - 1 * BASE_SCALE, topRight.y + topRight.height - 2 * BASE_SCALE);
		topShadowRight.flipX = true;
		topShadowRight.blend = MULTIPLY;
		topShadowRight.x -= topShadowRight.width;
		topBarGroup.add(topShadowRight);

		var topShadowBordersDistance:Float = MathUtil.distanceBetweenFloats(topShadowLeft.x + topShadowLeft.width, topShadowRight.x);
		var topShadowMiddle:FunkinSprite = new FunkinSprite(topShadowLeft.x + topShadowLeft.width, topShadowLeft.y).makeGraphic(Std.int(topShadowBordersDistance), Std.int(4 * BASE_SCALE), 0xFF999999);
		topShadowMiddle.blend = MULTIPLY;
		topBarGroup.add(topShadowMiddle);

		topBarGroup.add(topLeft);
		topBarGroup.add(topRight);
		topBarGroup.add(topMiddle);

		var lightBulb:FunkinSprite = new FunkinSprite(topLeft.x + 24 * BASE_SCALE, topLeft.y + 4 * BASE_SCALE).loadGraphic(getImage('lightBulb'));
		lightBulb.scaleSprite(BASE_SCALE);
		lightBulb.camera = mainCamera;
		lightBulb.color = 0xFF43A25A;
		topBarGroup.add(lightBulb);

		var lightGlow:FunkinSprite = new FunkinSprite().loadGraphic(Paths.image('glow'));
		lightGlow.scaleSprite(BASE_SCALE / 2);
		lightGlow.x = lightBulb.x + (lightBulb.width - lightGlow.width) / 2;
		lightGlow.y = lightBulb.y + (lightBulb.height - lightGlow.height) / 2;
		lightGlow.blend = ADD;
		lightGlow.alpha = 0.75;
		lightGlow.color = lightBulb.color;
		topBarGroup.add(lightGlow);

		var lightBulbOverlay:FunkinSprite = new FunkinSprite(lightBulb.x, lightBulb.y).loadGraphic(getImage('lightBulbOverlay'));
		lightBulbOverlay.scaleSprite(BASE_SCALE);
		lightBulbOverlay.camera = mainCamera;
		lightBulbOverlay.blend = MULTIPLY;
		topBarGroup.add(lightBulbOverlay);

		var miniTitle:FunkinSprite = new FunkinSprite(3 * BASE_SCALE, topShadowLeft.y + topShadowLeft.height + 2 * BASE_SCALE).loadGraphic(getImage('title'));
		miniTitle.scaleSprite(BASE_SCALE);
		miniTitle.camera = mainCamera;
		add(miniTitle);

		var mainButtonsBack:FunkinSprite = new FunkinSprite(2 * BASE_SCALE, miniTitle.y + miniTitle.height + 2 * BASE_SCALE).loadGraphic(getImage('buttonsBack'));
		mainButtonsBack.scaleSprite(BASE_SCALE);
		mainButtonsBack.camera = mainCamera;

		var buttonsBackShadow:FunkinSprite = new FunkinSprite(mainButtonsBack.x - 1 * BASE_SCALE, mainButtonsBack.y + 3 * BASE_SCALE).loadGraphic(getImage('buttonsBack-shadow'));
		buttonsBackShadow.scaleSprite(BASE_SCALE);
		buttonsBackShadow.blend = MULTIPLY;
		buttonsBackShadow.camera = mainCamera;

		add(buttonsBackShadow);
		add(mainButtonsBack);

		var buttonsDivision:FunkinSprite = new FunkinSprite(mainButtonsBack.x + 4 * BASE_SCALE, mainButtonsBack.y + 46 * BASE_SCALE).makeGraphic(94, 1, 0xFF5A5B61);

		for (position in [0, 1, 92, 93])
		{
			buttonsDivision.pixels.setPixel(position, 0, 0x3E4044);
		}

		buttonsDivision.scaleSprite(BASE_SCALE);
		buttonsDivision.camera = mainCamera;
		add(buttonsDivision);

		mainButtonsGroup = new FlxTypedGroup<MainMenuButton>(6);
		mainButtonsGroup.camera = mainCamera;
		add(mainButtonsGroup);

		createMainButtons(mainButtonsBack.x + 3 * BASE_SCALE * 2, mainButtonsBack.y + 3 * BASE_SCALE * 2);

		var version:FunkinText = new FunkinText(mainButtonsBack.x, mainButtonsBack.y + mainButtonsBack.height + 2 * BASE_SCALE, mainButtonsBack.width, '', 18, true);
		version.translationData = {id: 'common.version', parameters: [Defaults.VERSION]};
		version.alignment = CENTER;
		version.borderSize = 2;
		version.color = 0xFFBFBFBF;
		version.camera = mainCamera;
		add(version);

		add(topBarGroup);

		windowBordersGroup = new FlxTypedGroup<FunkinSprite>();
		windowBordersGroup.camera = mainCamera;
		add(windowBordersGroup);

		var windowBorderX:Float = mainButtonsBack.x + mainButtonsBack.width + 2 * BASE_SCALE;
		var windowBorderY:Float = topLeft.y + topLeft.height + 3 * BASE_SCALE;
		var windowBorderLeft:FunkinSprite = new FunkinSprite(windowBorderX, windowBorderY).loadGraphic(getImage('windowBorder-left'));
		windowBorderLeft.scaleSprite(BASE_SCALE);

		var windowBorderDistance:Float = MathUtil.distanceBetweenFloats(windowBorderLeft.x + windowBorderLeft.width, FlxG.width);
		var windowBorderMiddle:FunkinSprite = new FunkinSprite(windowBorderLeft.x + windowBorderLeft.width, windowBorderLeft.y).loadGraphic(getImage('windowBorder-middle'));
		windowBorderMiddle.setGraphicSize(windowBorderDistance, windowBorderMiddle.frameHeight * BASE_SCALE);
		windowBorderMiddle.updateHitbox();

		var windowShadowLeft:FunkinSprite = new FunkinSprite(windowBorderLeft.x - BASE_SCALE, windowBorderLeft.y + 5 * BASE_SCALE).loadGraphic(getImage('windowBorder-shadowL'));
		windowShadowLeft.scaleSprite(BASE_SCALE);
		windowShadowLeft.blend = MULTIPLY;

		var windowShadowDistance:Float = MathUtil.distanceBetweenFloats(windowBorderLeft.x + windowBorderLeft.width, FlxG.width);
		var windowShadowMiddle:FunkinSprite = new FunkinSprite(windowShadowLeft.x + windowShadowLeft.width, windowShadowLeft.y).loadGraphic(getImage('windowBorder-shadowM'));
		windowShadowMiddle.setGraphicSize(windowShadowDistance, windowShadowMiddle.frameHeight * BASE_SCALE);
		windowShadowMiddle.updateHitbox();
		windowShadowMiddle.blend = MULTIPLY;

		floatingCrewGroup = new FlxTypedGroup<FunkinSprite>();
		floatingCrewGroup.camera = FlxG.camera;
		add(floatingCrewGroup);

		var windowAreaX:Float = windowBorderLeft.x + 8 * BASE_SCALE;
		var windowAreaY:Float = windowBorderLeft.y + 8 * BASE_SCALE;
		var windowAreaW:Float = FlxG.width - windowAreaX;
		var windowAreaH:Float = MathUtil.distanceBetweenFloats(windowAreaY, windowBorderLeft.y + windowBorderLeft.height - 8 * BASE_SCALE);
		windowArea = new FlxRect(windowAreaX, windowAreaY, windowAreaW, windowAreaH);

		FlxG.camera.setPosition(windowArea.x, windowArea.y);
		FlxG.camera.setSize(Std.int(windowArea.width), Std.int(windowArea.height));

		var windowShine:FunkinSprite = new FunkinSprite().loadGraphic(getImage('window-shine'));
		windowShine.scaleSprite(BASE_SCALE);
		windowShine.blend = ADD;
		windowShine.alpha = 0.18;
		windowShine.x = windowArea.width * (windowArea.width / 1280) * 0.4;
		windowShine.camera = FlxG.camera;
		add(windowShine);

		windowMenu = new WindowSubMenuHandler(FlxG.camera, windowArea, BASE_SCALE);
		windowMenu.onClose.add(closeWindowSubMenu);
		add(windowMenu);

		windowBordersGroup.add(windowShadowLeft);
		windowBordersGroup.add(windowShadowMiddle);
		windowBordersGroup.add(windowBorderLeft);
		windowBordersGroup.add(windowBorderMiddle);

		final buttonScale:Float = FlxG.onMobile ? 5 : 3;
		backButton = new BackButton(FlxG.width * 0.9, FlxG.height * 0.95, FlxColor.WHITE, 1);
		backButton.scaleSprite(buttonScale);
		backButton.x -= backButton.width;
		backButton.y -= backButton.height;
		backButton.alpha = 0;
		backButton.camera = mainCamera;
		add(backButton);

		FlxTween.tween(backButton, {alpha: 1}, 1, {startDelay: 0.5, ease: FlxEase.quintOut});

		backButton.onConfirmStart.add(disableInput);
		backButton.onConfirmEnd.add(checkBackAction);

		Pointer.show();

		changeSelection();

		disableInput();

		FlxG.camera.y = windowArea.y + FlxG.height / 2;
		mainCamera.scroll.y = -FlxG.height / 2;
		FlxTween.tween(FlxG.camera, {y: windowArea.y}, 1, {ease: FlxEase.quintOut});
		FlxTween.tween(mainCamera.scroll, {y: 0}, 1, {ease: FlxEase.quintOut, onComplete: (_) -> enableInput()});
	}

	function createMainButtons(x:Float = 0, y:Float = 0)
	{
		var yPos:Float = y;

		for (i => buttonData in mainMenuButtons)
		{
			if (i >= 6)
			{
				return;
			}

			var button:MainMenuButton = new MainMenuButton(i, x, yPos, buttonData, BASE_SCALE);
			mainButtonsGroup.add(button);

			yPos += button.height + BASE_SCALE + 1;

			if (i == 2)
			{
				yPos += 3 * BASE_SCALE;
			}
		}
	}

	var allowInput:Bool = true;
	var curEntry:Int = 0;

	var curPointerEntry:Int = 0;
	var lastPointerEntry:Int = -1;

	override public function update(elapsed:Float)
	{
		if (allowInput)
		{
			handleInput();

			if (FlxG.onMobile)
			{
				handleTouch();
			}
			else
			{
				handleMouse();
			}
		}

		super.update(elapsed);
	}

	function handleInput()
	{
		if (!InputManager.usingControls)
		{
			return;
		}

		if (controls.UI_DOWN)
		{
			changeSelection(1);
		}
		else if (controls.UI_UP)
		{
			changeSelection(-1);
		}

		if (controls.ACCEPT)
		{
			checkSelection(curEntry);
		}

		#if FEATURE_DEBUG_CONTENT
		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(() -> new DebugState());
		}
		#end

		if (controls.BACK)
		{
			checkBackAction();
		}
	}

	function handleMouse()
	{
		if (InputManager.usingControls)
		{
			return;
		}

		var overlaps:Bool = false;

		for (button in mainButtonsGroup.members)
		{
			if (Pointer.overlaps(button, mainCamera) && button.available)
			{
				overlaps = true;
				pointerSelection(button.index);
				button.hover();
			}
			else
			{
				button.idle();
			}
		}

		if (overlaps)
		{
			if (Pointer.justReleased)
			{
				checkSelection(curPointerEntry);
			}
		}
		else
		{
			pointerSelection(-1);
		}
	}

	function handleTouch()
	{
		if (InputManager.usingControls)
		{
			return;
		}

		var overlaps:Bool = false;

		for (touch in FlxG.touches.list)
		{
			for (button in mainButtonsGroup.members)
			{
				if (touch.overlaps(button, mainCamera) && button.available)
				{
					overlaps = true;
					pointerSelection(button.index);
					button.hover();
				}
				else
				{
					button.idle();
				}
			}
		}

		if (overlaps)
		{
			if (Pointer.justReleased)
			{
				checkSelection(curPointerEntry);
			}
		}
		else
		{
			pointerSelection(-1);
		}
	}

	function changeSelection(change:Int = 0)
	{
		var oldEntry:Int = curEntry;
		curEntry = FlxMath.wrap(curEntry + change, 0, mainButtonsGroup.countLiving() - 1);

		if (!mainButtonsGroup.members[curEntry].available)
		{
			changeSelection(change);
			return;
		}

		if (curEntry != oldEntry)
		{
			for (button in mainButtonsGroup.members)
			{
				if (button.index == curEntry)
				{
					button.hover();
				}
				else
				{
					button.idle();
				}
			}

			FunkinSound.playMenuSound();
		}
	}

	function pointerSelection(position:Int = -1)
	{
		curPointerEntry = position;

		if (curPointerEntry != lastPointerEntry)
		{
			lastPointerEntry = curPointerEntry;

			if (position >= 0)
			{
				FunkinSound.playMenuSound();
			}
		}
	}

	function checkSelection(entry:Int)
	{
		var buttonData:MainMenuButtonsData = mainMenuButtons[entry];

		if (buttonData.available)
		{
			selectButton(buttonData);
		}
	}

	function checkBackAction()
	{
		if (curSelectionMode == Window)
		{
			closeWindowSubMenu();
		}
		else
		{
			transitionToTitle();
			MusicBeatState.setTransitions(VerticalFade);
			FlxG.switchState(() -> new TitleState(true));
		}
	}

	function transitionToTitle()
	{
		disableInput();

		FlxTween.tween(backButton, {alpha: 0}, 0.5, {startDelay: 0.5, ease: FlxEase.quadIn});

		FlxTween.tween(FlxG.camera, {y: windowArea.y + FlxG.height / 2}, 0.5, {ease: FlxEase.quadIn});
		FlxTween.tween(mainCamera.scroll, {y: -FlxG.height / 2}, 0.5, {ease: FlxEase.quadIn});
	}

	function selectButton(buttonData:MainMenuButtonsData)
	{
		switch (buttonData.triggerType)
		{
			case OPEN_WINDOW:
				openWindowSubMenu(buttonData.onSelect(this));

			case SWITCH_STATE:
				new FlxTimer().start(1, _ -> FlxG.switchState(buttonData.onSelect(this)));

			case OPEN_SUBSTATE:
				openSubState(buttonData.onSelect(this));
		}
	}

	function openWindowSubMenu(windowSubMenu:WindowSubMenu)
	{
		curSelectionMode = Window;
		backButton.visible = false;
		windowMenu.open(windowSubMenu);
	}

	function closeWindowSubMenu()
	{
		curSelectionMode = Main;
		backButton.visible = true;
		windowMenu.close();
	}

	override function onLanguageUpdate(language:String)
	{
		super.onLanguageUpdate(language);
		windowMenu.onLanguageUpdate(language);
	}

	function enableInput()
	{
		allowInput = true;
		backButton.enabled = true;
		windowMenu.enabled = true;
	}

	function disableInput()
	{
		allowInput = false;
		backButton.enabled = false;
		windowMenu.enabled = false;
	}
}

enum SelectionMode
{
	/**
	 * The player is selecting the main buttons.
	 */
	Main;

	/**
	 * The player is currently on a window submenu.
	 */
	Window;
}
