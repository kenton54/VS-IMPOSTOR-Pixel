package funkin.external.windows;

#if (windows && cpp)
/**
 * Functions that run exclusively on Windows operating systems.
 */
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib"/>
</target>
')
@:cppFileCode('
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define NOCRYPT
#define NOKANJI
#define NOHELP

#include <iostream>
#include <string>
#include <windows.h>
#include <dwmapi.h>
#include <psapi.h>
#include <stdint.h>
#include <stdio.h>
')
class WindowsAPI
{
	/**
	 * @return Whether the system has dark mode enabled or not.
	 */
	@:functionCode('
	HKEY hKey;
	DWORD value = 1; // default to light theme
	DWORD dwSize = sizeof(value);
	DWORD dwType = REG_DWORD;

	// i know this looks stupid, but it parses the backward slashes properly
	if (RegOpenKeyEx(HKEY_CURRENT_USER, "Software\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Themes\\\\Personalize", 0, KEY_READ, &hKey) == ERROR_SUCCESS)
	{
		RegQueryValueEx(hKey, "AppsUseLightTheme", NULL, &dwType, (LPBYTE)&value, &dwSize);
		RegCloseKey(hKey);
	}

	return value == 0;
	')
	public static function isSystemDarkMode():Bool
	{
		return false;
	}

	/**
	 * Toggles the window's dark mode.
	 * @param enable Whether to enable it or not.
	 */
	@:functionCode('
	HWND window = GetActiveWindow();

	int darkMode = enable ? 1 : 0;

	if (DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode)) != S_OK)
	{
		DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode));
	}

	UpdateWindow(window);
	')
	public static function setWindowDarkMode(enable:Bool):Void {}

	/**
	 * @return The amount of memory the application is using.
	 */
	@:functionCode('
	PROCESS_MEMORY_COUNTERS_EX pmc;

	if (GetProcessMemoryInfo(GetCurrentProcess(), (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc)))
		return pmc.WorkingSetSize;

	return 0;
	')
	public static function getProcessMemory():Float
	{
		return 0;
	}
}
#end
