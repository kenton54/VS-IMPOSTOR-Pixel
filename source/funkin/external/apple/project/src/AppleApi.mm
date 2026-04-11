#import "AppleApi.hpp"

#import <CoreFoundation/CoreFoundation.h>
#import <GameController/GameController.h>
#import <iostream>
#import <string>

std::string Apple_GetUserLanguage()
{
    NSArray *languages = [NSLocale preferredLanguages];

    if ([languages count] > 0)
    {
        NSString *primaryLanguage = [languages firstObject];
        return std::string([primaryLanguage UTF8String]);
    }
}

bool Apple_isKeyboardConnected()
{
    return [GCKeyboard coalesced] != nil;
}
