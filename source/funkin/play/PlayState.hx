package funkin.play;

import flixel.ui.FlxBar;

import funkin.sound.SoundGroup;
import funkin.ui.MusicBeatState;

class PlayState extends MusicBeatState
{
	/**
	 * The active instance of `PlayState`.
	 */
	public static var instance:Null<PlayState> = null;

	/**
	 * The IDs of the songs that will be played.
	 */
	public var playlist:Array<String> = [];

	/**
	 * The current index of the playlist.
	 */
	var playIndex:Int = 0;

	/**
	 * The instrumental of the current playing track of the playlist.
	 */
	public var inst:FunkinSound;

	/**
	 * The vocals of the current playing track of the playlist.
	 */
	public var vocals:SoundGroup;

	/**
	 * The camera that displays the gameplay (stage and characters).
	 */
	public var camGame:FlxCamera;

	/**
	 * The camera that displays the game interface.
	 */
	public var camHUD:FlxCamera;

	/**
	 * The camera that displays the pause menu.
	 */
	public var camPause:FlxCamera;

	/**
	 * The bar that displays the player's health.
	 */
	public var healthBar:FlxBar;

	/**
	 * The health of the player.
	 */
	public var health:Float = 0;

	/**
	 * The actual health of the player.
	 */
	public var healthLerp:Float = 0;

	public function new()
	{
		super();

		instance = this;
	}

	override function create()
	{
		persistentDraw = persistentUpdate = true;

		#if mobile
		lime.system.System.allowScreenTimeout = false;
		#end

		super.create();

		initCameras();
	}

	function initCameras()
	{
		FlxG.cameras.reset(camGame = new FlxCamera());
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		FlxG.cameras.add(camPause = new FlxCamera(), false);

		for (camera in [camGame, camHUD, camPause])
		{
			camera.bgColor = FlxColor.TRANSPARENT;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		updateHealthBar();
	}

	function updateHealthBar()
	{
		healthLerp = MathUtil.fpsLerp(healthLerp, health, 0.15);
	}

	function updateDiscordPresence()
	{
		#if FEATURE_DISCORD_API
		DiscordRPC.instance.changePresence({
			state: 'testing source',
			details: 'Source Port'
		});
		#end
	}
}
