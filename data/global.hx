public static var pixelPlayable:String = "bf";

function new() {
    window.title = "VS IMPOSTOR Pixel Edition";

    initSaveData();
}

function initSaveData() {
    if (FlxG.save.data.pixelBeans == null) FlxG.save.data.pixelBeans = 0;
    if (FlxG.save.data.pixelLanguage == null) FlxG.save.data.pixelLanguage = "english";
    if (FlxG.save.data.pixelTimeBar == null) FlxG.save.data.pixelTimeBar = true;
    if (FlxG.save.data.pixelPlayable == null) FlxG.save.data.pixelPlayable = "bf";
    if (FlxG.save.data.pixelPartner == null) FlxG.save.data.pixelPartner = "gf";
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.F5) reloadState();
}

function reloadState() {
    FlxG.resetState();
}

// da states
var redirectStates:Map<FlxState, String> = [
    //MainMenuState => "impostorMenuState",
    FreeplayState => "impostorFreeplayState"
];

// the actual state modification
function preStateSwitch() {
    for (redirectState in redirectStates.keys())
        if (Std.isOfType(FlxG.game._requestedState, redirectState))
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}