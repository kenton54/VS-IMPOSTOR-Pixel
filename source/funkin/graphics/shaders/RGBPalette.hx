package funkin.graphics.shaders;

class RGBPalette
{
	/**
	 * The shader the palette uses.
	 *
	 * Used to properly replace the color of each color channel of the assigned sprite.
	 */
	public var shader(default, null):RGBPaletteShader;

	/**
	 * The red channel of the palette.
	 */
	public var red(default, set):FlxColor;

	/**
	 * The green channel of the palette.
	 */
	public var green(default, set):FlxColor;

	/**
	 * The blue channel of the palette.
	 */
	public var blue(default, set):FlxColor;

	/**
	 * How much to multiply the values of each channel.
	 */
	public var multiplier(default, set):Float;

	function set_red(value:FlxColor):FlxColor
	{
		this.red = value;
		shader.r.value = [value.redFloat, value.greenFloat, value.blueFloat];
		return value;
	}

	function set_green(value:FlxColor):FlxColor
	{
		this.green = value;
		shader.g.value = [value.redFloat, value.greenFloat, value.blueFloat];
		return value;
	}

	function set_blue(value:FlxColor):FlxColor
	{
		this.blue = value;
		shader.b.value = [value.redFloat, value.greenFloat, value.blueFloat];
		return value;
	}

	function set_multiplier(value:Float):Float
	{
		this.multiplier = value;
		shader.mult.value = [value];
		return value;
	}

	public function new(?red:FlxColor, ?green:FlxColor, ?blue:FlxColor)
	{
		this.shader = new RGBPaletteShader();

		this.red = red;
		this.green = green;
		this.blue = blue;

		this.multiplier = 1.0;
	}
}

class RGBPaletteShader extends flixel.graphics.tile.FlxGraphicsShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec3 r;
		uniform vec3 g;
		uniform vec3 b;
		uniform float mult;

		vec4 flixel_texture2DCustom(sampler2D bitmap, vec2 coord)
		{
				vec4 color = flixel_texture2D(bitmap, coord);
				if (!hasTransform || color.a == 0.0 || mult == 0.0) {
						return color;
				}

				vec4 newColor = color;
				newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
				newColor.a = color.a;

				color = mix(color, newColor, mult);

				if(color.a > 0.0) {
						return vec4(color.rgb, color.a);
				}
				return vec4(0.0, 0.0, 0.0, 0.0);
		}

		void main()
		{
				gl_FragColor = flixel_texture2DCustom(bitmap, openfl_TextureCoordv);
		}
	')
	public function new()
	{
		super();
	}
}
