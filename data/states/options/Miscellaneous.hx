import funkin.options.Options;
import funkin.savedata.FunkinSave;

var options:Array<Dynamic> = [
    {
        name: "devMode",
        description: "devMode",
        type: "checkbox",
        savevar: "devMode",
        savepoint: Options
    }
    /*
    {
        name: "Reset Save Data",
        description: 'Select this option to delete all your progress (including song scores).\nWARNING: SELECTING THIS OPTION WILL RESTART THE GAME!',
        type: "function"
    }
    */
];

function onCallFunction(option:Int) {
    if (options[option].name == "Reset Save Data") {
        FlxG.resetGame();
    }
}