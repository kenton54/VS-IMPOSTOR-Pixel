import flixel.sound.FlxSound;
import flixel.util.FlxBaseSignal;
import funkin.backend.system.Flags;
import funkin.backend.system.Logs;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.TranslationUtil;
import funkin.backend.MusicBeatTransition;
import funkin.options.Options;
import openfl.display.BlendMode;

public static var storyStates:Array<String> = [
    "start",
    "postTutorial",
    "postLobbyShowcase",
    "postWeek1",
    "postOminous"
];
public static var storySequence:Int = 0;

public static final defaultStats:Map<String, Dynamic> = [
    "storyProgress" => "start",
    "totalNotes" => 0,
    "perfectNotes" => 0,
    "sickNotes" => 0,
    "goodNotes" => 0,
    "badNotes" => 0,
    "shitNotes" => 0,
    "missedNotes" => 0,
    "combosBroken" => 0,
    "attacksDodged" => 0,
    "taskSpeedrunSkeld" => 0.0,
    "taskSpeedrunMira" => 0.0,
    "taskSpeedrunPolus" => 0.0,
    "taskSpeedrunAirship" => 0.0,
    "totalTasks" => 0
];
public static var impostorStats:Map<String, Dynamic> = [];

public static var playablesList:Map<String, Bool> = ["bf" => true];
public static var skinsList:Map<String, Map<String, Bool>> = [/*character => [skin => bought]*/];

public static var seenPlayables:Array<String> = ["bf"];

public static var pixelPlayable:String = "bf";

public static var pixelBeans:Int = 0;

public static var globalUsingKeyboard:Bool = false;

public static var isPlayingVersus:Bool = false;

public static var isMobile:Bool = FlxG.onMobile;
public static var fakeMobile:Bool = false;

public static function setMobile(bool:Bool) {
    if (FlxG.onMobile) {
        isMobile = FlxG.onMobile;
        fakeMobile = !FlxG.onMobile;
    }
    else {
        if (!FlxG.onMobile) {
            isMobile = bool;
            fakeMobile = bool;
        }
    }
}

final defaultTransition:String = "bottom2topSmoothSquare";
public static function setTransition(transitionID:String) {
    trace("Setting transition to: " + (transitionID == "" ? "Default" : transitionID));

    if (transitionID == "")
        MusicBeatTransition.script = "data/transitions/" + defaultTransition;
    else
        MusicBeatTransition.script = "data/transitions/" + transitionID;
}

public static function translate(id:String, ?customValues:Array<Dynamic> = []):String {
    return TranslationUtil.translate(id, customValues);
}

public static function changeDiscordMenuStatus(menu:String) {
    DiscordUtil.call("onMenuLoaded", [menu]);
}

public static function changeDiscordEditorStatus(menu:String) {
    DiscordUtil.call("onEditorTreeLoaded", [menu]);
}

public static function lerp(value1:Float, value2:Float, ratio:Float, ?fpsSensitive:Bool):Float {
    if (fpsSensitive == null) fpsSensitive = false;

    if (fpsSensitive)
        return FlxMath.lerp(value1, value2, ratio);
    else
        return CoolUtil.fpsLerp(value1, value2, ratio);
}

public static function getStats(?def:Bool):Map<String, Dynamic> {
    var map:Map<String, Dynamic> = [];

    if (def) {
        for (stat in defaultStats.keyValueIterator()) {
            map.set(stat.key, stat.value);
        }
    }
    else {
        for (stat in impostorStats.keyValueIterator()) {
            map.set(stat.key, stat.value);
        }
    }

    return map;
}

public static function getStatName(id:String):Null<String> {
    var success:Bool = false;

    for (stat in impostorStats.keys()) {
        if (stat == id) {
            success = true;
            return translate("mainMenu.stats." + stat);
        }
    }

    trace(id, "doesnt exist, using default...");

    if (!success) {
        for (stat in defaultStats.keys()) {
            if (stat == id) {
                success = true;
                return translate("mainMenu.stats." + stat);
            }
        }
    }

    if (!success)
        throw 'Stat ID "'+id+'" doesn\'t exist!';

    return null;
}

public static function getStatValue(id:String):Dynamic {
    if (!defaultStats.exists(id)) throw 'Stat ID "'+id+'" doesn\'t exist!';

    if (impostorStats.exists(id))
        return impostorStats.get(id);
    else
        return defaultStats.get(id);
}

public static function setBlendMode(blend:String):BlendMode {
    switch(blend) {
        case "add": return BlendMode.ADD;
        case "alpha": return BlendMode.ALPHA;
        case "darken": return BlendMode.DARKEN;
        case "difference": return BlendMode.DIFFERENCE;
        case "erase": return BlendMode.ERASE;
        case "hardlight": return BlendMode.HARDLIGHT;
        case "invert": return BlendMode.INVERT;
        case "layer": return BlendMode.LAYER;
        case "lighten": return BlendMode.LIGHTEN;
        case "multiply": return BlendMode.MULTIPLY;
        case "normal": return BlendMode.NORMAL;
        case "overlay": return BlendMode.OVERLAY;
        case "screen": return BlendMode.SCREEN;
        case "shader": return BlendMode.SHADER;
        case "subtract": return BlendMode.SUBTRACT;
        default: return null;
    }
}

public static function playSound(sound:String, ?volume:Float) {
    volume ??= 1;
    FlxG.sound.play(Paths.sound(sound), volume * Options.volumeSFX);
}

/**
 * Plays a sound that persists between menus.
 * 
 * If you don't understand, the sound won't stop playing when switching states.
 * 
 * @param sound The sound file inside the "sounds/menu" folder.
 * @param volume The volume the sound should play at.
 */
public static function playMenuSound(sound:String, ?volume:Float) {
    volume = (volume == null) ? 1 : volume;

    var soundPath:String = Paths.sound("menu/" + sound);
    var menuSound:FlxSound = new FlxSound().loadEmbedded(soundPath, false, true);
    menuSound.volume = volume * Options.volumeSFX;
    menuSound.persist = true;
    menuSound.play();
}

public static function createMultiLineText(texts:Array<String>):String {
    var wholeText:String = "";
    var max:Int = texts.length - 1;
    for (i => text in texts) {
        wholeText += text;
        if (!(i >= max)) wholeText += '\n';
    }

    return wholeText;
}

public static function logTraceColored(text:Array<LogText>, ?level:String) {
    Logs.traceColored(text, getLogLevel(level));
}

public static function getLogLevel(string:String):Int {
    switch(string) {
        case "info": return 0;
        case "warning": return 1;
        case "error": return 2;
        case "trace": return 3;
        case "verbose": return 4;
        case "success": return 5;
        case "failure": return 6;
        default: return 0;
    }
}

public static function getLogColor(color:String):Int {
    switch(color) {
        case "black": return 0;
        case "darkBlue": return 1;
        case "darkGreen": return 2;
        case "darkCyan": return 3;
        case "darkRed": return 4;
        case "darkMagenta": return 5;
        case "darkYellow": return 6;
        case "lightGray": return 7;
        case "gray": return 8;
        case "blue": return 9;
        case "green": return 10;
        case "cyan": return 11;
        case "red": return 12;
        case "magenta": return 13;
        case "yellow": return 14;
        case "white": return 15;
        default: return -1;
    }
}

public static function dispatchSignal(signal:FlxBaseSignal, ?parameter1:Dynamic, ?parameter2:Dynamic, ?parameter3:Dynamic, ?parameter4:Dynamic, ?parameter5:Dynamic, ?parameter6:Dynamic) {
    for (handler in signal.handlers) {
        handler.listener(parameter1, parameter2, parameter3, parameter4, parameter5, parameter6);
    }
}

public static function shuffleTable(table:Array<Dynamic>) {
    var maxValidIndex = table.length - 1;
    for (i in 0...maxValidIndex) {
        var j = FlxG.random.int(i, maxValidIndex);
        var tmp = table[i];
        table[i] = table[j];
        table[j] = tmp;
    }
}

public static function resizeGame(width:Int, height:Int) {
    FlxG.initialWidth = width;
    FlxG.initialHeight = height;
    FlxG.width = width;
    FlxG.height = height;
}

public static function resizeWindow(width:Int, height:Int) {
    window.resize(width, height);
}

public static function saveImpostor() {
    FlxG.save.data.impPixelStorySequence = storySequence;
    FlxG.save.data.impPixelBeans = pixelBeans;
    FlxG.save.data.impPixelStats = getStats();
    FlxG.save.data.impPixelPlayablesUnlocked = playablesList;
    FlxG.save.data.impPixelSkinsUnlocked = skinsList;
    FlxG.save.data.impPixelFlags = getFlags();

    logTraceColored([
        {text: "[VS IMPOSTOR Pixel] ", color: getLogColor("red")},
        {text: "Data saved!", color: getLogColor("green")}
    ], "verbose");

    FlxG.save.flush();
}

public static function eraseImpostorSaveData() {
    storySequence = 0;
    impostorStats.clear();
    playablesList.clear();
    playablesList.set("bf", true);
    skinsList.clear();
    pixelBeans = 0;
    resetFlags();

    FlxG.save.data.impPixelStorySequence = null;
    FlxG.save.data.impPixelBeans = null;
    FlxG.save.data.impPixelStats = null;
    FlxG.save.data.impPixelPlayablesUnlocked = null;
    FlxG.save.data.impPixelSkinsUnlocked = null;
    FlxG.save.data.impPixelFlags = null;
}