package funkin.menus.achievements;

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;

import funkin.Paths;
import funkin.data.AchievementData;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.menus.mainmenu.MainMenuState;
import funkin.sound.FunkinSound;
import funkin.system.Achievements;
import funkin.system.Translations;
import funkin.ui.MusicBeatState;
import funkin.ui.StarsBackdrop;
import funkin.ui.StaticButton;
import funkin.ui.transitions.VerticalFade;

/**
 * The achievements screen.
 * Matches impostorAchievementsState: starfield, topBorder, X back-button.
 */
class AchievementsState extends MusicBeatState
{
	// ─── Constants ────────────────────────────────────────────────────────────────
	static final BASE_SCALE:Float = 5;

	/** Height of the topBorder image strip. */
	static final BORDER_H:Float = 8 * BASE_SCALE;

	/** Cards visible at once. */
	static final PAGE_SIZE:Int = 3;

	/** Card height in px. */
	static final CARD_H:Float = 180;

	/** Gap between cards in px. */
	static final CARD_GAP:Float = 8;

	/** Left/right margin. */
	static final CARD_MARGIN:Float = 14;

	// ─── Fields ───────────────────────────────────────────────────────────────────
	var _xButton:StaticButton;

	var _cards:Array<AchievementCard> = [];
	var _allAchievements:Array<AchievementData> = [];
	var _scrollOffset:Int = 0;

	var _counterText:FunkinText;

	/** Y position where the scrollbar track starts. */
	var _trackY:Float = 0;

	/** Total height of the scrollbar track. */
	var _trackH:Float = 0;

	var _scrollThumb:FunkinSprite;

	var _allowInput:Bool = false;

	// ─── Create ───────────────────────────────────────────────────────────────────

	override public function create()
	{
		super.create();

		FlxG.camera.bgColor = FlxColor.fromRGB(14, 14, 22);

		// ── Stars ─────────────────────────────────────────────────────────────────

		var stars:StarsBackdrop = new StarsBackdrop(-20, 4);
		add(stars);

		// ── Achievement cards ─────────────────────────────────────────────────────

		_buildList();
		_buildCards();

		// ── Top border (drawn over the cards so it always sits on top) ────────────

		var topBorder:FlxBackdrop = new FlxBackdrop(Paths.image('menus/general/topBorder'), FlxAxes.X);
		topBorder.scale.set(BASE_SCALE, BASE_SCALE);
		topBorder.updateHitbox();
		topBorder.scrollFactor.set(0, 0);
		add(topBorder);

		// ── Scrollbar track ───────────────────────────────────────────────────────

		var trackW:Int = 6;
		var trackX:Float = FlxG.width - CARD_MARGIN - trackW;
		_trackY = BORDER_H + 6;
		_trackH = FlxG.height - _trackY - 6;

		var scrollTrack:FunkinSprite = new FunkinSprite(trackX, _trackY).makeSolid(trackW, Std.int(_trackH), 0x33FFFFFF);
		scrollTrack.scrollFactor.set();
		add(scrollTrack);

		var thumbH:Float = Math.max(30, _trackH * (PAGE_SIZE / Math.max(_allAchievements.length, 1)));
		_scrollThumb = new FunkinSprite(trackX, _trackY).makeSolid(trackW, Std.int(thumbH), 0xCCFFFFFF);
		_scrollThumb.scrollFactor.set();
		add(_scrollThumb);

		// ── Unlock counter ────────────────────────────────────────────────────────

		_counterText = new FunkinText(0, BORDER_H + 6, FlxG.width - CARD_MARGIN * 2 - trackW - 4, '', 20);
		_counterText.alignment = RIGHT;
		_counterText.color = 0x88FFFFFF;
		_counterText.scrollFactor.set();
		add(_counterText);
		_updateCounter();

		// ── X back button (top-left, matching old state style) ────────────────────

		_xButton = new StaticButton(BASE_SCALE, BASE_SCALE, Paths.image('menus/x'), _goBack);
		_xButton.scaleSprite(BASE_SCALE);
		_xButton.scrollFactor.set();
		add(_xButton);

		// ── Populate everything now that all UI objects exist ─────────────────────

		_populateCards();

		FlxTimer.wait(0.2, () -> _allowInput = true);
	}

	// ─── Update ───────────────────────────────────────────────────────────────────

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!_allowInput)
			return;

		if (controls.UI_UP)
			_scroll(-1);
		else if (controls.UI_DOWN)
			_scroll(1);

		if (controls.BACK)
		{
			FunkinSound.playMenuSound(CANCEL);
			_goBack();
		}

		if (FlxG.mouse.wheel != 0)
			_scroll(-FlxG.mouse.wheel);
	}

	// ─── Helpers ─────────────────────────────────────────────────────────────────

	function _buildList()
	{
		_allAchievements = Achievements.achievements.copy();
		_allAchievements.sort((a, b) ->
		{
			var aU = Achievements.isUnlocked(a.ID);
			var bU = Achievements.isUnlocked(b.ID);
			if (aU != bU)
				return aU ? -1 : 1;
			return a.ID < b.ID ? -1 : 1;
		});
	}

	function _buildCards()
	{
		var cardY:Float = BORDER_H + 60;

		for (i in 0...PAGE_SIZE)
		{
			var card:AchievementCard = new AchievementCard(CARD_MARGIN, cardY + i * (CARD_H + CARD_GAP), FlxG.width - CARD_MARGIN * 2);
			card.scrollFactor.set();
			_cards.push(card);
			add(card);
		}
	}

	function _scroll(dir:Int)
	{
		var maxOffset:Int = Std.int(Math.max(0, _allAchievements.length - PAGE_SIZE));
		var newOffset:Int = Std.int(FlxMath.bound(_scrollOffset + dir, 0, maxOffset));
		if (newOffset == _scrollOffset)
			return;

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
		var maxOffset:Int = Std.int(Math.max(0, _allAchievements.length - PAGE_SIZE));

		if (maxOffset == 0)
		{
			_scrollThumb.visible = false;
			return;
		}

		_scrollThumb.visible = true;

		var thumbH:Float = _scrollThumb.height;
		var travelH:Float = _trackH - thumbH;
		var ratio:Float = _scrollOffset / maxOffset;

		_scrollThumb.y = _trackY + ratio * travelH;
	}

	function _updateCounter()
	{
		var total:Int = _allAchievements.length;
		var earned:Int = Achievements.achievementsUnlocked.length;
		_counterText.text = '$earned / $total';
	}

	function _goBack()
	{
		if (!_allowInput)
			return;
		_allowInput = false;
		FunkinSound.playMenuSound(CANCEL);
		MusicBeatState.setTransitions(VerticalFade);
		FlxG.switchState(() -> new MainMenuState());
	}

	override public function destroy()
	{
		super.destroy();
		_xButton.destroy();
	}
}

// ─── Achievement Card ──────────────────────────────────────────────────────

private class AchievementCard extends FunkinSpriteGroup
{
	static final ICON_SZ:Float = 160;
	static final PAD:Float = 14;
	static final CARD_H:Float = 180;

	var _bg:FunkinSprite;
	var _icon:flixel.FlxSprite;
	var _levelBadge:flixel.FlxSprite;
	var _nameText:FunkinText;
	var _descText:FunkinText;
	var _progressBar:FunkinSprite;
	var _progressFill:FunkinSprite;
	var _progressLabel:FunkinText;

	/** Full width of the progress bar in pixels. */
	var _barFullW:Float;

	var _cardW:Float;

	public function new(x:Float, y:Float, width:Float)
	{
		super(x, y);

		_cardW = width;

		// ── Background ────────────────────────────────────────────────────────────

		_bg = new FunkinSprite().makeSolid(Std.int(width), Std.int(CARD_H), 0xFF1A1A2E);
		add(_bg);

		var accentLine:FunkinSprite = new FunkinSprite().makeSolid(Std.int(width), 2, 0xFF2A2A55);
		add(accentLine);

		// ── Icon placeholder (sized to ICON_SZ so space is reserved before loadGraphic) ──

		_icon = new flixel.FlxSprite(PAD, (CARD_H - ICON_SZ) / 2);
		_icon.makeGraphic(Std.int(ICON_SZ), Std.int(ICON_SZ), 0x00000000, true); // unique transparent placeholder
		add(_icon);

		// ── Level badge ───────────────────────────────────────────────────────────

		_levelBadge = new flixel.FlxSprite();
		_levelBadge.makeGraphic(Std.int(ICON_SZ), Std.int(ICON_SZ), 0x00000000, true);
		add(_levelBadge);

		// ── Text ─────────────────────────────────────────────────────────────────

		var textX:Float = PAD + ICON_SZ + PAD;
		var textW:Float = width - textX - ICON_SZ - PAD * 2;

		_nameText = new FunkinText(textX, 16, textW, '', 28);
		_nameText.bold = true;
		add(_nameText);

		_descText = new FunkinText(textX, 56, textW, '', 17);
		_descText.color = 0xFF9999AA;
		add(_descText);

		// ── Progress bar ─────────────────────────────────────────────────────────
		// Use makeGraphic(unique:true) so we can resize the fill each frame.

		var barY:Float = CARD_H - 28;
		_barFullW = textW;

		_progressBar = new FunkinSprite(textX, barY).makeGraphic(Std.int(_barFullW), 8, 0xFF1E1E3A, true);
		_progressFill = new FunkinSprite(textX, barY).makeGraphic(1, 8, 0xFF66CC88, true);

		_progressLabel = new FunkinText(textX, barY - 20, textW, '', 13);
		_progressLabel.color = 0xFF66CC88;
		_progressLabel.alignment = RIGHT;

		add(_progressBar);
		add(_progressFill);
		add(_progressLabel);
	}

	/**
	 * Fill this card with data from an achievement.
	 */
	public function populate(achievement:AchievementData)
	{
		var unlocked:Bool = Achievements.isUnlocked(achievement.ID);
		var accent:FlxColor = Achievements.getAchievementLevelColor(achievement.level);
		var achLevel:String = Achievements.getAchievementLevelString(achievement.level);

		// Background tint
		_bg.color = unlocked ? 0xFF152015 : 0xFF12121E;

		// ── Icon ─────────────────────────────────────────────────────────────────

		var iconPath:String = Paths.image('achievements/${achievement.ID}');
		var safeIcon:String = openfl.Assets.exists(iconPath) ? iconPath : Paths.image('achievements/test');
		_icon.loadGraphic(safeIcon);
		_icon.setGraphicSize(Std.int(ICON_SZ), Std.int(ICON_SZ));
		_icon.updateHitbox();
		_icon.antialiasing = false;
		_icon.x = PAD;
		_icon.y = (CARD_H - ICON_SZ) / 2;
		_icon.alpha = unlocked ? 1.0 : 0.25;

		// ── Level badge ───────────────────────────────────────────────────────────

		var badgeKey:String = unlocked ? achLevel : 'locked';
		var badgePath:String = Paths.image('achievements/levels/$badgeKey');
		if (openfl.Assets.exists(badgePath))
		{
			_levelBadge.loadGraphic(badgePath);
			_levelBadge.setGraphicSize(Std.int(ICON_SZ), Std.int(ICON_SZ));
			_levelBadge.updateHitbox();
			_levelBadge.antialiasing = false;
		}
		_levelBadge.x = _cardW - _levelBadge.width - PAD;
		_levelBadge.y = (CARD_H - _levelBadge.height) / 2;
		_levelBadge.alpha = unlocked ? 1.0 : 0.35;

		// ── Text ─────────────────────────────────────────────────────────────────

		_nameText.text = unlocked ? achievement.name : '???';
		_nameText.color = unlocked ? 0xFFFFFFFF : 0xFF666677;

		_descText.text = unlocked ? achievement.description : Translations.translate('achievements.unknown');
		_descText.color = unlocked ? 0xFF9999AA : 0xFF555566;

		// ── Progress bar ─────────────────────────────────────────────────────────

		var showProgress:Bool = achievement.maxPoints != null && !unlocked;
		_progressBar.visible = showProgress;
		_progressFill.visible = showProgress;
		_progressLabel.visible = showProgress;

		if (showProgress)
		{
			var progress:Int = Achievements.getProgress(achievement.ID);
			var goal:Int = achievement.maxPoints;
			var ratio:Float = Math.min(progress / goal, 1.0);

			// Resize the fill graphic directly — no scale tricks needed.
			var fillW:Int = Std.int(Math.max(2, _barFullW * ratio));
			_progressFill.makeGraphic(fillW, 8, 0xFF66CC88, true);

			_progressLabel.text = '$progress / $goal';
		}
	}
}
