import funkin.options.Options;

var options:Array<Dynamic> = [
    {
        name: "Downscroll",
        description: "If checked, notes will go from up to down instead of down to up, as if they're falling.",
        type: "bool",
        savevar: "downscroll",
        savepoint: Options
    },
    {
        name: "Ghost Tapping",
        description: "If checked, notes will go from up to down instead of down to up, as if they're falling.",
        type: "bool",
        savevar: "ghostTapping",
        savepoint: Options
    },
    {
        name: "Song Offset",
        description: "Changes the offset that songs should start with.",
        type: "integer",
        min: -1000,
        max: 1000,
        change: 1,
        savevar: "songOffset",
        savepoint: Options
    },
    {
        name: "Sentitive Content",
        description: "If unchecked, blood, gore and strong language will be toned down.",
        type: "bool",
        savevar: "naughtyness",
        savepoint: Options
    },
    {
        name: "Zoom Camera on Beat",
        description: "If checked, the camera will zoom on each beat.",
        type: "bool",
        savevar: "camZoomOnBeat",
        savepoint: Options
    },
    {
        name: "Time Bar",
        description: "If checked, will show a bar that tracks the current song position, as well as its percentage from completion.",
        type: "bool",
        savevar: "impPixelTimeBar",
        savepoint: FlxG.save.data
    },
    {
        name: "StrumLines' Background",
        description: "Give the strumline a semi-(or fully)-transparent background.",
        type: "percent",
        change: 0.05,
        savevar: "impPixelStrumBG",
        savepoint: FlxG.save.data
    }
];

function onChangeBool(option:Int, newValue:Bool) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);
}

function onChangeInt(option:Int, newValue:Int) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);
}

function onChangeFloat(option:Int, newValue:Float) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);
}