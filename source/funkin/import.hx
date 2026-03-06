package funkin;

#if !macro
#if DISCORD_API
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
import flixel.util.FlxTimer;

import funkin.Defaults;
import funkin.Paths;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.sound.FunkinSound;
import funkin.system.Achievements;
import funkin.system.Conductor;
import funkin.system.Translations;
import funkin.utils.Assets;
import funkin.utils.MathUtil;

using StringTools;
#end
