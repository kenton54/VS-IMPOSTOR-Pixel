import funkin.backend.system.Flags;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.utils.WindowUtils;
import funkin.backend.MusicBeatTransition;
import funkin.savedata.FunkinSave;
import openfl.system.Capabilities;
importScript("utils/flags");
importScript("utils/utils");
importScript("utils/math");

public static final PIXEL_SAVE_PATH:String = "kenton";
public static final PIXEL_SAVE_NAME:String = "impostorPixel";

function new() {
    FlxSprite.defaultAntialiasing = false;

    initSaveData();

    Application.current.onExit.add(closeGame);

    // I have to do this, cuz otherwise it causes crashes (im not kidding)
    Options.streamedMusic = false;
    Options.streamedVocals = false;
    Options.save();

    if (FlxG.onMobile) {
        //var screenWidth:Float = Capabilities.screenResolutionX;
        //var screenHeight:Float = Capabilities.screenResolutionY;
        resizeGame(1600, 720);
    }
    else {
        window.minWidth = 1280;
        window.minHeight = 720;
        FlxG.mouse.visible = true;
    }
}

function initSaveData() {
    FlxG.save.bind(PIXEL_SAVE_PATH, null);
    FunkinSave.save.bind(PIXEL_SAVE_NAME, PIXEL_SAVE_PATH);

    // Options
    FlxG.save.data.middlescroll ??= FlxG.onMobile ? true : false;
    FlxG.save.data.impPixelTimeBar ??= true;
    FlxG.save.data.impPixelStrumBG ??= 0;
    FlxG.save.data.impPixelFastMenus ??= false;

    // Mod Source
    FlxG.save.data.impPixelStorySequence ??= 0;
    FlxG.save.data.impPixelBeans ??= 0;
    FlxG.save.data.impPixelStats ??= getStats(true);
    FlxG.save.data.impPixelPlayablesUnlocked ??= ["bf" => true];
    FlxG.save.data.impPixelSkinsUnlocked ??= [];
    FlxG.save.data.impPixelFlags ??= getFlags(true);

    initVars();
    initFlags(FlxG.save.data.impPixelFlags);

    logTraceColored([
        {text: "[VS IMPOSTOR Pixel] ", color: getLogColor("red")},
        {text: "Save Data initialized!"}
    ], "information");
}

function initVars() {
    storySequence = FlxG.save.data.impPixelStorySequence;
    setStats(FlxG.save.data.impPixelStats);
    playablesList = FlxG.save.data.impPixelPlayablesUnlocked;
    skinsList = FlxG.save.data.impPixelSkinsUnlocked;
    pixelBeans = FlxG.save.data.impPixelBeans;
}

function initFlags(data:Map<String, Dynamic>) {
    weeksCompleted = data.get("weeksCompleted");
    seenCharacters = data.get("seenCharacters");
    unlockedVideos = data.get("unlockedVideos");
}

static function setStats(data:Map<String, Dynamic>) {
    for (stat in data.keyValueIterator()) {
        impostorStats.set(stat.key, stat.value);
    }
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.ANY) globalUsingKeyboard = true;
    if (FlxG.mouse.justMoved) globalUsingKeyboard = false;

    if (fakeMobile) {
        if (FlxG.keys.justPressed.F8) {
            setTransition("bottom2topSmoothSquare");
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

    saveImpostor();
}

function closeGame()
    saveImpostor();

function destroy() {
    Application.current.onExit.remove(closeGame);

    FlxG.save.bind(Flags.SAVE_PATH, null);
    FunkinSave.save.bind(Flags.SAVE_NAME, Flags.SAVE_PATH);

    closeGame();

    Application.current.window.minWidth = null;
    Application.current.window.minHeight = null;

    resizeGame(1280, 720);

    if (fakeMobile && !Application.current.window.maximized)
        resizeWindow(1280, 720);

    isMobile = FlxG.onMobile;
    setMobile(false);

    FlxSprite.defaultAntialiasing = true;
}