// to prevent windows doing random shit and slowing things down
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define NOCRYPT
#define NOKANJI
#define NOHELP

#include <iostream>
#include <string>
#include <windows.h>
#include <psapi.h>
#include <dwmapi.h>
#include <iomanip>
#include <stdint.h>
#include <stdio.h>

void Windows_SetDarkMode(bool enable)
{
  HWND window = GetActiveWindow();

  int darkMode = enable ? 1 : 0;

  if (DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode)) != S_OK)
  {
    DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode));
  }

  UpdateWindow(window);
}

bool Windows_IsSystemDarkMode()
{
  HKEY hKey;
  DWORD data = 1;
  DWORD size = sizeof(data);

  const wchar_t *subkey = L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize";
  const wchar_t *value = L"AppsUseLightTheme";

  if (RegOpenKeyExW(HKEY_CURRENT_USER, subkey, 0, KEY_READ, &hKey) == ERROR_SUCCESS)
  {
    RegQueryValueExW(hKey, value, NULL, NULL, reinterpret_cast<LPBYTE>(&data), &size);
    RegCloseKey(hKey);
  }

  return data == 0;
}

char Windows_GetUserLanguage()
{
  wchar_t localeName[LOCALE_NAME_MAX_LENGTH];
  if (GetUserDefaultLocaleName(localeName, LOCALE_NAME_MAX_LENGTH))
  {
    return *localeName;
  }

  return *"en-US";
}
