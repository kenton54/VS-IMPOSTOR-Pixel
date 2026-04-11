#import "Apple.hpp"

#import <CoreFoundation/CoreFoundation.h>
#import <GameController/GameController.h>

char Apple_GetUserLanguage()
{
    std::string language_code;

    CFLocaleRef currentLocale = CFLocaleCopyCurrent();
    CFStringRef languageCodeRef = (CFStringRef)CFLocaleGetValue(currentLocale, kCFLocaleLanguageCode);

    if (languageCodeRef)
    {
        const char* cStringPtr = CFStringGetCStringPtr(languageCodeRef, kCFStringEncodingUTF8);
        if (cStringPtr)
        {
            language_code = cStringPtr;
        }
        else
        {
            CFIndex length = CFStringGetLength(languageCodeRef);
            CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8);
            char* buffer = (char*)malloc(maxSize);
            if (buffer && CFStringGetCString(languageCodeRef, buffer, maxSize, kCFStringEncodingUTF8))
            {
                language_code = buffer;
            }

            free(buffer);
        }
    }

    if (currentLocale)
    {
        CFRelease(currentLocale);
    }

    return language_code.c_str();
}

bool Apple_isKeyboardConnected()
{
    return [GCKeyboard coalesced] != nil;
}
