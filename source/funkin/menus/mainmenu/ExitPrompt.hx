package funkin.menus.mainmenu;

import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.input.Controls;
import funkin.input.InputManager;
import funkin.input.Pointer;

/**
 * The exit-confirmation prompt shown when the player tries to quit the game.
 *
 * Ported from the old repo (`impostor.menus.mainmenu.ExitPrompt`) and
 * adapted to the new codebase's conventions.
 */
class ExitPrompt extends MusicBeatSubState
{
	/**
	 * Dispatches when the user confirms the exit (Yes).
	 */
	public var onConfirmExit:FlxSignal = new FlxSignal();

	/**
	 * Dispatches when the user cancels the exit (No / Back).
	 */
	public var onCancelExit:FlxSignal = new FlxSignal();

	// Layout constants (pixel-art scale matches the main menu's BASE_SCALE = 5)
	static final BASE_SCALE:Float = 5;
	static final BOX_W:Float = 128; // in sprite pixels → ×5 on screen
	static final BOX_H:Float = 36;

	var _camera:FlxCamera;

	var _overlay:FunkinSprite;
	var _box:FunkinSprite;
	var _promptText:FunkinText;
	var _noText:FunkinText;
	var _yesText:FunkinText;

	var _curSelection:ExitPromptOption = NONE;
	var _lastHovered:ExitPromptOption = NONE;

	var _allowInput:Bool = false;

	override public function create()
	{
		super.create();

		// Dedicated camera so the prompt floats above everything else
		_camera = new FlxCamera();
		_camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(_camera, false);
		camera = _camera;

		// Dim overlay
		_overlay = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		_overlay.scrollFactor.set();
		_overlay.alpha = 0;
		add(_overlay);

		// Box background
		var boxW:Float = BOX_W * BASE_SCALE;
		var boxH:Float = BOX_H * BASE_SCALE;

		_box = new FunkinSprite((FlxG.width - boxW) / 2, (FlxG.height - boxH) / 2).makeSolid(Std.int(boxW), Std.int(boxH), 0xFF2B2B2B);
		_box.scrollFactor.set();
		_box.alpha = 0;
		add(_box);

		// Thin top/bottom accent lines on the box
		var lineTop:FunkinSprite = new FunkinSprite(_box.x, _box.y).makeSolid(Std.int(boxW), Std.int(BASE_SCALE), 0xFF45706D);
		lineTop.scrollFactor.set();
		add(lineTop);

		var lineBottom:FunkinSprite = new FunkinSprite(_box.x, _box.y + boxH - BASE_SCALE).makeSolid(Std.int(boxW), Std.int(BASE_SCALE), 0xFF45706D);
		lineBottom.scrollFactor.set();
		add(lineBottom);

		// Prompt text
		var textPad:Float = BASE_SCALE * 4;
		_promptText = new FunkinText(_box.x + textPad, _box.y + BASE_SCALE * 4, boxW - textPad * 2, '', 24);
		_promptText.translationData = {id: 'mainMenu.exitPrompt'};
		_promptText.alignment = CENTER;
		_promptText.scrollFactor.set();
		_promptText.alpha = 0;
		add(_promptText);

		// "No" button (left side)
		_noText = new FunkinText(0, _box.y + boxH * 0.6, boxW * 0.4, '', 30);
		_noText.translationData = {id: 'no'};
		_noText.alignment = CENTER;
		_noText.x = _box.x + boxW * 0.05;
		_noText.scrollFactor.set();
		_noText.alpha = 0;
		add(_noText);

		// "Yes" button (right side)
		_yesText = new FunkinText(0, _noText.y, boxW * 0.4, '', 30);
		_yesText.translationData = {id: 'yes'};
		_yesText.alignment = CENTER;
		_yesText.x = _box.x + boxW * 0.55;
		_yesText.scrollFactor.set();
		_yesText.alpha = 0;
		add(_yesText);

		// Default selection: No
		_curSelection = NO;
		_updateSelection();

		// Animate in
		FlxTween.tween(_overlay, {alpha: 0.6}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(_box, {alpha: 1}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(_promptText, {alpha: 1}, 0.3, {startDelay: 0.1, ease: FlxEase.quadOut});
		FlxTween.tween(_noText, {alpha: 0.5}, 0.3, {startDelay: 0.1, ease: FlxEase.quadOut,
			onComplete: (_) -> { _allowInput = true; }});
		FlxTween.tween(_yesText, {alpha: 0.5}, 0.3, {startDelay: 0.1, ease: FlxEase.quadOut});

		FunkinSound.playMenuSound(CANCEL);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!_allowInput)
			return;

		if (InputManager.usingControls)
			_handleInput();
		else if (FlxG.onMobile)
			_handleTouch();
		else
			_handleMouse();
	}

	// ─── Input handling ───────────────────────────────────────────────────────────

	function _handleInput()
	{
		if (controls.UI_LEFT)
		{
			if (_curSelection != NO)
			{
				_curSelection = NO;
				_updateSelection();
				FunkinSound.playMenuSound();
			}
		}
		else if (controls.UI_RIGHT)
		{
			if (_curSelection != YES)
			{
				_curSelection = YES;
				_updateSelection();
				FunkinSound.playMenuSound();
			}
		}

		if (controls.ACCEPT)
			_checkSelection();

		if (controls.BACK)
			_decline();
	}

	function _handleMouse()
	{
		var hovering:ExitPromptOption = NONE;

		if (Pointer.overlaps(_noText, _camera))
			hovering = NO;
		else if (Pointer.overlaps(_yesText, _camera))
			hovering = YES;

		if (hovering != NONE && hovering != _lastHovered)
		{
			_lastHovered = hovering;
			_curSelection = hovering;
			_updateSelection();
			FunkinSound.playMenuSound();
		}
		else if (hovering == NONE)
		{
			_lastHovered = NONE;
		}

		if (Pointer.justReleased)
			_checkSelection();
	}

	function _handleTouch()
	{
		for (touch in FlxG.touches.list)
		{
			var hovering:ExitPromptOption = NONE;

			if (touch.overlaps(_noText, _camera))
				hovering = NO;
			else if (touch.overlaps(_yesText, _camera))
				hovering = YES;

			if (hovering != NONE && hovering != _lastHovered)
			{
				_lastHovered = hovering;
				_curSelection = hovering;
				_updateSelection();
				FunkinSound.playMenuSound();
			}

			if (touch.justReleased && hovering != NONE)
				_checkSelection();
		}
	}

	// ─── Option logic ─────────────────────────────────────────────────────────────

	function _updateSelection()
	{
		_noText.alpha = (_curSelection == NO) ? 1.0 : 0.4;
		_yesText.alpha = (_curSelection == YES) ? 1.0 : 0.4;
	}

	function _checkSelection()
	{
		switch (_curSelection)
		{
			case YES: _accept();
			case NO: _decline();
			case NONE: // do nothing
		}
	}

	function _accept()
	{
		_allowInput = false;
		FunkinSound.playMenuSound(CONFIRM);

		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(1.0);

		FlxTween.tween(_overlay, {alpha: 1}, 0.8, {ease: FlxEase.quadIn});

		flixel.util.FlxTimer.wait(1.05, () ->
		{
			onConfirmExit.dispatch();
			lime.system.System.exit(0);
		});
	}

	function _decline()
	{
		_allowInput = false;
		FunkinSound.playMenuSound(CANCEL);

		FlxTween.tween(_overlay, {alpha: 0}, 0.2, {ease: FlxEase.quadOut});
		FlxTween.tween(_box, {alpha: 0}, 0.2, {ease: FlxEase.quadOut,
			onComplete: (_) ->
			{
				onCancelExit.dispatch();
				close();
			}
		});
	}

	override public function destroy()
	{
		super.destroy();

		FlxG.cameras.remove(_camera);
		FlxDestroyUtil.destroy(_camera);
		FlxDestroyUtil.destroy(onConfirmExit);
		FlxDestroyUtil.destroy(onCancelExit);
	}
}

private enum ExitPromptOption
{
	NONE;
	YES;
	NO;
}
