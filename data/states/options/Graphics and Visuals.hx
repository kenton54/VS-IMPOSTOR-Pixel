import flixel.group.FlxTypedSpriteGroup;
import funkin.options.Options;

var bounds:Array<Float> = [];

var options:Array<Dynamic> = [
    {
        name: "Framerate",
        description: "Pretty self explanatory, isn't it?",
        type: "integer",
        min: 30,
        max: 300,
        change: 10,
        saveVar: "framerate",
        savePoint: Options
    },
    {
        name: "Colored Health Bar",
        description: "If unchecked, the game will use the orginal red and green health bar from the Base Game (also known as V-Slice).",
        type: "bool",
        saveVar: "colorHealthBar",
        savePoint: Options
    },
    {
        name: "Intensive Shaders",
        description: 'If checked, songs that use shaders that have more impact on the framerate will be loaded.\nLeave unchecked for a smoother experience.',
        type: "bool",
        saveVar: "gameplayShaders",
        savePoint: Options
    },
    {
        name: "Flashing Lights",
        description: 'If unchecked, will make flashes less "flashy".\nLeave unchecked if you\'re sentitive to these.',
        type: "bool",
        saveVar: "flashingMenu",
        savePoint: Options
    },
    {
        name: "Low Memory Mode",
        description: "If checked, will reduce the amount of detail each part of the mod has to reduce memory usage.",
        type: "bool",
        saveVar: "lowMemoryMode",
        savePoint: Options
    },
    {
        name: "GPU Sprite Storing",
        description: "If checked, will store loaded bitmaps (or more known as sprites) in the GPU, heavily reducing memory usage.",
        type: "bool",
        saveVar: "gpuOnlyBitmaps",
        savePoint: Options
    },
    {
        name: "Freeze Game on Unfocus",
        description: FlxG.onMobile ? "If checked, opening the notification bar will freeze the game until you come back." : "If checked, going to another window will freeze the game until you come back.",
        type: "bool",
        saveVar: "autoPause",
        savePoint: Options
    }
];

var categoryCam:FlxCamera;
var group:FlxTypedSpriteGroup;

function create() {
    categoryCam = new FlxCamera(bounds[0], bounds[1], bounds[2], bounds[3]);
    categoryCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(categoryCam, false);

    group = new FlxTypedSpriteGroup();
    group.camera = categoryCam;
    add(group);

    for (i in 0...options.length) {
        var height:Float = 52;
        var bg:FlxSprite = new FlxSprite(0, height * i).makeGraphic(categoryCam.width, Std.int(height), FlxColor.BLACK);
        bg.alpha = 0.1;
        bg.blend = 9;
        group.add(bg);

        var label:FunkinText = new FunkinText(bg.x + 12, bg.y + bg.height / 2, 0, options[i].name, 30);
        label.font = Paths.font("retrogaming.ttf");
        label.borderSize = 2;
        label.y -= label.height / 2;
        group.add(label);
    }
}

function update(elapsed:Float) {}

function destroy() {
    group.destroy();
    FlxG.cameras.remove(categoryCam);
    categoryCam.destroy();
}