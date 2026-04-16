package funkin.ui.transitions;

import flixel.FlxBasic;

class BaseTransition extends MusicBeatSubState
{
	/**
	 * Whether the transition has fully played.
	 */
	public var completed(default, null):Bool = false;

	/**
	 * Whether the currently playing transition is an intro.
	 *
	 * If `false`, it's an outro.
	 */
	public var isTransitionIn(default, null):Bool = false;

	var transitionCamera:FlxCamera;

	var _transitionTweens:Array<FlxTween> = [];

	var onComplete:Void -> Void;

	public function new(?onComplete:Void -> Void)
	{
		super();

		this.onComplete = onComplete;

		transitionCamera = new FlxCamera();
		transitionCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(transitionCamera, false);
	}

	override function add(basic:FlxBasic):FlxBasic
	{
		super.add(basic);
		basic.cameras = [transitionCamera];
		return basic;
	}

	/**
	 * Gets called after the game has switched to the new state.
	 */
	public function transitionIn()
	{
		isTransitionIn = true;
	}

	/**
	 * Gets called before the game switches to a new state.
	 */
	public function transitionOut()
	{
		isTransitionIn = false;
	}

	/**
	 * Tweens the values of an object.
	 *
	 * Preferibly use this function instead of `FlxTween.tween` to prevent crashes.
	 *
	 * @param object    The object containing the properties to tween.
	 * @param values    An object containing key/value pairs of properties and target values.
	 * @param duration  How long the tween should be played for,  in seconds.
	 * @param options   Extra options to set to the tween.
	 */
	public function playTween(object:Dynamic, values:Dynamic, duration:Float = 1, ?options:TweenOptions)
	{
		_transitionTweens.push(FlxTween.tween(object, values, duration, options));
	}

	/**
	 * Completes the transition.
	 *
	 * If it's called mid-through the transition, it abruptly finishes it.
	 */
	public function complete()
	{
		if (completed)
		{
			return;
		}

		completed = true;

		if (onComplete != null)
		{
			onComplete();
		}
	}

	override function destroy()
	{
		super.destroy();

		FlxG.cameras.remove(transitionCamera);

		for (tween in _transitionTweens)
		{
			if (tween != null)
			{
				tween.cancel();
				tween.destroy();
			}
		}
	}
}
