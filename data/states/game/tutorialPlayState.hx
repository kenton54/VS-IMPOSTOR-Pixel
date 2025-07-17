import funkin.options.Options;

function create() {
    var key:FlxKey = Reflect.field(Options, "P1_BACK")[0];
    var text:FunkinText = new FunkinText(0, 0, FlxG.width, 'The tutorial hasn\'t begun\ndevelopment yet\n\nPress '+CoolUtil.keyToString(key)+' to go back', 64, false);
    text.alignment = "center";
    text.screenCenter();
    add(text);
}

function update(elapsed:Float) {
    if (controls.BACK)
        FlxG.switchState(new ModState("impostorMenuState"));
}