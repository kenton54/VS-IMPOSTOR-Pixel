import funkin.backend.assets.ModsFolder;
import funkin.backend.system.Logs;
import lime.app.Application;
import ImpostorFlags;

public static var storyState:Array<String> = [
    "start",
    "postTutorial",
    "postLobbyShowcase",
    "postWeek1",
    "",
    "",
    "postOminous"
];
public static var storySequence:Int = 0;

public static var impostorStats:Map<String, Dynamic> = [];

public static var playablesList:Map<String, Bool> = ["bf" => true];
public static var skinsList:Map<String, Map<String, Bool>> = [/*character => [skin => bought]*/];

public static var seenPlayables:Array<String> = ["bf"];

public static var pixelPlayable:String = "bf";

public static var pixelBeans:Int = 0;

public static var flags:ImpostorFlags;

public static var windowSizeMult:Float = 1;
public static var windowSizeRatio:Float = 1;
//public static var windowSizeHeightMult:Float = 1;

function new() {
    storySequence = FlxG.save.data.impPixelStorySequence;
    impostorStats = FlxG.save.data.impPixelStats;
    playablesList = FlxG.save.data.impPixelPlayablesUnlocked;
    skinsList = FlxG.save.data.impPixelSkinsUnlocked;
    pixelBeans = FlxG.save.data.impPixelBeans;
    flags = new ImpostorFlags();

    //customGameResize(FlxG.width, FlxG.height);

    //FlxG.signals.gameResized.add(customGameResize);
    Application.current.onExit.add(closeGame);
    ModsFolder.onModSwitch.add(onModSwitch);
}

/*
function customGameResize(width:Int, height:Int) {
    var daWidth:Float = width / 1280;
    var daHeight:Float = height / 720;
    var ratio:Float = daHeight / daWidth;
    windowSizeMult = daHeight;
    windowSizeRatio = ratio;
}
*/

function flushSaveData() {
    FlxG.save.data.impPixelStorySequence = storySequence;
    FlxG.save.data.impPixelStats = stats;
    FlxG.save.data.impPixelBeans = pixelBeans;
    FlxG.save.data.impPixelPlayablesUnlocked = playablesList;
    FlxG.save.data.impPixelSkinsUnlocked = skinsList;
    flags.save();

    FlxG.save.flush();

    /*
    Logs.traceColored([
        Logs.logText("[VS IMPOSTOR Pixel] ", 12),
        Logs.logText("Data succesfully saved!")
    ]);
    */
}

function destroy() {
    Application.current.onExit.remove(closeGame);
}

function closeGame() flushSaveData();

function onModSwitch() {
    ModsFolder.onModSwitch.remove(onModSwitch);
    flushSaveData();
}