package funkin.utils;

import openfl.display.Graphics;
import openfl.text.TextField;
import openfl.text.TextLineMetrics;

class DrawUtil
{
	/**
	 * Draws a flat-color background using a text field object as reference.
	 *
	 * @param background  The `Graphics` object to draw the background over.
	 * @param textField   The `TextField` to use as reference.
	 * @param color       The color of the background.
	 */
	public static function drawTextFieldBackground(background:Graphics, textField:TextField, color:FlxColor)
	{
		background.beginFill(color);

		for (i in 0...textField.numLines)
		{
			var lineMetrics:TextLineMetrics = textField.getLineMetrics(i);
			var lineY:Float = lineMetrics.height * i + lineMetrics.leading + lineMetrics.descent;
			background.drawRect(lineMetrics.x, lineY, lineMetrics.width, lineMetrics.height);
		}

		background.endFill();
	}
}
