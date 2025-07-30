import funkin.options.Options;

var options:Array<Dynamic> = [
    {
        name: "downscroll",
        type: "bool",
        savevar: "downscroll",
        savepoint: Options
    },
    {
        name: "middlescroll",
        type: "bool",
        savevar: "middlescroll",
        savepoint: FlxG.save.data
    },
    {
        name: "ghostTapping",
        type: "bool",
        savevar: "ghostTapping",
        savepoint: Options
    },
    {
        name: "songOffset",
        type: "integer",
        min: -1000,
        max: 1000,
        change: 1,
        savevar: "songOffset",
        savepoint: Options
    },
    {
        name: "naughtyness",
        type: "bool",
        savevar: "naughtyness",
        savepoint: Options
    },
    {
        name: "camZoomOnBeat",
        type: "bool",
        savevar: "camZoomOnBeat",
        savepoint: Options
    },
    {
        name: "timeBar",
        type: "bool",
        savevar: "impPixelTimeBar",
        savepoint: FlxG.save.data
    },
    {
        name: "strumsBG",
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