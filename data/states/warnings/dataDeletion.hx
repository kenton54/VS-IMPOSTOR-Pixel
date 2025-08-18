import flixel.addons.display.FlxBackdrop;
//import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.util.FlxGradient;

var backGrp:FlxSpriteGroup;
var frontGrp:FlxSpriteGroup;

var bg:FlxSprite;
var warnTape:FlxBackdrop;
var backGradient:FlxSprite;
//var particlesEmitter:FlxTypedEmitter;
var line:FlxSprite;
var topTxt:FlxSprite;
var boyfriend:FunkinSprite;

var isSelectingYes:Bool = false;
var no:FunkinText;
var yes:FunkinText;

var scale:Float = 5;

function create() {
    playSound("alarm");

    backGrp = new FlxSpriteGroup();
    frontGrp = new FlxSpriteGroup();

    backGrp.add(bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

    warnTape = new FlxBackdrop(Paths.image("menus/dataDeletion/warningTape"), FlxAxes.X);
    warnTape.scale.set(scale, scale);
    warnTape.updateHitbox();
    warnTape.y = FlxG.height;
    warnTape.y -= warnTape.height + 2 * scale;
    warnTape.velocity.x = -32;

    line = new FlxSprite(0, FlxG.height * 0.425).makeGraphic(FlxG.width, 30 * scale, FlxColor.WHITE);
    line.y -= line.height;

    backGradient = FlxGradient.createGradientFlxSprite(FlxG.width, line.height * 4, [0xFF000000, 0xFF5B0000, 0xFF5B0000, 0xFF000000]);
    backGradient.y = line.y + line.height / 2;
    backGradient.y -= backGradient.height / 2;

    topTxt = new FunkinText(line.x, line.y, line.width, createMultiLineText([
        translate("options.warning.dataDeletion1"),
        translate("options.warning.dataDeletion2"),
        translate("options.warning.dataDeletion3")
    ]), 58);
    topTxt.alignment = "center";
    topTxt.font = Paths.font("pixeloidsans.ttf");
    topTxt.color = FlxColor.RED;
    topTxt.borderColor = 0xFF500000;
    topTxt.borderSize = 5;
    topTxt.scale.y = line.height / topTxt.height;
    topTxt.updateHitbox();

    /*
    var maxScale:Float = 20;
    particlesEmitter = new FlxTypedEmitter(FlxG.width + maxScale * scale * 2, backGradient.y);
    particlesEmitter.loadParticles(Paths.image("menus/dataDeletion/fade"), 100);
    particlesEmitter.launchAngle.set(180);
    particlesEmitter.angle.set(90);
    particlesEmitter.speed.set(4000);
    particlesEmitter.scale.set(2, maxScale / 4, 8, maxScale);
    particlesEmitter.height = backGradient.height;
    particlesEmitter.blend = setBlendMode("add");
    particlesEmitter.alpha.set(0.1, 0.5);
    particlesEmitter.start(false, 0.005);
    */

    boyfriend = new FunkinSprite(0, 0, Paths.image("menus/dataDeletion/dumbass"));
    boyfriend.animation.addByIndices("false", "bf", [1], "", 0);
    boyfriend.animation.addByIndices("true", "bf", [2], "", 0);
    boyfriend.scale.set(6, 6);
    boyfriend.updateHitbox();
    boyfriend.screenCenter(FlxAxes.X);
    boyfriend.y = warnTape.y;
    boyfriend.y -= boyfriend.height / 1.5;

    no = new FunkinText(FlxG.width * 0.25, FlxG.width * 0.65, 0, translate("no").toUpperCase(), 80, false);
    no.font = Paths.font("pixeloidsans.ttf");
    no.x -= no.width / 2;
    no.y -= no.height / 2;

    yes = new FunkinText(FlxG.width * 0.75, FlxG.width * 0.65, 0, translate("yes").toUpperCase(), 80, false);
    yes.font = Paths.font("pixeloidsans.ttf");
    yes.x -= yes.width / 2;
    yes.y -= yes.height / 2;

    backGrp.add(backGradient);
    //backGrp.add(particlesEmitter); adding it to the group (from here) causes an error
    frontGrp.add(warnTape);
    frontGrp.add(line);
    frontGrp.add(topTxt);
    frontGrp.add(boyfriend);
    frontGrp.add(no);
    frontGrp.add(yes);

    updateSelection();

    new FlxTimer().start(0.1, _ -> allowSelection = true);
}

var usingKeyboard:Bool = true;
var mouseIsHoveringSmth:Bool = false;
var allowSelection:Bool = false;
function update(elapsed:Float) {
    if (FlxG.keys.justPressed.ANY) {
        usingKeyboard = true;
        FlxG.mouse.visible = false;
    }
    if (FlxG.mouse.justMoved) {
        usingKeyboard = false;
        FlxG.mouse.visible = true;
    }

    if (usingKeyboard) {
        if (!allowSelection) return;

        if (controls.LEFT_P) {
            isSelectingYes = false;
            updateSelection();
        }
        if (controls.RIGHT_P) {
            isSelectingYes = true;
            updateSelection();
        }
        if (controls.ACCEPT)
            checkSelection();
    }
    else {
        if (!allowSelection) return;

        if (isMobile) {}
        else {
            mouseIsHoveringSmth = false;

            if (FlxG.mouse.overlaps(no) && isSelectingYes) {
                if (!mouseIsHoveringSmth) {
                    mouseIsHoveringSmth = true;
                    isSelectingYes = false;
                    updateSelection();
                }
            }
            if (FlxG.mouse.overlaps(yes) && !isSelectingYes) {
                if (!mouseIsHoveringSmth) {
                    mouseIsHoveringSmth = true;
                    isSelectingYes = true;
                    updateSelection();
                }
            }

            if (FlxG.mouse.justReleased)
                checkSelection();
        }
    }
}

var yesShake:FlxTween;
function updateSelection() {
    playMenuSound("scroll");

    yes.scale.set(1, 1);
    yes.updateHitbox();

    no.scale.set(1, 1);
    no.updateHitbox();

    if (yesShake != null)
        yesShake.cancel();

    if (isSelectingYes) {
        yes.scale.set(1.25, 1.25);
        yes.updateHitbox();

        yes.color = FlxColor.RED;
        createAndShake();
    }
    else {
        yes.color = FlxColor.WHITE;
        no.scale.set(1.25, 1.25);
        no.updateHitbox();
    }

    yes.offset.set(0, 0);
    yes.centerOffsets();
    yes.x = FlxG.width * 0.75;
    yes.x -= yes.width / 2;
    yes.y = FlxG.height * 0.65;
    yes.y -= yes.height / 2;

    no.x = FlxG.width * 0.25;
    no.x -= no.width / 2;
    no.y = FlxG.height * 0.65;
    no.y -= no.height / 2;

    boyfriend.playAnim(Std.string(isSelectingYes));
}

function createAndShake() {
    yesShake = FlxTween.shake(yes, 0.05);
    yesShake.onComplete = createAndShake;
}

function checkSelection() {
    if (!usingKeyboard) {
        if (mouseIsHoveringSmth) return;
    }

    allowSelection = false;

    if (yesShake != null) {
        yesShake.cancel();
        yesShake.destroy();
    }

    if (isSelectingYes) {
        willEraseData = true;
        kill();
    }
    else {
        willEraseData = false;
        playMenuSound("cancel");

        var time:Float = 0.5;
        FlxTween.tween(bg, {alpha: 0}, time);
        FlxTween.tween(backGradient, {alpha: 0}, time);
        FlxTween.tween(line, {"scale.y": 0}, time, {ease: FlxEase.sineIn});
        FlxTween.tween(topTxt, {"scale.y": 0}, time, {ease: FlxEase.sineIn});
        FlxTween.tween(warnTape, {y: FlxG.height}, time, {ease: FlxEase.sineIn});
        FlxTween.tween(boyfriend, {alpha: 0}, time, {startDelay: time / 2});
        FlxTween.tween(no, {alpha: 0}, time);
        FlxTween.tween(yes, {alpha: 0}, time);
        //new FlxTimer().start(time / 2, _ -> particlesEmitter.kill());

        new FlxTimer().start(time * 1.5, _ -> kill());
    }
}

var willEraseData:Bool = false;
var wasDestroyed:Bool = false;
function kill() {
    if (willEraseData) {
        wasDestroyed = true;
    }
    else {
        wasDestroyed = true;
        backGrp.destroy();
        frontGrp.destroy();
    }
}