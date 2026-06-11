package funkin.menus.mainmenu;

import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxRect;
import flixel.util.FlxGradient;
import flixel.util.FlxSpriteUtil;

import funkin.menus.mainmenu.MainMenuButton;
import funkin.menus.mainmenu.submenu.*;
import funkin.system.FullScreenScaleMode;

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
	public var backgroundGroup:FlxTypedGroup<FlxSprite>;

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
				return new PlaySubMenu(state);
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
				return null; // new funkin.menus.achievements.AchievementsState();
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
				return new ExtrasSubMenu(state);
			}
		},
		{
			translationID: 'generic.exit',
			available: true,
			type: OTHER,
			triggerType: OPEN_SUBSTATE,
			onSelect: function(state:MainMenuState)
			{
				var prompt:funkin.menus.mainmenu.ExitPrompt = new funkin.menus.mainmenu.ExitPrompt();
				prompt.onCancelExit.add(() -> state.enableInput());
				return prompt;
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

		backgroundGroup = new FlxTypedGroup<FlxSprite>();
		backgroundGroup.camera = mainCamera;
		add(backgroundGroup);

		var bgMain:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFF45706D, 0xFF25413F]);
		bgMain.resetFrame();
		backgroundGroup.add(bgMain);

		var lineHeight:Int = Std.int(FlxG.height / BASE_SCALE);

		var bgRightLine:FlxSprite = FlxGradient.createGradientFlxSprite(3, lineHeight, [0xFF345452, 0xFF1C302E]);
		bgRightLine.resetFrame();

		bgRightLine.pixels.lock();

		for (yPos in 0...lineHeight)
		{
			bgRightLine.pixels.setPixel32(1, yPos, FlxColor.TRANSPARENT);
		}

		bgRightLine.pixels.unlock();

		bgRightLine.scale.set(BASE_SCALE, BASE_SCALE);
		bgRightLine.updateHitbox();
		bgRightLine.x = FlxG.width - bgRightLine.width - 54 * BASE_SCALE;
		backgroundGroup.add(bgRightLine);

		var bgLeftLine:FlxSprite = FlxGradient.createGradientFlxSprite(3, lineHeight, [0xFF345452, 0xFF1C302E]);
		bgLeftLine.resetFrame();

		bgLeftLine.pixels.lock();

		for (yPos in 0...lineHeight)
		{
			bgLeftLine.pixels.setPixel32(1, yPos, FlxColor.TRANSPARENT);
		}

		bgLeftLine.pixels.unlock();

		bgLeftLine.scale.set(BASE_SCALE, BASE_SCALE);
		bgLeftLine.updateHitbox();
		backgroundGroup.add(bgLeftLine);

		var bgMiddleLine:FunkinSprite = new FunkinSprite().makeSolid(Std.int(BASE_SCALE), Std.int(BASE_SCALE), 0xFF253D3B);
		backgroundGroup.add(bgMiddleLine);

		var bgTop:FunkinSprite = new FunkinSprite().makeSolid(FlxG.width, Std.int(FlxG.height / 2), 0xFF45706D);
		bgTop.y -= bgTop.height;
		backgroundGroup.add(bgTop);

		var bgTopLine1:FunkinSprite = new FunkinSprite().makeGraphic(3, 1, 0xFF345452);
		bgTopLine1.pixels.lock();
		bgTopLine1.pixels.setPixel32(1, 0, FlxColor.TRANSPARENT);
		bgTopLine1.pixels.unlock();
		bgTopLine1.scaleSprite(BASE_SCALE, (lineHeight / 2) * BASE_SCALE);
		bgTopLine1.y -= bgTopLine1.height;
		backgroundGroup.add(bgTopLine1);

		var bgTopLine2:FunkinSprite = bgTopLine1.clone();
		bgTopLine2.scaleSprite(BASE_SCALE, (lineHeight / 2) * BASE_SCALE);
		bgTopLine2.x = bgRightLine.x;
		bgTopLine2.y -= bgTopLine2.height;
		backgroundGroup.add(bgTopLine2);

		topBarGroup = new FlxTypedGroup<FunkinSprite>();
		topBarGroup.camera = mainCamera;

		var topLeft:FunkinSprite = new FunkinSprite(FullScreenScaleMode.notchSize.x + 1 * BASE_SCALE, 2 * BASE_SCALE).loadGraphic(getImage('top-left'));
		topLeft.scaleSprite(BASE_SCALE);

		var topRight:FunkinSprite = new FunkinSprite(FlxG.width - 1 * BASE_SCALE, 2 * BASE_SCALE).loadGraphic(getImage('top-right'));
		topRight.scaleSprite(BASE_SCALE);
		topRight.x -= topRight.width;

		var topBordersDistance:Float = MathUtil.distanceBetweenFloats(topLeft.x + topLeft.width, topRight.x);
		var topMiddle:FunkinSprite = new FunkinSprite(topLeft.x + topLeft.width, topLeft.y).makeGraphic(1, 18, 0xFF282828);

		topMiddle.pixels.lock();

		for (position in [0, 17])
		{
			topMiddle.pixels.setPixel(0, position, 0x111111);
		}

		topMiddle.pixels.unlock();

		topMiddle.setGraphicSize(topBordersDistance, topMiddle.frameHeight * BASE_SCALE);
		topMiddle.updateHitbox();

		var topShadowLeft:FunkinSprite = new FunkinSprite(topLeft.x, topLeft.y + topLeft.height - 2 * BASE_SCALE).makeGraphic(3, 4, FlxColor.TRANSPARENT);

		topShadowLeft.pixels.lock();

		for (yPos in 0...4)
		{
			for (xPos in 0...3)
			{
				switch (yPos)
				{
					case 2:
						if (xPos > 0)
						{
							topShadowLeft.pixels.setPixel32(xPos, yPos, 0xFF999999);
						}
					case 3:
						if (xPos > 1)
						{
							topShadowLeft.pixels.setPixel32(xPos, yPos, 0xFF999999);
						}
					default:
						topShadowLeft.pixels.setPixel32(xPos, yPos, 0xFF999999);
				}
			}
		}

		topShadowLeft.pixels.unlock();

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

		var miniTitle:FunkinSprite = new FunkinSprite(0, topShadowLeft.y + topShadowLeft.height + 2 * BASE_SCALE).loadGraphic(getImage('title'));
		miniTitle.scaleSprite(BASE_SCALE);
		miniTitle.camera = mainCamera;
		add(miniTitle);

		var mainButtonsBack:FunkinSprite = new FunkinSprite(FullScreenScaleMode.notchSize.x + 2 * BASE_SCALE, miniTitle.y + miniTitle.height + 2 * BASE_SCALE).loadGraphic(getImage('buttonsBack'));
		mainButtonsBack.scaleSprite(BASE_SCALE);
		mainButtonsBack.camera = mainCamera;

		var buttonsBackShadow:FunkinSprite = new FunkinSprite(mainButtonsBack.x - 1 * BASE_SCALE, mainButtonsBack.y + 3 * BASE_SCALE).loadGraphic(getImage('buttonsBack-shadow'));
		buttonsBackShadow.scaleSprite(BASE_SCALE);
		buttonsBackShadow.blend = MULTIPLY;
		buttonsBackShadow.camera = mainCamera;
		add(buttonsBackShadow);

		add(mainButtonsBack);

		bgTopLine1.x = bgLeftLine.x = mainButtonsBack.x + mainButtonsBack.width - bgLeftLine.width - 4 * BASE_SCALE;
		miniTitle.x = MathUtil.roundToGrid(mainButtonsBack.x + (mainButtonsBack.width - miniTitle.width) / 2, BASE_SCALE);

		bgMiddleLine.y = mainButtonsBack.y + 28 * BASE_SCALE;

		var buttonsDivision:FunkinSprite = new FunkinSprite(mainButtonsBack.x + 4 * BASE_SCALE, mainButtonsBack.y + 46 * BASE_SCALE).makeGraphic(94, 1, 0xFF5A5B61);

		buttonsDivision.pixels.lock();

		for (position in [0, 1, 92, 93])
		{
			buttonsDivision.pixels.setPixel(position, 0, 0x3E4044);
		}

		buttonsDivision.pixels.unlock();

		buttonsDivision.scaleSprite(BASE_SCALE);
		buttonsDivision.camera = mainCamera;
		add(buttonsDivision);

		mainButtonsGroup = new FlxTypedGroup<MainMenuButton>(6);
		mainButtonsGroup.camera = mainCamera;
		add(mainButtonsGroup);

		createMainButtons(mainButtonsBack.x + 3 * BASE_SCALE * 2, mainButtonsBack.y + 3 * BASE_SCALE * 2);

		var version:FunkinText = new FunkinText(mainButtonsBack.x, mainButtonsBack.y + mainButtonsBack.height + 2 * BASE_SCALE, mainButtonsBack.width, '', 18, true);
		version.translationData = {id: 'common.version', parameters: [Constants.VERSION]};
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
		var windowShadowMiddle:FunkinSprite = new FunkinSprite(windowBorderMiddle.x, windowBorderMiddle.y + windowBorderMiddle.height).makeSolid(Std.int(windowShadowDistance), Std.int(2 * BASE_SCALE), 0xFF999999);
		windowShadowMiddle.blend = MULTIPLY;

		windowBordersGroup.add(windowShadowLeft);
		windowBordersGroup.add(windowShadowMiddle);
		windowBordersGroup.add(windowBorderLeft);
		windowBordersGroup.add(windowBorderMiddle);

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

		bgMain.pixels.lock();

		for (xPos in Std.int(windowArea.x)...Std.int(windowArea.x + windowArea.width))
		{
			for (yPos in Std.int(windowArea.y)...Std.int(windowArea.y + windowArea.height))
			{
				bgMain.pixels.setPixel32(xPos, yPos, FlxColor.TRANSPARENT);
			}
		}

		bgMain.pixels.unlock();

		bgRightLine.pixels.lock();

		for (yPos in Std.int(windowArea.y / BASE_SCALE)...Std.int((windowArea.y + windowArea.height) / BASE_SCALE))
		{
			for (xPos in 0...3)
			{
				bgRightLine.pixels.setPixel32(xPos, yPos, FlxColor.TRANSPARENT);
			}
		}

		bgRightLine.pixels.unlock();

		bgMiddleLine.scaleSprite(windowAreaX, BASE_SCALE);

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

		final buttonScale:Float = FlxG.onMobile ? 5 : 3;
		backButton = new BackButton(FlxG.width * 0.92, FlxG.height * 0.95, FlxColor.WHITE, 1);
		backButton.scaleSprite(buttonScale);
		backButton.x -= backButton.width;
		backButton.y -= backButton.height;
		backButton.alpha = 0;
		backButton.camera = mainCamera;
		add(backButton);

		FlxTween.tween(backButton, {alpha: 1}, 1, {startDelay: 0.5, ease: FlxEase.quintOut});

		backButton.onConfirmStart.add(() ->
		{
			FunkinSound.playMenuSound(CANCEL);
			disableInput();
		});
		backButton.onConfirmEnd.add(checkBackAction);

		Pointer.show();

		changeSelection();

		if (comingFromTitleState)
		{
			disableInput();

			FlxG.camera.y = windowArea.y + FlxG.height / 2;
			mainCamera.scroll.y = -FlxG.height / 2;
			FlxTween.tween(FlxG.camera, {y: windowArea.y}, 1, {ease: FlxEase.quintOut});
			FlxTween.tween(mainCamera.scroll, {y: 0}, 1, {ease: FlxEase.quintOut, onComplete: (_) -> enableInput()});
		}
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

		// TEMP: press F8 to test achievement popup, delete when done
		if (FlxG.keys.justPressed.F8)
		{
			var testIds:Array<String> = ['noBeans', 'leroy', 'relivingNostalgia', 'alteredReality'];
			var testId:String = testIds[Std.int(Math.random() * testIds.length)];
			// Force-remove from unlocked so it can re-trigger for testing
			funkin.system.Achievements.achievementsUnlocked.remove(testId);
			funkin.system.Achievements.grantAchievement(testId);
		}
	}

	function handleInput()
	{
		if (!InputManager.usingControls)
		{
			return;
		}

		if (curSelectionMode == Main)
		{
			if (controls.UI_DOWN)
			{
				changeSelection(1);
			}
			else if (controls.UI_UP)
			{
				changeSelection(-1);
			}

			if (controls.ACCEPT_P)
			{
				curButton?.press();
			}
			else if (controls.ACCEPT_R)
			{
				checkSelection(curEntry);
				curButton?.select();
			}
		}

		#if FEATURE_DEBUG_CONTENT
		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(() -> new funkin.menus.debug.DebugState());
		}
		#end

		if (controls.BACK)
		{
			FunkinSound.playMenuSound(CANCEL);
			checkBackAction();
		}
	}

	var curButton:Null<MainMenuButton> = null;

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

				curButton = button;
			}
			else
			{
				button.idle();
			}
		}

		if (overlaps || windowMenu.isOverlappingButton)
		{
			Pointer.cursorMode = Hover;

			if (curButton != null)
			{
				if (Pointer.pressed)
				{
					curButton.press();
				}
				else if (Pointer.justReleased)
				{
					checkSelection(curPointerEntry);
					curButton.select();
				}
			}
		}
		else
		{
			Pointer.cursorMode = Normal;

			pointerSelection();
			curButton = null;
		}
	}

	var curTouch:Null<FlxTouch> = null;

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

					curButton = button;
					curTouch = touch;
				}
				else
				{
					button.idle();
				}
			}
		}

		if (overlaps && curTouch != null)
		{
			if (curTouch.pressed)
			{
				curButton?.press();
			}
			else if (curTouch.justReleased)
			{
				checkSelection(curPointerEntry);
				curButton?.select();
			}
		}
		else
		{
			pointerSelection();

			curButton = null;
			curTouch = null;
		}
	}

	function getCurrentSelectedButton():Null<MainMenuButton>
	{
		for (button in mainButtonsGroup.members)
		{
			if (button.selected)
			{
				return button;
			}
		}

		return null;
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
					curButton = button;
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
		if (mainButtonsGroup.members[entry] == getCurrentSelectedButton())
		{
			return;
		}

		var buttonData:MainMenuButtonsData = mainMenuButtons[entry];

		if (buttonData.available)
		{
			getCurrentSelectedButton()?.unselect();

			FunkinSound.playMenuSound(CONFIRM);
			selectButton(buttonData);
		}
		else
		{
			// you should never be able to trigger this part of the condition, but just in case.
			FunkinSound.playMenuSound(CANCEL);
		}
	}

	function checkBackAction()
	{
		if (curSelectionMode == Window)
		{
			windowMenu.close();
		}
		else
		{
			transitionToTitle();
			MusicBeatState.setTransitions(VerticalFade);
			FlxG.switchState(() -> new funkin.menus.title.TitleState(true));
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
		Pointer.cursorMode = Normal;

		switch (buttonData.triggerType)
		{
			case OPEN_WINDOW:
				openWindowSubMenu(buttonData.onSelect(this));

			case SWITCH_STATE:
				disableInput();
				flixel.util.FlxTimer.wait(1, () -> FlxG.switchState(buttonData.onSelect(this)));

			case OPEN_SUBSTATE:
				disableInput();
				openSubState(buttonData.onSelect(this));
		}
	}

	function openWindowSubMenu(windowSubMenu:WindowSubMenu)
	{
		if (windowMenu.hasMenuOpen())
		{
			windowMenu.close(false);
		}

		curSelectionMode = Window;
		backButton.visible = false;
		windowMenu.open(windowSubMenu);
	}

	function closeWindowSubMenu()
	{
		curSelectionMode = Main;
		backButton.visible = true;
		getCurrentSelectedButton()?.unselect();
	}

	override function onLanguageUpdate(language:String)
	{
		super.onLanguageUpdate(language);
		windowMenu.onLanguageUpdate(language);
	}

	public function enableInput()
	{
		allowInput = true;
		backButton.enabled = true;
		windowMenu.enabled = true;
	}

	public function disableInput()
	{
		allowInput = false;
		backButton.enabled = false;
		windowMenu.enabled = false;
	}
}

private enum SelectionMode
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
