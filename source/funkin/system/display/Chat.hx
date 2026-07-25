package funkin.system.display;

import funkin.data.ChatMessageData;
import funkin.data.ClientPreferences;
import funkin.input.InputManager;

import openfl.display.Sprite;

// TODO: figure this out

enum abstract ChatPosition(Int) from Int to Int
{
	/**
	 * The chat is positioned at the bottom left of the screen.
	 */
	var BOTTOM_LEFT;

	/**
	 * The chat is positioned at the bottom right of the screen.
	 */
	var BOTTOM_RIGHT;

	/**
	 * The chat is positioned at the top left of the screen.
	 */
	var TOP_LEFT;

	/**
	 * The chat is positioned at the top right of the screen.
	 */
	var TOP_RIGHT;

	@:from public static function fromInt(value:Int):ChatPosition
	{
		return switch (value)
		{
			case 0: BOTTOM_LEFT;
			case 1: BOTTOM_RIGHT;
			case 2: TOP_LEFT;
			case 3: TOP_RIGHT;
			default: BOTTOM_LEFT;
		}
	}

	@:to inline function toInt():Int
	{
		return this;
	}
}

class Chat extends Sprite
{
	/**
	 * The global `Chat` instance.
	 */
	public static var instance:Null<Chat> = null;

	/**
	 * The full list of sent and received messages from online connections or debug logs.
	 */
	public var history:Array<ChatMessageData> = [];

	/**
	 * An array holding recently sent messages. These messages are actively on a timer, and once that timer reaches a certain value, they get removed from this array.
	 *
	 * It's also helps the chat to tell which chat messages can render when the chat isn't open.
	 */
	public var recentMessages:Array<ChatMessage> = [];

	/**
	 * Where the chat is positioned.
	 */
	public var position:ChatPosition;

	/**
	 * Whether the chat is currently open.
	 */
	public var isOpen(default, null):Bool = false;

	@:noCompletion static function init()
	{
		FlxG.game.addChild(new Chat());
	}

	@:noCompletion function new()
	{
		super();

		instance = this;

		position = ClientPreferences.chatPosition;
	}

	override function __enterFrame(deltaTime:Int)
	{
		if (!isOpen)
		{
			if (recentMessages.length > 0)
			{
				for (message in recentMessages)
				{
					message.updateTimer(deltaTime / 1000);
				}
			}

			super.__enterFrame(deltaTime);
			return;
		}

		// delay the chat openning and closing for 1 frame
		if (InputManager.controlsP1.CHAT)
		{
			isOpen = !isOpen;
		}
	}

	public function sendLocally(message:String) {}

	public function sendGlobally(message:String) {}
}
