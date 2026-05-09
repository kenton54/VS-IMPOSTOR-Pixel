package funkin;

import flixel.FlxSprite;
import flixel.FlxState;

import funkin.system.ShaderResizeFix;

/**
 * The state the game starts with.
 *
 * Used for setting up critical classes.
 */
class InitState extends FlxState
{
	static var coreStarted:Bool = false;

	override public function create()
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
		FlxSprite.defaultAntialiasing = false;

		// FlxG.sound.volumeUpKeys = [];
		// FlxG.sound.volumeDownKeys = [];
		// FlxG.sound.muteKeys = [];

		FlxG.inputs.resetOnStateSwitch = false;

		FlxG.fixedTimestep = false;

		funkin.system.Translations.init();
		funkin.system.Achievements.init();

		// Drive achievement toast animations every frame.
		FlxG.signals.postUpdate.add(() -> funkin.system.Achievements.update(FlxG.elapsed));

		Conductor.init();

		#if FEATURE_DISCORD_API
		DiscordClient.init();

		lime.app.Application.current.onExit.add(function(exitCode:Int)
		{
			DiscordClient.shutdown();
		});
		#end

		ShaderResizeFix.init();

		#if android
		FlxG.android.preventDefaultKeys = [flixel.input.android.FlxAndroidKey.BACK];
		#end

		FlxG.stage.window.minWidth = 1280;
		FlxG.stage.window.minHeight = 720;

		funkin.system.FunkinSave.applyLoadedData();

		Pointer.hide();
	}

	function startGame()
	{
		coreStarted = true;

		funkin.ui.MusicBeatState.skipTransIn = true;
		FlxG.switchState(() -> new funkin.menus.title.TitleState());
	}
}
