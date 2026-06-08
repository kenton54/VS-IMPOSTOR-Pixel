package funkin.system;

import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * The heart of all musical logic.
 */
final class Conductor
{
	/**
	 * Triggered when a new measure is reached.
	 */
	public static var onMeasureHit:FlxTypedSignal<Int -> Void> = new FlxTypedSignal<Int -> Void>();

	/**
	 * Triggered when a new beat is reached.
	 */
	public static var onBeatHit:FlxTypedSignal<Int -> Void> = new FlxTypedSignal<Int -> Void>();

	/**
	 * Triggered when a new step is reached.
	 */
	public static var onStepHit:FlxTypedSignal<Int -> Void> = new FlxTypedSignal<Int -> Void>();

	/**
	 * Where the conductor is currently positioned at, in milliseconds.
	 */
	public static var songPosition(default, null):Float = 0;

	/**
	 * Where the conductor is currently positioned at, as a percentage value (a value between `0` and `1`).
	 *
	 * If the Conductor is in Standalone Mode, or there's not BGM playing, it will always return `0`.
	 */
	public static var songPercent(get, never):Float;

	/**
	 * The length of the currently playing BGM.
	 *
	 * If the Conductor is in Standalone Mode, or there's not BGM playing, it will always return `0`.
	 */
	public static var songLength(get, never):Float;

	/**
	 * The current Beats per minute.
	 */
	public static var curBPM(get, never):Float;

	/**
	 * How many beats are there in a measure.
	 */
	public static var beatsPerMeasure(get, never):Int;

	/**
	 * How many steps are there in a beat.
	 */
	public static var stepsPerMeasure(get, never):Int;

	/**
	 * Where the conductor is currently positioned at, in measures.
	 */
	public static var curMeasure(default, null):Int = 0;

	/**
	 * Where the conductor is currently positioned at, in measures and fractions of a measure.
	 */
	public static var curMeasureFloat(default, null):Float = 0;

	/**
	 * Where the conductor is currently positioned at, in beats.
	 */
	public static var curBeat(default, null):Int = 0;

	/**
	 * Where the conductor is currently positioned at, in beats and fractions of a measure.
	 */
	public static var curBeatFloat(default, null):Float = 0;

	/**
	 * Where the conductor is currently positioned at, in steps.
	 */
	public static var curStep(default, null):Int = 0;

	/**
	 * Where the conductor is currently positioned at, in steps and fractions of a measure.
	 */
	public static var curStepFloat(default, null):Float = 0;

	/**
	 * Duration of a measure, in milliseconds.
	 */
	public static var measureLengthMs(get, never):Float;

	/**
	 * Duration of a beat, in milliseconds.
	 */
	public static var beatLengthMs(get, never):Float;

	/**
	 * Duration of a step, in milliseconds.
	 */
	public static var stepLengthMs(get, never):Float;

	public static var timeSignatureNum(get, never):Int;

	public static var timeSignatureDen(get, never):Int;

	/**
	 * How much to offset the conductor.
	 */
	public static var offset:Float = 0;

	/**
	 * Whether the conductor is in Standalone Mode or not.
	 *
	 * The Conductor usually follows a song playing in the background, however if this is set to `true` (when initiating the Conductor),
	 * the Conductor will work on its own, without the need of a song, great if you want to have events play on beat without music.
	 */
	public static var standalone(get, never):Bool;

	/**
	 * The list of BPM Changes the Conductor has configured for the song.
	 */
	static var bpmChanges(default, null):Array<SongTimeData> = [];

	/**
	 * The most recent BPM Change according to the song position.
	 */
	public static var curBPMChange(get, never):Null<SongTimeData>;

	/**
	 * The current BPM Change indexed from `bpmChanges`.
	 */
	static var curBPMChangeIndex(default, null):Int = 0;

	static var conductorElapsed:Float = 0;

	/**
	 * Whether the Conductor updates or not.
	 */
	static var _paused:Bool = true;

	static var _standalone:Bool = false;

	/**
	 * Starts and sets up the Conductor for global use.
	 */
	@:allow(funkin.InitState)
	static function init()
	{
		FlxG.signals.preUpdate.add(update);
	}

	public static function start(bpm:Float = 100, standalone:Bool = false, timeSignatureNum:Int = 4, timeSignatureDen:Int = 4)
	{
		conductorElapsed = songPosition = curMeasureFloat = curBeatFloat = curStepFloat = curBPMChangeIndex = 0;
		curMeasure = curBeat = curStep = -1;
		resume();

		bpmChanges = [
			{
				time: 0,
				bpm: bpm,
				timeSignatureNum: 4,
				timeSignatureDen: 4
			}
		];

		_standalone = standalone;
	}

	/**
	 * Stops and resets the Conductor.
	 */
	public static function reset()
	{
		conductorElapsed = songPosition = curMeasureFloat = curBeatFloat = curStepFloat = curBPMChangeIndex = 0;
		curMeasure = curBeat = curStep = -1;
		pause();

		bpmChanges = [];

		_standalone = false;

		onMeasureHit.removeAll();
		onBeatHit.removeAll();
		onStepHit.removeAll();
	}

	/**
	 * Pauses the Conductor.
	 */
	public static function pause()
	{
		if (!_paused)
		{
			_paused = true;
		}
	}

	/**
	 * Resumes the Conductor if paused.
	 */
	public static function resume()
	{
		if (_paused)
		{
			_paused = false;
		}
	}

	/**
	 * Stops and resets the Conductor.
	 *
	 * An alternative to the method `reset`.
	 */
	public static function stop()
	{
		reset();
	}

	static function update()
	{
		if (_paused)
		{
			return;
		}

		var curSongTime:Float = _standalone ? conductorElapsed : (FlxG.sound.music != null ? FlxG.sound.music.time : 0);
		var curSongLength:Float = _standalone ? Math.POSITIVE_INFINITY : (FlxG.sound.music != null ? FlxG.sound.music.length : 0);

		var oldMeasure:Int = curMeasure;
		var oldBeat:Int = curBeat;
		var oldStep:Int = curStep;

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			songPosition = FlxMath.bound(Math.min(offset, 0), curSongTime, curSongLength);
			conductorElapsed += FlxG.elapsed * 1000 * FlxG.sound.music.pitch;
		}
		else if (_standalone)
		{
			conductorElapsed += FlxG.elapsed * 1000;
		}

		curStepFloat = FlxMath.roundDecimal((curSongTime / stepLengthMs), 4);
		curBeatFloat = curStepFloat / 4;
		curMeasureFloat = curStepFloat / stepsPerMeasure;

		curStep = Math.floor(curStepFloat);
		curBeat = Math.floor(curBeatFloat);
		curMeasure = Math.floor(curMeasureFloat);

		if (curStep != oldStep)
		{
			onStepHit.dispatch(curStep);
		}
		if (curBeat != oldBeat)
		{
			onBeatHit.dispatch(curBeat);
		}
		if (curMeasure != oldMeasure)
		{
			onMeasureHit.dispatch(curMeasure);
		}

		for (i in 0...bpmChanges.length)
		{
			if (songPosition >= bpmChanges[i].time)
			{
				curBPMChangeIndex = i;
			}
			if (songPosition < bpmChanges[i].time)
			{
				break;
			}
		}
	}

	static function get_songPercent():Float
	{
		if (songLength == 0)
		{
			return 0;
		}
		else
		{
			return songPosition / songLength;
		}
	}

	static function get_songLength():Float
	{
		if (FlxG.sound.music != null && !_standalone)
		{
			return FlxG.sound.music.length;
		}
		else
		{
			return 0;
		}
	}

	static function get_curBPMChange():SongTimeData
	{
		return bpmChanges[curBPMChangeIndex];
	}

	static function get_curBPM():Float
	{
		return curBPMChange?.bpm ?? 0;
	}

	static function get_beatsPerMeasure():Int
	{
		return timeSignatureNum;
	}

	static function get_stepsPerMeasure():Int
	{
		return Std.int(timeSignatureNum * 4);
	}

	static function get_measureLengthMs():Float
	{
		return beatLengthMs * timeSignatureNum;
	}

	static function get_beatLengthMs():Float
	{
		return (60 / curBPM) * 1000 * (4 / timeSignatureDen);
	}

	static function get_stepLengthMs():Float
	{
		return beatLengthMs / 4;
	}

	static function get_timeSignatureNum():Int
	{
		return curBPMChange?.timeSignatureNum ?? 4;
	}

	static function get_timeSignatureDen():Int
	{
		return curBPMChange?.timeSignatureDen ?? 4;
	}

	static function get_standalone():Bool
	{
		return _standalone;
	}
}

typedef SongTimeData =
{
	var time:Float;

	var bpm:Float;

	var timeSignatureNum:Int;

	var timeSignatureDen:Int;
}
