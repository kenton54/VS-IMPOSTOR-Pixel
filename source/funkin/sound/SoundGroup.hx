package funkin.sound;

class SoundGroup extends FlxTypedGroup<FunkinSound>
{
	/**
	 * Whether or not the group is playing.
	 */
	public var playing(get, never):Bool;

	/**
	 * The volume of the group.
	 */
	public var volume(get, set):Float;

	/**
	 * The position of the group, in milliseconds.
	 */
	public var time(get, set):Float;

	/**
	 * The pitch of the group.
	 *
	 * Which is essentially the playback speed.
	 */
	public var pitch(get, set):Float;

	override function add(basic:FunkinSound):FunkinSound
	{
		var result:FunkinSound = super.add(basic);

		if (result == null)
		{
			return null;
		}

		result.time = this.time;
		result.pitch = this.pitch;
		result.volume = this.volume;

		return result;
	}

	/**
	 * Plays all the sounds inside the group.
	 *
	 * @param forceRestart  Whether to play the sounds at the beggining or not.
	 * @param startTime     At which point to start playing the sounds, in milliseconds.
	 * @param endTime       At which point to stop playing the sounds, in milliseconds. If not set, the sounds will finish normally.
	 */
	public function play(forceRestart:Bool = false, startTime:Float = 0, ?endTime:Float)
	{
		forEachAlive(function(snd:FunkinSound)
		{
			snd.play(forceRestart, startTime, endTime);
		});
	}

	/**
	 * Pauses all playing sounds inside the group.
	 */
	public function pause()
	{
		forEachAlive(function(snd:FunkinSound)
		{
			snd.pause();
		});
	}

	/**
	 * Resumes all paused sounds inside the group.
	 */
	public function resume()
	{
		forEachAlive(function(snd:FunkinSound)
		{
			snd.resume();
		});
	}

	/**
	 * Stops all the sounds inside the group.
	 */
	public function stop()
	{
		forEachAlive(function(snd:FunkinSound)
		{
			snd.stop();
		});
	}

	override function destroy()
	{
		stop();
		super.destroy();
	}

	override function clear()
	{
		stop();
		super.clear();
	}

	function get_playing():Bool
	{
		var snd:Null<FunkinSound> = getFirstAlive();

		if (snd != null)
		{
			return snd.playing;
		}

		return false;
	}

	function get_volume():Float
	{
		var snd:Null<FunkinSound> = getFirstAlive();

		if (snd != null)
		{
			return snd.volume;
		}

		return 1;
	}

	function set_volume(value:Float):Float
	{
		forEachAlive(function(snd:FunkinSound)
		{
			snd.volume = value;
		});

		return value;
	}

	function get_time():Float
	{
		var snd:Null<FunkinSound> = getFirstAlive();

		if (snd != null)
		{
			return snd.time;
		}

		return 0;
	}

	function set_time(value:Float):Float
	{
		forEachAlive(function(snd:FunkinSound)
		{
			snd.time = value;
		});

		return value;
	}

	function get_pitch():Float
	{
		var snd:Null<FunkinSound> = getFirstAlive();

		if (snd != null)
		{
			return snd.pitch;
		}

		return 1;
	}

	function set_pitch(value:Float):Float
	{
		forEachAlive(function(snd:FunkinSound)
		{
			snd.pitch = value;
		});

		return value;
	}
}
