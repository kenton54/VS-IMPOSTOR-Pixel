public static function lerp(value1:Float, value2:Float, ratio:Float, ?fpsSensitive:Bool):Float {
    if (fpsSensitive == null) fpsSensitive = false;

    if (fpsSensitive)
        return FlxMath.lerp(value1, value2, ratio);
    else
        return CoolUtil.fpsLerp(value1, value2, ratio);
}

public static function distanceBetweenFloats(floatA:Float, floatB:Float):Float
    return floatB - floatA;

public static function distanceBetweenPoints(pointA:FlxPoint, pointB:FlxPoint):Float {
    var dx:Float = pointA.x - pointB.x;
    var dy:Float = pointA.y - pointB.y;
    return FlxMath.vectorLength(dx, dy);
}

public static function shuffleTable(table:Array<Dynamic>) {
    var maxValidIndex = table.length - 1;
    for (i in 0...maxValidIndex) {
        var j = FlxG.random.int(i, maxValidIndex);
        var tmp = table[i];
        table[i] = table[j];
        table[j] = tmp;
    }
}

public static function clamp(value:Float, min:Float, max:Float):Float {
    return Math.max(min, Math.min(max, value));
}