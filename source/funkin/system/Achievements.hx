package funkin.system;

import flixel.util.FlxTimer;

import funkin.data.AchievementData;

/**
 * The achievements backend.
 * Handles registering, unlocking, saving, and showing pop-up toasts.
 */
@:access(funkin.data.AchievementData)
class Achievements
{
	/**
	 * An array holding all loaded achievements.
	 */
	public static var achievements(default, null):Array<AchievementData> = [];

	/**
	 * An array holding the IDs of the user's unlocked achievements.
	 */
	public static var achievementsUnlocked(default, null):Array<String> = [];

	@:noCompletion static function init()
	{
		achievementsUnlocked = FunkinSave.unlockables?.achievements ?? [];
		registerAll();

		FlxG.signals.postStateSwitch.add(checkAchievements);
	}

	static function registerAll()
	{
		achievements = [
			create('scammed', bronze),
			create('curiosityBenefitedTheInspector', gold),
			create('relivingNostalgia', silver),
			create('newStoryUnfolds', silver),
			create('alteredReality', silver),
			create('outsmarted', silver),
			create('outperformed', silver),
			create('onTheRun', silver),
			create('noBeans', silver),
			create('waiterMoreBeansPlease', gold, 1000000),
			create('fingerBreaker', gold, 10000),
			create('tooHard', bronze, 200),
			create('skillIssue', bronze, 50),
			create('easyPrey', silver, 100),
			create('bruh', bronze),
			create('impostorFan', bronze),
			create('slothSupporter', bronze),
			create('leroy', platinum),
		];
	}

	/**
	 * Helper function that creates an achievement data.
	 *
	 * @param id							The ID of the achievement.
	 * @param level						The grade level of the achievement.
	 * @param unlockCriteria	(OPTIONAL) How the achievement gets unlocked.
	 * @return The created `AchievementData`.
	 */
	inline static function create(id:String, grade:AchievementGrade, ?points:Int, ?unlockCriteria:AchievementData -> Bool):AchievementData
	{
		return new AchievementData(id, grade, points, unlockCriteria);
	}

	inline static function createPointsBasedUnlockCriteria(points:Int):AchievementData -> Bool
	{
		return (achievement:AchievementData) ->
		{
			return achievement.progress >= points;
		};
	}

	/**
	 * @param id The ID of the achievement to check.
	 * @return Whether the achievement exists.
	 */
	public static function hasAchievement(id:String):Bool
	{
		for (a in achievements)
		{
			if (a.ID == id)
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * @param id The ID of the achievement to find.
	 * @return The achievement data with the matching ID, `null` if it didn't find any.
	 */
	public static function getAchievement(id:String):Null<AchievementData>
	{
		for (a in achievements)
		{
			if (a.ID == id)
			{
				return a;
			}
		}
		return null;
	}

	/**
	 * @param id The ID of the achievement to check.
	 * @return Whether the achievement is unlocked or not.
	 */
	public static function isUnlocked(id:String):Bool
	{
		return achievementsUnlocked.contains(id);
	}

	/**
	 * @param id The ID of the achievement to check.
	 * @return The progress the achievement towards unlock requirements.
	 */
	public static function getProgress(id:String):Int
	{
		var a:Null<AchievementData> = getAchievement(id);
		return a != null ? a.progress : 0;
	}

	/**
	 * Adds the specified amount of points to the specified achievement.
	 * @param id			The ID of the achievement.
	 * @param points	The amount of points to add to the achievement.
	 */
	public static function addPoints(id:String, points:Int = 0)
	{
		if (!hasAchievement(id) || isUnlocked(id))
		{
			return;
		}

		getAchievement(id)?.addPoints(points);
	}

	/**
	 * Unlocks the specified achievement. regardless if its unlock condition was met or not.
	 * @param id The ID of the achievement to unlock.
	 */
	public static function grantAchievement(id:String)
	{
		if (!hasAchievement(id))
		{
			trace('[Achievements] Achievement with the ID "$id" not found!');
			return;
		}

		if (isUnlocked(id))
		{
			trace('[Achievements] Achievement with the ID "$id" is already unlocked');
			return;
		}

		grantAchievementForce(getAchievement(id));
	}

	/**
	 * Forces the specified achievement to be unlocked.
	 * @param achievement The achievement to unlock.
	 */
	public static function grantAchievementForce(achievement:AchievementData)
	{
		if (achievement == null)
		{
			return;
		}

		FunkinSound.playMenuSound(HARD_CONFIRM);
		_spawnToast(achievement);

		achievementsUnlocked.push(achievement.ID);
		saveAchievements();
	}

	static function saveAchievements()
	{
		FunkinSave.unlockables.achievements = achievementsUnlocked.copy();
		FunkinSave.flush();
	}

	/**
	 * Checks if any achievement is supposed to be unlocked but hasn't.
	 */
	static function checkAchievements()
	{
		for (achievement in achievements)
		{
			if (isUnlocked(achievement.ID))
			{
				continue;
			}

			if (achievement.unlockCriteria != null)
			{
				if (achievement.unlockCriteria(achievement))
				{
					grantAchievementForce(achievement);
				}
			}
			else if (achievement.maxPoints != null)
			{
				if (achievement.progress >= achievement.maxPoints)
				{
					grantAchievementForce(achievement);
				}
			}
		}
	}

	// ─── Toast ───────────────────────────────────────────────────────────────────

	/** How many toasts are currently on screen (for vertical stacking). */
	static var _toastCount:Int = 0;

	static function _spawnToast(data:AchievementData)
	{
		var toast:AchievementToast = new AchievementToast(data, _toastCount);
		FlxG.state.add(toast);
		_toastCount++;

		// Decrement slot count when this toast is done
		toast.onDone = () -> _toastCount = Std.int(Math.max(0, _toastCount - 1));
	}
}

// ─── Toast Sprite ─────────────────────────────────────────────────────────────

/**
 * A self-contained toast notification rendered via FlxSpriteGroup
 * so it uses the normal Flixel asset pipeline (no raw BitmapData needed).
 */
class AchievementToast extends FlxSpriteGroup
{
	static final SCALE:Float = 4.5;
	static final SLIDE_TIME:Float = 0.55;
	static final SHOW_TIME:Float = 2.5;
	static final TOTAL_TIME:Float = 6.0;
	static final FADE_TIME:Float = 0.4;

	public var onDone:Void -> Void = null;

	var _data:AchievementData;
	var _label:FunkinText;
	var _targetX:Float;
	var _elapsed:Float = 0;
	var _nameSwapped:Bool = false;
	var _finished:Bool = false;

	public function new(data:AchievementData, slot:Int)
	{
		super();
		trace('[AchievementToast] Creating toast for: ${data.ID}, slot: $slot');
		_data = data;

		var panelPath:String = Paths.image('achievements/levels/${data.grade}Panel');
		var panel:FunkinSprite = new FunkinSprite(0, 0).loadGraphic(panelPath);
		panel.setGraphicSize(Std.int(panel.width * SCALE), Std.int(panel.height * SCALE));
		panel.updateHitbox();
		panel.antialiasing = false;
		add(panel);

		var panelW:Float = panel.width;
		var panelH:Float = panel.height;

		var levelIcon:FunkinSprite = new FunkinSprite(panelW, 0);
		levelIcon.loadGraphic(Paths.image('achievements/levels/${data.grade}'));
		levelIcon.setGraphicSize(Std.int(panelH), Std.int(panelH));
		levelIcon.updateHitbox();
		levelIcon.antialiasing = false;
		add(levelIcon);

		var iconPath:String = Paths.image('achievements/${data.ID}');
		if (!Assets.exists(iconPath))
		{
			iconPath = Paths.image('achievements/test');
		}

		var icon:FunkinSprite = new FunkinSprite(panelW, 0);
		icon.loadGraphic(iconPath);
		icon.setGraphicSize(Std.int(panelH), Std.int(panelH));
		icon.updateHitbox();
		icon.antialiasing = false;
		add(icon);

		// ── Header text ───────────────────────────────────────────────────────────

		// Split panel into top half (earned text) and bottom half (name)
		_label = new FunkinText(8, panelH * 0.25, panelW - 16, '', 20);
		_label.translationData = {id: 'achievements.earned'};
		_label.alignment = CENTER;
		_label.color = FlxColor.BLACK;
		_label.bold = true;
		add(_label);

		// ── Position: off-screen right, targeting bottom-right ───────────────────

		var totalW:Float = panelW + panelH; // panel + icon side by side
		_targetX = FlxG.width - totalW - 10;
		var targetY:Float = FlxG.height - panelH - 10 - slot * (panelH + 4);

		x = FlxG.width + 10;
		y = targetY;
		alpha = 0;

		// ── Animate in ───────────────────────────────────────────────────────────

		FlxTween.tween(this, {x: _targetX, alpha: 1}, SLIDE_TIME, {ease: FlxEase.quartOut});

		// Phase 2: swap label to achievement name
		FlxTimer.wait(SHOW_TIME, () ->
		{
			if (_finished)
				return;
			_nameSwapped = true;
			FlxTween.tween(_label, {alpha: 0}, 0.2, {
				onComplete: _ ->
				{
					_label.translationData = null;
					_label.text = _data.name;
					FlxTween.tween(_label, {alpha: 1}, 0.3);
				}
			});
		});

		// Phase 3: slide out and remove
		FlxTimer.wait(TOTAL_TIME, () ->
		{
			if (_finished)
				return;
			FlxTween.tween(this, {x: FlxG.width + 10, alpha: 0}, FADE_TIME, {
				onComplete: _ ->
				{
					_finished = true;
					FlxG.state.remove(this, true);
					if (onDone != null)
						onDone();
				}
			});
		});
	}
}
