package funkin.external.apple;

#if (macos || ios)
/**
 * Functions that run exclusively on Apple devices.
 */
@:cppFileCode('
#include <CoreFoundation/CoreFoundation.h>
#include <GameController/GameController.h>
#include <string>
#include <iostream>
')
class AppleAPI
{
	/**
	 * @return The user's current language in the Language Code format (i.e. `en-US`).
	 */
	@:functionCode('
		CFLocaleRef cflocale = CFLocaleCopyCurrent();

		CFStringRef value = (CFStringRef)CFLocaleGetValue(cflocale, kCFLocaleLanguageCode);

		char buffer[128];
    if (CFStringGetCString(value, buffer, sizeof(buffer), kCFStringEncodingUTF8))
		{
			CFRelease(cflocale);
			return std::string(buffer);
    }

    CFRelease(cflocale);
    return "en-US";
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
