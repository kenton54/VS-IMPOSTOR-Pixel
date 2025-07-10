import funkin.backend.system.framerate.Framerate;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.WindowUtils;
import lime.app.Application;
import StorySequenceManipulator;
import ImpostorFlags;

public var storySequence:Int = 0;

public static var playablesList:Map<String, Bool> = ["bf" => true];
public static var partnersList:Map<String, Bool> = ["gf" => true];
public static var skinsList:Array<String, Bool> = [];

public static var seenPlayables:Array<String> = ["bf"];

public static var pixelPlayable:String = "bf";

public var impPixelDebugMode:Bool = true;
var storySequenceDebugInfo:ImpostorStorySequence;
var flags:ImpostorFlags;

function new() {
    WindowUtils.winTitle = "VS IMPOSTOR Pixel";
    FlxSprite.defaultAntialiasing = false;

    if (impPixelDebugMode) {
        storySequenceDebugInfo = new ImpostorStorySequence();
        FlxG.addChildBelowMouse(storySequenceDebugInfo.sprite);
    }

    initSaveData();

    Application.current.onExit.add(closeGame);
}

function initSaveData() {
    FlxG.save.data.impPixelStorySequence ??= 0;
    FlxG.save.data.impPixelBeans ??= 0;
    FlxG.save.data.impPixelTimeBar ??= true;
    FlxG.save.data.impPixelxBRZ ??= false;
    FlxG.save.data.impPixelStrumBG ??= 0;
    FlxG.save.data.impPixelPlayablesUnlocked ??= ["bf" => true];
    FlxG.save.data.impPixelPartnersUnlocked ??= ["gf" => true];
    FlxG.save.data.impPixelSkinsUnlocked ??= [];
    FlxG.save.data.impPixelFlags ??= [];
    //if (FlxG.save.data.pixelPlayable == null) FlxG.save.data.pixelPlayable = "bf";
    //if (FlxG.save.data.pixelPartner == null) FlxG.save.data.pixelPartner = "gf";

    storySequence = FlxG.save.data.impPixelStorySequence;
    playablesList = FlxG.save.data.impPixelPlayablesUnlocked;
    partnersList = FlxG.save.data.impPixelPartnersUnlocked;
    flags = new ImpostorFlags().init();
}

function flushSaveData() {
    flags.save();
    FlxG.save.flush();
}

function update(elapsed:Float) {
    if (!impPixelDebugMode) return;

    if (FlxG.keys.justPressed.F5) reloadState();
    if (FlxG.keys.justPressed.F8) DiscordUtil.loadScript();
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
        if (Std.isOfType(FlxG.game._requestedState, redirectState))
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}

function closeGame() {
    trace("Saving Impostor Pixel data...");
    flushSaveData();
}

function destroy() {
    Application.current.onExit.remove(closeGame);
    if (impPixelDebugMode) storySequenceDebugInfo.destroy();
}