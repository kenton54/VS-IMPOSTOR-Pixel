import funkin.backend.utils.NativeAPI;
import funkin.options.Options;

var options:Array<Dynamic> = [
    {
        name: "showConsole",
        type: "function"
    },
    {
        name: "editorsResizable",
        type: "bool",
        savevar: "editorsResizable",
        savepoint: Options
    },
    {
        name: "bypassEditorsResize",
        type: "bool",
        savevar: "bypassEditorsResize",
        savepoint: Options
    },
    {
        name: "editorSFX",
        type: "bool",
        savevar: "editorSFX",
        savepoint: Options
    },
    {
        name: "editorCharterPrettyPrint",
        type: "bool",
        savevar: "editorCharterPrettyPrint",
        savepoint: Options
    },
    {
        name: "editorCharacterPrettyPrint",
        type: "bool",
        savevar: "editorCharacterPrettyPrint",
        savepoint: Options
    },
    {
        name: "editorStagePrettyPrint",
        type: "bool",
        savevar: "editorStagePrettyPrint",
        savepoint: Options
    },
    {
        name: "intensiveBlur",
        type: "bool",
        savevar: "intensiveBlur",
        savepoint: Options
    },
    {
        name: "charterAutoSaves",
        type: "bool",
        savevar: "charterAutoSaves",
        savepoint: Options
    },
    {
        name: "charterAutoSaveTime",
        type: "integer",
        min: 60,
        max: 60 * 10,
        change: 1,
        savevar: "charterAutoSaveTime",
        savepoint: Options
    },
    {
        name: "charterAutoSaveWarningTime",
        type: "integer",
        min: 0,
        max: 15,
        change: 1,
        savevar: "charterAutoSaveWarningTime",
        savepoint: Options
    },
    {
        name: "charterAutoSavesSeparateFolder",
        type: "bool",
        savevar: "charterAutoSavesSeparateFolder",
        savepoint: Options
    },
    {
        name: "songOffsetAffectEditors",
        type: "bool",
        savevar: "songOffsetAffectEditors",
        savepoint: Options
    }
];

function onChangeBool(option:Int, newValue:Bool) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);
}

function onChangeInt(option:Int, newValue:Int) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);
}

function onCallFunction(option:Int) {
    if (options[option].name == "showConsole") {
        NativeAPI.allocConsole();
    }
}