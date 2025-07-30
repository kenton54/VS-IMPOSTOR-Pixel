import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.Logs;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.WindowUtils;
import funkin.backend.MusicBeatTransition;
import lime.graphics.Image;
import openfl.system.Capabilities;
importScript("data/utils");

var defaultStats:Map<String, Dynamic> = [
    "Current Story Progression" => "start",
    "Total Note Hits" => 0,
    "Perfect Note Hits" => 0,
    "Sick Note Hits" => 0,
    "Good Note Hits" => 0,
    "Bad Note Hits" => 0,
    "Shit Note Hits" => 0,
    "Total Attacks Dodged" => 0,
    "Tasks Speedrun PB (Skeld)" => 0.0,
    "Tasks Speedrun PB (Mira HQ)" => 0.0,
    "Tasks Speedrun PB (Polus)" => 0.0,
    "Tasks Speedrun PB (Airship)" => 0.0,
    "Total Tasks Completed" => 0
];

function new() {
    FlxSprite.defaultAntialiasing = false;

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
    WindowUtils.winTitle = "VS IMPOSTOR Pixel";
    window.setIcon(Image.fromBytes(Assets.getBytes(Paths.image("app/red64"))));

    window.minWidth = 1280;
    window.minHeight = 720;
}

function initSaveData() {
    // Options
    FlxG.save.data.middlescroll ??= FlxG.onMobile ? true : false;
    FlxG.save.data.impPixelTimeBar ??= true;
    FlxG.save.data.impPixelStrumBG ??= 0;

    // Mod Source
    FlxG.save.data.impPixelStorySequence ??= 0;
    FlxG.save.data.impPixelBeans ??= 0;
    FlxG.save.data.impPixelStats ??= defaultStats;
    FlxG.save.data.impPixelPlayablesUnlocked ??= ["bf" => true];
    //FlxG.save.data.impPixelPartnersUnlocked ??= ["gf" => true];
    FlxG.save.data.impPixelSkinsUnlocked ??= [];
    FlxG.save.data.impPixelFlags ??= [];
}

function update(elapsed:Float) {
    if (fakeMobile) {
        if (FlxG.keys.justPressed.F8) {
            MusicBeatTransition.script = "data/transitions/closingSharpCircle";
            FlxG.switchState(new ModState("debug/mobileEmuInitializer"));
        }
    }
}

function postStateSwitch() {
    if (fakeMobile) {
        var mobilePreviewTxt:FunkinText = new FunkinText(FlxG.width * 0.02, FlxG.height * 0.98, 0, 'Mobile Preview, menus may look different in the real thing!\nPress F8 to exit the preview', 32, true);
        mobilePreviewTxt.font = Paths.font("pixeloidsans.ttf");
        mobilePreviewTxt.borderSize = 3;
        mobilePreviewTxt.y -= mobilePreviewTxt.height;
        FlxG.game._state.add(mobilePreviewTxt);
    }
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

function resizeWindow(width:Int, height:Int) {
    window.resize(width, height);
}

function closeGame() {}

function destroy() {
    Application.current.onExit.remove(closeGame);

    Application.current.window.minWidth = null;
    Application.current.window.minHeight = null;

    resizeGame(1280, 720);
    resizeWindow(1280, 720);

    isMobile = FlxG.onMobile;
    fakeMobile = false;

    FlxSprite.defaultAntialiasing = true;
}