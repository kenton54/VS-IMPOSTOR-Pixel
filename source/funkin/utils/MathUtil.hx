package funkin.utils;

/**
 * Helper math functions.
 */
class MathUtil
{
	/**
	 * Gets the distance between 2 integer values.
	 *
	 * @param intA The main integer value.
	 * @param intB The other integer value.
	 * @return The distance between the 2 values.
	 */
	public static function distanceBetweenIntegers(intA:Int, intB:Int):Int
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
	public static function distanceBetweenFloats(floatA:Float, floatB:Float):Float
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
	public static function distanceBetweenPoints(pointA:openfl.geom.Point, pointB:openfl.geom.Point):Float
	{
		var dx:Float = pointB.x - pointA.x;
		var dy:Float = pointB.y - pointA.y;
		return FlxMath.vectorLength(dx, dy);
	}
}
