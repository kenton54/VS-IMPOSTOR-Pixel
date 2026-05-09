package funkin.ui.debug.advanced;

import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * Shows information about the frame rate.
 */
class Framerate extends DebugCategory
{
	/**
	 * The frame rate the game is currently running at.
	 */
	public var currentFPS(get, never):Int;

	var mainFPSText:TextField;
	var othersFPSText:TextField;

	var fps(default, set):Int;
	var avgFps:Int = 0;
	var lowFps:Int = 0;

	var times:Array<Float> = [];
	var currentTime:Float = 0;

	public function new(backgroundColor:Int)
	{
		super(null, 220, 82, backgroundColor);

		othersFPSText = createTextField();
		othersFPSText.y = 38;
		addChild(othersFPSText);

		mainFPSText = new TextField();
		mainFPSText.x = 8;
		mainFPSText.y = 2;
		mainFPSText.width = overlayWidth - 16;
		mainFPSText.height = overlayHeight;
		mainFPSText.selectable = false;
		mainFPSText.mouseEnabled = false;
		mainFPSText.defaultTextFormat = new TextFormat(Constants.DEFAULT_FONT, 28, 0xFFFFFF, null, null, null, null, null, getTextAlignFromCategoryAlignment());
		addChild(mainFPSText);

		fps = 0;
	}

	override function update(deltaTime:Float)
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1)
		{
			times.shift();
		}

		fps = times.length;

		final otherCounters:Array<String> = [];
		otherCounters.push('Average FPS: $avgFps');
		otherCounters.push('Lowest FPS: $lowFps');

		othersFPSText.text = otherCounters.join('\n');
	}

	function get_currentFPS():Int
	{
		return fps;
	}

	function set_fps(value:Int):Int
	{
		fps = value;
		mainFPSText.text = 'FPS: $fps';

		if (fps < 10)
		{
			mainFPSText.textColor = 0xFF0000;
		}
		if (fps < 30)
		{
			mainFPSText.textColor = 0xFF8800;
		}
		else if (fps < 60)
		{
			mainFPSText.textColor = 0xFFFF00;
		}
		else
		{
			mainFPSText.textColor = 0xFFFFFF;
		}

		return fps;
	}
}
