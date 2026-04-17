package funkin.menus;

import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;

import funkin.graphics.shaders.RGBPalette;
import funkin.graphics.text.GameboyText;

class TitleState extends MusicBeatState
{
	static final PRESS_START_TWEEN_DURATION:Float = 1.5;
	static final CAMERA_DEFAULT_ZOOM:Float = 1;
	static final CAMERA_BEAT_BOP_STRENGTH:Float = 0.01;

	static var playedIntro:Bool = false;

	var curState:TitleStateMode = Idle;

	var stars:StarsBackdrop;

	var introGroup:FlxGroup;
	var introText:FunkinText;

	var titleRGBSprite:FunkinSprite;
	var titleMainSprite:FunkinSprite;
	var pressStartText:GameboyText;

	var transitionSprite:FlxSprite;

	var titleRGB:RGBPalette;
	var titleColors:Array<Array<FlxColor>> = [
		[0xFFE31629, 0xFF90003A],
		[0xFF3842AE, 0xFF2A1F78],
		[0xFF18683B, 0xFF0D412E],
		[0xFFEF69CB, 0xFFB74175],
		[0xFFF6CC5A, 0xFFD98E25],
		[0xFF352441, 0xFF23182F],
		[0xFFD2E5E8, 0xFF97ABB5],
		[0xFF461D87, 0xFF251161],
		[0xFF5D3E31, 0xFF412720],
		[0xFF61C2EF, 0xFF3B75C0],
		[0xFF5DD95D, 0xFF338C44],
		[0xFF58223C, 0xFF41132E],
		[0xFFFFBBD9, 0xFFCD7FB4],
		[0xFFF8ECAA, 0xFFE2BC69],
		[0xFF67768E, 0xFF4C5371],
		[0xFF998877, 0xFF6F5B4E],
		[0xFFFF7488, 0xFFD94368],
	];

	var doCameraBop:Bool = true;
	var canChangeColor:Bool = true;

	var comingFromMainMenu:Bool = false;
	var playingIntro:Bool = false;

	public function new(?fromMainMenu:Bool = false)
	{
		super();
		comingFromMainMenu = fromMainMenu;
	}

	override function create()
	{
		MusicBeatState.skipTransOut = true;

		super.create();

		FunkinSound.playMenuMusic();

		#if FEATURE_DISCORD_API
		DiscordClient.changePresence({
			state: 'Navigating Menus',
			details: 'Title Screen'
		});
		#end

		stars = new StarsBackdrop(-10, 5);
		add(stars);

		var titleSpriteGroup:FlxSpriteGroup = new FlxSpriteGroup();
		titleSpriteGroup.y = FlxG.height * 0.2;
		add(titleSpriteGroup);

		titleRGB = new RGBPalette(titleColors[0][0], titleColors[0][1]);

		titleRGBSprite = new FunkinSprite().loadGraphic(Paths.image('menus/title/title-color'));
		titleRGBSprite.scaleSprite(4);
		titleRGBSprite.shader = titleRGB.shader;
		titleSpriteGroup.add(titleRGBSprite);

		var titleAnimIndices:Array<Int> = [0, 0, 0, 0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 0];
		titleMainSprite = new FunkinSprite().loadGraphic(Paths.image('menus/title/title-main'), true, 197, 65);
		titleMainSprite.addAnimationByFrameList('idle', titleAnimIndices, 24, false);
		titleMainSprite.scaleSprite(4);
		titleSpriteGroup.add(titleMainSprite);

		titleSpriteGroup.screenCenter(X);

		pressStartText = new GameboyText(0, 0, '', 56);
		pressStartText.fieldWidth = FlxG.width;
		pressStartText.alignment = CENTER;
		pressStartText.translationData = {id: 'titleScreen.pressStart.press', parameters: ['ENTER']};
		pressStartText.screenCenter(X);
		pressStartText.y = FlxG.height * 0.9 - pressStartText.height;
		pressStartText.alpha = 1;
		add(pressStartText);

		introGroup = new FlxGroup();
		add(introGroup);

		var introBG:FunkinSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		introBG.scrollFactor.set();
		introGroup.add(introBG);

		introText = new FunkinText(0, 0, FlxG.width, '', 44, false);
		introText.scrollFactor.set();
		introText.alignment = CENTER;
		introText.screenCenter();
		introGroup.add(introText);

		transitionSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height * 2, [0x00000000, 0xFF000000, 0xFF000000]);
		transitionSprite.visible = false;
		add(transitionSprite);

		Pointer.show();

		if (!playedIntro)
		{
			playIntro();
		}
		else
		{
			skipIntro(comingFromMainMenu);

			if (comingFromMainMenu)
			{
				allowInput = false;
				FlxG.camera.scroll.y = FlxG.height / 2;
				FlxTween.tween(FlxG.camera.scroll, {y: 0}, 1, {ease: FlxEase.quintOut, onComplete: (_) -> allowInput = true});
			}
		}
	}

	function playIntro()
	{
		doCameraBop = false;
		canChangeColor = false;

		introGroup.revive();

		playingIntro = true;
		curState = Intro;
	}

	function endIntro(flash:Bool = true)
	{
		doCameraBop = true;
		canChangeColor = true;

		introGroup.kill();

		showTitle(flash);
		tweenPressStart();

		playingIntro = false;
		playedIntro = true;
		curState = Idle;
	}

	function skipIntro(ignoreChanges:Bool = false)
	{
		if (FlxG.sound.music != null && !ignoreChanges)
		{
			FlxG.sound.music.time = 9412;
		}

		endIntro(!ignoreChanges);
	}

	function showTitle(flash:Bool = true)
	{
		if (flash)
		{
			FlxG.camera.flash(FlxColor.WHITE, 3);
		}
	}

	var allowInput:Bool = true;
	var canSkipTransition:Bool = false;
	var playingDemo:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, CAMERA_DEFAULT_ZOOM, 0.05);

		var pressedEnter:Bool = controls.ACCEPT || (Pointer.justReleased && !Swipe.justSwipedAny);

		if (allowInput)
		{
			switch (curState)
			{
				case Intro:
					if (pressedEnter)
					{
						skipIntro();
					}

				case Idle:
					if (pressedEnter)
					{
						if (canSkipTransition && transitionTimer.active)
						{
							transitionToMainMenu(true);
						}
						else
						{
							startTransitionToMainMenu(controls.ACCEPT);
						}
					}

				case Demo:
					if (pressedEnter && playingDemo) {}
			}
		}
	}

	override function stepHit(step:Int)
	{
		super.stepHit(step);

		if (playingIntro)
		{
			if (step >= 64)
			{
				endIntro();
			}
		}
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		if (beat % 4 == 3)
		{
			titleMainSprite.playAnimation();
		}

		if (doCameraBop)
		{
			bopTitle();
			FlxG.camera.zoom += CAMERA_BEAT_BOP_STRENGTH;
		}
	}

	override function measureHit(measure:Int)
	{
		super.measureHit(measure);

		if (!canChangeColor && (curMeasure >= 20 || pressed))
		{
			return;
		}

		var chosenColors:Array<FlxColor> = FlxG.random.getObject(titleColors);
		titleRGB.red = chosenColors[0];
		titleRGB.green = chosenColors[1];
	}

	var pressed:Bool = false;
	var transitionTimer:FlxTimer = new FlxTimer();
	var psKeyboardTransData:funkin.system.Translations.TranslationData = {id: 'titleScreen.pressStart.press', parameters: ['ENTER']};
	var psMouseTransData:funkin.system.Translations.TranslationData = {id: 'titleScreen.pressStart.mouse'};
	var psTouchTransData:funkin.system.Translations.TranslationData = {id: 'titleScreen.pressStart.touch'};

	function startTransitionToMainMenu(keyboard:Bool)
	{
		pressed = true;
		FunkinSound.playMenuSound(CONFIRM);

		if (pressStartTweenIn != null)
		{
			pressStartTweenIn.cancel();
		}

		if (pressStartTweenOut != null)
		{
			pressStartTweenOut.cancel();
		}

		pressStartText.alpha = 1;

		pressStartText.translationData = keyboard ? psKeyboardTransData : (FlxG.onMobile ? psTouchTransData : psMouseTransData);

		canSkipTransition = true;
		doCameraBop = false;
		canChangeColor = false;
		canTweenPS = false;

		bopTitle();
		FlxG.camera.zoom += CAMERA_BEAT_BOP_STRENGTH * 4;

		pressStartText.screenCenter(X);
		FlxFlicker.flicker(pressStartText, 1, 0.05, false);

		transitionTimer.start(1, _ -> transitionToMainMenu());
	}

	function transitionToMainMenu(forced:Bool = false)
	{
		allowInput = false;
		canSkipTransition = false;

		if (forced)
		{
			transitionTimer.cancel();

			VerticalFade.inverse = true;
			MusicBeatState.setTransitions(VerticalFade);
			FlxG.switchState(() -> new MainMenuState(true));
		}
		else
		{
			transitionSprite.visible = true;
			transitionSprite.y = FlxG.height;
			FlxTween.tween(transitionSprite, {y: 0}, 1, {ease: FlxEase.quartIn});
			FlxTween.tween(FlxG.camera.scroll, {y: FlxG.height}, 1, {ease: FlxEase.quartIn});

			new FlxTimer().start(1.01, _ ->
			{
				VerticalFade.inverse = true;
				MusicBeatState.skipTransOut = true;
				MusicBeatState.setTransitions(VerticalFade);
				FlxG.switchState(() -> new MainMenuState(true));
			});
		}
	}

	var canTweenPS:Bool = true;
	var pressStartTweenIn:FlxTween = null;
	var pressStartTweenOut:FlxTween = null;
	var altPSText:Bool = false;

	function tweenPressStart()
	{
		if (!canTweenPS)
		{
			return;
		}

		altPSText = !altPSText;

		if (!altPSText #if android && funkin.external.android.AndroidAPI.isKeyboardConnected() #end)
		{
			pressStartText.translationData = psKeyboardTransData;
		}
		else
		{
			pressStartText.translationData = FlxG.onMobile ? psTouchTransData : psMouseTransData;
		}

		pressStartText.screenCenter(X);

		if (pressStartTweenIn != null)
		{
			pressStartTweenIn.cancel();
		}

		if (pressStartTweenOut != null)
		{
			pressStartTweenOut.cancel();
		}

		pressStartText.alpha = 0;
		pressStartTweenIn = FlxTween.tween(pressStartText, {alpha: 1}, PRESS_START_TWEEN_DURATION, {
			ease: FlxEase.quadOut,
			onComplete: _ ->
			{
				if (!canTweenPS)
				{
					return;
				}

				pressStartTweenOut = FlxTween.tween(pressStartText, {alpha: 0}, PRESS_START_TWEEN_DURATION, {
					ease: FlxEase.quadIn,
					onComplete: _ -> tweenPressStart()
				});
			}
		});
	}

	function bopTitle()
	{
		FlxTween.cancelTweensOf(titleMainSprite, ['scale.x', 'scale.y']);
		FlxTween.cancelTweensOf(titleRGBSprite, ['scale.x', 'scale.y']);

		var beatScale:Float = 4 * 1.05;
		var tweenDuration:Float = (Conductor.stepLengthMs / 1000) * 4;

		titleMainSprite.scale.set(beatScale, beatScale);
		titleRGBSprite.scale.set(beatScale, beatScale);
		FlxTween.tween(titleMainSprite, {'scale.x': 4, 'scale.y': 4}, tweenDuration, {ease: FlxEase.quadOut});
		FlxTween.tween(titleRGBSprite, {'scale.x': 4, 'scale.y': 4}, tweenDuration, {ease: FlxEase.quadOut});
	}
}

private enum TitleStateMode
{
	/**
	 * The player is currently watching the intro.
	 */
	Intro;

	/**
	 * The player is idling.
	 */
	Idle;

	/**
	 * The player is watching a cutscene or a gameplay demo.
	 */
	Demo;
}
