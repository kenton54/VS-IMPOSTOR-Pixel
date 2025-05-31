import StringTools;
import flixel.addons.display.FlxStarField2D;
import flixel.group.FlxTypedSpriteGroup;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import funkin.backend.chart.Chart;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.savedata.FunkinSave;
import PlayableData;

//var loadedPlayableId:String = "bf";
var loadedPlayable:PlayableData;

static var curPlayable:String = "bf";
static var curPage:Int = 0;
static var curSong:Int = 0;
static var curDiff:Int = 1;

/*static*/ var newPlayableWaiting:Bool = false;

static var curInstPlaying:String = "";

var fade2Volume:Float = 0.7;

var pageArray:Array<Array<Dynamic>>;
var songs:Array<Dynamic>;

var panels:Array<FlxTypedSpriteGroup> = [];

var spaceCam:FlxCamera;
var leftSideCam:FlxCamera;
var songsCam:FlxCamera;
var bordersCam:FlxCamera;

var charBG:FlxSprite;
var boxes:FlxSprite;
var computer:FlxSprite;

var playableChar:FunkinSprite;

var difficultySpr:FlxSprite;
var diffLeftArrow:FlxSprite;
var diffRightArrow:FlxSprite;
var chartDiffBar:FlxBar;
var mechDiffBar:FlxBar;

var chartDiffValue:Int = 0;
var chartDiffLerp:Float = 0;

var glow:FlxSprite;
var interpolateColor:FlxInterpolateColor;

function create() {
    loadedPlayable = new PlayableData(curPlayable);
    //loadedPlayableId = loadedPlayable.id;

    pageArray = Json.parse(Assets.getText(Paths.json("playlist")));

    songs = getSongList();

    spaceCam = new FlxCamera();
    spaceCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(spaceCam, false);

    leftSideCam = new FlxCamera();
    leftSideCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(leftSideCam, false);

    songsCam = new FlxCamera();
    songsCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(songsCam, true);

    bordersCam = new FlxCamera();
    bordersCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(bordersCam, false);

    var stars:FlxStarField2D = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 120);
    stars.setStarSpeed(5, 50);
    stars.camera = spaceCam;
    add(stars);

    glow = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/glow"));
    glow.scale.set(3, 3);
    glow.updateHitbox();
    glow.setPosition(FlxG.width - (glow.width / 2), FlxG.height - (glow.height / 1.75));
    glow.alpha = 0.4;
    glow.camera = spaceCam;
    add(glow);

    charBG = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/freeplay/leftside"));
    charBG.scale.set(6, 6);
    charBG.updateHitbox();
    charBG.camera = leftSideCam;
    add(charBG);

    var linething:FlxSprite = new FlxSprite((charBG.x + charBG.width) - 32, charBG.y - 10).makeGraphic(12, FlxG.height * 1.5, FlxColor.WHITE);
    linething.angle = -9.45;
    linething.camera = leftSideCam;
    add(linething);

    boxes = new FlxSprite(5, 465).loadGraphic(Paths.image("menus/freeplay/boxes"));
    boxes.scale.set(9, 9);
    boxes.updateHitbox();
    boxes.camera = leftSideCam;

    playableChar = new FunkinSprite();
    playableChar.scale.set(9, 9);
    playableChar.updateHitbox();
    playableChar.camera = leftSideCam;

    computer = new FlxSprite();
    computer.frames = Paths.getFrames("menus/freeplay/computer");
    computer.animation.addByPrefix("off", "off", 1, false);
    computer.animation.addByPrefix("turnOn", "turnOn", 24, false);
    computer.animation.addByPrefix("beatLeft", "beatLeft", 10, false);
    computer.animation.addByPrefix("beatRight", "beatRight", 10, false);
    computer.animation.addByPrefix("newChar", "newChar", 2, true);
    computer.animation.addByPrefix("danger", "danger", 2, true);
    computer.animation.play("off");
    computer.scale.set(9, 9);
    computer.updateHitbox();
    computer.setPosition((boxes.x + boxes.width) - computer.width - 27, boxes.y - computer.height);
    computer.camera = leftSideCam;

    add(computer);
    add(playableChar);
    add(boxes);

    var topBorder:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height * 0.115, FlxColor.BLACK);
    topBorder.camera = bordersCam;
    add(topBorder);

    var bottomBorder:FlxSprite = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, FlxG.height * 0.115, FlxColor.BLACK);
    bottomBorder.y -= bottomBorder.height;
    bottomBorder.camera = bordersCam;
    add(bottomBorder);

    difficultySpr = new FlxSprite();
    difficultySpr.scale.set(3.2, 3.2);
    difficultySpr.updateHitbox();
    difficultySpr.y = bottomBorder.y + 14;
    difficultySpr.camera = bordersCam;
    add(difficultySpr);

    diffLeftArrow = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/arrows"), true, 12, 20);
    diffLeftArrow.animation.add("idle", [0], 10, true);
    diffLeftArrow.animation.add("click", [1], 10, false);
    diffLeftArrow.animation.play("idle");
    diffLeftArrow.animation.finishCallback = _ -> {diffLeftArrow.animation.play("idle");};
    diffLeftArrow.scale.set(3.2, 3.2);
    diffLeftArrow.updateHitbox();
    diffLeftArrow.setPosition(FlxG.width * 0.33, bottomBorder.y + (diffLeftArrow.height / 8));
    diffLeftArrow.camera = bordersCam;
    add(diffLeftArrow);

    diffRightArrow = new FlxSprite().loadGraphicFromSprite(diffLeftArrow);
    diffRightArrow.animation.copyFrom(diffLeftArrow.animation);
    diffRightArrow.animation.play("idle");
    diffRightArrow.animation.finishCallback = _ -> {diffRightArrow.animation.play("idle");};
    diffRightArrow.scale.set(3.2, 3.2);
    diffRightArrow.updateHitbox();
    diffRightArrow.setPosition(FlxG.width * 0.64, bottomBorder.y + (diffRightArrow.height / 8));
    diffRightArrow.flipX = true;
    diffRightArrow.camera = bordersCam;
    add(diffRightArrow);

    var chartDiff:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/chartDiff"));
    chartDiff.scale.set(3.2, 3.2);
    chartDiff.updateHitbox();
    chartDiff.setPosition((diffRightArrow.x + diffRightArrow.width) + chartDiff.frameWidth, bottomBorder.y + (chartDiff.height / 8));
    chartDiff.camera = bordersCam;
    add(chartDiff);

    var mechanicsDiff:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/mechDiff"));
    mechanicsDiff.scale.set(3.2, 3.2);
    mechanicsDiff.updateHitbox();
    mechanicsDiff.setPosition(diffLeftArrow.x - mechanicsDiff.width - 20, bottomBorder.y + (mechanicsDiff.frameHeight / 10));
    mechanicsDiff.camera = bordersCam;
    add(mechanicsDiff);

    var dedCrew1:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/dedCrewDiff"));
    dedCrew1.scale.set(3.2, 3.2);
    dedCrew1.updateHitbox();
    dedCrew1.setPosition(FlxG.width - dedCrew1.width - 16, bottomBorder.y + (dedCrew1.height / 8) + 5);
    dedCrew1.camera = bordersCam;
    add(dedCrew1);

    var dedCrew2:FlxSprite = new FlxSprite().loadGraphicFromSprite(dedCrew1);
    dedCrew2.scale.set(3.2, 3.2);
    dedCrew2.updateHitbox();
    dedCrew2.flipX = true;
    dedCrew2.setPosition(16, bottomBorder.y + (dedCrew2.height / 8) + 5);
    dedCrew2.camera = bordersCam;
    add(dedCrew2);

    var diffBarOutline1:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/barDiff"));
    diffBarOutline1.scale.set(3.2, 3.2);
    diffBarOutline1.updateHitbox();
    diffBarOutline1.setPosition(chartDiff.x + chartDiff.width + 16, chartDiff.y + (diffBarOutline1.height / 2) + 15);
    diffBarOutline1.camera = bordersCam;

    var diffBarOutline2:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/barDiff"));
    diffBarOutline2.scale.set(3.2, 3.2);
    diffBarOutline2.updateHitbox();
    diffBarOutline2.setPosition(dedCrew2.x + dedCrew2.width + 16, diffBarOutline1.y);
    diffBarOutline2.camera = bordersCam;

    chartDiffBar = new FlxBar(diffBarOutline1.x + (3 * 3.2), diffBarOutline1.y + (2 * 3.2), FlxBarFillDirection.LEFT_TO_RIGHT, 160, 16);
    chartDiffBar.createGradientEmptyBar([FlxColor.BLACK], 1);
    chartDiffBar.createGradientFilledBar([FlxColor.RED, FlxColor.LIME], 1);
    chartDiffBar.setRange(0, 20);
    chartDiffBar.camera = bordersCam;

    add(chartDiffBar);
    add(diffBarOutline1);
    add(diffBarOutline2);

    var chartTxt:FunkinText = new FunkinText(0, 0, 0, "Chart", 24, false);
    chartTxt.font = Paths.font("gameboy.ttf");
    chartTxt.setPosition(chartDiff.x + chartDiff.width + 45, bottomBorder.y + 2);
    chartTxt.camera = bordersCam;
    add(chartTxt);

    var mechanicsTxt:FunkinText = new FunkinText(0, 0, 0, "Mechanics", 24, false);
    mechanicsTxt.font = Paths.font("gameboy.ttf");
    mechanicsTxt.setPosition(dedCrew2.x + dedCrew2.width, bottomBorder.y + 2);
    mechanicsTxt.camera = bordersCam;
    add(mechanicsTxt);

    regeneratePage();
    changeDifficulty(0);

    interpolateColor = new FlxInterpolateColor(glow.color);
}

function postCreate() {
    if (newPlayableWaiting) {
        fade2Volume = 0.4;
    }

    new FlxTimer().start(0.5, _ -> {computer.animation.play("turnOn", true);});
    new FlxTimer().start(1.25, _ -> {
        doComptIdle = true;

        if (newPlayableWaiting) {
            var comptGlow:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/computerGlow"));
            comptGlow.scale.set(1.5, 1.5);
            comptGlow.updateHitbox();
            comptGlow.alpha = 0;
            comptGlow.camera = leftSideCam;
            comptGlow.color = 0xFFFFD433;
            comptGlow.setPosition(computer.x - (comptGlow.getMidpoint().x / 2) - 27, computer.y - (comptGlow.getMidpoint().y / 2) - 27);
            comptGlow.blend = 0;
            insert(members.indexOf(computer), comptGlow);

            FlxTween.color(charBG, 0.1, 0xFFFFFFFF, 0xFF555555);
            FlxTween.color(boxes, 0.1, 0xFFFFFFFF, 0xFF999999);
            //FlxTween.color(computer, 0.1, 0xFFFFFFFF, 0xFF999999);
            FlxTween.tween(comptGlow, {alpha: 1}, 1, {ease: FlxEase.sineInOut,type: FlxTweenType.PINGPONG});
            computer.animation.play("newChar");
        }

        playCurSongInst();
    });

    // corrects position if ur hovering over a null panel
    if (panels[curSong].members.length < 1) changeSong(1);
}

function update(elapsed:Float) {
    handleInput();
    handleSongSelection();

    if (songs != null && songs.length > 0 && songs[curSong] != null)
        interpolateColor.fpsLerpTo(songs[curSong].parsedColor, 0.0625);
    else
        interpolateColor.fpsLerpTo(FlxColor.WHITE, 0.0625);
    glow.color = interpolateColor.color;

    chartDiffLerp = FlxMath.lerp(chartDiffValue, chartDiffLerp, 0.015);
    //trace(chartDiffLerp);
    chartDiffBar.value = chartDiffLerp;
}

var allowInput:Bool = true;
function handleInput() {
    if (!allowInput) return;

    if (controls.UP_P || FlxG.mouse.wheel > 0)
        changeSong(-1);
    if (controls.DOWN_P || FlxG.mouse.wheel < 0)
        changeSong(1);

    if (controls.LEFT_P) {
        diffLeftArrow.animation.play("click");
        changeDifficulty(-1);
    }
    if (controls.RIGHT_P) {
        diffRightArrow.animation.play("click");
        changeDifficulty(1);
    }

    if (controls.BACK)
        FlxG.switchState(new MainMenuState());

    if (FlxG.keys.justPressed.HOME)
        changeSong(-curSong);
    if (FlxG.keys.justPressed.END) {
        var amount2jump:Int = 0;
        for (panel in panels) {
            if (panel.members.length > 0) amount2jump += 1;
        }
        changeSong(amount2jump - curSong - 1);
    }

    if (FlxG.keys.justPressed.TAB) {
        if (curPlayable == "bf") curPlayable = "pico";
        else curPlayable = "bf";

        FlxG.resetState();
    }
}

function handleSongSelection() {
    var panelHeight:Float = 140;

    for (i => panel in panels) {
        if (panel == null) return;

        var yPanel:Float = ((FlxG.height - panelHeight) / 2) + ((i - curSong) * panelHeight) + 12;

        var xEquationLol:Float = 305 + (Math.abs(Math.cos((panel.y + (panelHeight / 2) - (FlxG.camera.scroll.y + (FlxG.height / 2))) / (FlxG.height * 1.25) * Math.PI)) * 150);

        panel.y = CoolUtil.fpsLerp(panel.y, yPanel, 0.2);
        panel.x = CoolUtil.fpsLerp(panel.x, xEquationLol, 0.3);
    }
}

static var lastSong:Int = 0;
function changeSong(change:Int) {
    if (panels != null && panels.length < 1) return;

    curSong = FlxMath.wrap(curSong + change, 0, panels.length - 1);

    if (panels[curSong].members.length < 1) changeSong(change / Math.abs(change));

    changeDifficulty(0);
    updateDiffBars();

    if (curSong != lastSong) {
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);
        lastSong = curSong;
        playCurSongInst();
    }
}

function changeDifficulty(change:Int) {
    var difficultiesFromSong:Array<String> = songs[curSong].difficulties;

    var changeAmount:Int = (difficultiesFromSong != null && difficultiesFromSong.length > 0) ? difficultiesFromSong.length - 1 : 1;
    curDiff = FlxMath.wrap(curDiff + change, 0, changeAmount);

    if (difficultiesFromSong != null && difficultiesFromSong[curDiff] != null) {
        if (Assets.exists(Paths.image("menus/freeplay/difficulties/" + difficultiesFromSong[curDiff])))
            difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/" + difficultiesFromSong[curDiff]));
        else
            difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/unknown"));
    }
    else {
        difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/none"));
    }
    difficultySpr.updateHitbox();
    difficultySpr.screenCenter(FlxAxes.X);

    if (change > 0)
        spawnXpos = -100;
    else if (change < 0)
        spawnXpos = FlxG.width;

    if (change != 0) {
        regeneratePage();
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);
    }
}

function updateDiffBars() {
    var chartRatings:Array<Dynamic>;
    var chosenRating;
    if (songs[curSong].customValues != null && songs[curSong].customValues.ratingsChart != null && songs[curSong].customValues.ratingsChart.length > 0) {
        chartRatings = songs[curSong].customValues.ratingsChart;
        chosenRating = switch(songs[curSong].difficulties[curDiff]) {
            case "easy": chartRatings.easy ?? 0;
            case "normal": chartRatings.normal ?? 0;
            case "hard": chartRatings.hard ?? 0;
            default: 0;
        }
    }
    else
        chosenRating = 0;

    chartDiffValue = chosenRating;
}

function playCurSongInst() {
    var player:Void -> Void = function() {
        if (curInstPlaying != songs[curSong].name) {
            //var inst:String = loadedPlayable.getCharInst(songs[curSong].difficulties[curDiff]);
            var song:String = Paths.inst(songs[curSong].name, songs[curSong].difficulties[curDiff]);
            FlxG.sound.playMusic(song, 0);
            FlxG.sound.music.fadeIn(1, 0, fade2Volume);
            Conductor.changeBPM(songs[curSong].bpm, songs[curSong].beatsPerMeasure, songs[curSong].stepsPerBeat);

            curInstPlaying = songs[curSong].name;
        }
        else
            FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume, fade2Volume);
    }
    Main.execAsync(player);
}

var doComptIdle:Bool = false;
var comptDance:Bool = false;
function beatHit(curBeat:Int) {
    if (!newPlayableWaiting) {
        if (doComptIdle && computer != null) {
            if (comptDance)
                computer.animation.play("beatRight");
            else
                computer.animation.play("beatLeft");
            
            comptDance = !comptDance;
        }
    }
}

function regeneratePage() {
    for (panel in panels) {
        remove(panel);
        //panel.clear();
    }

    panels = [];

    for (i in 0...songs.length) {
        panels[i] = new FlxTypedSpriteGroup();
        if (songs[i].difficulties.contains(songs[i].difficulties[curDiff])) {
            panels[i] = createPanel(songs[i]);
        }
        add(panels[i]);
    }
    //trace(panels);
}

var spawnXpos:Float = 0;
function createPanel(songData:Array<Dynamic>) {
    var scale:Float = 3;

    var icon:Array<String> = songData.icon.split("-");

    var group:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

    var panel:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/freeplay/panels/" + loadedPlayable.freeplayStyle));
    panel.antialiasing = false;
    panel.scale.set(scale, scale);
    panel.updateHitbox();
    group.add(panel);

    var songName:FunkinText = new FunkinText(panel.x + (42 * scale) + .5, panel.y + (13 * scale) + .5, 0, songData.displayName, 25, false);
    songName.font = Paths.font("pixeloidsans-bold.ttf");
    songName.letterSpacing = 1;
    group.add(songName);

    var stickerSprite:Null<String> = getRankSticker(songData);
    var rankSticker:FlxSprite = new FlxSprite((panel.x + panel.width) - (4 * scale), panel.y + (6 * scale));
    rankSticker.scale.set(scale, scale);
    if (stickerSprite != null) {
        rankSticker.loadGraphic(Paths.image("menus/freeplay/ranks/" + stickerSprite));
    }
    else
        rankSticker.visible = false;
    group.add(rankSticker);

    var iconExists:Bool = /*Assets.exists(Paths.image("menus/freeplay/icons/" + icon[0]))*/ true;
    var attachedIcon:FlxSprite = new FlxSprite();
    attachedIcon.antialiasing = false;
    if (iconExists) {
        attachedIcon.frames = Paths.getFrames("menus/freeplay/icons/" + loadedPlayable.id);
        attachedIcon.animation.addByPrefix("idle", "idle0", 10, true);
        attachedIcon.animation.addByPrefix("select", "confirm0", 10, false);
        attachedIcon.animation.addByPrefix("select-hold", "confirm-hold0", 10, true);
    }
    else
        attachedIcon.visible = false;

    attachedIcon.scale = panel.scale;
    attachedIcon.updateHitbox();
    attachedIcon.setPosition(panel.x + (attachedIcon.frameWidth / (4 * scale)), panel.y + (attachedIcon.frameHeight / (4 * scale)));
    group.add(attachedIcon);

    group.y = FlxG.height / 2.38;
    group.x = spawnXpos;
    
    return group;
}

function getSongList():Array<Dynamic> {
    var array:Array<Dynamic> = [];

    if (pageArray.pages[curPage].songs.length > 0) {
        for (song in pageArray.pages[curPage].songs) {
            array.push(Chart.loadChartMeta(loadedPlayable.getSongName(song), "normal", false));
        }
    }
    return array;
}

function getRankSticker(songData:Array<Dynamic>):String {
    var data:Float = FunkinSave.getSongHighscore(songData.name);
    var sticker:Null<String> = "";

    if (data.date != null) {
        if (data.accuracy >= 1)
            sticker = "p";
        else if (data.accuracy >= 0.95)
            sticker = "s";
        else if (data.accuracy >= 0.9)
            sticker = "a";
        else if (data.accuracy >= 0.85)
            sticker = "b";
        else if (data.accuracy >= 0.8)
            sticker = "c";
        else if (data.accuracy >= 0.7)
            sticker = "d";
        else if (data.accuracy >= 0.5)
            sticker = "e";
        else
            sticker = "f";
    }
    else
        sticker = null;

    return sticker;
}