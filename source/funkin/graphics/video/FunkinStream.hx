package funkin.graphics.video;

#if web
import openfl.media.SoundTransform;
import openfl.net.NetConnection;
import openfl.net.NetStream;

@:inheritDoc(openfl.net.NetStream)
class FunkinStream extends NetStream
{
	/**
	 * Whether the video can loop indefinitely.
	 */
	public var loop(default, set):Bool = false;

	/**
	 * Whether the video is muted.
	 */
	public var muted(default, set):Bool = false;

	@:noCompletion var __isBufferEmpty:Bool = false;

	@:inheritDoc(openfl.net.NetStream.new)
	public function new(connection:NetConnection, ?peerID:String)
	{
		super(connection, peerID);

		__video.addEventListener('abort', video_onAbort);
		__video.addEventListener('suspend', video_onSuspend);
	}

	function set_loop(value:Bool):Bool
	{
		return __video.loop = loop = value;
	}

	function set_muted(value:Bool):Bool
	{
		return __video.muted = muted = value;
	}

	@:noCompletion override function video_onPlaying(event:Dynamic)
	{
		if (__isBufferEmpty)
		{
			__dispatchStatus('NetStream.Buffer.Full');
		}
		else
		{
			super.video_onPlaying(event);
		}

		__isBufferEmpty = false;
	}

	@:noCompletion override function video_onWaiting(event:Dynamic)
	{
		__dispatchStatus('NetStream.Buffer.Empty');

		__isBufferEmpty = true;
	}

	@:noCompletion override function video_onEnd(event:Dynamic)
	{
		__dispatchStatus('NetStream.Play.Stop');
		__playStatus('NetStream.Play.Complete');
	}

	@:noCompletion override function video_onSeeking(event:Dynamic)
	{
		__dispatchStatus('NetStream.Seek.Notify');
		__playStatus('NetStream.Play.seeking');
	}

	@:noCompletion override function video_onError(event:Dynamic)
	{
		__dispatchStatus('NetStream.Play.Failed');
		__playStatus('NetStream.Play.error');
	}

	@:noCompletion function video_onAbort(event:Dynamic)
	{
		__dispatchStatus('NetStream.Play.StreamNotFound');
		__playStatus('NetStream.Play.abort');
	}

	@:noCompletion function video_onSuspend(event:Dynamic)
	{
		__playStatus('NetStream.Play.suspend');
	}

	@:noCompletion override function set_soundTransform(value:SoundTransform):SoundTransform
	{
		if (value != null)
		{
			__soundTransform.pan = value.pan;
			__soundTransform.volume = value.volume;

			__video.volume = __soundTransform.volume;
		}

		return value;
	}
}
#end
