#import "AppleApi.hpp"

#import <CoreFoundation/CoreFoundation.h>
#import <GameController/GameController.h>

String Apple_GetUserLanguage()
{
    NSString *language = [[NSLocale currentLocale] localeIdentifier];
    return language;
}

bool Apple_isKeyboardConnected()
{
    return [GCKeyboard coalesced] != nil;
}
