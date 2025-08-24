var transOut:Bool = false;

function create(event) {
    event.cancel();

    transOut = event.transOut;

    blackSpr = new FlxSprite(event.transOut ? -transitionCamera.width : transitionCamera.width, 0).makeGraphic(1, 1, FlxColor.BLACK);
    blackSpr.scale.set(transitionCamera.width, transitionCamera.height);
    blackSpr.updateHitbox();
    blackSpr.camera = transitionCamera;
    add(blackSpr);

    transitionSprite = new FunkinSprite();
    transitionSprite.loadSprite(Paths.image("menus/transitions/halfCircle"));
    transitionSprite.setGraphicSize(transitionCamera.height / 2);
    transitionSprite.updateHitbox();
    transitionSprite.screenCenter(FlxAxes.Y);
    transitionSprite.camera = transitionCamera;
    transitionSprite.x = event.transOut ? 0 : transitionSprite.width * 2.58;
    transitionSprite.flipX = !event.transOut;
    add(transitionSprite);

    var transDur:Float = FlxG.save.data.impPixelFastMenus ? 1 / 5 : 2 / 5;
    transitionCamera.scroll.x = transitionCamera.width;
    transitionTween = FlxTween.tween(transitionCamera, {"scroll.x": -transitionCamera.width}, transDur, {
        ease: event.transOut ? FlxEase.sineOut : FlxEase.sineIn,
        onComplete: _ -> {
            finish();
        }
    });
}

function onPostFinish() {
    if (!transOut) setTransition("");
}