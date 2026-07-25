package funkin.graphics;

import flixel.text.FlxText;

class FunkinText extends FlxText
{
	/**
	 * Creates a `FlxTextFormat`.
	 *
	 * @param parameters The parameters you want the format to modify a `FlxText` or `FunkinText`.
	 * @return The `FlxTextFormat`.
	 */
	public static function createFormat(parameters:TextFormatParameters):FlxTextFormat
	{
		var textFormat:FlxTextFormat = new FlxTextFormat(parameters.color, parameters.bold, parameters.italic, parameters.borderColor, parameters.underline);
		@:privateAccess {
			textFormat.format.size = parameters.size;
			textFormat.format.font = FlxG.assets.getFont(Paths.font(parameters.font))?.fontName ?? Constants.DEFAULT_FONT;
			textFormat.format.align = FlxTextAlign.toOpenFL(parameters.alignment ?? LEFT);
			textFormat.format.strikethrough = parameters.strikethrough;
			textFormat.format.letterSpacing = parameters.letterSpacing;
		}
		textFormat.leading = parameters.leading;
		return textFormat;
	}

	/**
	 * The translation ID this text object follows, so whenever you change the language the text can update accordingly.
	 *
	 * If `null` (which is the default value), the text won't follow any translation ID, so you can put whatever text you want.
	 */
	public var translationData(default, set):Null<funkin.system.Translations.TranslationData>;

	/**
	 * Whether to use striked-through text or not (`false` by default).
	 */
	public var strikethrough(get, set):Bool;

	/**
	 * The amount of space between each text line, in pixels.
	 */
	public var leading(get, set):Int;

	/**
	 * Creates a new `FunkinText`.
	 *
	 * @param x             The horizontal position of the text.
	 * @param y             The vertical position of the text.
	 * @param fieldWidth    The width of the text. Enables `autoSize` if `0` or below.
	 * @param text          The text you want the text object to display.
	 * @param size          The font size of the text.
	 * @param useBorders    Whether to render borders for the text.
	 */
	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, text:String = '', size:Int = 12, useBorders:Bool = false)
	{
		super(x, y, fieldWidth, text);

		setFormat(Constants.DEFAULT_FONT, size, 0xFFFFFFFF);
		translationData = null;

		if (useBorders)
		{
			borderStyle = OUTLINE;
			borderSize = 1.2;
			borderColor = 0xFF000000;
		}
	}

	override public function destroy()
	{
		super.destroy();
	}

	override public function clone():FunkinText
	{
		var text:FunkinText = new FunkinText(0, 0, fieldWidth, text, size);
		text.fieldHeight = fieldHeight;
		text.translationData = translationData;
		text._defaultFormat = _defaultFormat;
		text._formatRanges = _formatRanges;
		text.borderStyle = borderStyle;
		text.borderColor = borderColor;
		text.borderSize = borderSize;
		text.borderQuality = borderQuality;
		return text;
	}

	function set_translationData(data:Null<funkin.system.Translations.TranslationData>):Null<funkin.system.Translations.TranslationData>
	{
		translationData = data;

		if (translationData != null)
		{
			set_text('');
		}

		return data;
	}

	override function set_text(text:String):String
	{
		if (translationData != null)
		{
			text = funkin.system.Translations.translate(translationData.id, translationData.parameters);

			if (textField != null)
			{
				var oldText:String = textField.text;
				textField.text = text;
				_regen = (textField.text != oldText) || _regen;
			}
		}
		else
		{
			super.set_text(text);
		}

		return text;
	}

	function get_strikethrough():Bool
	{
		return _defaultFormat.strikethrough;
	}

	function set_strikethrough(value:Bool):Bool
	{
		if (_defaultFormat.strikethrough != value)
		{
			_defaultFormat.strikethrough = value;
			updateDefaultFormat();
		}
		return value;
	}

	function get_leading():Int
	{
		return _defaultFormat.leading;
	}

	function set_leading(value:Int):Int
	{
		if (_defaultFormat.leading != value)
		{
			_defaultFormat.leading = value;
			updateDefaultFormat();
		}
		return value;
	}
}

/**
 * Parameters to use when creating a `FlxTextFormat` from the static method `createFormat`.
 */
typedef TextFormatParameters =
{
	/**
	 * The text's size.
	 */
	var ?size:Int;

	/**
	 * The text's color.
	 */
	var ?color:Int;

	/**
	 * The text border's color.
	 */
	var ?borderColor:Int;

	/**
	 * The text's font.
	 */
	var ?font:String;

	/**
	 * Makes the text stand out more (needs to be supported by the desired font to properly apply).
	 */
	var ?bold:Bool;

	/**
	 * Makes the text skew sideways (needs to be supported by the desired font to properly apply).
	 */
	var ?italic:Bool;

	/**
	 * Makes a line appear below the text.
	 */
	var ?underline:Bool;

	/**
	 * Makes a line appear on top the text.
	 */
	var ?strikethrough:Bool;

	/**
	 * Where the text should align to.
	 */
	var ?alignment:FlxTextAlign;

	/**
	 * The amount of space between text lines, in pixels.
	 */
	var ?leading:Int;

	/**
	 * How much space is there between each text letter, number and/or symbol.
	 */
	var ?letterSpacing:Float;
}
