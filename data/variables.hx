import funkin.backend.system.Logs;
import lime.app.Application;
import ImpostorFlags;

public var storyState:Array<String> = [
    "start",
    "postLobbyShowcase",
    "postWeek1",
    "",
    "",
    "postOminous"
];
public var storySequence:Int = 0;

public static var playablesList:Map<String, Bool> = ["bf" => true];
public static var skinsList:Map<String, Map<String, Bool>> = [/*character => [skin => bought]*/];

public static var seenPlayables:Array<String> = ["bf"];

public static var pixelPlayable:String = "bf";

public static var pixelBeans:Int = 0;

public static var flags:ImpostorFlags;

function new() {
    storySequence = FlxG.save.data.impPixelStorySequence;
    playablesList = FlxG.save.data.impPixelPlayablesUnlocked;
    skinsList = FlxG.save.data.impPixelSkinsUnlocked;
    pixelBeans = FlxG.save.data.impPixelBeans;
    flags = new ImpostorFlags();

    Application.current.onExit.add(closeGame);
}

function flushSaveData() {
    FlxG.save.data.impPixelStorySequence = storySequence;
    FlxG.save.data.impPixelBeans = pixelBeans;
    FlxG.save.data.impPixelPlayablesUnlocked = playablesList;
    FlxG.save.data.impPixelSkinsUnlocked = skinsList;
    flags.save();

    FlxG.save.flush();

    Logs.traceColored([
        Logs.logText("[VS IMPOSTOR Pixel] ", 12),
        Logs.logText("Data succesfully saved!")
    ]);
}

function destroy() {
    Application.current.onExit.remove(closeGame);
    flushSaveData();
}

function closeGame() destroy();