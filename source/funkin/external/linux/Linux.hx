package funkin.external.linux;

#if linux
/**
 * Functions that run exclusively on Linux distros.
 */
@:build(funkin.utils.macro.IncludeMacro.xml('project/Build.xml'))
@:include('linux.hpp')
extern class Linux
{
	/**
	 * @return The user's current language in the Language Code format (i.e. `en-US`).
	 */
	@:native('Linux_GetUserLanguage')
	static function getUserLanguage():String;
}
#end
