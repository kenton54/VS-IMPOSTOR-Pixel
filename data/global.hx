import funkin.backend.assets.ModsFolder;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.Logs;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.WindowUtils;
import lime.app.Application;
import StorySequenceManipulator;
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
//public static var partnersList:Map<String, Bool> = ["gf" => true];
public static var skinsList:Map<String, Map<String, Bool>> = [/*character => [skin => bought]*/];

public static var seenPlayables:Array<String> = ["bf"];

public static var pixelPlayable:String = "bf";

public static var pixelBeans:Int = 0;

public var impPixelDebugMode:Bool = true;
var storySequenceDebugInfo:ImpostorStorySequence;
var flags:ImpostorFlags = new ImpostorFlags();

function new() {
    WindowUtils.winTitle = "VS IMPOSTOR Pixel";
    FlxSprite.defaultAntialiasing = false;

    if (impPixelDebugMode) {
        storySequenceDebugInfo = new ImpostorStorySequence();
        FlxG.addChildBelowMouse(storySequenceDebugInfo.sprite);
    }

    initSaveData();

    Application.current.onExit.add(closeGame);
    ModsFolder.onModSwitch.add(onModSwitch);
}

function initSaveData() {
    // Options
    FlxG.save.data.impPixelTimeBar ??= true;
    FlxG.save.data.impPixelxBRZ ??= false;
    FlxG.save.data.impPixelStrumBG ??= 0;

    // Mod Source
    FlxG.save.data.impPixelStorySequence ??= 0;
    FlxG.save.data.impPixelBeans ??= 0;
    FlxG.save.data.impPixelPlayablesUnlocked ??= ["bf" => true];
    //FlxG.save.data.impPixelPartnersUnlocked ??= ["gf" => true];
    FlxG.save.data.impPixelSkinsUnlocked ??= [];
    FlxG.save.data.impPixelFlags ??= [];

    storySequence = FlxG.save.data.impPixelStorySequence;
    playablesList = FlxG.save.data.impPixelPlayablesUnlocked;
    //partnersList = FlxG.save.data.impPixelPartnersUnlocked;
    flags.load(FlxG.save.data.impPixelFlags);
}

function flushSaveData() {
    FlxG.save.data.impPixelStorySequence = storySequence;
    FlxG.save.data.impPixelBeans = pixelBeans;
    FlxG.save.data.impPixelPlayablesUnlocked = playablesList;
    FlxG.save.data.impPixelSkinsUnlocked = skinsList;
    flags.save();

    FlxG.save.flush();
}

function update(elapsed:Float) {
    if (impPixelDebugMode) {
        if (FlxG.keys.justPressed.F5) reloadState();
    }
}

function reloadState() {
    FlxG.resetState();
}

// da states
var redirectStates:Map<FlxState, String> = [
    TitleState => "impostorTitleState"
    //MainMenuState => "impostorMenuState",
    FreeplayState => "impostorFreeplayState"
];

// the actual state modification
function preStateSwitch() {
    for (redirectState in redirectStates.keys())
        if (FlxG.game._requestedState is redirectState)
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}

function closeGame() {
    Logs.traceColored([
        Logs.logText("[VS IMPOSTOR Pixel] ", 12),
        Logs.logText("Saving Impostor Pixel data...")
    ]);
    flushSaveData();
}

function onModSwitch() {
    Application.current.onExit.remove(closeGame);
    if (impPixelDebugMode) storySequenceDebugInfo.destroy();

    flushSaveData();
}