import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.util.FlxGradient;
import PixelStars;
import VSliceCharacter;

public var songUsesLightsSabotage:Bool = false;
public var makeCrowdAppear:Bool = false;

public var darkDadChar:VSliceCharacter;
public var darkBoyfriendChar:VSliceCharacter;
public var darkGfChar:VSliceCharacter;

public var snowParticles:FlxTypedEmitter;

var stars:PixelStars;

var skyGradient:FlxSprite;

function create() {
    skyGradient = FlxGradient.createGradientFlxSprite(FlxG.width * 4, FlxG.height * 3, [0x0023193B, 0x8023193B, 0xFF755387]);
    skyGradient.setPosition(-1400, -1200);
    skyGradient.scrollFactor.set(0.1, 0.1);
    insert(0, skyGradient);

    stars = new PixelStars(-20, 3);
    stars.setScrollFactor(0.05, 0.05);
    stars.addStars(0);

    snowParticles = new FlxTypedEmitter(-1600, -800, 180);
    snowParticles.makeParticles(5, 5, FlxColor.WHITE, 100);
    snowParticles.launchAngle.set(120, 60);
    snowParticles.speed.set(100, 250, 200, 800);
    snowParticles.scale.set(1, 1, 3, 3);
    snowParticles.lifespan.set(1800, 1800);
    snowParticles.keepScaleRatio = true;
    snowParticles.width = FlxG.width * 2.5;
    snowParticles.camera = camGame;
    add(snowParticles);
}

function postCharacterSetup() {
    var polusShader = new CustomShader("adjustColor");
    polusShader.brightness = -12.0;
    polusShader.hue = -18.0;
    polusShader.contrast = -30.0;
    polusShader.saturation = -6.0;

    boyfriend.shader = polusShader;
    dad.shader = polusShader;
    gf.shader = polusShader;

    if (songUsesLightsSabotage) {
        darkDadChar = new VSliceCharacter(dad.x, dad.y, dad.curCharacter + "-lightsOut", false);
        darkDadChar.visible = false;
        dad.onPlayAnim.add(function(name:String, force:Bool, context:Dynamic, reverse:Bool, frame:Int) {
            darkDadChar.playAnim(name, force, "LOCK", reverse, frame);
        });

        darkBoyfriendChar = new VSliceCharacter(boyfriend.x, boyfriend.y, boyfriend.curCharacter + "-lightsOut", true);
        darkBoyfriendChar.visible = false;
        boyfriend.onPlayAnim.add(function(name:String, force:Bool, context:Dynamic, reverse:Bool, frame:Int) {
            darkBoyfriendChar.playAnim(name, force, "LOCK", reverse, frame);
        });

        darkGfChar = new VSliceCharacter(gf.x, gf.y, gf.curCharacter + "-lightsOut", false);
        darkGfChar.visible = false;
        gf.onPlayAnim.add(function(name:String, force:Bool, context:Dynamic, reverse:Bool, frame:Int) {
            darkGfChar.playAnim(name, force, "LOCK", reverse, frame);
        });

        insert(members.indexOf(dad) + 1, darkDadChar);
        insert(members.indexOf(boyfriend) + 1, darkBoyfriendChar);
        insert(members.indexOf(gf) + 1, darkGfChar);
    }
}

public function flash() {
    medbay_normal.setColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
    labWall_normal.setColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
    labEntrance_normal.setColorTransform(1, 1, 1, 1, 255, 255, 255, 1);
    ground_normal.setColorTransform(1, 1, 1, 1, 255, 255, 255, 1);

    gf.playAnim("shock", true);

    // 2 frames of a 24 animation framerate
    new FlxTimer().start(2 / 24, _ -> {
        medbay_normal.setColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
        labWall_normal.setColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
        labEntrance_normal.setColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
        ground_normal.setColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
    });
}

var lightsSabotaged:Bool = false;

public function sabotageLights() {
    if (!songUsesLightsSabotage) return;

    camGame.flash();
    medbay_dark.visible = true;
    labWall_dark.visible = true;
    labEntrance_dark.visible = true;
    ground_dark.visible = true;

    darkDadChar.visible = true;
    darkBoyfriendChar.visible = true;
    darkGfChar.visible = true;

    lightsSabotaged = true;
}

public function fixLights() {
    if (!songUsesLightsSabotage) return;

    if (lightsSabotaged) {
        FlxTween.cancelTweensOf(medbay_dark, ["alpha"]);
        FlxTween.cancelTweensOf(labWall_dark, ["alpha"]);
        FlxTween.cancelTweensOf(labEntrance_dark, ["alpha"]);
        FlxTween.cancelTweensOf(ground_dark, ["alpha"]);
        FlxTween.cancelTweensOf(darkDadChar, ["alpha"]);
        FlxTween.cancelTweensOf(darkBoyfriendChar, ["alpha"]);
        FlxTween.cancelTweensOf(darkGfChar, ["alpha"]);
        FlxTween.tween(medbay_dark, {alpha: 0}, 1, {onComplete: _ -> {
            medbay_dark.visible = false;
        }});
        FlxTween.tween(labWall_dark, {alpha: 0}, 1, {onComplete: _ -> {
            labWall_dark.visible = false;
        }});
        FlxTween.tween(labEntrance_dark, {alpha: 0}, 1, {onComplete: _ -> {
            labEntrance_dark.visible = false;
        }});
        FlxTween.tween(ground_dark, {alpha: 0}, 1, {onComplete: _ -> {
            ground_dark.visible = false;
        }});
        FlxTween.tween(darkDadChar, {alpha: 0}, 1, {onComplete: _ -> {
            darkDadChar.visible = false;
        }});
        FlxTween.tween(darkBoyfriendChar, {alpha: 0}, 1, {onComplete: _ -> {
            darkBoyfriendChar.visible = false;
        }});
        FlxTween.tween(darkGfChar, {alpha: 0}, 1, {onComplete: _ -> {
            darkGfChar.visible = false;
        }});

        lightsSabotaged = false;
    }
}

function update(elapsed:Float) {
    if (songUsesLightsSabotage) {
        darkBoyfriendChar.lastHit = boyfriend.lastHit;
        darkDadChar.lastHit = dad.lastHit;
    }
}