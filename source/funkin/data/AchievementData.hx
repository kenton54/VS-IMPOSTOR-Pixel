package funkin.data;

@:allow(funkin.system.Achievements)
class AchievementData
{
	public var ID:String;
	public var level:AchievementLevel;

	public var progress(default, null):Int = 0;

	public var maxPoints(default, null):Null<Int> = null;

	var unlockCriteria:AchievementData -> Bool;

	/**
	 * The readable name of the achievement.
	 */
	public var name(get, never):String;

	function get_name():String
	{
		return 'achievements.$ID.name';
	}

	/**
	 * The description that displays in the `AchievementsState` menu.
	 */
	public var description(get, never):String;

	function get_description():String
	{
		return 'achievements.$ID.desc';
	}

	/**
	 * Creates new achievement data.
	 *
	 * @param id							The ID of the achievement. This is also used to get the readable name of the achievement.
	 * @param level						The grade level of the achievement.
	 * @param points					How many points
	 * @param unlockCriteria	How the achievement should be unlocked. Optional.
	 */
	public function new(id:String, level:AchievementLevel, ?points:Int, ?unlockCriteria:AchievementData -> Bool)
	{
		this.ID = id;
		this.level = level;
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
}

enum AchievementLevel
{
	BRONZE;
	SILVER;
	GOLD;
	PLATINUM;
	LOCKED;
}
