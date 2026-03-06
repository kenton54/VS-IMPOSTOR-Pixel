package funkin.play;

import funkin.ui.MusicBeatState;

class PlayState extends MusicBeatState
{
	override public function create()
	{
		super.create();

		FunkinSound.playMusic(Paths.music('mainMenu'), 1, {bpm: 102});

		#if DISCORD_API
		DiscordClient.changePresence({
			state: "testing source",
			details: "Source Port"
		});
		#end

		var textTestLol:FunkinText = new FunkinText(4, 30, FlxG.width, "This is a text to test if this shit actually gets loaded, also hi", 36);
		add(textTestLol);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
