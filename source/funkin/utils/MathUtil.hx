package funkin.utils;

/**
 * Helper math functions.
 */
class MathUtil
{
	/**
	 * The value of the mathematical constant E.
	 */
	public inline static var EULER:Float = 2.718281828459045;

	/**
	 * Calculates the sine of `v`.
	 *
	 * The result is dependant on the user's preferences.
	 *
	 * If `lowDetail` is enabled, it returns a less precise value, but it's faster to calculate.
	 *
	 * Converts `v` to radians automatically.
	 *
	 * @param v The angle, in degrees.
	 * @return The sine of `v`.
	 */
	public static function sin(v:Float):Float
	{
		var rad:Float = v * flixel.math.FlxAngle.TO_RAD;

		if (funkin.data.ClientPreferences.lowDetail)
		{
			return FlxMath.fastSin(rad);
		}
		else
		{
			return Math.sin(rad);
		}
	}

	/**
	 * Calculates the cosine of `v`.
	 *
	 * The result is dependant on the user's preferences.
	 *
	 * If `lowDetail` is enabled, it returns a less precise value, but it's faster to calculate.
	 *
	 * Converts `v` to radians automatically.
	 *
	 * @param v The angle, in degrees.
	 * @return The cosine of `v`.
	 */
	public static function cos(v:Float):Float
	{
		var rad:Float = v * flixel.math.FlxAngle.TO_RAD;

		if (funkin.data.ClientPreferences.lowDetail)
		{
			return FlxMath.fastCos(rad);
		}
		else
		{
			return Math.cos(rad);
		}
	}

	/**
	 * @param v Input value.
	 * @return The factorial of `v`.
	 */
	public static function fact(v:Float):Float
	{
		return v <= 0 ? 1 : v * fact(v - 1);
	}

	/**
	 * @param v Input value.
	 * @return The fractional of `v`.
	 */
	public inline static function fract(v:Float):Float
	{
		return v - Math.floor(v);
	}

	/**
	 * Gets the distance between 2 integer values.
	 *
	 * @param intA The main integer value.
	 * @param intB The other integer value.
	 * @return The distance between the 2 values.
	 */
	public inline static function distanceBetweenIntegers(intA:Int, intB:Int):Int
	{
		return intB - intA;
	}

	/**
	 * Gets the distance between 2 float values.
	 *
	 * @param floatA The main float value.
	 * @param floatB The other float value.
	 * @return The distance between the 2 values.
	 */
	public inline static function distanceBetweenFloats(floatA:Float, floatB:Float):Float
	{
		return floatB - floatA;
	}

	/**
	 * Gets the distance between 2 `Point` objects.
	 *
	 * @param pointA The main point.
	 * @param pointB The other point.
	 * @return The distance between the 2 points.
	 */
	public inline static function distanceBetweenPoints(pointA:openfl.geom.Point, pointB:openfl.geom.Point):Float
	{
		var dx:Float = pointB.x - pointA.x;
		var dy:Float = pointB.y - pointA.y;
		return FlxMath.vectorLength(dx, dy);
	}

	/**
	 * GCD stands for "Great Common Divisor".
	 *
	 * @param a Value 1.
	 * @param b Value 2.
	 * @return The greatest common divisor between `a` and `b`.
	 */
	public static function gcd(a:Int, b:Int):Int
	{
		a = Math.floor(Math.abs(a));
		b = Math.floor(Math.abs(b));
		var t:Int;

		do
		{
			if (b == 0)
			{
				return a;
			}
			t = a;
			a = b;
			b = t % a;
		}
		while (true);
	}
}
