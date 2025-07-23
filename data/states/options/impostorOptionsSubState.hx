import flixel.group.FlxTypedSpriteGroup;
//import flixel.text.FlxInputText; // must wait until next codename update :face_holding_back_tears: (i need flixel +5.9.0)
import funkin.backend.scripting.Script;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIText;
import funkin.options.Options;
import sys.FileSystem;
importScript("data/variables");

var optionsCam:FlxCamera;

var startTxt:FunkinText;

var theEntireThing:FlxTypedSpriteGroup; // this thing exists only for the tween intro LOL
var phoneSpr:FlxSprite;
var phoneScreen:FlxTypedSpriteGroup;
var categoriesGroup:FlxTypedSpriteGroup;
var descriptionGroup:FlxTypedSpriteGroup;

var selectionMode:String = "contents";
var categories:Array<String> = [];
var curCategory:Script;
var curCategoryIndex:Int = -1;
var lastCategoryIndex:Int = -1;
var categoryBounds:Array<Float> = []; // its actually used for multiple things, not for what its var name stands for lol
var curCategoryGrp:FlxTypedSpriteGroup;
var curOption:Int = 0;
var lastOption:Int = -1;

var closeButton:FlxSprite;

var scale:Float = 5;

function create() {
    var path:String = FileSystem.absolutePath(Assets.getPath(Paths.getPath("data/states/options")));
    for (category in FileSystem.readDirectory(path)) {
        category = removeExtension(category);
        categories.push(category);
    }
    categories.remove(categories[categories.indexOf("impostorOptionsSubState")]);

    optionsCam = new FlxCamera();
    optionsCam.bgColor = 0x00000000;
    FlxG.cameras.add(optionsCam, false);

    theEntireThing = new FlxTypedSpriteGroup(0, FlxG.height);
    add(theEntireThing);

    phoneSpr = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image("menus/options/phone"));
    phoneSpr.scale.set(scale, scale);
    phoneSpr.updateHitbox();
    phoneSpr.camera = optionsCam;
    phoneSpr.x -= phoneSpr.width / 2;
    phoneSpr.y -= phoneSpr.height / 2;

    phoneScreen = new FlxTypedSpriteGroup(phoneSpr.x + 10 * scale, phoneSpr.y + 9 * scale);
    phoneScreen.camera = optionsCam;

    theEntireThing.add(phoneScreen);
    theEntireThing.add(phoneSpr);

    var heightCorrect:Float = phoneSpr.height - 9 * scale * 2;
    var boxWidth:Int = phoneSpr.width - 25 * scale;
    var phoneBack:FlxSprite = new FlxSprite().makeGraphic(boxWidth, heightCorrect, 0xFFAEC3C3);

    var titleVerBounds:Float = phoneBack.y + 24 * scale;
    var generalWidth:Int = 312;
    var optionsBox:FlxSprite = new FlxSprite(phoneBack.x + generalWidth, phoneBack.y + phoneBack.height).makeGraphic(phoneBack.width - generalWidth, phoneBack.height - titleVerBounds, FlxColor.WHITE);
    optionsBox.y -= optionsBox.height;
    optionsBox.alpha = 0.2;
    optionsBox.blend = 0;

    var phoneTitle:FunkinText = new FunkinText(phoneBack.x - 8 * scale, (phoneBack.y + titleVerBounds) / 2, phoneBack.width, "Options", 65, false);
    phoneTitle.font = Paths.font("pixeloidsans.ttf");
    phoneTitle.color = FlxColor.BLACK;
    phoneTitle.alignment = "right";
    phoneTitle.y -= phoneTitle.height / 2;
    phoneTitle.blend = 9;
    phoneTitle.alpha = 0.6;

    phoneScreen.add(phoneBack);
    phoneScreen.add(optionsBox);
    phoneScreen.add(phoneTitle);

    categoriesGroup = new FlxTypedSpriteGroup(0, titleVerBounds);
    phoneScreen.add(categoriesGroup);

    var categoriesHeight:Float = optionsBox.height / categories.length;
    //trace(categoriesHeight);
    for (i in 0...categories.length) {
        var categoryGrp:FlxTypedSpriteGroup = new FlxTypedSpriteGroup(0, categoriesHeight * i);
        categoriesGroup.add(categoryGrp);

        var bg:FlxSprite = new FlxSprite().makeGraphic(generalWidth, categoriesHeight, FlxColor.WHITE);
        bg.color = FlxColor.BLACK;
        bg.blend = 9;
        bg.alpha = 0.6;
        categoryGrp.add(bg);

        var title:FunkinText = new FunkinText(0, bg.height / 2, bg.width, categories[i], 33, false);
        title.font = Paths.font("pixeloidsans.ttf");
        title.color = FlxColor.BLACK;
        title.alignment = "center";
        title.y -= title.height / 2;
        categoryGrp.add(title);
    }

    startTxt = new FunkinText(generalWidth, titleVerBounds + optionsBox.height / 2, optionsBox.width, "Select a category to continue", 32, false);
    startTxt.alignment = "center";
    startTxt.font = Paths.font("pixeloidsans.ttf");
    startTxt.color = FlxColor.BLACK;
    startTxt.y -= startTxt.height / 2;
    phoneScreen.add(startTxt);

    categoryBounds = [0, titleVerBounds, optionsBox.width, optionsBox.height];
    curCategoryGrp = new FlxTypedSpriteGroup(generalWidth, titleVerBounds);
    phoneScreen.add(curCategoryGrp);

    descriptionGroup = new FlxTypedSpriteGroup(generalWidth, titleVerBounds);
    phoneScreen.add(descriptionGroup);

    var descPos:Float = optionsBox.height;
    var descBox:FlxSprite = new FlxSprite(0, descPos).makeGraphic(optionsBox.width, 128, FlxColor.BLACK);
    descBox.alpha = 0.4;
    descBox.y -= descBox.height / 3;
    descriptionGroup.add(descBox);
    categoryBounds[0] = descBox.y - 720;

    var descTxt:FunkinText = new FunkinText(0, descPos - (descBox.height / 3) / 2, descBox.width, "Lorem ipsum dolor sit amet", 18);
    descTxt.font = Paths.font("pixelarial-bold.ttf");
    descTxt.borderSize = 3;
    descTxt.alignment = "center";
    descTxt.y -= descTxt.height / 2.5;
    descriptionGroup.add(descTxt);

    //descriptionGroup.y -= descriptionGroup.height;

    closeButton = new FlxSprite(phoneSpr.x - 4 * scale, 0).loadGraphic(Paths.image("menus/mainmenu/x"));
    closeButton.scale.set(scale, scale);
    closeButton.updateHitbox();
    closeButton.camera = optionsCam;
    theEntireThing.add(closeButton);

    if (closeButton.x < 0) closeButton.x = 0;

    FlxTween.tween(theEntireThing, {y: 0}, 0.4, {ease: FlxEase.quartOut, onComplete: _ -> {
        canInteract = true;
    }});

    updateCategory();
}

function removeExtension(s:String):String {
    var dividedString:Array<String> = s.split(".");
    return dividedString[0];
}

function postCreate() {
    if (!FlxG.onMobile) FlxG.mouse.visible = true;
}

// prevents from opening a category IMMEDIATLY after opening this substate
var canInteract:Bool = false;
function update(elapsed:Float) {
    if (!canInteract) return;

    handleOptions();
    checkFinishedCheckboxAnim();

    handleKeyboard();
    if (FlxG.onMobile)
        handleTouch();
    else
        handleMouse();
}

var usingKeyboard:Bool = true;
function handleKeyboard() {
    if (controls.UP_P)
        changeOptionSelec(-1);
    if (controls.DOWN_P)
        changeOptionSelec(1);

    if (controls.SWITCHMOD) {
        useKeyboard();
        curCategoryIndex = FlxMath.wrap(curCategoryIndex + (FlxG.keys.pressed.SHIFT ? -1 : 1), 0, categoriesGroup.members.length - 1);
        updateCategory();
    }

    if (controls.LEFT_P)
        useKeyboard();
    if (controls.RIGHT_P)
        useKeyboard();

    if (controls.BACK)
        closeOptions();
}

function useKeyboard() {
    usingKeyboard = true;
    closeButton.visible = false;
    FlxG.mouse.visible = false;
}

var hoveringOverCategory:Bool = false;
function handleMouse() {
    if (FlxG.mouse.justMoved) {
        usingKeyboard = false;
        FlxG.mouse.visible = true;
        if (canInteract) closeButton.visible = true;
    }

    if (usingKeyboard) return;

    hoveringOverCategory = false;

    for (i => category in categoriesGroup.members) {
        if (FlxG.mouse.overlaps(category.members[0])) {
            hoveringOverCategory = true;
            if (FlxG.mouse.justReleased) {
                curCategoryIndex = i;
                updateCategory();
            }
        }
    }

    for (i => group in curCategoryGrp.members) {
        if (FlxG.mouse.overlaps(group.members[0])) {
            curOption = i;
            playSound();
        }
    }

    if (FlxG.mouse.overlaps(closeButton)) {
        hoveringOverCategory = true;
        if (FlxG.mouse.justReleased) {
            closeOptions();
        }
    }
}

function handleTouch() {
    if (usingKeyboard) return;

    hoveringOverCategory = false;

    for (touch in FlxG.touches.list) {
        for (i => category in categoriesGroup.members) {
            if (touch.overlaps(category.members[0])) {
                hoveringOverCategory = true;
                if (touch.justReleased) {
                    curCategoryIndex = i;
                    updateCategory();
                }
            }
        }

        if (touch.overlaps(closeButton)) {
            hoveringOverCategory = true;
            if (touch.justReleased) {
                closeOptions();
            }
        }
    }
}

function changeOptionSelec(change:Int) {
    useKeyboard();
    curOption = FlxMath.wrap(curOption + change, 0, curCategoryOptions.length - 1);
    playSound();

    curCheckbox = null;
    checkboxValue = null;
}

function handleOptions() {
    for (i => group in curCategoryGrp.members) {
        if (i == curOption) {
            group.members[0].alpha = 0.1;

            if (curCategoryOptions[i].type == "bool") {
                handleBoolean(i, group.members[2]);
            }
            if (curCategoryOptions[i].type == "integer") {
                group.members[2].visible = true;
                group.members[3].visible = true;
                handleAdditions(i, group.members[2], group.members[3], group.members[5]);
            }
            if (curCategoryOptions[i].type == "percent") {
                group.members[2].visible = true;
                group.members[3].visible = true;
                handlePercentage(i, group.members[2], group.members[3], group.members[5]);
            }
            if (curCategoryOptions[i].type == "choice") {
                group.members[2].visible = true;
                group.members[3].visible = true;
                handleChoices(i, group.members[2], group.members[3], group.members[5]);
            }
            if (curCategoryOptions[i].type == "function") {
                handleFunction(i);
            }
        }
        else {
            group.members[0].alpha = 0;

            if (curCategoryOptions[i].type == "integer" || curCategoryOptions[i].type == "percent" || curCategoryOptions[i].type == "choice") {
                group.members[2].visible = false;
                group.members[3].visible = false;
            }
        }
    }

    updateDescription();
}

function updateDescription() {
    if (categories[curCategoryIndex] == "Options" || curCategoryOptions != null && curCategoryOptions.length < 1) {
        descriptionGroup.members[0].visible = false;
        descriptionGroup.members[1].visible = false;
    }
    else {
        try {
            descriptionGroup.members[0].visible = true;
            descriptionGroup.members[1].visible = true;

            descriptionGroup.members[1].text = curCategoryOptions[curOption].description;

            var posBox:Float = 138;
            var posTxt:Float = 138;
            var mult:Int = 1;
            var offset:Float = 0;
            if (descriptionGroup.members[1].height > 32) {
                posBox -= 30;
                posTxt -= 32;
                mult *= 2;
                offset += 3;
            }
            if (descriptionGroup.members[1].height > 60) {
                posBox -= 30;
                posTxt -= 32;
                mult *= 2;
                offset += 1;
            }
            if (descriptionGroup.members[1].height > 88) {
                posBox -= 30;
                posTxt -= 32;
                mult *= 2;
            }

            descriptionGroup.members[0].y = categoryBounds[0] + posBox - descriptionGroup.members[0].height;
            descriptionGroup.members[1].y = categoryBounds[0] + posTxt - descriptionGroup.members[0].height + (2 * mult) + offset;
        }
        catch(e:Dynamic) {
            descriptionGroup.members[0].visible = false;
            descriptionGroup.members[1].visible = false;
        }
    }
}

var curCheckbox:FlxSprite;
var checkboxValue:Null<Bool> = null;
function checkFinishedCheckboxAnim() {
    if (curCheckbox == null && checkboxValue == null) return;

    if (curCheckbox.animation.finished) {
        curCheckbox.animation.play(Std.string(checkboxValue));
    }
}

function handleBoolean(position:Int, checkbox:FlxSprite) {
    if (usingKeyboard) {
        if (controls.ACCEPT) {
            FlxG.sound.play(Paths.sound("menu/select"), 1);

            var value:Bool;
            if (StringTools.endsWith(checkbox.animation.name, "true")) value = true;
            if (StringTools.endsWith(checkbox.animation.name, "false")) value = false;

            var newValue:Bool = !value;
            curCategory.call("onChangeBool", [position, newValue]);

            checkbox.animation.play("trans " + Std.string(newValue), true);
            curCheckbox = checkbox;
            checkboxValue = newValue;
        }
        return;
    }

    if (hoveringOverCategory) return;

    if (FlxG.onMobile) {
        for (touch in FlxG.touches.list) {
            if (touch.overlaps(curCategoryGrp.members[position].members[0]) && touch.justReleased) {
                FlxG.sound.play(Paths.sound("menu/select"), 1);

                var value:Bool;
                if (StringTools.endsWith(checkbox.animation.name, "true")) value = true;
                if (StringTools.endsWith(checkbox.animation.name, "false")) value = false;

                var newValue:Bool = !value;
                curCategory.call("onChangeBool", [position, newValue]);

                checkbox.animation.play("trans " + Std.string(newValue), true);
                curCheckbox = checkbox;
                checkboxValue = newValue;
            }
        }
    }
    else {
        if (FlxG.mouse.overlaps(curCategoryGrp.members[position].members[0]) && FlxG.mouse.justReleased) {
            FlxG.sound.play(Paths.sound("menu/select"), 1);

            var value:Bool;
            if (StringTools.endsWith(checkbox.animation.name, "true")) value = true;
            if (StringTools.endsWith(checkbox.animation.name, "false")) value = false;

            var newValue:Bool = !value;
            curCategory.call("onChangeBool", [position, newValue]);

            checkbox.animation.play("trans " + Std.string(newValue), true);
            curCheckbox = checkbox;
            checkboxValue = newValue;
        }
    }
}

var optHoldTimer:Float = 0;
var optMaxHeldTime:Float = 0.5;
var optFrameDelayer:Int = 0;
var optMaxDelay:Int = 5;
function handleAdditions(position:Int, subtractBtn:FlxSprite, addBtn:FlxSprite, valueTxt:FunkinText) {
    if (usingKeyboard) {
        if (controls.LEFT) {
            subtractBtn.animation.play("press");
            if (optHoldTimer >= optMaxHeldTime) {
                if (optFrameDelayer >= optMaxDelay) {
                    FlxG.sound.play(Paths.sound("menu/select"), 1);

                    var integer:Int = Std.parseInt(valueTxt.text);
                    var newValue:Int = integer - curCategoryOptions[position].change;
                    if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
                    valueTxt.text = Std.string(newValue);

                    curCategory.call("onChangeInt", [position, newValue]);

                    optFrameDelayer = 0;
                }
                else
                    optFrameDelayer++;

                if (optHoldTimer >= optMaxHeldTime * 3)
                    optMaxDelay = 2;
                if (optHoldTimer >= optMaxHeldTime * 6)
                    optMaxDelay = 1;
                if (optHoldTimer >= optMaxHeldTime * 9)
                    optMaxDelay = 0;
            }
            optHoldTimer += FlxG.elapsed;
        }
        else if (controls.LEFT_R) {
            subtractBtn.animation.play("idle");
            FlxG.sound.play(Paths.sound("menu/select"), 1);

            var integer:Int = Std.parseInt(valueTxt.text);
            var newValue:Int = integer - curCategoryOptions[position].change;
            if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
            valueTxt.text = Std.string(newValue);

            curCategory.call("onChangeInt", [position, newValue]);
        }
        else if (controls.RIGHT) {
            addBtn.animation.play("press");
            if (optHoldTimer >= optMaxHeldTime) {
                if (optFrameDelayer >= optMaxDelay) {
                    FlxG.sound.play(Paths.sound("menu/select"), 1);

                    var integer:Int = Std.parseInt(valueTxt.text);
                    var newValue:Int = integer + curCategoryOptions[position].change;
                    if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
                    valueTxt.text = Std.string(newValue);

                    curCategory.call("onChangeInt", [position, newValue]);

                    optFrameDelayer = 0;
                }
                else
                    optFrameDelayer++;

                if (optHoldTimer >= optMaxHeldTime * 3)
                    optMaxDelay = 2;
                if (optHoldTimer >= optMaxHeldTime * 6)
                    optMaxDelay = 1;
                if (optHoldTimer >= optMaxHeldTime * 9)
                    optMaxDelay = 0;
            }
            optHoldTimer += FlxG.elapsed;
        }
        else if (controls.RIGHT_R) {
            addBtn.animation.play("idle");
            FlxG.sound.play(Paths.sound("menu/select"), 1);

            var integer:Int = Std.parseInt(valueTxt.text);
            var newValue:Int = integer + curCategoryOptions[position].change;
            if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
            valueTxt.text = Std.string(newValue);

            curCategory.call("onChangeInt", [position, newValue]);
        }
        else {
            subtractBtn.animation.play("idle");
            addBtn.animation.play("idle");
            optHoldTimer = 0;
            optMaxDelay = 5;
        }

        return;
    }
    if (FlxG.onMobile) {
        for (touch in FlxG.touches.list) {
            if (touch.overlaps(subtractBtn)) {
                if (touch.pressed) {
                    subtractBtn.animation.play("press");
                    if (optHoldTimer >= optMaxHeldTime) {
                        if (optFrameDelayer >= optMaxDelay) {
                            FlxG.sound.play(Paths.sound("menu/select"), 1);

                            var integer:Int = Std.parseInt(valueTxt.text);
                            var newValue:Int = integer - curCategoryOptions[position].change;
                            if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
                            valueTxt.text = Std.string(newValue);

                            curCategory.call("onChangeInt", [position, newValue]);

                            optFrameDelayer = 0;
                        }
                        else
                            optFrameDelayer++;

                        if (optHoldTimer >= optMaxHeldTime * 3)
                            optMaxDelay = 2;
                        if (optHoldTimer >= optMaxHeldTime * 6)
                            optMaxDelay = 1;
                        if (optHoldTimer >= optMaxHeldTime * 9)
                            optMaxDelay = 0;
                    }
                    optHoldTimer += FlxG.elapsed;
                }
                else if (touch.justReleased) {
                    subtractBtn.animation.play("idle");
                    FlxG.sound.play(Paths.sound("menu/select"), 1);

                    var integer:Int = Std.parseInt(valueTxt.text);
                    var newValue:Int = integer - curCategoryOptions[position].change;
                    if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
                    valueTxt.text = Std.string(newValue);

                    curCategory.call("onChangeInt", [position, newValue]);
                }
                else {
                    subtractBtn.animation.play("idle");
                    optHoldTimer = 0;
                    optMaxDelay = 5;
                }
            }
            else {
                subtractBtn.animation.play("idle");
            }

            if (touch.overlaps(addBtn)) {
                if (touch.pressed) {
                    addBtn.animation.play("press");
                    if (optHoldTimer >= optMaxHeldTime) {
                        if (optFrameDelayer >= optMaxDelay) {
                            FlxG.sound.play(Paths.sound("menu/select"), 1);

                            var integer:Int = Std.parseInt(valueTxt.text);
                            var newValue:Int = integer + curCategoryOptions[position].change;
                            if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
                            valueTxt.text = Std.string(newValue);

                            curCategory.call("onChangeInt", [position, newValue]);

                            optFrameDelayer = 0;
                        }
                        else
                            optFrameDelayer++;

                        if (optHoldTimer >= optMaxHeldTime * 3)
                            optMaxDelay = 2;
                        if (optHoldTimer >= optMaxHeldTime * 6)
                            optMaxDelay = 1;
                        if (optHoldTimer >= optMaxHeldTime * 9)
                            optMaxDelay = 0;
                    }
                    optHoldTimer += FlxG.elapsed;
                }
                else if (touch.justReleased) {
                    addBtn.animation.play("idle");
                    FlxG.sound.play(Paths.sound("menu/select"), 1);

                    var integer:Int = Std.parseInt(valueTxt.text);
                    var newValue:Int = integer + curCategoryOptions[position].change;
                    if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
                    valueTxt.text = Std.string(newValue);

                    curCategory.call("onChangeInt", [position, newValue]);
                }
                else {
                    addBtn.animation.play("idle");
                    optHoldTimer = 0;
                    optMaxDelay = 5;
                }
            }
            else {
                addBtn.animation.play("idle");
            }
        }
    }
    else {
        if (FlxG.mouse.overlaps(subtractBtn)) {
            if (FlxG.mouse.pressed) {
                subtractBtn.animation.play("press");
                if (optHoldTimer >= optMaxHeldTime) {
                    if (optFrameDelayer >= optMaxDelay) {
                        FlxG.sound.play(Paths.sound("menu/select"), 1);

                        var integer:Int = Std.parseInt(valueTxt.text);
                        var newValue:Int = integer - curCategoryOptions[position].change;
                        if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
                        valueTxt.text = Std.string(newValue);

                        curCategory.call("onChangeInt", [position, newValue]);

                        optFrameDelayer = 0;
                    }
                    else
                        optFrameDelayer++;

                    if (optHoldTimer >= optMaxHeldTime * 3)
                        optMaxDelay = 2;
                    if (optHoldTimer >= optMaxHeldTime * 6)
                        optMaxDelay = 1;
                    if (optHoldTimer >= optMaxHeldTime * 9)
                        optMaxDelay = 0;
                }
                optHoldTimer += FlxG.elapsed;
            }
            else if (FlxG.mouse.justReleased) {
                subtractBtn.animation.play("idle");
                FlxG.sound.play(Paths.sound("menu/select"), 1);

                var integer:Int = Std.parseInt(valueTxt.text);
                var newValue:Int = integer - curCategoryOptions[position].change;
                if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
                valueTxt.text = Std.string(newValue);

                curCategory.call("onChangeInt", [position, newValue]);
            }
            else {
                subtractBtn.animation.play("idle");
                optHoldTimer = 0;
                optMaxDelay = 5;
            }
        }
        else {
            subtractBtn.animation.play("idle");
        }

        if (FlxG.mouse.overlaps(addBtn)) {
            if (FlxG.mouse.pressed) {
                addBtn.animation.play("press");
                if (optHoldTimer >= optMaxHeldTime) {
                    if (optFrameDelayer >= optMaxDelay) {
                        FlxG.sound.play(Paths.sound("menu/select"), 1);

                        var integer:Int = Std.parseInt(valueTxt.text);
                        var newValue:Int = integer + curCategoryOptions[position].change;
                        if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
                        valueTxt.text = Std.string(newValue);

                        curCategory.call("onChangeInt", [position, newValue]);

                        optFrameDelayer = 0;
                    }
                    else
                        optFrameDelayer++;

                    if (optHoldTimer >= optMaxHeldTime * 3)
                        optMaxDelay = 2;
                    if (optHoldTimer >= optMaxHeldTime * 6)
                        optMaxDelay = 1;
                    if (optHoldTimer >= optMaxHeldTime * 9)
                        optMaxDelay = 0;
                }
                optHoldTimer += FlxG.elapsed;
            }
            else if (FlxG.mouse.justReleased) {
                addBtn.animation.play("idle");
                FlxG.sound.play(Paths.sound("menu/select"), 1);

                var integer:Int = Std.parseInt(valueTxt.text);
                var newValue:Int = integer + curCategoryOptions[position].change;
                if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
                valueTxt.text = Std.string(newValue);

                curCategory.call("onChangeInt", [position, newValue]);
            }
            else {
                addBtn.animation.play("idle");
                optHoldTimer = 0;
                optMaxDelay = 5;
            }
        }
        else {
            addBtn.animation.play("idle");
        }
    }
}

function handlePercentage(position:Int, subtractBtn:FlxSprite, addBtn:FlxSprite, valueTxt:FunkinText) {
    if (usingKeyboard) {
        if (controls.LEFT) {
            subtractBtn.animation.play("press");
            if (optHoldTimer >= optMaxHeldTime) {
                if (optFrameDelayer >= optMaxDelay) {
                    FlxG.sound.play(Paths.sound("menu/select"), 1);

                    var float:Float = Std.parseFloat(valueTxt.text) / 100;
                    var newValue:Float = float - 0.05;
                    if (newValue < 0) newValue = 0;
                    valueTxt.text = Std.string(newValue * 100);

                    curCategory.call("onChangeFloat", [position, newValue]);

                    optFrameDelayer = 0;
                }
                else
                    optFrameDelayer++;
            }
            else
                optHoldTimer += FlxG.elapsed;
        }
        else if (controls.LEFT_R) {
            subtractBtn.animation.play("idle");
            FlxG.sound.play(Paths.sound("menu/select"), 1);

            var float:Float = Std.parseFloat(valueTxt.text) / 100;
            var newValue:Float = float - 0.05;
            if (newValue < 0) newValue = 0;
            valueTxt.text = Std.string(newValue * 100);

            curCategory.call("onChangeFloat", [position, newValue]);
        }
        else if (controls.RIGHT) {
            addBtn.animation.play("press");
            if (optHoldTimer >= optMaxHeldTime) {
                if (optFrameDelayer >= optMaxDelay) {
                    FlxG.sound.play(Paths.sound("menu/select"), 1);

                    var float:Float = Std.parseFloat(valueTxt.text) / 100;
                    var newValue:Float = float + 0.05;
                    if (newValue > 1) newValue = 1;
                    valueTxt.text = Std.string(newValue * 100);

                    curCategory.call("onChangeFloat", [position, newValue]);

                    optFrameDelayer = 0;
                }
                else
                    optFrameDelayer++;
            }
            else
                optHoldTimer += FlxG.elapsed;
        }
        else if (controls.RIGHT_R) {
            addBtn.animation.play("idle");
            FlxG.sound.play(Paths.sound("menu/select"), 1);

            var float:Float = Std.parseFloat(valueTxt.text) / 100;
            var newValue:Float = float + 0.05;
            if (newValue > 1) newValue = 1;
            valueTxt.text = Std.string(newValue * 100);

            curCategory.call("onChangeFloat", [position, newValue]);
        }
        else {
            subtractBtn.animation.play("idle");
            addBtn.animation.play("idle");
            optHoldTimer = 0;
        }

        return;
    }
    if (FlxG.onMobile) {
        for (touch in FlxG.touches.list) {
            if (touch.overlaps(subtractBtn)) {
                if (touch.pressed) {
                    subtractBtn.animation.play("press");
                    if (optHoldTimer >= optMaxHeldTime) {
                        if (optFrameDelayer >= optMaxDelay) {
                            FlxG.sound.play(Paths.sound("menu/select"), 1);

                            var float:Float = Std.parseFloat(valueTxt.text) / 100;
                            var newValue:Float = float - 0.05;
                            if (newValue < 0) newValue = 0;
                            valueTxt.text = Std.string(newValue * 100);

                            curCategory.call("onChangeFloat", [position, newValue]);

                            optFrameDelayer = 0;
                        }
                        else
                            optFrameDelayer++;
                    }
                    else
                        optHoldTimer += FlxG.elapsed;
                }
                else if (touch.justReleased) {
                    subtractBtn.animation.play("idle");
                    FlxG.sound.play(Paths.sound("menu/select"), 1);

                    var float:Float = Std.parseFloat(valueTxt.text) / 100;
                    var newValue:Float = float - 0.05;
                    if (newValue < 0) newValue = 0;
                    valueTxt.text = Std.string(newValue * 100);

                    curCategory.call("onChangeFloat", [position, newValue]);
                }
                else {
                    subtractBtn.animation.play("idle");
                    optHoldTimer = 0;
                }
            }
            else {
                subtractBtn.animation.play("idle");
            }

            if (touch.overlaps(addBtn)) {
                if (touch.pressed) {
                    addBtn.animation.play("press");
                    if (optHoldTimer >= optMaxHeldTime) {
                        if (optFrameDelayer >= optMaxDelay) {
                            FlxG.sound.play(Paths.sound("menu/select"), 1);

                            var float:Float = Std.parseFloat(valueTxt.text) / 100;
                            var newValue:Float = float + 0.05;
                            if (newValue > 1) newValue = 1;
                            valueTxt.text = Std.string(newValue * 100);

                            curCategory.call("onChangeFloat", [position, newValue]);

                            optFrameDelayer = 0;
                        }
                        else
                            optFrameDelayer++;
                    }
                    else
                        optHoldTimer += FlxG.elapsed;
                }
                else if (touch.justReleased) {
                    addBtn.animation.play("idle");
                    FlxG.sound.play(Paths.sound("menu/select"), 1);

                    var float:Float = Std.parseFloat(valueTxt.text) / 100;
                    var newValue:Float = float + 0.05;
                    if (newValue > 1) newValue = 1;
                    valueTxt.text = Std.string(newValue * 100);

                    curCategory.call("onChangeFloat", [position, newValue]);
                }
                else {
                    addBtn.animation.play("idle");
                    optHoldTimer = 0;
                }
            }
            else {
                addBtn.animation.play("idle");
            }
        }
    }
    else {
        if (FlxG.mouse.overlaps(subtractBtn)) {
            if (FlxG.mouse.pressed) {
                subtractBtn.animation.play("press");
                if (optHoldTimer >= optMaxHeldTime) {
                    if (optFrameDelayer >= optMaxDelay) {
                        FlxG.sound.play(Paths.sound("menu/select"), 1);

                        var float:Float = Std.parseFloat(valueTxt.text) / 100;
                        var newValue:Float = float - 0.05;
                        if (newValue < 0) newValue = 0;
                        valueTxt.text = Std.string(newValue * 100);

                        curCategory.call("onChangeFloat", [position, newValue]);

                        optFrameDelayer = 0;
                    }
                    else
                        optFrameDelayer++;
                }
                else
                    optHoldTimer += FlxG.elapsed;
            }
            else if (FlxG.mouse.justReleased) {
                subtractBtn.animation.play("idle");
                FlxG.sound.play(Paths.sound("menu/select"), 1);

                var float:Float = Std.parseFloat(valueTxt.text) / 100;
                var newValue:Float = float - 0.05;
                if (newValue < 0) newValue = 0;
                valueTxt.text = Std.string(newValue * 100);

                curCategory.call("onChangeFloat", [position, newValue]);
            }
            else {
                subtractBtn.animation.play("idle");
                optHoldTimer = 0;
            }
        }
        else {
            subtractBtn.animation.play("idle");
        }

        if (FlxG.mouse.overlaps(addBtn)) {
            if (FlxG.mouse.pressed) {
                addBtn.animation.play("press");
                if (optHoldTimer >= optMaxHeldTime) {
                    if (optFrameDelayer >= optMaxDelay) {
                        FlxG.sound.play(Paths.sound("menu/select"), 1);

                        var float:Float = Std.parseFloat(valueTxt.text) / 100;
                        var newValue:Float = float + 0.05;
                        if (newValue > 1) newValue = 1;
                        valueTxt.text = Std.string(newValue * 100);

                        curCategory.call("onChangeFloat", [position, newValue]);

                        optFrameDelayer = 0;
                    }
                    else
                        optFrameDelayer++;
                }
                else
                    optHoldTimer += FlxG.elapsed;
            }
            else if (FlxG.mouse.justReleased) {
                addBtn.animation.play("idle");
                FlxG.sound.play(Paths.sound("menu/select"), 1);

                var float:Float = Std.parseFloat(valueTxt.text) / 100;
                var newValue:Float = float + 0.05;
                if (newValue > 1) newValue = 1;
                valueTxt.text = Std.string(newValue * 100);

                curCategory.call("onChangeFloat", [position, newValue]);
            }
            else {
                addBtn.animation.play("idle");
                optHoldTimer = 0;
            }
        }
        else {
            addBtn.animation.play("idle");
        }
    }
}

function handleChoices(position:Int, leftBtn:FlxSprite, rightBtn:FlxSprite, valueTxt:FunkinText) {
    if (usingKeyboard) {
        if (controls.LEFT) {
            leftBtn.animation.play("press");
        }
        else if (controls.LEFT_R) {
            leftBtn.animation.play("idle");
            /*
            FlxG.sound.play(Paths.sound("menu/select"), 1);

            var integer:Int = Std.parseInt(valueTxt.text);
            var newValue:Int = integer - curCategoryOptions[position].change;
            if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
            valueTxt.text = Std.string(newValue);

            curCategory.call("onChangeChoice", [position, newValue]);
            */
        }
        else if (controls.RIGHT) {
            rightBtn.animation.play("press");
        }
        else if (controls.RIGHT_R) {
            rightBtn.animation.play("idle");
            /*
            FlxG.sound.play(Paths.sound("menu/select"), 1);

            var integer:Int = Std.parseInt(valueTxt.text);
            var newValue:Int = integer + curCategoryOptions[position].change;
            if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
            valueTxt.text = Std.string(newValue);

            curCategory.call("onChangeChoice", [position, newValue]);
            */
        }
        else {
            leftBtn.animation.play("idle");
            rightBtn.animation.play("idle");
            optHoldTimer = 0;
        }

        return;
    }
    if (FlxG.onMobile) {
        for (touch in FlxG.touches.list) {
            if (touch.overlaps(subtractBtn)) {
                if (touch.pressed) {
                    subtractBtn.animation.play("press");
                }
                else if (touch.justReleased) {
                    subtractBtn.animation.play("idle");
                }
                else {
                    subtractBtn.animation.play("idle");
                    optHoldTimer = 0;
                }
            }
            else {
                subtractBtn.animation.play("idle");
            }

            if (touch.overlaps(addBtn)) {
                if (touch.pressed) {
                    addBtn.animation.play("press");
                }
                else if (touch.justReleased) {
                    addBtn.animation.play("idle");
                    FlxG.sound.play(Paths.sound("menu/select"), 1);
                }
                else {
                    addBtn.animation.play("idle");
                    optHoldTimer = 0;
                }
            }
            else {
                addBtn.animation.play("idle");
            }
        }
    }
    else {
        if (FlxG.mouse.overlaps(subtractBtn)) {
            if (FlxG.mouse.pressed) {
                subtractBtn.animation.play("press");
            }
            else if (FlxG.mouse.justReleased) {
                subtractBtn.animation.play("idle");
                FlxG.sound.play(Paths.sound("menu/select"), 1);
            }
            else {
                subtractBtn.animation.play("idle");
                optHoldTimer = 0;
            }
        }
        else {
            subtractBtn.animation.play("idle");
        }

        if (FlxG.mouse.overlaps(addBtn)) {
            if (FlxG.mouse.pressed) {
                addBtn.animation.play("press");
            }
            else if (FlxG.mouse.justReleased) {
                addBtn.animation.play("idle");
                FlxG.sound.play(Paths.sound("menu/select"), 1);
            }
            else {
                addBtn.animation.play("idle");
                optHoldTimer = 0;
            }
        }
        else {
            addBtn.animation.play("idle");
        }
    }
}

function handleFunction(position:Int) {
    if (usingKeyboard && controls.ACCEPT) {
        FlxG.sound.play(Paths.sound("menu/select"), 1);
        curCategory.call("onCallFunction", [position]);
    }
    if (FlxG.onMobile) {
        for (touch in FlxG.touches.list) {
            if (touch.overlaps(curCategoryGrp.members[position].members[0]) && touch.justReleased) {
                FlxG.sound.play(Paths.sound("menu/select"), 1);
                curCategory.call("onCallFunction", [position]);
            }
        }
    }
    else {
        if (FlxG.mouse.overlaps(curCategoryGrp.members[position].members[0]) && FlxG.mouse.justReleased) {
            FlxG.sound.play(Paths.sound("menu/select"), 1);
            curCategory.call("onCallFunction", [position]);
        }
    }
}

function playSound() {
    if (curOption != lastOption) {
        CoolUtil.playMenuSFX(0);
        lastOption = curOption;
    }
}

function changeCategory(change:Int) {
    curCategoryIndex = FlxMath.wrap(curCategoryIndex + change, 0, categories.length - 1);
    updateCategory();
}

function updateCategory() {
    if (lastCategoryIndex != curCategoryIndex) {
        FlxG.sound.play(Paths.sound("menu/select"), 1);
        lastCategoryIndex = curCategoryIndex;
        curOption = 0;
        lastOption = 0;
        curCheckbox = null;
        checkboxValue = null;
        descriptionGroup.visible = true;

        deleteCategory();

        if (curCategory != null) {
            curCategory.destroy();
        }
        curCategory = Script.create(Paths.script("data/states/options/" + categories[curCategoryIndex]));
        curCategory.setParent(this);
        curCategory.load();
        curCategoryOptions = curCategory.get("options");
        if (FlxG.onMobile && categories[curCategoryIndex] == "Gameplay") {
            curCategoryOptions.insert(1, {
                name: "Middlescroll",
                description: "If checked, your notes will be centered.",
                type: "bool",
                savevar: "middlescroll",
                savepoint: FlxG.save.data
            });
        }

        for (i => category in categoriesGroup.members) {
            if (i == curCategoryIndex) {
                category.members[0].color = FlxColor.WHITE;
                category.members[0].alpha = 0.2;
                category.members[0].blend = 0;
            }
            else {
                category.members[0].color = FlxColor.BLACK;
                category.members[0].alpha = 0.6;
                category.members[0].blend = 9;
            }
        }

        startTxt.visible = false;

        createCategory();
    }
    else {
        CoolUtil.playMenuSFX(2);
        lastCategoryIndex = -1;
        curCategoryIndex = -1;
        curOption = 0;
        lastOption = -1;
        curCheckbox = null;
        checkboxValue = null;
        descriptionGroup.visible = false;

        deleteCategory();

        if (curCategory != null) {
            curCategory.call("destroy");
            curCategory.destroy();
            curCategory = null;
        }

        for (i => category in categoriesGroup.members) {
            category.members[0].color = FlxColor.BLACK;
            category.members[0].alpha = 0.6;
            category.members[0].blend = 9;
        }

        startTxt.visible = true;
    }
}

var curCategoryOptions:Array<Dynamic> = [];
function createCategory() {
    for (i in 0...curCategoryOptions.length) {
        var group:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
        curCategoryGrp.add(group);

        var height:Float = 52;
        var iHeight:Float = height * i; // this is necessary otherwise positions will get fucked up
        var x:Float = 0;
        var bg:FlxSprite = new FlxSprite(x, iHeight).makeGraphic(categoryBounds[2], Std.int(height), FlxColor.BLACK);
        bg.alpha = 0;
        bg.blend = 9;
        group.add(bg);

        var label:FunkinText = new FunkinText(x + 12, iHeight + bg.height / 2, 0, curCategoryOptions[i].name, 30);
        label.font = Paths.font("yoster-island.ttf");
        label.borderSize = 3;
        label.y -= label.height / 2;
        group.add(label);

        var optionTypeScale:Float = 2;
        if (curCategoryOptions[i].type == "bool") {
            var checkbox:FlxSprite = new FlxSprite(x + bg.width, iHeight + bg.height / 2);
            checkbox.frames = Paths.getFrames("menus/options/checkbox");
            checkbox.animation.addByPrefix("false", "idle false", 0, true);
            checkbox.animation.addByPrefix("trans true", "transition true", 24, false);
            checkbox.animation.addByPrefix("true", "idle true", 0, true);
            checkbox.animation.addByPrefix("trans false", "transition false", 24, false);
            checkbox.animation.play(Std.string(Reflect.getProperty(curCategoryOptions[i].savepoint, curCategoryOptions[i].savevar)));
            checkbox.scale.set(optionTypeScale, optionTypeScale);
            checkbox.updateHitbox();
            checkbox.x -= checkbox.width;
            checkbox.y -= checkbox.height / 1.5;
            group.add(checkbox);
        }
        else if (curCategoryOptions[i].type == "integer") {
            var inputBox:FlxSprite = new FlxSprite(x + bg.width - 2 * optionTypeScale, iHeight + bg.height / 2).loadGraphic(Paths.image("menus/options/inputBox"));
            inputBox.scale.set(optionTypeScale, optionTypeScale);
            inputBox.updateHitbox();
            inputBox.x -= inputBox.width;
            inputBox.y -= inputBox.height / 2;

            var rightBtn:FlxSprite = new FlxSprite(inputBox.x - 2 * optionTypeScale, inputBox.y);
            rightBtn.frames = Paths.getFrames("menus/options/buttons");
            rightBtn.animation.addByIndices("idle", "add", [1], "", 0, true);
            rightBtn.animation.addByIndices("press", "add", [2], "", 0, true);
            rightBtn.animation.play("idle");
            rightBtn.scale.set(optionTypeScale, optionTypeScale);
            rightBtn.updateHitbox();
            rightBtn.x -= rightBtn.width;
            rightBtn.visible = false;

            var leftBtn:FlxSprite = new FlxSprite(rightBtn.x - 2 * optionTypeScale, rightBtn.y);
            leftBtn.frames = Paths.getFrames("menus/options/buttons");
            leftBtn.animation.addByIndices("idle", "subtract", [1], "", 0, true);
            leftBtn.animation.addByIndices("press", "subtract", [2], "", 0, true);
            leftBtn.animation.play("idle");
            leftBtn.scale.set(optionTypeScale, optionTypeScale);
            leftBtn.updateHitbox();
            leftBtn.x -= leftBtn.width;
            leftBtn.visible = false;

            // change this when new codename update arrives
            var inputTxt:FunkinText = new FunkinText(inputBox.x, inputBox.y, inputBox.width, "", 24);
            inputTxt.font = Paths.font("retrogaming.ttf");
            inputTxt.borderSize = 2.2;
            inputTxt.alignment = "center";
            inputTxt.text = Std.string(Reflect.getProperty(curCategoryOptions[i].savepoint, curCategoryOptions[i].savevar));

            group.add(leftBtn);
            group.add(rightBtn);
            group.add(inputBox);
            group.add(inputTxt);
        }
        else if (curCategoryOptions[i].type == "percent") {
            var inputBox:FlxSprite = new FlxSprite(x + bg.width - 2 * optionTypeScale, iHeight + bg.height / 2).loadGraphic(Paths.image("menus/options/percentBox"));
            inputBox.scale.set(optionTypeScale, optionTypeScale);
            inputBox.updateHitbox();
            inputBox.x -= inputBox.width;
            inputBox.y -= inputBox.height / 2;

            var rightBtn:FlxSprite = new FlxSprite(inputBox.x - 2 * optionTypeScale, inputBox.y);
            rightBtn.frames = Paths.getFrames("menus/options/buttons");
            rightBtn.animation.addByIndices("idle", "add", [1], "", 0, true);
            rightBtn.animation.addByIndices("press", "add", [2], "", 0, true);
            rightBtn.animation.play("idle");
            rightBtn.scale.set(optionTypeScale, optionTypeScale);
            rightBtn.updateHitbox();
            rightBtn.x -= rightBtn.width;
            rightBtn.visible = false;

            var leftBtn:FlxSprite = new FlxSprite(rightBtn.x - 2 * optionTypeScale, rightBtn.y);
            leftBtn.frames = Paths.getFrames("menus/options/buttons");
            leftBtn.animation.addByIndices("idle", "subtract", [1], "", 0, true);
            leftBtn.animation.addByIndices("press", "subtract", [2], "", 0, true);
            leftBtn.animation.play("idle");
            leftBtn.scale.set(optionTypeScale, optionTypeScale);
            leftBtn.updateHitbox();
            leftBtn.x -= leftBtn.width;
            leftBtn.visible = false;

            // change this when new codename update arrives
            var inputTxt:FunkinText = new FunkinText(inputBox.x, inputBox.y, inputBox.width - 15 * optionTypeScale, "", 24);
            inputTxt.font = Paths.font("retrogaming.ttf");
            inputTxt.borderSize = 2.2;
            inputTxt.alignment = "center";
            inputTxt.text = Std.string(Reflect.getProperty(curCategoryOptions[i].savepoint, curCategoryOptions[i].savevar) * 100);

            group.add(leftBtn);
            group.add(rightBtn);
            group.add(inputBox);
            group.add(inputTxt);
        }
        else if (curCategoryOptions[i].type == "choice") {
            var inputBox:FlxSprite = new FlxSprite(x + bg.width - 2 * optionTypeScale, iHeight + bg.height / 2).loadGraphic(Paths.image("menus/options/largeBox"));
            inputBox.scale.set(optionTypeScale, optionTypeScale);
            inputBox.updateHitbox();
            inputBox.x -= inputBox.width;
            inputBox.y -= inputBox.height / 2;

            var rightBtn:FlxSprite = new FlxSprite(inputBox.x - 2 * optionTypeScale, inputBox.y);
            rightBtn.frames = Paths.getFrames("menus/options/buttons");
            rightBtn.animation.addByIndices("idle", "right", [1], "", 0, true);
            rightBtn.animation.addByIndices("press", "right", [2], "", 0, true);
            rightBtn.animation.play("idle");
            rightBtn.scale.set(optionTypeScale, optionTypeScale);
            rightBtn.updateHitbox();
            rightBtn.x -= rightBtn.width;
            rightBtn.visible = false;

            var leftBtn:FlxSprite = new FlxSprite(rightBtn.x - 2 * optionTypeScale, rightBtn.y);
            leftBtn.frames = Paths.getFrames("menus/options/buttons");
            leftBtn.animation.addByIndices("idle", "left", [1], "", 0, true);
            leftBtn.animation.addByIndices("press", "left", [2], "", 0, true);
            leftBtn.animation.play("idle");
            leftBtn.scale.set(optionTypeScale, optionTypeScale);
            leftBtn.updateHitbox();
            leftBtn.x -= leftBtn.width;
            leftBtn.visible = false;

            // change this when new codename update arrives
            var inputTxt:FunkinText = new FunkinText(inputBox.x, inputBox.y, inputBox.width, "", 24);
            inputTxt.font = Paths.font("retrogaming.ttf");
            inputTxt.borderSize = 2.2;
            inputTxt.alignment = "center";
            inputTxt.text = Std.string(Reflect.getProperty(curCategoryOptions[i].savepoint, curCategoryOptions[i].savevar));

            group.add(leftBtn);
            group.add(rightBtn);
            group.add(inputBox);
            group.add(inputTxt);
        }
    }
}

function deleteCategory() {
    curCategoryGrp.clear();
}

function closeOptions() {
    CoolUtil.playMenuSFX(2);
    canInteract = false;
    FlxTween.tween(theEntireThing, {y: FlxG.height}, 0.4, {ease: FlxEase.quartIn, onComplete: _ -> {
        close();
    }});
}

function destroy() {
    if (curCategory != null)
        curCategory.destroy();

    FlxG.cameras.remove(optionsCam);
    optionsCam.destroy();
}