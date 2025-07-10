class ImpostorFlags {
    // ———————————————————— Story Mode ———————————————————— //
    public static var week1Completed:Map<String, Bool> = ["bf" => false];
    public static var week2Completed:Map<String, Bool> = ["bf" => false];

    // ———————————————————— PlayState ———————————————————— //
    public static var playingVersus:Bool = false;

    public function new() {
        load(FlxG.save.data.impPixelFlags);
        trace("ImpostorFlags initialized");
    }

    public function init() {
        playingVersus = false;

        save();
    }

    private function load(data:Map<String, Dynamic>) {
        week1Completed = data["week1Completed"] ?? ["bf" => false];
        week2Completed = data["week2Completed"] ?? ["bf" => false];
        playingVersus = data["playingVersus"] ?? false;
    }

    public function getFlags():Map<String, Dynamic> {
        var map:Map<String, Dynamic> = [];

        map.set("week1Completed", week1Completed);
        map.set("week2Completed", week2Completed);

        map.set("playingVersus", playingVersus);

        return map;
    }

    public function save() {
        FlxG.save.data.impPixelFlags = getFlags();
    }
}