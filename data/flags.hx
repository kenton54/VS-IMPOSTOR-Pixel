// —————————————————————————————————————— Demo Exclusive ————————————————————————————————————— //
public static var isSussusMoogusComplete:Bool = false;

// ———————————————————————————————————————— Story Mode ——————————————————————————————————————— //
public static var weeksCompleted:Map<Int, String> = [/*week ID => character*/];

// ————————————————————————————————————————— Freeplay ———————————————————————————————————————— //
public static var seenCharacters:Array<String> = [/*character*/];

// ————————————————————————————————————— Cutscene Player ————————————————————————————————————— //
public static var unlockedVideos:Array<String> = [/*video path*/];

// ————————————————————————————————————— Static Functions ———————————————————————————————————— //
static function getFlags(?useDefault:Bool):Map<String, Dynamic> {
    var map:Map<String, Dynamic> = [];

    if (useDefault) {
        map.set("isSussusMoogusComplete", false);
        map.set("weeksCompleted", []);
        map.set("seenCharacters", []);
        map.set("unlockedVideos", []);
    }
    else {
        map.set("isSussusMoogusComplete", isSussusMoogusComplete);
        map.set("weeksCompleted", weeksCompleted);
        map.set("seenCharacters", seenCharacters);
        map.set("unlockedVideos", unlockedVideos);
    }

    return map;
}

public static function resetFlags() {
    isDemo = true;
    isSussusMoogusComplete = false;
    weeksCompleted.clear();
    seenCharacters = [];
    unlockedVideos = [];
}