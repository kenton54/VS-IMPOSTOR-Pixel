import flixel.input.mouse.FlxMouse;
import flixel.input.touch.FlxTouch;
import flixel.input.FlxPointer;
import flixel.input.FlxSwipe;
import flixel.FlxObject;

// Mobile related variables
public static var isMobile:Bool = FlxG.onMobile;
public static var fakeMobile:Bool = false;

public static final appPackageDotted:String = FlxG.stage.application.meta["package"] ?? FlxG.stage.application.meta["packageName"];
public static final appPackageSlash:String = StringTools.replace(appPackageDotted, ".", "/");

static final minSwipeDistance:Float = 20;

public static function setMobile(bool:Bool) {
    if (FlxG.onMobile) {
        isMobile = FlxG.onMobile;
        fakeMobile = !FlxG.onMobile;
    }
    else {
        isMobile = bool;
        fakeMobile = bool;
    }
}

public static function touchOverlaps(object:FlxBasic, ?camera:FlxCamera):Bool {
    if (getTouch() == null) return false;

    return getTouch().overlaps(object, camera);

    return false;
}

public static function touchOverlapsComplex(object:FlxObject, ?camera:FlxCamera) {
    if (getTouch() == null) return false;

    return object.overlapsPoint(getTouch().getWorldPosition(camera, object._point), true, camera);

    return false;
}

public static function touchJustMoved():Bool
    return getTouch().justMoved;

public static function touchJustPressed():Bool
    return getTouch().justPressed;

public static function touchIsHolding():Bool
    return getTouch().pressed;

public static function touchJustReleased():Bool
    return getTouch().justReleased;

public static function getSwipeLeft():Bool {
    final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
    if (swipe == null) return false;
    return (swipe.degrees > 135) && (swipe.degrees < -135) && (swipe.distance > minSwipeDistance);
}

public static function getSwipeRight():Bool {
    final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
    if (swipe == null) return false;
    return (swipe.degrees > -45) && (swipe.degrees < 45) && (swipe.distance > minSwipeDistance);
}

public static function getSwipeUp():Bool {
    final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
    if (swipe == null) return false;
    return (swipe.degrees > 45) && (swipe.degrees < 135) && (swipe.distance > minSwipeDistance);
}

public static function getSwipeDown():Bool {
    final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
    if (swipe == null) return false;
    return (swipe.degrees > -135) && (swipe.degrees < -45) && (swipe.distance > minSwipeDistance);
}

public static function getSwipeAny():Bool
    return getSwipeLeft() || getSwipeRight() || getSwipeUp() || getSwipeDown();

public static function getTouch():FlxPointer {
    if (FlxG.onMobile) {
        for (touch in FlxG.touches.list) {
            if (touch != null) return touch;
        }

        return FlxG.touches.getFirst();
    }
    else
        return FlxG.mouse;

    return null;
}

// this function can only be executed on real mobile targets
// currently crashes the game on mobile upon execute
public static function vibrateDevice(duration:Float, amplitude:Float) {
    if (FlxG.onMobile) {
        final amplitudeValue:Float = clamp(amplitude * FlxG.save.data.hapticsIntensity, 0, 1);
        final sharpness:Float = 1;

        #if android
        final vibrateJNI:Null<Dynamic> = createJNIStaticMethod(null, 'vibrateOneShot', '(II)V');
        if (vibrateJNI != null) vibrateJNI(Math.floor(duration * 1000), Math.floor(Math.max(1, Math.min(255, amplitudeValue * 255))));
        #elseif ios
        #else
        throw "Unrecognized device in use!";
        #end
    }
    else
        logTraceColored([
            {text: "[Mobile] ", color: getLogColor("green")},
            {text: 'The "vibrateDevice" method can only be executed on Mobile targets!'}
        ], "warning");
}