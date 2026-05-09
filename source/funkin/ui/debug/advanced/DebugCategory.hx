package funkin.ui.debug.advanced;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class DebugCategory extends Sprite
{
	public var overlayWidth(default, set):Float;
	public var overlayHeight(default, set):Float;

	/**
	 * How much vertical offset should this category be drawn with.
	 */
	public var verticalOffset:Float = 0;

	var alignment:CategoryAlignment = TOP_LEFT;

	public var title(default, null):TextField;
	public var background(default, null):Shape;

	public function new(?title:String, width:Float, height:Float, backgroundColor:Int, alignment:CategoryAlignment = TOP_LEFT)
	{
		super();

		this.alignment = alignment;

		background = new Shape();
		background.graphics.beginFill(backgroundColor, 0.6);
		background.graphics.drawRect(0, 0, 1, 1);
		background.graphics.endFill();
		addChild(background);

		overlayWidth = width;
		overlayHeight = height;

		if (title != null)
		{
			this.title = new TextField();
			this.title.text = title;
			this.title.x = 8;
			this.title.y = 2;
			this.title.width = background.width - 16;
			this.title.height = background.height;
			this.title.selectable = false;
			this.title.mouseEnabled = false;
			this.title.defaultTextFormat = new TextFormat(Constants.DEFAULT_FONT, 12, 0xAAAAAA, null, null, null, null, null, getTextAlignFromCategoryAlignment());
			addChild(this.title);
		}
	}

	/**
	 * Creates a `TextField` for use within the category. Useful as a shortcut.
	 * @return The `TextField` instance.
	 */
	public function createTextField():TextField
	{
		var textField:TextField = new TextField();
		textField.x = 8;
		textField.y = 18;
		textField.width = overlayWidth - 16;
		textField.height = overlayHeight;
		textField.selectable = false;
		textField.mouseEnabled = false;
		textField.defaultTextFormat = new TextFormat(Constants.DEFAULT_FONT, 15, 0xFFFFFF, null, null, null, null, null, getTextAlignFromCategoryAlignment());
		return textField;
	}

	@:allow(funkin.ui.debug.DebugOverlay)
	final function updatePosition()
	{
		switch (alignment)
		{
			case TOP_LEFT:
				x = 0;
				y = verticalOffset;
			case TOP_RIGHT:
				x = FlxG.stage.stageWidth - overlayWidth;
				y = verticalOffset;
			case BOTTOM_LEFT:
				x = 0;
				y = FlxG.stage.stageHeight - overlayHeight - verticalOffset;
			case BOTTOM_RIGHT:
				x = FlxG.stage.stageWidth - overlayWidth;
				y = FlxG.stage.stageHeight - overlayHeight - verticalOffset;
		}
	}

	@:allow(funkin.ui.debug.DebugOverlay)
	function update(deltaTime:Float) {}

	@:allow(funkin.ui.debug.DebugOverlay)
	function postUpdate() {}

	function getTextAlignFromCategoryAlignment():TextFormatAlign
	{
		return switch (alignment)
		{
			case TOP_LEFT, BOTTOM_LEFT: TextFormatAlign.LEFT;
			case TOP_RIGHT, BOTTOM_RIGHT: TextFormatAlign.RIGHT;
		}
	}

	function set_overlayWidth(value:Float):Float
	{
		// value += title.textWidth;

		overlayWidth = background.width = value;

		if (title != null)
		{
			title.width = value - 16;
		}

		return value;
	}

	function set_overlayHeight(value:Float):Float
	{
		// value += title.textHeight;

		overlayHeight = background.height = value;

		if (title != null)
		{
			title.height = value;
		}

		return value;
	}
}

enum abstract CategoryAlignment(String) from String to String
{
	/**
	 * Aligns the category to the top left of the window.
	 */
	var TOP_LEFT = 'topLeft';

	/**
	 * Aligns the category to the top right of the window.
	 */
	var TOP_RIGHT = 'topRight';

	/**
	 * Aligns the category to the bottom left of the window.
	 */
	var BOTTOM_LEFT = 'bottomLeft';

	/**
	 * Aligns the category to the bottom right of the window.
	 */
	var BOTTOM_RIGHT = 'bottomRight';
}
