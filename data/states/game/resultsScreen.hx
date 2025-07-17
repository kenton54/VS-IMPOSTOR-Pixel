import funkin.menus.StoryMenuState;
import flixel.sound.FlxSound;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.util.FlxStringUtil;
import funkin.backend.utils.CoolUtil;
import funkin.options.Options;

var beanAmount:Int = 0;

var barOutline:FlxSprite;
var barAccuracy:FlxBar;
var perfectShine:FlxSprite;
var accuracyTxt:FunkinText;

var curBeans:FunkinText;
var beans2get:FunkinText;

var resultChar:FlxSprite;
var rankSprite:FlxSprite;
var particles:FlxTypedEmitter;

var quitButton:FlxSprite;
var replayButton:FlxSprite;

var songName:String = "";
var songDisplayName:String = "";
var songDifficulty:String = "";
var gameScore:Int = 0;
var gameAccuracy:Float = 0.0;

var acurracyLerp:Float = 0;

var barSound:FlxSound;

function create() {
    importScript("data/global");

    FlxG.mouse.visible = false;

    songName = FlxG.save.data.resultsStuff[0];
    songDisplayName = FlxG.save.data.resultsStuff[1];
    songDifficulty = FlxG.save.data.resultsStuff[2];
    gameScore = FlxG.save.data.resultsStuff[3];
    gameAccuracy = FlxG.save.data.resultsStuff[4];

    //gameAccuracy = 1;

    beanAmount = Math.floor(gameScore / (800 / getDifficultyMultiplier(PlayState.difficulty)));

    barSound = new FlxSound();
    barSound.loadEmbedded(Paths.sound("results/bar"), true);
    barSound.pitch = 0.01; // 1%
    FlxG.sound.list.add(barSound);

    var title:FunkinText = new FunkinText(0, 12, 0, songDisplayName, 100);
    title.color = FlxColor.BLACK;
    title.borderColor = FlxColor.WHITE;
    title.borderSize = 3.5;
    title.alignment = "center";
    title.scale.x = 1.1;
    title.updateHitbox();
    title.screenCenter(FlxAxes.X);
    title.antialiasing = Options.antialiasing;
    add(title);

    var diffTxt:FunkinText = new FunkinText(0, (title.y + title.height) - 4, FlxG.width, songDifficulty, 32);
    diffTxt.color = FlxColor.BLACK;
    diffTxt.borderColor = FlxColor.WHITE;
    diffTxt.borderSize = 3;
    diffTxt.alignment = "center";
    diffTxt.antialiasing = Options.antialiasing;
    add(diffTxt);

    barOutline = new FlxSprite().loadGraphic(Paths.image("results/bar"));
    barOutline.scale.set(8, 8);
    barOutline.updateHitbox();
    barOutline.screenCenter();
    barOutline.x += 120;
    barOutline.antialiasing = false;

    barAccuracy = new FlxBar(barOutline.x + 16, barOutline.y + 16, FlxBarFillDirection.LEFT_TO_RIGHT, barOutline.width - 32, barOutline.height - 32);
    barAccuracy.setRange(0, 1);
    barAccuracy.createGradientEmptyBar([0xFF000000], 1);
    barAccuracy.createGradientFilledBar([0xFF888888, 0xFF555555], 1);
    barAccuracy.antialiasing = Options.antialiasing;

    perfectShine = new FlxSprite(barOutline.x, barOutline.y).loadGraphic(Paths.image("results/perfectShine"));
    perfectShine.scale.set(8, 8);
    perfectShine.updateHitbox();
    perfectShine.alpha = 0.5;
    perfectShine.blend = 0;
    perfectShine.visible = false;

    add(barAccuracy);
    add(perfectShine);
    add(barOutline);

    accuracyTxt = new FunkinText(barOutline.x, (barOutline.y + barOutline.height) + 4, barOutline.width, "0%", 40);
    accuracyTxt.color = FlxColor.BLACK;
    accuracyTxt.borderColor = FlxColor.WHITE;
    accuracyTxt.borderSize = 3;
    accuracyTxt.alignment = "center";
    add(accuracyTxt);

    var beanIcon:FlxSprite = new FlxSprite(480, 520).loadGraphic(Paths.image("pixelBean"));
    beanIcon.scale.set(4, 4);
    beanIcon.updateHitbox();
    beanIcon.antialiasing = false;
    add(beanIcon);

    curBeans = new FunkinText((beanIcon.x + beanIcon.width) + 12, beanIcon.y + (beanIcon.height / 8), 0, FlxStringUtil.formatMoney(FlxG.save.data.pixelBeans, false, true), 80);
    curBeans.borderSize = 5;
    curBeans.antialiasing = Options.antialiasing;
    add(curBeans);

    var beansTxt:FunkinText = new FunkinText(curBeans.x, (curBeans.y + curBeans.height) + 10, 0, "Beans", 36);
    beansTxt.borderSize = 3;
    beansTxt.antialiasing = Options.antialiasing;
    add(beansTxt);

    beans2get = new FunkinText(curBeans.x, 0, 0, "+" + beanAmount, 60);
    beans2get.y = curBeans.y - (10 + beans2get.height);
    beans2get.borderSize = 4;
    beans2get.antialiasing = Options.antialiasing;
    beans2get.visible = false;
    add(beans2get);

    var lightShadow:FlxSprite = new FlxSprite(18, 480).loadGraphic(Paths.image("results/light"));
    lightShadow.scale.set(2.4, 2);
    lightShadow.updateHitbox();
    lightShadow.alpha = 0.95;
    add(lightShadow);

    resultChar = new FlxSprite(-75, -360);
    resultChar.frames = Paths.getSparrowAtlas("results/characters/" + pixelPlayable);
    resultChar.animation.addByPrefix("intro", "intro", 24, false);
    resultChar.animation.addByPrefix("resultsShit", "shitIntro", 24, false);
    resultChar.animation.addByPrefix("resultsShit-loop", "shitLoop", 24, true);
    resultChar.animation.addByPrefix("resultsOk", "okIntro", 24, false);
    resultChar.animation.addByPrefix("resultsOk-loop", "okLoop", 24, true);
    resultChar.animation.addByPrefix("resultsGood", "goodIntro", 24, false);
    resultChar.animation.addByPrefix("resultsGood-loop", "goodLoop", 24, true);
    resultChar.scale.set(8, 8);
    resultChar.updateHitbox();
    resultChar.antialiasing = false;
    resultChar.visible = false;
    add(resultChar);

    var rankFramerate:Int = 12;
    rankSprite = new FlxSprite(barOutline.x + barOutline.width, barOutline.y);
    rankSprite.frames = Paths.getSparrowAtlas("results/ranks");
    rankSprite.animation.addByPrefix("S++", "p", rankFramerate, true);
    rankSprite.animation.addByPrefix("S", "s", rankFramerate, true);
    rankSprite.animation.addByPrefix("A", "a", rankFramerate, true);
    rankSprite.animation.addByPrefix("B", "b", rankFramerate, true);
    rankSprite.animation.addByPrefix("C", "c", rankFramerate, true);
    rankSprite.animation.addByPrefix("D", "d", rankFramerate, true);
    rankSprite.animation.addByPrefix("E", "e", rankFramerate, true);
    rankSprite.animation.addByPrefix("F", "f", rankFramerate, true);
    rankSprite.scale.set(3, 3);
    rankSprite.updateHitbox();
    rankSprite.x -= rankSprite.width / 2.5;
    rankSprite.y -= rankSprite.height / 2.5;
    rankSprite.visible = false;

    particles = new FlxTypedEmitter(rankSprite.x + (rankSprite.width / 2), rankSprite.y + (rankSprite.height / 2), 20);
    particles.makeParticles(5, 5, getBarRankColor()[0], 20);
    particles.scale.set(1.5, 1.5, 3, 3);
    particles.speed.set(80, -500, -80);
    particles.lifespan.set(500, 500);
    particles.acceleration.set(0, 360);
    particles.keepScaleRatio = true;

    add(particles);
    add(rankSprite);

    quitButton = new FlxSprite(20, FlxG.height - 5).loadGraphic(Paths.image("quit"));
    quitButton.scale.set(5, 5);
    quitButton.updateHitbox();
    quitButton.y -= quitButton.height;
    quitButton.visible = false;
    add(quitButton);

    replayButton = new FlxSprite(FlxG.width - 20, FlxG.height - 5).loadGraphic(Paths.image("replay"));
    replayButton.scale.set(5, 5);
    replayButton.updateHitbox();
    replayButton.x -= replayButton.width;
    replayButton.y -= quitButton.height;
    replayButton.visible = false;
    add(replayButton);

    trace("Beans to get: " + beanAmount);

    new FlxTimer().start(0.5, _ -> {
        resultChar.visible = true;
        resultChar.animation.play("intro", true);
    });

    new FlxTimer().start(0.8, _ -> {
        barSound.play();
        FlxTween.tween(barSound, {pitch: gameAccuracy * 3}, 4, {ease: FlxEase.expoOut});
        lerpTween = FlxTween.num(acurracyLerp, gameAccuracy, 4, {ease: FlxEase.expoOut, onComplete: _ -> {playResultsAnim();}}, function(num) {
            acurracyLerp = num;
            barAccuracy.value = acurracyLerp;
            accuracyTxt.text = FlxMath.roundDecimal(acurracyLerp * 100, 2) + "%";
        });
        doLerp = true;
    });
}

var doLerp:Bool = false;
var allowExit:Bool = false;
var lerpTween:FlxTween;

function update(elapsed:Float) {
    if (doLerp) {
        if (Math.abs(acurracyLerp) > gameAccuracy - 0.002) {
            lerpTween.cancel();
            acurracyLerp = gameAccuracy;
            accuracyTxt.text = FlxMath.roundDecimal(acurracyLerp * 100, 2) + "%";
        }

        if (acurracyLerp >= gameAccuracy)
            playResultsAnim();

        /*
        barAccuracy.value = acurracyLerp;
        accuracyTxt.text = acurracyLerp * 100 + "%";
        */
    }

    if (allowExit) {
        if (FlxG.mouse.overlaps(quitButton) && FlxG.mouse.justPressed) {
            FlxG.sound.play(Paths.sound("menu/cancel"));
            FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
        }
        if (FlxG.mouse.overlaps(replayButton) && FlxG.mouse.justPressed) {
            FlxG.sound.play(Paths.sound("menu/cancel"));
            FlxG.switchState(new PlayState());
        }
    }
}

function playResultsAnim() {
    var rankAnimTimer:Float = 0.4;

    doLerp = false;
    barSound.stop();
    barSound.destroy();

    if (gameAccuracy > 0.85) {
        FlxG.sound.play(Paths.sound("results/sick"));
        new FlxTimer().start(rankAnimTimer, _ ->{
            resultChar.animation.play("resultsGood", true);
            resultChar.animation.finishCallback = _ -> {resultChar.animation.play("resultsGood-loop");};
        });
    }
    else if (gameAccuracy > 0.7) {
        FlxG.sound.play(Paths.sound("results/normal"));
        new FlxTimer().start(rankAnimTimer, _ ->{
            resultChar.animation.play("resultsOk", true);
            resultChar.animation.finishCallback = _ -> {resultChar.animation.play("resultsOk-loop");};
        });
    }
    else {
        FlxG.sound.play(Paths.sound("results/shit"));
        new FlxTimer().start(rankAnimTimer, _ -> {
            resultChar.animation.play("resultsShit", true);
            resultChar.animation.finishCallback = _ -> {resultChar.animation.play("resultsShit-loop");};
        });
    }
    displayRank();
    newBeans();
}

function displayRank() {
    barSound.stop();

    if (gameAccuracy >= 1)
        perfectShine.visible = true;

    barOutline.scale.set(8.4, 8.4);
    barAccuracy.scale.set(1.05, 1.05);
    perfectShine.scale.set(8.4, 8.4);
    FlxTween.tween(barOutline, {"scale.x": 8, "scale.y": 8}, 0.5);
    FlxTween.tween(barAccuracy, {"scale.x": 1, "scale.y": 1}, 0.5);
    FlxTween.tween(perfectShine, {"scale.x": 8, "scale.y": 8}, 0.5);

    barAccuracy.createGradientFilledBar(getBarRankColor(), 1);
    barAccuracy.updateBar();

    rankSprite.visible = true;
    rankSprite.animation.play(getRank(), true);
    rankSprite.scale.set(10, 10);
    FlxTween.tween(rankSprite, {"scale.x": 3, "scale.y": 3}, 0.075, {onComplete: _ -> {
        particles.start(true, 1);
        FlxTween.shake(rankSprite, 0.05, 0.1);
    }});
}

function newBeans() {
    new FlxTimer().start(1, _ -> {
        beans2get.visible = true;
        FlxTween.shake(beans2get, 0.5, 0.08);
    });

    new FlxTimer().start(2.5, _ -> {
        var yPos1:Float = beans2get.y - 15;
        var yPos2:Float = curBeans.y + (curBeans.height / 4);
        FlxTween.tween(beans2get, {y: yPos1}, 0.1, {ease: FlxEase.smoothStepInOut, onComplete: _ -> {
            FlxG.sound.play(Paths.sound("results/merge"));
            FlxTween.tween(beans2get, {alpha: 0}, 0.2, {onComplete: _ -> {
                curBeans.scale.set(1.2, 1.2);
                FlxTween.tween(curBeans, {"scale.x": 1, "scale.y": 1}, 0.5);

                var newAmount = FlxG.save.data.pixelBeans + beanAmount;
                curBeans.text = FlxStringUtil.formatMoney(newAmount, false, true);

                FlxG.save.data.pixelBeans += beanAmount;

                new FlxTimer().start(1, _ -> {canExit();});
            }});
            FlxTween.tween(beans2get, {y: yPos2}, 0.3, {ease: FlxEase.smoothStepIn});
        }});
    });
}

function canExit() {
    allowExit = true;
    FlxG.mouse.visible = true;
    quitButton.visible = true;
    replayButton.visible = true;
}

function getDifficultyMultiplier(difficulty:String):Float {
    return switch(difficulty) {
        case "EASY": 0.5;
        case "NORMAL": 1;
        case "HARD": 2;
    };
}

function getRank():String {
    if (gameAccuracy >= 1)
        return "S++";
    else if (gameAccuracy >= 0.95)
        return "S";
    else if (gameAccuracy >= 0.9)
        return "A";
    else if (gameAccuracy >= 0.85)
        return "B";
    else if (gameAccuracy >= 0.8)
        return "C";
    else if (gameAccuracy >= 0.7)
        return "D";
    else if (gameAccuracy >= 0.5)
        return "E";
    else
        return "F";
}

function getBarRankColor():Array<FlxColor> {
    if (gameAccuracy >= 1)          // P
        return [0xFFDBB438, 0xFFC79D2E];
    else if (gameAccuracy >= 0.95)  // S
        return [0xFF44FFFF, 0xFF00CCFF];
    else if (gameAccuracy >= 0.9)   // A
        return [0xFF88FF44, 0xFF00AA00];
    else if (gameAccuracy >= 0.85)  // B
        return [0xFFAAFF44, 0xFF88DD00];
    else if (gameAccuracy >= 0.8)   // C
        return [0xFFFFFF44, 0xFFFFBB00];
    else if (gameAccuracy >= 0.7)   // D
        return [0xFFFFAA44, 0xFFFF7700];
    else if (gameAccuracy >= 0.5)   // E
        return [0xFFFF8844, 0xFFFF6600];
    else                            // F wow u suck
        return [0xFFFF4444, 0xFFDD0033];
}