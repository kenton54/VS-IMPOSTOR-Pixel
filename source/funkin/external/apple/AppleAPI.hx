package funkin.external.apple;

#if (macos || ios)
/**
 * Functions that run exclusively on Apple devices.
 */
@:cppFileCode('
#include <CoreFoundation/CoreFoundation.h>
#include <GameController/GameController.h>
#include <iostream>
#include <string>
')
class AppleAPI
{
	/**
	 * @return The user's current language in the Language Code format (i.e. `en-US`).
	 */
	@:functionCode('
		std::string language_code;

		CFArrayRef languages = CFLocaleCopyPreferredLanguages();

    CFStringRef langCode = (CFStringRef)CFArrayGetValueAtIndex(languages, 0);

    char buffer[128];
    if (CFStringGetCString(langCode, buffer, sizeof(buffer), kCFStringEncodingUTF8))
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

	/**
	 * @return Whether a keyboard is connected or not. macOS will always return `true`.
	 */
	@:functionCode('
		return [GCKeyboard coalesced] != nil;
	')
	public static function isKeyboardConnected():Bool
	{
		return #if desktop true #else false #end;
	}
}
#end
