package funkin;

/**
 * Holds fallback values for some classes.
 */
final class Constants
{
	/**
	 * The mod's title name.
	 */
	public static final TITLE:String = 'VS IMPOSTOR Pixel';

	/**
	 * The mod's version.
	 */
	public static var VERSION(get, never):String;

	static function get_VERSION():String
	{
		return FlxG.stage.application.meta.get('version');
	}

	/**
	 * Whether the build is compiled as debug or release.
	 */
	public static final DEBUG_BUILD:Bool = #if debug true #else false #end;

	/**
	 * The path to the location of the save data.
	 */
	public static final SAVE_PATH:String = 'kenton';

	/**
	 * The languages the mod supports.''
	 */
	public static final LANGUAGES:Array<String> = ['en', 'es', 'fr', 'pt', 'ru', 'vi'];

	/**
	 * The default font `FunkinText` renders with.
	 */
	public static final DEFAULT_FONT:String = 'Pixeloid Sans Bold';

	/**
	 * The language the engine fallbacks to if a language fails to load or fails to get a translation ID.
	 */
	public static final DEFAULT_LANGUAGE:String = 'en';

	/**
	 * The default animation name to add or play for all sprites.
	 */
	public static final DEFAULT_ANIMATION_NAME:String = 'idle';

	/**
	 * How frequent will the debug overlay update the information it displays.
	 */
	public static final DEBUG_OVERLAY_UPDATE_FREQUENCY:Int = 500;

	/**
	 * The chance for shooting stars to spawn each frame.
	 */
	public static final SHOOTING_STAR_SPAWN_CHANCE:Float = 0.01;

	/**
	 * The default shooting star launch speed.
	 */
	public static final DEFAULT_SHOOTING_STAR_SPEED:Float = 2000;

	/**
	 * The default shooting star minimum launch angle.
	 *
	 * Right    = 0 Degrees.
	 *
	 * Down     = 90 Degrees.
	 *
	 * Left     = 180 Degrees.
	 *
	 * Up       = 270 Degrees.
	 */
	public static final DEFAULT_SHOOTING_STAR_LAUNCH_ANGLE_MIN:Float = 10;

	/**
	 * The default shooting star maximum launch angle.
	 *
	 * Right    = 0 Degrees.
	 *
	 * Down     = 90 Degrees.
	 *
	 * Left     = 180 Degrees.
	 *
	 * Up       = 270 Degrees.
	 */
	public static final DEFAULT_SHOOTING_STAR_LAUNCH_ANGLE_MAX:Float = 45;

	/**
	 * The default beats per minute.
	 */
	public static final DEFAULT_BPM:Float = 100;

	/**
	 * The default character to load if another one fails to load.
	 */
	public static final DEFAULT_CHARACTER:String = 'bf';
}
