package funkin;

import flixel.FlxState;

#if sys
import sys.FileSystem;
#end

/**
 * The state the game starts with.
 *
 * Used for setting up core classes.
 */
@:access(funkin.input.InputManager)
@:access(funkin.system.Achievements)
@:access(funkin.system.Statistics)
@:access(funkin.system.Translations)
class InitState extends FlxState
{
	static var coreStarted:Bool = false;

	override function create()
	{
		if (coreStarted)
		{
			startGame();
			return;
		}

		setupGame();

		funkin.input.InputManager.init();

		startGame();
	}

	function setupGame()
	{
		flixel.FlxSprite.defaultAntialiasing = false;

		// FlxG.sound.volumeUpKeys = [];
		// FlxG.sound.volumeDownKeys = [];
		// FlxG.sound.muteKeys = [];

		FlxG.inputs.resetOnStateSwitch = false;

		FlxG.fixedTimestep = false;

		trace('a');

		funkin.system.Translations.init();
		funkin.system.Achievements.init();
		funkin.system.Statistics.init();

		trace('b');

		Conductor.init();

		trace('c');

		#if FEATURE_DISCORD_API
		DiscordClient.init();

		lime.app.Application.current.onExit.add(function(exitCode:Int)
		{
			DiscordClient.shutdown();
		});
		#end

		funkin.system.ShaderResizeFix.init();

		trace('d');

		#if android
		FlxG.android.preventDefaultKeys = [flixel.input.android.FlxAndroidKey.BACK];
		#end

		FlxG.stage.window.minWidth = 1280;
		FlxG.stage.window.minHeight = 720;

		funkin.system.FunkinSave.applyLoadedData();

		Pointer.hide();

		trace('e');
	}

	function startGame()
	{
		coreStarted = true;

		#if (FEATURE_DEBUG_CONTENT && sys)
		var sysArgs:Array<String> = Sys.args().filter(arg -> arg != null && arg != '');

		var filePath:Null<String> = null;

		for (arg in sysArgs)
		{
			if (filePath == null && FileSystem.isDirectory(arg) && FileSystem.exists(arg))
			{
				filePath = arg;
			}
		}

		if (filePath != null)
		{
			if (funkin.data.song.SongParser.isFormatValid(filePath))
			{
				// FlxG.switchState(() -> new funkin.menus.debug.charter.loader.ChartLoaderState(filePath));
			}
			return;
		}
		#end

		funkin.ui.MusicBeatState.setTransitions(funkin.ui.transitions.Fade);
		FlxG.switchState(() -> new funkin.menus.StartupState());
	}
}
