import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.util.FlxSort;
import funkin.backend.chart.EventsData;
import funkin.backend.scripting.DummyScript;
import funkin.backend.scripting.Script;
import funkin.backend.system.Flags;
import funkin.backend.system.Logs;
import funkin.backend.utils.WindowUtils;
import funkin.backend.system.Conductor.BeatType;
import funkin.backend.MusicBeatState;
import funkin.editors.charter.Charter;
import funkin.game.NoteGroup;
import funkin.menus.StoryMenuState;
import funkin.savedata.FunkinSave;
import funkin.savedata.HighscoreChange;
import funkin.options.Options;
import Date;
import HoldCoverHandler;
import ImpostorFlags;
import VSliceCharacter;

public var taskbarBG:FlxSprite;
public var taskbar:FlxSprite;
public var taskbarTxt:FunkinText;
public var overrideTaskbarTxt:Bool = false;

public var ratingHitTxt:FunkinText;

public var camMovementSpeed:Float = 1;

public var songPercent:Float = 0;

var strumlineBackgrounds:Array<FlxSprite> = [];

var totalNotes:Int = 0;
var notesHit:Int = 0;
var perfectHits:Int = 0;
var sickHits:Int = 0;
var goodHits:Int = 0;
var badHits:Int = 0;
var shitHits:Int = 0;
var notesMissed:Int = 0;
var combosBroken:Int = 0;

static var campaignPerfectHits:Int = 0;
static var campaignSickHits:Int = 0;
static var campaignGoodHits:Int = 0;
static var campaignBadHits:Int = 0;
static var campaignShitHits:Int = 0;
static var campaignCombosBroken:Int = 0;

var healthLerp:Float = 0;
public var maxHealth:Float = 2;

var fixScore:Bool = false;

var noteScale:Float = 5.55;

var noteArray:Array<String> = ["left", "down", "up", "right"];
var noteColor:Array<String> = ["purple", "blue", "green", "red"];

public var holdCoverHandlers:Array<HoldCoverHandler> = [];

public var noteStyle:String;

function create() {
    MusicBeatState.skipTransIn = false;

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

    taskbarTxt = new FunkinText(taskbarBG.x + 24, taskbarBG.y + 10, 0, PlayState.SONG.meta.displayName, 20);
    taskbarTxt.borderSize = 2;
    taskbarTxt.alpha = 0;
    taskbarTxt.camera = camHUD;
    taskbarTxt.visible = FlxG.save.data.pixelTimeBar;
    add(taskbarTxt);

    camZooming = true;
    validScore = true;
    curCameraTarget = -1;

    if (Reflect.hasField(PlayState.SONG.meta.customValues, "noteStyle")) {
        noteStyle = PlayState.SONG.meta.customValues.noteStyle;
    }
    else {
        noteStyle = "default";
        logTraceColored([
            {text: "[PlayState] ", color: getLogColor("cyan")},
            {text: "No style for the strumlines, notes, splashes and hold covers found in the song's metadata, using default..."}
        ]);
    }
}

function onNoteCreation(event) {
	event.cancel();

	var pixelNote = event.note;

	if (pixelNote.isSustainNote) {
		pixelNote.frames = Paths.getFrames("game/notes/" + noteStyle + "/sustains");
		pixelNote.animation.addByPrefix("hold", "sustain hold " + noteColor[event.strumID]);
		pixelNote.animation.addByPrefix("holdend", "sustain end " + noteColor[event.strumID]);
	}
	else {
		pixelNote.frames = Paths.getFrames("game/notes/" + noteStyle + "/notes");
		pixelNote.animation.addByPrefix("scroll", "note " + noteArray[event.strumID]);
	}
	pixelNote.scale.set(noteScale, noteScale);
	pixelNote.updateHitbox();
}

function onStrumCreation(event) {
	event.cancel();

	var daStrum = event.strum;

	daStrum.frames = Paths.getFrames("game/notes/" + noteStyle + "/strums");
	daStrum.animation.addByPrefix("static", "strum idle " + noteArray[event.strumID], 24, false);
	daStrum.animation.addByPrefix("pressed", "strum press " + noteArray[event.strumID], 12, false);
	daStrum.animation.addByPrefix("confirm", "strum hit " + noteArray[event.strumID], 24, false);

	daStrum.scale.set(noteScale, noteScale);
	daStrum.updateHitbox();

	daStrum.x -= 32;
}

function onPostNoteCreation(event) {
	event.note.splash = noteStyle;

    if (event.note.isSustainNote)
        event.note.alpha = 1;
    else {
        if (event.note.strumLine != null && !event.note.strumLine.cpu)
            totalNotes++;
    }
}

function postCreate() {
    camGame.snapToTarget();

    updateRatingStuff = null;
    defaultDisplayRating = false;
    defaultDisplayCombo = false;
    comboGroup.destroy();

    canDie = !ImpostorFlags.playingVersus;

    for (strumline in strumLines.members) {
        if (!strumline.visible) continue;
        var coverHandler:HoldCoverHandler = new HoldCoverHandler(noteStyle, strumline);
        holdCoverHandlers.push(coverHandler);
    }

    healthLerp = health;

    healthBarBG.loadGraphic(Paths.image("game/healthBar"));
    healthBarBG.scale.set(4.68, 4.68);
    healthBarBG.updateHitbox();
    healthBarBG.screenCenter(FlxAxes.X);
    healthBarBG.y = FlxG.height * 0.9;

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

    createCharacters();

    for (strumline in strumLines.members)
        insert(members.length, strumline);

    insert(members.length, splashHandler.getSplashGroup(noteStyle));

    WindowUtils.suffix = " - " + PlayState.SONG.meta.displayName + (!ImpostorFlags.playingVersus ? " [" + PlayState.difficulty + "] (SOLO)" : " (VERSUS)");

    // add backgrounds to the strumlines
    if (FlxG.save.data.impPixelStrumBG > 0) {
        for (strumline in strumLines.members) {
            if (!strumline.visible) continue;

            var strumBG:FlxSprite = new FlxSprite(strumline.members[0].x).makeGraphic(strumline.members[0].width * (strumline.members.length - 1) - 8, FlxG.height, FlxColor.BLACK);
            strumBG.alpha = FlxG.save.data.impPixelStrumBG;
            strumBG.camera = camHUD;
            insert(members.indexOf(strumline), strumBG);
            strumlineBackgrounds.push(strumBG);
        }
    }

    scripts.call("postUIOverhaul");
}

function createCharacters() {
    // old chars get removed
    for (i => strumline in strumLines.members) {
        for (char in strumline.characters)
            remove(char);
    }

    // then get replaced with the new ones :smiling_imp:
    for (i => strL in PlayState.SONG.strumLines) {
        if (strL == null) continue;

        var chars:Array<VSliceCharacter> = [];
        var charPos:String = strL.position == null ? (switch(strL.type) {
            case 0: "dad";
            case 1: "boyfriend";
            case 2: "girlfriend";
        }) : strL.position;

        if (strL.characters != null) {
            for (c => char in strL.characters) {
                var character:VSliceCharacter = new VSliceCharacter(0, 0, char, stage.isCharFlipped(stage.characterPoses[char] != null ? char : charPos, strL.type == 1));
                stage.applyCharStuff(character, charPos, c);
                chars.push(character);
            }
        }

        strumLines.members[i].characters = chars;
    }
}

function update(elapsed:Float) {
    if (generatedMusic)
        songPercent = (Conductor.songPosition / inst.length);

    taskbar.scale.x = songPercent * 4;
    taskbar.updateHitbox();

    updateHealthBar();

    // why do i have to do this like this
    if (fixScore) {
        PlayState.instance.songScore = Math.floor(lerp(PlayState.instance.songScore, 0, 0.25, true));
        if (PlayState.instance.songScore <= 0) {
            PlayState.instance.songScore = 0;
            fixScore = false;
        }
        updateScore();
    }
}

function updateHealthBar() {
    healthLerp = FlxMath.lerp(healthLerp, health, 0.15);
    healthBar.value = healthLerp;
}

function postUpdate(elapsed:Float) {
    if (!overrideTaskbarTxt) {
        taskbarTxt.text = PlayState.SONG.meta.displayName;
        taskbarTxt.text += " (" + Math.round(songPercent * 100) + "%)";
    }

    if (!inCutscene)
        processNotes(elapsed);

    if (FlxG.keys.justPressed.NINE)
        endSong();

    if (FlxG.keys.justPressed.EIGHT)
        transitionToResults();

    if (FlxG.keys.justPressed.ONE)
        playerStrums.cpu = !playerStrums.cpu;

    if (FlxG.keys.pressed.RIGHT && generatedMusic && !endingSong) {
        if (FlxG.sound.music != null) {
            for (strL in strumLines.members) strL.vocals.time += 800;
            inst.time += 800;
            vocals.time += 800;
        }
    }

    if (PlayState.chartingMode) {
        if (FlxG.keys.justPressed.NINE)
            endSong();
    }
}

function onCountdown(event) {
    trace(event.swagCounter, introLength);

    // girlfriend countdown animation
    if (!gf.visible || gf.alpha == 0) return;

    var correctCounter:Int = FlxMath.remapToRange(event.swagCounter, 0, introLength-1, introLength-1, 0);
    var animCounter:Int = correctCounter - 1;
    if (animCounter != 0) {
        if (gf.hasAnim("countdown" + animCounter))
            gf.playAnim("countdown" + animCounter);
    }
    else {
        if (gf.hasAnim("countdownGo"))
            gf.playAnim("countdownGo");
        else if (gf.hasAnim("cheer"))
            gf.playAnim("cheer");
    }
}

function onStartSong() {
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
    for (i => strumline in strumLines.members) {
        if (!strumline.cpu) {
            for (playerNote in strumline.notes.members) {
                if (playerNote == null || !playerNote.alive) continue;

                if (playerNote.wasGoodHit) {
                    if (playerNote.isSustainNote && playerNote.sustainLength > 0) {
                        health += holdHealthBonus * elapsed;
                        songScore += Std.int(holdScoreBonus * elapsed);
                        updateScore();
                    }
                }
            }
        }
        else {
            for (opponentNote in strumline.notes.members) {
                if (opponentNote == null || !opponentNote.alive) continue;
            }
        }

        var coverHandler:HoldCoverHandler = holdCoverHandlers[i];
        if (coverHandler == null) continue;
        for (holdCover in coverHandler.group.members) {
            if (holdCover == null || !holdCover.beingHeld) continue;

            if (Conductor.songPosition >= holdCover.endTime)
                holdCover.playEnd();
        }
    }
}

// all of these can be modified in any song
public var perfectHealth:Float = 2 / 100 * maxHealth;       // 2% gain
public var sickHealth:Float = 1.5 / 100 * maxHealth;        // 1.5% gain
public var goodHealth:Float = 0.75 / 100 * maxHealth;       // 0.75% gain
public var badHealth:Float = 0 / 100 * maxHealth;           // no gain
public var shitHealth:Float = -1 / 100 * maxHealth;         // 1% loss
public var holdHealthBonus:Float = 4 / 100 * maxHealth;     // 4% gain per second
public var ghostHealth:Float = -2 / 100 * maxHealth;        // 2% loss
public var missHealth:Float = -4 / 100 * maxHealth;         // 4% loss
public var holdHealthDrop:Float = 0.5 / 100 * maxHealth;    // 0.5% gain per sustain length remaining
public var holdHealthDropMax:Float = 0 / 100 * maxHealth;
public var holdDropThreshold:Float = 210;

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
        impostorStats.set("totalNotes", impostorStats.get("totalNotes") + 1);
        updateScore();
        recalculateAccuracy();

        if (event.countAsCombo)
            combo++;

        if (!event.animCancelled || event.noteType != "No Anim Note") {
            for (char in event.characters) {
                if (char != null)
                    char.playSingAnim(event.direction, event.animSuffix, "SING", event.forceAnim);
            }
        }

        if (event.note.__strum != null) {
            event.note.__strum.press(event.note.strumTime);
            if (showSplashes) splashHandler.showSplash(event.note.splash, event.note.__strum);
        }

        if (daRating == "bad" || daRating == "shit") {
            breakCombo();
        }

        displayRating(daRating, score2add);

        grantNoteStat(daRating);
    }

    if (event.deleteNote)
        strumline.deleteNote(event.note);

    scripts.call("onNewPlayerHit", [event]);
    scripts.call("onNewNoteHit", [event]);
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
        if (!event.animCancelled || event.noteType != "No Anim Note") {
            for (char in event.characters) {
                if (char != null)
                    char.playSingAnim(event.direction, event.animSuffix, "SING", event.forceAnim);
            }
        }

        if (event.note.__strum != null) {
            event.note.__strum.press(event.note.strumTime);
        }
    }

    if (event.deleteNote)
        strumline.deleteNote(event.note);

    scripts.call("onNewOpponentHit", [event]);
    scripts.call("onNewNoteHit", [event]);
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

    var scor:Int = 0;
    if (!event.ghostMiss) {
        if (event.note == null) return;
        if (strumline == null) return;

        if (event.note.isSustainNote) {
            var nextSustain:Note = event.note.sustainParent.nextNote;
            while(nextSustain != null) {
                strumline.deleteNote(nextSustain);
                nextSustain = nextSustain.nextSustain;
            }
            if (event.note.sustainParent.wasGoodHit) return;
        }
        else {
            strumline.deleteNote(event.note);
            health += missHealth;
            scor = missScore;
        }

        /*if (event.note.isSustainNote) {
            var sustainLength:Float = 0;
            var nextSustain:Note = event.note.sustainParent.nextNote;
            while(nextSustain != null) {
                sustainLength += nextSustain.sustainLength;
                nextSustain = nextSustain.nextSustain;
            }

            trace(event.note.strumTime, sustainLength, Conductor.songPosition);
            var posLength:Float = event.note.strumTime + sustainLength;
            var remainingLength:Float = posLength - Conductor.songPosition;
            trace(remainingLength);
            if (remainingLength > holdDropThreshold) {
                var remainingLengthSec:Float = remainingLength / 1000;
                var healthChangeUncapped:Float = remainingLengthSec * holdHealthDrop;
                var healthChangeMax:Float = holdHealthDropMax - (event.note.wasGoodHit ? missHealth : 0);
                var healthChange:Float = clamp(healthChangeUncapped, healthChangeMax, 0);
                scor = Std.int(holdHealthDrop * remainingLengthSec);
                health -= healthChange;
                trace(scor, healthChange);
            }
            else {
                logTraceColored([
                    {text: "[PlayState] ", color: getLogColor("cyan")},
                    {text: "Hold Note was too short, miss will not be penalized."}
                ]);
                return;
            }
        }*/
        notesMissed++;
        breakCombo();
    }
    else {
        health += ghostHealth;
        scor = ghostScore;
    }

    //playSound(event.missSound, event.missVolume);

    vocals.volume = 0;
    strumline.vocals.volume = 0;

    songScore += scor;
    updateScore();
    recalculateAccuracy();

    for (char in event.characters) {
        if (char != null)
            char.playSingAnim(event.direction, event.animSuffix, "MISS", event.forceAnim);
    }

    displayRating(0, scor);

    scripts.call("onNewPlayerMiss", [event]);
}

function updateScore() {
    scoreTxt.text = Std.string(songScore);
}

function recalculateAccuracy() {
    accuracy = Math.min(1, Math.max(0, (sickHits + perfectHits) / totalNotes));
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

    if (gf != null)
        gf.playComboAnim(combo);
}

public function breakCombo(ignoreCurCombo:Bool = false) {
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

        combosBroken++;
        impostorStats.set("combosBroken", impostorStats.get("combosBroken") + 1);
    }
    scripts.call("preComboBroken", [combo]);

    gf.playDropAnim(combo);
    combo = 0;

    scripts.call("onComboBroken", [combo]);
}

function getRatingDisplay(rating:String):String {
    var ratin:String = "";
    if (rating == "perfect")
        ratin = "Perfect!!!";
    else if (rating == "sick")
        ratin = "Sick!!";
    else if (rating == "good")
        ratin = "Good!";
    else if (rating == "bad")
        ratin = "Bad";
    else if (rating == "shit")
        ratin = "Shit";
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

function onNewCameraMove(position:FlxPoint, strumLine:StrumLine, focusedChars:Int) {
    for (strumline in strumLines.members) {
        for (char in strumline.characters) {
            char.scripts.call("cameraPositionChange", [position]);
        }
    }
}

function onInputUpdate(event) {
    for (i in 0...event.justReleased.length) {
        if (event.justReleased[i]) {
            for (strumline in strumLines.members) {
                if (!strumline.cpu) {
                    var strum:Strum = strumline.members[i];
                    if (strum.ID != i) continue;
                    strumline.notes.forEachAlive(function(note) {
                        if (note.noteData != strum.ID) return;
                        if (note.sustainParent == null) return;

                        if (note.sustainParent.wasGoodHit)
                            noteMiss(strumline, note);
                    });
                }
            }

            for (coverHandler in holdCoverHandlers) {
                if (coverHandler == null) continue;
                for (holdCover in coverHandler.group.members) {
                    if ((holdCover.strumID == i) && !StringTools.endsWith(holdCover.getAnimName(), "-end"))
                        holdCover.killCover();
                }
            }
        }
    }
}

function grantNoteStat(rating:String) {
    switch (rating) {
        case "perfect":
            perfectHits++;
            impostorStats.set("perfectNotes", impostorStats.get("perfectNotes") + 1);
        case "sick":
            sickHits++;
            impostorStats.set("sickNotes", impostorStats.get("sickNotes") + 1);
        case "good":
            goodHits++;
            impostorStats.set("goodNotes", impostorStats.get("goodNotes") + 1);
        case "bad":
            badHits++;
            impostorStats.set("badNotes", impostorStats.get("badNotes") + 1);
        case "shit":
            shitHits++;
            impostorStats.set("shitNotes", impostorStats.get("shitNotes") + 1);
        case "miss":
            impostorStats.set("missedNotes", impostorStats.get("missedNotes") + 1);
        default:
            // do nothing
    }
}

function onNewNoteHit(event) {
    var noteStrumLine:StrumLine = event.note.strumLine;
    var noteStrum:Strum = event.note.__strum;
    var noteID:Int = event.note.noteData;
    var note:Note = event.note;

    if (!note.isSustainNote) {
        if (note.nextNote != null && note.nextNote.isSustainNote) {
            var sustainLength:Float = 0;
            var nextSustain:Note = note.nextNote;
            while(nextSustain != null) {
                sustainLength += nextSustain.sustainLength;
                nextSustain = nextSustain.nextSustain;
            }

            holdCoverHandlers[strumLines.members.indexOf(noteStrumLine)].showHoldCover(noteStrum, !noteStrumLine.cpu, note.strumTime + sustainLength);
        }
    }
    else {
        if (noteStrum != null) noteStrum.lastHit = Conductor.songPosition + 30;

        for (i in 0...event.characters.length) event.characters[i].lastHit = Conductor.songPosition + 30;
    }
}

function onSongEnd(event) {
    event.cancel();

    endingSong = true;
	canPause = false;

    for (strumline in strumLines.members) strumline.vocals.stop();
    inst.stop();
    vocals.stop();

    if (validScore) {
        FunkinSave.setSongHighscore(PlayState.SONG.meta.name, PlayState.difficulty, PlayState.variation, {
            score: songScore,
            misses: notesMissed,
            accuracy: accuracy,
            hits: getSongHits(false),
            date: Date.now().toString()
        }, []);
    }

    checkNextSong();
}

function checkNextSong() {
    if (!endingSong) return;

    if (PlayState.isStoryMode) {
        PlayState.campaignScore += songScore;
        PlayState.campaignMisses += notesMissed;
        PlayState.campaignAccuracyTotal += accuracy;
        PlayState.campaignAccuracyCount++;

        campaignPerfectHits += perfectHits;
        campaignSickHits += sickHits;
        campaignGoodHits += goodHits;
        campaignBadHits += badHits;
        campaignShitHits += shitHits;

        PlayState.storyPlaylist.shift();

        if (PlayState.storyPlaylist.length < 1) {
            if (validScore) {
                FunkinSave.setWeekHighscore(PlayState.storyWeek.id, PlayState.difficulty, {
                    score: PlayState.campaignScore,
                    misses: PlayState.campaignMisses,
                    accuracy: PlayState.campaignAccuracy,
                    hits: getSongHits(true),
                    date: Date.now().toString()
                });
            }

            transition2results();
        }
        else {
            registerSmoothTransition();
            prepareNextSong();
        }
    }
    else {
        if (PlayState.chartingMode) {
            setTransition("closingSharpCircle");
            FlxG.switchState(new Charter(PlayState.SONG.meta.name, PlayState.difficulty, PlayState.variation, false));
        }
        else
            transition2results();
    }

    FunkinSave.flush();
    FlxG.save.flush();
}

function getSongHits(campaign:Bool):Map<String, Int> {
    var map:Map<String, Int> = [];
    map.set("perfects", campaign ? campaignPerfectHits : perfectHits);
    map.set("sicks", campaign ? campaignSickHits : sickHits);
    map.set("goods", campaign ? campaignGoodHits : goodHits);
    map.set("bads", campaign ? campaignBadHits : badHits);
    map.set("shits", campaign ? campaignShitHits : shitHits);
    map.set("combosBroken", campaign ? campaignCombosBroken : combosBroken);
    return map;
}

function prepareNextSong() {
    if (!endingSong) return;

    PlayState.__loadSong(PlayState.storyPlaylist[0], PlayState.difficulty, PlayState.variation);

    // if the stage is not the same, just reload PlayState
    if (PlayState.smoothTransitionData.stage != curStage) {
        PlayState.smoothTransitionData = null;
        setTransition("closingSharpCircle");

        FlxG.switchState(new PlayState());
    }
    else {
        // This is mostly copied from PlayState, but modified so it works properly without reloading the state to load the next song.
        scripts.call("preNextSongInitiated");

        generatedMusic = false;
        startingSong = false;
        _startCountdownCalled = false;
        startedCountdown = false;

        canDie = false;

        camZoomLerp = Flags.DEFAULT_ZOOM_LERP;
        camZooming = false;
        camZoomingInterval = Flags.DEFAULT_CAM_ZOOM_INTERVAL;
        camZoomingOffset = Flags.DEFAULT_CAM_ZOOM_OFFSET;
        camZoomingEvery = BeatType.MEASURE;
        camZoomingLastBeat = null;
        camZoomingStrength = Flags.DEFAULT_CAM_ZOOM_STRENGTH;
        camZoomingMult = Flags.DEFAULT_ZOOM;

        camGameZoomLerp = Flags.DEFAULT_CAM_ZOOM_LERP;
        camGameZoomMult = Flags.DEFAULT_CAM_ZOOM_MULT;

        defaultCamZoom = camGame.zoom;
        FlxG.camera.followLerp = camZoomLerp;

        introLength = Flags.DEFAULT_INTRO_LENGTH;
        startTimer.destroy();

        Note.__customNoteTypeExists = [];

        while(events.length > 0) events.pop();
        eventsTween.clear();

        for (script in scripts.scripts) {
            if (script.fileName == 'game.hx') {} // DONT REMOVE IMPORTANT SCRIPTS
            else if (script.fileName == (stage.stageFile+'.hx')) {}
            else scripts.remove(script);
        }

        if (FlxG.sound.music != null) FlxG.sound.music.destroy();
        inst.destroy();
        vocals.destroy();

        for (strumline in strumLines.members) {
            strumline.vocals.destroy();
            strumline.notes.clear();
            strumline.data = null;
        }

        Conductor.reset();

        resetTallies();
        health = maxHealth / 2;
        fixScore = true;

        // here starts the new song initialization

        MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = false;

        endingSong = false;

        camZooming = true;
        canPause = true;
        canDie = true;
        validScore = true;

        paused = false;

        scrollSpeed = PlayState.SONG.scrollSpeed;

        Conductor.setupSong(PlayState.SONG);

        // Checks if cutscene files exists
		var cutscenePath = Paths.script('songs/' + PlayState.SONG.meta.name + '/cutscene');
		var endCutscenePath = Paths.script('songs/' + PlayState.SONG.meta.name + '/cutscene-end');
		if (Assets.exists(cutscenePath)) cutscene = cutscenePath;
		if (Assets.exists(endCutscenePath)) endCutscene = endCutscenePath;

        // this version of loading scripts doesn't support deprecated directories (i removed them intentionally lol), their support will be over eventually
        if (!PlayState.chartingMode || Options.charterEnablePlaytestScripts) {
            var normal = 'songs/' + PlayState.SONG.meta.name + '/scripts';
            var scriptsFolders:Array<String> = [normal, normal + '/' + PlayState.difficulty + '/', 'songs/'];

            for (folder in scriptsFolders) {
                for (file in Paths.getFolderContent(folder, true, PlayState.fromMods ? 1 : -1)) {
                    if (folder != "songs/")
                        addScript(file);
                }
            }

            var songEvents:Array<String> = [];
            for (event in PlayState.SONG.events)
                CoolUtil.pushOnce(songEvents, event.name);

            for (file in Paths.getFolderContent('data/events/', true, PlayState.fromMods ? 1 : -1)) {
                var fileName:String = CoolUtil.getFilename(file);
                if (StringTools.contains(EventsData.eventsList, fileName) && StringTools.contains(songEvents, fileName))
                    addScript(file);
            }
		}

        generateNewSong(PlayState.SONG);

        for (i => chartStrumline in PlayState.SONG.strumLines) {
            var strumline:StrumLine = strumLines.members[i];

            var voices = Paths.voices(PlayState.SONG.meta.name, PlayState.difficulty, chartStrumline.vocalsSuffix);
            strumline.vocals = (chartStrumline.vocalsSuffix != "") ? FlxG.sound.load(Options.streamedVocals ? Assets.getMusic(voices) : voices) : new FlxSound();
            strumline.vocals.persist = false;
            strumline.vocals.group = FlxG.sound.defaultMusicGroup;

            //strumline.notes = new NoteGroup();
            strumline.data = chartStrumline;
        }

        if (camHUD.alpha < 1)
            FlxTween.tween(camHUD, {alpha: 1}, 1);

		for (noteType in PlayState.SONG.noteTypes) {
			var scriptPath = Paths.script('data/notes/' + noteType);
			if (Assets.exists(scriptPath) && !StringTools.contains(scripts, scriptPath)) {
				var script = Script.create(scriptPath);
				if (!(script is DummyScript)) {
					scripts.add(script);
					script.load();
				}
			}
		}

        for (str in strumLines.members)
			str.generate(str.data, null);

        startingSong = true;

        WindowUtils.suffix = " - " + PlayState.SONG.meta.displayName + (!ImpostorFlags.playingVersus ? " [" + PlayState.difficulty + "] (SOLO)" : " (VERSUS)");

        updateDiscordPresence();

        startCutscene("", cutscene, null, true);

        scripts.call("nextSongInitiated");
    }
}

function generateNewSong(?songData:Dynamic) {
    if (songData == null) songData = PlayState.SONG;

    var foundCam = false;
    var foundSigs = (CoolUtil.getDefault(songData.meta.beatsPerMeasure, 4) != 4) || (CoolUtil.getDefault(songData.meta.stepsPerBeat, 4) != 4);

    if (events == null) events = [];
    else events = [
        for (event in songData.events) {
            switch (event.name) {
                case "Camera Movement":
                    if (!foundCam && event.time < 10) {
                        foundCam = true;
                        executeEvent(event);
                    }
                case "Time Signature Change":
                    if (!foundSigs && (event.params[0] != 4 || event.params[1] != 4)) {
                        foundSigs = true;
                    }
            }
            event;
        }
    ];

    if (!foundSigs) {
        camZoomingInterval = 4;
        camZoomingEvery = BeatType.BEAT;
    }

    events.sort(function(p1, p2) {
        return FlxSort.byValues(1, p1.time, p2.time);
    });

    curSong = songData.meta.name.toLowerCase();
    curSongID = StringTools.replace(curSong, " ", "-");

    var instPath = Paths.inst(PlayState.SONG.meta.name, PlayState.difficulty, PlayState.SONG.meta.instSuffix);
    inst = FlxG.sound.load(Assets.getMusic(instPath));
    FlxG.sound.music = inst;

    var vocalsPath = Paths.voices(PlayState.SONG.meta.name, PlayState.difficulty, PlayState.SONG.meta.vocalsSuffix);
    if (PlayState.SONG.meta.needsVoices && Assets.exists(vocalsPath))
        vocals = FlxG.sound.load(Options.streamedVocals ? Assets.getMusic(vocalsPath) : vocalsPath);
    else
        vocals = new FlxSound();

    vocals.group = FlxG.sound.defaultMusicGroup;
    vocals.persist = false;

    generatedMusic = true;
}

function onEvent(event) {}

function transition2results() {
    var leftSide:CamPosData = getCharactersCamPos(strumLines.members[0].characters);
    var rightSide:CamPosData = getCharactersCamPos(strumLines.members[1].characters);

    var camGo2Pos:FlxPoint = FlxPoint.get(0, 0);
    camGo2Pos.x = FlxMath.lerp(leftSide.pos.x, rightSide.pos.x, 0.5);
    camGo2Pos.y = FlxMath.lerp(leftSide.pos.y, rightSide.pos.y, 0.5);

    // TODO: improve this transition
    FlxTween.cancelTweensOf(camFollow);
    camFollow.setPosition(camGo2Pos.x, camGo2Pos.y - 500);

    FlxTween.tween(camHUD, {alpha: 0}, 1);
    camGame.fade(FlxColor.BLACK, 1, false);
    new FlxTimer().start(1, _ -> FlxG.switchState(new ModState("resultsScreen")));
}

function resetTallies() {
    totalNotes = 0;
    notesHit = 0;
    perfectHits = 0;
    sickHits = 0;
    goodHits = 0;
    badHits = 0;
    shitHits = 0;
    notesMissed = 0;
    combosBroken = 0;
}

function clamp(value:Float, min:Float, max:Float):Float {
    return Math.max(min, Math.min(max, value));
}