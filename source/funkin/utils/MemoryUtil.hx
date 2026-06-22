package funkin.utils;

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
	 * @return The total amount of memory the application is using.
	 */
	public static function getProcessMemory():Float
	{
		#if (windows && cpp)
		return funkin.external.windows.WindowsAPI.getProcessMemory();
		#elseif ((macos || ios) && cpp)
		return funkin.external.apple.AppleAPI.getProcessMemory();
		#elseif (linux || android)
		try
		{
			#if cpp
			final input:sys.io.FileInput = sys.io.File.read('/proc/${cpp.NativeSys.sys_get_pid()}/status', false);
			#else
			final input:sys.io.FileInput = sys.io.File.read('/proc/self/status', false);
			#end

			final regex:EReg = ~/^VmRSS:\s+(\d+)\s+kB/m;
			var line:String;
			do
			{
				if (input.eof())
				{
					input.close();
					return 0.0;
				}

				line = input.readLine();
			}
			while (!regex.match(line));

			input.close();

			final kb:Float = Std.parseFloat(regex.matched(1));

			if (!Math.isNaN(kb))
			{
				return kb * 1024.0;
			}
		}
		catch (e:Dynamic) {}
		#end

		return 0;
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
}
