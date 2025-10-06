if (PlayState.isStoryMode) {
    disableScript();
    return;
}

public var taskbarBG:FlxSprite;
public var taskbar:FlxSprite;
public var taskbarTxt:FunkinText;

function create() {
    taskbarBG = new FlxSprite(45).loadGraphic(Paths.image("game/taskBar"));
    taskbarBG.scale.set(4, 3.5);
    taskbarBG.updateHitbox();
    taskbarBG.alpha = 0;
    taskbarBG.y = 4;
    taskbarBG.camera = camHUD;
    taskbarBG.visible = FlxG.save.data.impPixelTimeBar;
    add(taskbarBG);

    taskbar = new FlxSprite(taskbarBG.x + 16, taskbarBG.y + 14).makeGraphic(544, 14, 0xFFFFFFFF); // you can customize the color
    taskbar.color = 0xFF43D844;
    taskbar.alpha = 0;
    taskbar.camera = camHUD;
    taskbar.visible = FlxG.save.data.impPixelTimeBar;
    add(taskbar);

    taskbarTxt = new FunkinText(taskbarBG.x + 24, taskbarBG.y + 10, 0, PlayState.SONG.meta.displayName, 20);
    taskbarTxt.borderSize = 2;
    taskbarTxt.alpha = 0;
    taskbarTxt.camera = camHUD;
    taskbarTxt.visible = FlxG.save.data.impPixelTimeBar;
    add(taskbarTxt);
}

function onStartSong() {
    FlxTween.tween(taskbarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    FlxTween.tween(taskbar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    FlxTween.tween(taskbarTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
}

function update(elapsed:Float) {
    taskbar.scale.x = songPercent;
    taskbar.updateHitbox();

    if (updateTaskbarTxt) {
        taskbarTxt.text = PlayState.SONG.meta.displayName;
        taskbarTxt.text += " (" + Math.round(songPercent * 100) + "%)";
    }
}