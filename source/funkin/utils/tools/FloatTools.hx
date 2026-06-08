package funkin.utils.tools;

/**
 * Utilities for Floats.
 */
class FloatTools
{
	/**
	 * Limits the Float to the specified bounds.
	 *
	 * @param value The Float to bound.
	 * @param min 	The minimum allowed value.
	 * @param max 	The maximum allowed value.
	 * @return The bounded Float.
	 */
	public static function clamp(value:Float, ?min:Float, ?max:Float):Float
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
