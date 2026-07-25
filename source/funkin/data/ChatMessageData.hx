package funkin.data;

class ChatMessageData
{
	@:noCompletion static var idEnumerator:Int = 0;

	/**
	 * The unique ID of the chat message.
	 */
	@:alias('id')
	public var ID:Int = idEnumerator++;

	/**
	 * The user that sent the message.
	 */
	public var owner:Null<String>;

	/**
	 * The full message that was sent.
	 */
	public var message:String;

	/**
	 * The color of the message.
	 */
	public var color:FlxColor;

	public function new(message:String, ?owner:String, ?color:FlxColor = FlxColor.WHITE)
	{
		this.message = message;
		this.owner = owner;
		this.color = color;
	}
}
