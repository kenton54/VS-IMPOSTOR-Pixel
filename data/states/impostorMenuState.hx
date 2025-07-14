import flixel.effects.FlxFlicker;
import flixel.group.FlxTypedSpriteGroup;
import flixel.ui.FlxButton;
import funkin.backend.utils.DiscordUtil;
//import funkin.backend.utils.HttpUtil;
import funkin.editors.EditorPicker;
import funkin.menus.credits.CreditsMain;
import funkin.menus.ModSwitchMenu;
//import sys.net.Socket;
//import sys.Http;
import PixelStars;
import openfl.filters.ShaderFilter;
import openfl.ui.Mouse;
importScript("data/variables");

var modVersion:String = "0.0.0";

var discordAvatar:FlxSprite;
var discordUsername:FunkinText;

var lightThing:FlxSprite;
var lightGlow:FlxSprite;

var mainButtons:Array<Dynamic> = [
    {
        name: "Play",
        available: true,
        icon: Paths.image("menus/mainmenu/icons/play"),
        colorIdle: 0xFF0A3C33,
        colorHover: 0xFF10584B
    },
    {
        name: "Achievements",
        available: true,
        icon: Paths.image("menus/mainmenu/icons/achievements"),
        colorIdle: 0xFF0A3C33,
        colorHover: 0xFF10584B
    },
    {
        name: "Shop",
        available: true,
        icon: Paths.image("menus/mainmenu/icons/shop"),
        colorIdle: 0xFF0A3C33,
        colorHover: 0xFF10584B
    }
];
var otherButtons:Array<Dynamic> = [
    {
        name: "Options",
        available: true,
        icon: Paths.image("menus/mainmenu/icons/options"),
        colorIdle: 0xFFAAE2DC,
        colorHover: 0xFFFFFFFF
    },
    {
        name: "Credits",
        available: (storyState[storySequence] == "start") ? false : true,
        icon: Paths.image("menus/mainmenu/icons/credits"),
        colorIdle: 0xFFAAE2DC,
        colorHover: 0xFFFFFFFF
    }
];
var modButton:Array<Dynamic> = [
    {
        name: "Mods",
        available: true,
        colorIdle: 0xFFFFFFFF,
        colorHover: 0xFFFFFFFF
    }
];

var allButtonsArray:Array<Dynamic> = [];
var buttonsTotalLength:Int = mainButtons.length + otherButtons.length;
var buttonGroup:FlxTypedSpriteGroup;
var buttonsMainGroup:FlxTypedSpriteGroup;
var buttonsLabelGroup:FlxTypedSpriteGroup;
var buttonsIconGroup:FlxTypedSpriteGroup;

var playSectionButtons:Array<Dynamic> = [
    {
        name: "World Map",
        available: true,
        image: Paths.image("menus/mainmenu/playSec/story"),
        colorIdle: 0xFF0A3C33,
        colorHover: 0xFF10584B
    },
    {
        name: "Freeplay",
        available: (storyState[storySequence] == "start") ? false : true,
        icon: Paths.image("menus/mainmenu/playSec/freeplay" + pixelPlayable),
        colorIdle: 0xFF0A3C33,
        colorHover: 0xFF10584B
    }
];

var topButtonsGroup:FlxTypedSpriteGroup;

var mainCam:FlxCamera;
var spaceCam:FlxCamera;
var spaceGroup:FlxTypedSpriteGroup;

var baseScale:Float = 5;

var curEntry:Int = 0;
static var lastEntry:Int = -1;

function create() {
    DiscordUtil.call("onMenuLoaded", ["Main Menu"]);

    DiscordUtil.init();

    mainCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    mainCam.bgColor = 0x00000000;
    FlxG.cameras.add(mainCam, true);

    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/mainmenu/bg"));
    bg.scale.set(baseScale, baseScale);
    bg.updateHitbox();
    bg.camera = mainCam;
    add(bg);

    var top:FlxSprite = new FlxSprite(3 * baseScale, 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/top"));
    top.scale.set(baseScale, baseScale);
    top.updateHitbox();
    top.camera = mainCam;
    add(top);

    var topShadow:FlxSprite = new FlxSprite(3 * baseScale, (top.y + top.height) - 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/top-shadow"));
    topShadow.scale.set(baseScale, baseScale);
    topShadow.updateHitbox();
    topShadow.blend = 9;
    topShadow.camera = mainCam;
    add(topShadow);

    discordAvatar = new FlxSprite(dcAvatarBounds.x, dcAvatarBounds.y);

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

    lightThing = new FlxSprite(top.x + 26 * baseScale, top.y + 4 * baseScale).loadGraphic(Paths.image("menus/mainmenu/lightThing"));
    lightThing.scale.set(baseScale, baseScale);
    lightThing.camera = mainCam;
    lightThing.updateHitbox();

    lightGlow = new FlxSprite(lightThing.x - 7 * baseScale, lightThing.y - 7 * baseScale).loadGraphic(Paths.image("menus/mainmenu/lightGlow"));
    lightGlow.scale.set(baseScale, baseScale);
    lightGlow.updateHitbox();
    lightGlow.blend = 0;
    lightGlow.camera = mainCam;

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
        discordUsername.text = "Disconnected from Discord";
        discordUsername.color = FlxColor.GRAY;
    }

    discordUsername.fieldWidth = discordUsername.width + 40;
    discordUsername.alignment = "center";
    discordUsername.setPosition((lightThing.x + lightThing.width) + 2 * baseScale, top.y + 5 * baseScale);

    add(lightGlow);
    add(lightThing);

    topButtonsGroup = new FlxTypedSpriteGroup();
    topButtonsGroup.camera = mainCam;
    add(topButtonsGroup);

    var discordButton:FlxSprite = new FlxSprite(top.x + top.width, top.y + top.height);
    discordButton.loadGraphic(Paths.image("menus/mainmenu/discordButton"), true, 14, 14);
    discordButton.animation.add("idle", [0], 0, false);
    discordButton.animation.add("click", [1], 0, false);
    discordButton.scale.set(baseScale, baseScale);
    discordButton.updateHitbox();
    discordButton.x -= discordButton.width + 8 * baseScale;
    discordButton.y -= discordButton.height + 2 * baseScale;
    topButtonsGroup.add(discordButton);

    var title:FlxSprite = new FlxSprite(3 * baseScale, (topShadow.y + topShadow.height) + 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/title"));
    title.scale.set(baseScale, baseScale);
    title.updateHitbox();
    title.camera = mainCam;
    add(title);

    var buttonsBack:FlxSprite = new FlxSprite(2 * baseScale, (title.y + title.height) + 2 * baseScale).loadGraphic(Paths.image("menus/mainmenu/buttonsBack"));
    buttonsBack.scale.set(baseScale, baseScale);
    buttonsBack.updateHitbox();
    buttonsBack.camera = mainCam;
    add(buttonsBack);

    var buttonsBackShadow:FlxSprite = new FlxSprite(buttonsBack.x - 1 * baseScale, buttonsBack.y + 3 * baseScale).loadGraphic(Paths.image("menus/mainmenu/buttonsBack-shadow"));
    buttonsBackShadow.scale.set(baseScale, baseScale);
    buttonsBackShadow.updateHitbox();
    buttonsBackShadow.blend = 9;
    buttonsBackShadow.camera = mainCam;
    add(buttonsBackShadow);

    var divisionThing:FlxSprite = new FlxSprite(buttonsBack.x + 4 * baseScale, buttonsBack.y + 46 * baseScale).loadGraphic(Paths.image("menus/mainmenu/buttonsDivision"));
    divisionThing.scale.set(baseScale, baseScale);
    divisionThing.updateHitbox();
    divisionThing.camera = mainCam;
    add(divisionThing);

    var posH:Float = buttonsBack.x + 3 * baseScale;
    var posV:Float = buttonsBack.y + 3 * baseScale;
    buttonGroup = new FlxTypedSpriteGroup(posH, posV);
    buttonGroup.camera = mainCam;
    add(buttonGroup);

    buttonsMainGroup = new FlxTypedSpriteGroup();
    buttonGroup.add(buttonsMainGroup);

    buttonsLabelGroup = new FlxTypedSpriteGroup();
    buttonGroup.add(buttonsLabelGroup);

    buttonsIconGroup = new FlxTypedSpriteGroup();
    buttonGroup.add(buttonsIconGroup);

    createMainButtons(3 * baseScale, 3 * baseScale);
    createOtherButtons(3 * baseScale, (divisionThing.y - posV) + 3 * baseScale);
    createFinalButtons(3 * baseScale, posV + 9 * baseScale);

    var windowBorder:FlxSprite = new FlxSprite((buttonsBack.x + buttonsBack.width) + 2 * baseScale, (top.y + top.height) + 3 * baseScale).loadGraphic(Paths.image("menus/mainmenu/windowBorder"));
    windowBorder.scale.set(baseScale, baseScale);
    windowBorder.updateHitbox();
    windowBorder.camera = mainCam;
    add(windowBorder);

    var windowBorderShadow:FlxSprite = new FlxSprite(windowBorder.x - 1 * baseScale, windowBorder.y + 5 * baseScale).loadGraphic(Paths.image("menus/mainmenu/windowBorder-shadow"));
    windowBorderShadow.scale.set(baseScale, baseScale);
    windowBorderShadow.updateHitbox();
    windowBorderShadow.blend = 9;
    windowBorderShadow.camera = mainCam;
    add(windowBorderShadow);

    var spaceHpos:Float = windowBorder.x + 4 * baseScale;
    var spaceVpos:Float = windowBorder.y + 4 * baseScale;
    var camWidth:Float = 150 * baseScale - 4 * baseScale;
    var camHeight:Float = 112 * baseScale - 4 * baseScale * 2;
    spaceCam = new FlxCamera(spaceHpos, spaceVpos, camWidth, camHeight);

    var frontCam:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    frontCam.bgColor = 0x00000000;

    FlxG.cameras.add(spaceCam, false);
    FlxG.cameras.add(frontCam, true);

    windowBorder.camera = frontCam;
    windowBorderShadow.camera = frontCam;

    spaceGroup = new FlxTypedSpriteGroup();
    spaceGroup.camera = spaceCam;

    add(spaceGroup);

    var starField:PixelStars = new PixelStars(-20, 2, 2);
    starField.addStarsToGroup(spaceGroup);

    var version:FunkinText = new FunkinText(buttonsBack.x, buttonsBack.y + buttonsBack.height + 2 * baseScale, buttonsBack.width, "Mod Version: " + modVersion/* + '\nCodename Version: ' + Main.releaseVersion*/, 18);
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
        buttonSprite.scale.set(baseScale, baseScale);
        buttonSprite.updateHitbox();
        buttonsMainGroup.add(buttonSprite);

        var buttonLabel:FunkinText = new FunkinText(x, yPos + 8, buttonSprite.width, button.name, 32, false);
        buttonLabel.font = Paths.font("pixeloidsans.ttf");
        buttonLabel.color = button.colorIdle;
        buttonLabel.alignment = "right";
        buttonLabel.x -= 4 * baseScale;
        buttonsLabelGroup.add(buttonLabel);

        var buttonIcon:FlxSprite = new FlxSprite(x + (buttonSprite.width / 6.5), yPos);
        buttonIcon.loadGraphic(button.icon);
        buttonIcon.scale.set(baseScale, baseScale);
        buttonIcon.updateHitbox();
        buttonIcon.x -= buttonIcon.width / 2;
        buttonsIconGroup.add(buttonIcon);

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

        var buttonIcon:FlxSprite = new FlxSprite(x + (buttonSprite.width / 8), yPos);
        buttonIcon.loadGraphic(button.icon);
        buttonIcon.scale.set(baseScale, baseScale);
        buttonIcon.updateHitbox();
        buttonIcon.x -= buttonIcon.width / 2;
        buttonsIconGroup.add(buttonIcon);

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

        var buttonLabel:FunkinText = new FunkinText(x, yPos + 0.2, buttonSprite.width, button.name, 20, false);
        buttonLabel.font = Paths.font("pixeloidsans.ttf");
        buttonLabel.color = button.colorIdle;
        buttonLabel.alignment = "right";
        buttonLabel.x -= 3 * baseScale;
        buttonsLabelGroup.add(buttonLabel);

        allButtonsArray.push(button);
    }
}

var checkTimer:Float = 0;
var checkLimit:Float = 5;
function update(elapsed:Float) {
    handleInput();
    handleMouse();
    handleMainButtons();
    handleTopButtons();

    /*
    if (checkTimer >= checkLimit) {
        updateDiscordUserStatus();
    }

    checkTimer += elapsed;
    if (checkTimer > checkLimit + 0.025) checkTimer = 0;
    */
}

function handleMouse() {
    if (FlxG.mouse.justMoved) {
        if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
    }

    if (!FlxG.mouse.visible) return;

    if (mouseIsOverABtn) {
        Mouse.cursor = "button";
    }
    else {
        lastEntry = -1;
        Mouse.cursor = "arrow";
    }
}

function handleInput() {
    if (controls.ACCEPT || mouseIsOverABtn && FlxG.mouse.justPressed) {
        checkSelectedEntry();
    }

    if (FlxG.keys.justPressed.SEVEN) {
		openSubState(new EditorPicker());
        persistentUpdate = !(persistentDraw = true);
	}

    if (controls.BACK) {
        FlxG.switchState(new ModState("impostorTitleState"));
    }

    if (controls.SWITCHMOD) {
        openSubState(new ModSwitchMenu());
        persistentUpdate = !(persistentDraw = true);
    }
}

var mouseIsOverABtn:Bool = false;
function handleMainButtons() {
    mouseIsOverABtn = false;

    if (!FlxG.mouse.visible) return;

    var i:Int = 0;
    buttonsMainGroup.forEach(function(button) {
        if (FlxG.mouse.overlaps(button)) {
            mouseIsOverABtn = true;
            button.animation.play("hover");

            buttonsLabelGroup.members[i].color = allButtonsArray[i].colorHover;

            curEntry = buttonsLabelGroup.members.indexOf(buttonsLabelGroup.members[i]);

            playSound();
        }
        else {
            button.animation.play("idle");
            buttonsLabelGroup.members[i].color = allButtonsArray[i].colorIdle;
        }
        i++;
    });
}

var connecting:Bool = false;
function handleTopButtons() {
    topButtonsGroup.forEach(function(button) {
        if (FlxG.mouse.overlaps(button)) {
            if (connecting) return;

            if (FlxG.mouse.pressed) {
                button.animation.play("click");
            }
            else {
                button.animation.play("idle");
            }

            if (FlxG.mouse.justReleased) {
                if (button == topButtonsGroup.members[0]) {
                    if (DiscordUtil.ready) {
                        shutdownDiscordRPC();
                    }
                    else {
                        initDiscordRPC();
                    }
                }
            }
        }
        else {
            button.animation.play("idle");
        }
    });
}

function playSound() {
    if (curEntry != lastEntry) {
        CoolUtil.playMenuSFX(0);
        lastEntry = curEntry;
    }
}

function checkSelectedEntry() {
    trace("current entry id: "+curEntry);

    CoolUtil.playMenuSFX(1);
    FlxFlicker.flicker(buttonsMainGroup.members[curEntry], 1, 0.05, true, true);
    FlxFlicker.flicker(buttonsLabelGroup.members[curEntry], 1, 0.05, true, true);
    if (buttonsIconGroup.members[curEntry] != null) FlxFlicker.flicker(buttonsIconGroup.members[curEntry], 1, 0.05, true, true);
}

function openPlaySection() {}

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
        DiscordUtil.call("onMenuLoaded", ["Main Menu"]);

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
    }
}