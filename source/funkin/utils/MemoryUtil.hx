package funkin.utils;

import openfl.display3D.Context3D;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

/**
 * Helper functions related to system memory.
 */
class MemoryUtil
{
	/**
	 * @return The amount of RAM the system has installed.
	 */
	public static function getSystemMemory():Float
	{
		return 0;
	}

	/**
	 * @return The total amount of memory the application is using.
	 */
	public static function getTaskMemory():Float
	{
		return 0;
	}

	/**
	 * @return The percentage of the amount of memory the application is using.
	 */
	public static function getRAMUsage():Float
	{
		return getTaskMemory() / getSystemMemory();
	}

	/**
	 * @return The amount of memory Haxe is using.
	 */
	public static function getGCMemory():Float
	{
		return openfl.system.System.totalMemoryNumber;
	}

	/**
	 * Enables garbage collection.
	 */
	public static function enableGC()
	{
		#if (cpp || hl)
		Gc.enable(true);
		#end
	}

	/**
	 * Disables garbage collection.
	 */
	public static function disableGC()
	{
		#if (cpp || hl)
		Gc.enable(false);
		#end
	}

	/**
	 * Manually performs garbage collection.
	 * @param major If `true`, will perform a major cleanup.
	 */
	public static function cleanGC(major:Bool = true)
	{
		#if cpp
		Gc.run(major);
		#elseif hl
		Gc.major();
		#end
	}

	public static function getGraphicsMemoryTotal():Int
	{
		return FlxG.stage.context3D.totalGPUMemory;
	}

	public static function getGraphicsMemoryUsage():Float
	{
		var vramBytes:Int = @:privateAccess FlxG.stage.context3D.gl.getParameter(Context3D.__glMemoryCurrentAvailable);
		return vramBytes;
	}

	public static function getVRAMUsage():Float
	{
		return getGraphicsMemoryUsage() / getGraphicsMemoryTotal();
	}
}
