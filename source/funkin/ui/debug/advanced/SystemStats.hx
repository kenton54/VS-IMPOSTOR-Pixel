package funkin.ui.debug.advanced;

import lime.system.Display;
import lime.system.System;

import openfl.text.TextField;

#if windows
import funkin.utils.RegistryUtil;
#end

#if web
import js.Browser;
#end

/**
 * Shows information about the system's specs.
 */
class SystemStats extends DebugCategory
{
	public var osInfo:String = '';
	public var cpuName:String = '';
	public var displayInfo:String = '';
	public var gameDisplay:String = '';
	public var gpuName:String = '';
	public var gpuMaxSize:String = '';
	public var memType:String = '';

	var systemInfo:TextField;

	public function new(backgroundColor:Int)
	{
		super('System', 1024, 138, backgroundColor, TOP_RIGHT);

		systemInfo = createTextField();
		addChild(systemInfo);

		#if windows
		var windowsVersionPath:String = 'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion';
		var buildNumber:Int = Std.parseInt(RegistryUtil.get(HKEY_LOCAL_MACHINE, windowsVersionPath, 'CurrentBuildNumber'));
		var edition:String = RegistryUtil.get(HKEY_LOCAL_MACHINE, windowsVersionPath, 'ProductName');

		var lcuKey:String = 'WinREVersion';
		if (buildNumber >= 22000)
		{
			edition.replace('Windows 10', 'Windows 11');
			lcuKey = 'LCUVer';
		}

		osInfo = edition;

		var lcuVersion:String = RegistryUtil.get(HKEY_LOCAL_MACHINE, windowsVersionPath, lcuKey);

		if (lcuVersion != null && lcuVersion != '')
		{
			osInfo += lcuVersion;
		}
		else if (System.platformLabel != null && System.platformLabel != '' && System.platformVersion != null && System.platformVersion != '')
		{
			osInfo += '${System.platformLabel.replace(System.platformVersion, '').trim()}  ${System.platformVersion}';
		}
		#elseif web
		osInfo = '${Browser.navigator.appVersion}';
		#end

		var display:Display = FlxG.stage.application.window.display;
		displayInfo = '${display.currentMode.width}x${display.currentMode.height} ${display.dpi * 100}% Scale @ ${display.currentMode.refreshRate}Hz (${display.name})';

		try
		{
			#if windows
			cpuName = RegistryUtil.get(HKEY_LOCAL_MACHINE, 'HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0', 'ProcessorNameString');
			#end
		}
		catch (e:Dynamic) {}

		var size:Int = FlxG.bitmap.maxTextureSize;
		gpuMaxSize = '${size}x${size}';
	}

	override public function postUpdate()
	{
		var display:Display = FlxG.stage.application.window.display;
		displayInfo = '${display.currentMode.width}x${display.currentMode.height} @ ${display.currentMode.refreshRate}Hz (${display.name})';

		var systemStuff:Array<String> = [];

		if (cpuName != '')
		{
			systemStuff.push('CPU Architecture: $cpuName');
		}

		if (osInfo != '')
		{
			#if web
			systemStuff.push('Browser: $osInfo ${Browser.navigator.platform}');
			#else
			systemStuff.push('Operating System: $osInfo');
			#end
		}

		if (displayInfo != '')
		{
			systemStuff.push('Display Monitor: $displayInfo');
		}

		gameDisplay = '${FlxG.stage.stageWidth}x${FlxG.stage.stageHeight} @ ${FlxG.width}x${FlxG.height}';
		systemStuff.push('Game Display: $gameDisplay');

		final rendererShit:Array<String> = [];
		rendererShit.push(Std.string(@:privateAccess FlxG.stage.context3D.gl.getParameter(FlxG.stage.context3D.gl.RENDERER)));
		rendererShit.push('(OpenGL ${@:privateAccess FlxG.stage.context3D.gl.getParameter(FlxG.stage.context3D.gl.VERSION)})');

		systemStuff.push('Renderer: ${rendererShit.join(" ")}');

		systemStuff.push('Language: ${funkin.system.Translations.getUserLanguage()}');

		systemInfo.text = systemStuff.join('\n');
	}
}
