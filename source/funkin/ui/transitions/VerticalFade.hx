package funkin.ui.transitions;

class VerticalFade extends BaseTransition
{
	/**
	 * Whether the fade should go up instead of down.
	 */
	public static var inverse:Bool = false;

	var fadeSprite:FunkinSprite;
	var blackSpr:FunkinSprite;

	override function create()
	{
		var fadeBitmap = flixel.util.FlxGradient.createGradientBitmapData(1, FlxG.height, [FlxColor.TRANSPARENT, FlxColor.BLACK]);
		fadeSprite = new FunkinSprite().loadGraphic(fadeBitmap);
		fadeSprite.scaleSprite(FlxG.width, 1);
		add(fadeSprite);

		blackSpr = new FunkinSprite().makeGraphic(1, FlxG.height, FlxColor.BLACK);
		blackSpr.scaleSprite(FlxG.width, 1);
		add(blackSpr);

		super.create();
	}

	override function transitionIn()
	{
		super.transitionIn();

		blackSpr.y = inverse ? -transitionCamera.height : transitionCamera.height;
		fadeSprite.flipY = inverse;

		var startPos:Float = transitionCamera.height * (inverse ? -1 : 1);
		var endPos:Float = -transitionCamera.height * (inverse ? -1 : 1);
		transitionCamera.scroll.y = startPos;
		playTween(transitionCamera.scroll, {y: endPos}, 0.5, {ease: FlxEase.sineOut, onComplete: (_) -> complete()});
	}

	override function transitionOut()
	{
		super.transitionOut();

		blackSpr.y = inverse ? transitionCamera.height : -transitionCamera.height;
		fadeSprite.flipY = !inverse;

		var startPos:Float = transitionCamera.height * (inverse ? -1 : 1);
		var endPos:Float = -transitionCamera.height * (inverse ? -1 : 1);
		transitionCamera.scroll.y = startPos;
		playTween(transitionCamera.scroll, {y: endPos}, 0.5, {ease: FlxEase.sineOut, onComplete: (_) -> complete()});
	}

	override function complete()
	{
		super.complete();

		if (isTransitionIn)
		{
			inverse = false;
		}
	}
}
