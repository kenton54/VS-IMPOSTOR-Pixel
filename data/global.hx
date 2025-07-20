import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.Logs;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.WindowUtils;
import lime.graphics.Image;
import openfl.system.Capabilities;
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

    //gameResized(Application.current.window.width, Application.current.window.height);

    Application.current.onExit.add(closeGame);

    if (FlxG.onMobile) {
        //var screenWidth:Float = Capabilities.screenResolutionX;
        //var screenHeight:Float = Capabilities.screenResolutionY;
        resizeGame(1600, 720);
    }
    else {
        setWindowParameters();
        FlxG.mouse.visible = true;
    }
}

function setWindowParameters() {
    window.setIcon(Image.fromBytes(Assets.getBytes(Paths.image("app/red64"))));

    window.minWidth = 1280;
    window.minHeight = 720;
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
    TitleState => "impostorTitleState",
    MainMenuState => "impostorMenuState",
    FreeplayState => "impostorFreeplayState"
];

// the actual state modification
function preStateSwitch() {
    for (redirectState in redirectStates.keys())
        if (FlxG.game._requestedState is redirectState)
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}

function resizeGame(width:Int, height:Int) {
    FlxG.initialWidth = width;
    FlxG.initialHeight = height;
    FlxG.width = width;
    FlxG.height = height;
}

function closeGame() {}

function destroy() {
    Application.current.onExit.remove(closeGame);
    if (impPixelDebugMode) storySequenceDebugInfo.destroy();

    Application.current.window.minWidth = null;
    Application.current.window.minHeight = null;

    if (FlxG.onMobile) {
        resizeGame(1280, 720);
    }
}