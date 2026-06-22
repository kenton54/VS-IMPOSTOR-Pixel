package funkin.external.android;

#if android
import extension.androidtools.jni.JNICache;

import lime.math.Rectangle;
import lime.system.JNI;

/**
 * Functions that run exclusively on Android devices.
 */
class AndroidAPI
{
	/**
	 * @return The user's current language in the Language Code format (e.g. `en-US`).
	 */
	public static function getUserLanguage():String
	{
		var getDefault:Void -> Dynamic = JNICache.createStaticMethod('java/util/Locale', 'getDefault', '()Ljava/util/Locale;');
		var toString:Dynamic -> String = JNICache.createMemberMethod('java/util/Locale', 'toString', '()Ljava/lang/String;');

		if (getDefault != null && toString != null)
		{
			return toString(getDefault());
		}

		return 'en-US';
	}

	/**
	 * Retrieves the dimentions of display cutouts (such as notches).
	 * @return An array of `Rectangle` objects, each representing a display cutout's position and size.
	 */
	public static function getCutoutDimensions():Array<Rectangle>
	{
		final getCutoutDimensionsJNI:Null<Dynamic> = JNICache.createStaticMethod('funkin/util/ScreenUtil', 'getCutoutDimensions', '()[Landroid/graphics/Rect;');

		if (getCutoutDimensionsJNI != null)
		{
			final rectangles:Array<Rectangle> = [];

			for (rectangle in cast(getCutoutDimensionsJNI(), Array<Dynamic>))
			{
				if (rectangle == null)
				{
					continue;
				}

				final topJNI:Null<JNIMemberField> = JNICache.createMemberField('android/graphics/Rect', 'top', 'I');
				final leftJNI:Null<JNIMemberField> = JNICache.createMemberField('android/graphics/Rect', 'left', 'I');
				final rightJNI:Null<JNIMemberField> = JNICache.createMemberField('android/graphics/Rect', 'right', 'I');
				final bottomJNI:Null<JNIMemberField> = JNICache.createMemberField('android/graphics/Rect', 'bottom', 'I');

				if (topJNI != null && leftJNI != null && rightJNI != null && bottomJNI != null)
				{
					final top:Int = topJNI.get(rectangle);
					final left:Int = leftJNI.get(rectangle);
					final right:Int = rightJNI.get(rectangle);
					final bottom:Int = bottomJNI.get(rectangle);

					rectangles.push(new Rectangle(left, top, right - left, bottom - top));
				}
			}

			return rectangles;
		}

		return [];
	}

	/**
	 * @return Whether a keyboard is connected or not.
	 */
	public static function isKeyboardConnected():Bool
	{
		var isConnectedJNI:Null<Void -> Bool> = JNICache.createStaticMethod('funkin/util/KeyboardUtil', 'isKeyboardConnected', '()Z');

		if (isConnectedJNI != null)
		{
			return isConnectedJNI();
		}

		return false;
	}
}
#end
