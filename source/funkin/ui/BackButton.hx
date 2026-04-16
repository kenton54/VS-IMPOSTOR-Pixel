package funkin.ui;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

class BackButton extends funkin.input.FunkinButton
{
	/**
	 * Dispatches when the button's confirm animation starts playing.
	 */
	public var onConfirmStart:FlxSignal = new FlxSignal();

	/**
	 * Dispatches when the button's confirm animation finishes playing.
	 */
	public var onConfirmEnd:FlxSignal = new FlxSignal();

	/**
	 * The opacity to tween to when the button goes idle.
	 */
	public var restOpacity:Float;

	/**
	 * If enabled, the button skips its confirm animation entirely, dispatching both signals immediately.
	 */
	public var instant:Bool;

	public function new(x:Float = 0, y:Float = 0, color:FlxColor = FlxColor.WHITE, restOpacity:Float = 0.3, instant:Bool = false)
	{
		super(x, y);

		frames = Paths.getFrames('ui/backButton');
		addAnimationByPrefix('idle', 'idle', 24, false);
		addAnimationByPrefix('press', 'press', 24, false);
		addAnimationByPrefix('confirm', 'confirm', 24, false);
		addAnimationOffsets('press', -1, -1);
		addAnimationOffsets('confirm', -7, -7);
		playAnimation('idle');

		this.color = color;

		this.restOpacity = restOpacity;
		this.instant = instant;

		onPress.add(playHold);
		onRelease.add(playConfirm);
		onUnhover.add(playIdle);
		onFinishAnimation.add(animEnd);
	}

	override function destroy()
	{
		super.destroy();

		FlxDestroyUtil.destroy(onConfirmStart);
		FlxDestroyUtil.destroy(onConfirmEnd);
	}

	var _confirming:Bool = false;

	function playIdle()
	{
		if (!enabled || _confirming)
		{
			return;
		}

		FlxTween.cancelTweensOf(this);
		playAnimation('idle');

		FlxTween.tween(this, {alpha: restOpacity}, 0.5, {ease: FlxEase.expoOut});
	}

	function playHold()
	{
		if (!enabled || _confirming)
		{
			return;
		}

		FlxTween.cancelTweensOf(this);
		playAnimation('press');

		alpha = 1;
	}

	function playConfirm()
	{
		if (!enabled || _confirming)
		{
			return;
		}

		_confirming = true;
		enabled = false;
		onConfirmStart.dispatch();

		if (instant)
		{
			_confirming = false;
			onConfirmEnd.dispatch();
			return;
		}

		playAnimation('confirm');
	}

	function animEnd(anim:String)
	{
		if (anim == 'confirm')
		{
			_confirming = false;
			onConfirmEnd.dispatch();

			playAnimation('idle');
		}
	}

	override function update(elapsed:Float)
	{
		#if android
		if (FlxG.android.justReleased.BACK && enabled)
		{
			onConfirmEnd.dispatch();
		}
		#end

		super.update(elapsed);
	}
}
