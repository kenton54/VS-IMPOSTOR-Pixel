package funkin.system;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.ColorTransform;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import funkin.Paths;
import funkin.sound.FunkinSound;
import funkin.system.FunkinSave;
import funkin.system.Translations;

/**
 * The achievements backend.
 *
 * Handles registering achievements, unlocking them, updating progress,
 * persisting them in the save file, and showing the on-screen pop-up toast.
 *
 * Ported from the Codename Engine utils/achievements.hx and rewritten
 * to fit the new repo's conventions.
 */
class Achievements
{
	// ─── Public State ─────────────────────────────────────────────────────────────

	public static var achievements:Array<Achievement> = [];

	public static var achievementsUnlocked:Array<String> = [];

	// ─── Pop-up State ─────────────────────────────────────────────────────────────

	static var achievementScale:Float = 4.5;
	static var popUpScale:Float = 1.2;

	/** Slots of currently visible toasts. `null` means the slot is free. */
	static var activeAchievements:Array<Dynamic> = [];

	/** Tweens parallel to `activeAchievements`. */
	static var activeTweens:Array<Array<AchTween>> = [];

	static var showAchTimer:Float = 2.5;
	static var maxTimer:Float = 6.0;

	// ─── Init ─────────────────────────────────────────────────────────────────────

	@:allow(funkin.InitState)
	static function init()
	{
		achievementsUnlocked = FunkinSave.data?.unlockables?.achievements ?? [];
		activeAchievements = [];
		activeTweens = [];

		registerAll();
	}

	// ─── Registration ─────────────────────────────────────────────────────────────

	/**
	 * All achievements the mod contains.
	 * IDs must match the keys in the translations spreadsheet.
	 */
	static function registerAll()
	{
		achievements = [
			// ── Legacy menu secrets ───────────────────────────────────────────────
			create('scammed',                       BRONZE),
			create('curiosityBenefitedTheInspector',GOLD),
			create('relivingNostalgia',             SILVER),

			// ── Story progression ─────────────────────────────────────────────────
			create('newStoryUnfolds',               SILVER),
			create('alteredReality',                SILVER),

			// ── Score / song specific ─────────────────────────────────────────────
			create('outsmarted',                    SILVER),
			create('outperformed',                  SILVER),
			create('onTheRun',                      SILVER),

			// ── Economy ───────────────────────────────────────────────────────────
			create('noBeans',                       SILVER),
			create('waiterMoreBeansPlease',         GOLD,   1000000),

			// ── Note-hitting milestones ───────────────────────────────────────────
			create('fingerBreaker',                 GOLD,   10000),

			// ── Failure milestones ────────────────────────────────────────────────
			create('tooHard',                       BRONZE, 200),
			create('skillIssue',                    BRONZE, 50),
			create('easyPrey',                      SILVER, 100),
			create('bruh',                          BRONZE),

			// ── Exploration / secrets ─────────────────────────────────────────────
			create('impostorFan',                   BRONZE),
			create('slothSupporter',                BRONZE),

			// ── Easter egg ────────────────────────────────────────────────────────
			create('leroy',                         PLATINUM),
		];
	}

	static function create(id:String, level:AchievementLevel, ?points:Int):Achievement
	{
		return new Achievement(id, level, points);
	}

	// ─── Queries ──────────────────────────────────────────────────────────────────

	public static function hasAchievement(id:String):Bool
	{
		for (a in achievements)
			if (a.ID == id) return true;
		return false;
	}

	public static function getAchievement(id:String):Null<Achievement>
	{
		for (a in achievements)
			if (a.ID == id) return a;
		return null;
	}

	public static function isUnlocked(id:String):Bool
	{
		return achievementsUnlocked.contains(id);
	}

	public static function getProgress(id:String):Int
	{
		var a:Achievement = getAchievement(id);
		return a != null ? a.progress : 0;
	}

	// ─── Unlock / Points ──────────────────────────────────────────────────────────

	/**
	 * Adds points to a point-based achievement and unlocks it when the goal is met.
	 */
	public static function addPoints(id:String, amount:Int = 1):Void
	{
		if (!hasAchievement(id) || isUnlocked(id)) return;

		var a:Achievement = getAchievement(id);
		if (a.points == null) return;

		a.progress += amount;

		if (a.progress >= a.points)
			grantAchievement(id);
	}

	/**
	 * Unlocks an achievement and shows the pop-up toast. Safe to call multiple times
	 * (ignored if already unlocked or unknown).
	 */
	public static function grantAchievement(id:String):Void
	{
		if (!hasAchievement(id) || isUnlocked(id)) return;
		_popupAchievement(getAchievement(id));
	}

	// ─── Save ─────────────────────────────────────────────────────────────────────

	public static function saveAchievements():Void
	{
		if (FunkinSave.data?.unlockables == null) return;
		FunkinSave.data.unlockables.achievements = achievementsUnlocked.copy();
		FunkinSave.flush();
	}

	// ─── Pop-up (faithfully ported from old achievements.hx) ─────────────────────

	static function _popupAchievement(data:Achievement):Void
	{
		FunkinSound.playMenuSound(HARD_CONFIRM);

		if (!achievementsUnlocked.contains(data.ID))
		{
			achievementsUnlocked.push(data.ID);
			saveAchievements();
		}

		var achLevel:String = getAchievementLevelString(data.level);

		var achievementToast:Sprite = new Sprite();
		achievementToast.scaleX = popUpScale;
		achievementToast.scaleY = popUpScale;

		var achWidth:Float  = 72 * achievementScale;
		var achHeight:Float = 28 * achievementScale;
		var fullRatio:Float = 32 * achievementScale;

		// Panel background image (level-coloured)
		var panelBD:BitmapData = funkin.utils.Assets.getBitmapData(Paths.image('achievements/levels/${achLevel}Panel'));
		var achievementPanel:Bitmap = new Bitmap(panelBD);
		achievementPanel.scaleX = achievementScale;
		achievementPanel.scaleY = achievementScale;
		achievementPanel.alpha = 0;
		achievementToast.addChild(achievementPanel);

		// Derive text colour from panel colour brightness
		var achColor:FlxColor = getAchievementLevelColor(data.level);
		var r:Float = ((achColor >> 16) & 0xFF) / 255;
		var g:Float = ((achColor >> 8)  & 0xFF) / 255;
		var b:Float = (achColor         & 0xFF) / 255;
		var textColor:Int = ((r + g + b) / 3) > 0.5 ? 0x000000 : 0xFFFFFF;

		// "You earned an achievement!" header text
		var textFormat:TextFormat = new TextFormat(
			Paths.font('pixeloidsans.ttf'),
			26, textColor
		);
		textFormat.align = TextFormatAlign.CENTER;

		var achievementText:TextField = new TextField();
		achievementText.width          = achievementPanel.width;
		achievementText.selectable     = false;
		achievementText.embedFonts     = true;
		achievementText.multiline      = true;
		achievementText.wordWrap       = true;
		achievementText.defaultTextFormat = textFormat;
		achievementText.text           = Translations.translate('achievements.earned');
		achievementText.height         = 26;
		achievementText.alpha          = 0;
		achievementText.height         = achievementText.textHeight + 6;
		achievementToast.addChild(achievementText);
		_objectCenter(achievementText, achievementPanel);

		// Level icon (bronze / silver / gold / platinum image)
		var levelBD:BitmapData = funkin.utils.Assets.getBitmapData(Paths.image('achievements/levels/$achLevel'));
		var achievementLevel:Bitmap = new Bitmap(levelBD);
		achievementLevel.scaleX = achievementScale;
		achievementLevel.scaleY = achievementScale;
		achievementLevel.x = achievementPanel.width;
		achievementToast.addChild(achievementLevel);

		// Achievement icon (the unique per-achievement image)
		var iconPath:String = Paths.image('achievements/${data.ID}');
		var iconBD:BitmapData = funkin.utils.Assets.exists(iconPath)
			? funkin.utils.Assets.getBitmapData(iconPath)
			: funkin.utils.Assets.getBitmapData(Paths.image('achievements/test'));
		var achievementSprite:Bitmap = new Bitmap(iconBD);
		achievementSprite.scaleX = achievementScale;
		achievementSprite.scaleY = achievementScale;
		achievementSprite.x = achievementLevel.x;
		achievementToast.addChild(achievementSprite);

		// Find a free slot (reuse null gaps, otherwise append)
		var nullSpot:Int    = -1;
		var foundNull:Bool  = false;
		for (i in 0...activeAchievements.length)
		{
			if (activeAchievements[i] == null)
			{
				foundNull = true;
				nullSpot  = i;
				break;
			}
		}

		var slot:Int = foundNull ? nullSpot : activeAchievements.length;

		// Position: slides from right edge
		achievementToast.x = FlxG.stage.stageWidth;
		achievementToast.y = (10 / popUpScale) + ((fullRatio + 1.01 * achievementScale) * slot);
		var toastTargetX:Float = FlxG.stage.stageWidth - achievementPanel.width - fullRatio - 20;
		var toastTargetY:Float = 20 + ((fullRatio + 1.01 * achievementScale) * slot);

		// White flash colour transform
		var colorShit:ColorTransform = new ColorTransform();
		colorShit.color = FlxColor.WHITE;
		achievementToast.transform.colorTransform = colorShit;

		// Offset panel + header to the right so they slide in
		achievementPanel.x += 32;
		achievementText.x  += 32;

		// Build tweens using our simple openfl-compatible tweener
		var startX:Float = achievementToast.x;
		var startY:Float = achievementToast.y;

		var tw1:AchTween = AchTween.create(0,   1.0, FlxEase.quartOut, (t) -> {
			achievementToast.x      = startX + (toastTargetX - startX) * t;
			achievementToast.y      = startY + (toastTargetY - startY) * t;
			achievementToast.scaleX = popUpScale + (1 - popUpScale) * t;
			achievementToast.scaleY = popUpScale + (1 - popUpScale) * t;
			achievementToast.transform.colorTransform = colorShit;
		});
		var tw2:AchTween = AchTween.create(0,   1.0, FlxEase.quartOut, (t) -> {
			colorShit.redMultiplier   = t;
			colorShit.greenMultiplier = t;
			colorShit.blueMultiplier  = t;
			colorShit.redOffset       = 0;
			colorShit.greenOffset     = 0;
			colorShit.blueOffset      = 0;
			achievementToast.transform.colorTransform = colorShit;
		});
		var panelStartX:Float = achievementPanel.x;
		var tw3:AchTween = AchTween.create(0.5, 0.5, FlxEase.quartOut, (t) -> {
			achievementPanel.alpha = t;
			achievementPanel.x     = panelStartX + (0 - panelStartX) * t;
		});
		var textStartX:Float = achievementText.x;
		var tw4:AchTween = AchTween.create(0.5, 0.5, FlxEase.quartOut, (t) -> {
			achievementText.alpha = t;
			achievementText.x     = textStartX + (0 - textStartX) * t;
		});
		var tw5:AchTween = AchTween.create(2.0, 0.5, FlxEase.quartOut, (t) -> {
			achievementText.alpha = 1 - t;
		});

		var tweenArr:Array<AchTween> = [tw1, tw2, tw3, tw4, tw5];

		FlxG.game.addChild(achievementToast);

		var entry:Dynamic = {
			data:      data,
			sprite:    achievementToast,
			panel:     achievementPanel,
			text:      achievementText,
			shownName: false,
			onFinish:  false,
			timer:     0.0
		};

		if (foundNull)
		{
			activeAchievements[slot] = entry;
			activeTweens[slot] = tweenArr;
		}
		else
		{
			activeAchievements.push(entry);
			activeTweens.push(tweenArr);
		}
	}

	/**
	 * Must be called every frame (from InitState or a persistent manager object).
	 */
	public static function update(elapsed:Float):Void
	{
		for (i => achievement in activeAchievements)
		{
			if (achievement == null) continue;

			achievement.timer += elapsed;

			for (tw in activeTweens[i])
				tw.tick(elapsed);

			// Phase 2: swap header text for achievement name
			if (achievement.timer >= showAchTimer && !achievement.shownName)
			{
				var achText:openfl.text.TextField = cast achievement.text;
				if (achText.alpha > 0) continue;

				achievement.shownName = true;

				var tw:AchTween = AchTween.create(0, 0.5, FlxEase.quartOut, (t) -> {
					(cast achievement.text : openfl.text.TextField).alpha = t;
				});
				activeTweens[i].push(tw);

				achText.text   = (achievement.data : Achievement).name;
				achText.height = achText.textHeight + 6;
				_objectCenter(achText, cast achievement.panel);
			}

			// Phase 3: fade out and clean up
			if (achievement.timer >= maxTimer)
			{
				var achSprite:openfl.display.Sprite = cast achievement.sprite;

				if (achievement.onFinish && achSprite.alpha <= 0)
				{
					for (tw in activeTweens[i])
						tw.cancel();
					activeTweens[i] = null;
					_dispose(achievement);
				}

				if (!achievement.onFinish)
				{
					achievement.onFinish = true;
					var tw:AchTween = AchTween.create(0, 0.2, FlxEase.quartOut, (t) -> {
						(cast achievement.sprite : openfl.display.Sprite).alpha = 1 - t;
					});
					activeTweens[i].push(tw);
				}
			}
		}
	}

	static function _dispose(achievement:Dynamic):Void
	{
		FlxG.game.removeChild(achievement.sprite);

		achievement.data   = null;
		achievement.text   = null;
		achievement.panel  = null;
		achievement.sprite = null;

		var idx:Int = activeAchievements.indexOf(achievement);
		activeAchievements[idx] = null;
		achievement = null;
	}

	public static function disposeAll():Void
	{
		for (achievement in activeAchievements)
		{
			if (achievement == null) continue;
			FlxG.game.removeChild(achievement.sprite);
			achievement.text   = null;
			achievement.panel  = null;
			achievement.sprite = null;
			achievement        = null;
		}
		activeAchievements = [];
		activeTweens       = [];
	}

	// ─── Helper: centre a TextField over a Bitmap ─────────────────────────────────

	static function _objectCenter(text:TextField, over:Bitmap):Void
	{
		text.x = over.x + (over.width  - text.width)  / 2;
		text.y = over.y + (over.height - text.height) / 2;
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

	public var name(get, never):String;
	function get_name():String return Translations.translate('achievements.${ID}.name');

	public var description(get, never):String;
	function get_description():String return Translations.translate('achievements.${ID}.desc');

	public var level:AchievementLevel;

	/** Total points needed to unlock. `null` → unlocked manually via `grantAchievement`. */
	public var points:Null<Int>;

	public var progress:Int = 0;

	public function new(id:String, level:AchievementLevel, ?points:Int)
	{
		this.ID     = id;
		this.level  = level;
		this.points = points;
	}

	public function clone():Achievement
	{
		return new Achievement(ID, level, points);
	}
}

// ─── Achievement Level ────────────────────────────────────────────────────────

enum AchievementLevel
{
	BRONZE;
	SILVER;
	GOLD;
	PLATINUM;
	LOCKED;
}

// ─── Lightweight OpenFL-compatible tweener ────────────────────────────────────

/**
 * A simple manually-ticked tween for use with OpenFL display objects,
 * which can't use FlxTween (Flixel-only).
 */
class AchTween
{
	var _delay:Float;
	var _duration:Float;
	var _elapsed:Float = 0;
	var _ease:Float -> Float;
	var _onUpdate:Float -> Void;
	var _done:Bool = false;

	function new(delay:Float, duration:Float, ease:Float->Float, onUpdate:Float->Void)
	{
		_delay    = delay;
		_duration = duration;
		_ease     = ease;
		_onUpdate = onUpdate;
	}

	public static function create(delay:Float, duration:Float, ease:Float->Float, onUpdate:Float->Void):AchTween
	{
		return new AchTween(delay, duration, ease, onUpdate);
	}

	public function tick(elapsed:Float):Void
	{
		if (_done) return;

		_elapsed += elapsed;

		var active:Float = _elapsed - _delay;
		if (active < 0) return;

		var t:Float = Math.min(active / _duration, 1.0);
		_onUpdate(_ease(t));

		if (t >= 1.0)
			_done = true;
	}

	public function cancel():Void
	{
		_done = true;
	}

	public var finished(get, never):Bool;
	function get_finished():Bool return _done;
}
