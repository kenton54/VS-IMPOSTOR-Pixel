package funkin.external.apple;

#if (macos || ios)
/**
 * Functions that run exclusively on Apple devices.
 */
@:cppFileCode('
#include <CoreFoundation/CoreFoundation.h>
#include <GameController/GameController.h>
#include <mach/mach.h>
#include <sys/types.h>
#include <sys/sysctl.h>
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

		CFLocaleRef cur_locale = CFLocaleCopyCurrent();
		CFStringRef lang_code_ref = (CFStringRef)CFLocaleGetValue(cur_locale, kCFLocaleLanguageCode);

		if (lang_code_ref)
		{
			const char* cStringPtr = CFStringGetCStringPtr(lang_code_ref, kCFStringEncodingUTF8);
			if (cStringPtr)
			{
				language_code = cStringPtr;
			}
			else
			{
				CFIndex length = CFStringGetLength(lang_code_ref);
				CFIndex max_size = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8);

				char* buffer = (char*)malloc(max_size);
				if (buffer && CFStringGetCString(lang_code_ref, buffer, max_size, kCFStringEncodingUTF8))
				{
					language_code = buffer;
				}

				free(buffer);
			}
		}

		if (cur_locale)
		{
			CFRelease(cur_locale);
		}

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
		return false;
	')
	public static function isKeyboardConnected():Bool
	{
		return #if desktop true #else false #end;
	}
}
#end
