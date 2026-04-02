package funkin;

import flixel.FlxSprite;
import flixel.FlxState;

import funkin.menus.TitleState;
import funkin.system.ShaderResizeFix;

/**
 * The state the game starts with.
 * 
 * Used for setting up critical classes.
 */
class InitState extends FlxState
{
	override public function create()
	{
		FlxSprite.defaultAntialiasing = false;

		Conductor.init();
		Translations.init();
		Achievements.init();
		#if DISCORD_API
		DiscordClient.init();
		#end
		ShaderResizeFix.init();

		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = true;
		#end

		#if android
		FlxG.android.preventDefaultKeys = [flixel.input.android.FlxAndroidKey.BACK];
		#end

		FlxG.stage.window.minWidth = 1280;
		FlxG.stage.window.minHeight = 720;

		FlxG.cameras.bgColor = FlxColor.TRANSPARENT;

		startGame();
	}

	function startGame()
	{
		FlxG.switchState(() -> new TitleState());
	}
}
