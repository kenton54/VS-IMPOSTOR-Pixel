package funkin.data;

import funkin.system.FunkinSave;

import lime.system.System;

class ClientPreferences
{
	/**
	 * How often the game gets updated and drawn, in hertz.
	 */
	public static var frameRate(get, set):Int;

	/**
	 * Whether the game should update every CPU cycle or by a fixed amount of frames.
	 */
	public static var unlockedFrameRate(get, set):Bool;

	/**
	 * Whether content that may disturb or make people uncomfortable should be shown.
	 */
	public static var sentitiveContent(get, set):Bool;

	/**
	 * If enabled, makes light more "flashy", if that makes any sense lol.
	 */
	public static var photosentivity(get, set):Bool;

	/**
	 * If enabled, uses shaders that may be too resource-intensive.
	 */
	public static var intensiveShaders(get, set):Bool;

	/**
	 * If enabled, disables some background elements everywhere in the mod, making menus load faster and gameplay be less laggy.
	 *
	 * For non-pixelated sprites, disables anti-aliasing.
	 */
	public static var lowDetail(get, set):Bool;

	/**
	 * The active colorblind shader.
	 */
	public static var colorBlindMode(get, set):ColorBlindMode;

	/**
	 * Whether notes go down instead of up.
	 */
	public static var downScroll(get, set):Bool;

	/**
	 * Whether the notes get centered on the screen.
	 */
	public static var middleScroll(get, set):Bool;

	/**
	 * Whether the time bar is shown when playing a song, showing its progress.
	 */
	public static var timeBar(get, set):Bool;

	/**
	 * How intense the vibration is.
	 */
	public static var hapticsIntensity(get, set):Float;

	/**
	 * How intense the vibration is.
	 */
	public static var strumlinesBackground(get, set):Float;

	/**
	 * Offsets the song in the specified amount of milliseconds.
	 */
	public static var songOffset(get, set):Int;

	/**
	 * Whether vertical-sync is enabled.
	 *
	 * If enabled, frame rate will be locked to the monitor's refresh rate.
	 */
	public static var vsync(get, set):Bool;

	/**
	 * Whether to allow the system to go shut itself down after idling for too long.
	 */
	public static var screenTimeout(get, set):Bool;

	/**
	 * Whether the camera zooms in on every song's beat.
	 */
	public static var zoomCameraOnBeat(get, set):Bool;

	/**
	 * Whether to freeze the game when the its window gets unfocused.
	 */
	public static var autoPause(get, set):Bool;

	/**
	 * Whether to show the FPS Counter.
	 */
	public static var showFPSCounter(get, set):Bool;

	/**
	 * The saved game's language.
	 */
	public static var language(get, set):String;

	/**
	 * If enabled, synchronizes the game's language with the system's language.
	 */
	public static var syncSystemLanguage(get, set):Bool;

	static function get_frameRate():Int
	{
		#if web
		return 60;
		#elseif mobile
		var refreshRate:Int = FlxG.stage.window.displayMode.refreshRate;

		if (refreshRate < 60)
		{
			refreshRate = 60;
		}

		return refreshRate;
		#else
		return FunkinSave.clientPreferences?.frameRate ?? 60;
		#end
	}

	static function set_frameRate(value:Int):Int
	{
		#if web
		return 60;
		#elseif mobile
		var refreshRate:Int = FlxG.stage.window.displayMode.refreshRate;

		if (refreshRate < 60)
		{
			refreshRate = 60;
		}

		return refreshRate;
		#else
		FunkinSave.clientPreferences.frameRate = value;
		FunkinSave.flush();

		FlxG.updateFramerate = FlxG.drawFramerate = value;

		return value;
		#end
	}

	static function get_unlockedFrameRate():Bool
	{
		return FunkinSave.clientPreferences?.unlockedFrameRate ?? false;
	}

	static function set_unlockedFrameRate(value:Bool):Bool
	{
		FunkinSave.clientPreferences.unlockedFrameRate = value;
		FunkinSave.flush();
		return value;
	}

	static function get_sentitiveContent():Bool
	{
		return FunkinSave.clientPreferences?.sentitiveContent ?? true;
	}

	static function set_sentitiveContent(value:Bool):Bool
	{
		FunkinSave.clientPreferences.sentitiveContent = value;
		FunkinSave.flush();
		return value;
	}

	static function get_photosentivity():Bool
	{
		return FunkinSave.clientPreferences?.photosentivity ?? false;
	}

	static function set_photosentivity(value:Bool):Bool
	{
		FunkinSave.clientPreferences.photosentivity = value;
		FunkinSave.flush();
		return value;
	}

	static function get_intensiveShaders():Bool
	{
		return FunkinSave.clientPreferences?.intensiveShaders ?? true;
	}

	static function set_intensiveShaders(value:Bool):Bool
	{
		FunkinSave.clientPreferences.intensiveShaders = value;
		FunkinSave.flush();
		return value;
	}

	static function get_lowDetail():Bool
	{
		return FunkinSave.clientPreferences?.lowDetail ?? false;
	}

	static function set_lowDetail(value:Bool):Bool
	{
		FunkinSave.clientPreferences.lowDetail = value;
		FunkinSave.flush();
		return value;
	}

	static function get_colorBlindMode():ColorBlindMode
	{
		return FunkinSave.clientPreferences?.colorBlindMode ?? NONE;
	}

	static function set_colorBlindMode(value:ColorBlindMode):ColorBlindMode
	{
		FunkinSave.clientPreferences.colorBlindMode = value;
		FunkinSave.flush();

		funkin.graphics.shaders.ColorBlindShader.updateShader(value);

		return value;
	}

	static function get_downScroll():Bool
	{
		return FunkinSave.clientPreferences?.downScroll ?? true;
	}

	static function set_downScroll(value:Bool):Bool
	{
		FunkinSave.clientPreferences.downScroll = value;
		FunkinSave.flush();
		return value;
	}

	static function get_middleScroll():Bool
	{
		return FunkinSave.clientPreferences?.middleScroll ?? true;
	}

	static function set_middleScroll(value:Bool):Bool
	{
		FunkinSave.clientPreferences.middleScroll = value;
		FunkinSave.flush();
		return value;
	}

	static function get_timeBar():Bool
	{
		return FunkinSave.clientPreferences?.timeBar ?? true;
	}

	static function set_timeBar(value:Bool):Bool
	{
		FunkinSave.clientPreferences.timeBar = value;
		FunkinSave.flush();
		return value;
	}

	static function get_hapticsIntensity():Float
	{
		return FunkinSave.clientPreferences?.hapticsIntensity ?? 1.0;
	}

	static function set_hapticsIntensity(value:Float):Float
	{
		FunkinSave.clientPreferences.hapticsIntensity = value;
		FunkinSave.flush();
		return value;
	}

	static function get_strumlinesBackground():Float
	{
		return FunkinSave.clientPreferences?.strumlinesBackground ?? 0.0;
	}

	static function set_strumlinesBackground(value:Float):Float
	{
		FunkinSave.clientPreferences.strumlinesBackground = value.clamp(0, 1);
		FunkinSave.flush();
		return value;
	}

	static function get_songOffset():Int
	{
		return FunkinSave.clientPreferences?.songOffset ?? 0;
	}

	static function set_songOffset(value:Int):Int
	{
		FunkinSave.clientPreferences.songOffset = value.clamp(-1000, 1000);
		FunkinSave.flush();

		Conductor.offset = value;

		return value;
	}

	static function get_vsync():Bool
	{
		#if web
		return false;
		#else
		return FunkinSave.clientPreferences?.vsync ?? false;
		#end
	}

	static function set_vsync(value:Bool):Bool
	{
		#if web
		return false;
		#else
		FunkinSave.clientPreferences.vsync = value;
		FunkinSave.flush();

		FlxG.stage.window.context.attributes.vsync = value;

		return value;
		#end
	}

	static function get_screenTimeout():Bool
	{
		#if !mobile
		return false;
		#else
		return FunkinSave.clientPreferences?.screenTimeout ?? true;
		#end
	}

	static function set_screenTimeout(value:Bool):Bool
	{
		#if !mobile
		return false;
		#else
		FunkinSave.clientPreferences.screenTimeout = value;
		FunkinSave.flush();

		System.allowScreenTimeout = value;

		return value;
		#end
	}

	static function get_zoomCameraOnBeat():Bool
	{
		return FunkinSave.clientPreferences?.zoomCameraOnBeat ?? true;
	}

	static function set_zoomCameraOnBeat(value:Bool):Bool
	{
		FunkinSave.clientPreferences.zoomCameraOnBeat = value;
		FunkinSave.flush();
		return value;
	}

	static function get_autoPause():Bool
	{
		return FunkinSave.clientPreferences?.autoPause ?? true;
	}

	static function set_autoPause(value:Bool):Bool
	{
		FunkinSave.clientPreferences.autoPause = value;
		FunkinSave.flush();

		FlxG.autoPause = value;

		return value;
	}

	static function get_showFPSCounter():Bool
	{
		#if !desktop
		return false;
		#else
		return FunkinSave.clientPreferences?.showFPSCounter ?? false;
		#end
	}

	static function set_showFPSCounter(value:Bool):Bool
	{
		#if !desktop
		return false;
		#else
		FunkinSave.clientPreferences.showFPSCounter = value;
		FunkinSave.flush();

		Main.debugOverlay.visible = value;

		return value;
		#end
	}

	static function get_language():String
	{
		return FunkinSave.clientPreferences?.language ?? 'en';
	}

	static function set_language(value:String):String
	{
		FunkinSave.clientPreferences.language = value;
		FunkinSave.flush();

		if (!syncSystemLanguage)
		{
			funkin.system.Translations.curLanguageID = value;
		}

		return value;
	}

	static function get_syncSystemLanguage():Bool
	{
		return FunkinSave.clientPreferences?.syncSystemLanguage ?? false;
	}

	static function set_syncSystemLanguage(value:Bool):Bool
	{
		FunkinSave.clientPreferences.syncSystemLanguage = value;
		FunkinSave.flush();

		if (value)
		{
			@:privateAccess funkin.system.Translations.checkSystemLanguage();
		}

		return value;
	}
}

enum abstract ColorBlindMode(String) from String to String
{
	var NONE:String = 'none';

	var DEUTERANOMALY:String = 'deuteranomaly';

	var PROTANOMALY:String = 'protanomaly';

	var PROTANOPIA:String = 'protanopia';

	var DEUTERANOPIA:String = 'deuteranopia';

	var TRITANOPIA:String = 'tritanopia';

	var TRITANOMALY:String = 'tritanomaly';
}
