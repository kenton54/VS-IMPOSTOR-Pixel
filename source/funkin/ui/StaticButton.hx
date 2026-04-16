package funkin.ui;

class StaticButton extends funkin.input.FunkinButton
{
	public function new(x:Float = 0, y:Float = 0, image:String, trigger:Void -> Void)
	{
		super(x, y);
		loadGraphic(image);

		onRelease.add(trigger);
	}

	override function update(elapsed:Float)
	{
		#if android
		if (FlxG.android.justReleased.BACK && enabled)
		{
			onRelease.dispatch();
		}
		#end

		super.update(elapsed);
	}
}
