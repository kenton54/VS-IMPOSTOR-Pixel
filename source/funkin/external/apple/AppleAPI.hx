package funkin.external.apple;

#if (macos || ios)
/**
 * Functions that run exclusively on Apple devices.
 */
@:cppFileCode('
#include <CoreFoundation/CoreFoundation.h>
#include <GameController/GameController.h>
')
class AppleAPI
{
	/**
	 * @return The user's current language in the Language Code format (i.e. `en-US`).
	 */
	@:functionCode('
		NSString *language = [[NSLocale currentLocale] localeIdentifier];
    return language;
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
