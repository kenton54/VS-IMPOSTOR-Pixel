import flixel.util.FlxDestroyUtil;

var extraTween1:FlxTween = null;
var extraTween2:FlxTween = null;
var extraTween3:FlxTween = null;
var extraTween4:FlxTween = null;

function create(event) {
    event.cancel();

    blackSpr = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
    blackSpr.scale.set(transitionCamera.width, transitionCamera.height);
    blackSpr.updateHitbox();
    blackSpr.camera = transitionCamera;
    add(blackSpr);

    var blackSpr1:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
    blackSpr1.scale.set(transitionCamera.width, transitionCamera.height);
    blackSpr1.updateHitbox();
    blackSpr1.camera = transitionCamera;
    add(blackSpr1);

    var blackSpr2:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
    blackSpr2.scale.set(transitionCamera.width, transitionCamera.height);
    blackSpr2.updateHitbox();
    blackSpr2.camera = transitionCamera;
    add(blackSpr2);

    var blackSpr3:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
    blackSpr3.scale.set(transitionCamera.width, transitionCamera.height);
    blackSpr3.updateHitbox();
    blackSpr3.camera = transitionCamera;
    add(blackSpr3);

    transitionSprite = new FunkinSprite();
    transitionSprite.loadSprite(Paths.image("menus/transitions/circle"));
    transitionSprite.setGraphicSize(transitionCamera.width + 200);
    transitionSprite.updateHitbox();
    transitionSprite.screenCenter();
    transitionSprite.camera = transitionCamera;
    add(transitionSprite);

    var intendedScale:Float = transitionSprite.scale.x;
    var circleX:Float = transitionSprite.x;
    var circleY:Float = transitionSprite.y;
    var circleWidth:Int = transitionSprite.width;
    var circleHeight:Int = transitionSprite.height;
    var tweenDur:Float = 2 / 4;
    var tweenEase:FlxEase = event.transOut ? FlxEase.quartOut : FlxEase.quartIn;
    if (event.transOut) {
        blackSpr.y = circleY - blackSpr.height;
        blackSpr1.x = circleX - blackSpr.width;
        blackSpr2.x = circleX + circleWidth;
        blackSpr3.y = circleY + circleHeight;

        extraTween1 = FlxTween.tween(blackSpr, {y: -transitionCamera.height / 2}, tweenDur, {ease: tweenEase});
        extraTween2 = FlxTween.tween(blackSpr1, {x: -transitionCamera.width / 2}, tweenDur, {ease: tweenEase});
        extraTween3 = FlxTween.tween(blackSpr2, {x: transitionCamera.width / 2}, tweenDur, {ease: tweenEase});
        extraTween4 = FlxTween.tween(blackSpr3, {y: transitionCamera.height / 2}, tweenDur, {ease: tweenEase});
        transitionTween = FlxTween.tween(transitionSprite, {"scale.x": 0, "scale.y": 0}, tweenDur, {
            ease: tweenEase,
            onComplete: _ -> {
                finish();
            }
        });
    }
    else {
        transitionSprite.scale.set(0, 0);
        transitionSprite.updateHitbox();
        transitionSprite.screenCenter();

        blackSpr.y = -transitionCamera.height / 2;
        blackSpr1.x = -transitionCamera.width / 2;
        blackSpr2.x = transitionCamera.width / 2;
        blackSpr3.y = transitionCamera.height / 2;

        extraTween1 = FlxTween.tween(blackSpr, {y: circleY - blackSpr.height}, tweenDur, {ease: tweenEase});
        extraTween2 = FlxTween.tween(blackSpr1, {x: circleX - blackSpr.width}, tweenDur, {ease: tweenEase});
        extraTween3 = FlxTween.tween(blackSpr2, {x: circleX + circleWidth}, tweenDur, {ease: tweenEase});
        extraTween4 = FlxTween.tween(blackSpr3, {y: circleY + circleHeight}, tweenDur, {ease: tweenEase});
        transitionTween = FlxTween.tween(transitionSprite, {"scale.x": intendedScale, "scale.y": intendedScale}, tweenDur, {
            ease: tweenEase,
            onComplete: _ -> {
                finish();
            }
        });
    }
}

function destroy() {
    extraTween1 = FlxDestroyUtil.destroy(extraTween1);
    extraTween2 = FlxDestroyUtil.destroy(extraTween2);
    extraTween3 = FlxDestroyUtil.destroy(extraTween3);
    extraTween4 = FlxDestroyUtil.destroy(extraTween4);
}