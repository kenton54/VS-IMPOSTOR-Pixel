package funkin.graphics.video;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

#if hxvlc
// this is only used in hxvlc lol
import haxe.Int64;

import hxvlc.flixel.FlxVideoSprite;
#end

/**
 * Cross-platform video playback.
 *
 * It's used as a bridge between HxVLC and the `FlxVideo` class.
 */
class FunkinVideo extends #if hxvlc FlxVideoSprite #else FlxVideo #end
{
	/**
	 * Triggered when the video finished loading and setting up.
	 */
	public var onFormatSetup(default, null):FlxSignal = new FlxSignal();

	/**
	 * Triggered when the video starts playing.
	 */
	public var onPlay(default, null):FlxSignal = new FlxSignal();

	/**
	 * Triggered when the video finishes playing.
	 */
	public var onFinish(default, null):FlxSignal = new FlxSignal();

	#if hxvlc
	/**
	 * Whether the video is currently playing.
	 */
	public var playing(default, null):Bool = false;

	/**
	 * Where the playhead is positioned, in milliseconds.
	 */
	public var time(get, set):Float;

	/**
	 * The duration of the video, in milliseconds.
	 */
	public var length(get, never):Float;

	/**
	 * The rate at which the video is being played back.
	 */
	public var playbackRate(get, set):Float;

	/**
	 * If the video should loop indefinitely.
	 *
	 * Can only be set when loading a video.
	 */
	public var looped(default, null):Bool = false;
	#end

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		#if hxvlc
		bitmap.onFormatSetup.add(() ->
		{
			updateHitbox();
			onFormatSetup.dispatch();
		});
		bitmap.onPlaying.add(() -> onPlay.dispatch());
		bitmap.onEndReached.add(() -> onFinish.dispatch());
		#else
		formatSetup.add(() -> onFormatSetup.dispatch());
		startPlaying.add(() -> onPlay.dispatch());
		endReach.add(() -> onFinish.dispatch());
		#end
	}

	override function destroy()
	{
		super.destroy();

		FlxDestroyUtil.destroy(onFormatSetup);
		FlxDestroyUtil.destroy(onPlay);
		FlxDestroyUtil.destroy(onFinish);
	}

	/**
	 * Loads a video file in the specified directory or URL.
	 *
	 * @param path The directory where the file is located, or the URL of the video file.
	 * @param loop Whether the video should loop.
	 * @return This `FunkinVideo` instance, for chaining.
	 */
	#if hxvlc public #else override #end function loadVideo(path:String, loop:Bool = false):FunkinVideo
	{
		#if hxvlc
		load(path, loop ? ['--loop'] : null);
		looped = loop;
		#else
		super.loadVideo(path, loop);
		#end

		return this;
	}

	#if hxvlc
	override function play():Bool
	{
		playing = true;
		return super.play();
	}

	override function pause()
	{
		super.pause();
		playing = true;
	}

	override function resume()
	{
		super.resume();
		playing = true;
	}

	override function stop()
	{
		super.stop();
		playing = true;
	}

	function get_time():Float
	{
		return cast Int64.toInt(bitmap.time);
	}

	function set_time(value:Float):Float
	{
		bitmap.time = Int64.fromFloat(value);
		return value;
	}

	function get_length():Float
	{
		return cast Int64.toInt(bitmap.length);
	}

	function get_playbackRate():Float
	{
		return bitmap.rate;
	}

	function set_playbackRate(value:Float):Float
	{
		return bitmap.rate = value;
	}
	#end
}
