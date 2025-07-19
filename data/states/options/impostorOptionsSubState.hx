import flixel.group.FlxTypedSpriteGroup;
import funkin.options.Options;
importScript("data/variables");

var optionsCam:FlxCamera;

var phone:FlxTypedSpriteGroup;

function create() {
    optionsCam = new FlxCamera();
    optionsCam.bgColor = 0x80000000;
    FlxG.cameras.add(optionsCam, false);

    phone = new FlxTypedSpriteGroup();
    phone.camera = optionsCam;
    add(phone);
}

function postCreate() {
    FlxG.mouse.visible = true;
}

function update(elapsed:Float) {
    if (controls.BACK || /*FlxG.mouse.overlaps(closeButton) &&*/ FlxG.mouse.justPressed) {
        CoolUtil.playMenuSFX(2);
        close();
    }
}

function destroy() {
    buttonsBack.destroy();

    FlxG.cameras.remove(statsCam);
    statsCam.destroy();
}