import flixel.sound.FlxSound;
import flixel.util.FlxBaseSignal;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.TranslationUtil;
import funkin.backend.MusicBeatTransition;
import funkin.options.Options;
import lime.system.JNI; // JNI stands for JavaNativeInterface
import openfl.display.BlendMode;
import Sys;

public static var storyStates:Array<String> = [
    "start",
    "postTutorial",
    "postLobbyShowcase",
    "postWeek1",
    "postOminous"
];
public static var storySequence:Int = 0;

public static var playablesList:Map<String, Bool> = ["bf" => true];
public static var skinsList:Map<String, Map<String, Bool>> = [/*character => [skin => bought]*/];

public static var seenPlayables:Array<String> = ["bf"];

public static var pixelPlayable:String = "bf";

public static var pixelBeans:Int = 0;

public static var globalUsingKeyboard:Bool = false;

public static var isPlayingVersus:Bool = false;

final defaultTransition:String = "bottom2topSmoothSquare";
public static function setTransition(transitionID:String) {
    //trace("Setting transition to: " + (transitionID == "" ? "Default" : transitionID));

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

public static function dispatchSignal(signal:FlxBaseSignal, ?parameter1:Dynamic, ?parameter2:Dynamic, ?parameter3:Dynamic, ?parameter4:Dynamic, ?parameter5:Dynamic, ?parameter6:Dynamic) {
    for (handler in signal.handlers) {
        handler.listener(parameter1, parameter2, parameter3, parameter4, parameter5, parameter6);
    }
}

public static function getPlatform():String {
    #if desktop
    return "desktop";
    #elseif mobile
    return "mobile";
    #elseif web
    return "web";
    #else
    return "unknown";
    #end
}

public static function getTarget():String {
    #if windows
    return "windows";
    #elseif linux
    return "linux";
    #elseif mac
    return "mac";
    #elseif android
    return "android";
    #elseif ios
    return "ios";
    #elseif html5
    return "html5";
    #elseif flash
    return "flash"; // there's 0% chance youll get this returned
    #elseif switch
    return "switch";
    #else
    return "unknown";
    #end
}

// this function can only be executed on real mobile targets
public static function createJNIStaticMethod(className:String, methodName:String, signature:String):Null<Dynamic> {
    if (FlxG.onMobile) {
        className = JNI.transformClassName(className);
        return JNI.createStaticMethod(className, methodName, signature);
    }

    return null;
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