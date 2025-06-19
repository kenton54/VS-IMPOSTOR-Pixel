import StringTools;
import flixel.effects.FlxFlicker;
import flixel.group.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import funkin.backend.chart.Chart;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.savedata.FunkinSave;
import PlayableData;
import PixelStars;

var loadedPlayable:PlayableData;

static var curPlayable:String = "bf";
static var curPageP1:Int = 0;
static var curPageP2:Int = 0;
static var curSongP1:Int = 0;
static var curSongP2:Int = 0;
static var curDiffP1:Int = 1;
static var curDiffP2:Int = 1;

/*static*/ var newPlayableWaiting:Bool = false;

static var curInstPlaying:String = "";

var fade2Volume:Float = 0.7;

var pageArray:Array<Array<Dynamic>>;
static var songList1:Array<Dynamic>;
static var songList2:Array<Dynamic>;

var panels1:Array<FlxTypedSpriteGroup> = [];
var panels2:Array<FlxTypedSpriteGroup> = [];

var spaceCam:FlxCamera;
var charactersCam:FlxCamera;
var songsCam:FlxCamera;
var songDataCam:FlxCamera;
var bordersCam:FlxCamera;

var charP1Side:FlxTypedSpriteGroup;
var charP2Side:FlxTypedSpriteGroup;

var charBG:FlxSprite;
var boxes:FlxSprite;
var computerP1:FlxSprite;
var computerP2:FlxSprite;

var playableCharP1:FunkinSprite;
var playableCharP2:FunkinSprite;

var difficultySpr:FlxSprite;
var diffLeftArrow:FlxSprite;
var diffRightArrow:FlxSprite;

var player1DiffIcon:FlxSprite;
var player1DiffTxt:FunkinText;
var chartDiffBar:FlxBar;
var mechDiffBar:FlxBar;

var pressAcceptTxt2P:FunkinText;

var chartDiffValue:Int = 0;
var chartDiffLerp:Float = 0;

var mechDiffValue:Int = 0;
var mechDiffLerp:Float = 0;

var glow:FlxSprite;
var interpolateColor:FlxInterpolateColor;

var bottomBorder:FlxSprite;

var allowGlobalInput:Bool = false;
var isVersusActive:Bool = false;

var scorTxtTxt:FunkinText;
var scoreTxt:FunkinText;
var accuracyTxt:FunkinText;
var intendedScore:Int = 0;
var intendedAccuracy:Float = 0;
var lerpScore:Int = 0;
var lerpAccuracy:Float = 0;

function create() {
    loadedPlayable = new PlayableData(curPlayable);

    pageArray = Json.parse(Assets.getText(Paths.json("playlist")));

    spaceCam = new FlxCamera();
    spaceCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(spaceCam, false);

    charactersCam = new FlxCamera();
    charactersCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(charactersCam, false);

    songsCam = new FlxCamera();
    songsCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(songsCam, true);

    songDataCam = new FlxCamera();
    songDataCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(songDataCam, false);

    bordersCam = new FlxCamera();
    bordersCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(bordersCam, false);

    var stars:PixelStars = new PixelStars(0, 0, -30, 4, 2);
    stars.setCamera(spaceCam);
    stars.addStars();

    glow = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/glow"));
    glow.scale.set(3, 3);
    glow.updateHitbox();
    glow.setPosition(FlxG.width - (glow.width / 2), FlxG.height - (glow.height / 1.75));
    glow.alpha = 0.4;
    glow.camera = spaceCam;
    add(glow);
    
    charP1Side = new FlxTypedSpriteGroup();
    charP1Side.camera = charactersCam;
    add(charP1Side);

    charP2Side = new FlxTypedSpriteGroup();
    charP2Side.x = FlxG.width;
    charP2Side.camera = charactersCam;
    add(charP2Side);

    charBG = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/freeplay/leftside"));
    charBG.scale.set(6, 6);
    charBG.updateHitbox();
    charP1Side.add(charBG);

    var player2BG:FlxSprite = new FlxSprite().loadGraphicFromSprite(charBG);
    player2BG.scale.set(6, 6);
    player2BG.updateHitbox();
    player2BG.flipX = true;
    charP2Side.add(player2BG);

    var linething1:FlxSprite = new FlxSprite(charBG.width - 32, -10).makeGraphic(12, FlxG.height * 1.5, FlxColor.WHITE);
    linething1.angle = -9.45;
    charP1Side.add(linething1);

    var linething2:FlxSprite = new FlxSprite(22, -10).makeGraphic(12, FlxG.height * 1.5, FlxColor.WHITE);
    linething2.angle = 9.45;
    charP2Side.add(linething2);

    boxes = new FlxSprite(5, 465).loadGraphic(Paths.image("menus/freeplay/boxes"));
    boxes.scale.set(9, 9);
    boxes.updateHitbox();

    var otherBoxes:FlxSprite = new FlxSprite(-2, 465).loadGraphicFromSprite(boxes);
    otherBoxes.scale.set(9, 9);
    otherBoxes.updateHitbox();
    otherBoxes.flipX = true;

    playableCharP1 = new FunkinSprite();
    playableCharP1.scale.set(9, 9);
    playableCharP1.updateHitbox();

    playableCharP2 = new FunkinSprite();
    playableCharP2.scale.set(9, 9);
    playableCharP2.updateHitbox();

    computerP1 = new FlxSprite();
    computerP1.frames = Paths.getFrames("menus/freeplay/computer");
    computerP1.animation.addByPrefix("off", "off", 1, false);
    computerP1.animation.addByPrefix("turnOn", "turnOn", 30, false);
    computerP1.animation.addByPrefix("beatLeft", "beatLeft", 10, false);
    computerP1.animation.addByPrefix("beatRight", "beatRight", 10, false);
    computerP1.animation.addByPrefix("newChar", "newChar", 4, true);
    computerP1.animation.addByPrefix("danger", "danger", 4, true);
    computerP1.animation.addByPrefix("versus", "versus", 4, true);
    computerP1.animation.addByPrefix("wave", "wave", 4, true);
    computerP1.animation.play("off");
    computerP1.scale.set(9, 9);
    computerP1.updateHitbox();
    computerP1.setPosition((boxes.x + boxes.width) - computerP1.width - 27, boxes.y - computerP1.height);

    computerP2 = new FlxSprite();
    computerP2.frames = Paths.getFrames("menus/freeplay/computer");
    computerP2.animation.copyFrom(computerP1.animation);
    computerP2.animation.addByPrefix("versus-flipped", "vsFlipped", 4, true);
    computerP2.animation.play("off");
    computerP2.scale.set(9, 9);
    computerP2.updateHitbox();
    computerP2.setPosition(-2 + 27, otherBoxes.y - computerP2.height);
    computerP2.flipX = true;

    charP1Side.add(computerP1);
    charP1Side.add(playableCharP1);
    charP1Side.add(boxes);

    charP2Side.add(computerP2);
    charP2Side.add(playableCharP2);
    charP2Side.add(otherBoxes);

    pressAcceptTxt2P = new FunkinText(820, 500, 500, 'PLAYER 2\nPRESS START', 56, true);
    pressAcceptTxt2P.alignment = "center";
    pressAcceptTxt2P.borderSize = 4;
    pressAcceptTxt2P.camera = bordersCam;
    pressAcceptTxt2P.visible = false;
    add(pressAcceptTxt2P);

    var topBorder:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height * 0.115, FlxColor.BLACK);
    topBorder.camera = bordersCam;
    add(topBorder);

    bottomBorder = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, FlxG.height * 0.115, FlxColor.BLACK);
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

    player1DiffIcon = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/mechDiff"));
    player1DiffIcon.scale.set(3.2, 3.2);
    player1DiffIcon.updateHitbox();
    player1DiffIcon.setPosition(diffLeftArrow.x - player1DiffIcon.width - 20, bottomBorder.y + (player1DiffIcon.frameHeight / 10));
    player1DiffIcon.camera = bordersCam;
    add(player1DiffIcon);

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

    chartDiffBar = new FlxBar(diffBarOutline1.x + (3 * 3.2), diffBarOutline1.y + (2 * 3.2), FlxBarFillDirection.LEFT_TO_RIGHT, 162, 16);
    chartDiffBar.createGradientEmptyBar([0xFF000000], 1);
    chartDiffBar.createGradientFilledBar([0xFFFE0000, 0xFFFFFF00, 0xFF00FA00], 1);
    chartDiffBar.setRange(0, 20);
    chartDiffBar.camera = bordersCam;

    mechDiffBar = new FlxBar(diffBarOutline2.x + (3 * 3.2) - 2, diffBarOutline2.y + (2 * 3.2), FlxBarFillDirection.RIGHT_TO_LEFT, 162, 16);
    mechDiffBar.createGradientEmptyBar([0xFF000000], 1);
    mechDiffBar.createGradientFilledBar([0xFF00FA00, 0xFFFFFF00, 0xFFFE0000], 1);
    mechDiffBar.setRange(0, 20);
    mechDiffBar.camera = bordersCam;

    add(chartDiffBar);
    add(mechDiffBar);
    add(diffBarOutline1);
    add(diffBarOutline2);

    var chartTxt:FunkinText = new FunkinText(0, 0, 0, "Chart", 24, false);
    chartTxt.font = Paths.font("gameboy.ttf");
    chartTxt.setPosition(chartDiff.x + chartDiff.width + 45, bottomBorder.y + 2);
    chartTxt.camera = bordersCam;
    add(chartTxt);

    player1DiffTxt = new FunkinText(0, 0, 220, "Mechanics", 24, false);
    player1DiffTxt.font = Paths.font("gameboy.ttf");
    player1DiffTxt.alignment = "center";
    player1DiffTxt.setPosition(dedCrew2.x + dedCrew2.width, bottomBorder.y + 2);
    player1DiffTxt.camera = bordersCam;
    add(player1DiffTxt);

    var lengthOfScoreTxt:Int = 544;

    scorTxtTxt = new FunkinText(FlxG.width, topBorder.height, lengthOfScoreTxt, "HIGHSCORE", 24, true);
    scorTxtTxt.font = Paths.font("pixeloidsans.ttf");
    scorTxtTxt.letterSpacing = 2;
    scorTxtTxt.alignment = "right";
    scorTxtTxt.borderSize = 3;
    scorTxtTxt.camera = songDataCam;
    scorTxtTxt.x -= scorTxtTxt.width + 8;
    add(scorTxtTxt);

    scoreTxt = new FunkinText(FlxG.width, scorTxtTxt.y + scorTxtTxt.height - 16, lengthOfScoreTxt, "00000000", 64, true);
    scoreTxt.font = Paths.font("pixeloidsans.ttf");
    scoreTxt.letterSpacing = 2;
    scoreTxt.alignment = "right";
    scoreTxt.borderSize = 8;
    scoreTxt.camera = songDataCam;
    scoreTxt.x -= scoreTxt.width;
    add(scoreTxt);

    accuracyTxt = new FunkinText(FlxG.width, scoreTxt.y + scoreTxt.height - 16, lengthOfScoreTxt, "0.00%", 40, true);
    accuracyTxt.font = Paths.font("pixeloidsans.ttf");
    accuracyTxt.letterSpacing = 2;
    accuracyTxt.alignment = "right";
    accuracyTxt.borderSize = 5;
    accuracyTxt.camera = songDataCam;
    accuracyTxt.x -= accuracyTxt.width;
    add(accuracyTxt);

    regeneratePageP1();
    changeDifficultyP1(0);

    interpolateColor = new FlxInterpolateColor(glow.color);
}

function postCreate() {
    if (newPlayableWaiting) {
        fade2Volume = 0.4;
    }

    new FlxTimer().start(0.25, _ -> {computerP1.animation.play("turnOn", true);});
    new FlxTimer().start(0.9, _ -> {
        allowGlobalInput = true;

        if (newPlayableWaiting) {
            var comptGlow:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/computerGlow"));
            comptGlow.scale.set(1.5, 1.5);
            comptGlow.updateHitbox();
            comptGlow.alpha = 0;
            comptGlow.camera = charactersCam;
            comptGlow.color = 0xFFFFD433;
            comptGlow.setPosition(computerP1.x - (comptGlow.getMidpoint().x / 2) - 27, computerP1.y - (comptGlow.getMidpoint().y / 2) - 27);
            comptGlow.blend = 0;
            charP1Side.insert(charP1Side.members.indexOf(computerP1), comptGlow);

            FlxTween.color(charBG, 0.1, 0xFFFFFFFF, 0xFF555555);
            FlxTween.color(boxes, 0.1, 0xFFFFFFFF, 0xFF999999);
            FlxTween.tween(comptGlow, {alpha: 0.9}, 1, {ease: FlxEase.sineInOut,type: FlxTweenType.PINGPONG});
            computerP1.animation.play("newChar");
        }
        else {
            doComptIdleDance = true;
            pressAcceptTxt2P.visible = true;
            computerP1.animation.play("beatRight", true);

            flickerLoopP2Txt();
        }

        playCurSongInst();
    });

    if (FlxG.save.data.impPixelxBRZ) {
        forEach(function(spr) {
            if (spr.camera == bordersCam) {
                if (spr is FlxSprite) {
                    var xbrzShader:CustomShader = new CustomShader("xbrz");
                    xbrzShader.precisionHint = 0;
                    spr.shader = xbrzShader;
                }
            }
        });
        charP1Side.forEach(function(spr) {
            if (spr is FlxSprite) {
                var xbrzShader:CustomShader = new CustomShader("xbrz");
                xbrzShader.precisionHint = 0;
                spr.shader = xbrzShader;
            }
        });
        charP2Side.forEach(function(spr) {
            if (spr is FlxSprite) {
                var xbrzShader:CustomShader = new CustomShader("xbrz");
                xbrzShader.precisionHint = 0;
                spr.shader = xbrzShader;
            }
        });
    }

    // corrects position if ur hovering over a null panel
    if (panels1[curSongP1].members.length < 1) changeSongP1(1);
    if (panels2[curSongP2].members.length < 1) changeSongP2(1);
}

function update(elapsed:Float) {
    handlePlayer1Input();
    handlePlayer2Input();
    handleGlobalInput();
    handleSongSelection();

    if (songList1 != null && songList1.length > 0 && songList1[curSongP1] != null)
        interpolateColor.fpsLerpTo(songList1[curSongP1].parsedColor, 0.0625);
    else
        interpolateColor.fpsLerpTo(FlxColor.WHITE, 0.0625);
    glow.color = interpolateColor.color;

    chartDiffLerp = FlxMath.lerp(chartDiffLerp, chartDiffValue, 0.1);
    chartDiffBar.value = chartDiffLerp;

    mechDiffLerp = FlxMath.lerp(mechDiffLerp, mechDiffValue, 0.1);
    mechDiffBar.value = mechDiffLerp;

    updateScoreText();
}

var allowP1Input:Bool = true;
var isSongChosenP1:Bool = false;
function handlePlayer1Input() {
    if (!allowGlobalInput) return;

    if (!allowP1Input) return;

    if (isVersusActive) {
        if (isSongChosenP1) {
            if (controlsP1.BACK)
                deselectSongP1();
        }
        else {
            if (controlsP1.UP_P)
                changeSongP1(-1);
            if (controlsP1.DOWN_P)
                changeSongP1(1);

            if (controlsP1.ACCEPT)
                selectSongP1();
        }
    }
    else {
        if (isSongChosenP1) {
            if (controlsP1.BACK)
                deselectSongP1();
        }
        else {
            if (controlsP1.UP_P || FlxG.mouse.wheel > 0)
                changeSongP1(-1);
            if (controlsP1.DOWN_P || FlxG.mouse.wheel < 0)
                changeSongP1(1);

            if (controlsP1.LEFT_P) {
                diffLeftArrow.animation.play("click");
                changeDifficultyP1(-1);
            }
            if (controlsP1.RIGHT_P) {
                diffRightArrow.animation.play("click");
                changeDifficultyP1(1);
            }

            if (controlsP1.ACCEPT)
                selectSongP1();

            if (controlsP1.BACK) {
                FlxG.sound.play(Paths.sound("menu/cancel"), 1);
                FlxG.switchState(new MainMenuState());
            }
        }
    }
}

var allowP2Input:Bool = true;
var isSongChosenP2:Bool = false;
function handlePlayer2Input() {
    if (!allowGlobalInput) return;

    if (!allowP2Input) return;

    if (newPlayableWaiting) return;

    if (isVersusActive) {
        if (isSongChosenP2) {
            if (controlsP2.BACK)
                deselectSongP2();
        }
        else {
            if (controlsP2.UP_P)
                changeSongP2(-1);
            if (controlsP2.DOWN_P)
                changeSongP2(1);

            if (controlsP2.ACCEPT)
                selectSongP2();

            if (controlsP2.BACK)
                exitVersus();
        }
    }
    else {
        if (isSongChosenP1) return;

        if (controlsP2.ACCEPT)
            initVersus();
    }
}

function handleGlobalInput() {
    if (!allowGlobalInput) return;

    if (!isVersusActive) {
        if (FlxG.keys.justPressed.HOME)
            changeSongP1(-curSongP1);
        if (FlxG.keys.justPressed.END) {
            var amount2jump:Int = 0;
            for (panel in panels1) {
                if (panel.members.length > 0) amount2jump += 1;
            }
            changeSongP1(amount2jump - curSongP1 - 1);
        }

        if (FlxG.keys.justPressed.TAB) {
            if (curPlayable == "bf") curPlayable = "pico";
            else curPlayable = "bf";

            FlxG.resetState();
        }
    }
}

function handleSongSelection() {
    static var panelHeight:Float = 140;

    if (isVersusActive) {
        for (i => panel in panels1) {
            if (panel == null) return;

            var yPanel:Float = ((FlxG.height - panelHeight) / 2) + ((i - curSongP1) * panelHeight) + 12;

            var xEquationLol:Float = (Math.abs(Math.cos((panel.y + (panelHeight / 2) - (FlxG.camera.scroll.y + (FlxG.height / 2))) / (FlxG.height * 1.25) * Math.PI)) * 150);

            panel.y = CoolUtil.fpsLerp(panel.y, yPanel, 0.2);
            panel.x = CoolUtil.fpsLerp(panel.x, xEquationLol, 0.25);
        }
        for (i => panel in panels2) {
            if (panel == null) return;

            var yPanel:Float = ((FlxG.height - panelHeight) / 2) + ((i - curSongP2) * panelHeight) + 12;

            // this is probably the laziest and stupidest solution... but it works LOL
            var xEquationLol:Float = -(Math.abs(Math.cos((panel.y + (panelHeight / 2) - (FlxG.camera.scroll.y + (FlxG.height / 2))) / (FlxG.height * 1.25) * Math.PI)) * 150) + FlxG.width / 1.5 - 4;

            panel.y = CoolUtil.fpsLerp(panel.y, yPanel, 0.2);
            panel.x = CoolUtil.fpsLerp(panel.x, xEquationLol, 0.25);
        }
    }
    else {
        for (i => panel in panels1) {
            if (panel == null) return;

            var yPanel:Float = ((FlxG.height - panelHeight) / 2) + ((i - curSongP1) * panelHeight) + 12;

            var xEquationLol:Float = 305 + (Math.abs(Math.cos((panel.y + (panelHeight / 2) - (FlxG.camera.scroll.y + (FlxG.height / 2))) / (FlxG.height * 1.25) * Math.PI)) * 150);

            panel.y = CoolUtil.fpsLerp(panel.y, yPanel, 0.2);
            panel.x = CoolUtil.fpsLerp(panel.x, xEquationLol, 0.25);
        }
    }
}

static var lastSongP1:Int = -1;
function changeSongP1(change:Int) {
    if (panels1 != null && panels1.length < 1) return;

    curSongP1 = FlxMath.wrap(curSongP1 + change, 0, panels1.length - 1);

    if (panels1[curSongP1].members.length < 1) {
        changeSongP1(change / Math.abs(change));
        return;
    }

    changeDifficultyP1(0);
    playCurSongInst();
    panelTextMovementP1();

    if (curSongP1 != lastSongP1) {
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);
        lastSongP1 = curSongP1;
    }
}

static var lastSongP2:Int = -1;
function changeSongP2(change:Int) {
    if (panels2 != null && panels2.length < 1) return;

    curSongP2 = FlxMath.wrap(curSongP2 + change, 0, panels2.length - 1);

    if (panels2[curSongP2].members.length < 1) {
        changeSongP2(change / Math.abs(change));
        return;
    }

    changeDifficultyP2(0);
    panelTextMovementP2();

    if (curSongP2 != lastSongP2) {
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);
        lastSongP2 = curSongP2;
    }
}

function changeDifficultyP1(change:Int) {
    var difficultiesFromSong:Array<String> = songList1[curSongP1].difficulties;

    var changeAmount:Int = (difficultiesFromSong != null && difficultiesFromSong.length > 0) ? difficultiesFromSong.length - 1 : 1;
    curDiffP1 = FlxMath.wrap(curDiffP1 + change, 0, changeAmount);

    if (isVersusActive) curDiffP1 = changeAmount;

    if (difficultiesFromSong != null && difficultiesFromSong[curDiffP1] != null) {
        if (Assets.exists(Paths.image("menus/freeplay/difficulties/" + difficultiesFromSong[curDiffP1])))
            difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/" + difficultiesFromSong[curDiffP1]));
        else
            difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/unknown"));
    }
    else {
        difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/none"));
    }
    difficultySpr.updateHitbox();
    difficultySpr.screenCenter(FlxAxes.X);

    updateDiffBarsP1();
    updateScoreValue();

    if (!isVersusActive) {
        if (change > 0)
            spawnXposP1 = -400;
        else if (change < 0)
            spawnXposP1 = FlxG.width;
    }
    else
        spawnXposP1 = -400;

    if (change != 0) {
        regeneratePageP1();
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);
    }
}

function changeDifficultyP2(change:Int) {
    var difficultiesFromSong:Array<String> = songList1[curSongP2].difficulties;

    var changeAmount:Int = (difficultiesFromSong != null && difficultiesFromSong.length > 0) ? difficultiesFromSong.length - 1 : 1;
    curDiffP2 = FlxMath.wrap(curDiffP2 + change, 0, changeAmount);

    if (isVersusActive) curDiffP2 = changeAmount;

    if (difficultiesFromSong != null && difficultiesFromSong[curDiffP2] != null) {
        if (Assets.exists(Paths.image("menus/freeplay/difficulties/" + difficultiesFromSong[curDiffP2])))
            difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/" + difficultiesFromSong[curDiffP2]));
        else
            difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/unknown"));
    }
    else {
        difficultySpr.loadGraphic(Paths.image("menus/freeplay/difficulties/none"));
    }
    difficultySpr.updateHitbox();
    difficultySpr.screenCenter(FlxAxes.X);

    updateDiffBarsP2();

    spawnXposP2 = FlxG.width;

    if (change != 0) {
        regeneratePageP2();
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);
    }
}

function updateDiffBarsP1() {
    var chartRatings:Array<Dynamic>;
    var chosenChartRating:Int = 0;
    if (songList1[curSongP1].customValues != null && songList1[curSongP1].customValues.ratingsChart != null) {
        chartRatings = songList1[curSongP1].customValues.ratingsChart;
        chosenChartRating = switch(songList1[curSongP1].difficulties[curDiffP1]) {
            case "easy": chartRatings.easy ?? 0;
            case "normal": chartRatings.normal ?? 0;
            case "hard": chartRatings.hard ?? 0;
            case "erect": chartRatings.erect ?? 0;
            case "nightmare": chartRatings.nightmare ?? 0;
            default: 0;
        }
    }
    else
        chosenChartRating = 0;

    var chosenMechRating:Int = 0;
    if (!isVersusActive) {
        var mechRatings:Array<Dynamic>;
        if (songList1[curSongP1].customValues != null && songList1[curSongP1].customValues.ratingsMechanics != null) {
            mechRatings = songList1[curSongP1].customValues.ratingsMechanics;
            chosenMechRating = switch(songList1[curSongP1].difficulties[curDiffP1]) {
                case "easy": mechRatings.easy ?? 0;
                case "normal": mechRatings.normal ?? 0;
                case "hard": mechRatings.hard ?? 0;
                case "erect": mechRatings.erect ?? 0;
                case "nightmare": mechRatings.nightmare ?? 0;
                default: 0;
            }
        }
        else
            chosenMechRating = 0;
    }

    if (isVersusActive) {
        mechDiffValue = chosenChartRating;
    }
    else {
        chartDiffValue = chosenChartRating;
        mechDiffValue = chosenMechRating;
    }
}

function updateDiffBarsP2() {
    var chartRatings:Array<Dynamic>;
    var chosenChartRating:Int = 0;
    if (songList2[curSongP2].customValues != null && songList2[curSongP2].customValues.ratingsChart != null) {
        chartRatings = songList2[curSongP2].customValues.ratingsChart;
        chosenChartRating = switch(songList2[curSongP2].difficulties[curDiffP2]) {
            case "easy": chartRatings.easy ?? 0;
            case "normal": chartRatings.normal ?? 0;
            case "hard": chartRatings.hard ?? 0;
            case "erect": chartRatings.erect ?? 0;
            case "nightmare": chartRatings.nightmare ?? 0;
            default: 0;
        }
    }
    else
        chosenChartRating = 0;

    chartDiffValue = chosenChartRating;
}

function updateScoreValue() {
    if (songList1[curSongP1] != null && songList1[curSongP1].difficulties.length <= 0) {
		intendedScore = 0;
        intendedAccuracy = 0;
		return;
	}

    var saveData = FunkinSave.getSongHighscore(songList1[curSongP1].name, songList1[curSongP1].difficulties[curDiffP1], []);
    //trace(saveData);
    intendedScore = saveData.score ?? 0;
    intendedAccuracy = saveData.accuracy ?? 0;
}

function updateScoreText() {
    lerpScore = Math.floor(lerp(lerpScore, intendedScore, 0.4));
    if (Math.abs(lerpScore - intendedScore) <= 5)
		lerpScore = intendedScore;

    lerpAccuracy = lerp(lerpAccuracy, intendedAccuracy, 0.2);
    if (Math.abs(lerpAccuracy - intendedAccuracy) <= 0.01)
		lerpAccuracy = intendedAccuracy;

    scoreTxt.text = StringTools.lpad(Std.string(lerpScore), "0", 8);
    
    var splittedAcc:Array<String> = Std.string(FlxMath.roundDecimal(lerpAccuracy * 100, 2)).split(".");
    var accWholeNums:String = splittedAcc[0];
    var accDecimals:String = splittedAcc[1] ?? "0";
    accuracyTxt.text = accWholeNums + "." + StringTools.rpad(accDecimals, "0", 2) + "%";
}

var allowSongInstPlayer:Bool = true;
function playCurSongInst() {
    if (!allowSongInstPlayer) return;

    if (curInstPlaying != (curInstPlaying = Paths.inst(songList1[curSongP1].name, songList1[curSongP1].difficulties[curDiffP1]))) {
        var musicPlayer:Void -> Void = function() {
            FlxG.sound.playMusic(curInstPlaying, 0);
            FlxG.sound.music.fadeIn(2, 0, fade2Volume);
            Conductor.changeBPM(songList1[curSongP1].bpm, songList1[curSongP1].beatsPerMeasure, songList1[curSongP1].stepsPerBeat);
        }
        Main.execAsync(musicPlayer);
    }
    else
        FlxG.sound.music.fadeIn(2, FlxG.sound.music.volume, fade2Volume);
}

function selectSongP1() {
    allowP1Input = false;
    isSongChosenP1 = true;

    FlxG.sound.play(Paths.sound("menu/confirm"), 1);

    if (isVersusActive) {
        for (i => panel in panels1) {
            if (i == curSongP1) {
                panel.members[3].animation.play("select");
                panel.members[3].animation.finishCallback = _ -> {panel.members[3].animation.play("select-hold");};
            }
            else {
                panel.forEach(function(spr) {
                    FlxTween.tween(spr, {alpha: 0}, 0.2);
                });
            }
        }
        new FlxTimer().start(0.2, _ -> {
            allowP1Input = true;
        });
    }
    else {
        for (i => panel in panels1) {
            if (i == curSongP1) {
                panel.members[3].animation.play("select");
                panel.members[3].animation.finishCallback = _ -> {panel.members[3].animation.play("select-hold");};
            }
            else {
                panel.forEach(function(spr) {
                    FlxTween.tween(spr, {alpha: 0}, 0.2);
                });
            }
        }
    }

    checkPlayersSelection();
}

function selectSongP2() {
    allowP2Input = false;
    isSongChosenP2 = true;

    FlxG.sound.play(Paths.sound("menu/confirm"), 1);

    for (i => panel in panels2) {
        if (i == curSongP2) {
            panel.members[3].animation.play("select");
            panel.members[3].animation.finishCallback = _ -> {panel.members[3].animation.play("select-hold");};
        }
        else {
            panel.forEach(function(spr) {
                FlxTween.tween(spr, {alpha: 0}, 0.2);
            });
        }
    }
    new FlxTimer().start(0.2, _ -> {
        allowP2Input = true;
    });

    checkPlayersSelection();
}

function deselectSongP1() {
    allowP1Input = false;
    isSongChosenP1 = false;

    FlxG.sound.play(Paths.sound("menu/cancel"), 1);

    if (isVersusActive) {
        for (i => panel in panels1) {
            if (i == curSongP1) {
                panel.members[3].animation.play("select", false, true);
                panel.members[3].animation.finishCallback = _ -> {panel.members[3].animation.play("idle");};
            }
            else {
                panel.forEach(function(spr) {
                    FlxTween.tween(spr, {alpha: 1}, 0.2);
                });
            }
        }
    }
    else { // this case scenario shouldnt be possible, but leave it in incase an error happens ig?
        for (i => panel in panels1) {
            if (i == curSongP1) {
                panel.members[3].animation.play("select", false, true);
                panel.members[3].animation.finishCallback = _ -> {panel.members[3].animation.play("idle");};
                FlxTween.tween(songsCam, {zoom: 1}, 0.5, {ease: FlxEase.expoOut});
                FlxG.sound.music.fadeIn(0.5, 0, fade2Volume);
            }
            else {
                panel.forEach(function(spr) {
                    FlxTween.tween(spr, {alpha: 1}, 0.2);
                });
            }
        }
    }
    new FlxTimer().start(0.2, _ -> {
        allowP1Input = true;
    });
}

function deselectSongP2() {
    allowP2Input = false;
    isSongChosenP2 = false;

    FlxG.sound.play(Paths.sound("menu/cancel"), 1);

    for (i => panel in panels2) {
        if (i == curSongP2) {
            panel.members[3].animation.play("select", false, true);
            panel.members[3].animation.finishCallback = _ -> {panel.members[3].animation.play("idle");};
        }
        else {
            panel.forEach(function(spr) {
                FlxTween.tween(spr, {alpha: 1}, 0.2);
            });
        }
    }
    new FlxTimer().start(0.2, _ -> {
        allowP2Input = true;
    });
}

function checkPlayersSelection() {
    if (isVersusActive) {
        if (isSongChosenP1 && isSongChosenP2) {
            allowGlobalInput = false;
            FlxTween.tween(songsCam, {zoom: 1.2}, 0.5, {ease: FlxEase.expoOut});
        }
    }
    else {
        FlxTween.tween(songsCam, {zoom: 1.3}, 0.5, {ease: FlxEase.expoOut});
        FlxG.sound.music.fadeIn(0.5, fade2Volume, 0);
        decidedSong = songList1[curSongP1];
        decidedDiff = songList1[curSongP1].difficulties[curDiffP1];
        loadSong();
    }
}

var decidedSong:Array<Dynamic> = [];
var decidedDiff:String = "";
function loadSong() {
    allowSongInstPlayer = false;
    curInstPlaying = null;

    PlayState.loadSong(decidedSong.name, decidedDiff, false, isVersusActive);

    new FlxTimer().start(1, _ -> {
        FlxG.switchState(new PlayState());
    });
}

function flickerLoopP2Txt() {
    pressAcceptTxt2P.visible = true;
    FlxFlicker.flicker(pressAcceptTxt2P, 1, 0.5, true, true, flickerLoopP2Txt);
}

function acceptP2Txt() {
    if (FlxFlicker.isFlickering(pressAcceptTxt2P))
        FlxFlicker.stopFlickering(pressAcceptTxt2P);

    var uhhhIdkHow2CallThis:FunkinText = pressAcceptTxt2P.clone();
    uhhhIdkHow2CallThis.setPosition(pressAcceptTxt2P.x, pressAcceptTxt2P.y);
    insert(members.indexOf(pressAcceptTxt2P) - 1, uhhhIdkHow2CallThis);

    FlxTween.tween(uhhhIdkHow2CallThis, {alpha: 0}, 0.5);
    FlxTween.tween(uhhhIdkHow2CallThis.scale, {x: 1.5, y: 1.5}, 0.75, {ease: FlxEase.quartOut, onComplete: _ -> {
        uhhhIdkHow2CallThis.destroy();
        remove(uhhhIdkHow2CallThis);
    }});

    FlxG.sound.play(Paths.sound("menu/enterP2"), 1);
    FlxFlicker.flicker(pressAcceptTxt2P, 1.25, 0.05, false, true);
}

function initVersus() {
    isVersusActive = true;
    allowGlobalInput = false;
    allowSongInstPlayer = false;
    curInstPlaying = "";
    spawnXposP1 = 0;
    spawnXposP2 = FlxG.width;
    doComptIdleDance = false;
    lastSongP1 = -1;
    lastSongP2 = -1;
    isSongChosenP1 = false;
    isSongChosenP2 = false;
    scorTxtTxt.visible = false;
    scoreTxt.visible = false;
    accuracyTxt.visible = false;
    clearPageP1();

    chartDiffValue = 0;
    mechDiffValue = 0;

    FlxG.sound.music.stop();

    FlxTween.tween(charP1Side, {x: -48}, 1.5, {ease: FlxEase.quartOut});
    FlxTween.tween(charP2Side, {x: 848}, 1.25, {ease: FlxEase.quartOut});
    FlxTween.tween(glow, {alpha: 0}, 1);

    computerP1.animation.play("danger");
    computerP2.animation.play("danger");

    acceptP2Txt();

    new FlxTimer().start(1.5, _ -> {
        allowP1Input = true;
        allowP2Input = true;
        allowGlobalInput = true;
        regeneratePageP1();
        regeneratePageP2();

        player1DiffIcon.loadGraphic(Paths.image("menus/freeplay/chartDiff"));
        player1DiffIcon.updateHitbox();
        player1DiffIcon.setPosition(diffLeftArrow.x - player1DiffIcon.width - 20, bottomBorder.y + (player1DiffIcon.height / 8));
        player1DiffTxt.text = "Chart";

        computerP1.animation.play("versus");
        computerP2.animation.play("versus-flipped");

        diffLeftArrow.visible = false;
        diffRightArrow.visible = false;
    });
}

function exitVersus() {
    isVersusActive = false;
    allowGlobalInput = false;
    curInstPlaying = "";
    spawnXposP1 = 0;
    doComptIdleDance = true;
    lastSongP1 = -1;
    lastSongP2 = -1;
    isSongChosenP1 = false;
    isSongChosenP2 = false;
    clearPageP1();
    clearPageP2();

    chartDiffValue = 0;
    mechDiffValue = 0;

    FlxG.sound.music.stop();

    FlxTween.tween(charP1Side, {x: 0}, 1.5, {ease: FlxEase.quartOut});
    FlxTween.tween(charP2Side, {x: FlxG.width}, 1.5, {ease: FlxEase.quartIn});
    FlxTween.tween(glow, {alpha: 0.4}, 0.6, {startDelay: 0.4});

    computerP1.animation.play("wave");
    computerP2.animation.play("wave");

    FlxG.sound.play(Paths.sound("menu/cancel"), 1);

    new FlxTimer().start(1.8, _ -> {
        allowP1Input = true;
        allowP2Input = true;
        allowSongInstPlayer = true;
        allowGlobalInput = true;
        regeneratePageP1();

        player1DiffIcon.loadGraphic(Paths.image("menus/freeplay/mechDiff"));
        player1DiffIcon.updateHitbox();
        player1DiffIcon.setPosition(diffLeftArrow.x - player1DiffIcon.width - 20, bottomBorder.y + (player1DiffIcon.frameHeight / 10));
        player1DiffTxt.text = "Mechanics";

        diffLeftArrow.visible = true;
        diffRightArrow.visible = true;

        scorTxtTxt.visible = true;
        scoreTxt.visible = true;
        accuracyTxt.visible = true;

        flickerLoopP2Txt();
    });
}

function clearPageP1() {
    for (panel in panels1) {
        panel.clear();
        remove(panel);
        panel.destroy();
    }

    panels1 = [];
}

function clearPageP2() {
    for (panel in panels2) {
        panel.clear();
        remove(panel);
        panel.destroy();
    }

    panels2 = [];
}

function regeneratePageP1() {
    clearPageP1();

    getSongListP1();

    var songs2Eliminate:Array<Int> = [];
    for (i in 0...songList1.length) {
        if (!songList1[i].difficulties.contains(songList1[i].difficulties[curDiffP1]))
            songs2Eliminate.push(i);
    }

    var positionCorrection:Int = 0;
    for (song in songs2Eliminate) {
        song -= positionCorrection;
        songList1.remove(songList1[song]);
        positionCorrection += 1;
    }

    for (i in 0...songList1.length) {
        var newPanel:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
        newPanel = createPanel(songList1[i], 1);
        add(newPanel);
        panels1.push(newPanel);
    }
    changeSongP1(0);
}

function regeneratePageP2() {
    clearPageP2();

    getSongListP2();

    var songs2Eliminate:Array<Int> = [];
    for (i in 0...songList2.length) {
        if (!songList2[i].difficulties.contains(songList2[i].difficulties[curDiffP1]))
            songs2Eliminate.push(i);
    }

    var positionCorrection:Int = 0;
    for (song in songs2Eliminate) {
        song -= positionCorrection;
        songList2.remove(songList2[song]);
        positionCorrection += 1;
    }

    for (i in 0...songList2.length) {
        var newPanel:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
        newPanel = createPanel(songList2[i], 2);
        add(newPanel);
        panels2.push(newPanel);
    }
    changeSongP2(0);
}

var doComptIdleDance:Bool = false;
var comptDance:Bool = false;
function beatHit(curBeat:Int) {
    if (!newPlayableWaiting) {
        if (doComptIdleDance && computerP1 != null) {
            if (comptDance)
                computerP1.animation.play("beatRight", true);
            else
                computerP1.animation.play("beatLeft", true);
            
            comptDance = !comptDance;
        }
    }
}

var spawnXposP1:Float = 0;
var spawnXposP2:Float = FlxG.width;
function createPanel(songData:Array<Dynamic>, ?player:Int) {
    var scale:Float = 3;

    var icon:Array<String> = songData.icon.split("-");

    var group:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

    var panel:FlxSprite = new FlxSprite(0, 0);
    var path:String;
    if (isVersusActive) {
        if (player != null) {
            path = Paths.image("menus/freeplay/panels/player" + player);
        }
        else {
            path = Paths.image("menus/freeplay/panels/" + loadedPlayable.freeplayStyle);
        }
    }
    else {
        path = Paths.image("menus/freeplay/panels/" + loadedPlayable.freeplayStyle);
    }
    panel.loadGraphic(path);
    panel.antialiasing = false;
    panel.scale.set(scale, scale);
    panel.updateHitbox();

    var panelBG:FlxSprite = new FlxSprite(panel.x + (37 * scale), panel.y + (10 * scale)).loadGraphic(Paths.image("menus/freeplay/panels/panelBg"));
    panelBG.antialiasing = false;
    panelBG.scale.set(scale, scale);
    panelBG.updateHitbox();

    var songName:FunkinText = new FunkinText(panel.x + (42 * scale) + .5, panel.y + (13 * scale) + .5, 0, songData.displayName, 25, false);
    songName.font = Paths.font("pixeloidsans.ttf");
    songName.letterSpacing = 1;
    songName.clipRect = new FlxRect(0, 0, clipLimitR, songName.height);

    group.add(panelBG);
    group.add(songName);
    group.add(panel);

    var iconExists:Bool = /*Assets.exists(Paths.image("menus/freeplay/icons/" + icon[0]))*/ true;
    var attachedIcon:FlxSprite = new FlxSprite();
    attachedIcon.scale = panel.scale;
    attachedIcon.updateHitbox();
    attachedIcon.antialiasing = false;
    if (iconExists) {
        attachedIcon.frames = Paths.getFrames("menus/freeplay/icons/" + loadedPlayable.id);
        attachedIcon.animation.addByPrefix("idle", "idle0", 10, true);
        attachedIcon.animation.addByPrefix("select", "confirm0", 10, false);
        attachedIcon.animation.addByPrefix("select-hold", "confirm-hold0", 10, true);
        attachedIcon.animation.play("idle");
    }
    else
        attachedIcon.visible = false;

    attachedIcon.setPosition(panel.x + attachedIcon.origin.x, panel.y + attachedIcon.origin.y);
    group.add(attachedIcon);

    // the sticker MUST be the last sprite that gets added to the group, so it doesnt interfer with values
    var stickerSprite:Null<String> = getRankSticker(songData);
    var rankSticker:FlxSprite = new FlxSprite((panel.x + panel.width) - (4 * scale), panel.y + (6 * scale));
    rankSticker.scale.set(scale, scale);
    if (stickerSprite != null && !isVersusActive) {
        rankSticker.loadGraphic(Paths.image("menus/freeplay/ranks/" + stickerSprite));
        group.add(rankSticker);
    }

    group.y = FlxG.height / 2.38;

    if (isVersusActive) {
        if (player == 2) {
            group.x = spawnXposP2 - panel.width;
        }
        else
            group.x = spawnXposP1;
    }
    else
        group.x = spawnXposP1;

    if (FlxG.save.data.impPixelxBRZ) {
        group.forEach(function(spr) {
            if (spr is FlxSprite) {
                var xbrzShader:CustomShader = new CustomShader("xbrz");
                xbrzShader.precisionHint = 0;
                spr.shader = xbrzShader;
            }
        });
    }

    return group;
}

var clipLimitL:Float = -12;
var clipLimitR:Float = 300;

function panelTextMovementP1() {
    for (i in 0...panels1.length) {
        FlxTween.cancelTweensOf(panels1[i].members[1]);
        panels1[i].members[1].clipRect = new FlxRect(0, 0, clipLimitR, panels1[i].members[1].height);
        panels1[i].members[1].offset.x = 0;
        if (panels1[curSongP1].members[1].width > clipLimitR) {
            movePanelTextRight(panels1[curSongP1].members[1]);
        }
    }
}

function panelTextMovementP2() {
    for (i in 0...panels2.length) {
        FlxTween.cancelTweensOf(panels2[i].members[1]);
        panels2[i].members[1].clipRect = new FlxRect(0, 0, clipLimitR, panels2[i].members[1].height);
        panels2[i].members[1].offset.x = 0;
        if (panels2[curSongP2].members[1].width > clipLimitR) {
            movePanelTextRight(panels2[curSongP2].members[1]);
        }
    }
}

function movePanelTextRight(text:FunkinText) {
    if (text == null) return;

    var distance2move:Float = text.width - clipLimitR + 14;

    FlxTween.tween(text, {"offset.x": distance2move}, 2, {startDelay: 0.3, ease: FlxEase.sineInOut, onUpdate: _ -> {
        text.clipRect = new FlxRect(text.offset.x + clipLimitL, 0, clipLimitR, text.height);
    }, onComplete: _ -> {
        movePanelTextLeft(text);
    }});
}

function movePanelTextLeft(text:FunkinText) {
    if (text == null) return;

    FlxTween.tween(text, {"offset.x": 0}, 2, {startDelay: 0.3, ease: FlxEase.sineInOut, onUpdate: _ -> {
        text.clipRect = new FlxRect(text.offset.x + clipLimitL, 0, clipLimitR, text.height);
    }, onComplete: _ -> {
        movePanelTextRight(text);
    }});
}

function getSongListP1():Array<Dynamic> {
    songList1 = [];
    if (pageArray.pages[curPageP1].songs.length > 0) {
        for (song in pageArray.pages[curPageP1].songs) {
            songList1.push(Chart.loadChartMeta(loadedPlayable.getSongName(song), "normal", false));
        }
    }
}

function getSongListP2():Array<Dynamic> {
    songList2 = [];
    if (pageArray.pages[curPageP2].songs.length > 0) {
        for (song in pageArray.pages[curPageP2].songs) {
            songList2.push(Chart.loadChartMeta(loadedPlayable.getSongName(song), "normal", false));
        }
    }
}

function getRankSticker(songData:Array<Dynamic>):String {
    var data:Float = FunkinSave.getSongHighscore(songData.name, songData.difficulties[curDiffP1], []);
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

// taken from MusicBeatState
function lerp(v1:Float, v2:Float, ratio:Float, fpsSensitive:Bool = false) {
    if (fpsSensitive)
        return FlxMath.lerp(v1, v2, ratio);
    else
        return CoolUtil.fpsLerp(v1, v2, ratio);
}