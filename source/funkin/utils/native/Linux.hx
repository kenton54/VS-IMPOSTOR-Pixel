package funkin.utils.native;

#if linux
/**
 * Code that can only be run on systems running Linux distros.
 */
@:cppFileCode('
#include <iostream>
#include <cstdlib>
#include <string>
#include <fstream>
')
class Linux
{
	/**
	 * @return The total amount of RAM the system has installed.
	 */
	@:functionCode('
		std::string token;
		std::ifstream file("/proc/meminfo");
		unsigned long memTotal = 0;

		while (file >> token) {
			if (token == "MemTotal:") {
				if (file >> memTotal) {
					return static_cast<Float>(memTotal);
				}
			}

			file.ignore(std::numeric_limits<std::streamsize>::max(), \'\\n\');
		}
		return 0.0;
	')
	public static function getTotalSystemMemory():Float
	{
		return 0;
	}

	/**
	 * @return The system\'s current language in the Language Code format (i.e. `en-US`).
	 */
	@:functionCode('
		const char* lang = std::getenv("LANG");
		if (lang != nullptr) {
			return String(lang);
		}
		return String("en-US");
	')
	public static function getSystemLanguage():String
	{
		return '';
	}
}
#end
