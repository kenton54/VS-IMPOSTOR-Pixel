import funkin.options.Options;
import funkin.savedata.FunkinSave;

var options:Array<Dynamic> = [
    {
        name: "devMode",
        type: "bool",
        savevar: "devMode",
        savepoint: Options
    },
    {
        name: "resetSaveData",
        description: 'Select this option to delete all your progress (including song scores).\nWARNING: SELECTING THIS OPTION WILL RESTART THE GAME!',
        type: "function"
    }
];

function onChangeBool(option:Int, newValue:Bool) {
    Reflect.setProperty(options[option].savepoint, options[option].savevar, newValue);
}

var queuedDataDeletion:Bool = false;
function onCallFunction(option:Int) {
    if (options[option].name == "resetSaveData")
        queuedDataDeletion = true;
}