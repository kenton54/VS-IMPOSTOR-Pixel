package funkin.menus.achievements;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import funkin.Paths;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.input.Pointer;
import funkin.menus.mainmenu.MainMenuState;
import funkin.sound.FunkinSound;
import funkin.system.Achievements;
import funkin.system.Translations;
import funkin.ui.BackButton;
import funkin.ui.MusicBeatState;
import funkin.ui.StarsBackdrop;
import funkin.ui.transitions.VerticalFade;

/**
 * The achievements screen.
 *
 * Matches the old Codename Engine impostorAchievementsState:
 *   - scrolling starfield backdrop
 *   - tiling topBorder graphic at the top (pixelart-scaled)
 *   - X back-button in the top-left
 *
 * The list of achievements, card layout, and scroll logic are original additions
 * layered on top of that faithful skeleton.
 */
class AchievementsState extends MusicBeatState
{
	// ─── Layout constants (match the main menu base scale) ───────────────────────

	static final BASE_SCALE:Float = 5;

	/** Height of the topBorder strip in game pixels. */
	static final BORDER_H:Float = 5 * BASE_SCALE;   // 5 sprite px × 5

	/** How many achievement cards are visible at once. */
	static final PAGE_SIZE:Int = 5;

	/** Height of a single card (px). */
	static final CARD_H:Float = 62;

	/** Vertical gap between cards (px). */
	static final CARD_GAP:Float = 6;

	/** Card left/right margin from the screen edge. */
	static final CARD_MARGIN:Float = 20;

	// ─── Fields ───────────────────────────────────────────────────────────────────

	var _stars:StarsBackdrop;
	var _topBorder:FlxBackdrop;
	var _backButton:BackButton;

	var _cards:Array<AchievementCard> = [];
	var _allAchievements:Array<Achievement> = [];
	var _scrollOffset:Int = 0;

	/** "X / N unlocked" counter text */
	var _counterText:FunkinText;

	/** Scrollbar thumb */
	var _scrollThumb:FunkinSprite;
	var _scrollTrackH:Float = 0;

	var _allowInput:Bool = false;

	// ─── Create ───────────────────────────────────────────────────────────────────

	override public function create()
	{
		super.create();

		FlxG.camera.bgColor = FlxColor.fromRGB(14, 14, 22);

		// ── Stars (behind everything, same params as old state) ───────────────────

		_stars = new StarsBackdrop(-20, 4);
		add(_stars);

		// ── Achievement cards ─────────────────────────────────────────────────────

		_buildList();
		_buildCards();

		// ── Top border (scrolling image, same as old state) ───────────────────────
		// Added AFTER cards so it draws on top.

		_topBorder = new FlxBackdrop(Paths.image('menus/general/topBorder'), FlxAxes.X);
		_topBorder.scale.set(BASE_SCALE, BASE_SCALE);
		_topBorder.updateHitbox();
		_topBorder.scrollFactor.set(0, 0);
		add(_topBorder);

		// ── Scrollbar ─────────────────────────────────────────────────────────────

		var trackX:Float = FlxG.width - CARD_MARGIN * 0.6;
		var trackY:Float = BORDER_H + 4;
		_scrollTrackH    = FlxG.height - trackY - 8;

		var scrollTrack:FunkinSprite = new FunkinSprite(trackX, trackY).makeSolid(4, Std.int(_scrollTrackH), 0x33FFFFFF);
		scrollTrack.scrollFactor.set();
		add(scrollTrack);

		_scrollThumb = new FunkinSprite(trackX, trackY).makeSolid(4, 40, 0xAAFFFFFF);
		_scrollThumb.scrollFactor.set();
		add(_scrollThumb);

		// ── Unlock counter ────────────────────────────────────────────────────────

		_counterText = new FunkinText(0, BORDER_H + 4, FlxG.width - CARD_MARGIN * 1.5, '', 18);
		_counterText.alignment = RIGHT;
		_counterText.color = 0x88FFFFFF;
		_counterText.scrollFactor.set();
		add(_counterText);
		_updateCounter();

		// ── Back button (top-left, same position as old state) ────────────────────

		_backButton = new BackButton(BASE_SCALE, BASE_SCALE, FlxColor.WHITE, 0.6, false);
		_backButton.scaleSprite(BASE_SCALE);
		_backButton.scrollFactor.set();
		add(_backButton);

		_backButton.onConfirmStart.add(() -> FunkinSound.playMenuSound(CANCEL));
		_backButton.onConfirmEnd.add(_goBack);

		// ── Populate cards now that all UI objects exist ───────────────────────────

		_populateCards();

		// ── Delay input briefly ───────────────────────────────────────────────────

		FlxTimer.wait(0.2, () -> _allowInput = true);
	}

	// ─── Update ───────────────────────────────────────────────────────────────────

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!_allowInput) return;

		if (controls.UI_UP)
			_scroll(-1);
		else if (controls.UI_DOWN)
			_scroll(1);

		if (controls.BACK)
		{
			FunkinSound.playMenuSound(CANCEL);
			_goBack();
		}

		// Mouse-wheel scroll
		if (FlxG.mouse.wheel != 0)
			_scroll(-FlxG.mouse.wheel);
	}

	// ─── Helpers ─────────────────────────────────────────────────────────────────

	/** Builds the sorted master list (unlocked first, then by ID). */
	function _buildList()
	{
		_allAchievements = Achievements.achievements.copy();
		_allAchievements.sort((a, b) ->
		{
			var aU = Achievements.isUnlocked(a.ID);
			var bU = Achievements.isUnlocked(b.ID);
			if (aU != bU) return aU ? -1 : 1;
			return a.ID < b.ID ? -1 : 1;
		});
	}

	/** Creates the reusable card objects. */
	function _buildCards()
	{
		var cardY:Float = BORDER_H + 28;  // leave room for the counter text row

		for (i in 0...PAGE_SIZE)
		{
			var card:AchievementCard = new AchievementCard(
				CARD_MARGIN,
				cardY + i * (CARD_H + CARD_GAP),
				FlxG.width - CARD_MARGIN * 2
			);
			card.scrollFactor.set();
			_cards.push(card);
			add(card);
		}
	}

	function _scroll(dir:Int)
	{
		var maxOffset:Int = Std.int(Math.max(0, _allAchievements.length - PAGE_SIZE));
		var newOffset:Int = Std.int(FlxMath.bound(_scrollOffset + dir, 0, maxOffset));
		if (newOffset == _scrollOffset) return;

		_scrollOffset = newOffset;
		_populateCards();
		FunkinSound.playMenuSound();
	}

	function _populateCards()
	{
		for (i in 0...PAGE_SIZE)
		{
			var idx:Int = _scrollOffset + i;

			if (idx < _allAchievements.length)
			{
				_cards[i].populate(_allAchievements[idx]);
				_cards[i].visible = true;
			}
			else
			{
				_cards[i].visible = false;
			}
		}

		_updateScrollThumb();
	}

	function _updateScrollThumb()
	{
		if (_allAchievements.length <= PAGE_SIZE)
		{
			_scrollThumb.visible = false;
			return;
		}

		_scrollThumb.visible = true;

		var ratio:Float  = _scrollOffset / (_allAchievements.length - PAGE_SIZE);
		var thumbH:Float = _scrollTrackH * (PAGE_SIZE / _allAchievements.length);

		_scrollThumb.scale.y = thumbH / _scrollThumb.frameHeight;
		_scrollThumb.updateHitbox();
		_scrollThumb.y = _scrollThumb.y + ratio * (_scrollTrackH - thumbH);
	}

	function _updateCounter()
	{
		var total:Int    = _allAchievements.length;
		var earned:Int   = Achievements.achievementsUnlocked.length;
		_counterText.text = '$earned / $total';
	}

	function _goBack()
	{
		_allowInput = false;
		MusicBeatState.setTransitions(VerticalFade);
		FlxG.switchState(() -> new MainMenuState());
	}

	// ─── Destroy ─────────────────────────────────────────────────────────────────

	override public function destroy()
	{
		super.destroy();
		_backButton.destroy();
	}
}

// ─── Achievement Card ─────────────────────────────────────────────────────────

/**
 * A single row card showing one achievement's icon, name, description,
 * level badge, and progress if applicable.
 */
private class AchievementCard extends FlxSpriteGroup
{
	static final ICON_SIZE:Float = 48;
	static final BADGE_W:Float   = 56;
	static final PAD:Float       = 10;

	var _bg:FunkinSprite;
	var _iconBorder:FunkinSprite;
	var _icon:FlxSprite;
	var _levelBadge:FlxSprite;
	var _nameText:FunkinText;
	var _descText:FunkinText;
	var _progressBar:FunkinSprite;
	var _progressFill:FunkinSprite;
	var _progressText:FunkinText;

	var _cardW:Float;

	public function new(x:Float, y:Float, width:Float)
	{
		super(x, y);

		_cardW = width;

		// Background
		_bg = new FunkinSprite().makeSolid(Std.int(width), 62, 0xFF1A1A2E);
		add(_bg);

		// Icon border / placeholder
		_iconBorder = new FunkinSprite(PAD, (62 - ICON_SIZE) / 2).makeSolid(Std.int(ICON_SIZE), Std.int(ICON_SIZE), 0xFF2A2A44);
		add(_iconBorder);

		// Icon image (loaded per-achievement in populate())
		_icon = new FlxSprite(PAD, (62 - ICON_SIZE) / 2);
		add(_icon);

		// Level badge image (right side)
		_levelBadge = new FlxSprite(width - BADGE_W - PAD, (62 - ICON_SIZE) / 2);
		add(_levelBadge);

		var textX:Float  = PAD + ICON_SIZE + PAD;
		var textW:Float  = width - textX - BADGE_W - PAD * 2;

		// Achievement name
		_nameText = new FunkinText(textX, 8, textW, '', 20);
		_nameText.bold = true;
		add(_nameText);

		// Description
		_descText = new FunkinText(textX, 30, textW, '', 14);
		_descText.color = 0xFF9999AA;
		add(_descText);

		// Progress bar (for point-based achievements)
		var barY:Float = 50;
		var barW:Float = textW;
		_progressBar  = new FunkinSprite(textX, barY).makeSolid(Std.int(barW), 6, 0xFF333355);
		_progressFill = new FunkinSprite(textX, barY).makeSolid(1, 6, 0xFF66CC88);
		_progressText = new FunkinText(textX, barY - 14, barW, '', 12);
		_progressText.color = 0xFF66CC88;

		add(_progressBar);
		add(_progressFill);
		add(_progressText);
	}

	/**
	 * Fills this card with data from an achievement.
	 */
	public function populate(achievement:Achievement)
	{
		var unlocked:Bool = Achievements.isUnlocked(achievement.ID);

		// Tier colours (match the old repo's getAchievementLevelColor values)
		var accent:FlxColor = Achievements.getAchievementLevelColor(achievement.level);
		var achLevel:String = Achievements.getAchievementLevelString(achievement.level);

		// Background tint: greenish when unlocked, dark when locked
		_bg.color = unlocked ? 0xFF1A2E1A : 0xFF1A1A2E;

		// Icon border glow
		_iconBorder.color = unlocked ? accent : 0xFF2A2A44;

		// Load the per-achievement icon sprite (fall back to "test" if missing)
		var iconPath:String = Paths.image('achievements/${achievement.ID}');
		var safeIconPath:String = openfl.Assets.exists(iconPath) ? iconPath : Paths.image('achievements/test');
		_icon.loadGraphic(safeIconPath);
		_icon.setGraphicSize(Std.int(ICON_SIZE), Std.int(ICON_SIZE));
		_icon.updateHitbox();
		_icon.alpha = unlocked ? 1.0 : 0.35;

		// Load level badge icon
		var badgeKey:String = unlocked ? achLevel : 'locked';
		var badgePath:String = Paths.image('achievements/levels/$badgeKey');
		if (openfl.Assets.exists(badgePath))
		{
			_levelBadge.loadGraphic(badgePath);
			_levelBadge.setGraphicSize(Std.int(ICON_SIZE), Std.int(ICON_SIZE));
			_levelBadge.updateHitbox();
		}
		_levelBadge.x = _cardW - _levelBadge.width - PAD;
		_levelBadge.y = (62 - _levelBadge.height) / 2;

		// Name
		if (unlocked)
		{
			_nameText.text  = achievement.name;
			_nameText.color = 0xFFFFFFFF;
		}
		else
		{
			_nameText.text  = '???';
			_nameText.color = 0xFF666677;
		}

		// Description
		if (unlocked)
		{
			_descText.text  = achievement.description;
			_descText.color = 0xFF9999AA;
		}
		else
		{
			_descText.text  = Translations.translate('achievements.unknown');
			_descText.color = 0xFF555566;
		}

		// Progress bar (only for point-based, not yet unlocked)
		var showProgress:Bool = achievement.points != null && !unlocked;
		_progressBar.visible  = showProgress;
		_progressFill.visible = showProgress;
		_progressText.visible = showProgress;

		if (showProgress)
		{
			var progress:Int  = Achievements.getProgress(achievement.ID);
			var goal:Int      = achievement.points;
			var ratio:Float   = Math.min(progress / goal, 1.0);
			var barW:Float    = _progressBar.width;

			_progressFill.scale.x = Math.max(ratio, 0.01);
			_progressFill.updateHitbox();
			_progressText.text = '$progress / $goal';
		}
	}
}
