package funkin.system;

import flixel.util.FlxTimer;

import funkin.data.AchievementData;
import funkin.system.FunkinSave;
import funkin.system.Translations;

/**
 * The achievements backend.
 * Handles registering, unlocking, saving, and showing pop-up toasts.
 */
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

	@:allow(funkin.InitState)
	static function init()
	{
		achievementsUnlocked = FunkinSave.unlockables?.achievements ?? [];
		registerAll();

		FlxG.signals.postStateSwitch.add(checkAchievements);
	}

	static function registerAll()
	{
		achievements = [
			create('scammed', BRONZE),
			create('curiosityBenefitedTheInspector', GOLD),
			create('relivingNostalgia', SILVER),
			create('newStoryUnfolds', SILVER),
			create('alteredReality', SILVER),
			create('outsmarted', SILVER),
			create('outperformed', SILVER),
			create('onTheRun', SILVER),
			create('noBeans', SILVER),
			create('waiterMoreBeansPlease', GOLD, 1000000),
			create('fingerBreaker', GOLD, 10000),
			create('tooHard', BRONZE, 200),
			create('skillIssue', BRONZE, 50),
			create('easyPrey', SILVER, 100),
			create('bruh', BRONZE),
			create('impostorFan', BRONZE),
			create('slothSupporter', BRONZE),
			create('leroy', PLATINUM),
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
	inline static function create(id:String, level:AchievementLevel, ?points:Int, ?unlockCriteria:AchievementData -> Bool):AchievementData
	{
		return new AchievementData(id, level, points, unlockCriteria);
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

	public static function getAchievementLevelString(level:AchievementLevel):String
	{
		return switch (level)
		{
			case BRONZE: 'bronze';
			case SILVER: 'silver';
			case GOLD: 'gold';
			case PLATINUM: 'platinum';
			case LOCKED: 'locked';
		};
	}

	public static function getAchievementLevelColor(level:AchievementLevel):FlxColor
	{
		return switch (level)
		{
			case BRONZE: 0xFF7A644F;
			case SILVER: 0xFF9E9999;
			case GOLD: 0xFFF8A514;
			case PLATINUM: 0xFFB6C5E4;
			case LOCKED: 0xFF292929;
		};
	}

	public static function getAchievementLevelPrize(level:AchievementLevel):Int
	{
		return switch (level)
		{
			case BRONZE: 100;
			case SILVER: 200;
			case GOLD: 500;
			case PLATINUM: 1000;
			case LOCKED: 0;
		};
	}
}

class Achievement
{
	public var ID:String;
	public var level:AchievementLevel;

	public var progress(default, null):Int = 0;

	public var maxPoints(default, null):Null<Int> = null;

	var unlockCriteria:Achievement -> Bool;

	/**
	 * The readable name of the achievement.
	 */
	public var name(get, never):String;

	function get_name():String
	{
		return Translations.translate('achievements.$ID.name');
	}

	/**
	 * The description that displays in the `AchievementsState` menu.
	 */
	public var description(get, never):String;

	function get_description():String
	{
		return Translations.translate('achievements.$ID.desc');
	}

	/**
	 * Creates new achievement data.
	 *
	 * @param id							The ID of the achievement. This is also used to get the readable name of the achievement.
	 * @param level						The grade level of the achievement.
	 * @param points					How many points
	 * @param unlockCriteria	How the achievement should be unlocked. Optional.
	 */
	public function new(id:String, level:AchievementLevel, ?points:Int, ?unlockCriteria:Achievement -> Bool)
	{
		this.ID = id;
		this.level = level;
		this.maxPoints = points;
		this.unlockCriteria = unlockCriteria;
	}

	/**
	 * @param points The amount of points to add to the achievement.
	 */
	public function addPoints(points:Int = 0)
	{
		progress += points;
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

		var levelStr:String = Achievements.getAchievementLevelString(data.level);

		var panelPath:String = Paths.image('achievements/levels/${levelStr}Panel');
		var panel:FunkinSprite = new FunkinSprite(0, 0).loadGraphic(panelPath);
		panel.setGraphicSize(Std.int(panel.width * SCALE), Std.int(panel.height * SCALE));
		panel.updateHitbox();
		panel.antialiasing = false;
		add(panel);

		var panelW:Float = panel.width;
		var panelH:Float = panel.height;

		var levelIcon:FunkinSprite = new FunkinSprite(panelW, 0);
		levelIcon.loadGraphic(Paths.image('achievements/levels/$levelStr'));
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
		_label.color = _textColor(data.level);
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

	static function _textColor(level:AchievementLevel):FlxColor
	{
		return switch (level)
		{
			case GOLD, PLATINUM: FlxColor.BLACK;
			default: FlxColor.WHITE;
		};
	}
}
