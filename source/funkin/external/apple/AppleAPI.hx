package funkin.external.apple;

#if (macos || ios)
/**
 * Functions that run exclusively on Apple devices.
 */
@:build(funkin.utils.macro.IncludeMacro.xml('project/Build.xml'))
@:include('AppleApi.hpp')
extern class AppleAPI
{
	/**
	 * @return The user's current language in the Language Code format (i.e. `en-US`).
	 */
	@:native('Apple_GetUserLanguage')
	static function getUserLanguage():String;

	/**
	 * @return Whether a keyboard is connected or not.
	 */
	@:native('Apple_isKeyboardConnected')
	static function isKeyboardConnected():Bool;
}
#end
