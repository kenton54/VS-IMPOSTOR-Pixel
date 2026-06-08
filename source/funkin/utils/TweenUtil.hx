package funkin.utils;

class TweenUtil
{
	/**
	 * @param object The object to check.
	 * @return Whether the specified object has any tweens.
	 */
	public static function hasTweens(object:Dynamic):Bool
	{
		var result:Bool = false;

		FlxTween.globalManager.forEach(function(tween:FlxTween)
		{
			@:privateAccess {
				if (tween.isTweenOf(object))
				{
					result = true;
				}
			}
		});

		return result;
	}
}
