package funkin;

#if !macro
#if FEATURE_DISCORD_API
import funkin.api.DiscordClient;
#end

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import funkin.Constants;
import funkin.Paths;
import funkin.graphics.FunkinGroup;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.input.Pointer;
import funkin.input.Swipe;
import funkin.sound.FunkinSound;
import funkin.system.Conductor;
import funkin.utils.MathUtil;

import openfl.utils.Assets;

using Lambda;
using StringTools;

using funkin.utils.tools.FloatTools;
using funkin.utils.tools.IntTools;

using thx.Arrays;
#end
