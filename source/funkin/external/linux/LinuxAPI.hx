package funkin.external.linux;

#if linux
/**
 * Functions that run exclusively on Linux distros.
 */
@:cppFileCode('
#include <iostream>
#include <string>
')
class LinuxAPI {}
#end
