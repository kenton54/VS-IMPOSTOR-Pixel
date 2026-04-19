package funkin.utils.tools;

/**
 * Utilities for Integers.
 */
class IntTools
{
	/**
	 * Limits the Integer to the specified bounds.
	 *
	 * @param value The Integer to bound.
	 * @param min 	The minimum allowed value.
	 * @param max 	The maximum allowed value.
	 * @return The bounded Integer.
	 */
	public static function clamp(value:Int, ?min:Int, ?max:Int):Int
	{
		if (min != null)
		{
			if (value < min)
			{
				value = min;
			}
		}

		if (max != null)
		{
			if (value > max)
			{
				value = max;
			}
		}

		return value;
	}
}
