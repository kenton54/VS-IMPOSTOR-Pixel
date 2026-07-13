package funkin.menus.title;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.text.FlxInputText;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;

import funkin.graphics.shaders.RGBPalette;
import funkin.graphics.text.GameboyText;
import funkin.system.FullScreenScaleMode;
import funkin.utils.InputUtil;

class TitleState extends MusicBeatState
{
	inline static final PRESS_START_TWEEN_DURATION:Float = 1.5;
	inline static final CAMERA_DEFAULT_ZOOM:Float = 1;
	inline static final CAMERA_BEAT_BOP_STRENGTH:Float = 0.01;

	static var playedIntro:Bool = false;

	var curState:TitleStateMode = Idle;

	var stars:StarsBackdrop;

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

	var keyboardButton:StaticButton;
	var typeCancelButton:StaticButton;
	var typeConfirmButton:StaticButton;
	var typeCodeHint:FunkinText;

	var secretCodeInputTxt:FlxInputText;
	var inputtingSecretCode:Bool = false;
	var codeInputHitbox:FlxObject;

	var doCameraBop:Bool = true;
	var canChangeColor:Bool = true;

	var comingFromMainMenu:Bool = false;

	public function new(?fromMainMenu:Bool = false)
	{
		super();
		comingFromMainMenu = fromMainMenu;

		psKeyboardTransData = {id: 'titleScreen.pressStart.press', parameters: [InputUtil.getActionName(controls.getActionFromControl(ACCEPT))]};
		psMouseTransData = {id: 'titleScreen.pressStart.mouse'};
		psTouchTransData = {id: 'titleScreen.pressStart.touch'};
	}

	override function create()
	{
		MusicBeatState.skipTransOut = true;
		FunkinSound.playMenuMusic();
		subStateClosed.add(onSubStateClose);

		#if FEATURE_DISCORD_API
		DiscordClient.changePresence({
			state: 'Navigating Menus',
			details: 'Title Screen'
		});
		#end

		super.create();

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

		typeCodeHint = new FunkinText(0, 0, FlxG.width, '', 24);
		typeCodeHint.fieldWidth = FlxG.width * 0.75;
		typeCodeHint.alignment = CENTER;
		typeCodeHint.translationData = {id: 'titleScreen.typeCodeHint'};
		typeCodeHint.screenCenter(X);
		typeCodeHint.y = FlxG.height * 0.9;

		if (FlxG.onMobile)
		{
			typeCodeHint.y -= pressStartText.height + typeCodeHint.height;
		}

		typeCodeHint.alpha = 0;
		add(typeCodeHint);

		secretCodeInputTxt = new FlxInputText(0, 0, FlxG.width, '', 48, FlxColor.WHITE, FlxColor.TRANSPARENT);
		secretCodeInputTxt.font = Constants.DEFAULT_FONT;
		secretCodeInputTxt.caretWidth = 4;
		secretCodeInputTxt.selectionColor = FlxColor.BLUE;
		secretCodeInputTxt.filterMode = ALPHANUMERIC;
		secretCodeInputTxt.forceCase = UPPER_CASE;
		secretCodeInputTxt.multiline = false;
		secretCodeInputTxt.selectable = false;
		secretCodeInputTxt.alignment = CENTER;
		secretCodeInputTxt.maxChars = 32;
		secretCodeInputTxt.screenCenter(X);
		secretCodeInputTxt.y = pressStartText.y + (pressStartText.height - secretCodeInputTxt.height) / 2;
		add(secretCodeInputTxt);

		codeInputHitbox = new FlxObject(secretCodeInputTxt.x, secretCodeInputTxt.y, secretCodeInputTxt.width - 200, secretCodeInputTxt.height);
		codeInputHitbox.screenCenter(X);
		add(codeInputHitbox);

		final buttonsScale:Float = FlxG.onMobile ? 6 : 4;
		final bottomBottomOffset:Float = FlxG.onMobile ? 72 : 12;

		keyboardButton = new StaticButton(FullScreenScaleMode.notchSize.x + 12, 12, Paths.image('menus/title/keyboard'), openKeyboard);
		keyboardButton.scaleSprite(buttonsScale);
		keyboardButton.alpha = 0;
		keyboardButton.visible = false;
		add(keyboardButton);

		typeCancelButton = new StaticButton(FullScreenScaleMode.notchSize.x + 12, 0, Paths.image('menus/title/cancel'), closeKeyboard.bind(false));
		typeCancelButton.scaleSprite(buttonsScale);
		typeCancelButton.y = FlxG.height - typeCancelButton.height - bottomBottomOffset;
		typeCancelButton.alpha = 0;
		typeCancelButton.visible = false;
		typeCancelButton.enabled = false;
		add(typeCancelButton);

		typeConfirmButton = new StaticButton(0, 0, Paths.image('menus/title/confirm'), closeKeyboard.bind(true));
		typeConfirmButton.scaleSprite(buttonsScale);
		typeConfirmButton.x = FlxG.width - typeConfirmButton.width - 12;
		typeConfirmButton.y = FlxG.height - typeConfirmButton.height - bottomBottomOffset;
		typeConfirmButton.alpha = 0;
		typeConfirmButton.visible = false;
		typeConfirmButton.enabled = false;
		add(typeConfirmButton);

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
				FlxTween.tween(FlxG.camera.scroll, {y: 0}, 1, {
					ease: FlxEase.quintOut,
					onComplete: (_) ->
					{
						allowInput = true;
					}
				});
			}
		}
	}

	function playIntro()
	{
		doCameraBop = false;
		canChangeColor = false;

		persistentUpdate = true;
		openSubState(new IntroSubState());

		curState = Intro;
	}

	function endIntro(flash:Bool = true)
	{
		doCameraBop = true;
		canChangeColor = true;

		showTitle(flash);
		tweenPressStart();

		playedIntro = true;
		curState = Idle;

		FlxTimer.wait(1, appearKeyboard);
	}

	function skipIntro(ignoreChanges:Bool = false)
	{
		if (!ignoreChanges)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.time = 9412;
			}
		}

		closeSubState();

		endIntro(!ignoreChanges);
	}

	function showTitle(flash:Bool = true)
	{
		FlxG.camera.stopFX();

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
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, CAMERA_DEFAULT_ZOOM, FlxMath.getElapsedLerp(0.05, elapsed));

		var pressedEnter:Bool = (controls.ACCEPT || (Pointer.justReleased && !Swipe.justSwipedAny)) && !keyboardButton.pressed;

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
					if (!inputtingSecretCode)
					{
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

						if (controls.BACK)
						{
							FlxG.sound.music.time = 0;
							playIntro();
						}

						if (controls.CHAT)
						{
							openKeyboard();
						}
					}
					else
					{
						if (FlxG.keys.justPressed.ENTER)
						{
							closeKeyboard();
						}
						else if (FlxG.keys.justPressed.ESCAPE)
						{
							closeKeyboard(false);
						}

						if (Pointer.pressAction(codeInputHitbox) && !secretCodeInputTxt.hasFocus)
						{
							secretCodeInputTxt.startFocus();
						}
					}

				case Demo:
					if (pressedEnter && playingDemo) {}
			}
		}

		typeCodeHint.alpha = FlxMath.lerp(typeCodeHint.alpha, !inputtingSecretCode ? 0 : (secretCodeInputTxt.text.length == 0 ? 1 : 0), FlxMath.getElapsedLerp(0.1, elapsed));

		super.update(elapsed);
	}

	override function stepHit(step:Int)
	{
		super.stepHit(step);

		if (curState == Intro)
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
	var psKeyboardTransData:funkin.system.Translations.TranslationData;
	var psMouseTransData:funkin.system.Translations.TranslationData;
	var psTouchTransData:funkin.system.Translations.TranslationData;

	function startTransitionToMainMenu(keyboard:Bool)
	{
		pressed = true;
		FunkinSound.playMenuSound(CONFIRM);

		stopPressStartTween();

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

		dissapearKeyboard(false);

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
			transitionSprite.flipY = false;
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

		stopPressStartTween();

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

	function stopPressStartTween()
	{
		if (pressStartTweenIn != null)
		{
			pressStartTweenIn.cancel();
		}

		if (pressStartTweenOut != null)
		{
			pressStartTweenOut.cancel();
		}
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

	function resumeTitle()
	{
		FunkinSound.resumeMusic();
		FlxG.sound.music?.fadeIn(2, 0, 1);

		doCameraBop = true;
		tweenPressStart();
	}

	function appearKeyboard()
	{
		keyboardButton.visible = true;
		keyboardButton.enabled = true;
		FlxTween.cancelTweensOf(keyboardButton);
		FlxTween.tween(keyboardButton, {alpha: 1}, 0.25);

		typeCancelButton.enabled = false;
		FlxTween.cancelTweensOf(typeCancelButton);
		FlxTween.tween(typeCancelButton, {alpha: 0}, 0.25, {onComplete: (_) -> typeCancelButton.visible = false});

		typeConfirmButton.enabled = false;
		FlxTween.cancelTweensOf(typeConfirmButton);
		FlxTween.tween(typeConfirmButton, {alpha: 0}, 0.25, {onComplete: (_) -> typeConfirmButton.visible = false});
	}

	function dissapearKeyboard(appearHelpers:Bool = true)
	{
		keyboardButton.enabled = false;
		FlxTween.cancelTweensOf(keyboardButton);
		FlxTween.tween(keyboardButton, {alpha: 0}, 0.25, {onComplete: (_) -> keyboardButton.visible = false});

		if (appearHelpers)
		{
			typeCancelButton.visible = true;
			typeCancelButton.enabled = true;
			FlxTween.cancelTweensOf(typeCancelButton);
			FlxTween.tween(typeCancelButton, {alpha: 1}, 0.25);

			typeConfirmButton.visible = true;
			typeConfirmButton.enabled = true;
			FlxTween.cancelTweensOf(typeConfirmButton);
			FlxTween.tween(typeConfirmButton, {alpha: 1}, 0.25);
		}
	}

	function onSubStateClose(subState:flixel.FlxSubState)
	{
		if ((subState is VideoSubState))
		{
			#if FEATURE_DISCORD_API
			DiscordClient.changePresence({
				state: 'Navigating Menus',
				details: 'Title Screen'
			});
			#end

			resumeTitle();

			transitionSprite.flipY = true;
			FlxTween.tween(transitionSprite, {y: -FlxG.height - transitionSprite.height}, 2, {ease: FlxEase.quartOut, onComplete: (_) -> transitionSprite.visible = false});
			FlxTween.tween(FlxG.camera.scroll, {y: 0}, 2, {ease: FlxEase.quartOut});

			appearKeyboard();
		}
		else if ((subState is IntroSubState))
		{
			endIntro();
		}
	}

	function openKeyboard()
	{
		doCameraBop = false;
		stopPressStartTween();
		FlxTween.tween(pressStartText, {alpha: 0}, 0.25);

		inputtingSecretCode = true;
		secretCodeInputTxt.startFocus();

		dissapearKeyboard();
	}

	function closeKeyboard(checkInput:Bool = true)
	{
		inputtingSecretCode = false;
		secretCodeInputTxt.endFocus();

		if (checkInput)
		{
			if (!checkCodeInput(secretCodeInputTxt.text))
			{
				doCameraBop = true;
				tweenPressStart();

				appearKeyboard();
			}
			else
			{
				typeCancelButton.enabled = false;
				FlxTween.cancelTweensOf(typeCancelButton);
				FlxTween.tween(typeCancelButton, {alpha: 0}, 0.25, {onComplete: (_) -> typeCancelButton.visible = false});

				typeConfirmButton.enabled = false;
				FlxTween.cancelTweensOf(typeConfirmButton);
				FlxTween.tween(typeConfirmButton, {alpha: 0}, 0.25, {onComplete: (_) -> typeConfirmButton.visible = false});
			}
		}
		else
		{
			doCameraBop = true;
			tweenPressStart();
			appearKeyboard();

			FunkinSound.playMenuSound(CANCEL);
		}

		secretCodeInputTxt.text = '';
	}

	final validCodes:Array<String> = ['legacy', 'leroy', '67', 'sneep', 'folly', 'ilovepurple', 'ihategrey'];

	function checkCodeInput(input:String):Bool
	{
		if (validCodes.contains(input.toLowerCase()))
		{
			FunkinSound.playMenuSound(CONFIRM);
			FlxG.sound.music?.fadeOut(1, 0, (_) -> FunkinSound.pauseMusic());

			switch (input.toLowerCase())
			{
				case 'leroy':
					persistentUpdate = false;
					transitionUpwards(() -> openSubState(new VideoSubState('leroy')));
			}

			return true;
		}

		FunkinSound.playMenuSound(CANCEL);

		return false;
	}

	function transitionUpwards(onComplete:Void -> Void)
	{
		allowInput = false;

		transitionSprite.visible = true;
		transitionSprite.flipY = true;
		transitionSprite.y = -FlxG.height - transitionSprite.height;
		FlxTween.tween(transitionSprite, {y: -FlxG.height}, 1, {ease: FlxEase.quartIn});
		FlxTween.tween(FlxG.camera.scroll, {y: -FlxG.height}, 1, {ease: FlxEase.quartIn, onComplete: (_) -> onComplete()});
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
