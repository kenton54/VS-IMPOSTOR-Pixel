package funkin.ui.debug;

import flixel.util.FlxStringUtil;

import funkin.input.FunkinAction;
import funkin.input.InputManager;
import funkin.system.FunkinMemory;
import funkin.system.Translations;
import funkin.utils.DrawUtil;
import funkin.utils.MemoryUtil;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

class AdvancedDisplay extends Sprite
{
	var textField:TextField;
	var background:Shape;

	public function new(x:Float = 0, y:Float = 0)
	{
		super();

		this.x = x;
		this.y = y;

		background = new Shape();
		background.alpha = 0.6;
		addChild(background);

		textField = new TextField();
		textField.autoSize = LEFT;
		textField.selectable = true;
		textField.mouseEnabled = false;
		textField.defaultTextFormat = new TextFormat(Constants.DEFAULT_FONT, 14, 0xFFFFFF);
		addChild(textField);
	}

	override function __enterFrame(deltaTime:Int)
	{
		if (!visible)
		{
			return;
		}

		var infoArray:Array<String> = [];

		infoArray.push('FPS: ${Main.debugOverlay.simple.currentFPS}');
		infoArray.push('Update Time: ${deltaTime}ms');
		infoArray.push('');
		infoArray.push('GC Memory: ${getGCMemory()}');
		infoArray.push('App Process Memory: ${getProcessMemory()}');
		infoArray.push('');
		infoArray.push('Debug Build: ${Constants.DEBUG_BUILD}');
		infoArray.push('');
		infoArray.push('Song Position: ${FlxStringUtil.formatTime(Conductor.songPosition / 1000, true)} | ${FlxStringUtil.formatTime(Conductor.songLength / 1000, true)} (${Math.round(Conductor.songPercent * 100)}%)');
		infoArray.push('Song BPM: ${Conductor.curBPM}');
		infoArray.push('Song Measure: ${Conductor.curMeasure}');
		infoArray.push('Song Beat: ${Conductor.curBeat}');
		infoArray.push('Song Step: ${Conductor.curStep}');
		infoArray.push('Song Time Signature: ${Conductor.timeSignatureNum}/${Conductor.timeSignatureDen}');
		infoArray.push('Conductor Standalone Mode: ${Conductor.standalone}');
		infoArray.push('');
		infoArray.push('Active Input: ${InputManager.usingControls ? (FunkinAction.lastDeviceUsed == GAMEPAD ? 'Gamepad' : 'Keyboard') : (FlxG.onMobile ? 'Touch' : 'Mouse')}');
		infoArray.push('Connected Gamepads: ${FlxG.gamepads.numActiveGamepads}');
		infoArray.push('');
		infoArray.push('Game Resolution: ${FlxG.width}x${FlxG.height}');
		infoArray.push('Game Volume: ${FlxG.sound.volume * 100}%');
		infoArray.push('Game Muted: ${FlxG.sound.muted}');

		// this crashes on web targets
		#if !web
		infoArray.push('State: ${FlxStringUtil.getClassName(FlxG.state)}');
		infoArray.push('SubState: ${FlxStringUtil.getClassName(FlxG.state.subState)}');
		#end

		infoArray.push('Objects Count: ${getStateMemberCount()}');
		infoArray.push('Bitmaps Count: ${@:privateAccess FlxG.bitmap._cache.count()}');
		infoArray.push('Sounds Count: ${FlxG.sound.list.length}');
		infoArray.push('Cameras Count: ${FlxG.cameras.list.length}');
		infoArray.push('Children Count: ${FlxG.game.numChildren}');
		infoArray.push('');
		infoArray.push('Total Loaded: ${FlxStringUtil.formatBytes(FunkinMemory.bytesLoaded)}');
		@:privateAccess
		{
			infoArray.push('Cached Graphics: ${FunkinMemory.cachedGraphics.count()}');
			infoArray.push('Cached Sounds: ${FunkinMemory.cachedSounds.count()}');
			infoArray.push('Temporary Cached Graphics: ${FunkinMemory.temporalCachedGraphics.count()}');
		}
		infoArray.push('');
		infoArray.push('Game Language: ${Translations.curLanguageID}');
		infoArray.push('System Language: ${Translations.getUserLanguage()}');

		textField.text = infoArray.join('\n');

		super.__enterFrame(deltaTime);

		drawBackground();
	}

	function getGCMemory():String
	{
		#if web
		return 'Not supported for Web targets';
		#else
		return FlxStringUtil.formatBytes(MemoryUtil.getGCMemory());
		#end
	}

	function getProcessMemory():String
	{
		#if web
		return 'Not supported for Web targets';
		#else
		return FlxStringUtil.formatBytes(MemoryUtil.getProcessMemory());
		#end
	}

	function getStateMemberCount():Int
	{
		var length:Int = getGroupMemberCount(FlxG.state);

		if (FlxG.state.subState != null)
		{
			length += getGroupMemberCount(FlxG.state.subState);
		}

		return length;
	}

	@:access(flixel.group.FlxTypedGroup)
	function getGroupMemberCount(group:FlxGroup):Int
	{
		var length:Int = 0;

		if (group != null)
		{
			for (member in group.members)
			{
				length++;

				var group = FlxTypedGroup.resolveGroup(member);
				if (group != null)
				{
					length += getGroupMemberCount(group);
				}
			}
		}

		return length;
	}

	function drawBackground()
	{
		background.graphics.clear();
		DrawUtil.drawTextFieldBackground(background.graphics, textField, FlxColor.BLACK);
	}
}
