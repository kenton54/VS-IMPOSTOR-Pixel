package funkin.menus;

import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;

import funkin.graphics.shaders.RGBPalette;
import funkin.graphics.text.GameboyText;
import funkin.menus.mainmenu.MainMenuState;
import funkin.ui.MusicBeatState;
import funkin.ui.StarsBackdrop;
#if android
import funkin.utils.native.Android;
#end

class TitleState extends MusicBeatState
{
	static var PRESS_START_TWEEN_DURATION:Float = 1.5;
	static var CAMERA_DEFAULT_ZOOM:Float = 1;
	static var CAMERA_BEAT_BOP_STRENGTH:Float = 0.01;

	var curState:TitleStateMode = IDLE;

	var stars:StarsBackdrop;

	var introGroup:FlxGroup;
	var introText:FunkinText;

	var titleRGBSprite:FunkinSprite;
	var titleMainSprite:FunkinSprite;
	var pressStartText:GameboyText;

	var transitionSprite:FlxSprite;

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

	override public function create()
	{
		MusicBeatState.skipTransOut = true;

		super.create();

		FunkinSound.playMenuMusic();

		#if DISCORD_API
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

		titleRGBSprite = new FunkinSprite().loadGraphic(Paths.image('menus/title/color'));
		titleRGBSprite.scaleSprite(4);
		titleRGBSprite.shader = new RGBPalette(titleColors[0][0], titleColors[0][1]);
		titleSpriteGroup.add(titleRGBSprite);

		var titleAnimIndices:Array<Int> = [0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 0];
		titleMainSprite = new FunkinSprite().loadGraphic(Paths.image('menus/title/title'), true, 197, 65);
		titleMainSprite.addAnimationByFrameList(null, titleAnimIndices, 24, false);
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

		transitionSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height * 2, [0x00000000, 0xFF000000, 0xFF000000]);
		transitionSprite.visible = false;
		add(transitionSprite);

		tweenPressStart();
		curState = IDLE;
	}

	var allowInput:Bool = true;
	var canSkipTransition:Bool = false;
	var playingDemo:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, CAMERA_DEFAULT_ZOOM, 0.05);
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER
			|| (FlxG.onMobile ? FlxG.touches.getFirst()?.justReleased : FlxG.mouse.justReleased);

		if (allowInput)
		{
			switch (curState)
			{
				case INTRO:
					if (pressedEnter) {}
				case IDLE:
					if (pressedEnter)
					{
						if (canSkipTransition && transitionTimer.active)
						{
							transitionToMainMenu(true);
						}
						else
						{
							accept(FlxG.keys.justPressed.ENTER);
						}
					}
				case DEMO:
					if (pressedEnter && playingDemo) {}
			}
		}
	}

	override public function beatHit(beat:Int)
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

	override public function measureHit(measure:Int)
	{
		super.measureHit(measure);

		if (curMeasure >= 20 || pressed)
		{
			return;
		}

		var chosenColors:Array<FlxColor> = FlxG.random.getObject(titleColors);
		titleRGBSprite.shader = new RGBPalette(chosenColors[0], chosenColors[1]);
	}

	var pressed:Bool = false;
	var transitionTimer:FlxTimer = new FlxTimer();
	var psKeyboardTransData:TranslationData = {id: 'titleScreen.pressStart.press', parameters: ['ENTER']};
	var psMouseTransData:TranslationData = {id: 'titleScreen.pressStart.mouse'};
	var psTouchTransData:TranslationData = {id: 'titleScreen.pressStart.touch'};

	function accept(keyboard:Bool)
	{
		pressed = true;

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
			FlxG.switchState(() -> new MainMenuState());
		}
		else
		{
			transitionSprite.visible = true;
			transitionSprite.y = FlxG.height;
			FlxTween.tween(transitionSprite, {y: 0}, 1, {ease: FlxEase.quartIn});
			FlxTween.tween(FlxG.camera.scroll, {y: FlxG.height}, 1, {ease: FlxEase.quartIn});

			new FlxTimer().start(1.01, _ ->
			{
				MusicBeatState.skipTransIn = true;
				FlxG.switchState(() -> new MainMenuState());
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

		if (altPSText = !altPSText #if android && Android.isKeyboardConnected() #end)
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

		var beatScale:Float = 4 * 1.08;
		var tweenDuration:Float = (Conductor.stepLengthMs / 1000) * 4;

		titleMainSprite.scale.set(beatScale, beatScale);
		titleRGBSprite.scale.set(beatScale, beatScale);
		FlxTween.tween(titleMainSprite, {'scale.x': 4, 'scale.y': 4}, tweenDuration, {ease: FlxEase.quadOut});
		FlxTween.tween(titleRGBSprite, {'scale.x': 4, 'scale.y': 4}, tweenDuration, {ease: FlxEase.quadOut});
	}

	override function onLanguageUpdate(language:String)
	{
		super.onLanguageUpdate(language);
	}
}

private enum TitleStateMode
{
	INTRO;
	IDLE;
	DEMO;
}
