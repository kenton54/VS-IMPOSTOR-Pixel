import funkin.backend.system.Flags;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.utils.WindowUtils;
import funkin.backend.MusicBeatTransition;
import lime.graphics.Image;
import openfl.system.Capabilities;
importScript("data/flags");
importScript("data/utils");

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

    //Application.current.window.__attributes.context.vsync = true;
}

function setWindowParameters() {
    WindowUtils.winTitle = "VS IMPOSTOR Pixel";
    window.setIcon(Image.fromBytes(Assets.getBytes(Paths.image("app/red64"))));
}

function initSaveData() {
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
    //FlxG.save.data.impPixelPartnersUnlocked ??= ["gf" => true];
    FlxG.save.data.impPixelSkinsUnlocked ??= [];
    FlxG.save.data.impPixelFlags ??= getFlags(true);

    initVars();
    initFlags(FlxG.save.data.impPixelFlags);
}

function initVars() {
    storySequence = FlxG.save.data.impPixelStorySequence;
    setStats(FlxG.save.data.impPixelStats);
    playablesList = FlxG.save.data.impPixelPlayablesUnlocked;
    skinsList = FlxG.save.data.impPixelSkinsUnlocked;
    pixelBeans = FlxG.save.data.impPixelBeans;
}

function initFlags(data:Map<String, Dynamic>) {
    isSussusMoogusComplete = data.get("isSussusMoogusComplete");
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