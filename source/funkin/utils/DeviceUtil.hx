package funkin.utils;

#if android
import funkin.external.android.AndroidAPI;
#elseif ios
import funkin.external.apple.AppleAPI;
#end

#if web
import js.Browser;
#end

import openfl.geom.Rectangle;

class DeviceUtil
{
	/**
	 * @return Whether the current device is a MacOS.
	 */
	public static function isMacOS():Bool
	{
		#if macos
		return true;
		#elseif web
		return Browser.window.navigator.platform.startsWith('Mac')
			|| Browser.window.navigator.platform.startsWith('iPad')
			|| Browser.window.navigator.platform.startsWith('iPhone');
		#else
		return false;
		#end
	}

	/**
	 * @return A `Rectangle` object that represents the dimensions of the device's screen notch. On non-mobile targets, it returns an empty `Rectangle`.
	 */
	public static function getNotchRect():Rectangle
	{
		var notchRect:Rectangle = new Rectangle();

		#if android
		final rectDimensions:Array<Array<Float>> = [[], [], [], []];

		for (rect in AndroidAPI.getCutoutDimensions())
		{
			rectDimensions[0].push(rect.x);
			rectDimensions[1].push(rect.y);
			rectDimensions[2].push(rect.width);
			rectDimensions[3].push(rect.height);
		}

		for (i => dimensions in rectDimensions)
		{
			for (dimension in dimensions)
			{
				switch (i)
				{
					case 0:
						notchRect.x += dimension;

					case 1:
						notchRect.y += dimension;

					case 2:
						notchRect.width += dimension;

					case 3:
						notchRect.height += dimension;
				}
			}
		}
		#elseif ios
		// TODO: ios notch rectangle
		#end

		return notchRect;
	}
}
