import flixel.addons.display.FlxBackdrop;
import BackButton;
import PixelStars;

var stars:PixelStars;

var baseScale:Float = 5;

var backButton:BackButton;

function create() {
    stars = new PixelStars(-40, 4, 3);
    stars.addStars();

    var topBorder:FlxBackdrop = new FlxBackdrop(Paths.image("menus/general/topBorder"), FlxAxes.X);
    topBorder.scale.set(baseScale, baseScale);
    topBorder.updateHitbox();
    add(topBorder);

    backButton = new BackButton(baseScale, baseScale, () -> {
        setTransition("fade");
        FlxG.switchState(new ModState("impostorMenuState"));
    }, baseScale, false, "menus/x", true);
    add(backButton);

    FlxG.mouse.visible = true;
}

function destroy() {
    backButton.destroy();
}