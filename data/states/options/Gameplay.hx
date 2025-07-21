import funkin.options.Options;

var options:Array<Dynamic> = [
    {
        name: "Time Bar",
        description: "If checked, will show a bar that tracks the current song position, as well as its percentage from completion.",
        type: "bool",
        savevar: "impPixelTimeBar",
        savepoint: FlxG.save.data
    },
    {
        name: "StrumLines' Background",
        description: "If unchecked, the game will use the orginal red and green health bar from the Base Game (also known as V-Slice).",
        type: "percent",
        change: 0.05,
        savevar: "impPixelStrumBG",
        savepoint: FlxG.save.data
    }
];