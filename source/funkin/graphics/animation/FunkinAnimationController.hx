package funkin.graphics.animation;

import animate.FlxAnimateController;

class FunkinAnimationController extends FlxAnimateController
{
	var _funkinSprite:FunkinSprite;

	public function new(sprite:FunkinSprite)
	{
		super(sprite);
		_funkinSprite = sprite;
	}

	override function play(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
	{
		animName = (animName == null || animName == '') ? _funkinSprite.getDefaultAnimation() : animName;

		if (!_funkinSprite.hasAnimation(animName))
		{
			return;
		}

		super.play(animName, force, reversed, frame);
	}
}
