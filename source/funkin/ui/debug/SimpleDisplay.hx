package funkin.ui.debug;

import flixel.util.FlxStringUtil;

import funkin.utils.MemoryUtil;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * Shows information about the frame rate and garbage collector memory.
 */
class SimpleDisplay extends Sprite
{
	public var currentFPS(get, never):Int;

	var fpsText:TextField;
	var memoryText:TextField;

	var fps(default, set):Int;

	var times:Array<Float> = [];
	var currentTime:Float = 0;

	var updateTimer:Int = 0;

	public function new(x:Float = 0, y:Float = 0)
	{
		super();

		this.x = x;
		this.y = y;

		fpsText = new TextField();
		fpsText.width = 300;
		fpsText.height = 40;
		fpsText.selectable = false;
		fpsText.mouseEnabled = false;
		fpsText.defaultTextFormat = new TextFormat(Constants.DEFAULT_FONT, 26, 0xFFFFFF);
		fpsText.text = 'FPS: 0';
		addChild(fpsText);

		memoryText = new TextField();
		memoryText.y = 34;
		memoryText.width = 400;
		memoryText.height = 20;
		memoryText.selectable = false;
		memoryText.mouseEnabled = false;
		memoryText.defaultTextFormat = new TextFormat(Constants.DEFAULT_FONT, 15, 0xFFFFFF);
		addChild(memoryText);

		#if web
		memoryText.visible = false;
		#else
		memoryText.text = 'Memory: ${FlxStringUtil.formatBytes(0)}';
		#end
	}

	override function __enterFrame(deltaTime:Int)
	{
		currentTime += deltaTime / 1000;
		times.push(currentTime);

		while (times[0] < currentTime - 1)
		{
			times.shift();
		}

		fps = times.length;

		if (!visible)
		{
			return;
		}

		updateTimer += deltaTime;

		if (updateTimer < Constants.DEBUG_OVERLAY_UPDATE_FREQUENCY)
		{
			return;
		}

		#if !web
		memoryText.text = 'Memory: ${FlxStringUtil.formatBytes(MemoryUtil.getGCMemory())}';
		#end

		updateTimer = 0;

		super.__enterFrame(deltaTime);
	}

	function get_currentFPS():Int
	{
		return fps;
	}

	function set_fps(value:Int):Int
	{
		if (value == fps)
		{
			return value;
		}

		fps = value;

		if (visible)
		{
			updateFPSDisplay(fps);
		}

		return fps;
	}

	function updateFPSDisplay(curFPS:Int)
	{
		fpsText.text = 'FPS: $curFPS';

		if (curFPS < 10)
		{
			fpsText.textColor = 0xFF0000;
		}
		if (curFPS < 30)
		{
			fpsText.textColor = 0xFF8800;
		}
		else if (curFPS < 60)
		{
			fpsText.textColor = 0xFFFF00;
		}
		else
		{
			fpsText.textColor = 0xFFFFFF;
		}
	}
}
