package;

import flixel.FlxG;
import flixel.FlxGame;

import funkin.InitState;
import funkin.data.ClientPreferences;
import funkin.system.logs.CrashHandler;
import funkin.ui.debug.DebugOverlay;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

#if linux
import hxgamemode.GamemodeClient;
#end

#if hxvlc
import hxvlc.util.Handle;
#end

/**
 * The class where the game is initialized, as well as other configurations.
 */
class Main extends Sprite
{
	/**
	 * IMPOSTOR Pixel's custom debug overlay.
	 *
	 * Contains information about the game and the system running this mod.
	 */
	public static var debugOverlay:DebugOverlay;

	public static function main()
	{
		#if android
		Sys.setCwd(haxe.io.Path.addTrailingSlash(extension.androidtools.content.Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(haxe.io.Path.addTrailingSlash(lime.system.System.documentsDirectory));
		#end

		#if (windows && cpp)
		if (funkin.external.windows.WindowsAPI.isSystemDarkMode())
		{
			funkin.external.windows.WindowsAPI.setWindowDarkMode(true);
		}
		#end

		#if linux
		GamemodeClient.request_start();
		#end

		CrashHandler.init();

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	function init(?event:Event)
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		#if (sys && !mobile)
		Lib.current.stage.window.onClose.add(function()
		{
			#if hxvlc
			Handle.dispose();
			#end

			Sys.exit(0);
		});
		#end

		startGame();
	}

	function startGame()
	{
		debugOverlay = new DebugOverlay();

		funkin.system.FunkinSave.load();

		#if hxvlc
		Handle.initAsync(null, function(success:Bool)
		{
			if (success)
			{
				trace('[HXVLC] LibVLC initialized successfully!');
			}
			else
			{
				trace('[HXVLC] LibVLC failed to start!');
			}
		});
		#end

		final frameRate:Int = ClientPreferences.unlockedFrameRate ? 0 : ClientPreferences.frameRate;

		var game:FlxGame = new FlxGame(1280, 720, InitState, frameRate, frameRate, true, FlxG.stage.window.fullscreen);
		addChild(game);

		#if !web
		FlxG.scaleMode = new funkin.system.FullScreenScaleMode();
		#end

		addChild(debugOverlay);
	}
}
