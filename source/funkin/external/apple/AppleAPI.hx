package funkin.external.apple;

#if (macos || ios)
/**
 * Functions that run exclusively on Apple devices.
 */
@:cppFileCode('
#include <CoreFoundation/CoreFoundation.h>
#include <iostream>
#include <string>
')
class AppleAPI
{
	/**
	 * @return The user's current language in the Language Code format (e.g. `en-US`).
	 */
	@:functionCode('
		std::string language_code;

		CFArrayRef languages = CFLocaleCopyPreferredLanguages();
    CFStringRef lang_code_ref = (CFStringRef)CFArrayGetValueAtIndex(languages, 0);

    char buffer[128];
    if (CFStringGetCString(lang_code_ref, buffer, sizeof(buffer), kCFStringEncodingUTF8))
		{
			CFRelease(languages);
			language_code = std::string(buffer);
    }

    CFRelease(languages);
		return language_code.c_str();
	')
	public static function getUserLanguage():String
	{
		return 'en-US';
	}
}
#end
