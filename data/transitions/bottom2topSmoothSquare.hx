function create(event) {
    event.cancel();

    blackSpr = new FlxSprite(0, event.transOut ? transitionCamera.height : -transitionCamera.height).makeGraphic(1, 1, FlxColor.BLACK);
    blackSpr.scale.set(transitionCamera.width, transitionCamera.height);
    blackSpr.updateHitbox();
    blackSpr.camera = transitionCamera;
    add(blackSpr);

    transitionSprite = new FunkinSprite();
    transitionSprite.loadSprite(Paths.image("menus/transitions/smoothVerLine"));
    transitionSprite.setGraphicSize(transitionCamera.width, transitionCamera.height);
    transitionSprite.updateHitbox();
    transitionSprite.camera = transitionCamera;
    //transitionSprite.y = event.transOut ? 0 : transitionSprite.height * 2.58;
    transitionSprite.flipY = true;
    add(transitionSprite);

    transitionCamera.flipY = !event.transOut;
    transitionCamera.scroll.y = -transitionCamera.height;
    transitionTween = FlxTween.tween(transitionCamera, {"scroll.y": transitionCamera.height}, 2 / 5, {
        ease: FlxEase.sineOut,
        onComplete: _ -> {
            finish();
        }
    });

    if (event.transOut)
        setTransition("");
}