import funkin.backend.week.Week;
import funkin.editors.EditorTreeMenu.EditorTreeMenuScreen;
import funkin.options.type.IconOption;
import funkin.options.type.TextOption;

function create() {
    changeDiscordEditorStatus("Week Selector");

    var weeks:Array<String> = [];
    for (week in Paths.getFolderContent("data/weeks/weeks/", false, 1, true))
        weeks.push(week);

    var options:Array<IconOption> = [];
    for (week in weeks)
        options.push(makeWeekOption(week));

    var daThing = new EditorTreeMenuScreen("editor.week.name", "weekSelection.desc", "weekSelection.", options, "newWeek", "newWeekDesc", () -> {});
    addMenu(daThing);
}

function makeWeekOption(week:String):IconOption {
    var daWeek = Week.loadWeek(week, false);

    var option = new IconOption(daWeek.name, translate("weekSelection.acceptWeek"), daWeek.sprite, () -> openWeekOption(daWeek));
    option.suffix = " >";

    return option;
}

function openWeekOption(weekData:Dynamic) {
    var subMenu = new EditorTreeMenuScreen(weekData.name, "weekSelection.selectDifficulty");

    for (difficulty in weekData.difficulties) {
        subMenu.add(new TextOption(difficulty, translate("weekSelection.acceptDifficulty"), "", () -> {
            PlayState.loadWeek(weekData, difficulty);
            FlxG.switchState(new PlayState());
        }));
    }

    addMenu(subMenu);
}