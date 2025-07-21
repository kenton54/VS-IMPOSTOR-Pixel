import flixel.group.FlxTypedSpriteGroup;
import funkin.options.Options;

var bounds:Array<Float> = [];

var options:Array<Dynamic> = [
    {
        name: "Time Bar",
        description: "If checked, will show a bar that tracks the current song position, as well as its percentage from completion.",
        type: "bool",
        saveVar: "impPixelTimeBar",
        savePoint: FlxG.save.data
    },
    {
        name: "StrumLines' Background",
        description: "If unchecked, the game will use the orginal red and green health bar from the Base Game (also known as V-Slice).",
        type: "percent",
        change: 0.05,
        saveVar: "impPixelStrumBG",
        savePoint: FlxG.save.data
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

function destroy() {
    group.destroy();
    FlxG.cameras.remove(categoryCam);
    categoryCam.destroy();
}