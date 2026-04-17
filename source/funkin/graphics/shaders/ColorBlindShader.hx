package funkin.graphics.shaders;

import funkin.data.ClientPreferences.ColorBlindMode;

import openfl.filters.ColorMatrixFilter;

class ColorBlindShader
{
	/**
	 * The current active colorblind mode.
	 */
	public static var currentMode(default, null):Null<ColorBlindMode> = null;

	/**
	 * Normal vision.
	 */
	static var noneMatrix:Array<Float> = [
		1, 0, 0, 0, 0,
		0, 1, 0, 0, 0,
		0, 0, 1, 0, 0,
		0, 0, 0, 1, 0
	];

	/**
	 * Red-weak.
	 */
	static var protanomalyMatrix:Array<Float> = [
		 0.817, 0.333, -0.15, 0, 0,
		 0.333, 0.667,     0, 0, 0,
		-0.017,     0, 1.017, 0, 0,
		     0,     0,     0, 1, 0
	];

	/**
	 * Red-blind.
	 */
	static var protanopiaMatrix:Array<Float> = [
		 0.152,  1.053, -0.205, 0, 0,
		 0.115,  0.786,  0.099, 0, 0,
		-0.004, -0.048,  1.052, 0, 0,
		     0,      0,      0, 1, 0
	];

	/**
	 * Green-weak.
	 */
	static var deuteranomalyMatrix:Array<Float> = [
		  0.8,   0.2,     0, 0, 0,
		0.258, 0.742,     0, 0, 0,
		    0, 0.142, 0.858, 0, 0,
		    0,     0,     0, 1, 0
	];

	/**
	 * Green-blind.
	 */
	static var deuteranopiaMatrix:Array<Float> = [
		 0.43, 0.72, -0.15, 0, 0,
		 0.34, 0.57,  0.09, 0, 0,
		-0.02, 0.01,  1.01, 0, 0,
		    0,    0,     0, 1, 0
	];

	/**
	 * Blue-weak.
	 */
	static var tritanomalyMatrix:Array<Float> = [
		0.967, 0.033,     0, 0, 0,
		    0, 0.733, 0.267, 0, 0,
		    0, 0.183, 0.817, 0, 0,
		    0,     0,     0, 1, 0
	];

	/**
	 * Blue-blind.
	 */
	static var tritanopiaMatrix:Array<Float> = [
		 1.256, -0.077, -0.179, 0, 0,
		-0.078,  0.931,  0.148, 0, 0,
		 0.005,  0.691,  0.304, 0, 0,
		     0,      0,      0, 1, 0
	];

	static var colorBlindShader:ColorMatrixFilter;

	/**
	 * Updates the active colorblind shader depending on the specified colorblind mode.
	 *
	 * @param mode The colorblind mode.
	 */
	public static function updateShader(mode:ColorBlindMode)
	{
		if (currentMode != null && mode != null && mode == currentMode)
		{
			return;
		}

		var colorMatrix:Array<Float> = switch (mode)
		{
			case DEUTERANOMALY:
				deuteranomalyMatrix;

			case PROTANOMALY:
				protanomalyMatrix;

			case PROTANOPIA:
				protanopiaMatrix;

			case DEUTERANOPIA:
				deuteranopiaMatrix;

			case TRITANOPIA:
				tritanopiaMatrix;

			case TRITANOMALY:
				tritanomalyMatrix;

			default:
				noneMatrix;
		}

		if (colorBlindShader == null)
		{
			colorBlindShader = new ColorMatrixFilter();
		}

		colorBlindShader.matrix = colorMatrix;

		if (FlxG.game.filters == null)
		{
			FlxG.game.filters = [colorBlindShader];
		}
		else
		{
			var lastValidIndex:Int = FlxG.game.filters.length - 1;

			if (!FlxG.game.filters.contains(colorBlindShader))
			{
				FlxG.game.filters.push(colorBlindShader);
			}
			else if (FlxG.game.filters[lastValidIndex] != colorBlindShader)
			{
				FlxG.game.filters.remove(colorBlindShader);
				FlxG.game.filters.push(colorBlindShader);
			}
		}

		currentMode = mode;
	}
}
