package funkin.system;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import funkin.Paths;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.sound.FunkinSound;
import funkin.system.FunkinSave;
import funkin.system.Translations;

/**
 * The achievements backend.
 * Handles registering, unlocking, saving, and showing pop-up toasts.
 */
class Achievements
{
	// ─── Public state ────────────────────────────────────────────────────────────

	public static var achievements:Array<Achievement> = [];
	public static var achievementsUnlocked:Array<String> = [];

	// ─── Init ─────────────────────────────────────────────────────────────────────

	@:allow(funkin.InitState)
	static function init()
	{
		achievementsUnlocked = FunkinSave.data?.unlockables?.achievements ?? [];

		registerAll();
	}

	// ─── Registration ────────────────────────────────────────────────────────────

	static function registerAll()
	{
		achievements = [
			create('scammed',                        BRONZE),
			create('curiosityBenefitedTheInspector', GOLD),
			create('relivingNostalgia',              SILVER),
			create('newStoryUnfolds',                SILVER),
			create('alteredReality',                 SILVER),
			create('outsmarted',                     SILVER),
			create('outperformed',                   SILVER),
			create('onTheRun',                       SILVER),
			create('noBeans',                        SILVER),
			create('waiterMoreBeansPlease',          GOLD,   1000000),
			create('fingerBreaker',                  GOLD,   10000),
			create('tooHard',                        BRONZE, 200),
			create('skillIssue',                     BRONZE, 50),
			create('easyPrey',                       SILVER, 100),
			create('bruh',                           BRONZE),
			create('impostorFan',                    BRONZE),
			create('slothSupporter',                 BRONZE),
			create('leroy',                          PLATINUM),
		];
	}

	static inline function create(id:String, level:AchievementLevel, ?points:Int):Achievement
		return new Achievement(id, level, points);

	// ─── Queries ─────────────────────────────────────────────────────────────────

	public static function hasAchievement(id:String):Bool
	{
		for (a in achievements) if (a.ID == id) return true;
		return false;
	}

	public static function getAchievement(id:String):Null<Achievement>
	{
		for (a in achievements) if (a.ID == id) return a;
		return null;
	}

	public static function isUnlocked(id:String):Bool
		return achievementsUnlocked.contains(id);

	public static function getProgress(id:String):Int
	{
		var a = getAchievement(id);
		return a != null ? a.progress : 0;
	}

	// ─── Unlock ──────────────────────────────────────────────────────────────────

	public static function addPoints(id:String, amount:Int = 1):Void
	{
		if (!hasAchievement(id) || isUnlocked(id)) return;
		var a = getAchievement(id);
		if (a.points == null) return;
		a.progress += amount;
		if (a.progress >= a.points) grantAchievement(id);
	}

	public static function grantAchievement(id:String):Void
	{
		trace('[Achievements] grantAchievement called: $id');
		if (!hasAchievement(id)) { trace('[Achievements] SKIPPED - not found'); return; }
		if (isUnlocked(id))      { trace('[Achievements] SKIPPED - already unlocked'); return; }
		achievementsUnlocked.push(id);
		saveAchievements();
		FunkinSound.playMenuSound(HARD_CONFIRM);
		trace('[Achievements] Spawning toast for $id');
		_spawnToast(getAchievement(id));
	}

	public static function saveAchievements():Void
	{
		if (FunkinSave.data?.unlockables == null) return;
		FunkinSave.data.unlockables.achievements = achievementsUnlocked.copy();
		FunkinSave.flush();
	}

	// ─── Toast ───────────────────────────────────────────────────────────────────

	/** How many toasts are currently on screen (for vertical stacking). */
	static var _toastCount:Int = 0;

	static function _spawnToast(data:Achievement):Void
	{
		var toast:AchievementToast = new AchievementToast(data, _toastCount);
		FlxG.state.add(toast);
		_toastCount++;

		// Decrement slot count when this toast is done
		toast.onDone = () -> _toastCount = Std.int(Math.max(0, _toastCount - 1));
	}

	// ─── Level helpers ────────────────────────────────────────────────────────────

	public static function getAchievementLevelString(level:AchievementLevel):String
	{
		return switch (level)
		{
			case BRONZE:   'bronze';
			case SILVER:   'silver';
			case GOLD:     'gold';
			case PLATINUM: 'platinum';
			case LOCKED:   'locked';
		};
	}

	public static function getAchievementLevelColor(level:AchievementLevel):FlxColor
	{
		return switch (level)
		{
			case BRONZE:   0xFF7A644F;
			case SILVER:   0xFF9E9999;
			case GOLD:     0xFFF8A514;
			case PLATINUM: 0xFFB6C5E4;
			case LOCKED:   0xFF292929;
		};
	}

	public static function getAchievementLevelPrize(level:AchievementLevel):Int
	{
		return switch (level)
		{
			case BRONZE:   100;
			case SILVER:   200;
			case GOLD:     500;
			case PLATINUM: 1000;
			case LOCKED:   0;
		};
	}
}

// ─── Achievement ─────────────────────────────────────────────────────────────

class Achievement
{
	public var ID:String;
	public var level:AchievementLevel;
	public var points:Null<Int>;
	public var progress:Int = 0;

	public var name(get, never):String;
	function get_name():String return Translations.translate('achievements.${ID}.name');

	public var description(get, never):String;
	function get_description():String return Translations.translate('achievements.${ID}.desc');

	public function new(id:String, level:AchievementLevel, ?points:Int)
	{
		this.ID     = id;
		this.level  = level;
		this.points = points;
	}
}

// ─── Achievement Level ────────────────────────────────────────────────────────

enum AchievementLevel { BRONZE; SILVER; GOLD; PLATINUM; LOCKED; }

// ─── Toast Sprite ─────────────────────────────────────────────────────────────

/**
 * A self-contained toast notification rendered via FlxSpriteGroup
 * so it uses the normal Flixel asset pipeline (no raw BitmapData needed).
 */
class AchievementToast extends FlxSpriteGroup
{
	static final SCALE:Float        = 4.5;
	static final SLIDE_TIME:Float   = 0.55;
	static final SHOW_TIME:Float    = 2.5;
	static final TOTAL_TIME:Float   = 6.0;
	static final FADE_TIME:Float    = 0.4;

	public var onDone:Void -> Void = null;

	var _data:Achievement;
	var _label:FunkinText;
	var _targetX:Float;
	var _elapsed:Float  = 0;
	var _nameSwapped:Bool = false;
	var _finished:Bool    = false;

	public function new(data:Achievement, slot:Int)
	{
		super();
		trace('[AchievementToast] Creating toast for: ${data.ID}, slot: $slot');
		_data = data;

		var levelStr:String = Achievements.getAchievementLevelString(data.level);

		// ── Panel background ──────────────────────────────────────────────────────

		var panelPath:String = Paths.image('achievements/levels/${levelStr}Panel');
		var panel:FlxSprite = new FlxSprite(0, 0);
		panel.loadGraphic(panelPath);
		panel.setGraphicSize(Std.int(panel.width * SCALE), Std.int(panel.height * SCALE));
		panel.updateHitbox();
		panel.antialiasing = false;
		add(panel);

		var panelW:Float = panel.width;
		var panelH:Float = panel.height;

		// ── Level icon ────────────────────────────────────────────────────────────

		var levelIcon:FlxSprite = new FlxSprite(panelW, 0);
		levelIcon.loadGraphic(Paths.image('achievements/levels/$levelStr'));
		levelIcon.setGraphicSize(Std.int(panelH), Std.int(panelH));
		levelIcon.updateHitbox();
		levelIcon.antialiasing = false;
		add(levelIcon);

		// ── Achievement icon ──────────────────────────────────────────────────────

		var iconPath:String = Paths.image('achievements/${data.ID}');
		if (!openfl.Assets.exists(iconPath))
			iconPath = Paths.image('achievements/test');

		var icon:FlxSprite = new FlxSprite(panelW, 0);
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
			if (_finished) return;
			_nameSwapped = true;
			FlxTween.tween(_label, {alpha: 0}, 0.2, {onComplete: _ ->
			{
				_label.translationData = null;
				_label.text  = _data.name;
				FlxTween.tween(_label, {alpha: 1}, 0.3);
			}});
		});

		// Phase 3: slide out and remove
		FlxTimer.wait(TOTAL_TIME, () ->
		{
			if (_finished) return;
			FlxTween.tween(this, {x: FlxG.width + 10, alpha: 0}, FADE_TIME, {onComplete: _ ->
			{
				_finished = true;
				FlxG.state.remove(this, true);
				if (onDone != null) onDone();
			}});
		});
	}

	static function _textColor(level:AchievementLevel):FlxColor
	{
		return switch (level)
		{
			case GOLD, PLATINUM: FlxColor.BLACK;
			default:             FlxColor.WHITE;
		};
	}
}
