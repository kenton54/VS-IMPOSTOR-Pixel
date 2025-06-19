import flixel.graphics.tile.FlxGraphicsShader;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import funkin.editors.charter.Charter;
import funkin.game.HealthIcon;
import funkin.game.Note;
import funkin.game.StrumLine;
import funkin.menus.StoryMenuState;
import funkin.savedata.FunkinSave;
import funkin.savedata.HighscoreChange;
import funkin.options.Options;
import openfl.filters.ShaderFilter;
import Date;

public var taskbarBG:FlxSprite;
public var taskbar:FlxSprite;
public var taskbarTxt:FunkinText;

public var ratingHitTxt:FunkinText;

public var camMovementSpeed:Float = 1;

public var songPercent:Float = 0;

var notesHit:Float = 0;
var sickHits:Int = 0;
var notesMissed:Int = 0;

var healthLerp:Float = 0;
var maxHealth:Float = 2;

// hold note covers
var coverData:Array<Any> = [];
var coverGroup:FlxSpriteGroup;
public var holdCoverSkin:String = "game/holdCovers/impostorPixel-default";
public var holdCoverColor:Array<String> = ["purple", "blue", "green", "red"];

function create() {
    taskbarBG = new FlxSprite(45).loadGraphic(Paths.image("game/taskBar"));
    taskbarBG.scale.set(4, 3.5);
    taskbarBG.updateHitbox();
    taskbarBG.alpha = 0;
    taskbarBG.y = PlayState.downscroll ? 675 : 4;
    taskbarBG.camera = camHUD;
    taskbarBG.visible = FlxG.save.data.pixelTimeBar;
    add(taskbarBG);

    taskbar = new FlxSprite(taskbarBG.x + 16, taskbarBG.y + 14).loadGraphic(Paths.image("game/taskBar-progress"));
    taskbar.scale.set(4, 3.5);
    taskbar.updateHitbox();
    taskbar.color = 0xFF43D844;
    taskbar.alpha = 0;
    taskbar.camera = camHUD;
    taskbar.visible = FlxG.save.data.pixelTimeBar;
    add(taskbar);

    taskbarTxt = new FunkinText(taskbarBG.x + 24, taskbarBG.y + 10, 0, SONG.meta.displayName, 20);
    taskbarTxt.borderSize = 2;
    taskbarTxt.alpha = 0;
    taskbarTxt.camera = camHUD;
    taskbarTxt.visible = FlxG.save.data.pixelTimeBar;
    add(taskbarTxt);

    camZooming = true;
}

/*
function createHoldCovers() {
    coverGroup = new FlxSpriteGroup();
    coverGroup.camera = camHUD;
    add(coverGroup);

    var i:Int = 0;
    for (strumLine in strumLines.members) {
        if (i > 3) i = 0;

        // dont create hold covers if the strumline doesnt have any notes
        if (strumLine.notes.length < 1) break;

        for (strum in strumLine.members) {
            var cover:FlxSprite = new FlxSprite();
            cover.frames = Paths.getFrames(holdCoverSkin);
            cover.animation.addByPrefix("start", holdCoverColor[i] + " hold cover start", 24, false);
            cover.animation.addByPrefix("hold", holdCoverColor[i] + " hold cover loop", 24, true);
            cover.animation.addByPrefix("end", holdCoverColor[i] + " hold cover end", 24, false);
            cover.animation.play("hold");
            cover.antialiasing = false;
            cover.scale.set(5.55, 5.55);
            cover.updateHitbox();
            cover.offset.set(-53.5, -50);
            cover.visible = false;

            cover.setPosition(strum.x, strum.y);

            coverGroup.add(cover);
            coverData.push({cover: cover});

            i++;
        }
    }
}
*/

function postCreate() {
    healthLerp = health;

    healthBarBG.loadGraphic(Paths.image("game/healthBar"));
    healthBarBG.scale.set(4.68, 4.68);
    healthBarBG.updateHitbox();
    healthBarBG.screenCenter(FlxAxes.X);
    healthBarBG.y = FlxG.height * 0.89;

    var leftColor:FlxColor = (dad != null && dad.iconColor != null && Options.colorHealthBar) ? dad.iconColor : (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000);
    var rightColor:FlxColor = (boyfriend != null && boyfriend.iconColor != null && Options.colorHealthBar) ? boyfriend.iconColor : (PlayState.opponentMode ? 0xFFFF0000 : 0xFF66FF33);

    healthBar.barWidth = 732;
    healthBar.barHeight = 21;
    healthBar.createFilledBar(leftColor, rightColor);
    healthBar.setPosition(healthBarBG.x + 8, healthBarBG.y + 8);
    healthBar.setParent();
    healthBar.setRange(0, maxHealth);
    healthBar.updateBar();

    iconP1.y = (healthBarBG.y + healthBarBG.height / 2) - iconP1.height / 2;
    iconP2.y = (healthBarBG.y + healthBarBG.height / 2) - iconP2.height / 2;

    insert(0, healthBarBG);
    insert(1, healthBar);
    insert(2, iconP1);
    insert(3, iconP2);

    scoreTxt.font = Paths.font("gameboy.ttf");
    scoreTxt.text = "0";
    scoreTxt.size = 28;
    scoreTxt.fieldWidth = FlxG.width;
    scoreTxt.alignment = "center";
    scoreTxt.borderSize = 3.5;
    scoreTxt.scale.x = 1.2;
    scoreTxt.updateHitbox();
    scoreTxt.screenCenter(FlxAxes.X);
    scoreTxt.y = (healthBarBG.y + healthBarBG.height) + 1;

    missesTxt.visible = false;
    accuracyTxt.visible = false;

    ratingHitTxt = new FunkinText(0, healthBar.y, FlxG.width, '\n', 40, true);
    ratingHitTxt.font = Paths.font("pixeloidsans.ttf");
    ratingHitTxt.alignment = "center";
    ratingHitTxt.borderSize = 5;
    ratingHitTxt.y += PlayState.downscroll ? 0 : -110;
    ratingHitTxt.camera = camHUD;
    ratingHitTxt.alpha = 0;
    add(ratingHitTxt);

    //createHoldCovers();

    for (strumline in strumLines.members) {
        insert(members.length, strumline);
    }

    if (FlxG.save.data.impPixelxBRZ) {
        forEach(function(spr) {
            if (spr is FunkinSprite) {
                if (spr.camera == camGame) {
                    var xbrzShader:CustomShader = new CustomShader("xbrz");
                    xbrzShader.precisionHint = 0;
                    spr.shader = xbrzShader;
                }
            }
        });

        splashHandler.getSplashGroup("impostorPixel-default").forEach(function(splash) {
            var xbrzShader:CustomShader = new CustomShader("xbrz");
            xbrzShader.precisionHint = 0;
            splash.shader = xbrzShader;
        });
    }
}

function update(elapsed:Float) {
    songPercent = (Conductor.songPosition / inst.length);

    taskbar.scale.x = songPercent * 4;
    taskbar.updateHitbox();

    updateHealthBar();
}

function updateHealthBar() {
    healthLerp = FlxMath.lerp(healthLerp, health, 0.15);
    healthBar.value = healthLerp;
}

function postUpdate(elapsed:Float) {
    taskbarTxt.text = SONG.meta.displayName + " (" + Math.round(songPercent * 100) + "%)";
    scoreTxt.text = songScore;

    FlxG.camera.followLerp = 0.04 * camMovementSpeed;

    if (!inCutscene)
        processNotes(elapsed);

    if (FlxG.keys.justPressed.NINE)
        endSong();

    if (FlxG.keys.justPressed.EIGHT)
        transitionToResults();
}

function onStartSong() {
    //inst.onComplete = impostorEndSong;

    FlxTween.tween(taskbarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    FlxTween.tween(taskbar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    FlxTween.tween(taskbarTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
}

var holdScoreBonus:Float = 250;
var holdScorePenalty:Float = -125;

var maxScore:Float = 500;
var minScore:Float = 9;
var missScore:Float = -100;
var ghostScore:Float = -50;

var vsliceScoringOffset:Float = 54.99;
var vsliceScoringSlope:Float = 0.08;

function processNotes(elapsed:Float) {
    for (playerNote in playerStrums.notes.members) {
        if (playerNote == null || !playerNote.alive) continue;

        if (playerNote.wasGoodHit && playerNote.isSustainNote && playerNote.sustainLength > 0) {
            health += holdHealthBonus * elapsed;
            songScore += Std.int(holdScoreBonus * elapsed);
        }
    }
}

var perfectHealth:Float = 2 / 100 * maxHealth;      // 2% gain
var sickHealth:Float = 1.5 / 100 * maxHealth;       // 1.5% gain
var goodHealth:Float = 0.75 / 100 * maxHealth;      // 0.75% gain
var badHealth:Float = 0 / 100 * maxHealth;          // no gain
var shitHealth:Float = -1 / 100 * maxHealth;        // 1% loss
var holdHealthBonus:Float = 4 / 100 * maxHealth;    // 4% gain per second
var ghostHealth:Float = -2 / 100 * maxHealth;       // 2% loss
var missHealth:Float = -4 / 100 * maxHealth;        // 4% loss
var holdHealthDrop:Float = 0.5 / 100 * maxHealth;   // 0.5% gain per sustain length remaining

function onPlayerHit(event) {
    event.cancel();

    event.note.wasGoodHit = true;

    var strumline:StrumLine = strumLines.members[event.playerID];

    if (event.unmuteVocals) {
        vocals.volume = 1;
        strumline.vocals.volume = 1;
    }

    var timing:Float = Math.abs(Conductor.songPosition - event.note.strumTime);

    var score2add:Int = calculateScore(timing);
    var health2gain:Float = healthJudge(timing);
    var daRating:String = ratingJudge(timing);
    var showSplashes:Bool = (timing < sickThreshold);
    var accuracy:Float = 0;

    if (!event.note.isSustainNote) {
        songScore += score2add;
        health += health2gain;
        if (daRating == "sick" || daRating == "perfect")
            sickHits++;
        notesHit++;
        recalculateAccuracy();

        if (event.countAsCombo)
            combo++;

        for (char in event.characters) {
            if (char != null)
                char.playSingAnim(event.direction, event.animSuffix, "SING", event.forceAnim);
        }

        if (event.note.__strum != null) {
            event.note.__strum.press(event.note.strumTime);
            if (showSplashes) splashHandler.showSplash(event.note.splash, event.note.__strum);
        }

        if (daRating == "bad" || daRating == "shit") {
            breakCombo();
        }

        displayRating(daRating, score2add);
    }
    else {
        for (char in event.characters) {
            if (char != null) {
                var animName:String = char.singAnims[event.direction % char.singAnims.length] + event.animSuffix + "-loop";
                if (char.animation.exists(animName))
                    char.playSingAnim(event.direction, event.animSuffix + "-loop", "SING", false);
                else {
                    char.playSingAnim(event.direction, event.animSuffix, "SING", false);
                    char.animation.finish();
                }
            }
        }

        if (event.note.__strum != null) {
            event.note.__strum.press(event.note.strumTime);
            event.note.__strum.animation.finish();
        }
    }

    if (event.autoHitLastSustain) {
        if (event.note.nextSustain != null && event.note.nextSustain.nextSustain == null) {
            // its a tail
            event.note.nextSustain.wasGoodHit = true;
        }
    }

    if (event.deleteNote)
        strumline.deleteNote(event.note);
}

function onDadHit(event) {
    event.cancel();

    event.note.wasGoodHit = true;

    var strumline:StrumLine = strumLines.members[event.playerID];

    if (event.unmuteVocals) {
        vocals.volume = 1;
        strumline.vocals.volume = 1;
    }

    var timing:Float = Math.abs(Conductor.songPosition - event.note.strumTime);

    var score2add:Int = calculateScore(timing);
    var health2gain:Float = healthJudge(timing);
    var daRating:String = ratingJudge(timing);
    var showSplashes:Bool = (timing < sickThreshold);
    var accuracy:Float = 0;

    if (!event.note.isSustainNote) {
        /*
        songScore += score2add;
        health += health2gain;
        accuracyPressedNotes++;
        totalAccuracyAmount += event.accuracy;

        if (event.countAsCombo)
            combo++;
        */

        for (char in event.characters) {
            if (char != null)
                char.playSingAnim(event.direction, event.animSuffix, "SING", event.forceAnim);
        }

        if (event.note.__strum != null) {
            event.note.__strum.press(event.note.strumTime);
            //if (showSplashes) splashHandler.showSplash(event.note.splash, event.note.__strum);
        }

        /*
        if (daRating == "bad" || daRating == "shit") {
            breakCombo();
        }

        displayRating(daRating, score2add);
        */
    }
    else {
        for (char in event.characters) {
            if (char != null) {
                var animName:String = char.singAnims[event.direction % char.singAnims.length] + event.animSuffix + "-loop";
                if (char.animation.exists(animName))
                    char.playSingAnim(event.direction, event.animSuffix + "-loop", "SING", false);
                else {
                    char.playSingAnim(event.direction, event.animSuffix, "SING", false);
                    char.animation.finish();
                }
            }
        }

        if (event.note.__strum != null) {
            event.note.__strum.press(event.note.strumTime);
            event.note.__strum.animation.finish();
        }
    }

    if (event.autoHitLastSustain) {
        if (event.note.nextSustain != null && event.note.nextSustain.nextSustain == null) {
            // its a tail
            event.note.nextSustain.wasGoodHit = true;
        }
    }

    if (event.deleteNote)
        strumline.deleteNote(event.note);
}

var exactThreshold:Float = 5;
var missThreshold:Float = 160;
function calculateScore(timing:Float):Int {
    var daScor:Int = 0;
    if (timing > missThreshold)
        daScor = missScore;
    else if (timing < exactThreshold)
        daScor = maxScore;
    else {
        var factor:Float = 1 - (1 / (1 + Math.exp(-vsliceScoringSlope * (timing - vsliceScoringOffset))));
        daScor = Std.int(maxScore * factor + minScore);
    }

    return daScor;
}

var perfectThreshold:Float = 12.5;
var sickThreshold:Float = 45;
var goodThreshold:Float = 90;
var badThreshold:Float = 135;
var shitThreshold:Float = 160;

function healthJudge(timing:Float):Float {
    var hp:Float = 0;
    if (timing < perfectThreshold)
        hp = perfectHealth;
    else if (timing < sickThreshold)
        hp = sickHealth;
    else if (timing < goodThreshold)
        hp = goodHealth;
    else if (timing < badThreshold)
        hp = badHealth;
    else if (timing < shitThreshold)
        hp = shitHealth;

    return hp;
}

function ratingJudge(timing:Float):String {
    var rating:String = "";
    if (timing < perfectThreshold)
        rating = "perfect";
    else if (timing < sickThreshold)
        rating = "sick";
    else if (timing < goodThreshold)
        rating = "good";
    else if (timing < badThreshold)
        rating = "bad";
    else if (timing < shitThreshold)
        rating = "shit";
    else
        rating = "miss";

    return rating;
}

function onPlayerMiss(event) {
    event.cancel();

    var strumline:StrumLine = strumLines.members[event.playerID];

    FlxG.sound.play(event.missSound, event.missVolume);

    if (event.muteVocals) {
        vocals.volume = 0;
	    strumline.vocals.volume = 0;
    }

    var scor:Int = 0;
    if (event.ghostMiss) {
        health += ghostHealth;
        scor = ghostScore;
    }
    else {
        if (!event.note.isSustainNote) {
            health += missHealth;
            scor = missScore;
        }
        breakCombo();
    }

    notesMissed++;
    notesHit++;
    songScore += scor;
    recalculateAccuracy();

    for (char in event.characters) {
        if (char != null)
            char.playSingAnim(event.direction, event.animSuffix, "MISS", event.forceAnim);
    }

    if (event.note != null && strumline != null) {
        var timing:Float = Math.abs(Conductor.songPosition - event.note.strumTime);

        strumline.deleteNote(event.note);

        displayRating(ratingJudge(timing), scor);
    }
}

function recalculateAccuracy() {
    accuracy = Math.min(1, Math.max(0, (sickHits - notesMissed) / notesHit));
    trace("accuracy: "+accuracy);
}

var ratingTimer:FlxTimer = new FlxTimer();
function displayRating(rating:String, score:Int) {
    FlxTween.cancelTweensOf(ratingHitTxt, ["scale.x", "scale.y", "alpha"]);
    ratingHitTxt.alpha = 1;
    ratingHitTxt.scale.set(1.2, 1.2);
    FlxTween.tween(ratingHitTxt, {"scale.x": 1, "scale.y": 1}, 0.25, {ease: FlxEase.sineOut});

    var comboTxt:String = (rating == "miss") ? "" : " x" + Std.string(combo);
    var combTxtShow:String = (combo >= 10) ? comboTxt : "";
    var plus:String = (score >= 0) ? "+" : "";
    ratingHitTxt.text = getRatingDisplay(rating) + combTxtShow + '\n' + plus + Std.string(score);
    ratingHitTxt.color = getRatingColor(rating);

    ratingTimer.cancel();
    ratingTimer.start(1.5, _ -> {
        FlxTween.tween(ratingHitTxt, {alpha: 0}, 0.5);
    });
}

function breakCombo(ignoreCurCombo:Bool = false) {
    if (combo >= 10 || ignoreCurCombo) {
        var combBrokenTxt:FunkinText = new FunkinText(0, ratingHitTxt.y, 400, "Combo Broken", ratingHitTxt.size, true);
        combBrokenTxt.font = ratingHitTxt.font;
        combBrokenTxt.borderSize = ratingHitTxt.borderSize;
        combBrokenTxt.alignment = "center";
        combBrokenTxt.color = FlxColor.RED;
        combBrokenTxt.camera = camHUD;
        combBrokenTxt.screenCenter(FlxAxes.X);
        insert(members.indexOf(ratingHitTxt) + 1, combBrokenTxt);

        combBrokenTxt.moves = true;
        combBrokenTxt.acceleration.y = 600;
        combBrokenTxt.velocity.y -= FlxG.random.int(140, 175);
        combBrokenTxt.velocity.x += FlxG.random.int(-40, 40);
        combBrokenTxt.angularVelocity = combBrokenTxt.velocity.x / 4;

        new FlxTimer().start(0.5, _ -> {
            FlxTween.tween(combBrokenTxt, {alpha: 0}, 0.5, {onComplete: _ -> {
                combBrokenTxt.destroy();
            }});
        });
    }
    combo = 0;
}

function getRatingDisplay(rating:String):String {
    var ratin:String = "";
    if (rating == "perfect")
        ratin = "Perfect!!!";
    else if (rating == "sick")
        ratin = "Sussy!!";
    else if (rating == "good")
        ratin = "Sus!";
    else if (rating == "bad")
        ratin = "Bad";
    else if (rating == "shit")
        ratin = "Ass!";
    else
        ratin = "Miss...";

    return ratin;
}

function getRatingColor(rating:String):FlxColor {
    var color:FlxColor = FlxColor.BLACK;
    if (rating == "perfect")
        color = 0xFFFFDF00;
    else if (rating == "sick")
        color = FlxColor.CYAN;
    else if (rating == "good")
        color = FlxColor.LIME;
    else if (rating == "bad")
        color = 0xFFFF4500;
    else if (rating == "shit")
        color = 0xFFAA0000;
    else
        color = FlxColor.GRAY;

    return color;
}

/*
function onNoteHit(event) {
    coverBehaviour(event.note, event.player);
}

function coverBehaviour(note:Note, isPlayer:Bool) {
    var data:Int = note.noteData;
    if (isPlayer) data += strumLines.members[1].members.length;

    var cover:FlxSprite = coverData[data].cover;
    if (cover == null) return;

    if (note.isSustainNote) {
        if (StringTools.endsWith(note.animation.curAnim.name, "end")) {
            var delay:Float = 0.1;
            if (!isPlayer) {
                new FlxTimer().start(delay, _ -> {cover.visible = false;});
            }
            else {
                new FlxTimer().start(delay, _ -> {
                    cover.animation.play("end", true);
                    cover.animation.finishCallback = _ -> cover.visible = false;
                });
            }
        }
        else {
            cover.visible = true;
            cover.animation.play("start");
            cover.animation.finishCallback = _ -> cover.animation.play("hold", true);
        }
    }
}

function coverKill(cover:FlxSprite) {
    cover.visible = false;
    cover.kill();
}
*/

/*
function impostorEndSong() {
    PlayState.instance.scripts.call("onSongEnd");
    inst.volume = 0;
    vocals.volume = 0;
    for (strumLine in strumLines.members) {
		strumLine.vocals.volume = 0;
		strumLine.vocals.pause();
	}
	inst.pause();
	vocals.pause();

    trace(PlayState.SONG.meta.name, PlayState.difficulty, songScore, misses, accuracy);

    bullshit = {
        score: songScore,
        misses: misses,
        accuracy: accuracy,
        hits: [],
        date: Date.now().toString()
    }
    trace(bullshit);

    if (validScore) {
        FunkinSave.setSongHighscore(SONG.meta.name, PlayState.difficulty, bullshit, []);
    }

    trace(FunkinSave.getSongHighscore(SONG.meta.name, PlayState.difficulty));

    startCutscene("end-", endCutscene, go2nextSong);
    PlayState.resetSongInfos();
}

function go2nextSong() {
    if (PlayState.isStoryMode) {
        PlayState.campaignScore += songScore;
        PlayState.campaignMisses += misses;
        PlayState.campaignAccuracyTotal += accuracy;
        PlayState.campaignAccuracyCount++;
        PlayState.storyPlaylist.shift();

        if (storyPlaylist.length <= 0) {
            transitionToResults();

            if (validScore) {
                FunkinSave.setWeekHighscore(PlayState.storyWeek.id, PlayState.difficulty, {
                    score: PlayState.campaignScore,
                    misses: PlayState.campaignMisses,
                    accuracy: PlayState.campaignAccuracy,
                    hits: [],
                    date: Date.now().toString()
                });
            }
            FlxG.save.flush();
        }
        else {
            PlayState.instance.registerSmoothTransition(PlayState.storyPlaylist[0].toLowerCase(), PlayState.difficulty);

            registerSmoothTransition();

            FlxG.sound.music.stop();

            PlayState.__loadSong(PlayState.storyPlaylist[0].toLowerCase(), PlayState.difficulty);

            FlxG.switchState(new PlayState());
        }
    }
    else {
        if (PlayState.chartingMode) FlxG.switchState(new Charter(PlayState.SONG.meta.name, PlayState.difficulty, false));
        else transitionToResults();
    }
}
*/

function transitionToResults() {
    curCameraTarget = -1;

    var cam1:FlxPoint = FlxPoint.get(strumLines.members[0].characters[0].cameraOffset.x, strumLines.members[0].characters[0].cameraOffset.y);
    var cam2:FlxPoint = FlxPoint.get(strumLines.members[1].characters[0].cameraOffset.x, strumLines.members[1].characters[0].cameraOffset.y);

    var camGo2Pos:FlxPoint = FlxPoint.get(0, 0);
    camGo2Pos.x = FlxMath.lerp(cam1.x, cam2.x, 0.5);
    camGo2Pos.y = FlxMath.lerp(cam1.y, cam2.y, 0.5);

    camFollow.setPosition(camGo2Pos.x, camGo2Pos.y - 300);

    FlxG.save.data.resultsStuff = [
        PlayState.SONG.meta.name,
        PlayState.SONG.meta.displayName,
        PlayState.difficulty,
        PlayState.isStoryMode ? campaignScore : songScore,
        PlayState.isStoryMode ? campaignAccuracy : accuracy
    ];

    FlxTween.tween(camHUD, {alpha: 0}, 1);
    camGame.fade(FlxColor.BLACK, 1, false);
    new FlxTimer().start(1, _ -> {FlxG.switchState(new ModState("resultsScreen"));});
}