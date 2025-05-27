import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import funkin.editors.charter.Charter;
import funkin.menus.StoryMenuState;
import funkin.savedata.FunkinSave;
import funkin.savedata.HighscoreChange;
import funkin.options.Options;
import Date;

public var taskbarBG:FlxSprite;
public var taskbar:FlxSprite;
public var taskbarTxt:FunkinText;

public var camMovementSpeed:Float = 1;

public var songPercent:Float = 0.0;

var healthLerp:Float = 0;

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
}

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
            cover.scale.set(strum.scale.x, strum.scale.y);
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

    createHoldCovers();
}

function update(elapsed:Float) {
    songPercent = (Conductor.songPosition / inst.length);

    updateHealthBar();
}

function updateHealthBar() {
    healthLerp = FlxMath.lerp(healthLerp, health, 0.15);
    healthBar.value = healthLerp;
}

function postUpdate(elapsed:Float) {
    taskbar.scale.x = songPercent * 4;
    taskbar.updateHitbox();
    taskbarTxt.text = SONG.meta.displayName + " (" + Math.round(songPercent * 100) + "%)";
    scoreTxt.text = songScore;

    FlxG.camera.followLerp = 0.04 * camMovementSpeed;

    if (FlxG.keys.justPressed.EIGHT) transitionToResults();
}

function onStartSong() {
    inst.onComplete = impostorEndSong;

    FlxTween.tween(taskbarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    FlxTween.tween(taskbar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    FlxTween.tween(taskbarTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
}

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

function impostorEndSong() {
    scripts.call("onSongEnd");
    inst.volume = 0;
    vocals.volume = 0;
    for (strumLine in strumLines.members) {
		strumLine.vocals.volume = 0;
		strumLine.vocals.pause();
	}
	inst.pause();
	vocals.pause();

    if (validScore) {
        FunkinSave.setSongHighscore(PlayState.SONG.meta.name, PlayState.difficulty, {
            score: PlayState.songScore,
            misses: PlayState.misses,
            accuracy: PlayState.accuracy,
            hits: [],
            date: Date.now().toString()
        }, getSongChanges());
    }

    startCutscene("end-", endCutscene, go2nextSong);
    PlayState.resetSongInfos();
}

function go2nextSong() {
    if (PlayState.isStoryMode) {
        PlayState.campaignScore += PlayState.songScore;
        PlayState.campaignMisses += PlayState.misses;
        PlayState.campaignAccuracyTotal += PlayState.accuracy;
        PlayState.campaignAccuracyCount++;
        PlayState.storyPlaylist.shift();

        if (storyPlaylist.length <= 0) {
            transitionToResults();

            if (validScore) {
                FunkinSave.setWeekHighscore(PlayState.storyWeek.id, PlayState.difficulty, {
                    score: PlayState.campaignScore,
                    misses: PlayState.campaignMisses,
                    accuracy: PlayState.campaignAccuracy,
                    //rank: getStoryRank(campaignAccuracy),
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

function getSongChanges():Array<HighscoreChange> {
    var a = [];
    if (PlayState.opponentMode)
        a.push(HighscoreChange.COpponentMode);
    if (PlayState.coopMode)
        a.push(HighscoreChange.CCoopMode);
    return a;
}

function getStoryRank(accuracy:Float):String {
    if (accuracy >= 1)
        return "S++";
    else if (accuracy >= 0.95)
        return "S";
    else if (accuracy >= 0.9)
        return "A";
    else if (accuracy >= 0.85)
        return "B";
    else if (accuracy >= 0.8)
        return "C";
    else if (accuracy >= 0.7)
        return "D";
    else if (accuracy >= 0.5)
        return "E";
    else
        return "F";
}

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