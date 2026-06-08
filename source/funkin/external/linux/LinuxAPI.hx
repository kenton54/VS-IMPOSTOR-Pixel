package funkin.external.linux;

#if linux
/**
 * Functions that run exclusively on Linux distros.
 */
@:cppFileCode('
#include <iostream>
#include <string>
')
class LinuxAPI
{
	/**
	 * @return The user's current language in the Language Code format (e.g. `en-US`).
	 */
	@:functionCode('
		const char *lang = std::getenv("LANG");
		if (lang != nullptr)
		{
			return String(lang);
		}
		return String("en-US");
	')
	public static function getUserLanguage():String
	{
		return 'en-US';
	}
}
#end
