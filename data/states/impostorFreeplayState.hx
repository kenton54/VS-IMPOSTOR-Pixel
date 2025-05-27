import StringTools;
import flixel.addons.display.FlxStarField2D;
import flixel.addons.display.shapes.FlxShape;
import flixel.group.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.util.FlxGradient;
import funkin.backend.chart.Chart;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.savedata.FunkinSave;

var loadedPlayable:String = "bf";

static var curPage:Int = 0;
static var curSong:Int = 0;
static var curDiff:Int = 1;

var pageArray:Array<Array<Dynamic>>;
var songs:Array<Dynamic>;

var panels:Array<FlxTypedSpriteGroup> = [];

var spaceCam:FlxCamera;
var leftSideCam:FlxCamera;
var songsCam:FlxCamera;
var bordersCam:FlxCamera;

var charBG:FlxSprite;

var difficultySpr:FlxSprite;
var diffLeftArrow:FlxSprite;
var diffRightArrow:FlxSprite;

var glow:FlxSprite;
var interpolateColor:FlxInterpolateColor;

function create() {
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
    add(linething);

    var boxes:FlxSprite = new FlxSprite(5, 465).loadGraphic(Paths.image("menus/freeplay/boxes"));
    boxes.scale.set(9, 9);
    boxes.updateHitbox();
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
    diffLeftArrow.setPosition(FlxG.width * 0.32, bottomBorder.y + (diffLeftArrow.height / 8));
    diffLeftArrow.camera = bordersCam;
    add(diffLeftArrow);

    diffRightArrow = new FlxSprite().loadGraphicFromSprite(diffLeftArrow);
    diffRightArrow.animation.copyFrom(diffLeftArrow.animation);
    diffRightArrow.animation.play("idle");
    diffRightArrow.animation.finishCallback = _ -> {diffRightArrow.animation.play("idle");};
    diffRightArrow.scale.set(3.2, 3.2);
    diffRightArrow.updateHitbox();
    diffRightArrow.setPosition(FlxG.width * 0.65, bottomBorder.y + (diffRightArrow.height / 8));
    diffRightArrow.flipX = true;
    diffRightArrow.camera = bordersCam;
    add(diffRightArrow);

    regeneratePage();
    changeDifficulty(0);

    interpolateColor = new FlxInterpolateColor(glow.color);
}

function update(elapsed:Float) {
    handleInput();
    handleSongSelection();

    if (songs != null && songs.length > 0 && songs[curSong] != null)
        interpolateColor.fpsLerpTo(songs[curSong].parsedColor, 0.0625);
    else
        interpolateColor.fpsLerpTo(FlxColor.WHITE, 0.0625);
    glow.color = interpolateColor.color;
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
}

function handleSongSelection() {
    var panelHeight:Float = 140;
    for (i => panel in panels) {
        var yPanel:Float = ((FlxG.height - panelHeight) / 2) + ((i - curSong) * panelHeight) + 12;

        panel.y = CoolUtil.fpsLerp(panel.y, yPanel, 0.2);
        panel.x = 280 + (Math.abs(Math.cos((panel.y + (panelHeight / 2) - (FlxG.camera.scroll.y + (FlxG.height / 2))) / (FlxG.height * 1.25) * Math.PI)) * 150);
    }
}

var lastSong:Int = 0;
function changeSong(change:Int) {
    curSong = FlxMath.wrap(curSong + change, 0, panels.length - 1);

    changeDifficulty(0);

    if (curSong != lastSong) {
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);
        lastSong = curSong;
    }
}

function changeDifficulty(change:Int) {
    var difficultiesFromSong:Array<String> = songs[curSong].difficulties;

    var changeAmount:Int = (difficultiesFromSong != null && difficultiesFromSong.length > 0) ? difficultiesFromSong.length - 1 : 1;
    curDiff = FlxMath.wrap(curDiff + change, 0, changeAmount);

    if (difficultiesFromSong != null && difficultiesFromSong[curDiff] != null) {
        difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/" + difficultiesFromSong[curDiff]));
    }
    else {
        difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/none"));
    }
    difficultySpr.updateHitbox();
    difficultySpr.screenCenter(FlxAxes.X);

    if (change != 0) {
        regeneratePage();
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);
    }
}

function regeneratePage() {
    for (panel in panels) {
        panel.clear();
    }
    panels = [];

    for (i in 0...songs.length) {
        panels[i] = new FlxTypedSpriteGroup();
        panels[i] = createPanel(songs[i]);
        add(panels[i]);
    }
}

function createPanel(songData:Array<Dynamic>) {
    var scale:Float = 3;

    var icon:Array<String> = songData.icon.split("-");

    var group:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

    var panel:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/freeplay/panels/" + loadedPlayable));
    panel.antialiasing = false;
    panel.scale.set(scale, scale);
    panel.updateHitbox();
    group.add(panel);

    var songName:FunkinText = new FunkinText(panel.x + (42 * scale) + .5, panel.y + (13 * scale) + .5, 0, songData.displayName, 23.5, false);
    songName.font = Paths.font("gameboy.ttf");
    songName.letterSpacing = -2;
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

    var iconExists:Bool = Assets.exists(Paths.image("menus/freeplay/icons/" + icon[0]));
    iconExists = true;
    var attachedIcon:FlxSprite = new FlxSprite(panel.x - (3 * scale), panel.y - (7 * scale));
    attachedIcon.antialiasing = false;
    if (iconExists) {
        attachedIcon.frames = Paths.getFrames("menus/freeplay/icons/bf");
        attachedIcon.animation.addByPrefix("idle", "idle0", 10, true);
        attachedIcon.animation.addByPrefix("select", "confirm0", 10, false);
        attachedIcon.animation.addByPrefix("select-hold", "confirm-hold0", 10, true);
    }
    else
        attachedIcon.visible = false;

    attachedIcon.scale = panel.scale;
    attachedIcon.updateHitbox();
    group.add(attachedIcon);
    
    return group;
}

function getSongList():Array<Dynamic> {
    var array:Array<Dynamic> = [];

    if (pageArray.pages[curPage].songs.length > 0) {
        for (song in pageArray.pages[curPage].songs) {
            array.push(Chart.loadChartMeta(song, "normal", false));
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

    sticker = "p";
    return sticker;
}