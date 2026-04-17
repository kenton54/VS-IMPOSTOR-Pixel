package funkin.sound;

import flixel.system.FlxAssets.FlxSoundAsset;

import funkin.system.FunkinMemory;

import openfl.media.Sound;

class FunkinSound extends flixel.sound.FlxSound
{
	static var pool:FlxTypedGroup<FunkinSound> = new FlxTypedGroup<FunkinSound>();

	/**
	 *
	 * Creates a `FunkinSound` object.
	 *
	 * @param key 				Where the sound file is located inside the assets folder.
	 * @param volume 			The volume to start playing the sound with.
	 * @param looped 			Whether the sound loops indefinitely.
	 * @param autoDestroy Whether the sound gets automatically disposed when it finishes playing.
	 * @param autoPlay 		Whether the sound should automatically start playblack when it finished loading.
	 * @param persist			Whether the sound should persist through menu transitions, Otherwise it gets disposed.
	 * @param onComplete	A function to call when the sound finishes playing.
	 * @param onLoad			A function to call when the sound finishes loading.
	 * @return The `FunkinSound` object, or `null` if the sound asset wasn't found.
	 */
	public static function load(key:String, volume:Float = 1, looped:Bool = false, autoDestroy:Bool = false, autoPlay:Bool = false, persist:Bool = false, ?onComplete:Void -> Void, ?onLoad:Void -> Void):FunkinSound
	{
		var sound:FunkinSound = pool.recycle(soundConstruct);
		sound.loadEmbedded(FunkinMemory.getSound(key), looped, autoDestroy, onComplete);

		sound.volume = volume;
		sound.persist = persist;

		FlxG.sound.defaultSoundGroup.add(sound);
		FlxG.sound.list.add(sound);

		if (autoPlay)
		{
			sound.play();
		}

		if (onLoad != null && sound._sound != null)
		{
			onLoad();
		}

		return sound;
	}

	/**
	 * Loads and plays a sound automatically.
	 *
	 * @param key 		Where the sound file is located inside the assets folder.
	 * @param volume 	The volume to start playing the sound with.
	 * @return The loaded sound.
	 */
	public static function playSound(key:String, volume:Float = 1):FunkinSound
	{
		return load(key, volume, false, true, true, true);
	}

	/**
	 * Plays a menu sound.
	 *
	 * @param sound 	The menu sound to play.
	 * @param volume 	The volume it should be played at.
	 * @return The loaded menu sound.
	 */
	public static function playMenuSound(sound:MenuSound = SCROLL, volume:Float = 1):FunkinSound
	{
		return playSound(Paths.sound('menu/$sound'), volume);
	}

	/**
	 * Creates a `FunkinSound` an loads it into the global music track.
	 *
	 * @param key 								Where the sound file is located inside the assets folder.
	 * @param volume 							The volume it should be played at.
	 * @param conductorParams 		Extra optional parameters to set to the music.
	 * @return The `FunkinSound` object, or `null` if the music asset wasn't found.
	 */
	public static function playMusic(key:String, volume:Float = 1, ?conductorParams:ConductorParams):FunkinSound
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeTween?.cancel();
			FlxG.sound.music.stop();
			FlxG.sound.music.kill();
		}

		var music:FunkinSound = pool.recycle(soundConstruct);
		music.loadStreamed(FunkinMemory.getSound(key), true, false);

		music.volume = volume;
		music.persist = true;

		FlxG.sound.defaultSoundGroup.add(music);

		music.play();

		if (music != null)
		{
			setMusic(music);
		}

		if (conductorParams != null)
		{
			var beatsPerMeasure:Int = conductorParams.beatsPerMeasure ?? 4;
			var stepsPerBeat:Int = conductorParams.stepsPerBeat ?? 4;
			Conductor.start(conductorParams.bpm, false, beatsPerMeasure, stepsPerBeat);
		}

		return music;
	}

	static var lastMenuMusic:Null<MenuMusic> = null;

	/**
	 * Plays a menu music.
	 *
	 * @param menuMusic 	The menu music to play.
	 * @param bpm					The BPM the conductor should play with.
	 * @param volume 			The volume it should be played at.
	 * @param fade 				Whether the music should fade in when it starts playing.
	 * @return The loaded menu music.
	 */
	public static function playMenuMusic(menuMusic:MenuMusic = MAIN_MENU, bpm:Float = 102, volume:Float = 1, fade:Bool = true):FunkinSound
	{
		if (menuMusic == lastMenuMusic && FlxG.sound.music.playing)
		{
			return cast FlxG.sound.music;
		}

		var music:FunkinSound = playMusic(Paths.music(menuMusic), 0, {bpm: bpm});

		if (music != null && fade)
		{
			music.fadeIn(4, 0, volume);
		}
		else if (music != null)
		{
			music.volume = volume;
		}

		lastMenuMusic = menuMusic;

		return music;
	}

	/**
	 * Pauses the global music track and the conductor.
	 */
	public static function pauseMusic()
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
		}

		Conductor.pause();
	}

	/**
	 * Resumes the paused global music track and the conductor.
	 */
	public static function resumeMusic()
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.resume();
		}

		Conductor.resume();
	}

	/**
	 * Stops the global music track and the conductor.
	 *
	 * This doesn't destroy it.
	 */
	public static function stopMusic()
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		Conductor.pause();
	}

	/**
	 * Stops the global music track and destroys it.
	 *
	 * This also resets the conductor.
	 */
	public static function destroyMusic()
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.destroy();
			FlxG.sound.music = null;
		}

		lastMenuMusic = null;
		Conductor.reset();
	}

	static function soundConstruct():FunkinSound
	{
		var sound:FunkinSound = new FunkinSound();

		pool.add(sound);
		FlxG.sound.list.add(sound);

		return sound;
	}

	static function setMusic(newMusic:FunkinSound)
	{
		FlxG.sound.music = newMusic;
		FlxG.sound.list.remove(FlxG.sound.music);
	}

	public function new()
	{
		super();
	}

	override function destroy()
	{
		super.destroy();

		if (fadeTween != null)
		{
			fadeTween.cancel();
			fadeTween = null;
		}

		FlxTween.cancelTweensOf(this);
	}

	/**
	 * Loads a sound from an embedded sound asset.
	 *
	 * Works better for big sound files, like music.
	 *
	 * @param embeddedSound 	A class with the loaded sound, or the directory where the file is located inside the assets folder.
	 * @param looped 					Whether the sound loops indefinitely.
	 * @param autoDestroy 		Whether the sound gets automatically disposed when it finishes playing.
	 * @param onComplete 			A function to call when the sound finishes playing.
	 * @return This `FunkinSound` instance.
	 */
	public function loadStreamed(embeddedSound:FlxSoundAsset, looped:Bool = false, autoDestroy:Bool = false, ?onComplete:Void -> Void):FunkinSound
	{
		if (embeddedSound == null)
		{
			return this;
		}

		cleanup(true);

		if ((embeddedSound is Sound))
		{
			_sound = embeddedSound;
		}
		else if ((embeddedSound is Class))
		{
			_sound = Type.createInstance(embeddedSound, []);
		}
		else if ((embeddedSound is String))
		{
			if (Assets.exists(embeddedSound, SOUND) || Assets.exists(embeddedSound, MUSIC))
			{
				_sound = Assets.getMusic(embeddedSound);
			}
			else
			{
				FlxG.log.error('Couldn\'t find a sound asset with the ID "$embeddedSound".');
			}
		}

		return cast init(looped, autoDestroy, onComplete);
	}

	override function update(elapsed:Float)
	{
		if (!playing)
		{
			return;
		}

		if (_time < 0)
		{
			_time += elapsed * 1000;
			if (_time >= 0)
			{
				play();
			}
		}
		else
		{
			super.update(elapsed);
		}
	}

	override function play(forceRestart:Bool = false, startTime:Float = 0.0, ?endTime:Float):FunkinSound
	{
		if (!exists)
		{
			return this;
		}

		if (forceRestart)
		{
			cleanup(false, true);
		}
		else if (playing)
		{
			return this;
		}

		if (startTime < 0)
		{
			this.active = true;
			this._time = startTime;
		}
		else
		{
			if (_paused)
			{
				resume();
			}
			else
			{
				startSound(startTime);
			}
		}

		this.endTime = endTime;
		return this;
	}

	override function pause():FunkinSound
	{
		if (!playing)
		{
			return this;
		}

		if (_time < 0)
		{
			_paused = true;
			active = false;
		}
		else
		{
			super.pause();
		}

		return this;
	}

	override function resume():FunkinSound
	{
		if (!_paused)
		{
			return this;
		}

		if (_time < 0)
		{
			_paused = true;
			active = false;
		}
		else
		{
			super.resume();
		}

		return this;
	}
}

enum abstract MenuSound(String) from String to String
{
	var SCROLL:String = 'scroll';

	var CONFIRM:String = 'confirm';

	var CANCEL:String = 'cancel';

	var SELECT:String = 'select';

	var OK:String = 'ok';

	var LOCK:String = 'lock';

	var HARD_CONFIRM:String = 'hardConfirm';
}

enum abstract MenuMusic(String) from String to String
{
	var MAIN_MENU:String = "mainMenu";

	var OMINOUS:String = "ominousMenu";
}

typedef ConductorParams =
{
	var bpm:Float;
	var ?stepsPerBeat:Int;
	var ?beatsPerMeasure:Int;
}
