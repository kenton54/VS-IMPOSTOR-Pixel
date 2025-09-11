public static final defaultStats:Map<String, Dynamic> = [
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
            return translate("mainMenu.stats." + stat);
        }
    }

    trace(id, "doesnt exist, using default...");

    if (!success) {
        for (stat in defaultStats.keys()) {
            if (stat == id) {
                success = true;
                return translate("mainMenu.stats." + stat);
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