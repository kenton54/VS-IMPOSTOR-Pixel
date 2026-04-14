package funkin.system;

import funkin.data.ClientPreferences;

class FunkinSave
{
	static final SAVE_ERROR_WINDOW_TITLE:String = '${Defaults.TITLE} - Save Data Error';

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
	 * Loads the user's saved data.
	 */
	public static function load()
	{
		FlxG.save.bind(Defaults.SAVE_PATH, 'ImpostorPixel');

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
		var saveData:BaseSaveData = getDefaultSaveData();

		for (saveField in Reflect.fields(saveData))
		{
			Reflect.setField(saveData, saveField, Reflect.field(input, saveField));
		}

		return saveData;
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
			clientPreferences: {
				frameRate: refreshRate,
				sentitiveContent: true,
				flashingLights: true,
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

	static function get_clientPreferences():ClientPreferencesSaveData
	{
		return data.clientPreferences;
	}

	static function get_serverPreferences():ServerPreferencesSaveData
	{
		return data.serverPreferences;
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
	var songs:Map<String, SongSaveData>;

	/**
	 * All lobbies's scores.
	 */
	var lobbies:Map<String, SongSaveData>;

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
	 * Whether content that may disturb or make people uncomfortable should be shown.
	 */
	var sentitiveContent:Bool;

	/**
	 * If enabled, makes light more "flashy", if that makes any sense lol.
	 */
	var flashingLights:Bool;

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
			var player1:PlayerControlData;
			var player2:PlayerControlData;
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
typedef PlayerControlData =
{
	/**
	 * Holds the keyboard's saved controls.
	 */
	var keyboard:BindsData;

	/**
	 * Holds the gamepad's saved controls.
	 */
	var gamepad:BindsData;
}

/**
 * Holds a device's saved controls.
 */
typedef BindsData =
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
