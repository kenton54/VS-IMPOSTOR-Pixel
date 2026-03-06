package;

import flixel.FlxGame;

import funkin.InitState;
import funkin.system.logs.CrashHandler;
import funkin.ui.debug.DebugOverlay;

import haxe.io.Path;

import lime.system.System;

import openfl.Lib;
import openfl.display.Sprite;

#if linux
import hxgamemode.GamemodeClient;
#end

#if android
import extension.androidtools.content.Context;
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
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(Path.addTrailingSlash(System.documentsDirectory));
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

		#if hxvlc
		Handle.init();
		#end

		#if (windows && cpp)
		funkin.utils.native.Windows.setWindowDarkMode(true);
		#end

		var game:FlxGame = new FlxGame(0, 0, InitState, 60, 60, true);
		addChild(game);

		debugOverlay = new DebugOverlay(0x484848);
		addChild(debugOverlay);
	}
}
