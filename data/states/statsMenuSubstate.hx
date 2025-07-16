import flixel.util.FlxStringUtil;
import AmongUsBox;
importScript("data/variables");

// maps are dumb becuz they cant keep stuff in order
var statsLabels:Array<String> = [
    "Current Story Progression",
    "Total Note Hits",
    "Perfect Note Hits",
    "Sick Note Hits",
    "Good Note Hits",
    "Bad Note Hits",
    "Shit Note Hits",
    "Total Attacks Dodged"/*,
    "Tasks Speedrun PB (Skeld)",
    "Tasks Speedrun PB (Mira HQ)",
    "Tasks Speedrun PB (Polus)",
    "Tasks Speedrun PB (Airship)",
    "Total Tasks Completed"*/
];
var defaultStats:Map<String, Dynamic> = [
    "Current Story Progression" => storyState[storySequence],
    "Total Note Hits" => 0,
    "Perfect Note Hits" => 0,
    "Sick Note Hits" => 0,
    "Good Note Hits" => 0,
    "Bad Note Hits" => 0,
    "Shit Note Hits" => 0,
    "Total Attacks Dodged" => 0,
    "Tasks Speedrun PB (Skeld)" => 0.0,
    "Tasks Speedrun PB (Mira HQ)" => 0.0,
    "Tasks Speedrun PB (Polus)" => 0.0,
    "Tasks Speedrun PB (Airship)" => 0.0,
    "Total Tasks Completed" => 0
];

var statsCam:FlxCamera;

var buttonsBack:AmongUsBox;
var closeButton:FlxSprite;

function create() {
    statsCam = new FlxCamera();
    statsCam.bgColor = 0x80000000;
    FlxG.cameras.add(statsCam, false);

    var scale:Float = 4;
    buttonsBack = new AmongUsBox(0, 0, 640, 640, "fancy", scale);
    buttonsBack.box.screenCenter();
    buttonsBack.box.camera = statsCam;
    add(buttonsBack.box);

    var statsTitle:FunkinText = new FunkinText(buttonsBack.box.x, buttonsBack.box.y, buttonsBack.box.width, "Statistics", 48);
    statsTitle.font = Paths.font("pixeloidsans.ttf");
    statsTitle.alignment = "center";
    statsTitle.camera = statsCam;
    statsTitle.y += 8 * scale;
    add(statsTitle);

    var i:Int = 0;
    for (stat in statsLabels) {
        var yPos:Float = (statsTitle.y + statsTitle.height) + (3 * scale) + (i * 22);
        var color:FlxColor = (i % 2 == 0) ? FlxColor.WHITE : 0xFF999999;
        var daStat:FunkinText = new FunkinText(statsTitle.x + 8 * scale, yPos, buttonsBack.width, stat, 22, false);
        daStat.font = Paths.font("retrogaming.ttf");
        daStat.color = color;
        daStat.camera = statsCam;
        add(daStat);

        var value:Dynamic;
        value = stats[statsLabels[i]] ?? defaultStats[statsLabels[i]];
        if (StringTools.contains(stat, "Story Progression")) value = '"'+value+'"';
        if (StringTools.contains(stat, "Speedrun")) value = FlxStringUtil.formatTime(value, true);
        var statValue:FunkinText = new FunkinText(statsTitle.x + 4 * scale, yPos, buttonsBack.width, Std.string(value), 22, false);
        statValue.alignment = "right";
        statValue.font = Paths.font("retrogaming.ttf");
        statValue.color = color;
        statValue.camera = statsCam;
        add(statValue);

        i++;
    }

    closeButton = new FlxSprite(buttonsBack.box.x, buttonsBack.box.y).loadGraphic(Paths.image("menus/mainmenu/x"));
    closeButton.scale.set(scale, scale);
    closeButton.updateHitbox();
    closeButton.x -= closeButton.width + 2 * scale;
    closeButton.camera = statsCam;
    add(closeButton);
}

function postCreate() {
    FlxG.mouse.visible = true;
}

function update(elapsed:Float) {
    if (controls.BACK || FlxG.mouse.overlaps(closeButton) && FlxG.mouse.justPressed) {
        CoolUtil.playMenuSFX(2);
        close();
    }
}

function destroy() {
    buttonsBack.destroy();

    FlxG.cameras.remove(statsCam);
    statsCam.destroy();
}