package funkin.system;

import funkin.data.ClientPreferences;
import funkin.input.Controls.InputDevice;

class FunkinSave
{
	static final SAVE_ERROR_WINDOW_TITLE:String = '${Constants.TITLE} - Save Data Error';

	/**
	 * The user's loaded save data.
	 */
	public static var data(get, never):BaseSaveData;

	/**
	 * The user's loaded preferences.
	 */
	public static var clientPreferences(get, never):ClientPreferencesSaveData;

	/**
	 * The user's loaded hosting preferences.
	 */
	public static var serverPreferences(get, never):ServerPreferencesSaveData;

	/**
	 * The user's statistics.
	 */
	public static var stats(get, never):StatisticsSaveData;

	/**
	 * The user's unlocked unlockables.
	 */
	public static var unlockables(get, never):UnlockablesSaveData;

	/**
	 * Loads the user's saved data.
	 */
	public static function load()
	{
		FlxG.save.bind(Constants.SAVE_PATH, 'ImpostorPixel');

		switch (FlxG.save.status)
		{
			case EMPTY:
				FlxG.log.notice('Save data is empty, using a new save data!');
				FlxG.save.mergeData(getDefaultSaveData(), true);

			case LOAD_ERROR(type):
				switch (type)
				{
					case IO(exception):
						handleSaveDataError('An error ocurred while trying to read your saved data!', exception.message);

					default:
						handleSaveDataError('An unexpected error ocurred while trying to load the save data.');
				}

			case BOUND(_, _):
				FlxG.save.mergeData(resolveSaveData(FlxG.save.data), true);

			default:
				handleSaveDataError('An unexpected error ocurred while trying to load the save data.');
		}
	}

	static var retryAttempts:Int = 0;
	static final maxRetries:Int = 10;

	static function handleSaveDataError(message:String, ?log:String)
	{
		if (retryAttempts >= maxRetries)
		{
			var fullMessage:String = message;

			if (log != null)
			{
				fullMessage += '\n\nError log: $log';
			}

			lime.app.Application.current.window.alert(fullMessage, SAVE_ERROR_WINDOW_TITLE);
			FlxG.save.mergeData(getDefaultSaveData(), true);
		}
		else
		{
			retryAttempts++;
			load();
		}
	}

	/**
	 * Checks whether the user has played the song in any of the given difficulties.
	 *
	 * @param song 						The song ID.
	 * @param difficultyList 	An array holding difficulty IDs. If none is set, it'll default to `easy`, `normal` and `hard`.
	 * @return Whether the user has played the song or not.
	 */
	public static function hasBeatenSong(song:String, ?difficultyList:Array<String>):Bool
	{
		if (difficultyList == null)
		{
			difficultyList = ['easy', 'normal', 'hard'];
		}

		for (difficulty in difficultyList)
		{
			var songScore:Null<SongScoreSaveData> = getSongScore(song, difficulty);

			if (songScore != null)
			{
				if (songScore.score > 0)
				{
					return true;
				}
				else
				{
					// we dont return false right away, so it can check for the other difficulties as well
					continue;
				}
			}
		}

		return false;
	}

	/**
	 * @param song 				The song ID.
	 * @param difficulty 	The difficulty ID.
	 * @return Data containing the score, judgements counts and accuracy achieved by the user, or `null` if there's no score.
	 */
	public static function getSongScore(song:String, difficulty:String = 'normal'):Null<SongScoreSaveData>
	{
		var songDiffData:Null<SongDifficultySaveData> = data.highscores.songs.get(song);

		if (songDiffData == null)
		{
			songDiffData = [];
			data.highscores.songs.set(song, songDiffData);

			return null;
		}

		return songDiffData.get(difficulty);
	}

	/**
	 * Sets the user's saved score from the specified song and difficulty.
	 *
	 * @param song 				The song ID.
	 * @param difficulty 	The difficulty ID.
	 * @param score 			The new score data.
	 */
	public static function setSongScore(song:String, difficulty:String, score:SongScoreSaveData)
	{
		var songDiffData:Null<SongDifficultySaveData> = data.highscores.songs.get(song);

		if (songDiffData == null)
		{
			songDiffData = [];
			data.highscores.songs.set(song, songDiffData);
		}

		songDiffData.set(difficulty, score);
		flush();
	}

	/**
	 * @param song 				The song ID.
	 * @param difficulty 	The difficulty ID.
	 * @param score 			The score data to compared with the saved one.
	 * @return Whether the specified score surpasses the saved one.
	 */
	public static function isSongHighScore(song:String, difficulty:String = 'normal', score:SongScoreSaveData):Bool
	{
		var songDiffData:Null<SongDifficultySaveData> = data.highscores.songs.get(song);

		if (songDiffData == null)
		{
			songDiffData = [];
			data.highscores.songs.set(song, songDiffData);

			return true;
		}

		var curSongScore:Null<SongScoreSaveData> = songDiffData.get(difficulty);

		if (curSongScore == null)
		{
			return true;
		}

		return score.score > curSongScore.score;
	}

	/**
	 * @param playerID 		The player ID.
	 * @param inputDevice The type of device.
	 * @return The control's bindings from the specified player and input device. Or `null` if there're no bindings saved.
	 */
	public static function getControls(playerID:Int, inputDevice:InputDevice):Null<ControlBindsSaveData>
	{
		return switch (inputDevice)
		{
			case Keyboard: playerID == 0 ? clientPreferences?.controls?.player1.keyboard : clientPreferences?.controls?.player2.keyboard;
			case Gamepad(_): playerID == 0 ? clientPreferences?.controls?.player1.gamepad : clientPreferences?.controls?.player2.gamepad;
		};
	}

	/**
	 * @param playerID 		The player ID.
	 * @param inputDevice The type of device.
	 * @return Whether saved controls exist from the specified player and input device.
	 */
	public static function hasControls(playerID:Int, inputDevice:InputDevice):Bool
	{
		var controls:Null<ControlBindsSaveData> = getControls(playerID, inputDevice);

		if (controls == null)
		{
			return false;
		}

		var controlFields:Array<String> = Reflect.fields(controls);
		return controlFields.length > 0;
	}

	/**
	 * Sets the specified player and input device's control bindings.
	 *
	 * @param playerID 		The player ID.
	 * @param inputDevice The type of device.
	 * @param controls 		The new control bindins's data.
	 */
	public static function setControls(playerID:Int, inputDevice:InputDevice, controls:ControlBindsSaveData)
	{
		switch (inputDevice)
		{
			case Keyboard:
				getPlayerControls(playerID).keyboard = controls;

			case Gamepad(_):
				getPlayerControls(playerID).gamepad = controls;
		}

		flush();
	}

	static function getPlayerControls(playerID:Int):PlayerControlsSaveData
	{
		return playerID == 0 ? clientPreferences?.controls?.player1 : clientPreferences?.controls?.player2;
	}

	/**
	 * Applies various settings manually.
	 */
	@:allow(funkin.InitState)
	static function applyLoadedData()
	{
		ClientPreferences.colorBlindMode = clientPreferences.colorBlindMode;
		ClientPreferences.screenTimeout = clientPreferences.screenTimeout;
		ClientPreferences.songOffset = clientPreferences.songOffset;
		ClientPreferences.autoPause = clientPreferences.autoPause;
		ClientPreferences.showFPSCounter = clientPreferences.showFPSCounter;

		if (clientPreferences.syncSystemLanguage)
		{
			ClientPreferences.syncSystemLanguage = clientPreferences.syncSystemLanguage;
		}
		else
		{
			ClientPreferences.language = clientPreferences.language;
		}
	}

	/**
	 * Saves the user's save data.
	 */
	public static function flush()
	{
		if (!FlxG.save.flush())
		{
			switch (FlxG.save.status)
			{
				case SAVE_ERROR(type):
					switch (type)
					{
						case STORAGE:
							lime.app.Application.current.window.alert('Couldn\'t save game data!\nNot enough storage space!', SAVE_ERROR_WINDOW_TITLE);

						case ENCODING(exception):
							lime.app.Application.current.window.alert('Couldn\'t save game data!\n\nError log: ${exception.message}', SAVE_ERROR_WINDOW_TITLE);
					}

				default:
					// we dont care about the other ones
			}
		}
	}

	/**
	 * Clears the user's save data, changing everything to its default state.
	 */
	public static function erase()
	{
		FlxG.save.erase();
		FlxG.save.mergeData(getDefaultSaveData());
	}

	static function resolveSaveData(input:Dynamic):BaseSaveData
	{
		if (input == null)
		{
			return getDefaultSaveData();
		}
		else
		{
			var saveData:BaseSaveData = cast thx.Objects.deepCombine(getDefaultSaveData(), input);
			return saveData;
		}
	}

	static function getDefaultSaveData():BaseSaveData
	{
		var refreshRate:Int = 60;

		#if mobile
		refreshRate = FlxG.stage.window.displayMode.refreshRate;

		if (refreshRate < 60)
		{
			refreshRate = 60;
		}
		#end

		return {
			volume: 1,
			mute: false,
			fullscreen: false,
			seenWarningScreen: false,
			highscores: {
				songs: [],
				lobbies: [],
				speedruns: []
			},
			inventory: {
				playableCharacter: 'bf',
				companionCharacter: 'gf',
				playableCharacterSkin: '',
				companionCharacterSkin: '',
				pet: ''
			},
			unlockables: {
				maps: [],
				playableCharacters: [
					{
						id: 'bf',
						bought: true
					}
				],
				companionCharacters: [
					{
						id: 'gf',
						bought: true
					}
				],
				characterSkins: [],
				pets: [],
				achievements: []
			},
			story: {
				storySequence: 0
			},
			stats: {
				playtime: 0,
				totalNoteHits: 0,
				perfectNoteHits: 0,
				greatNoteHits: 0,
				goodNoteHits: 0,
				badNoteHits: 0,
				awfulNoteHits: 0,
				missedNotes: 0,
				combosBroken: 0
			},
			clientPreferences: {
				frameRate: refreshRate,
				unlockedFrameRate: false,
				sentitiveContent: true,
				photosentivity: false,
				intensiveShaders: true,
				lowDetail: false,
				colorBlindMode: 'none',
				downScroll: false,
				middleScroll: false,
				timeBar: true,
				hapticsIntensity: 1,
				strumlinesBackground: 0,
				songOffset: 0,
				vsync: false,
				zoomCameraOnBeat: true,
				autoPause: true,
				screenTimeout: false,
				showFPSCounter: false,
				language: 'en',
				syncSystemLanguage: true,
				controls: {
					player1: {
						keyboard: {},
						gamepad: {}
					},
					player2: {
						keyboard: {},
						gamepad: {}
					}
				}
			},
			serverPreferences: {
				ipAdress: '127.0.0.1',
				port: 3000,
				nickname: 'player'
			}
		};
	}

	inline static function get_clientPreferences():ClientPreferencesSaveData
	{
		return data.clientPreferences;
	}

	inline static function get_serverPreferences():ServerPreferencesSaveData
	{
		return data.serverPreferences;
	}

	inline static function get_unlockables():UnlockablesSaveData
	{
		return data.unlockables;
	}

	inline static function get_stats():StatisticsSaveData
	{
		return data.stats;
	}

	static function get_data():BaseSaveData
	{
		return FlxG.save.data;
	}
}

/**
 * The root of the save data.
 */
typedef BaseSaveData =
{
	/**
	 * The user's saved volume from last session.
	 *
	 * Variable from HaxeFlixel.
	 */
	var volume:Float;

	/**
	 * Whether the game was muted in the last session.
	 *
	 * Variable from HaxeFlixel.
	 */
	var mute:Bool;

	/**
	 * Whether the game was in fullscreen last session.
	 */
	var fullscreen:Bool;

	/**
	 * Whether the user has seen the startup warning screen when opening the mod for the first time.
	 */
	var seenWarningScreen:Bool;

	/**
	 * The user's saved highscores for each song and lobby.
	 */
	var highscores:HighscoresSaveData;

	/**
	 * The user's selected bought items.
	 */
	var inventory:InventorySaveData;

	/**
	 * The user's unlocked content.
	 */
	var unlockables:UnlockablesSaveData;

	/**
	 * The user's saved story progression.
	 */
	var story:StorySaveData;

	/**
	 * The user's statistics.
	 */
	var stats:StatisticsSaveData;

	/**
	 * The user's saved client preferences.
	 *
	 * These are settings that only the user can see
	 * and won't affect online play.
	 */
	var clientPreferences:ClientPreferencesSaveData;

	/**
	 * The user's saved server preferences.
	 *
	 * These are settings that will affect online play,
	 * but only when the user is hosting an online session.
	 */
	var serverPreferences:ServerPreferencesSaveData;
}

/**
 * Holds scores for songs, lobbies and task speedruns.
 */
typedef HighscoresSaveData =
{
	/**
	 * All songs's scores.
	 */
	var songs:SongSaveData;

	/**
	 * All lobbies's scores.
	 */
	var lobbies:SongSaveData;

	/**
	 * All speedruns's personal best for each map.
	 */
	var speedruns:Map<MapSaveVar, Float>;
}

/**
 * Key is the song ID, Value is the song's difficulties, which holds the actual scores.
 */
typedef SongSaveData = Map<String, SongDifficultySaveData>;

/**
 * Key is the difficulty ID, Value is the song's score data.
 */
typedef SongDifficultySaveData = Map<String, SongScoreSaveData>;

/**
 * Holds song data, like score, accuracy and tallies.
 */
typedef SongScoreSaveData =
{
	/**
	 * The song's saved score.
	 */
	var score:Int;

	/**
	 * The song's saved tallies.
	 */
	var tallies:SongTalliesData;
}

/**
 * Holds a song score's tallies.
 */
typedef SongTalliesData =
{
	var perfects:Int;
	var greats:Int;
	var goods:Int;
	var bads:Int;
	var awfuls:Int;
	var misses:Int;
	var comboBreaks:Int;

	var maxCombo:Int;
	var totalNotesHit:Int;
	var totalNotes:Int;
}

/**
 * Holds the user's selected playable character, skin and pet.
 */
typedef InventorySaveData =
{
	/**
	 * The user's current selected playable character.
	 */
	var playableCharacter:String;

	/**
	 * The user's current selected companion character.
	 */
	var companionCharacter:String;

	/**
	 * The user's current selected skin for the selected playable character.
	 */
	var playableCharacterSkin:String;

	/**
	 * The user's current selected skin for the selected playable character.
	 */
	var companionCharacterSkin:String;

	/**
	 * The user's current pet.
	 */
	var pet:PetSaveVar;
}

/**
 * The mod's unlockables.
 */
typedef UnlockablesSaveData =
{
	/**
	 * The user's unlocked overworld maps.
	 */
	var maps:MapsSaveData;

	/**
	 * The user's unlocked and bought playable characters.
	 */
	var playableCharacters:CharactersSaveData;

	/**
	 * The user's unlocked and bought companion characters.
	 */
	var companionCharacters:CharactersSaveData;

	/**
	 * The user's bought character skins for each playable and companion character.
	 */
	var characterSkins:CharacterSkinsSaveData;

	/**
	 * The user's bought pet.
	 */
	var pets:PetsSaveData;

	/**
	 * The user's earned achievements.
	 */
	var achievements:AchievementsSaveData;
}

/**
 * An array holding the user's unlocked overworld maps.
 */
typedef MapsSaveData = Array<MapSaveVar>;

/**
 * Map ID.
 */
typedef MapSaveVar = String;

/**
 * An array holding the user's unlocked and bought characters.
 */
typedef CharactersSaveData = Array<CharacterSaveVar>;

/**
 * Character Data.
 */
typedef CharacterSaveVar =
{
	/**
	 * The ID of the character.
	 */
	var id:String;

	/**
	 * Whether the character was bought or not.
	 */
	var bought:Bool;
}

/**
 * Key is the playable character ID, Value is the bought skin.
 */
typedef CharacterSkinsSaveData = Map<String, CharacterSkinSaveVar>;

/**
 * Character Skin ID.
 */
typedef CharacterSkinSaveVar = String;

/**
 * An array holding the user's bought pets.
 */
typedef PetsSaveData = Array<PetSaveVar>;

/**
 * Pet ID.
 */
typedef PetSaveVar = String;

/**
 * An array holding the user's earned achievements's ID.
 */
typedef AchievementsSaveData = Array<String>;

/**
 * The mod's story sequence and flags.
 */
typedef StorySaveData =
{
	/**
	 * Where the story is positioned at.
	 */
	var storySequence:Int;
}

typedef StatisticsSaveData =
{
	/**
	 * The user's total passed time playing the game.
	 */
	var playtime:Float;

	/**
	 * The total amount of notes the user has hit.
	 */
	var totalNoteHits:Int;

	/**
	 * The total amount of notes the user has hit with a Perfect rating.
	 */
	var perfectNoteHits:Int;

	/**
	 * The total amount of notes the user has hit with a Great rating.
	 */
	var greatNoteHits:Int;

	/**
	 * The total amount of notes the user has hit with a Good rating.
	 */
	var goodNoteHits:Int;

	/**
	 * The total amount of notes the user has hit with a Bad rating.
	 */
	var badNoteHits:Int;

	/**
	 * The total amount of notes the user has hit with an Awful rating.
	 */
	var awfulNoteHits:Int;

	/**
	 * The total amount of notes the user has missed.
	 */
	var missedNotes:Int;

	/**
	 * The total amount of combos the user broke.
	 */
	var combosBroken:Int;
}

/**
 * The user's preferences.
 */
typedef ClientPreferencesSaveData =
{
	/**
	 * How often the game gets updated and drawn, in hertz.
	 */
	var frameRate:Int;

	/**
	 * Whether the game should update every CPU cycle or by a fixed amount of frames.
	 */
	var unlockedFrameRate:Bool;

	/**
	 * Whether content that may disturb or make people uncomfortable should be shown.
	 */
	var sentitiveContent:Bool;

	/**
	 * If enabled, reduces the use/strength of flashing lights.
	 */
	var photosentivity:Bool;

	/**
	 * If enabled, uses shaders that may be too resource-intensive.
	 */
	var intensiveShaders:Bool;

	/**
	 * If enabled, disables some background elements everywhere in the mod, making menus load faster and gameplay be less laggy.
	 *
	 * For non-pixelated sprites, disables anti-aliasing.
	 */
	var lowDetail:Bool;

	/**
	 * The active colorblind shader.
	 */
	var colorBlindMode:ColorBlindMode;

	/**
	 * Whether notes go down instead of up.
	 */
	var downScroll:Bool;

	/**
	 * Whether the notes get centered on the screen.
	 */
	var middleScroll:Bool;

	/**
	 * Whether the time bar is shown when playing a song, showing its progress.
	 */
	var timeBar:Bool;

	/**
	 * How intense the vibration is.
	 */
	var hapticsIntensity:Float;

	/**
	 * The opacity of the strumlines's background.
	 */
	var strumlinesBackground:Float;

	/**
	 * Offsets the song in the specified amount of milliseconds.
	 */
	var songOffset:Int;

	/**
	 * Whether vertical-sync is enabled.
	 *
	 * If enabled, frame rate will be locked to the monitor's refresh rate.
	 */
	var vsync:Bool;

	/**
	 * Whether to allow the device to shut itself down when idling for too long.
	 */
	var screenTimeout:Bool;

	/**
	 * Whether the camera zooms in on every song's beat.
	 */
	var zoomCameraOnBeat:Bool;

	/**
	 * Whether to freeze the game when the its window gets unfocused.
	 */
	var autoPause:Bool;

	/**
	 * Whether to show the FPS Counter.
	 */
	var showFPSCounter:Bool;

	/**
	 * The saved game's language.
	 */
	var language:String;

	/**
	 * If enabled, synchronizes the game's language with the system's language.
	 */
	var syncSystemLanguage:Bool;

	/**
	 * The user's saved controls for both players.
	 */
	var controls:
		{
			var player1:PlayerControlsSaveData;
			var player2:PlayerControlsSaveData;
		};
}

/**
 * Online hosting preferences.
 */
typedef ServerPreferencesSaveData =
{
	/**
	 * The last IP Adress the user used.
	 *
	 * For quick connectivity.
	 */
	var ipAdress:String;

	/**
	 * The last port the user used.
	 *
	 * For quick connectivity.
	 */
	var port:Int;

	/**
	 * The user's nickname.
	 */
	var nickname:String;
}

/**
 * The player's control data.
 */
typedef PlayerControlsSaveData =
{
	/**
	 * Holds the keyboard's saved controls.
	 */
	var keyboard:ControlBindsSaveData;

	/**
	 * Holds the gamepad's saved controls.
	 */
	var gamepad:ControlBindsSaveData;
}

/**
 * Holds a device's saved controls.
 */
typedef ControlBindsSaveData =
{
	var ?NOTE_LEFT:Array<Int>;
	var ?NOTE_DOWN:Array<Int>;
	var ?NOTE_UP:Array<Int>;
	var ?NOTE_RIGHT:Array<Int>;
	var ?DODGE:Array<Int>;
	var ?RESET:Array<Int>;

	var ?UI_LEFT:Array<Int>;
	var ?UI_DOWN:Array<Int>;
	var ?UI_UP:Array<Int>;
	var ?UI_RIGHT:Array<Int>;
	var ?ACCEPT:Array<Int>;
	var ?BACK:Array<Int>;
	var ?PAUSE:Array<Int>;
	var ?FULLSCREEN:Array<Int>;
	var ?INTERACT:Array<Int>;
	var ?MAP:Array<Int>;
	var ?CHAT:Array<Int>;

	var ?VOLUME_UP:Array<Int>;
	var ?VOLUME_DOWN:Array<Int>;
	var ?VOLUME_MUTE:Array<Int>;
}
