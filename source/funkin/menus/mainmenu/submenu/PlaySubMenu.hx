package funkin.menus.mainmenu.submenu;

import funkin.menus.mainmenu.WindowSubMenu.WindowButton;

class PlaySubMenu extends WindowSubMenu
{
	var worldmapButton:WindowButton;
	var freeplayButton:WindowButton;
	var tutorialButton:WindowButton;

	var selectingFreeplay:Bool = false;
	var selectingTutorial:Bool = false;

	public function new(instance:MainMenuState)
	{
		super(instance, 'generic.play');
	}

	override function create()
	{
		super.create();

		worldmapButton = new WindowButton(_menuInstance.windowArea.width / 2, 3 * MainMenuState.BASE_SCALE);
		createBigButton(worldmapButton, Paths.image('menus/mainmenu/windowButtons/worldmap'), 'mainMenu.worldMap');
		worldmapButton.x -= Math.round(worldmapButton.width + 0.5 * MainMenuState.BASE_SCALE);
		worldmapButton.available = true;
		add(worldmapButton);

		freeplayButton = new WindowButton(_menuInstance.windowArea.width / 2, 3 * MainMenuState.BASE_SCALE);
		createBigButton(freeplayButton, Paths.image('menus/mainmenu/windowButtons/freeplay'), 'generic.freeplay');
		freeplayButton.x += Math.round(0.5 * MainMenuState.BASE_SCALE);
		freeplayButton.available = true;
		add(freeplayButton);

		tutorialButton = new WindowButton(_menuInstance.windowArea.width / 2, worldmapButton.y + worldmapButton.height + MainMenuState.BASE_SCALE);
		tutorialButton.idleColor = 0xFFAAE2DC;
		tutorialButton.hoverColor = 0xFFFFFFFF;

		tutorialButton.button.loadGraphic(Paths.image('menus/mainmenu/windowButtons/tutorial'), true, 72, 12);
		tutorialButton.button.addAnimationByFrameList('idle', [0], 0);
		tutorialButton.button.addAnimationByFrameList('hover', [1], 0);
		tutorialButton.button.addAnimationByFrameList('locked', [2], 0);
		tutorialButton.button.playAnimation('idle');
		tutorialButton.button.scaleSprite(MainMenuState.BASE_SCALE);
		tutorialButton.button.parentScale.set(MainMenuState.BASE_SCALE, MainMenuState.BASE_SCALE);

		tutorialButton.label.parentY = 2 * MainMenuState.BASE_SCALE;
		tutorialButton.label.fieldWidth = tutorialButton.button.width;
		tutorialButton.label.size = 28;
		tutorialButton.label.translationData = {id: 'mainMenu.tutorial'};
		tutorialButton.label.alignment = CENTER;

		tutorialButton.x -= tutorialButton.width / 2;
		tutorialButton.available = true;
		add(tutorialButton);

		changeSelection(false, false);
	}

	function createBigButton(group:WindowButton, image:String, langID:String)
	{
		group.idleColor = 0xFF0A3C33;
		group.hoverColor = 0xFF10584B;

		group.button.loadGraphic(image, true, 56, 55);
		group.button.addAnimationByFrameList('idle', [0], 0);
		group.button.addAnimationByFrameList('hover', [1], 0);
		group.button.addAnimationByFrameList('locked', [2], 0);
		group.button.playAnimation('idle');
		group.button.scaleSprite(MainMenuState.BASE_SCALE);
		group.button.parentScale.set(MainMenuState.BASE_SCALE, MainMenuState.BASE_SCALE);

		group.label.parentY = 44 * MainMenuState.BASE_SCALE;
		group.label.fieldWidth = group.button.width;
		group.label.size = 30;
		group.label.translationData = {id: langID};
		group.label.alignment = CENTER;
	}

	override function update(elapsed:Float)
	{
		if (InputManager.usingControls)
		{
			if (controls.UI_LEFT || controls.UI_RIGHT)
			{
				changeSelection(true, false);
			}

			if (controls.UI_UP || controls.UI_DOWN)
			{
				changeSelection(false, true);
			}
		}
		else
		{
			if (pointerOverlaps(worldmapButton))
			{
				forceSelection(false, false);
			}
			else if (pointerOverlaps(freeplayButton))
			{
				forceSelection(true, false);
			}
			else if (pointerOverlaps(tutorialButton))
			{
				forceSelection(selectingFreeplay, true);
			}
			else
			{
				unselectEverything();
			}
		}

		super.update(elapsed);
	}

	function changeSelection(changeFreeplay:Bool, changeTutorial:Bool)
	{
		var lastFreeplay:Bool = selectingFreeplay;
		var lastTutorial:Bool = selectingTutorial;

		if (changeFreeplay)
		{
			selectingFreeplay = !selectingFreeplay;
		}

		if (changeTutorial)
		{
			selectingTutorial = !selectingTutorial;
		}

		updateButtons();

		if (lastFreeplay != selectingFreeplay || lastTutorial != selectingTutorial)
		{
			FunkinSound.playMenuSound();
		}
	}

	function forceSelection(freeplay:Bool, tutorial:Bool)
	{
		var lastFreeplay:Bool = selectingFreeplay;
		var lastTutorial:Bool = selectingTutorial;

		selectingFreeplay = freeplay;
		selectingTutorial = tutorial;

		updateButtons();

		if (lastFreeplay != selectingFreeplay || lastTutorial != selectingTutorial)
		{
			FunkinSound.playMenuSound();
		}
	}

	function updateButtons()
	{
		@:privateAccess
		{
			if (selectingTutorial)
			{
				worldmapButton.hovering = freeplayButton.hovering = false;
				tutorialButton.hovering = true;
			}
			else
			{
				worldmapButton.hovering = !selectingFreeplay;
				freeplayButton.hovering = selectingFreeplay;
				tutorialButton.hovering = false;
			}
		}
	}

	function unselectEverything()
	{
		@:privateAccess worldmapButton.hovering = freeplayButton.hovering = tutorialButton.hovering = false;
	}
}
