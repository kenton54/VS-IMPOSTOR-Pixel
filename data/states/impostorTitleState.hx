import flixel.effects.FlxFlicker;
import flixel.group.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxGradient;
import flixel.FlxObject;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.backend.MusicBeatState;
import funkin.options.Options;
import PixelStars;
importScript("data/variables");

var stars:PixelStars;

var camFollow:FlxObject;

var title:FlxTypedSpriteGroup;
var baseScale:Float = 4;

var pressStart:FunkinText;
var psColor:FlxInterpolateColor;

static var oldpsColor:FlxInterpolateColor;

static var reloadState:Bool = false;

function create() {
    DiscordUtil.call("onMenuLoaded", ["Title Screen"]);

    if (storyState[storySequence] == "start" || storyState[storySequence] == "postLobbyShowcase") {
        title();
    }
    else {
        CoolUtil.playMenuSong(true);
        intro();
    }

    MusicBeatState.skipTransIn = true;

    camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
    add(camFollow);

    stars = new PixelStars(-40, 4, 3);
    stars.setScrollFactor(0.2, 0.2);
    stars.addStars();

    title = new FlxTypedSpriteGroup();
    add(title);

    var titleColor:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/title/color"));
    titleColor.scale.set(baseScale, baseScale);
    titleColor.updateHitbox();
    titleColor.centerOffsets();
    titleColor.screenCenter(FlxAxes.X);
    titleColor.y = FlxG.height * 0.2;
    titleColor.color = 0xFFE31629;
    title.add(titleColor);

    var titleMain:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/title/main"));
    titleMain.scale.set(baseScale, baseScale);
    titleMain.updateHitbox();
    titleMain.centerOffsets();
    titleMain.screenCenter(FlxAxes.X);
    titleMain.y = FlxG.height * 0.2;
    title.add(titleMain);

    var acceptKey:FlxKey = Reflect.field(Options, "P1_ACCEPT")[0];
    pressStart = new FunkinText(0, 0, FlxG.width, "PRESS " + CoolUtil.keyToString(acceptKey) + " TO PLAY", 52);
    pressStart.alignment = "center";
    pressStart.color = FlxColor.TRANSPARENT;
    pressStart.borderColor = FlxColor.WHITE;
    pressStart.borderSize = 6.75;
    pressStart.font = Paths.font("gameboy.ttf");
    pressStart.y = FlxG.height * 0.8;
    add(pressStart);

    psColor = new FlxInterpolateColor(colorArray[colorArrayPos]);

    FlxG.camera.follow(camFollow);

    reloadState = false;
}

function onResize(event) {
    reloadState = true;
    MusicBeatState.skipTransIn = true;
    MusicBeatState.skipTransOut = true;
    FlxG.resetState();
}

var transitioning:Bool = false;
function update(elapsed:Float) {
    if (FlxG.keys.justPressed.F11) FlxG.fullscreen = !FlxG.fullscreen;

    if (controls.ACCEPT) {
        if (transitionTimer.active) {
            FlxG.switchState(new MainMenuState());
            transitionTimer.cancel();
        }
        else if (!transitioning)
            accept();
    }

    interpolatePSColor();

    FlxG.camera.zoom = CoolUtil.fpsLerp(FlxG.camera.zoom, 1, 0.05);
}

var interpolate:Bool = true;
var colorArray:Array<FlxColor> = [FlxColor.CYAN, 0xFF4242CF];
var colorArrayPos:Int = 0;
var colorArraychange:Int = 1;
function interpolatePSColor() {
    if (!interpolate) {
        pressStart.borderColor = FlxColor.WHITE;
        psColor.color = FlxColor.WHITE;
        colorArrayPos = 0;
        colorArraychange = 1;
    }
    else {
        psColor.fpsLerpTo(colorArray[colorArrayPos], 0.04);
        pressStart.borderColor = psColor.color;

        if (Math.abs(pressStart.borderColor - colorArray[colorArrayPos]) <= 65536 * 2) {
            pressStart.borderColor = colorArray[colorArrayPos];
            psColor.color = colorArray[colorArrayPos];
            colorArrayPos += colorArraychange;
        }

        if (colorArrayPos == colorArray.length - 1) colorArraychange = -1;
        if (colorArrayPos == 0) colorArraychange = 1;
    }
}

function beatHit(curBeat:Int) {
    bopTitle();
}

function title(?flash:Bool) {
    if (flash && !reloadState)
        FlxG.camera.flash(FlxColor.WHITE, 1);
    else if (!reloadState)
        FlxG.camera.fade(0xFF000000, 1, true);
}

function bopTitle() {
    title.forEach(function(spr) {
        FlxTween.cancelTweensOf(spr, ["scale.x", "scale.y"]);

        var daScale:Float = (baseScale * 1.075);
        var duration:Float = 60 / Conductor.bpm;

        spr.scale.set(daScale, daScale);
        FlxTween.tween(spr, {"scale.x": baseScale, "scale.y": baseScale}, duration, {ease: FlxEase.backInOut});
    });
}

var transitionTimer:FlxTimer = new FlxTimer();
function accept() {
    interpolate = false;

    CoolUtil.playMenuSFX(1);
    FlxG.camera.zoom += 0.08;

    var fakePressStart:FunkinText = pressStart.clone();
    fakePressStart.setPosition(pressStart.x, pressStart.y);
    insert(members.indexOf(pressStart), fakePressStart);
    FlxTween.tween(fakePressStart, {"scale.x": 1.2, "scale.y": 1.2}, 0.75, {ease: FlxEase.quartOut});
    FlxTween.tween(fakePressStart, {alpha: 0}, 0.5);
    FlxFlicker.flicker(pressStart, 1.25, 0.05, false, true);

    transitionTimer.start(0.75, _ -> {
        transitioning = true;

        MusicBeatState.skipTransOut = true;

        var blackThing:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height * 2, [0x00000000, 0xFF000000, 0xFF000000]);
        blackThing.y = FlxG.height;
        add(blackThing);

        FlxTween.tween(blackThing, {y: -320}, 1.5, {ease: FlxEase.sineIn});

        var firstPos:Float = camFollow.y - 50;
        FlxTween.tween(camFollow, {y: firstPos}, 0.5, {ease: FlxEase.sineInOut, onComplete: _ -> {
            FlxTween.tween(camFollow, {y: FlxG.height}, 1, {ease: FlxEase.quadIn});
        }});

        new FlxTimer().start(1.6, _ -> {
            FlxG.switchState(new MainMenuState());
        });
    });
}

function destroy() {
    stars.destroy();
    stars = null;
}