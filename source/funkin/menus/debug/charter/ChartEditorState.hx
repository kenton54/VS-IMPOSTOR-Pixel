package funkin.menus.debug.charter;

#if FEATURE_DEBUG_CONTENT
import funkin.play.PlayState;

import openfl.display.Sprite;
import openfl.events.Event;

class ChartEditorState extends Sprite
{
	public static var instance:Null<ChartEditorState> = null;

	public static function openChartEditor()
	{
		FlxG.switchState(() -> new PlayState());
		FlxG.signals.postStateSwitch.add(createChartEditor);
	}

	static function createChartEditor()
	{
		FlxG.signals.postStateSwitch.remove(createChartEditor);
		FlxG.addChildBelowMouse(new ChartEditorState());
	}

	public function new()
	{
		super();

		instance = this;

		addEventListener(Event.ADDED_TO_STAGE, create);
	}

	function create(_) {}
}
#end
