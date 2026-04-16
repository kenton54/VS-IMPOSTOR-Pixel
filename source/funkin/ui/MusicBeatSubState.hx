package funkin.ui;

class MusicBeatSubState extends flixel.FlxSubState
{
	/**
	 * Player 1's controls.
	 */
	public var controls(get, never):funkin.input.Controls;

	/**
	 * The Conductor's current song measure.
	 */
	public var curMeasure(get, never):Int;

	/**
	 * The Conductor's current song beat.
	 */
	public var curBeat(get, never):Int;

	/**
	 * The Conductor's current song step.
	 */
	public var curStep(get, never):Int;

	/**
	 * Gets called after the state has fully switched.
	 *
	 * Has very niche use cases.
	 */
	public function createPost() {}

	/**
	 * Gets called by the Conductor when it reaches a new measure.
	 * @param measure The reached measure.
	 */
	public function measureHit(measure:Int) {}

	/**
	 * Gets called by the Conductor when it reaches a new beat.
	 * @param beat The reached beat.
	 */
	public function beatHit(beat:Int) {}

	/**
	 * Gets called by the Conductor when it reaches a new step.
	 * @param step The reached step.
	 */
	public function stepHit(step:Int) {}

	/**
	 * Gets called whenever the game's language gets updated.
	 * @param language The new language.
	 */
	public function onLanguageUpdate(language:String) {}

	function get_controls():funkin.input.Controls
	{
		return funkin.input.InputManager.controlsP1;
	}

	function get_curMeasure():Int
	{
		return Conductor.curMeasure;
	}

	function get_curBeat():Int
	{
		return Conductor.curBeat;
	}

	function get_curStep():Int
	{
		return Conductor.curStep;
	}
}
