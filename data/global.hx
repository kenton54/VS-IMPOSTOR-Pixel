public static var playablesList:Array<String> = ["bf"];
public static var seenPlayables:Array<String> = ["bf"];
public static var pixelPlayable:String = "bf";

function new() {
    window.title = "VS IMPOSTOR Pixel";

    FlxSprite.defaultAntialiasing = false;

    initSaveData();
}

function initSaveData() {
    FlxG.save.data.impPixelBeans ??= 0;
    FlxG.save.data.impPixelTimeBar ??= true;
    FlxG.save.data.impPixelxBRZ ??= false;
    //if (FlxG.save.data.pixelPlayable == null) FlxG.save.data.pixelPlayable = "bf";
    //if (FlxG.save.data.pixelPartner == null) FlxG.save.data.pixelPartner = "gf";
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