package funkin.ui;

class XButton extends funkin.input.FunkinButton
{
	public function new(x:Float = 0, y:Float = 0, trigger:Void -> Void)
	{
		super(x, y);
		loadGraphic(Paths.image('ui/x'));

		onPress.add(trigger);
	}

	override function update(elapsed:Float)
	{
		#if android
		if (FlxG.android.justReleased.BACK)
		{
			onPress.dispatch();
		}
		#end

		super.update(elapsed);
	}
}
