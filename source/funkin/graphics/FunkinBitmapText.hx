package funkin.graphics;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class FunkinBitmapText extends FlxBitmapText
{
	/**
	 * The size of the text in pixels.
	 */
	public var size(default, set):Int;

	/**
	 * The translation ID this text object follows, so whenever you change the language the text can update accordingly.
	 *
	 * If `null` (which is the default value), the text won't follow any translation ID, so you can put whatever text you want.
	 */
	public var translationData(default, set):Null<TranslationData>;

	/**
	 * The actual size of the text.
	 */
	var _sizeCalc:Float = 0;

	/**
	 * Constructs a new text field component.
	 *
	 * @param x     The horizontal position of the text object.
	 * @param y     The vertical position of the text object.
	 * @param text  The text to display.
	 * @param font  The `FlxBitmapFont` to use.
	 */
	public function new(x:Float = 0, y:Float = 0, text:UnicodeString = '', size:Int = 12, ?font:FlxBitmapFont)
	{
		super(x, y, text, font);
		translationData = null;
		set_size(size);
	}

	override public function clone():FunkinBitmapText
	{
		var bitmapText:FunkinBitmapText = new FunkinBitmapText(0, 0, text, size, font);
		bitmapText.fieldWidth = fieldWidth;
		bitmapText.translationData = translationData;
		bitmapText.alignment = alignment;
		bitmapText.wrap = wrap;
		bitmapText.lineSpacing = lineSpacing;
		bitmapText.letterSpacing = letterSpacing;
		bitmapText.padding = padding;
		bitmapText.textColor = textColor;
		bitmapText.borderStyle = borderStyle;
		bitmapText.borderColor = borderColor;
		bitmapText.borderSize = borderSize;
		bitmapText.borderQuality = borderQuality;
		bitmapText.background = background;
		bitmapText.backgroundColor = backgroundColor;
		return bitmapText;
	}

	function set_size(value:Int):Int
	{
		if (size != value)
		{
			size = value;

			_sizeCalc = value / lineHeight;
			scale.set(_sizeCalc, _sizeCalc);
			updateHitbox();
			pendingTextBitmapChange = true;
		}

		return value;
	}

	function set_translationData(data:Null<TranslationData>):Null<TranslationData>
	{
		translationData = data;

		if (translationData != null)
		{
			set_text('');
		}

		pendingTextBitmapChange = true;

		return data;
	}

	override function set_text(value:UnicodeString):UnicodeString
	{
		if (translationData != null)
		{
			text = Translations.translate(translationData.id, translationData.parameters);
			pendingTextChange = true;
		}
		else
		{
			super.set_text(value);
		}

		return value;
	}

	override function set_fieldWidth(value:Int):Int
	{
		super.set_fieldWidth(value);
		width = fieldWidth;
		return value;
	}
}
