package funkin.system.logs;

import lime.app.Application;

import openfl.Lib;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;

/**
 * Manages crashes and facilitates debugging.
 */
final class CrashHandler
{
	static final CRASH_WINDOW_TITLE:String = '${Constants.TITLE} - Crash Handler';

	@:allow(Main)
	static function init()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onCriticalError);
		#elseif hl
		hl.Api.setErrorHandler(onCriticalError);
		#end
	}

	static function onUncaughtError(error:UncaughtErrorEvent)
	{
		try
		{
			showErrorPopUp(generateErrorMessage(error));
		}
		catch (e:Dynamic)
		{
			// crash handler crashes... wow
			trace('ERROR HANDLING THE CRASH: $e');
		}

		#if sys
		Sys.sleep(1);
		Lib.application.window.close();
		#end
	}

	static function onCriticalError(error:String)
	{
		trace('CRITICAL ERROR: $error');

		try
		{
			showErrorPopUp(error);
		}
		catch (e:Dynamic)
		{
			trace('ERROR HANDLING CRITICAL CRASH: $e');
		}

		#if sys
		Sys.sleep(1);
		Lib.application.window.close();
		#end
	}

	static function showErrorPopUp(error:String)
	{
		Application.current.window.alert(error, CRASH_WINDOW_TITLE);
	}

	static function generateErrorMessage(error:UncaughtErrorEvent):String
	{
		var errorMsg:String = '';
		var callStack:Array<haxe.CallStack.StackItem> = haxe.CallStack.exceptionStack(true); // for some reason importing "CallStack" doesnt work

		if (Std.isOfType(error.error, Error))
		{
			errorMsg = 'ERROR: ${cast (error.error, Error).message}\n\n';
		}
		else if (Std.isOfType(error.error, ErrorEvent))
		{
			errorMsg = 'ERROR: ${cast (error.error, ErrorEvent).text}\n\n';
		}
		else
		{
			errorMsg = 'ERROR: ${error.error}\n\n';
		}

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case CFunction:
					errorMsg += 'C Function';

				case Module(module):
					errorMsg += 'Module $module';

				case FilePos(stackItem, file, line, column):
					errorMsg += 'File: $file (Line #$line)';

					if (column != null)
					{
						errorMsg += ' (Column #$column)';
					}

				case Method(classname, method):
					errorMsg += '$classname.$method';

				case LocalFunction(value):
					errorMsg += 'Local Function $value';
			}

			errorMsg += '\n';
		}

		trace('\n$errorMsg');

		return errorMsg;
	}
}
