import funkin.options.Options;

var options:Array<Dynamic> = [
    {
        name: "framerate",
        type: "integer",
        min: 30,
        max: 300,
        change: 10,
        savevar: "framerate",
        savepoint: Options
    },
    {
        name: "colorHealthBar",
        type: "bool",
        savevar: "colorHealthBar",
        savepoint: Options
    },
    {
        name: "gameplayShaders",
        type: "bool",
        savevar: "gameplayShaders",
        savepoint: Options
    },
    {
        name: "flashingMenu",
        type: "bool",
        savevar: "flashingMenu",
        savepoint: Options
    },
    {
        name: "lowMemoryMode",
        type: "bool",
        savevar: "lowMemoryMode",
        savepoint: Options
    },
    {
        name: "gpuOnlyBitmaps",
        type: "bool",
        savevar: "gpuOnlyBitmaps",
        savepoint: Options
    },
    {
        name: "autoPause",
        type: "bool",
        savevar: "autoPause",
        savepoint: Options
    },
    {
        name: "impPixelFastMenus",
        type: "bool",
        savevar: "impPixelFastMenus",
        savepoint: FlxG.save.data
    }
];

function onChangeBool(option:Int, newValue:Bool) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);

    if (options[option].savevar == "autoPause") {
        FlxG.autoPause = newValue;
    }
}

function onChangeInt(option:Int, newValue:Int) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);

    if (options[option].savevar == "framerate") {
        if (FlxG.updateFramerate < newValue)
			FlxG.drawFramerate = FlxG.updateFramerate = newValue;
		else
			FlxG.updateFramerate = FlxG.drawFramerate = newValue;
    }
}

function onChangeFloat(option:Int, newValue:Float) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);
}

function onChangeChoice(option:Int, newValue:Int) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, options[option].choices[newValue]);
}