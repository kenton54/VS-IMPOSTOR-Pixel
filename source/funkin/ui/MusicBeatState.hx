package funkin.ui;

import flixel.FlxSubState;

import funkin.input.Controls;
import funkin.system.FullScreenScaleMode;
import funkin.ui.transitions.BaseTransition;

@:access(flixel.FlxState)
@:access(flixel.FlxSubState)
class MusicBeatState extends FlxSubState
{
	/**
	 * Whether to skip the next transition intro.
	 */
	public static var skipTransIn:Bool = false;

	/**
	 * Whether to skip the next transition outro.
	 */
	public static var skipTransOut:Bool = false;

	/**
	 * Transition to play after the game has switched to the new state.
	 */
	public static var transitionIn:Null<Class<BaseTransition>> = null;

	/**
	 *  Transition to play before the game switches to a new state.
	 */
	public static var transitionOut:Null<Class<BaseTransition>> = null;

	/**
	 * Helper function to set the intro and outro transitions.
	 *
	 * @param transition The transition.
	 */
	public static function setTransitions(?transition:Class<BaseTransition>)
	{
		MusicBeatState.transitionIn = transition;
		MusicBeatState.transitionOut = transition;
	}

	/**
	 * Resets the intro and outro transitions and their flags.
	 */
	public static function resetTransitions()
	{
		transitionIn = null;
		transitionOut = null;

		skipTransIn = false;
		skipTransOut = false;
	}

	/**
	 * Player 1's controls.
	 */
	public var controls(get, never):Controls;

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
	 * Current playing transition.
	 */
	public var transState(default, null):BaseTransition;

	var _requestTransition:BaseTransition;
	var _requestTransitionReset:Bool = false;
	var _transitionIn:Bool = false;

	/**
	 * Creates a new state with the ability to do transitions and do stuff on beats.
	 */
	public function new()
	{
		if (FullScreenScaleMode.instance != null)
		{
			FullScreenScaleMode.instance.onMeasurePostAwait();
		}

		super();

		Conductor.onMeasureHit.add(measureHit);
		Conductor.onBeatHit.add(beatHit);
		Conductor.onStepHit.add(stepHit);

		FlxG.signals.postStateSwitch.add(createPost);
	}

	override public function destroy()
	{
		super.destroy();

		Conductor.onMeasureHit.remove(measureHit);
		Conductor.onBeatHit.remove(beatHit);
		Conductor.onStepHit.remove(stepHit);

		FlxG.signals.postStateSwitch.remove(createPost);

		if (transState != null)
		{
			if (!transState.completed)
			{
				transState.complete();
			}

			transState.destroy();
			transState = null;
		}
	}

	/**
	 * Gets called after the state has fully switched.
	 *
	 * Used to play transitions, but can be used for other niche things.
	 */
	public function createPost()
	{
		if (subState != null && Std.isOfType(subState, MusicBeatState))
		{
			cast(subState, MusicBeatState).createPost();
		}

		startIntro();
	}

	/**
	 * Gets called by the Conductor when it reaches a new measure.
	 * @param measure The reached measure.
	 */
	public function measureHit(measure:Int)
	{
		if (subState != null && Std.isOfType(subState, MusicBeatState))
		{
			cast(subState, MusicBeatState).measureHit(measure);
		}

		if (transState != null)
		{
			transState.measureHit(measure);
		}
	}

	/**
	 * Gets called by the Conductor when it reaches a new beat.
	 * @param beat The reached beat.
	 */
	public function beatHit(beat:Int)
	{
		if (subState != null && Std.isOfType(subState, MusicBeatState))
		{
			cast(subState, MusicBeatState).beatHit(beat);
		}

		if (transState != null)
		{
			transState.beatHit(beat);
		}
	}

	/**
	 * Gets called by the Conductor when it reaches a new step.
	 * @param step The reached step.
	 */
	public function stepHit(step:Int)
	{
		if (subState != null && Std.isOfType(subState, MusicBeatState))
		{
			cast(subState, MusicBeatState).stepHit(step);
		}

		if (transState != null)
		{
			transState.stepHit(step);
		}
	}

	/**
	 * Gets called whenever the game's language gets updated.
	 * @param language The new language.
	 */
	public function onLanguageUpdate(language:String)
	{
		if (subState != null && Std.isOfType(subState, MusicBeatState))
		{
			cast(subState, MusicBeatState).onLanguageUpdate(language);
		}

		if (transState != null)
		{
			transState.onLanguageUpdate(language);
		}
	}

	override function onFocus()
	{
		super.onFocus();

		if (subState != null)
		{
			subState.onFocus();
		}

		if (transState != null)
		{
			transState.onFocus();
		}
	}

	override function onFocusLost()
	{
		super.onFocusLost();

		if (subState != null)
		{
			subState.onFocusLost();
		}

		if (transState != null)
		{
			transState.onFocusLost();
		}
	}

	override function onResize(width:Int, height:Int)
	{
		super.onResize(width, height);

		if (subState != null)
		{
			subState.onResize(width, height);
		}

		if (transState != null)
		{
			transState.onResize(width, height);
		}
	}

	override function draw()
	{
		super.draw();

		if (transState != null)
		{
			transState.draw();
		}
	}

	function resetTransition()
	{
		if (transState != null)
		{
			if (!transState.completed)
			{
				transState.complete();
			}

			if (transState.closeCallback != null)
			{
				transState.closeCallback();
			}

			transState.destroy();
		}

		transState = _requestTransition;
		_requestTransition = null;

		if (transState != null)
		{
			transState._parentState = this;

			if (!transState._created)
			{
				transState._created = true;
				transState.create();
			}

			if (transState.openCallback != null)
			{
				transState.openCallback();
			}

			if (_transitionIn)
			{
				transState.transitionIn();
			}
			else
			{
				transState.transitionOut();
			}
		}
	}

	override function tryUpdate(elapsed:Float)
	{
		super.tryUpdate(elapsed);

		if (_requestTransitionReset)
		{
			_requestTransitionReset = false;
			resetTransition();
		}

		if (transState != null)
		{
			transState.tryUpdate(elapsed);

			if (transState.completed)
			{
				_requestTransitionReset = true;
			}
		}
	}

	/**
	 * Called after the state has been created.
	 */
	public function startIntro()
	{
		if (!skipTransIn && transitionIn != null)
		{
			_requestTransition = Type.createInstance(transitionIn, []);
			_transitionIn = true;

			_requestTransitionReset = true;
		}

		resetTransitions();
	}

	override function startOutro(onOutroComplete:Void -> Void)
	{
		if (!skipTransOut && transitionOut != null)
		{
			_requestTransition = Type.createInstance(transitionOut, [onOutroComplete]);
			_transitionIn = false;

			_requestTransitionReset = true;
		}
		else
		{
			super.startOutro(onOutroComplete);
		}
	}

	function get_controls():Controls
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
