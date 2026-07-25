package funkin.data;

class AchievementData
{
	public var ID:String;
	public var grade:AchievementGrade;

	public var progress(default, null):Int = 0;

	public var maxPoints(default, null):Null<Int> = null;

	var unlockCriteria:AchievementData -> Bool;

	/**
	 * The readable name of the achievement.
	 */
	public var name(get, never):String;

	/**
	 * The description that displays in the `AchievementsState` menu.
	 */
	public var description(get, never):String;

	/**
	 * Creates new achievement data.
	 *
	 * @param id							The ID of the achievement. This is also used to get the readable name of the achievement.
	 * @param grade						The grade level of the achievement.
	 * @param points					How many points
	 * @param unlockCriteria	How the achievement should be unlocked. Optional.
	 */
	public function new(id:String, grade:AchievementGrade, ?points:Int, ?unlockCriteria:AchievementData -> Bool)
	{
		this.ID = id;
		this.grade = grade;
		this.maxPoints = points;
		this.unlockCriteria = unlockCriteria;

		if (points != null && unlockCriteria == null)
		{
			unlockCriteria = (achievement:AchievementData) ->
			{
				return achievement.progress >= achievement.maxPoints;
			};
		}
	}

	/**
	 * @param points The amount of points to add to the achievement.
	 */
	public function addPoints(points:Int = 0)
	{
		progress += points;
	}

	function get_name():String
	{
		return 'achievements.$ID.name';
	}

	function get_description():String
	{
		return 'achievements.$ID.desc';
	}
}

enum abstract AchievementGrade(String) to String
{
	/**
	 * The lowest achievement grade.
	 */
	var bronze;

	var silver;

	var gold;

	var platinum;

	/**
	 * The achievement is supposed to be locked.
	 */
	var locked;

	@:to public inline function toString():String
	{
		return this;
	}

	/**
	 * @return The color of the achievement toast, depending on its level.
	 */
	@:to public function toColor():FlxColor
	{
		return switch (this)
		{
			case bronze: 0xFF7A644F;
			case silver: 0xFF9E9999;
			case gold: 0xFFF8A514;
			case platinum: 0xFFB6C5E4;
			case locked: 0xFF292929;
			default: 0xFF292929;
		}
	}

	/**
	 * @return The amount of beans to reward the player when unlocking the achievement, depending on its level.
	 */
	@:to public function toBeans():Int
	{
		return switch (this)
		{
			case bronze: 100;
			case silver: 200;
			case gold: 500;
			case platinum: 1000;
			case locked: 0;
			default: 0;
		}
	}
}
