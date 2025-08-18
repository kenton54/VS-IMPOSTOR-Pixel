import funkin.backend.system.Flags;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.utils.WindowUtils;
import funkin.backend.MusicBeatTransition;
import lime.graphics.Image;
import openfl.system.Capabilities;
import ImpostorFlags;
importScript("data/utils");

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

    // Mod Source
    FlxG.save.data.impPixelStorySequence ??= 0;
    FlxG.save.data.impPixelBeans ??= 0;
    FlxG.save.data.impPixelStats ??= getStats(true);
    FlxG.save.data.impPixelPlayablesUnlocked ??= ["bf" => true];
    //FlxG.save.data.impPixelPartnersUnlocked ??= ["gf" => true];
    FlxG.save.data.impPixelSkinsUnlocked ??= [];
    FlxG.save.data.impPixelFlags ??= [];

    ImpostorFlags.load(FlxG.save.data.impPixelFlags);
    initVars();
}

function initVars() {
    storySequence = FlxG.save.data.impPixelStorySequence;
    setStats(FlxG.save.data.impPixelStats);
    playablesList = FlxG.save.data.impPixelPlayablesUnlocked;
    skinsList = FlxG.save.data.impPixelSkinsUnlocked;
    pixelBeans = FlxG.save.data.impPixelBeans;
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

    ImpostorFlags.save();
    saveImpostor();
}

function closeGame() {
    ImpostorFlags.save();
    saveImpostor();
    FlxG.save.flush();
}

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