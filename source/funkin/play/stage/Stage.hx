package funkin.play.stage;

import flixel.FlxState;

class Stage extends FlxTypedGroup<Bopper>
{
	public var name(default, null):String;

	public var camZoom(default, null):Float;

	var sprites(default, null):Map<String, Bopper> = [];

	var _parent:FlxState;

	var _queuedBuildStage:Bool = false;

	public function loadStage(stage:String)
	{
		if (_parent == null)
		{
			_queuedBuildStage = true;
		}
		else
		{
			buildStage();
		}
	}

	function buildStage() {}

	/**
	 * @param id The ID of the stage object.
	 * @return The object inside the stage with the matching ID.
	 */
	public function getSprite(id:String):Bopper
	{
		return sprites.get(id);
	}
}
