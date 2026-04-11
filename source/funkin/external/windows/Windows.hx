package funkin.external.windows;

#if (windows && cpp)
/**
 * Functions that run exclusively on Windows operating systems.
 */
@:build(funkin.utils.macro.IncludeMacro.xml('project/Build.xml'))
@:include('windows.hpp')
extern class Windows
{
	/**
	 * @return Whether the system has dark mode enabled or not.
	 */
	@:native('Windows_IsSystemDarkMode')
	static function isSystemDarkMode():Bool;

	/**
	 * Toggles the window's dark mode.
	 * @param enable Whether to enable it or not.
	 */
	@:native('Windows_SetDarkMode')
	static function setWindowDarkMode(enable:Bool):Void;

	/**
	 * @return The user's current language in the Language Code format (i.e. `en-US`).
	 */
	@:native('Windows_GetUserLanguage')
	static function getUserLanguage():String;
}
#end
