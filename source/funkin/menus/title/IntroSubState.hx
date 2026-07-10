package funkin.menus.title;

import funkin.utils.TweenUtil;

class IntroSubState extends MusicBeatState
{
	var bg:FunkinSprite;
	var introText:FunkinText;
	var presentsText:FunkinText;

	var legacyLogo:FunkinSprite;

	var introLogo:FunkinSprite;
	var logoGlow:FunkinSprite;
	var logoShine:FunkinSprite;

	var introIndex:Int = 0;
	var introEvents:Array<TitleIntroEventParams>;

	public function new()
	{
		super();

		introEvents = [
			{
				step: 4,
				func: function()
				{
					addText('kenton');
				}
			},
			{
				step: 8,
				func: function()
				{
					addTranslation('titleScreen.intro.team', ['VS IMPOSTOR Pixel']);
				}
			},
			{
				step: 12,
				func: function()
				{
					addTranslation('titleScreen.intro.presents');
				}
			},
			{
				step: 16,
				func: function()
				{
					var lineMetrics:openfl.text.TextLineMetrics = introText.textField.getLineMetrics(2);
					presentsText.text = introText.textField.getLineText(2);
					presentsText.y = introText.y + lineMetrics.leading + lineMetrics.height * 2;
					presentsText.visible = true;

					resetText();

					FlxTween.tween(presentsText, {y: FlxG.height * 0.14}, (Conductor.stepLengthMs / 1000) * 4, {ease: FlxEase.quartIn});
				}
			},
			{
				step: 20,
				func: function()
				{
					addTranslation('titleScreen.intro.modBased');
					FlxTween.tween(introText, {y: FlxG.height * 0.22}, (Conductor.stepLengthMs / 1000) * 4, {startDelay: (Conductor.stepLengthMs / 1000) * 2, ease: FlxEase.quadIn});
				}
			},
			{
				step: 24,
				func: function()
				{
					FlxTween.cancelTweensOf(introText);
					FlxTween.tween(introText, {y: FlxG.height * 0.22}, (Conductor.stepLengthMs / 1000) * 4, {ease: FlxEase.quartOut});

					legacyLogo.visible = true;
					legacyLogo.alpha = 0;
					legacyLogo.scale.set();
					FlxTween.tween(legacyLogo, {alpha: 0.75, 'scale.x': 0.5, 'scale.y': 0.5}, (Conductor.stepLengthMs / 1000) * 4, {ease: FlxEase.quintIn});
				}
			},
			{
				step: 28,
				func: function()
				{
					FlxTween.cancelTweensOf(legacyLogo);
					legacyLogo.scale.set(0.75, 0.75);
					legacyLogo.alpha = 1;
				}
			},
			{
				step: 32,
				func: function()
				{
					resetText();
					presentsText.visible = false;
					legacyLogo.visible = false;
				}
			},
			{
				step: 36,
				func: function()
				{
					addText('splash 1');
					introText.y = FlxG.height * 0.3;
				}
			},
			{
				step: 44,
				func: function()
				{
					addText('splash 2');
					introText.y = FlxG.height * 0.3;
				}
			},
			{
				step: 48,
				func: function()
				{
					resetText();
				}
			},
			{
				step: 52,
				func: function()
				{
					FlxTween.cancelTweensOf(introLogo);

					introLogo.playAnimation('versus');
					introLogo.alpha = 1;
					FlxTween.tween(introLogo, {alpha: 0}, (Conductor.stepLengthMs / 1000) * 4);
				}
			},
			{
				step: 56,
				func: function()
				{
					FlxTween.cancelTweensOf(introLogo);

					introLogo.playAnimation('impostor');
					introLogo.alpha = 1;
					FlxTween.tween(introLogo, {alpha: 0}, (Conductor.stepLengthMs / 1000) * 4);
				}
			},
			{
				step: 60,
				func: function()
				{
					FlxTween.cancelTweensOf(introLogo);

					introLogo.playAnimation('pixel');
					introLogo.alpha = 1;

					logoShine.scale.set(0.8, 0.8);

					FlxTween.tween(logoGlow, {alpha: 0.5}, (Conductor.stepLengthMs / 1000) * 4, {ease: FlxEase.quadIn});
					FlxTween.tween(logoShine, {alpha: 0.3, 'scale.x': 1.05, 'scale.y': 1.05}, (Conductor.stepLengthMs / 1000) * 4, {ease: FlxEase.quadIn});

					FlxG.camera.fade(0x40FFFFFF, (Conductor.stepLengthMs / 1000) * 4);
				}
			},
			{
				step: 64,
				func: function()
				{
					close();
				}
			}
		];
	}

	override function create()
	{
		super.create();

		bg = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);

		legacyLogo = new FunkinSprite().loadGraphic(Paths.image('menus/title/legacyLogo'));
		legacyLogo.scaleSprite(0.65);
		legacyLogo.scrollFactor.set();
		legacyLogo.screenCenter(X);
		legacyLogo.y = FlxG.height * 0.82 - legacyLogo.height;
		legacyLogo.visible = false;
		add(legacyLogo);

		logoGlow = new FunkinSprite().loadGraphic(Paths.image('menus/title/logoGlow'));
		logoGlow.alpha = 0;
		add(logoGlow);

		logoShine = new FunkinSprite().loadGraphic(Paths.image('menus/title/logoShine'));
		logoShine.alpha = 0;
		logoShine.blend = ADD;
		add(logoShine);

		introLogo = new FunkinSprite().loadSprite('menus/title/introLogo');
		introLogo.addAnimationByPrefix('versus', 'versus', 0, false);
		introLogo.addAnimationByPrefix('impostor', 'impostor', 0, false);
		introLogo.addAnimationByPrefix('pixel', 'pixel', 40, false);
		introLogo.scaleSprite(4);
		introLogo.screenCenter(X);
		introLogo.y = FlxG.height * 0.2;
		introLogo.alpha = 0;
		add(introLogo);

		logoGlow.x = introLogo.x + (introLogo.width - logoGlow.width) / 2;
		logoGlow.y = introLogo.y + (introLogo.height - logoGlow.height) / 2;

		logoShine.x = introLogo.x + (introLogo.width - logoShine.width) / 2;
		logoShine.y = introLogo.y + (introLogo.height - logoShine.height) / 2;

		introText = new FunkinText(0, 0, FlxG.width, '', 44);
		introText.scrollFactor.set();
		introText.alignment = CENTER;
		introText.screenCenter();
		add(introText);

		presentsText = new FunkinText(0, 0, FlxG.width, '', 44);
		presentsText.scrollFactor.set();
		presentsText.alignment = CENTER;
		presentsText.screenCenter();
		presentsText.visible = false;
		add(presentsText);
	}

	override function update(elapsed:Float)
	{
		if (legacyLogo.visible && !TweenUtil.hasTweens(legacyLogo))
		{
			legacyLogo.scale.x = legacyLogo.scale.y = FlxMath.lerp(legacyLogo.scale.x, 0.65, FlxMath.getElapsedLerp(0.08, elapsed));
		}

		super.update(elapsed);
	}

	override function stepHit(step:Int)
	{
		if (step > 64)
		{
			close();
			return;
		}

		if (introEvents != null)
		{
			var curIntroEvent:TitleIntroEventParams = introEvents[introIndex];
			if (curIntroEvent != null)
			{
				if (step >= curIntroEvent.step)
				{
					curIntroEvent?.func();
					introIndex++;
				}
			}
		}

		super.stepHit(step);
	}

	function addText(text:String)
	{
		if (introText.text.length == 0)
		{
			introText.text = text;
		}
		else
		{
			introText.text += '\n$text';
		}

		introText.screenCenter();
	}

	function addTranslation(id:String, ?params:Array<Dynamic>)
	{
		addText(funkin.system.Translations.translate(id, params));
	}

	function resetText()
	{
		introText.text = '';
		introText.clearFormats();
		introText.screenCenter();
	}
}

typedef TitleIntroEventParams =
{
	/**
	 * The step this event occurs.
	 */
	var step:Int;

	/**
	 * The function to call when the event gets executed.
	 */
	var ?func:Void -> Void;
}
