class RGBPalette {
    public static function convertColorToFloatArray(color:FlxColor):Array<Float> {
        var red:Float = ((color >> 16) & 0xFF) / 255;
        var green:Float = ((color >> 8) & 0xFF) / 255;
        var blue:Float = (color & 0xFF) / 255;

        return [red, green, blue];
    }

    public var shader(default, null):CustomShader;

    public var red(default, set):FlxColor;
    public var green(default, set):FlxColor;
    public var blue(default, set):FlxColor;

    public var multiplier(default, set):Float;

    function set_red(value:FlxColor):FlxColor {
        red = value;
        shader.r = RGBPalette.convertColorToFloatArray(value);
        return value;
    }

    function set_green(value:FlxColor):FlxColor {
        green = value;
        shader.g = RGBPalette.convertColorToFloatArray(value);
        return value;
    }

    function set_blue(value:FlxColor):FlxColor {
        blue = value;
        shader.b = RGBPalette.convertColorToFloatArray(value);
        return value;
    }

    function set_multiplier(value:Float):Float {
        multiplier = value;
        shader.mult = value;
        return value;
    }

    public function new(?red:FlxColor, ?green:FlxColor, ?blue:FlxColor) {
        this.shader = new CustomShader("rgbPalette");

        this.red = red;
        this.green = green;
        this.blue = blue;

        this.multiplier = 1;
    }
}