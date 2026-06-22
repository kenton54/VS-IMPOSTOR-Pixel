package funkin.external.apple;

#if (macos || ios)
/**
 * Functions that run exclusively on Apple devices.
 */
@:cppFileCode('
#include <CoreFoundation/CoreFoundation.h>
#include <mach/mach.h>
#include <iostream>
#include <string>
')
class AppleAPI
{
	/**
	 * @return The amount of memory the application is using.
	 */
	@:functionCode('
	struct task_basic_info info;

	mach_msg_type_number_t count = TASK_BASIC_INFO_COUNT;

	if (task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &count) != KERN_SUCCESS)
		return 0;

	return info.resident_size;
	')
	public static function getProcessMemory():Float
	{
		return 0;
	}
}
#end
