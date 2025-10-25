import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTweenType;
import funkin.backend.assets.ModsFolder;
import funkin.backend.utils.DiscordUtil;
import funkin.editors.character.CharacterSelection;
import funkin.editors.charter.CharterSelection;
import funkin.editors.stage.StageSelection;
import funkin.editors.EditorTreeMenu;
import funkin.menus.credits.CreditsMain;
import funkin.options.Options;
import lime.graphics.Image;
import openfl.ui.Mouse;
import BackButton;
import PixelStars;

var discordIntegration:Bool = false;

var modVersion:String = "0.3.0";

var discordAvatar:FlxSprite;
var discordUsername:FunkinText;

var lightThing:FlxSprite;
var lightGlow:FlxSprite;
var lightLight:FlxSprite;

var mainButtons:Array<Dynamic> = [
    {
        name: translate("mainMenu.play"),
        available: true,
        icon: Paths.image("menus/mainmenu/icons/play"),
        colorIdle: 0xFF0A3C33,
        colorHover: 0xFF10584B
    },
    {
        name: translate("mainMenu.achievements"),
        available: true,
        icon: Paths.image("menus/mainmenu/icons/achievements"),
        colorIdle: 0xFF0A3C33,
        colorHover: 0xFF10584B
    },
    {
        name: translate("mainMenu.shop"),
        available: (storyStates[storySequence] == "start") ? false : true,
        icon: Paths.image("menus/mainmenu/icons/shop"),
        colorIdle: 0xFF0A3C33,
        colorHover: 0xFF10584B
    }
];
var otherButtons:Array<Dynamic> = [
    {
        name: translate("mainMenu.options"),
        available: true,
        icon: Paths.image("menus/mainmenu/icons/options"),
        colorIdle: 0xFFAAE2DC,
        colorHover: 0xFFFFFFFF
    },
    {
        name: translate("mainMenu.extras"),
        available: true,
        icon: Paths.image("menus/mainmenu/icons/credits"),
        colorIdle: 0xFFAAE2DC,
        colorHover: 0xFFFFFFFF
    }
];
var modButton:Array<Dynamic> = [
    {
        name: translate("mainMenu.mods"),
        available: true,
        colorIdle: 0xFFFFFFFF,
        colorHover: 0xFFFFFFFF
    }
];

var allButtonsArray:Array<Dynamic> = [];
var buttonsTotalLength:Int = mainButtons.length + otherButtons.length + modButton.length;
var buttonGroup:FlxSpriteGroup;
var buttonsMainGroup:FlxSpriteGroup;
var buttonsLabelGroup:FlxSpriteGroup;
var buttonsIconGroup:FlxSpriteGroup;

var playSectionButtons:Array<Array<Dynamic>> = [
    {
        [
            {
                name: translate("mainMenu.worldmap"),
                available: true,
                image: Paths.image("menus/mainmenu/bigButtons/worldmap"),
                colorIdle: 0xFF0A3C33,
                colorHover: 0xFF10584B,
                transition: "closingSharpCircle"
            },
            {
                name: translate("mainMenu.freeplay"),
                available: (storyStates[storySequence] == "start") ? false : true,
                image: Paths.image("menus/mainmenu/bigButtons/freeplay"),
                colorIdle: 0xFF0A3C33,
                colorHover: 0xFF10584B,
                transition: "right2leftSharpCircle"
            }
        ];
    },
    {
        [
            {
                name: translate("mainMenu.tutorial"),
                available: true,
                image: Paths.image("menus/mainmenu/bigButtons/tutorial"),
                colorIdle: 0xFFAAE2DC,
                colorHover: 0xFFFFFFFF,
                transition: "closingSharpCircle"
            }
        ];
    }
];
var extrasSectionButtons:Array<Array<Dynamic>> = [
    {
        [
            {
                name: translate("mainMenu.credits"),
                available: true,
                image: Paths.image("menus/mainmenu/bigButtons/credits"),
                colorIdle: 0xFF0A3C33,
                colorHover: 0xFF10584B,
                transition: "fade"
            },
            {
                name: translate("mainMenu.movieTheater"),
                available: (unlockedVideos.length > 0),
                image: Paths.image("menus/mainmenu/bigButtons/movieTheater"),
                colorIdle: 0xFF0A3C33,
                colorHover: 0xFF10584B,
                transition: "closingSharpCircle"
            }
        ];
    }
];
var modsArray:Array<Array<Dynamic>> = []; // the options are added dynamically
var debugOptions:Array<Array<Dynamic>> = [
    {
        [
            {
                name: "Chart Editor",
                image: Paths.image("editors/icons/chart"),
                transition: "right2leftSharpCircle"
            }
        ];
    },
    {
        [
            {
                name: "Character Editor",
                image: Paths.image("editors/icons/character"),
                transition: "right2leftSharpCircle"
            }
        ];
    },
    {
        [
            {
                name: "Stage Editor",
                image: Paths.image("editors/icons/stage"),
                transition: "right2leftSharpCircle"
            }
        ];
    },
    {
        [
            {
                name: "Week Player",
                image: "",
                transition: "right2leftSharpCircle"
            }
        ];
    },
    {
        [
            {
                name: "Mobile Emulator",
                image: Paths.image("editors/icons/mobile"),
                transition: "closingSharpCircle"
            }
        ];
    }
];

var topButtonsGroup:FlxSpriteGroup;

var mainCam:FlxCamera;
var spaceCam:FlxCamera;
var frontCam:FlxCamera;
var spaceGroup:FlxSpriteGroup;
var windowGroup:FlxSpriteGroup;

var baseScale:Float = 5;

function create() {
    changeDiscordMenuStatus("Main Menu");

    subStateClosed.add(onCloseSubstate);

    mainCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    mainCam.bgColor = 0x00000000;
    FlxG.cameras.add(mainCam, true);

    var bgLeft:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/mainmenu/bg-left"));
    bgLeft.scale.set(baseScale, baseScale);
    bgLeft.updateHitbox();
    bgLeft.camera = mainCam;

    var bgRight:FlxSprite = new FlxSprite(FlxG.width).loadGraphic(Paths.image("menus/mainmenu/bg-right"));
    bgRight.scale.set(baseScale, baseScale);
    bgRight.updateHitbox();
    bgRight.x -= bgRight.width;
    bgRight.camera = mainCam;

    var bgDistance:Int = FlxMath.distanceBetween(bgLeft, bgRight) - bgRight.width;
    var bgMiddle:FlxSprite = new FlxSprite(bgLeft.x + bgLeft.width).loadGraphic(Paths.image("menus/mainmenu/bg-middle"));
    bgMiddle.scale.set(bgDistance, baseScale);
    bgMiddle.updateHitbox();
    bgMiddle.camera = mainCam;

    add(bgMiddle);
    add(bgLeft);
    add(bgRight);

    var topLeft:FlxSprite = new FlxSprite(3 * baseScale, 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/top-left"));
    topLeft.scale.set(baseScale, baseScale);
    topLeft.updateHitbox();
    topLeft.camera = mainCam;

    var topRight:FlxSprite = new FlxSprite(FlxG.width - 3 * baseScale, topLeft.y).loadGraphic(Paths.image("menus/mainmenu/top-right"));
    topRight.scale.set(baseScale, baseScale);
    topRight.updateHitbox();
    topRight.x -= topRight.width;
    topRight.camera = mainCam;

    var topDistance:Int = FlxMath.distanceBetween(topLeft, topRight) - topLeft.width + 4 * baseScale;
    var topMiddle:FlxSprite = new FlxSprite(topLeft.x + topLeft.width, topLeft.y).loadGraphic(Paths.image("menus/mainmenu/top-middle"));
    topMiddle.scale.set(topDistance, baseScale);
    topMiddle.updateHitbox();
    topMiddle.camera = mainCam;

    var topShadowL:FlxSprite = new FlxSprite(topLeft.x, (topLeft.y + topLeft.height) - 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/top-shadow"));
    topShadowL.scale.set(baseScale, baseScale);
    topShadowL.updateHitbox();
    topShadowL.blend = 9;
    topShadowL.camera = mainCam;

    var topShadowR:FlxSprite = new FlxSprite(topRight.x, (topRight.y + topRight.height) - 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/top-shadow"));
    topShadowR.scale.set(baseScale, baseScale);
    topShadowR.updateHitbox();
    topShadowR.blend = 9;
    topShadowR.camera = mainCam;
    topShadowR.flipX = true;

    var topShadowDistance:Int = FlxMath.distanceBetween(topShadowL, topShadowR) - topShadowR.width;
    var topShadowM:FlxSprite = new FlxSprite(topShadowL.x + topShadowL.width, topShadowL.y).makeGraphic(Std.int(topShadowDistance), Std.int(4 * baseScale), 0xFF999999);
    topShadowM.blend = 9;
    topShadowM.camera = mainCam;

    add(topShadowM);
    add(topShadowL);
    add(topShadowR);
    add(topMiddle);
    add(topLeft);
    add(topRight);

    if (!isMobile && discordIntegration) {
        discordAvatar = new FlxSprite(topLeft.x + 6 * baseScale, topLeft.y + 2.5 * baseScale);

        if (DiscordUtil.ready) {
            try {
                discordAvatar.loadGraphic(DiscordUtil.user.getAvatar(64));
            }
            catch (e:Dynamic) {
                discordAvatar.loadGraphic(Paths.image("menus/mainmenu/nullAvatar"));
            }
        }
        else
            discordAvatar.loadGraphic(Paths.image("menus/mainmenu/nullAvatar"));

        discordAvatar.camera = mainCam;
        discordAvatar.shader = new CustomShader("spriteSphereBounds");
        discordAvatar.shader.uRadius = 0.5;
        discordAvatar.shader.uCenter = [discordAvatar.width / 2, discordAvatar.height / 2];
        add(discordAvatar);
    }

    lightThing = new FlxSprite(topLeft.x + 26 * baseScale, topLeft.y + 4 * baseScale).loadGraphic(Paths.image("menus/mainmenu/lightThing"));
    lightThing.scale.set(baseScale, baseScale);
    lightThing.updateHitbox();
    lightThing.camera = mainCam;

    lightGlow = new FlxSprite().loadGraphic(Paths.image("menus/mainmenu/lightGlow"));
    lightGlow.scale.set(1.5, 1.5);
    lightGlow.updateHitbox();
    lightGlow.setPosition(lightThing.x + (lightThing.width / 2) - (lightGlow.width / 2), lightThing.y + (lightThing.height / 2) - (lightGlow.height / 2));
    lightGlow.blend = 0;
    lightGlow.camera = mainCam;

    lightLight = new FlxSprite(lightThing.x, lightThing.y).loadGraphic(Paths.image("menus/mainmenu/lightLight"));
    lightLight.scale.set(baseScale, baseScale);
    lightLight.updateHitbox();
    lightLight.camera = mainCam;
    lightLight.blend = 0;

    if (isMobile) {
        lightThing.color = 0xFF43A25A;
        lightGlow.color = 0xFF43A25A;
    }
    else if (discordIntegration) {
        discordUsername = new FunkinText(0, 0, 0, "", 32);
        discordUsername.borderSize = 4;
        discordUsername.font = Paths.font("pixeloidsans.ttf");
        discordUsername.camera = mainCam;
        add(discordUsername);

        if (DiscordUtil.ready) {
            lightThing.color = 0xFF43A25A;
            lightGlow.color = 0xFF43A25A;
            discordUsername.text = DiscordUtil.user.globalName;
            discordUsername.color = FlxColor.WHITE;
        }
        else {
            lightThing.color = 0xFF333333;
            lightGlow.color = 0xFF333333;
            lightGlow.visible = false;
            lightLight.visible = false;
            discordUsername.text = "Disconnected from Discord";
            discordUsername.color = FlxColor.GRAY;
        }

        discordUsername.fieldWidth = discordUsername.width + 40;
        discordUsername.alignment = "center";
        discordUsername.setPosition((lightThing.x + lightThing.width) + 2 * baseScale, topLeft.y + 5 * baseScale);
    }
    else {
        lightThing.color = 0xFF43A25A;
        lightGlow.color = 0xFF43A25A;
    }

    add(lightGlow);
    add(lightThing);
    add(lightLight);

    topButtonsGroup = new FlxSpriteGroup();
    topButtonsGroup.camera = mainCam;
    add(topButtonsGroup);

    var statsButton:FlxSprite = new FlxSprite(topRight.x + topRight.width, topLeft.y + topLeft.height);
    statsButton.loadGraphic(Paths.image("menus/mainmenu/statsButton"), true, 14, 14);
    statsButton.animation.add("idle", [0], 0, false);
    statsButton.animation.add("click", [1], 0, false);
    statsButton.scale.set(baseScale, baseScale);
    statsButton.updateHitbox();
    statsButton.x -= statsButton.width + 8 * baseScale;
    statsButton.y -= statsButton.height + 2 * baseScale;
    topButtonsGroup.add(statsButton);

    if (!isMobile) {
        var debugButton:FlxSprite;
        if (Options.devMode) {
            debugButton = new FlxSprite(statsButton.x - statsButton.width, statsButton.y);
            debugButton.loadGraphic(Paths.image("menus/mainmenu/debugButton"), true, 14, 14);
            debugButton.animation.add("idle", [0], 0, false);
            debugButton.animation.add("click", [1], 0, false);
            debugButton.scale.set(baseScale, baseScale);
            debugButton.updateHitbox();
            debugButton.x -= 4 * baseScale;
            topButtonsGroup.add(debugButton);
        }

        if (discordIntegration) {
            var xPos:Float = (debugButton != null) ? debugButton.x - debugButton.width : statsButton.x - statsButton.width;
            var yPos:Float = (debugButton != null) ? debugButton.y : statsButton.y;
            var discordButton:FlxSprite = new FlxSprite(xPos, yPos);
            discordButton.loadGraphic(Paths.image("menus/mainmenu/discordButton"), true, 14, 14);
            discordButton.animation.add("idle", [0], 0, false);
            discordButton.animation.add("click", [1], 0, false);
            discordButton.scale.set(baseScale, baseScale);
            discordButton.updateHitbox();
            discordButton.x -= 4 * baseScale;
            topButtonsGroup.add(discordButton);
        }
    }

    var title:FlxSprite = new FlxSprite(3 * baseScale, (topShadowL.y + topShadowL.height) + 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/title"));
    title.scale.set(baseScale, baseScale);
    title.updateHitbox();
    title.camera = mainCam;
    add(title);

    var buttonsBack:FlxSprite = new FlxSprite(2 * baseScale, (title.y + title.height) + 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/buttonsBack"));
    buttonsBack.scale.set(baseScale, baseScale);
    buttonsBack.updateHitbox();
    buttonsBack.camera = mainCam;

    var buttonsBackShadow:FlxSprite = new FlxSprite(buttonsBack.x - 1 * baseScale, buttonsBack.y + 3 * baseScale).loadGraphic(Paths.image("menus/mainmenu/buttonsBack-shadow"));
    buttonsBackShadow.scale.set(baseScale, baseScale);
    buttonsBackShadow.updateHitbox();
    buttonsBackShadow.blend = 9;
    buttonsBackShadow.camera = mainCam;

    add(buttonsBackShadow);
    add(buttonsBack);

    var divisionThing:FlxSprite = new FlxSprite(buttonsBack.x + 4 * baseScale, buttonsBack.y + 46 * baseScale).loadGraphic(Paths.image("menus/mainmenu/buttonsDivision"));
    divisionThing.scale.set(baseScale, baseScale);
    divisionThing.updateHitbox();
    divisionThing.camera = mainCam;
    add(divisionThing);

    var posH:Float = buttonsBack.x + 3 * baseScale;
    var posV:Float = buttonsBack.y + 3 * baseScale;
    buttonGroup = new FlxSpriteGroup(posH, posV);
    buttonGroup.camera = mainCam;
    add(buttonGroup);

    buttonsMainGroup = new FlxSpriteGroup();
    buttonGroup.add(buttonsMainGroup);

    buttonsLabelGroup = new FlxSpriteGroup();
    buttonGroup.add(buttonsLabelGroup);

    buttonsIconGroup = new FlxSpriteGroup();
    buttonGroup.add(buttonsIconGroup);

    createMainButtons(3 * baseScale, 3 * baseScale);
    createOtherButtons(3 * baseScale, (divisionThing.y - posV) + 3 * baseScale);
    createFinalButtons(3 * baseScale, posV + 9 * baseScale);

    var windowBorderLeft:FlxSprite = new FlxSprite((buttonsBack.x + buttonsBack.width) + 2 * baseScale, (topLeft.y + topLeft.height) + 3 * baseScale).loadGraphic(Paths.image("menus/mainmenu/windowBorder-left"));
    windowBorderLeft.scale.set(baseScale, baseScale);
    windowBorderLeft.updateHitbox();

    var windowBorderDistance:Int = FlxMath.distanceToPoint(windowBorderLeft, FlxPoint.get(FlxG.width, windowBorderLeft.y));
    var windowBorderMiddle:FlxSprite = new FlxSprite(windowBorderLeft.x + windowBorderLeft.width, windowBorderLeft.y).loadGraphic(Paths.image("menus/mainmenu/windowBorder-middle"));
    windowBorderMiddle.scale.set(windowBorderDistance, baseScale);
    windowBorderMiddle.updateHitbox();

    var windowBorderShadowL:FlxSprite = new FlxSprite(windowBorderLeft.x - 1 * baseScale, windowBorderLeft.y + 5 * baseScale).loadGraphic(Paths.image("menus/mainmenu/windowBorder-shadow-left"));
    windowBorderShadowL.scale.set(baseScale, baseScale);
    windowBorderShadowL.updateHitbox();
    windowBorderShadowL.blend = 9;

    var windowShadowDistance:Int = FlxMath.distanceToPoint(windowBorderShadowL, FlxPoint.get(FlxG.width, windowBorderShadowL.y));
    var windowBorderShadowM:FlxSprite = new FlxSprite(windowBorderShadowL.x + windowBorderShadowL.width, windowBorderShadowL.y).loadGraphic(Paths.image("menus/mainmenu/windowBorder-shadow-middle"));
    windowBorderShadowM.scale.set(windowShadowDistance, baseScale);
    windowBorderShadowM.updateHitbox();
    windowBorderShadowM.blend = 9;

    add(windowBorderShadowM);
    add(windowBorderShadowL);
    add(windowBorderMiddle);
    add(windowBorderLeft);

    var spaceHpos:Float = windowBorderLeft.x + 4 * baseScale;
    var spaceVpos:Float = windowBorderLeft.y + 4 * baseScale;
    var camWidth:Float = FlxG.width - spaceHpos;
    var camHeight:Float = 112 * baseScale - 4 * baseScale * 2;
    spaceCam = new FlxCamera(spaceHpos, spaceVpos, camWidth, camHeight);

    frontCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    frontCam.bgColor = 0x00000000;

    FlxG.cameras.add(spaceCam, false);
    FlxG.cameras.add(frontCam, true);

    var windowShine:FlxSprite = new FlxSprite(spaceCam.width, 4 * baseScale).loadGraphic(Paths.image("menus/mainmenu/window-shine"));
    windowShine.scale.set(baseScale, baseScale);
    windowShine.updateHitbox();
    windowShine.blend = 0;
    windowShine.alpha = 0.15;
    windowShine.x -= windowShine.width * (spaceCam.width / 760);
    windowShine.camera = spaceCam;
    add(windowShine);

    windowBorderLeft.camera = frontCam;
    windowBorderMiddle.camera = frontCam;
    windowBorderShadowL.camera = frontCam;
    windowBorderShadowM.camera = frontCam;

    spaceGroup = new FlxSpriteGroup();
    spaceGroup.camera = spaceCam;
    add(spaceGroup);

    var starField:PixelStars = new PixelStars(-20, 2, 2);
    starField.addStarsToGroup(spaceGroup);

    windowGroup = new FlxSpriteGroup();
    windowGroup.camera = spaceCam;
    add(windowGroup);

    var version:FunkinText = new FunkinText(buttonsBack.x, buttonsBack.y + buttonsBack.height + 2 * baseScale, buttonsBack.width, "VS IMPOSTOR Pixel v" + modVersion /*+ '\nCodename Version: ' + Main.releaseVersion*/, 18);
    version.font = Paths.font("pixeloidsans.ttf");
    version.alignment = "center";
    version.borderSize = 2;
    version.color = 0xFFBFBFBF; // lol
    version.camera = mainCam;
    add(version);
}

function createMainButtons(x:Float, y:Float) {
    for (i => button in mainButtons) {
        var yPos:Float = y + 13 * baseScale * i;

        var buttonSprite:FlxSprite = new FlxSprite(x, yPos);
        buttonSprite.loadGraphic(Paths.image("menus/mainmenu/mainButton"), true, 90, 12);
        buttonSprite.animation.add("idle", [0], 0, false);
        buttonSprite.animation.add("hover", [1], 0, false);
        buttonSprite.animation.add("blocked", [2], 0, false);
        buttonSprite.scale.set(baseScale, baseScale);
        buttonSprite.updateHitbox();
        buttonsMainGroup.add(buttonSprite);

        if (!button.available && !Options.devMode)
            buttonSprite.animation.play("blocked");

        var buttonLabel:FunkinText = new FunkinText(x, yPos + 8, buttonSprite.width, button.name, 32, false);
        buttonLabel.font = Paths.font("pixeloidsans.ttf");
        buttonLabel.color = button.colorIdle;
        buttonLabel.alignment = "right";
        buttonLabel.x -= 4 * baseScale;
        buttonsLabelGroup.add(buttonLabel);

        if (!button.available && !Options.devMode)
            buttonLabel.color = FlxColor.BLACK;

        var buttonIcon:FlxSprite = new FlxSprite(x + (buttonSprite.width / 6.5), yPos);
        buttonIcon.loadGraphic(button.icon);
        buttonIcon.scale.set(baseScale, baseScale);
        buttonIcon.updateHitbox();
        buttonIcon.x -= buttonIcon.width / 2;
        buttonsIconGroup.add(buttonIcon);

        if (!button.available && !Options.devMode) {
            buttonIcon.color = 0xFF888888;
            buttonIcon.shader = new CustomShader("grayscale");
            buttonIcon.shader._amount = 1;
        }

        allButtonsArray.push(button);
    }
}

function createOtherButtons(x:Float, y:Float) {
    for (i => button in otherButtons) {
        var yPos:Float = y + 10 * baseScale * i;

        var buttonSprite:FlxSprite = new FlxSprite(x, yPos);
        buttonSprite.loadGraphic(Paths.image("menus/mainmenu/otherButton"), true, 90, 9);
        buttonSprite.animation.add("idle", [0], 0, false);
        buttonSprite.animation.add("hover", [1], 0, false);
        buttonSprite.scale.set(baseScale, baseScale);
        buttonSprite.updateHitbox();
        buttonsMainGroup.add(buttonSprite);

        var buttonLabel:FunkinText = new FunkinText(x, yPos + 4, buttonSprite.width, button.name, 28, false);
        buttonLabel.font = Paths.font("pixeloidsans.ttf");
        buttonLabel.color = button.colorIdle;
        buttonLabel.alignment = "right";
        buttonLabel.x -= 8 * baseScale;
        buttonsLabelGroup.add(buttonLabel);

        if (!button.available && !Options.devMode)
            buttonLabel.color = FlxColor.BLACK;

        var buttonIcon:FlxSprite = new FlxSprite(x + (buttonSprite.width / 8), yPos);
        buttonIcon.loadGraphic(button.icon);
        buttonIcon.scale.set(baseScale, baseScale);
        buttonIcon.updateHitbox();
        buttonIcon.x -= buttonIcon.width / 2;
        buttonsIconGroup.add(buttonIcon);

        if (!button.available && !Options.devMode) {
            buttonIcon.color = 0xFF888888;
            buttonIcon.shader = new CustomShader("grayscale");
            buttonIcon.shader._amount = 1;
        }

        allButtonsArray.push(button);
    }
}

function createFinalButtons(x:Float, y:Float) {
    for (i => button in modButton) {
        var yPos:Float = y + 10 * baseScale * i;

        var buttonSprite:FlxSprite = new FlxSprite(x, yPos);
        buttonSprite.loadGraphic(Paths.image("menus/mainmenu/lonelyButton"), true, 53, 6);
        buttonSprite.animation.add("idle", [0], 0, false);
        buttonSprite.animation.add("hover", [1], 0, false);
        buttonSprite.scale.set(baseScale, baseScale);
        buttonSprite.updateHitbox();
        buttonsMainGroup.add(buttonSprite);

        var buttonLabel:FunkinText = new FunkinText(x, yPos - 2.4, buttonSprite.width, button.name, 25.5, false);
        buttonLabel.font = Paths.font("pixeloidsans.ttf");
        buttonLabel.color = button.colorIdle;
        buttonLabel.alignment = "right";
        buttonLabel.x -= 3 * baseScale;
        buttonsLabelGroup.add(buttonLabel);

        allButtonsArray.push(button);
    }
}

var backButton:BackButton;
function postCreate() {
    var backBtnScale:Float = isMobile ? 4 : 3;
    backButton = new BackButton(FlxG.width * 0.975, FlxG.height, goBack2Title, backBtnScale, false);
    backButton.camera = frontCam;
    backButton.visible = !usingKeyboard;
    backButton.x -= backButton.width;
    backButton.y -= backButton.height * 1.1;
    add(backButton);

    backButton.onConfirm.add(disableInput);

    FlxG.mouse.visible = !usingKeyboard;
    if (isMobile) FlxG.mouse.visible = false;
}

var checkTimer:Float = 0;
var checkLimit:Float = 5;
function update(elapsed:Float) {
    if (currentSelectionMode == "main") {
        handleMainButtons();
        handleTopButtons();
    }
    else if (currentSelectionMode == "window")
        handleWindow();

    handleKeyboard(elapsed);

    if (isMobile)
        handleTouch();
    else
        handleMouse();

    handlePointer();
}

function postUpdate(elapsed:Float) {
    if (storyStates[storySequence] == "postWeek1")
        floatSus();
}

// main, window
var currentSelectionMode:String = "main";

var curMainEntry:Int = 0;
var lastMainEntry:Int = -1;
var curWindowEntry:Array<Int> = [0, 0];
var lastWindowEntry:Array<Int> = [-1, -1];

var maxWindowEntries:Array<Array<Int>> = [0][0];
var curWindow:Array<Dynamic> = [];
var curWindowLogic:Void = null;
var curWindowChooseBehaviour:Void = null;

var allowKeyboard:Bool = true;
var usingKeyboard:Bool = globalUsingKeyboard;
var holdTimer:Float = 0;
var maxHeldTime:Float = 0.5;
var frameDelayer:Int = 0;
var maxDelay:Int = 2;
function handleKeyboard(elapsed:Float) {
    if (!allowKeyboard) return;

    if (currentSelectionMode == "main") {
        if (controls.UP_P)
            changeMainEntry(-1);
        if (controls.DOWN_P)
            changeMainEntry(1);

        if (controls.UP) {
            if (holdTimer >= maxHeldTime) {
                if (frameDelayer >= maxDelay) {
                    changeMainEntry(-1);
                    frameDelayer = 0;
                }
                else {
                    frameDelayer++;
                }
            }
            else
                holdTimer += elapsed;
        }
        else if (controls.DOWN) {
            if (holdTimer >= maxHeldTime)
                if (frameDelayer >= maxDelay) {
                    changeMainEntry(1);
                    frameDelayer = 0;
                }
                else {
                    frameDelayer++;
                }
            else
                holdTimer += elapsed;
        }
        else {
            frameDelayer = 0;
            holdTimer = 0;
        }

        if (!usingKeyboard) return;

        if (controls.SWITCHMOD)
            statsMenu();

        if (controls.ACCEPT)
            checkSelectedMainEntry();

        if (controls.BACK)
            goBack2Title();
    }
    else if (currentSelectionMode == "window") {
        if (controls.UP_P)
            changeWindowEntry(-1, 0);
        if (controls.DOWN_P)
            changeWindowEntry(1, 0);
        if (controls.LEFT_P)
            changeWindowEntry(0, -1);
        if (controls.RIGHT_P)
            changeWindowEntry(0, 1);

        if (!usingKeyboard) return;

        if (controls.ACCEPT)
            checkSelectedWindowEntry();

        if (controls.BACK) {
            closeWindowSection();
            currentSelectionMode = "main";
        }
    }
}

function useKeyboard() {
    usingKeyboard = true;
    backButton.visible = false;
    FlxG.mouse.visible = false;
}

var allowMouse:Bool = true;
function handleMouse() {
    if (!allowMouse) return;

    if (FlxG.mouse.justMoved) {
        usingKeyboard = false;
        holdTimer = 0;
        FlxG.mouse.visible = true;
        if (currentSelectionMode == "main") backButton.visible = true;
    }

    if (!FlxG.mouse.visible) return;
    if (usingKeyboard) return;

    if (isOverButton)
        Mouse.cursor = "button";
    else
        Mouse.cursor = "arrow";
}

var isTouchingButton:Bool = false;
var allowTouch:Bool = true;
function handleTouch() {
    if (!allowTouch) return;

    for (touch in FlxG.touches.list) {
        if (touch.justReleased) {
            usingKeyboard = false;
            if (currentSelectionMode == "main") backButton.visible = true;
        }
    }

    if (FlxG.onMobile) {
        if (FlxG.android.justReleased.BACK)
            goBack2Title();
    }
}

function handlePointer() {
    if (!allowTouch || !allowMouse) return;

    if (isOverButton) {
        if (currentSelectionMode == "main") {
            if (touchJustReleased())
                checkSelectedMainEntry();
        }
        else if (currentSelectionMode == "window") {
            if (touchJustReleased())
                checkSelectedWindowEntry();
        }
    }
    else {
        lastMainEntry = -1;
        lastWindowEntry[0] = -1;
        lastWindowEntry[1] = -1;
    }
}

var isOverButton:Bool = false;
function handleMainButtons() {
    if (usingKeyboard) {
        for (i in 0...buttonsTotalLength) {
            if (i == curMainEntry) {
                if (allButtonsArray[i].available || Options.devMode) {
                    buttonsMainGroup.members[i].animation.play("hover");
                    buttonsLabelGroup.members[i].color = allButtonsArray[i].colorHover;
                }
            }
            else {
                if (allButtonsArray[i].available || Options.devMode) {
                    buttonsMainGroup.members[i].animation.play("idle");
                    buttonsLabelGroup.members[i].color = allButtonsArray[i].colorIdle;
                }
            }
        }

        return;
    }

    isOverButton = false;

    if (!allowMouse || !allowTouch) return;

    if (currentSelectionMode == "main") {
        var i:Int = 0;
        buttonsMainGroup.forEach(function(button) {
            if (touchOverlaps(button)) {
                if (allButtonsArray[i].available || Options.devMode) {
                    isOverButton = true;
                    button.animation.play("hover");
                    buttonsLabelGroup.members[i].color = allButtonsArray[i].colorHover;

                    curMainEntry = i;
                    playSoundMain();
                }
            }
            else {
                if (allButtonsArray[i].available || Options.devMode) {
                    button.animation.play("idle");
                    buttonsLabelGroup.members[i].color = allButtonsArray[i].colorIdle;
                }
            }
            i++;
        });
    }
}

var connecting:Bool = false;
function handleTopButtons() {
    if (!allowMouse) return;
    if (currentSelectionMode != "main") return;

    topButtonsGroup.forEach(function(button) {
        if (touchOverlaps(button)) {
            if (connecting) return;

            if (touchIsHolding())
                button.animation.play("click");
            else
                button.animation.play("idle");

            if (touchJustReleased()) {
                if (button == topButtonsGroup.members[0])
                    statsMenu();
                if (button == topButtonsGroup.members[2]) {
                    playMenuSound("select", 1);
                    if (DiscordUtil.ready)
                        shutdownDiscordRPC();
                    else
                        initDiscordRPC();
                }
                else if (button == topButtonsGroup.members[1]) {
                    playMenuSound("select", 1);
                    openWindowSection('Developer Tools', debugOptions, function(posH, posV, group) {
                        var daHeight:Float = (spaceCam.height - posV - 4 * baseScale) / debugOptions.length;
                        var maxHeight:Float = 106;
                        for (c => column in debugOptions) {
                            var columnGroup = new FlxSpriteGroup(posH, posV + c * daHeight);
                            group.add(columnGroup);

                            for (row in column) {
                                var rowGroup = new FlxSpriteGroup();
                                columnGroup.add(rowGroup);

                                var bg:FlxSprite = new FlxSprite().makeGraphic(spaceCam.width, daHeight, FlxColor.WHITE);
                                bg.alpha = 0;
                                rowGroup.add(bg);

                                var toolLabel:FunkinText = new FunkinText(32 * baseScale, bg.height / 2, 0, row.name, 32);
                                toolLabel.font = Paths.font("pixeloidsans.ttf");
                                toolLabel.borderSize = 3;
                                toolLabel.y -= toolLabel.height / 2;

                                var toolIcon:FlxSprite = new FlxSprite(0, toolLabel.y + (toolLabel.height / 2)).loadGraphic(row.image);
                                toolIcon.scale.set(baseScale, baseScale);
                                toolIcon.updateHitbox();
                                toolIcon.x = 15 * baseScale - toolIcon.width / 2;

                                if (daHeight < maxHeight) {
                                    toolIcon.scale.y = baseScale * (daHeight / maxHeight);
                                    toolIcon.updateHitbox();
                                }

                                toolIcon.y -= toolIcon.height / 2;

                                rowGroup.add(toolIcon);
                                rowGroup.add(toolLabel);
                            }
                        }
                    }, function() {
                        isOverButton = false;

                        if (!allowMouse || !allowTouch) return;

                        var col:Int = 0;
                        windowGroup.forEach(function(column) {
                            if (column is FlxSpriteGroup) {
                                var rw:Int = 0;
                                column.forEach(function(row) {
                                    if (row.members[0].overlapsPoint(getTouch().getWorldPosition(spaceCam), true, spaceCam)) {
                                        row.members[0].alpha = 0.25;

                                        isOverButton = true;
                                        curWindowEntry[0] = col;
                                        curWindowEntry[1] = rw;
                                        playSoundWindow();
                                    }
                                    else
                                        row.members[0].alpha = 0;
                                    rw++;
                                });
                                col++;
                            }
                        });
                    }, function() {
                        playMenuSound("confirm");

                        if (curWindowEntry[1] == 0) {
                            var duration:Float = FlxG.save.data.impPixelFastMenus ? 0.5 : 1;
                            FlxFlicker.flicker(windowGroup.members[1 + curWindowEntry[0]].members[curWindowEntry[1]].members[1], duration, 0.05, true, true);
                            FlxFlicker.flicker(windowGroup.members[1 + curWindowEntry[0]].members[curWindowEntry[1]].members[2], duration, 0.05, true, true);

                            if (FlxG.sound.music != null) FlxG.sound.music.fadeOut();

                            new FlxTimer().start(duration, _ -> {
                                switch(curWindowEntry[0]) {
                                    case 0: FlxG.switchState(new CharterSelection());
                                    case 1: FlxG.switchState(new CharacterSelection());
                                    case 2: FlxG.switchState(new StageSelection());
                                    case 3:
                                        var state = new EditorTreeMenu();
                                        state.bgType = "charter";
                                        state.scriptName = "debug/weekSelector";
                                        FlxG.switchState(state);
                                    case 4: FlxG.switchState(new ModState("debug/mobileEmuInitializer"));
                                }
                            });
                        }
                    });
                }
            }
        }
        else
            button.animation.play("idle");
    });
}

function statsMenu() {
    playMenuSound("select", 1);
    openSubState(new ModSubState("statsMenuSubState"));
    persistentUpdate = persistentDraw = true;
}

function playSoundMain() {
    if (curMainEntry != lastMainEntry) {
        playMenuSound("scroll");
        lastMainEntry = curMainEntry;
    }
}

function playSoundWindow() {
    if (curWindowEntry[0] != lastWindowEntry[0] || curWindowEntry[1] != lastWindowEntry[1]) {
        playMenuSound("scroll");
        lastWindowEntry[0] = curWindowEntry[0];
        lastWindowEntry[1] = curWindowEntry[1];

        trace("Column Pos: "+curWindowEntry[0],"Row Pos: "+curWindowEntry[1]);
    }
}

function changeMainEntry(change:Int) {
    useKeyboard();
    curMainEntry = FlxMath.wrap(curMainEntry + change, 0, buttonsTotalLength - 1);

    if (!allButtonsArray[curMainEntry].available && !Options.devMode) {
        changeMainEntry(change);
        return;
    }

    playSoundMain();
}

function changeWindowEntry(changeColumn:Int, changeRow:Int) {
    useKeyboard();
    curWindowEntry[0] = FlxMath.wrap(curWindowEntry[0] + changeColumn, 0, curWindow.length - 1);
    curWindowEntry[1] = FlxMath.wrap(curWindowEntry[1] + changeRow, 0, curWindow[curWindowEntry[0]].length - 1);

    if (!curWindow[curWindowEntry[0]][curWindowEntry[1]].available) {
        changeWindowEntry(changeColumn, changeRow);
        return;
    }

    playSoundWindow();
}

function checkSelectedMainEntry() {
    playMenuSound("confirm");

    disableInput();

    FlxFlicker.flicker(buttonsMainGroup.members[curMainEntry], 1, 0.05, true, true);
    FlxFlicker.flicker(buttonsLabelGroup.members[curMainEntry], 1, 0.05, true, true);
    if (buttonsIconGroup.members[curMainEntry] != null) FlxFlicker.flicker(buttonsIconGroup.members[curMainEntry], 1, 0.05, true, true);

    switch(curMainEntry) {
        case 0: openWindowSection(translate("mainMenu.play"), playSectionButtons, function(posH, posV, group) {
                var centerX:Float = ((posH + (spaceCam.width - 4 * baseScale)) / 2) - 3 * baseScale;
                var thirdButtonYPos:Float = 0;
                for (c => column in playSectionButtons) {
                    var columnGroup = new FlxSpriteGroup(posH, posV);
                    group.add(columnGroup);

                    for (r => row in column) {
                        var rowGroup:FlxSpriteGroup = new FlxSpriteGroup();
                        columnGroup.add(rowGroup);

                        if (c == 0 && r == 0) {
                            var worldMapGroup:FlxSpriteGroup = new FlxSpriteGroup(centerX, 5 * baseScale);
                            worldMapGroup.x -= 28 * baseScale;
                            rowGroup.add(worldMapGroup);

                            var worldMapButton:FlxSprite = new FlxSprite().loadGraphic(row.image, true, 56, 55);
                            worldMapButton.animation.add("idle", [0], 0, false);
                            worldMapButton.animation.add("hover", [1], 0, false);
                            worldMapButton.scale.set(baseScale, baseScale);
                            worldMapButton.updateHitbox();
                            worldMapGroup.add(worldMapButton);

                            var worldMapTxt:FunkinText = new FunkinText(0.1 * baseScale, worldMapButton.height, worldMapButton.width * 2, row.name, 32, false);
                            worldMapTxt.font = Paths.font("pixeloidsans.ttf");
                            worldMapTxt.alignment = "center";
                            worldMapTxt.color = row.colorIdle;
                            worldMapTxt.x -= worldMapButton.width / 2;
                            worldMapTxt.y -= worldMapTxt.height + 2.6 * baseScale;
                            worldMapGroup.add(worldMapTxt);

                            worldMapGroup.x -= (worldMapButton.width / 2) - 1 * baseScale;

                            thirdButtonYPos = worldMapGroup.height;
                        }
                        else if (c == 0 && r == 1) {
                            var freeplayGroup:FlxSpriteGroup = new FlxSpriteGroup(centerX, 5 * baseScale);
                            freeplayGroup.x += 28 * baseScale;
                            rowGroup.add(freeplayGroup);

                            var freeplayButton:FlxSprite = new FlxSprite().loadGraphic(row.image, true, 56, 55);
                            freeplayButton.animation.add("idle", [0], 0, false);
                            freeplayButton.animation.add("hover", [1], 0, false);
                            freeplayButton.scale.set(baseScale, baseScale);
                            freeplayButton.updateHitbox();
                            freeplayGroup.add(freeplayButton);

                            var freeplayTxt:FunkinText = new FunkinText(0.1 * baseScale, freeplayButton.height, freeplayButton.width * 2, row.name, 32, false);
                            freeplayTxt.font = Paths.font("pixeloidsans.ttf");
                            freeplayTxt.alignment = "center";
                            freeplayTxt.color = row.colorIdle;
                            freeplayTxt.x -= freeplayButton.width / 2;
                            freeplayTxt.y -= freeplayTxt.height + 2.6 * baseScale;
                            freeplayGroup.add(freeplayTxt);

                            freeplayGroup.x -= (freeplayButton.width / 2) - 2 * baseScale;
                        }
                        else {
                            var howToPlayGroup:FlxSpriteGroup = new FlxSpriteGroup(centerX + 2, thirdButtonYPos + 6 * baseScale);
                            rowGroup.add(howToPlayGroup);

                            var howToPlayBtn:FlxSprite = new FlxSprite().loadGraphic(row.image, true, 66, 12);
                            howToPlayBtn.animation.add("idle", [0], 0, false);
                            howToPlayBtn.animation.add("hover", [1], 0, false);
                            howToPlayBtn.scale.set(baseScale, baseScale);
                            howToPlayBtn.updateHitbox();
                            howToPlayGroup.add(howToPlayBtn);

                            var howToPlayTxt:FunkinText = new FunkinText(0, howToPlayBtn.height, howToPlayBtn.width, row.name, 32, false);
                            howToPlayTxt.font = Paths.font("pixeloidsans.ttf");
                            howToPlayTxt.alignment = "center";
                            howToPlayTxt.color = row.colorIdle;
                            howToPlayTxt.y -= howToPlayTxt.height + 1.7 * baseScale;
                            howToPlayGroup.add(howToPlayTxt);

                            howToPlayGroup.x -= howToPlayGroup.width / 2;
                        }
                    }
                }
            }, function() {
                if (usingKeyboard) {
                    var col:Int = 0;
                    windowGroup.forEach(function(column) {
                        if (column is FlxSpriteGroup) {
                            var rw:Int = 0;
                            if (col == curWindowEntry[0]) {
                                column.forEach(function(row) {
                                    if (row is FlxSpriteGroup) {
                                        if (rw == curWindowEntry[1]) {
                                            row.forEach(function(grp) {
                                                grp.members[0].animation.play("hover");
                                                grp.members[1].color = curWindow[col][rw].colorHover;
                                            });
                                        }
                                        else {
                                            row.forEach(function(grp) {
                                                grp.members[0].animation.play("idle");
                                                grp.members[1].color = curWindow[col][rw].colorIdle;
                                            });
                                        }
                                        rw++;
                                    }
                                });
                            }
                            else {
                                column.forEach(function(row) {
                                    if (row is FlxSpriteGroup) {
                                        row.forEach(function(grp) {
                                            grp.members[0].animation.play("idle");
                                            grp.members[1].color = curWindow[col][rw].colorIdle;
                                        });
                                        rw++;
                                    }
                                });
                            }
                            col++;
                        }
                    });
                    return;
                }
                
                isOverButton = false;

                if (allowMouse || allowTouch) {
                    var col:Int = 0;
                    windowGroup.forEach(function(column) {
                        if (column is FlxSpriteGroup) {
                            var rw:Int = 0;
                            column.forEach(function(row) {
                                if (row is FlxSpriteGroup) {
                                    row.forEach(function(grp) {
                                        if (grp is FlxSpriteGroup) {
                                            if (grp.members[0].overlapsPoint(getTouch().getWorldPosition(spaceCam), true, spaceCam)) {
                                                grp.members[0].animation.play("hover");
                                                grp.members[1].color = curWindow[col][rw].colorHover;

                                                isOverButton = true;
                                                curWindowEntry[0] = col;
                                                curWindowEntry[1] = rw;
                                                playSoundWindow();
                                            }
                                            else {
                                                grp.members[0].animation.play("idle");
                                                grp.members[1].color = curWindow[col][rw].colorIdle;
                                            }
                                        }
                                    });
                                    rw++;
                                }
                            });
                            col++;
                        }
                    });
                }
            }, function() {
                playMenuSound("confirm");

                var col:Int = 0;
                windowGroup.forEach(function(column) {
                    if (column is FlxSpriteGroup) {
                        var rw:Int = 0;
                        if (col != curWindowEntry[0]) {
                            col++;
                            return;
                        }
                        else {
                            column.forEach(function(row) {
                                if (row is FlxSpriteGroup) {
                                    if (rw != curWindowEntry[1]) {
                                        rw++;
                                        return;
                                    }
                                    else {
                                        row.forEach(function(grp) {
                                            FlxFlicker.flicker(grp.members[0], 1, 0.05, true, true);
                                            FlxFlicker.flicker(grp.members[1], 1, 0.05, true, true);
                                        });
                                        rw++;
                                    }
                                }
                            });
                            col++;
                        }
                    }
                });

                new FlxTimer().start(1, _ -> {
                    switch(curWindowEntry[0]) {
                        case 0: switch(curWindowEntry[1]) {
                            case 0: FlxG.switchState(new ModState("worldmapState", ["lobby"]));
                            case 1: FlxG.switchState(new ModState("impostorFreeplayState"));
                        }
                        case 1: FlxG.switchState(new ModState("game/tutorialPlayState"));
                    }
                });
            });
        case 1:
            new FlxTimer().start(0.5, _ -> {
                setTransition("fade");
                FlxG.switchState(new ModState("impostorAchievementsState"));
            });
        case 2:
            new FlxTimer().start(0.5, _ -> {
                setTransition("fade");
                FlxG.switchState(new ModState("impostorShopState"));
            });
        case 3:
            openSubState(new ModSubState("options/impostorOptionsSubState"));
            persistentUpdate = persistentDraw = true;
        case 4: openWindowSection(translate("mainMenu.extras"), extrasSectionButtons, function(posH, posV, group) {
                var centerX:Float = ((posH + (spaceCam.width - 4 * baseScale)) / 2) - 3 * baseScale;
                var thirdButtonYPos:Float = 0;
                for (c => column in extrasSectionButtons) {
                    var columnGroup = new FlxSpriteGroup(posH, posV);
                    group.add(columnGroup);

                    for (r => row in column) {
                        var rowGroup:FlxSpriteGroup = new FlxSpriteGroup();
                        columnGroup.add(rowGroup);

                        if (r == 0) {
                            var creditsGroup:FlxSpriteGroup = new FlxSpriteGroup(centerX, 9 * baseScale);
                            creditsGroup.x -= 28 * baseScale;
                            rowGroup.add(creditsGroup);

                            var creditsBtn:FlxSprite = new FlxSprite().loadGraphic(row.image, true, 56, 55);
                            creditsBtn.animation.add("idle", [0], 0, false);
                            creditsBtn.animation.add("hover", [1], 0, false);
                            creditsBtn.scale.set(baseScale, baseScale);
                            creditsBtn.updateHitbox();
                            creditsGroup.add(creditsBtn);

                            var creditsTxt:FunkinText = new FunkinText(0.1 * baseScale, creditsBtn.height, creditsBtn.width * 2, row.name, 32, false);
                            creditsTxt.font = Paths.font("pixeloidsans.ttf");
                            creditsTxt.alignment = "center";
                            creditsTxt.color = row.colorIdle;
                            creditsTxt.x -= creditsBtn.width / 2;
                            creditsTxt.y -= creditsTxt.height + 2.6 * baseScale;
                            creditsGroup.add(creditsTxt);

                            creditsGroup.x -= (creditsBtn.width / 2) - 1 * baseScale;

                            thirdButtonYPos = creditsGroup.height;
                        }
                        else {
                            var movieGroup:FlxSpriteGroup = new FlxSpriteGroup(centerX, 9 * baseScale);
                            movieGroup.x += 28 * baseScale;
                            rowGroup.add(movieGroup);

                            var movieButton:FlxSprite = new FlxSprite().loadGraphic(row.image, true, 56, 55);
                            movieButton.animation.add("idle", [0], 0, false);
                            movieButton.animation.add("hover", [1], 0, false);
                            movieButton.animation.add("blocked", [2], 0, false);
                            movieButton.scale.set(baseScale, baseScale);
                            movieButton.updateHitbox();
                            movieGroup.add(movieButton);

                            var movieTxt:FunkinText = new FunkinText(11.5 * baseScale, movieButton.height, movieButton.width * 2, row.name, 32, false);
                            movieTxt.font = Paths.font("pixeloidsans.ttf");
                            movieTxt.alignment = "center";
                            movieTxt.color = row.colorIdle;
                            movieTxt.x -= movieButton.width / 2;
                            movieTxt.y -= movieTxt.height + 2.6 * baseScale;
                            movieTxt.scale.x = 0.8;
                            movieTxt.updateHitbox();
                            movieGroup.add(movieTxt);

                            if (!row.available) {
                                movieButton.animation.play("blocked");
                                movieTxt.color = FlxColor.BLACK;
                            }

                            movieGroup.x -= (movieButton.width / 2) - 2 * baseScale;
                        }
                    }
                }
            }, function() {
                if (usingKeyboard) {
                    var col:Int = 0;
                    windowGroup.forEach(function(column) {
                        if (column is FlxSpriteGroup) {
                            var rw:Int = 0;
                            if (col == curWindowEntry[0]) {
                                column.forEach(function(row) {
                                    if (row is FlxSpriteGroup) {
                                        if (rw == curWindowEntry[1]) {
                                            row.forEach(function(grp) {
                                                if (curWindow[col][rw].available) {
                                                    grp.members[0].animation.play("hover");
                                                    grp.members[1].color = curWindow[col][rw].colorHover;
                                                }
                                            });
                                        }
                                        else {
                                            row.forEach(function(grp) {
                                                if (curWindow[col][rw].available) {
                                                    grp.members[0].animation.play("idle");
                                                    grp.members[1].color = curWindow[col][rw].colorIdle;
                                                }
                                            });
                                        }
                                        rw++;
                                    }
                                });
                            }
                            else {
                                column.forEach(function(row) {
                                    if (row is FlxSpriteGroup) {
                                        row.forEach(function(grp) {
                                            if (curWindow[col][rw].available) {
                                                grp.members[0].animation.play("idle");
                                                grp.members[1].color = curWindow[col][rw].colorIdle;
                                            }
                                        });
                                        rw++;
                                    }
                                });
                            }
                            col++;
                        }
                    });
                    return;
                }

                isOverButton = false;

                if (allowMouse || allowTouch) {
                    var col:Int = 0;
                    windowGroup.forEach(function(column) {
                        if (column is FlxSpriteGroup) {
                            var rw:Int = 0;
                            column.forEach(function(row) {
                                if (row is FlxSpriteGroup) {
                                    row.forEach(function(grp) {
                                        if (grp is FlxSpriteGroup) {
                                            if (grp.members[0].overlapsPoint(getTouch().getWorldPosition(spaceCam), true, spaceCam)) {
                                                if (curWindow[col][rw].available) {
                                                    grp.members[0].animation.play("hover");
                                                    grp.members[1].color = curWindow[col][rw].colorHover;

                                                    isOverButton = true;
                                                    curWindowEntry[0] = col;
                                                    curWindowEntry[1] = rw;
                                                    playSoundWindow();
                                                }
                                            }
                                            else {
                                                if (curWindow[col][rw].available) {
                                                    grp.members[0].animation.play("idle");
                                                    grp.members[1].color = curWindow[col][rw].colorIdle;
                                                }
                                            }
                                        }
                                    });
                                    rw++;
                                }
                            });
                            col++;
                        }
                    });
                }
            }, function() {
                playMenuSound("confirm");

                var col:Int = 0;
                windowGroup.forEach(function(column) {
                    if (column is FlxSpriteGroup) {
                        var rw:Int = 0;
                        if (col != curWindowEntry[0]) {
                            col++;
                            return;
                        }
                        else {
                            column.forEach(function(row) {
                                if (row is FlxSpriteGroup) {
                                    if (rw != curWindowEntry[1]) {
                                        rw++;
                                        return;
                                    }
                                    else {
                                        row.forEach(function(grp) {
                                            FlxFlicker.flicker(grp.members[0], 1, 0.05, true, true);
                                            FlxFlicker.flicker(grp.members[1], 1, 0.05, true, true);
                                        });
                                        rw++;
                                    }
                                }
                            });
                            col++;
                        }
                    }
                });

                switch(curWindowEntry[0]) {
                    case 0: switch(curWindowEntry[1]) {
                        case 0:
                            new FlxTimer().start(0.5, _ -> {
                                FlxG.switchState(new ModState("impostorCreditsState"));
                            });
                        case 1:
                            new FlxTimer().start(1, _ -> {
                                FlxG.switchState(new ModState("movieTheaterState"));
                            });
                    }
                }
                new FlxTimer().start(1, _ -> {
                    switch(curWindowEntry[0]) {
                        case 0: switch(curWindowEntry[1]) {
                            case 0: FlxG.switchState(new ModState("impostorCreditsState"));
                            case 1: FlxG.switchState(new ModState("movieTheaterState"));
                        }
                    }
                });
            });
        case 5:
            modsArray = [];
            var mods:Array<String> = [];
            mods = ModsFolder.getModsList();
            mods.push(null);
            for (i => mod in mods) {
                modsArray[i] = [];
                modsArray[i][0] = mod;
            }
            openWindowSection(translate("mainMenu.mods"), modsArray, function(posH, posV, group) {
                var daHeight:Float = (spaceCam.height - posV - 4 * baseScale) / modsArray.length;
                for (c => column in modsArray) {
                    var columnGroup = new FlxSpriteGroup(posH, posV + c * daHeight);
                    group.add(columnGroup);

                    for (row in column) {
                        var rowGroup = new FlxSpriteGroup();
                        columnGroup.add(rowGroup);

                        var bg:FlxSprite = new FlxSprite().makeGraphic(spaceCam.width, daHeight, FlxColor.WHITE);
                        bg.color = (row == null) ? FlxColor.RED : FlxColor.WHITE;
                        bg.alpha = 0;
                        rowGroup.add(bg);

                        var daMod:FunkinText = new FunkinText(4 * baseScale, bg.height / 2, 0, (row == null) ? translate("mods.disableMods") : row, 28);
                        daMod.font = Paths.font("retrogaming.ttf");
                        daMod.borderSize = 3;
                        if (daHeight < 30) {
                            daMod.scale.y = daHeight / 30;
                            daMod.updateHitbox();
                        }
                        daMod.y -= daMod.height / 2;
                        rowGroup.add(daMod);
                    }
                }
            }, function() {
                if (usingKeyboard) {
                    var col:Int = 0;
                    windowGroup.forEach(function(column) {
                        if (column is FlxSpriteGroup) {
                            var rw:Int = 0;
                            if (col == curWindowEntry[0]) {
                                column.forEach(function(row) {
                                    if (rw == curWindowEntry[1])
                                        row.members[0].alpha = 0.25;
                                    rw++;
                                });
                            }
                            else {
                                column.forEach(function(row) {
                                    row.members[0].alpha = 0;
                                    rw++;
                                });
                            }
                            col++;
                        }
                    });
                    return;
                }

                isOverButton = false;

                if (allowMouse || allowTouch) {
                    var col:Int = 0;
                    windowGroup.forEach(function(column) {
                        if (column is FlxSpriteGroup) {
                            var rw:Int = 0;
                            column.forEach(function(row) {
                                if (row.members[0].overlapsPoint(getTouch().getWorldPosition(spaceCam), true, spaceCam)) {
                                    row.members[0].alpha = 0.25;

                                    isOverButton = true;
                                    curWindowEntry[0] = col;
                                    curWindowEntry[1] = rw;
                                    playSoundWindow();
                                }
                                else
                                    row.members[0].alpha = 0;
                                rw++;
                            });
                            col++;
                        }
                    });
                }
            }, function() {
                playMenuSound("cancel");

                if (FlxG.sound.music != null) FlxG.sound.music.fadeOut();

                setTransition("slowFade");
                ModsFolder.switchMod(curWindow[curWindowEntry[0]][0]);
            });
    }
}

function openWindowSection(title:String, windowArray:Array<Array<Dynamic>>, membersCreation:Float->Float->FlxSpriteGroup->Void, updateLogic:Void, onChoose:Void) {
    currentSelectionMode = "window";
    curWindow = windowArray;
    curWindowLogic = updateLogic;
    curWindowChooseBehaviour = onChoose;

    backButton.visible = false;

    var correctCornerPos:Float = 4 * baseScale;

    var bg:FlxSprite = new FlxSprite().makeGraphic(spaceCam.width, spaceCam.height, 0xFF404040);
    bg.alpha = 0.7;
    windowGroup.add(bg);

    var titleSpr:FunkinText = new FunkinText(spaceCam.width, correctCornerPos + 2 * baseScale, 0, title, 48);
    titleSpr.font = Paths.font("pixeloidsans.ttf");
    titleSpr.alignment = "center";
    titleSpr.borderSize = 5;
    titleSpr.x -= titleSpr.width + 8 * baseScale;
    titleSpr.fieldWidth = titleSpr.width + 40;

    var xButton:BackButton = new BackButton(correctCornerPos + 2 * baseScale, correctCornerPos, () -> closeWindowSection(), baseScale, false, "menus/x", true);

    var divisionWidth:Float = spaceCam.width - correctCornerPos - 4 * baseScale;
    var division:FlxSprite = new FlxSprite(correctCornerPos + 2 * baseScale, xButton.y + xButton.height).makeGraphic(Std.int(divisionWidth), baseScale, FlxColor.WHITE);
    division.y += 2;

    membersCreation(correctCornerPos, division.y + division.height, windowGroup);

    windowGroup.add(division);
    windowGroup.add(titleSpr);
    windowGroup.add(xButton);

    enableInput();
    FlxG.mouse.visible = !usingKeyboard;
}

function handleWindow() {
    curWindowLogic();
}

function closeWindowSection() {
    playMenuSound("cancel");
    currentSelectionMode = "main";
    curWindow = [];
    curWindowLogic = null;
    curWindowEntry[0] = 0;
    curWindowEntry[1] = 0;
    lastWindowEntry[0] = -1;
    lastWindowEntry[1] = -1;

    if (!usingKeyboard)
        backButton.visible = true;

    windowGroup.forEach(function(spr) {
        spr.destroy();
    });
    windowGroup.clear();
}

function checkSelectedWindowEntry() {
    if (curWindow == null) return;

    disableInput();

    var trans:String = "";
    try {
        trans = curWindow[curWindowEntry[0]][curWindowEntry[1]].transition;
    }
    catch(e:Dynamic) {
        trans = "closingSharpCircle";
    }

    setTransition(trans);
    curWindowChooseBehaviour();
}

function floatSus() {}

function shutdownDiscordRPC() {
    DiscordUtil.shutdown();
    DiscordUtil.ready = false;
    updateDiscordUserStatus(false);
}

function initDiscordRPC() {
    DiscordUtil.currentID = "-1";
    DiscordUtil.init();
    discordUsername.fieldWidth = 0;
    discordUsername.text = "Connecting to Discord...";
    discordUsername.color = FlxColor.GRAY;
    discordUsername.fieldWidth = discordUsername.width + 40;

    connecting = true;
    new FlxTimer().start(5, _ -> {
        connecting = false;
        updateDiscordUserStatus(true);
    });
}

var userCurrentStatus:String = "";
function updateDiscordUserStatus(fetchInfo:Bool) {
    if (fetchInfo && DiscordUtil.ready) {
        changeDiscordMenuStatus("Main Menu");

        try {
            discordAvatar.loadGraphic(DiscordUtil.user.getAvatar(64));
        }
        catch (e:Dynamic) {
            discordAvatar.loadGraphic(Paths.image("menus/mainmenu/nullAvatar"));
        }
        discordUsername.fieldWidth = 0;
        discordUsername.text = DiscordUtil.user.globalName;
        discordUsername.color = FlxColor.WHITE;
        discordUsername.fieldWidth = discordUsername.width + 40;
        lightThing.color = 0xFF43A25A;
        lightGlow.color = 0xFF43A25A;
        lightGlow.visible = true;
        lightLight.visible = true;
    }
    else {
        discordAvatar.loadGraphic(Paths.image("menus/mainmenu/nullAvatar"));
        discordUsername.fieldWidth = 0;
        discordUsername.text = "Disconnected from Discord";
        discordUsername.color = FlxColor.GRAY;
        discordUsername.fieldWidth = discordUsername.width + 40;
        lightThing.color = 0xFF333333;
        lightGlow.color = 0xFF333333;
        lightGlow.visible = false;
        lightLight.visible = false;
    }
}

function onOpenSubState(event) {
    disableInput();
}

function onCloseSubstate() {
    changeDiscordMenuStatus("Main Menu");
    enableInput();
}

function enableInput() {
    allowMouse = true;
    allowKeyboard = true;
    allowTouch = true;
    backButton.enabled = true;
}

function disableInput() {
    allowMouse = false;
    allowKeyboard = false;
    allowTouch = false;
    backButton.enabled = false;
    FlxG.mouse.visible = false;
    Mouse.cursor = "arrow";
}

function goBack2Title() {
    setTransition("bottom2topSmoothSquare");
    FlxG.switchState(new ModState("impostorTitleState"));
}

function destroy() {
    buttonGroup.destroy();
    buttonsMainGroup.destroy();
    buttonsLabelGroup.destroy();
    buttonsIconGroup.destroy();
    topButtonsGroup.destroy();

    // discord stuff
    if (discordIntegration) {
        discordAvatar.destroy();
        discordUsername.destroy();

        lightThing.destroy();
        lightGlow.destroy();
        lightLight.destroy();
    }

    spaceGroup.destroy();
    windowGroup.destroy();

    backButton.destroy();

    FlxG.cameras.remove(mainCam);
    FlxG.cameras.remove(spaceCam);
    FlxG.cameras.remove(frontCam);

    mainCam.destroy();
    spaceCam.destroy();
    frontCam.destroy();
}