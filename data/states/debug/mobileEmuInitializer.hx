/**
 * or deactivates it, depends what the value of "isMobile" is at
**/

importScript("data/utils");

function create() {
    if (isMobile) {
        resizeGame(1280, 720);
        if (!Application.current.window.maximized)
            resizeWindow(1280, 720);
    }
    else {
        resizeGame(1600, 720);
        if (!Application.current.window.maximized)
            resizeWindow(1600, 720);
    }

    setMobile(!isMobile);

    new FlxTimer().start(0.01, _ -> {
        FlxG.switchState(new ModState("impostorTitleState"));
    });
}