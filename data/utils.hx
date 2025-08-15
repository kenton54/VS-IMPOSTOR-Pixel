import funkin.backend.system.Logs;
import funkin.backend.utils.TranslationUtil;

public static var storyStates:Array<String> = [
    "start",
    "postTutorial",
    "postLobbyShowcase",
    "postWeek1",
    "postOminous"
];
public static var storySequence:Int = 0;

static var defaultStats:Map<String, Dynamic> = [
    "storyProgress" => "start",
    "totalNotes" => 0,
    "perfectNotes" => 0,
    "sickNotes" => 0,
    "goodNotes" => 0,
    "badNotes" => 0,
    "shitNotes" => 0,
    "missedNotes" => 0,
    "combosBroken" => 0,
    "attacksDodged" => 0,
    "taskSpeedrunSkeld" => 0.0,
    "taskSpeedrunMira" => 0.0,
    "taskSpeedrunPolus" => 0.0,
    "taskSpeedrunAirship" => 0.0,
    "totalTasks" => 0
];
public static var impostorStats:Map<String, Dynamic> = [];

public static var playablesList:Map<String, Bool> = ["bf" => true];
public static var skinsList:Map<String, Map<String, Bool>> = [/*character => [skin => bought]*/];

public static var seenPlayables:Array<String> = ["bf"];

public static var pixelPlayable:String = "bf";

public static var pixelBeans:Int = 0;

public static var isMobile:Bool = FlxG.onMobile;
public static var fakeMobile:Bool = false;

public static function setMobile(bool:Bool) {
    if (FlxG.onMobile) {
        isMobile = FlxG.onMobile;
        fakeMobile = !FlxG.onMobile;
    }
    else {
        if (!FlxG.onMobile) {
            isMobile = bool;
            fakeMobile = bool;
        }
    }
}

public static function getStats(?def:Bool):Map<String, Dynamic> {
    var map:Map<String, Dynamic> = [];

    if (def) {
        for (stat in defaultStats.keyValueIterator()) {
            map.set(stat.key, stat.value);
        }
    }
    else {
        for (stat in impostorStats.keyValueIterator()) {
            map.set(stat.key, stat.value);
        }
    }

    return map;
}

public static function getStatName(id:String):Null<String> {
    var success:Bool = false;

    for (stat in impostorStats.keys()) {
        if (stat == id) {
            success = true;
            return TranslationUtil.translate("mainMenu.stats." + stat);
        }
    }

    trace(id, "doesnt exist, using default...");

    if (!success) {
        for (stat in defaultStats.keys()) {
            if (stat == id) {
                success = true;
                return TranslationUtil.translate("mainMenu.stats." + stat);
            }
        }
    }

    if (!success)
        throw 'Stat ID "'+id+'" doesn\'t exist!';

    return null;
}

public static function getStatValue(id:String):Dynamic {
    if (!defaultStats.exists(id)) throw 'Stat ID "'+id+'" doesn\'t exist!';

    if (impostorStats.exists(id))
        return impostorStats.get(id);
    else
        return defaultStats.get(id);
}

public static function resizeGame(width:Int, height:Int) {
    FlxG.initialWidth = width;
    FlxG.initialHeight = height;
    FlxG.width = width;
    FlxG.height = height;
}

public static function resizeWindow(width:Int, height:Int) {
    window.resize(width, height);
}

public static function saveImpostor() {
    FlxG.save.data.impPixelStorySequence = storySequence;
    FlxG.save.data.impPixelStats = impostorStats;
    FlxG.save.data.impPixelPlayablesUnlocked = playablesList;
    FlxG.save.data.impPixelSkinsUnlocked = skinsList;
    FlxG.save.data.impPixelBeans = pixelBeans;

    Logs.traceColored([
        {text: "[VS IMPOSTOR Pixel] ", color: 12},
        {text: "Data Saved!", color: -1}
    ]);
}