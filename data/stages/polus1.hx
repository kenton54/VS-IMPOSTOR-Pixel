import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.util.FlxGradient;
import funkin.backend.shaders.CustomShader;
import PixelStars;
import SolidColorShader;

public var songUsesLightsSabotage:Bool = false;
public var makeCrowdAppear:Bool = false;

public var darkDadChar:Character;
public var darkBoyfriendChar:Character;
public var darkGfChar:Character;

public var snowParticles:FlxTypedEmitter;

var stars:PixelStars;

var skyGradient:FlxSprite;

function create() {
    skyGradient = FlxGradient.createGradientFlxSprite(FlxG.width * 3, FlxG.height * 4, [0x004D3357, 0xFF4D3357]);
    skyGradient.x = -1400;
    skyGradient.y = -1000;
    skyGradient.scrollFactor.set(0.15, 0.15);
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

function postCreate() {
    if (songUsesLightsSabotage) {
        darkDadChar = new Character(dad.x, dad.y, dad.curCharacter + "-lightsOut", false);
        darkDadChar.visible = false;
        darkBoyfriendChar = new Character(boyfriend.x, boyfriend.y, boyfriend.curCharacter + "-lightsOut", true);
        darkBoyfriendChar.visible = false;
        darkGfChar = new Character(gf.x, gf.y, gf.curCharacter + "-lightsOut", false);
        darkGfChar.visible = false;
        insert(members.indexOf(dad) + 1, darkDadChar);
        insert(members.indexOf(boyfriend) + 1, darkBoyfriendChar);
        insert(members.indexOf(gf) + 1, darkGfChar);
    }
}

public function polus1Flash() {
    var solidColor1:SolidColorShader = new SolidColorShader(FlxColor.BLACK);
    var solidColor2:SolidColorShader = new SolidColorShader(FlxColor.BLACK);
    var solidColor3:SolidColorShader = new SolidColorShader(FlxColor.WHITE);
    var solidColor4:SolidColorShader = new SolidColorShader(FlxColor.WHITE);
    medbay_normal.shader = solidColor1.shader;
    labWall_normal.shader = solidColor2.shader;
    labEntrance_normal.shader = solidColor3.shader;
    ground_normal.shader = solidColor3.shader;

    gf.playAnim("shock", true);

    new FlxTimer().start(2 / 24, _ -> {
        medbay_normal.shader = null;
        labWall_normal.shader = null;
        labEntrance_normal.shader = null;
        ground_normal.shader = null;

        solidColor1.destroy();
        solidColor2.destroy();
        solidColor3.destroy();
    });
}

var lightsSabotaged:Bool = false;

public function polus1SabotageLights() {
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

public function polus1FixLights() {
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

function onNewPlayerHit(event) {
    if (songUsesLightsSabotage) {
        if (!event.note.isSustainNote) {
            if (!event.animCancelled || event.noteType != "No Anim Note") {
                darkBoyfriendChar.playSingAnim(event.direction, event.animSuffix, "SING", event.forceAnim);
            }
        }
        else {
            if (!event.animCancelled || event.noteType != "No Anim Note") {
                var animName:String = darkBoyfriendChar.singAnims[event.direction % darkBoyfriendChar.singAnims.length] + event.animSuffix + "-loop";
                if (darkBoyfriendChar.animation.exists(animName))
                    darkBoyfriendChar.playSingAnim(event.direction, event.animSuffix + "-loop", "SING", false);
                else {
                    darkBoyfriendChar.playSingAnim(event.direction, event.animSuffix, "SING", false);
                    darkBoyfriendChar.animation.finish();
                }
            }
        }
    }
}

function onNewPlayerMiss(event) {
    if (songUsesLightsSabotage)
        darkBoyfriendChar.playSingAnim(event.direction, event.animSuffix, "MISS", event.forceAnim);
}

function onNewOpponentHit(event) {
    if (songUsesLightsSabotage) {
        if (!event.note.isSustainNote) {
            if (!event.animCancelled || event.noteType != "No Anim Note") {
                darkDadChar.playSingAnim(event.direction, event.animSuffix, "SING", event.forceAnim);
            }
        }
        else {
            if (!event.animCancelled || event.noteType != "No Anim Note") {
                var animName:String = darkDadChar.singAnims[event.direction % darkDadChar.singAnims.length] + event.animSuffix + "-loop";
                if (darkDadChar.animation.exists(animName))
                    darkDadChar.playSingAnim(event.direction, event.animSuffix + "-loop", "SING", event.forceAnim);
                else {
                    darkDadChar.playSingAnim(event.direction, event.animSuffix, "SING", event.forceAnim);
                    darkDadChar.animation.finish();
                }
            }
        }
    }
}

function onComboBroken(curCombo:Int) {
    if (songUsesLightsSabotage)
        darkGfChar.scripts.call("playComboDropAnim", [curCombo]);
}

function onEvent(event) {
    if (event.event.name == "Play Animation") {
        params = {
            strumline: event.event.params[0],
            animation: event.event.params[1],
            isForced: event.event.params[2],
        }
        if (songUsesLightsSabotage) {
            switch(params.strumline) {
                case 0: darkDadChar.playAnim(params.animation, params.isForced, null);
                case 1: darkBoyfriendChar.playAnim(params.animation, params.isForced, null);
                case 2: darkGfChar.playAnim(params.animation, params.isForced, null);
            }
        }
    }
}