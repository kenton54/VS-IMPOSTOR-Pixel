package funkin.api;

#if FEATURE_DISCORD_API
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

import sys.thread.Thread;

class DiscordRPC
{
	/**
	 * The ID of the Discord Application.
	 */
	static final CLIENT_ID:String = '1392684759658008758';

  public static var instance(get, never):DiscordRPC;

  static var _instance:Null<DiscordRPC> = null;

  static function get_instance():DiscordRPC
  {
    if (_instance == null)
    {
      _instance = new DiscordRPC();
    }

    return _instance;
  }

  var handlers:DiscordEventHandlers;
  var thread:Null<Thread> = null;

	private function new()
	{
		handlers = new DiscordEventHandlers();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnect);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
	}

  public function init()
  {
    Discord.Initialize(CLIENT_ID, cpp.RawPointer.addressOf(handlers), false, null);
    thread = Thread.create(update);
  }

	function update()
	{
		while (true)
		{
			#if DISCORD_DISABLE_IO_THREAD
			Discord.UpdateConnection();
			#end

			Discord.RunCallbacks();

			Sys.sleep(1);
		}
	}

	static function onReady(request:cpp.RawConstPointer<DiscordUser>)
	{
		trace('[DISCORD] Successfully connected to user "${request[0].username}"!');
	}

	static function onDisconnect(error:Int, message:cpp.ConstCharStar)
	{
		trace('[DISCORD] Disconnected from user');
	}

	static function onError(error:Int, message:cpp.ConstCharStar)
	{
		throw '[DISCORD] AN ERROR OCURRED! (Error code: $error | Message: ${cast (message, String)})';
	}

	/**
	 * Changes what the Discord Rich Presence presence displays.
	 * @param params The parameters to change.
	 */
	public function changePresence(params:DiscordRPCParams)
	{
		var presence:DiscordRichPresence = new DiscordRichPresence();

		presence.type = params.activity ?? DiscordActivityType.DiscordActivityType_Playing;

		presence.state = cast(params.state, Null<String>) ?? '';
		presence.details = cast(params.details, Null<String>) ?? '';

		// The big image representing the game that appears on the Rich Presence.
		// The text that appears when you hover over the Rich Presence image.
		presence.largeImageText = 'VS IMPOSTOR Pixel';
		// The key name of the image inside the Rich Presence assets.
		presence.largeImageKey = cast(params.largeImageKey, Null<String>) ?? 'red';

		// A small icon that appears at the bottom right of the image of the Rich Presence.
		// The text that appears when you hover over the Rich Presence image.
		presence.smallImageText = cast(params.smallImageText, Null<String>) ?? '';
		// The key name of the image inside the Rich Presence assets.
		presence.smallImageKey = cast(params.smallImageKey, Null<String>) ?? '';

    // TODO: add buttons to the rpc

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	}

	/**
	 * Clears the current Discord Rich Presence.
	 */
	public function clearPresence()
	{
		Discord.ClearPresence();
	}

	/**
	 * Stops the active Discord Rich Presence.
	 */
	public function shutdown()
	{
		Discord.Shutdown();
	}
}

/**
 * Parameters for changing the presence of the Discord Rich Presence.
 */
typedef DiscordRPCParams =
{
	/**
	 * The current state the player is at.
	 */
	var state:String;

	/**
	 * Details about the state.
	 */
	var details:String;

	/**
	 * What the user is doing.
	 */
	var ?activity:DiscordActivityType;

	/**
	 * The image to display in the Discord Rich Presence.
	 *
	 * MUST BE THE KEY NAME OF THE IMAGE INSIDE THE RICH PRESENCE ASSETS!!!
	 */
	var ?largeImageKey:String;

	/**
	 * The image to display in the small icon at the bottom right of the large image.
	 *
	 * MUST BE THE KEY NAME OF THE IMAGE INSIDE THE RICH PRESENCE ASSETS!!!
	 */
	var ?smallImageKey:String;

	/**
	 * A text describing what the small icon implies.
	 */
	var ?smallImageText:String;
}
#end
