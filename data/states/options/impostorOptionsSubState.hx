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

var phoneSpr:FlxSprite;
var phoneScreen:FlxTypedSpriteGroup;
var categoriesGroup:FlxTypedSpriteGroup;

var selectionMode:String = "contents";
var categories:Array<String> = [];
var curCategory:Script;
var curCategoryIndex:Int = -1;
var lastCategoryIndex:Int = -1;
var categoryBounds:Array<Float> = [];
var curCategoryGrp:FlxTypedSpriteGroup;

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
    optionsCam.bgColor = 0x80000000;
    FlxG.cameras.add(optionsCam, false);

    phoneSpr = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image("menus/options/phone"));
    phoneSpr.scale.set(scale, scale);
    phoneSpr.updateHitbox();
    phoneSpr.camera = optionsCam;
    phoneSpr.x -= phoneSpr.width / 2;
    phoneSpr.y -= phoneSpr.height / 2;

    phoneScreen = new FlxTypedSpriteGroup(phoneSpr.x + 10 * scale, phoneSpr.y + 9 * scale);
    phoneScreen.camera = optionsCam;

    add(phoneScreen);
    add(phoneSpr);

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

    categoryBounds = [phoneBack.x + generalWidth, phoneBack.y + titleVerBounds, optionsBox.width, optionsBox.height];
    curCategoryGrp = new FlxTypedSpriteGroup(categoryBounds[0] - 70, categoryBounds[1] - 65);
    phoneScreen.add(curCategoryGrp);

    closeButton = new FlxSprite(phoneSpr.x - 4 * scale, phoneSpr.y - 4 * scale).loadGraphic(Paths.image("menus/mainmenu/x"));
    closeButton.scale.set(scale, scale);
    closeButton.updateHitbox();
    closeButton.camera = optionsCam;
    add(closeButton);

    if (closeButton.x < 0) closeButton.x = 0;
    if (closeButton.y < 0) closeButton.y = 0;
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
    if (curCategory != null)
        curCategory.call("update", [elapsed]);

    handleKeyboard();
    if (FlxG.onMobile)
        handleTouch();
    else
        handleMouse();
}

function handleKeyboard() {
    if (controls.BACK)
        closeOptions();
}

function handleMouse() {
    if (canInteract) {
        for (i => category in categoriesGroup.members) {
            if (FlxG.mouse.overlaps(category.members[0])) {
                if (FlxG.mouse.justReleased) {
                    curCategoryIndex = i;
                    updateCategory();
                }
            }
        }

        if (FlxG.mouse.overlaps(closeButton) && FlxG.mouse.justReleased) {
            closeOptions();
        }
    }

    if (FlxG.mouse.justReleased) canInteract = true;
}

function handleTouch() {
    if (canInteract) {
        for (touch in FlxG.touches.list) {
            for (i => category in categoriesGroup.members) {
                if (touch.overlaps(category.members[0])) {
                    if (touch.justReleased) {
                        curCategoryIndex = i;
                        updateCategory();
                    }
                }
            }

            if (touch.overlaps(closeButton) && touch.justReleased) {
                closeOptions();
            }
        }
    }

    for (touch in FlxG.touches.list)
        if (touch.justReleased) canInteract = true;
}

function changeCategory(change:Int) {
    curCategoryIndex = FlxMath.wrap(curCategoryIndex + change, 0, categories.length - 1);
    updateCategory();
}

function updateCategory() {
    if (lastCategoryIndex != curCategoryIndex) {
        FlxG.sound.play(Paths.sound("menu/select"), 1);
        lastCategoryIndex = curCategoryIndex;

        deleteCategory();

        if (curCategory != null) {
            curCategory.destroy();
        }
        curCategory = Script.create(Paths.script("data/states/options/" + categories[curCategoryIndex]));
        curCategory.setParent(this);
        curCategory.load();
        curCategoryOptions = curCategory.get("options");

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

            var leftBtn:FlxSprite = new FlxSprite(rightBtn.x - 2 * optionTypeScale, rightBtn.y);
            leftBtn.frames = Paths.getFrames("menus/options/buttons");
            leftBtn.animation.addByIndices("idle", "subtract", [1], "", 0, true);
            leftBtn.animation.addByIndices("press", "subtract", [2], "", 0, true);
            leftBtn.animation.play("idle");
            leftBtn.scale.set(optionTypeScale, optionTypeScale);
            leftBtn.updateHitbox();
            leftBtn.x -= leftBtn.width;

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

            var leftBtn:FlxSprite = new FlxSprite(rightBtn.x - 2 * optionTypeScale, rightBtn.y);
            leftBtn.frames = Paths.getFrames("menus/options/buttons");
            leftBtn.animation.addByIndices("idle", "subtract", [1], "", 0, true);
            leftBtn.animation.addByIndices("press", "subtract", [2], "", 0, true);
            leftBtn.animation.play("idle");
            leftBtn.scale.set(optionTypeScale, optionTypeScale);
            leftBtn.updateHitbox();
            leftBtn.x -= leftBtn.width;

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
    }
}

function deleteCategory() {
    curCategoryGrp.clear();
}

function closeOptions() {
    CoolUtil.playMenuSFX(2);
    close();
}

function destroy() {
    if (curCategory != null)
        curCategory.destroy();

    FlxG.cameras.remove(optionsCam);
    optionsCam.destroy();
}