package funkin.menus.debug.character;

#if FEATURE_DEBUG_CONTENT
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.animation.FlxAnimation;
import flixel.math.FlxPoint;

import funkin.play.Character;
import funkin.ui.backend.TopBar;
import funkin.ui.backend.UIButton;
import funkin.ui.backend.UIButtonList;

class CharacterEditorState extends MusicBeatState
{
	static final MIN_ZOOM:Float = 0.5;
	static final MAX_ZOOM:Float = 10;

	var uiCamera:FlxCamera;
	var spriteSheetCamera:FlxCamera;

	var background:FlxBackdrop;

	var reference:FunkinSprite;
	var character:Character;

	var characterDataBG:FunkinSprite;

	var topBar:TopBar;

	/**
	 * The `File` option in the menu bar.
	 */
	var fileMenu:UIButtonList;

	// var fileExitItem:UIButton;

	/**
	 * The `Edit` option in the menu bar.
	 */
	var editMenu:UIButtonList;

	/**
	 * The `View` option in the menu bar.
	 */
	var viewMenu:UIButtonList;

	// var viewSpritesheetItem:MenuCheckBox;

	/**
	 * The `Help` option in the menu bar.
	 */
	var helpMenu:UIButtonList;

	var isViewingSpriteSheet:Bool = false;

	// var spriteSheetWindow:Window;
	// var animationListContainer:VBox;
	var animationList:FlxTypedGroup<FunkinText>;

	var zoomText:FunkinText;

	override public function create()
	{
		super.create();

		uiCamera = new FlxCamera();
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera, false);

		/*
			spriteSheetCamera = new FlxCamera(0, 0, 480, 240);
			spriteSheetCamera.bgColor = FlxColor.TRANSPARENT;
			FlxG.cameras.add(spriteSheetCamera, false);
		 */

		background = new FlxBackdrop(FlxGridOverlay.createGrid(16, 16, 32, 32, true, 0xFFFFFFFF, 0xFFDCDCDC));
		background.cameras = [FlxG.camera /*, spriteSheetCamera*/];
		add(background);

		var xAxis:FunkinSprite = new FunkinSprite().makeSolid(9999, 1, FlxColor.RED);
		xAxis.blend = MULTIPLY;
		xAxis.screenCenter(X);
		add(xAxis);

		var yAxis:FunkinSprite = new FunkinSprite().makeSolid(1, 9999, FlxColor.LIME);
		yAxis.blend = MULTIPLY;
		yAxis.screenCenter(Y);
		add(yAxis);

		reference = new FunkinSprite().loadGraphic(Paths.image("menus/debug/character/funker"));
		reference.scaleSprite(10);
		reference.color = FlxColor.BLACK;
		reference.alpha = 0.4;
		add(reference);

		character = new Character();
		character.animation.onFrameChange.add(updateAnimation);
		add(character);

		/*
			animationList = new FlxTypedGroup<FunkinText>();
			animationList.camera = uiCamera;
			add(animationList);
		 */

		zoomText = new FunkinText(8, FlxG.height - 4, "", 20, true);
		zoomText.text = 'Zoom: ${Math.round(FlxG.camera.zoom * 100)}%';
		zoomText.font = "Arial";
		zoomText.bold = true;
		zoomText.scrollFactor.set();
		zoomText.y -= zoomText.height;
		zoomText.camera = uiCamera;
		add(zoomText);

		initUI();

		changeCharacter(Defaults.DEFAULT_CHARACTER);

		updateSpriteSheetViewer();

		FlxG.camera.scroll.x = -(FlxG.camera.width - characterDataBG.width) / 2;
		FlxG.camera.scroll.y = -FlxG.camera.height / 2;
	}

	function initUI()
	{
		final optionsWidth:Float = 120;

		topBar = new TopBar();
		topBar.camera = uiCamera;

		characterDataBG = new FunkinSprite(0, topBar.bar.height).makeSolid(480, Std.int(FlxG.height - topBar.bar.height), 0xFF303030);
		characterDataBG.camera = uiCamera;
		characterDataBG.x = FlxG.width - characterDataBG.width;

		add(characterDataBG);
		add(topBar);

		// File Menu Section //

		fileMenu = new UIButtonList('File');
		topBar.addButton(fileMenu);

		var fileSaveItem:UIButton = new UIButton('Save');
		fileMenu.addItem(fileSaveItem);

		var fileSaveAsItem:UIButton = new UIButton('Save As...');
		fileMenu.addItem(fileSaveAsItem);

		var fileExitItem:UIButton = new UIButton('Exit');
		fileExitItem.onPress.add(() -> FlxG.switchState(() -> new DebugState()));
		fileMenu.addItem(fileExitItem);

		// Edit Menu Section //

		editMenu = new UIButtonList('Edit');
		topBar.addButton(editMenu);

		// View Menu Section //

		viewMenu = new UIButtonList('View');
		topBar.addButton(viewMenu);

		// Help Menu Section //

		helpMenu = new UIButtonList('Help');
		topBar.addButton(helpMenu);

		/*
			menuBar = new MenuBar();
			menuBar.width = FlxG.width;
			menuBar.cameras = [uiCamera];

			animationListContainer = new VBox();
			animationListContainer.width = 400;
			animationListContainer.height = FlxG.height - menuBar.actualComponentHeight;
			animationListContainer.y = menuBar.actualComponentHeight;
			animationListContainer.cameras = [uiCamera];

			// File Menu Section //

			fileMenu = new Menu();
			fileMenu.text = "File";
			fileMenu.width = optionsWidth;
			fileMenu.menuBar = menuBar;
			menuBar.addComponent(fileMenu);

			fileExitItem = new MenuItem();
			fileExitItem.text = "Exit";
			fileExitItem.shortcutText = "Ctrl + Q";
			fileExitItem.onClick = _ ->
			{
			FlxG.switchState(() -> new DebugState());
			};
			fileMenu.addComponent(fileExitItem);

			// Edit Menu Section //

			editMenu = new Menu();
			editMenu.text = "Edit";
			editMenu.width = optionsWidth;
			editMenu.menuBar = menuBar;
			menuBar.addComponent(editMenu);

			// View Menu Section //

			viewMenu = new Menu();
			viewMenu.text = "View";
			viewMenu.width = optionsWidth;
			viewMenu.menuBar = menuBar;
			menuBar.addComponent(viewMenu);

			viewSpritesheetItem = new MenuCheckBox();
			viewSpritesheetItem.text = "Sprite Sheet";
			viewSpritesheetItem.selected = isViewingSpriteSheet;
			viewSpritesheetItem.onClick = _ ->
			{
				toggleSpriteSheet();
			};
			viewMenu.addComponent(viewSpritesheetItem);

			// Help Menu Section //

			helpMenu = new Menu();
			helpMenu.text = "Help";
			helpMenu.width = optionsWidth;
			helpMenu.menuBar = menuBar;
			menuBar.addComponent(helpMenu);

			add(animationListContainer);

			add(menuBar);
		 */
	}

	override public function update(elapsed:Float)
	{
		handleCameraControls(elapsed);
		handleCharacterManipulationControls();

		super.update(elapsed);
	}

	var scrollAmount:Float = 500;

	function handleCameraControls(elapsed:Float)
	{
		if (FlxG.keys.pressed.LEFT)
		{
			FlxG.camera.scroll.x -= scrollAmount * elapsed;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			FlxG.camera.scroll.x += scrollAmount * elapsed;
		}

		if (FlxG.keys.pressed.UP)
		{
			FlxG.camera.scroll.y -= scrollAmount * elapsed;
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			FlxG.camera.scroll.y += scrollAmount * elapsed;
		}

		// if (FlxG.mouse.wheel != 0)
		// setZoom(FlxG.camera.zoom + FlxG.mouse.wheel / 500);
	}

	function setZoom(value:Float)
	{
		FlxG.camera.zoom = FlxMath.bound(value, MIN_ZOOM, MAX_ZOOM);
		zoomText.text = 'Zoom: ${Math.round(FlxG.camera.zoom * 100)}%';
	}

	var curAnimIndex:Int = 0;

	function handleCharacterManipulationControls()
	{
		if (FlxG.keys.justPressed.W)
		{
			changeAnimation(-1);
		}
		else if (FlxG.keys.justPressed.S)
		{
			changeAnimation(1);
		}

		if (FlxG.keys.justPressed.A)
		{
			changeFrame(-1);
		}
		else if (FlxG.keys.justPressed.D)
		{
			changeFrame(1);
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			character.replayAnimation();
		}
	}

	function changeAnimation(change:Int = 0)
	{
		var animList:Array<String> = character.animation.getNameList();
		curAnimIndex = FlxMath.wrap(curAnimIndex + change, 0, animList.length - 1);
		character.playAnimation(animList[curAnimIndex], true);

		updateTextList();
	}

	function changeFrame(change:Int = 0)
	{
		var anim:FlxAnimation = character.getCurrentAnimation();
		if (anim != null)
		{
			anim.pause();
			anim.curFrame = FlxMath.wrap(anim.curFrame + change, 0, anim.numFrames - 1);
		}
	}

	function updateAnimation(animation:String, frame:Int, index:Int) {}

	function toggleSpriteSheet()
	{
		isViewingSpriteSheet = !isViewingSpriteSheet;
		// viewSpritesheetItem.selected = isViewingSpriteSheet;

		updateSpriteSheetViewer();
	}

	function updateSpriteSheetViewer()
	{
		if (isViewingSpriteSheet)
		{
			// spriteSheetCamera.visible = true;
			// spriteSheetWindow.show();

			// spriteSheetCamera.x = spriteSheetWindow.x;
			// spriteSheetCamera.y = spriteSheetWindow.y;
		}
		else
		{
			// spriteSheetCamera.visible = false;
			// spriteSheetWindow.hide();
		}
	}

	function changeCharacter(newCharacter:String)
	{
		character.loadCharacter(newCharacter);
		curAnimIndex = 0;

		/*
			animationList.forEach((txt:FunkinText) -> txt.destroy());
			animationList.clear();

			for (i => animation in character.animation.getNameList())
			{
				var animText:FunkinText = new FunkinText(8, 6 + (24 * i), 0, animation, 20, true);
				animText.font = "Arial";
				animText.bold = true;
				animText.scrollFactor.set();

				var animOffset:FlxPoint = character.getAnimationOffsets(animation);
				animText.text = '$animation: [${animOffset.x}, ${animOffset.y}]';

				animationList.add(animText);
			}
		 */

		updateTextList();
	}

	function updateTextList()
	{
		/*
			for (i => text in animationList.members)
			{
				if (i == curAnimIndex)
					text.color = FlxColor.CYAN;
				else
					text.color = FlxColor.WHITE;
			}
		 */
	}
}
#end
