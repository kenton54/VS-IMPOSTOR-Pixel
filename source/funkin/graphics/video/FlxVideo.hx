package funkin.graphics.video;

#if web
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

import openfl.events.NetStatusEvent;
import openfl.media.SoundTransform;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;

/**
 * Handles video playback for Web targets.
 */
class FlxVideo extends FlxSprite
{
	/**
	 * Triggered when the video finished loading and setting up.
	 */
	public var formatSetup(default, null):FlxSignal = new FlxSignal();

	/**
	 * Triggered when the video starts playing.
	 */
	public var startPlaying(default, null):FlxSignal = new FlxSignal();

	/**
	 * Triggered when the video finishes playing.
	 */
	public var endReach(default, null):FlxSignal = new FlxSignal();

	/**
	 * Triggered when the video playback gets to unloaded data, and pauses.
	 */
	public var onBufferEmpty(default, null):FlxSignal = new FlxSignal();

	/**
	 * Triggered when the video playback resumes after loading previously unloaded data.
	 */
	public var onBufferLoad(default, null):FlxSignal = new FlxSignal();

	/**
	 * Triggered when an error occurs.
	 */
	public var onError(default, null):FlxSignal = new FlxSignal();

	/**
	 * The OpenFL `Video` object attached to this video, it takes care of rendering the video.
	 */
	public var video(default, null):Video;

	/**
	 * The `NetStream` object attached to this video, it takes care of video playback.
	 */
	public var netStream(default, null):FunkinStream;

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
	public var length(default, null):Float = 0;

	/**
	 * The volume at which the video is played.
	 */
	public var volume(get, set):Float;

	/**
	 * If the video should loop indefinitely.
	 */
	public var looped(default, set):Bool = false;

	/**
	 * The rate at which the video is being played back.
	 */
	public var playbackRate(get, set):Float;

	var _mediaVolume:Float = 1;

	var _netConnection:NetConnection;

	var _finished:Bool = false;

	var _queuedEvent:Null<String> = null;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		video = new Video();
		video.x = 0;
		video.y = 0;
		video.alpha = 0;

		_netConnection = new NetConnection();
		_netConnection.connect(null);
		_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);

		netStream = new FunkinStream(_netConnection);
		netStream.client = {onMetaData: onMetaData, onPlayStatus: onPlayStatus};

		if (FlxG.autoPause)
		{
			FlxG.signals.focusGained.add(focusHandler);
			FlxG.signals.focusLost.add(unfocusHandler);
		}

		FlxG.sound.onVolumeChange.add(setFrontendVolume);

		// triggers an update
		setFrontendVolume(FlxG.sound.muted ? 0 : FlxG.sound.volume);
	}

	override function destroy()
	{
		super.destroy();

		netStream.dispose();
		video = null;

		FlxDestroyUtil.destroy(formatSetup);
		FlxDestroyUtil.destroy(startPlaying);
		FlxDestroyUtil.destroy(endReach);
		FlxDestroyUtil.destroy(onBufferEmpty);
		FlxDestroyUtil.destroy(onBufferLoad);
		FlxDestroyUtil.destroy(onError);

		if (FlxG.autoPause)
		{
			FlxG.signals.focusGained.remove(focusHandler);
			FlxG.signals.focusLost.remove(unfocusHandler);
		}

		FlxG.sound.onVolumeChange.remove(setFrontendVolume);
	}

	override function kill()
	{
		pause();
		super.kill();
	}

	override function revive()
	{
		resume();
		super.revive();
	}

	/**
	 * Loads a video file in the specified directory or URL.
	 *
	 * @param path The directory where the file is located, or the URL of the video file.
	 * @param loop Whether the video should loop.
	 * @return This `FlxVideo` instance, for chaining.
	 */
	public function loadVideo(path:String, loop:Bool = false):FlxVideo
	{
		@:privateAccess netStream.__video.src = path;
		this.looped = loop;
		return this;
	}

	/**
	 * Starts video playblack.
	 * @return Always returns `true`, for compatibility with HxVLC.
	 */
	public function play():Bool
	{
		if (!FlxG.isGameFocused)
		{
			_queuedEvent = 'play';
		}
		else
		{
			@:privateAccess netStream.__video.play();
		}

		return true;
	}

	/**
	 * Pauses video playblack, if playing.
	 */
	public function pause()
	{
		if (playing && !_finished)
		{
			if (!FlxG.isGameFocused)
			{
				_queuedEvent = 'pause';
			}
			else
			{
				_pause();
			}
		}
	}

	/**
	 * Resumes video playblack, if paused.
	 */
	public function resume()
	{
		if (!playing && !_finished)
		{
			if (!FlxG.isGameFocused)
			{
				_queuedEvent = 'resume';
			}
			else
			{
				_resume();
			}
		}
	}

	/**
	 * Toggles between pausing or resuming video playblack.
	 */
	public function togglePaused()
	{
		if (playing)
		{
			pause();
		}
		else
		{
			resume();
		}
	}

	/**
	 * Stops video playblack.
	 */
	public function stop()
	{
		finish();
	}

	override function draw()
	{
		renderVideo();
		super.draw();
	}

	function renderVideo()
	{
		final videoWidth:Int = Math.ceil(video.width);
		final videoHeight:Int = Math.ceil(video.height);

		makeGraphic(videoWidth, videoHeight, FlxColor.TRANSPARENT);

		frameWidth = video.videoWidth;
		frameHeight = video.videoHeight;

		pixels.draw(video);

		resetFrame();
	}

	function finish()
	{
		playing = false;
		_finished = true;

		endReach.dispatch();
	}

	function onMetaData(metaData:VideoMetaData)
	{
		video.attachNetStream(netStream);
		video.width = metaData.width;
		video.height = metaData.height;
		length = metaData.duration * 1000;
		videoReady();
	}

	function videoReady()
	{
		renderVideo();
		formatSetup.dispatch();
		volume = FlxG.sound.muted ? 0 : FlxG.sound.volume;
	}

	function onPlayStatus(status:VideoPlayStatus) {}

	function onNetConnectionStatus(event:NetStatusEvent)
	{
		switch (event.info.code)
		{
			case 'NetStream.Buffer.Empty':
				onBufferEmpty.dispatch();

			case 'NetStream.Buffer.Full':
				onBufferLoad.dispatch();

			case 'NetStream.Play.StreamNotFound':
				onError.dispatch();

			case 'NetStream.Play.Failed':
				onError.dispatch();

			case 'NetStream.Play.Start':
				startPlaying.dispatch();

			case 'NetStream.Play.Stop':
				finish();
		}
	}

	function focusHandler()
	{
		if (_queuedEvent != null)
		{
			switch (_queuedEvent)
			{
				case 'play':
					@:privateAccess netStream.__video.play();

				case 'pause':
					_pause();

				case 'resume':
					_resume();
			}
		}

		_queuedEvent = null;
	}

	function unfocusHandler()
	{
		if (_queuedEvent == null && playing)
		{
			_pause();
			_queuedEvent = 'play';
		}
	}

	function _pause()
	{
		netStream.pause();
		playing = false;
	}

	function _resume()
	{
		netStream.resume();
		playing = true;
	}

	override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):FlxVideo
	{
		FlxG.log.error('loadGraphic is a function not supported in FlxVideo');
		return this;
	}

	override function loadGraphicFromSprite(Sprite:FlxSprite):FlxVideo
	{
		FlxG.log.error('loadGraphicFromSprite is a function not supported in FlxVideo');
		return this;
	}

	override function loadRotatedGraphic(Graphic:FlxGraphicAsset, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false, ?Key:String):FlxVideo
	{
		FlxG.log.error('loadRotatedGraphic is a function not supported in FlxVideo');
		return this;
	}

	override function calcFrame(force:Bool = false)
	{
		renderVideo();
		super.calcFrame(force);
	}

	override function updateHitbox()
	{
		renderVideo();
		super.updateHitbox();
	}

	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera)
	{
		renderVideo();
		return super.getScreenBounds(newRect, camera);
	}

	function get_time():Float
	{
		return netStream.time * 1000;
	}

	function set_time(value:Float):Float
	{
		netStream.seek(value / 1000);
		return value;
	}

	function get_volume():Float
	{
		return netStream.soundTransform.volume;
	}

	function set_volume(value:Float):Float
	{
		if (netStream.soundTransform == null)
		{
			netStream.soundTransform = new SoundTransform();
		}

		_mediaVolume = value.clamp(0, 1);

		var sndTrans:SoundTransform = netStream.soundTransform;
		sndTrans.volume = _mediaVolume * FlxG.sound.volume;
		netStream.soundTransform = sndTrans;
		return value;
	}

	/**
	 * Functions exclusively made for flixel's `SoundFrontEnd`, so it doesn't interfere with the volume
	 * set by the user.
	 *
	 * @param volume The new front-end volume.
	 */
	function setFrontendVolume(value:Float)
	{
		if (netStream.soundTransform == null)
		{
			netStream.soundTransform = new SoundTransform();
		}

		var sndTrans:SoundTransform = netStream.soundTransform;
		sndTrans.volume = _mediaVolume * value;
		netStream.soundTransform = sndTrans;

		if (value == 0)
		{
			netStream.muted = true;
		}
		else
		{
			netStream.muted = false;
		}
	}

	function set_looped(value:Bool):Bool
	{
		return netStream.loop = value;
	}

	function get_playbackRate():Float
	{
		return netStream.speed;
	}

	function set_playbackRate(value:Float):Float
	{
		return netStream.speed = value;
	}

	override function get_width():Float
	{
		renderVideo();
		return super.get_width();
	}

	override function get_height():Float
	{
		renderVideo();
		return super.get_height();
	}

	override function set_antialiasing(value:Bool):Bool
	{
		return video.smoothing = super.set_antialiasing(value);
	}
}

typedef VideoMetaData =
{
	var width:Int;
	var height:Int;
	var duration:Float;
}

typedef VideoPlayStatus =
{
	var code:String;
	var duration:Float;
	var position:Float;
	var speed:Float;
	var start:Float;
}
#end
