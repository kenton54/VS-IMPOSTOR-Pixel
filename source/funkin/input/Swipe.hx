package funkin.input;

import flixel.input.FlxSwipe;

class Swipe
{
	/**
	 * Checks if the user is swiping leftwards.
	 */
	public static var swipeLeft(get, never):Bool;

	/**
	 * Checks if the user is swiping rightwards.
	 */
	public static var swipeRight(get, never):Bool;

	/**
	 * Checks if the user is swiping upwards.
	 */
	public static var swipeUp(get, never):Bool;

	/**
	 * Checks if the user is swiping downwards.
	 */
	public static var swipeDown(get, never):Bool;

	/**
	 * Checks if the user is swiping to any direction.
	 */
	public static var swipeAny(get, never):Bool;

	/**
	 * Checks if the user just swope leftwards.
	 */
	public static var justSwipedLeft(get, never):Bool;

	/**
	 * Checks if the user just swope rightwards.
	 */
	public static var justSwipedRight(get, never):Bool;

	/**
	 * Checks if the user just swope upwards.
	 */
	public static var justSwipedUp(get, never):Bool;

	/**
	 * Checks if the user just swope downwards.
	 */
	public static var justSwipedDown(get, never):Bool;

	/**
	 * Checks if the user just swope in any direction.
	 */
	public static var justSwipedAny(get, never):Bool;

	/**
	 * Checks if a leftwards flick has passed or not.
	 */
	public static var flickLeft(get, never):Bool;

	/**
	 * Checks if a rightwards flick has passed or not.
	 */
	public static var flickRight(get, never):Bool;

	/**
	 * Checks if an upwards flick has passed or not.
	 */
	public static var flickUp(get, never):Bool;

	/**
	 * Checks if a downwards flick has passed or not.
	 */
	public static var flickDown(get, never):Bool;

	/**
	 * Checks if a flick to any direction has passed or not.
	 */
	public static var flickAny(get, never):Bool;

	/**
	 * Stops any current flick.
	 */
	public static function resetVelocity()
	{
		FlxG.touches.flickManager.destroy();
		FlxG.mouse.flickManager.destroy();
	}

	static function get_swipeLeft():Bool
	{
		#if mobile
		return Pointer.pointer?.justMovedLeft ?? false;
		#else
		return FlxG.mouse.justMovedLeft && Pointer.pressed;
		#end
	}

	static function get_swipeRight():Bool
	{
		#if mobile
		return Pointer.pointer?.justMovedRight ?? false;
		#else
		return FlxG.mouse.justMovedRight && Pointer.pressed;
		#end
	}

	static function get_swipeUp():Bool
	{
		#if mobile
		return Pointer.pointer?.justMovedUp ?? false;
		#else
		return FlxG.mouse.justMovedUp && Pointer.pressed;
		#end
	}

	static function get_swipeDown():Bool
	{
		#if mobile
		return Pointer.pointer?.justMovedDown ?? false;
		#else
		return FlxG.mouse.justMovedDown && Pointer.pressed;
		#end
	}

	static function get_swipeAny():Bool
	{
		return swipeLeft || swipeRight || swipeUp || swipeDown;
	}

	static function get_justSwipedLeft():Bool
	{
		final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
		return swipe?.degrees > 135 || swipe?.degrees < -135 && swipe?.distance > 20;
	}

	static function get_justSwipedRight():Bool
	{
		final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
		return swipe?.degrees > -45 && swipe?.degrees < 45 && swipe?.distance > 20;
	}

	static function get_justSwipedUp():Bool
	{
		final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
		return swipe?.degrees > 45 && swipe?.degrees < 135 && swipe?.distance > 20;
	}

	static function get_justSwipedDown():Bool
	{
		final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
		return swipe?.degrees > -135 && swipe?.degrees < -45 && swipe?.distance > 20;
	}

	static function get_justSwipedAny():Bool
	{
		return justSwipedLeft || justSwipedRight || justSwipedUp || justSwipedDown;
	}

	static function get_flickLeft():Bool
	{
		#if mobile
		return FlxG.touches.flickManager.flickLeft;
		#else
		return FlxG.mouse.flickManager.flickLeft;
		#end
	}

	static function get_flickRight():Bool
	{
		#if mobile
		return FlxG.touches.flickManager.flickRight;
		#else
		return FlxG.mouse.flickManager.flickRight;
		#end
	}

	static function get_flickUp():Bool
	{
		#if mobile
		return FlxG.touches.flickManager.flickUp;
		#else
		return FlxG.mouse.flickManager.flickUp;
		#end
	}

	static function get_flickDown():Bool
	{
		#if mobile
		return FlxG.touches.flickManager.flickDown;
		#else
		return FlxG.mouse.flickManager.flickDown;
		#end
	}

	static function get_flickAny():Bool
	{
		return flickLeft || flickRight || flickUp || flickDown;
	}
}
