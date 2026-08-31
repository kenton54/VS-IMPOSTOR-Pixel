package funkin.graphics.text;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;

/**
 * A `FunkinBitmapText` with the Gameboy font preloaded into it.
 */
class GameboyText extends FunkinBitmapText
{
	/**
	 * All the glyphs this font uses.
	 */
  // TODO: make this cleaner
	static final glyphs:String = ' !"#%&\'()*+.-,/0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`{|}~¡¨¯´¸¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝŸ';

	public function new(x:Float = 0, y:Float = 0, text:String = '', size:Int = 12)
	{
		super(x, y, text, size, FlxBitmapFont.fromMonospace(Paths.font('gameboy.png'), glyphs, FlxPoint.get(8, 10)));
		letterSpacing = -1;
	}

	override function set_text(value:UnicodeString):UnicodeString
	{
		super.set_text(value);
		text = text.toUpperCase();
		return value;
	}
}
