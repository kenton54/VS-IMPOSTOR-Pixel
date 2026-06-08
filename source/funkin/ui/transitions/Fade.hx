package funkin.ui.transitions;

class Fade extends BaseTransition
{
	var fadeSprite:FunkinSprite;

	override function create()
	{
		fadeSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(fadeSprite);

		super.create();
	}

	override function transitionIn()
	{
		super.transitionIn();

		fadeSprite.alpha = 1;
		playTween(fadeSprite, {alpha: 0}, 0.25, {onComplete: (_) -> complete()});
	}

	override function transitionOut()
	{
		super.transitionOut();

		fadeSprite.alpha = 0;
		playTween(fadeSprite, {alpha: 1}, 0.25, {onComplete: (_) -> complete()});
	}
}
