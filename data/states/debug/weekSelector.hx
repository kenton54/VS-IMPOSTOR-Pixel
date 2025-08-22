import funkin.backend.week.Week;
import funkin.editors.EditorTreeMenu.EditorTreeMenuScreen;
import funkin.options.type.IconOption;
import funkin.options.type.NewOption;
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

var curWeek:Null<Dynamic> = null;

function openWeekOption(weekData:Dynamic) {
    var subMenu = new EditorTreeMenuScreen(weekData.name, "weekSelection.selectDifficulty", "weekSelection.", null, "newDifficulty", "newDifficultyDesc");

    curWeek = weekData;

    for (difficulty in weekData.difficulties) {
        subMenu.add(new TextOption(difficulty, translate("weekSelection.acceptDifficulty"), "", () -> {
            PlayState.loadWeek(weekData, difficulty);
            FlxG.switchState(new PlayState());
        }));
    }

    subMenu.insert(0, new NewOption(translate('weekSelection.newDifficulty'), translate('weekSelection.newDifficultyDesc'), () -> {
        openSubState(new WeekDificultyCreationScreen(saveDifficulty));
    }));

    subMenu.curSelected = 1;

    addMenu(subMenu);
}

function saveDifficulty(newDiff:String) {
    curWeek.difficulties.push(newDiff);

    // TODO: figure out a way to save changes
}

import funkin.editors.ui.UIButton;
import funkin.editors.ui.UISubstateWindow;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIText;

class WeekDificultyCreationScreen extends UISubstateWindow {
    private var saveTo:Null<Dynamic> -> Void = null;

    public var newDiffTxtBox:UITextBox;

    public var saveButton:UIButton;
	public var closeButton:UIButton;

    public function new(saveTo:(String)->Void) {
        super();
        this.saveTo = (saveTo != null) ? saveTo : null;
    }

    override public function create() {
        winTitle = translate("weekDifficultyCreationScreen.win-title");

        winWidth = 360;
		winHeight = 220;

        super.create();

        var diffTxt:UIText;
		add(diffTxt = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, translate("weekDifficultyCreationScreen.title"), 28));

        add(newDiffTxtBox = new UITextBox(diffTxt.x, diffTxt.y + diffTxt.height + 36, translate("weekDifficultyCreationScreen.diffName")));

        add(saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, translate("editor.saveClose"), function() {
			saveNewDiff();
			close();
		}, 125));
    }

    private function saveNewDiff() {
		if (saveTo != null) saveTo(newDiffTxtBox.label.text);
	}
}