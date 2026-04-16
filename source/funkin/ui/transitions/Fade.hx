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
		playTween(fadeSprite, {alpha: 0}, 0.5);
	}

	override function transitionOut()
	{
		super.transitionOut();

		fadeSprite.alpha = 0;
		playTween(fadeSprite, {alpha: 1}, 0.5);
	}
}
