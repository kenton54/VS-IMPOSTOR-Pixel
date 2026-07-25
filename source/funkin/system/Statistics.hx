package funkin.system;

class Statistics
{
	/**
	 * The user's total passed time playing the game.
	 */
	public static var playtime(default, null):Float;

	/**
	 * The total amount of notes the user has hit.
	 */
	public static var totalNoteHits(default, null):Int;

	/**
	 * The total amount of notes the user has hit with a Perfect rating.
	 */
	public static var perfectNoteHits(default, null):Int;

	/**
	 * The total amount of notes the user has hit with a Great rating.
	 */
	public static var greatNoteHits(default, null):Int;

	/**
	 * The total amount of notes the user has hit with a Good rating.
	 */
	public static var goodNoteHits(default, null):Int;

	/**
	 * The total amount of notes the user has hit with a Bad rating.
	 */
	public static var badNoteHits(default, null):Int;

	/**
	 * The total amount of notes the user has hit with an Awful rating.
	 */
	public static var awfulNoteHits(default, null):Int;

	/**
	 * The total amount of notes the user has missed.
	 */
	public static var missedNotes(default, null):Int;

	/**
	 * The total amount of combos the user broke.
	 */
	public static var combosBroken(default, null):Int;

	@:noCompletion static function init()
	{
		playtime = FunkinSave.stats?.playtime ?? 0;
		totalNoteHits = FunkinSave.stats?.totalNoteHits ?? 0;
		perfectNoteHits = FunkinSave.stats?.perfectNoteHits ?? 0;
		greatNoteHits = FunkinSave.stats?.greatNoteHits ?? 0;
		goodNoteHits = FunkinSave.stats?.goodNoteHits ?? 0;
		badNoteHits = FunkinSave.stats?.badNoteHits ?? 0;
		awfulNoteHits = FunkinSave.stats?.awfulNoteHits ?? 0;
		missedNotes = FunkinSave.stats?.missedNotes ?? 0;
		combosBroken = FunkinSave.stats?.combosBroken ?? 0;

		FlxG.signals.postUpdate.add(updatePlaytime.bind(FlxG.elapsed));
		lime.app.Application.current.window.onClose.add(saveStats);
	}

	static function updatePlaytime(elapsed:Float)
	{
		playtime += elapsed;
	}

	static function saveStats()
	{
		FunkinSave.stats.playtime = playtime;
		FunkinSave.stats.totalNoteHits = totalNoteHits;
		FunkinSave.stats.perfectNoteHits = perfectNoteHits;
		FunkinSave.stats.greatNoteHits = greatNoteHits;
		FunkinSave.stats.goodNoteHits = goodNoteHits;
		FunkinSave.stats.badNoteHits = badNoteHits;
		FunkinSave.stats.awfulNoteHits = awfulNoteHits;
		FunkinSave.stats.missedNotes = missedNotes;
		FunkinSave.stats.combosBroken = combosBroken;

		FunkinSave.flush();
	}
}
