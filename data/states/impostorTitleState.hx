import flixel.effects.FlxFlicker;
import flixel.group.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxGradient;
import flixel.FlxObject;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.MusicBeatState;
import funkin.backend.MusicBeatTransition;
import funkin.options.Options;
import PixelStars;
importScript("data/variables");

var stars:PixelStars;

var camFollow:FlxObject;

var title:FlxTypedSpriteGroup;
var baseScale:Float = 4;

var pressStart:FunkinText;

static var gameStarted:Bool = false;

function create() {
    DiscordUtil.call("onMenuLoaded", ["Title Screen"]);

    MusicBeatTransition.script = "data/transitions/bottom2topSmoothSquare";

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

    pressStart = new FunkinText(0, 0, FlxG.width, "", 52);
    pressStart.alignment = "center";
    pressStart.color = FlxColor.TRANSPARENT;
    pressStart.borderColor = FlxColor.WHITE;
    pressStart.borderSize = 6.75;
    pressStart.font = Paths.font("gameboy.ttf");
    pressStart.y = FlxG.height * 0.8;
    pressStart.alpha = 0;
    add(pressStart);

    tweenPressStart();

    FlxG.camera.follow(camFollow);

    gameStarted = true;
}

var acceptKey:FlxKey = Reflect.field(Options, "P1_ACCEPT")[0];

var transitioning:Bool = false;
function update(elapsed:Float) {
    if (FlxG.keys.justPressed.F11) FlxG.fullscreen = !FlxG.fullscreen;

    if (FlxG.mouse.justPressed || FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justPressed) {
        if (transitionTimer.active && !transitioning) {
            transitionTimer.cancel();
            FlxG.switchState(new MainMenuState());
        }
        else if (!transitionTimer.active && !transitioning) {
            pressStart.text = FlxG.onMobile ? "TOUCH THE SCREEN TO PLAY" : "CLICK TO PLAY";
            accept();
        }
    }
    if (controls.ACCEPT) {
        if (transitionTimer.active && !transitioning) {
            transitionTimer.cancel();
            FlxG.switchState(new MainMenuState());
        }
        else if (!transitionTimer.active && !transitioning) {
            pressStart.text = "PRESS " + CoolUtil.keyToString(acceptKey) + " TO PLAY";
            accept();
        }
    }

    FlxG.camera.zoom = CoolUtil.fpsLerp(FlxG.camera.zoom, 1, 0.05);
}

var tweenDur:Float = 1.5;
var tweenIn:FlxTween = null;
var tweenOut:FlxTween = null;
var colorArray:Array<FlxColor> = [
    0xFF0CF0A0, 0xFF27F6CD, 0xFF33FFFF, 0xFF33DAF6, 0xFF33B5ED,
    0xFF3387E1, 0xFF3362D8, 0xFF3333CC, 0xFF4422DD, 0xFF420DDD];
var mouseTxt:Bool = false;
function tweenPressStart() {
    pressStart.borderColor = colorArray[FlxG.random.int(0, colorArray.length - 1)];
    if (FlxG.onMobile) {
        pressStart.text = "TOUCH THE SCREEN TO PLAY";
        tweenIn = FlxTween.tween(pressStart, {alpha: 1}, tweenDur, {ease: FlxEase.sineOut, onComplete: _ -> {
            tweenOut = FlxTween.tween(pressStart, {alpha: 0}, tweenDur, {ease: FlxEase.sineIn, onComplete: _ -> {
                tweenPressStart();
            }});
        }});
    }
    else {
        if (!mouseTxt) {
            pressStart.text = "PRESS " + CoolUtil.keyToString(acceptKey).toUpperCase() + " TO PLAY";
        }
        else {
            pressStart.text = "CLICK TO PLAY";
        }
        tweenIn = FlxTween.tween(pressStart, {alpha: 1}, tweenDur, {ease: FlxEase.sineOut, onComplete: _ -> {
            tweenOut = FlxTween.tween(pressStart, {alpha: 0}, tweenDur, {ease: FlxEase.sineIn, onComplete: _ -> {
                tweenPressStart();
            }});
        }});
        mouseTxt = !mouseTxt;
    }
}

function beatHit(curBeat:Int) {
    bopTitle();
}

function title(?flash:Bool) {
    if (flash)
        FlxG.camera.flash(FlxColor.WHITE, !gameStarted ? 1 : 0.5);
    else
        FlxG.camera.fade(0xFF000000, !gameStarted ? 1 : 0.25, true);
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
    if (tweenIn != null && tweenIn.active) tweenIn.cancel();
    if (tweenOut != null && tweenOut.active) tweenOut.cancel();
    FlxTween.cancelTweensOf(pressStart, ["alpha"]);
    pressStart.alpha = 1;
    pressStart.borderColor = FlxColor.WHITE;

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
            FlxG.switchState(new ModState("impostorMenuState"));
        });
    });
}

function destroy() {
    stars.destroy();
    stars = null;
}