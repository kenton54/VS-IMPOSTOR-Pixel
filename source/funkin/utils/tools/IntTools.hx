package funkin.utils.tools;

/**
 * Utilities for Integers.
 */
class IntTools
{
	/**
	 * Limits the integer to the specified bounds.
	 *
	 * @param value The Integer to bound.
	 * @param min 	The minimum allowed value.
	 * @param max 	The maximum allowed value.
	 * @return The bounded value.
	 */
	public static function clamp(value:Int, min:Int, max:Int):Int
	{
		return value < min ? min : (value > max ? max : value);
	}
}
