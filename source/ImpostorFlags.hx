class ImpostorFlags {
    // ———————————————————— Story Mode ———————————————————— //
    public static var week1Completed:Map<String, Bool> = ["bf" => false];
    public static var week2Completed:Map<String, Bool> = ["bf" => false];

    // ———————————————————— PlayState ———————————————————— //
    public static var playingVersus:Bool = false; // not to be saved

    // ———————————————————— Cutscene Player ———————————————————— //
    public static var unlockedVideos:Map<String, Bool> = [/*"video path" => isUnlocked*/];

    public static function load(data:Map<String, Dynamic>) {
        week1Completed = data["week1Completed"] ?? ["bf" => false];
        week2Completed = data["week2Completed"] ?? ["bf" => false];
        unlockedVideos = data["unlockedVideos"] == [];
    }

    public static function getFlags():Map<String, Dynamic> {
        var map:Map<String, Dynamic> = [];

        map.set("week1Completed", week1Completed);
        map.set("week2Completed", week2Completed);

        map.set("playingVersus", playingVersus);

        map.set("unlockedVideos", unlockedVideos);

        return map;
    }

    public static function save() {
        FlxG.save.data.impPixelFlags = getFlags();
    }
}