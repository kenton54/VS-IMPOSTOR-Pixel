import flixel.util.FlxStringUtil;
import AmongUsBox;

// the only reason these are here is becuz maps fuck up the order
var stats:Array<String> = [
    "storyProgress",
    "totalNotes",
    "perfectNotes",
    "sickNotes",
    "goodNotes",
    "badNotes",
    "shitNotes",
    "missedNotes",
    "combosBroken",
    "attacksDodged",
    "taskSpeedrunSkeld",
    "taskSpeedrunMira",
    "taskSpeedrunPolus",
    "taskSpeedrunAirship",
    "totalTasks"
];

var statsCam:FlxCamera;

var buttonsBack:AmongUsBox;
var closeButton:FlxSprite;

function create() {
    changeDiscordMenuStatus("Viewing his Stats");

    statsCam = new FlxCamera();
    statsCam.bgColor = 0x80000000;
    FlxG.cameras.add(statsCam, false);

    var scale:Float = 4;
    buttonsBack = new AmongUsBox(0, 0, 640, 640, "fancy", scale);
    buttonsBack.box.screenCenter();
    buttonsBack.box.camera = statsCam;
    add(buttonsBack.box);

    var statsTitle:FunkinText = new FunkinText(buttonsBack.box.x, buttonsBack.box.y, buttonsBack.box.width, translate("mainMenu.stats.title"), 48);
    statsTitle.font = Paths.font("pixeloidsans.ttf");
    statsTitle.alignment = "center";
    statsTitle.camera = statsCam;
    statsTitle.y += 8 * scale;
    add(statsTitle);

    for (i => stat in stats) {
        var yPos:Float = (statsTitle.y + statsTitle.height) + (3 * scale) + (i * 22);
        var color:FlxColor = (i % 2 == 0) ? FlxColor.WHITE : 0xFF999999;
        var daStat:FunkinText = new FunkinText(statsTitle.x + 8 * scale, yPos, buttonsBack.width, getStatName(stat), 22, false);
        daStat.font = Paths.font("retrogaming.ttf");
        daStat.color = color;
        daStat.camera = statsCam;
        add(daStat);

        var value:Dynamic = getStatValue(stat);
        if (StringTools.contains(stat, "storyProgress")) value = '"'+value+'"';
        if (StringTools.contains(stat, "Speedrun")) value = FlxStringUtil.formatTime(value, true);
        var statValue:FunkinText = new FunkinText(statsTitle.x + 4 * scale, yPos, buttonsBack.width, Std.string(value), 22, false);
        statValue.alignment = "right";
        statValue.font = Paths.font("retrogaming.ttf");
        statValue.color = color;
        statValue.camera = statsCam;
        add(statValue);
    }

    closeButton = new FlxSprite(buttonsBack.box.x, buttonsBack.box.y).loadGraphic(Paths.image("menus/mainmenu/x"));
    closeButton.scale.set(scale, scale);
    closeButton.updateHitbox();
    closeButton.x -= closeButton.width + 2 * scale;
    closeButton.camera = statsCam;
    add(closeButton);
}

function postCreate() {
    if (!isMobile) FlxG.mouse.visible = true;
}

function update(elapsed:Float) {
    if (controls.BACK || (!isMobile ? (FlxG.mouse.overlaps(closeButton) && FlxG.mouse.justPressed) : (FlxG.touches.getFirst() != null && FlxG.touches.getFirst().overlaps(closeButton) && FlxG.touches.getFirst().justPressed))) {
        playMenuSound("cancel");
        close();
    }
}

function destroy() {
    FlxG.mouse.visible = false;

    buttonsBack.destroy();
    FlxG.cameras.remove(statsCam);
    statsCam.destroy();
}