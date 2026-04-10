package funkin.menus.debug;

#if FEATURE_DEBUG_CONTENT
class DebugState extends MusicBeatState
{
	var editorsArray:Array<String> = ['Chart Editor', 'Character Editor'];

	var editorsTxt:FlxTypedGroup<FunkinText>;

	var curEntry:Int = 0;

	override public function create()
	{
		FunkinSound.stopMusic();

		super.create();

		var bg:FunkinSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.GRAY);
		add(bg);

		editorsTxt = new FlxTypedGroup<FunkinText>();
		add(editorsTxt);

		for (i in 0...editorsArray.length)
		{
			var text:FunkinText = new FunkinText(0, 0, 0, editorsArray[i], 32);
			text.screenCenter();
			text.y = (((FlxG.height - text.height) / 2) / editorsArray.length) * (i + 1);
			editorsTxt.add(text);
		}

		changeEntry();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.UP)
		{
			changeEntry(-1);
		}
		else if (FlxG.keys.justPressed.DOWN)
		{
			changeEntry(1);
		}

		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			checkEntry();
		}
		if (FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.switchState(() -> new MainMenuState());
		}
	}

	function changeEntry(change:Int = 0)
	{
		curEntry = FlxMath.wrap(curEntry + change, 0, editorsArray.length - 1);

		for (i => text in editorsTxt.members)
		{
			if (i == curEntry)
			{
				text.scale.set(1.2, 1.2);
			}
			else
			{
				text.scale.set(1, 1);
			}
		}
	}

	function checkEntry()
	{
		switch (curEntry)
		{
			case 0: // nothing yet
			case 1:
				FlxG.switchState(() -> new funkin.menus.debug.character.CharacterEditorState());
		}
	}
}
#end
