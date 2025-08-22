import funkin.options.Options;

var options:Array<Dynamic> = [
    {
        name: "volumeGlobal",
        type: "percent",
        change: 0.05,
        savevar: "volume",
        savepoint: FlxG.save.data
    },
    {
        name: "volumeMusic",
        type: "percent",
        change: 0.05,
        savevar: "volumeMusic",
        savepoint: Options
    },
    {
        name: "volumeSFX",
        type: "percent",
        change: 0.05,
        savevar: "volumeSFX",
        savepoint: Options
    },/*
    {
        name: "streamedMusic",
        type: "bool",
        savevar: "streamedMusic",
        savepoint: Options
    },
    {
        name: "streamedVocals",
        type: "bool",
        savevar: "streamedVocals",
        savepoint: Options
    },*/
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
        change: 10,
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

    if (options[option].savevar == "volume") {
        FlxG.sound.volume = newValue;
        FlxG.save.data.volume = newValue;
    }
}