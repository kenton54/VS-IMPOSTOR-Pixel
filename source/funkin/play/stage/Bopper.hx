package funkin.play.stage;

class Bopper extends FunkinSprite
{
	/**
	 * How often the bopper plays the dance animation every beat.
	 *
	 * If set to `0`, it won't dance.
	 */
	public var danceEvery:Float = 0;

	/**
	 * Whether the bopper should bop every beat, regardless if the animation is finished or not.
	 */
	public var bopEveryBeat:Bool = false;

	/**
	 * Whether the bopper should play the `danceLeft` and `danceRight` animations instead of `idle`.
	 */
	public var shouldAlternate:Bool = false;

	/**
	 * Optional suffix to add to the dance animations.
	 */
	public var danceSuffix(default, set):String = '';

	public function new(x:Float = 0, y:Float = 0, danceEvery:Float = 0)
	{
		super(x, y);
		this.danceEvery = danceEvery;
	}

	override function initVars()
	{
		super.initVars();

		Conductor.onMeasureHit.add(measureHit);
		Conductor.onBeatHit.add(beatHit);
		Conductor.onStepHit.add(stepHit);
	}

	override function destroy()
	{
		super.destroy();

		Conductor.onMeasureHit.remove(measureHit);
		Conductor.onBeatHit.remove(beatHit);
		Conductor.onStepHit.remove(stepHit);
	}

	var danced:Bool = false;

	/**
	 * Called every time the bopper will dance, usually every beat.
	 *
	 * @param forceRestart Whether to forcefully restart the animation, if this the same that will play.
	 */
	public function dance(forceRestart:Bool = false)
	{
		if (canAlternate() && shouldAlternate)
		{
			if (danced)
			{
				playAnimation('danceRight$danceSuffix', forceRestart);
			}
			else
			{
				playAnimation('danceLeft$danceSuffix', forceRestart);
			}

			danced = !danced;
		}
		else
		{
			playAnimation('idle$danceSuffix', forceRestart);
		}
	}

	function measureHit(measure:Int) {}

	function beatHit(beat:Int) {}

	function stepHit(step:Int)
	{
		if (danceEvery > 0 && (step % (danceEvery * Conductor.timeSignatureNum)) == 0)
		{
			dance(bopEveryBeat);
		}
	}

	function canAlternate():Bool
	{
		return hasAnimation('danceLeft$danceSuffix') || hasAnimation('danceRight$danceSuffix');
	}

	function set_danceSuffix(value:String):String
	{
		danceSuffix = value;
		dance();
		return value;
	}
}
