import funkin.backend.week.Week;
import funkin.editors.EditorTreeMenu.EditorTreeMenuScreen;
import funkin.options.type.TextOption;

var weeks:Array<String> = [];

function create() {
    changeDiscordEditorStatus("Week Selector");

    for (week in Paths.getFolderContent("data/weeks/weeks/", false, 1, true))
        weeks.push(week);

    var options:Array<TextOption> = [];
    for (week in weeks)
        options.push(makeWeekOption(week));

    var daThing = new EditorTreeMenuScreen("editor.week.name", "weekSelection.desc", "weekSelection.", options, "newWeek", "newWeekDesc", () -> {});
    addMenu(daThing);
}

function makeWeekOption(week:String):TextOption {
    var daWeek = Week.loadWeek(week, false);
    var option = new TextOption(daWeek.name, translate("weekSelection.acceptWeek"), "", () -> {
        PlayState.loadWeek(daWeek, "normal");
        FlxG.switchState(new PlayState());
    });
    option.__text.text = daWeek.name; // for some reason i have to do this
    return option;
}