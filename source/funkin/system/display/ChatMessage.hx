package funkin.system.display;

import flixel.text.FlxText;

import funkin.data.ChatMessageData;
import funkin.data.ClientPreferences;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

@:access(flixel.text.FlxText)
class ChatMessage extends Sprite
{
	public var background:Bitmap;

	public var textField(default, null):TextField;

	public var displayTimer:Float = 0;

	var finished:Bool = false;

	public function new(data:ChatMessageData, bgWidth:Int = 100)
	{
		super();

		background = new Bitmap(new BitmapData(1, 1, true, FlxColor.BLACK));
		background.width = bgWidth;
		addChild(background);

		var fullMessage:String = data.owner != null ? '<${data.owner}> ${data.message}' : data.message;
		var format:TextFormat = new TextFormat('_sans');

		textField = new TextField();
		textField.embedFonts = true;
		textField.defaultTextFormat = format;
		textField.text = fullMessage;
		textField.x = textField.y = FlxText.VERTICAL_GUTTER;
		textField.width = bgWidth - FlxText.VERTICAL_GUTTER * 2;
		textField.selectable = false;
		textField.mouseEnabled = false;
		addChild(textField);

		background.height = textField.textHeight + FlxText.VERTICAL_GUTTER;
	}

	public function updateTimerAmbiguous(elapsed:Float):Bool
	{
		if (finished)
		{
			return false;
		}

		displayTimer += elapsed;

		if (displayTimer >= ClientPreferences.chatMessageDisplayTime)
		{
			finished = true;
		}

		return true;
	}

	public function updateTimer(elapsed:Float)
	{
		if (!updateTimerAmbiguous(elapsed))
		{
			return;
		}

		var vanishTime:Float = ClientPreferences.chatMessageDisplayTime - 1.0;
		if (displayTimer >= vanishTime)
		{
			this.alpha = ClientPreferences.chatMessageDisplayTime - vanishTime;
		}
	}
}
