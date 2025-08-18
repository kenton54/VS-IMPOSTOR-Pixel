import funkin.options.Options;

var warnCam:FlxCamera;
var warnTxt:FunkinText;

var acceptKey:FlxKey = Reflect.field(Options, "P1_ACCEPT")[0];

function create() {
    warnCam = new FlxCamera();
    warnCam.bgColor = 0x88000000;
    FlxG.cameras.add(warnCam, false);

    var pressOrTouch:String = FlxG.onMobile ? translate("touch") : translate("press", [CoolUtil.keyToString(acceptKey)]) + " or " + translate("click");
    warnTxt = new FunkinText(0, 0, FlxG.width, createMultiLineText([
        translate("options.warning.language"),
        "",
        translate("options.warning.menuReload"),
        "",
        translate("options.warning.pressSuffix", [pressOrTouch])
    ]), 40);
    warnTxt.alignment = "center";
    warnTxt.font = Paths.font("pixeloidsans.ttf");
    warnTxt.borderSize = 5;
    warnTxt.screenCenter(FlxAxes.Y);
    warnTxt.camera = warnCam;
    add(warnTxt);
}

function update(elapsed:Float) {
    if (FlxG.onMobile ? (FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justReleased) : FlxG.mouse.justReleased || controls.ACCEPT) {
        FlxG.resetState();
    }
}

function destroy() {
    FlxG.cameras.remove(warnCam);
    warnTxt.destroy();
}