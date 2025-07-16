import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.Logs;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.WindowUtils;
import StorySequenceManipulator;

var impPixelDebugMode:Bool = true;
var storySequenceDebugInfo:ImpostorStorySequence;

function new() {
    WindowUtils.winTitle = "VS IMPOSTOR Pixel";
    FlxSprite.defaultAntialiasing = false;

    if (impPixelDebugMode) {
        storySequenceDebugInfo = new ImpostorStorySequence();
        FlxG.addChildBelowMouse(storySequenceDebugInfo.sprite);
    }

    initSaveData();

    Application.current.window.minWidth = 1280;
    Application.current.window.minHeight = 720;
    //gameResized(Application.current.window.width, Application.current.window.height);

    Application.current.onExit.add(closeGame);
}

function initSaveData() {
    // Options
    FlxG.save.data.impPixelTimeBar ??= true;
    FlxG.save.data.impPixelxBRZ ??= false;
    FlxG.save.data.impPixelStrumBG ??= 0;

    // Mod Source
    FlxG.save.data.impPixelStorySequence ??= 0;
    FlxG.save.data.impPixelBeans ??= 0;
    FlxG.save.data.impPixelStats = [];
    FlxG.save.data.impPixelPlayablesUnlocked ??= ["bf" => true];
    //FlxG.save.data.impPixelPartnersUnlocked ??= ["gf" => true];
    FlxG.save.data.impPixelSkinsUnlocked ??= [];
    FlxG.save.data.impPixelFlags ??= [];
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
    MainMenuState => "impostorMenuState",
    FreeplayState => "impostorFreeplayState"
];

// the actual state modification
function preStateSwitch() {
    for (redirectState in redirectStates.keys())
        if (FlxG.game._requestedState is redirectState)
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}

/*
function gameResized(width:Int, height:Int) {
    FlxG.initialWidth = width;
    FlxG.initialHeight = height;
    FlxG.width = width;
    FlxG.height = height;
}
*/

function closeGame() {}

function destroy() {
    Application.current.onExit.remove(closeGame);
    if (impPixelDebugMode) storySequenceDebugInfo.destroy();

    Application.current.window.minWidth = null;
    Application.current.window.minHeight = null;
    //gameResized(1280, 720);
    //FlxG.resizeWindow(FlxG.width, FlxG.height);
}