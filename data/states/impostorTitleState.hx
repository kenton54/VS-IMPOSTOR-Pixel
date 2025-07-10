import flixel.group.FlxTypedSpriteGroup;
import funkin.backend.utils.DiscordUtil;
import PixelStars;

var title:FlxTypedSpriteGroup;
var baseScale:Float = 4;

var pressStart:FunkinText;

function create() {
    DiscordUtil.call("onMenuLoaded", ["Title Screen"]);

    var stars:PixelStars = new PixelStars(0, 0, -40, 4, 3);
    stars.addStars();

    title = new FlxTypedSpriteGroup();
    add(title);

    var titleColor:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/title/color"));
    titleColor.scale.set(baseScale, baseScale);
    titleColor.updateHitbox();
    titleColor.centerOffsets();
    titleColor.screenCenter(FlxAxes.X);
    titleColor.y = FlxG.height * 0.1;
    titleColor.color = 0xFFE31629;
    title.add(titleColor);

    var titleMain:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/title/main"));
    titleMain.scale.set(baseScale, baseScale);
    titleMain.updateHitbox();
    titleMain.centerOffsets();
    titleMain.screenCenter(FlxAxes.X);
    titleMain.y = FlxG.height * 0.1;
    title.add(titleMain);

    pressStart = new FunkinText(0, 0, FlxG.width, "PRESS ENTER TO PLAY", 52);
    pressStart.alignment = "center";
    pressStart.color = FlxColor.TRANSPARENT;
    pressStart.borderColor = FlxColor.WHITE;
    pressStart.borderSize = 5.1;
    pressStart.font = Paths.font("gameboy.ttf");
    pressStart.y = FlxG.height * 0.8;
    add(pressStart);
}

function update(elapsed:Float) {
    if (controls.ACCEPT) {
        FlxG.switchState(new MainMenuState());
    }
}

function beatHit(curBeat:Int) {
    bopTitle();
}

function bopTitle() {
    title.forEach(function(spr) {
        FlxTween.cancelTweensOf(spr, ["scale.x", "scale.y"]);

        var daScale:Float = (baseScale * 1.1);
        var duration:Float = 60 / Conductor.bpm;

        spr.scale.set(daScale, daScale);
        FlxTween.tween(spr, {"scale.x": baseScale, "scale.y": baseScale}, duration, {ease: FlxEase.backInOut});
    });
}