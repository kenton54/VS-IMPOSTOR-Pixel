import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.math.FlxRect;
//import flixel.text.FlxInputText; // i need flixel +5.9.0 :face_holding_back_tears:
import funkin.backend.scripting.Script;
import funkin.backend.utils.TranslationUtil;
import funkin.options.Options;
import funkin.savedata.FunkinSave;
import openfl.filters.ShaderFilter;
import sys.FileSystem;
import BackButton;

var optionsCam:FlxCamera;

var startTxt:FunkinText;

var theEntireThing:FlxSpriteGroup; // this thing exists only for the tween intro LOL
var phoneSpr:FlxSprite;
var phoneScreen:FlxSpriteGroup;
var categoriesGroup:FlxSpriteGroup;
var descriptionGroup:FlxSpriteGroup;

var selectionMode:String = "contents";
var categories:Array<String> = [];
var curCategory:Script;
var curCategoryIndex:Int = -1;
var lastCategoryIndex:Int = -1;
var categoryBounds:Array<Float> = []; // its actually used for multiple things, not for what its var name stands for lol
var curCategoryGrp:FlxSpriteGroup;
var curOption:Int = 0;
var lastOption:Int = -1;

var volumeBeep:FlxSound;

var closeButton:BackButton;

var scale:Float = 5;
var generalWidth:Int = 312;

var lastLang:String = TranslationUtil.curLanguage;
var lastDev:Bool = Options.devMode;

static var lastCategory:Null<String> = null;

function create() {
    changeDiscordMenuStatus("Options Menu");

    createCategories();

    optionsCam = new FlxCamera();
    optionsCam.bgColor = 0x00000000;
    FlxG.cameras.add(optionsCam, false);

    theEntireThing = new FlxSpriteGroup(0, FlxG.height);
    add(theEntireThing);

    phoneSpr = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image("menus/options/phone"));
    phoneSpr.scale.set(scale, scale);
    phoneSpr.updateHitbox();
    phoneSpr.camera = optionsCam;
    phoneSpr.x -= phoneSpr.width / 2;
    phoneSpr.y -= phoneSpr.height / 2;

    phoneScreen = new FlxSpriteGroup(phoneSpr.x + 10 * scale, phoneSpr.y + 9 * scale);
    phoneScreen.camera = optionsCam;

    theEntireThing.add(phoneScreen);
    theEntireThing.add(phoneSpr);

    var heightCorrect:Float = phoneSpr.height - 9 * scale * 2;
    var boxWidth:Int = phoneSpr.width - 25 * scale;
    var phoneBack:FlxSprite = new FlxSprite().makeGraphic(boxWidth, heightCorrect, 0xFFAEC3C3);

    var titleVerBounds:Float = phoneBack.y + 24 * scale;
    var optionsBox:FlxSprite = new FlxSprite(phoneBack.x + generalWidth, phoneBack.y + phoneBack.height).makeGraphic(phoneBack.width - generalWidth, (phoneBack.height - titleVerBounds) + 4, FlxColor.WHITE);
    var optionsBoxHeight:Float = optionsBox.height - 4; // to prevent misplacements
    optionsBox.y -= optionsBoxHeight;
    optionsBox.alpha = 0.2;
    optionsBox.blend = 0;

    var phoneTitle:FunkinText = new FunkinText(phoneBack.x - 8 * scale, (phoneBack.y + titleVerBounds) / 2, phoneBack.width, translate("mainMenu.options"), 65, false);
    phoneTitle.font = Paths.font("pixeloidsans.ttf");
    phoneTitle.color = FlxColor.BLACK;
    phoneTitle.alignment = "right";
    phoneTitle.y -= phoneTitle.height / 2;
    phoneTitle.blend = 9;
    phoneTitle.alpha = 0.6;

    phoneScreen.add(phoneBack);
    phoneScreen.add(optionsBox);
    phoneScreen.add(phoneTitle);

    categoriesGroup = new FlxSpriteGroup(0, titleVerBounds);
    phoneScreen.add(categoriesGroup);

    rearrangeCategories();

    startTxt = new FunkinText(generalWidth, titleVerBounds + optionsBoxHeight / 2, optionsBox.width, translate("options.selectCategory"), 32, false);
    startTxt.alignment = "center";
    startTxt.font = Paths.font("pixeloidsans.ttf");
    startTxt.color = FlxColor.BLACK;
    startTxt.y -= startTxt.height / 2;
    phoneScreen.add(startTxt);

    categoryBounds = [0, titleVerBounds, optionsBox.width, optionsBoxHeight];
    curCategoryGrp = new FlxSpriteGroup(generalWidth, titleVerBounds);
    phoneScreen.add(curCategoryGrp);

    descriptionGroup = new FlxSpriteGroup(generalWidth, titleVerBounds);
    phoneScreen.add(descriptionGroup);

    var descPos:Float = optionsBoxHeight;
    var descBox:FlxSprite = new FlxSprite(0, descPos).makeGraphic(optionsBox.width, 98, FlxColor.BLACK);
    descBox.alpha = 0.4;
    descBox.y -= descBox.height / 3;
    descriptionGroup.add(descBox);
    categoryBounds[0] = descBox.y - 720;

    var descTxt:FunkinText = new FunkinText(0, descPos - (descBox.height / 3) / 2, descBox.width, "Lorem ipsum dolor sit amet", 16);
    descTxt.font = Paths.font("pixelarial-bold.ttf");
    descTxt.borderSize = 2;
    descTxt.alignment = "center";
    descTxt.y -= descTxt.height / 2.5;
    descriptionGroup.add(descTxt);

    //descriptionGroup.y -= descriptionGroup.height;

    closeButton = new BackButton(phoneSpr.x - 4 * scale, 0, closeOptions, scale, false, "menus/x", true);
    closeButton.camera = optionsCam;
    theEntireThing.add(closeButton);

    if (closeButton.x < 0) closeButton.x = 0;

    var duration:Float = FlxG.save.data.impPixelFastMenus ? 0.2 : 0.4;
    FlxTween.tween(theEntireThing, {y: 0}, duration, {ease: FlxEase.quartOut, onComplete: _ -> {
        canInteract = true;
    }});

    if (lastCategory != null && lastCategory != "") {
        curCategoryIndex = categories.indexOf(lastCategory);
        lastCategory = null;
    }

    volumeBeep = FlxG.sound.load(Paths.sound("bar"), FlxG.save.data.volume, true);

    updateCategory();

    if (globalUsingKeyboard)
        useKeyboard();
}

function createCategories() {
    for (category in Paths.getFolderContent("data/states/options", false, 1, true)) {
        categories.push(category);
    }
    categories.remove(categories[categories.indexOf("impostorOptionsSubState")]);
    if (!Options.devMode || FlxG.onMobile) categories.remove(categories[categories.indexOf("Debug")]);
}

function rearrangeCategories() {
    var categoriesHeight:Float = phoneScreen.members[1].height / categories.length;
    for (i in 0...categories.length) {
        var categoryGrp:FlxSpriteGroup = new FlxSpriteGroup(0, categoriesHeight * i);
        categoriesGroup.add(categoryGrp);

        var bg:FlxSprite = new FlxSprite().makeGraphic(generalWidth, categoriesHeight, FlxColor.WHITE);
        bg.color = FlxColor.BLACK;
        bg.blend = 9;
        bg.alpha = 0.6;
        categoryGrp.add(bg);

        var catTrans:String = translate("options.section." + StringTools.replace(categories[i].toLowerCase(), " ", ""));
        var title:FunkinText = new FunkinText(0, bg.height / 2, bg.width, catTrans, 33, false);
        title.font = Paths.font("pixeloidsans.ttf");
        title.color = FlxColor.BLACK;
        title.alignment = "center";
        title.y -= title.height / 2;
        categoryGrp.add(title);
    }
}

function removeExtension(s:String):String {
    var dividedString:Array<String> = s.split(".");
    return dividedString[0];
}

function postCreate() {
    if (!isMobile && !globalUsingKeyboard) FlxG.mouse.visible = true;
}

// prevents from opening a category IMMEDIATLY after opening this substate
var canInteract:Bool = false;
function update(elapsed:Float) {
    checkCurrentCategory(elapsed);

    if (categories[curCategoryIndex] == "Gameplay")
        checkVolume();

    if (!canInteract) return;

    handleOptions();

    handleKeyboard();
    handlePointer();
}

var usingKeyboard:Bool = globalUsingKeyboard;
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
function handlePointer() {
    if (getTouch().justMoved) {
        usingKeyboard = false;
        FlxG.mouse.visible = true;
        if (canInteract) closeButton.visible = true;
    }

    if (usingKeyboard) return;

    hoveringOverCategory = false;

    for (i => category in categoriesGroup.members) {
        if (touchOverlaps(category.members[0])) {
            hoveringOverCategory = true;
            if (touchJustReleased()) {
                curCategoryIndex = i;
                updateCategory();
            }
        }
    }

    for (i => group in curCategoryGrp.members) {
        if (touchOverlaps(group.members[0])) {
            curOption = i;
            playSound();
        }
    }

    if (FlxG.android.justReleased.BACK)
        closeOptions();
}

function changeOptionSelec(change:Int) {
    useKeyboard();
    curOption = FlxMath.wrap(curOption + change, 0, curCategoryOptions.length - 1);
    playSound();
}

function handleOptions() {
    if (categories[curCategoryIndex] == "Controls") {}
    else if (categories[curCategoryIndex] == "Languages") {
        for (i => group in curCategoryGrp.members) {
            if (i == curOption)
                group.members[0].alpha = 0.1;
            else
                group.members[0].alpha = 0;

            handleLanguages(i, group.members[2]);
        }
    }
    else {
        for (i => group in curCategoryGrp.members) {
            if (i == curOption) {
                group.members[0].alpha = 0.1;

                if (curCategoryOptions[i].type == "bool") {
                    handleBoolean(i, group.members[2]);
                }
                if (curCategoryOptions[i].type == "integer") {
                    group.members[2].visible = true;
                    group.members[3].visible = true;
                    handleAdditions(i, group.members[2], group.members[3], group.members[4]);
                }
                if (curCategoryOptions[i].type == "percent") {
                    handlePercentage(i, group.members[4], group.members[5], group.members[2]);
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

                if (curCategoryOptions[i].type == "integer" || curCategoryOptions[i].type == "choice") {
                    group.members[2].visible = false;
                    group.members[3].visible = false;
                }
            }

            if (curCategoryOptions[i].type == "percent")
                group.members[5].playAnim(usingKeyboard ? "normal" : "fat");
        }
    }

    updateDescription();
}

function updateDescription() {
    if (categories[curCategoryIndex] == "Controls" || curCategoryOptions != null && curCategoryOptions.length < 1) {
        descriptionGroup.members[0].visible = false;
        descriptionGroup.members[1].visible = false;
    }
    else if (categories[curCategoryIndex] == "Languages") {
        descriptionGroup.members[0].visible = true;
        descriptionGroup.members[1].visible = true;

        var posBox:Float = 101 - 21;
        var posTxt:Float = 101 - 25.5;
        descriptionGroup.members[0].y = categoryBounds[0] + posBox - descriptionGroup.members[0].height;
        descriptionGroup.members[1].y = categoryBounds[0] + posTxt - descriptionGroup.members[0].height + 7;
        descriptionGroup.members[1].alignment = "left";

        var curLangData:Map<String, Dynamic> = TranslationUtil.getConfig(curCategoryOptions[curOption].split("/")[0]);
        descriptionGroup.members[1].text = " " + translate("options.language.translator", [curLangData["credits"]]);
        descriptionGroup.members[1].text += '\n ' + translate("version") + ': ' + curLangData["version"];
    }
    else {
        descriptionGroup.members[1].alignment = "center";
        descriptionGroup.members[0].visible = true;
        descriptionGroup.members[1].visible = true;

        try {
            var daTranslation:String = "";
            if (TranslationUtil.exists("options." + StringTools.replace(categories[curCategoryIndex].toLowerCase(), " ", "") + "." + curCategoryOptions[curOption].name + "-desc" + (isMobile ? "-mobile" : "")))
                daTranslation = translate("options." + StringTools.replace(categories[curCategoryIndex].toLowerCase(), " ", "") + "." + curCategoryOptions[curOption].name + "-desc" + (isMobile ? "-mobile" : ""));
            else
                daTranslation = translate("options." + StringTools.replace(categories[curCategoryIndex].toLowerCase(), " ", "") + "." + curCategoryOptions[curOption].name + "-desc");
            descriptionGroup.members[1].text = daTranslation;

            var posBox:Float = 101;
            var posTxt:Float = 101;
            var mult:Int = 1;
            var offset:Float = 0;
            if (descriptionGroup.members[1].height > 32) {
                posBox -= 22;
                posTxt -= 25.5;
                mult *= 2;
                offset += 2;
            }
            if (descriptionGroup.members[1].height > 60) {
                posBox -= 22;
                posTxt -= 25.5;
                mult *= 2;
                offset += 1;
            }
            if (descriptionGroup.members[1].height > 88) {
                posBox -= 22;
                posTxt -= 25.5;
                mult *= 2;
                offset += -8;
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

function handleBoolean(position:Int, checkbox:FlxSprite) {
    if (usingKeyboard) {
        if (controls.ACCEPT) {
            playMenuSound("select");

            var value:Bool;
            if (StringTools.endsWith(checkbox.animation.name, "true")) value = true;
            if (StringTools.endsWith(checkbox.animation.name, "false")) value = false;

            var newValue:Bool = !value;
            curCategory.call("onChangeBool", [position, newValue]);

            checkbox.animation.play("trans " + Std.string(newValue), true);
        }
        return;
    }

    if (hoveringOverCategory) return;

    if (touchOverlaps(curCategoryGrp.members[position].members[0]) && touchJustPressed()) {
        playMenuSound("select");

        var value:Bool;
        if (StringTools.endsWith(checkbox.animation.name, "true")) value = true;
        if (StringTools.endsWith(checkbox.animation.name, "false")) value = false;

        var newValue:Bool = !value;
        curCategory.call("onChangeBool", [position, newValue]);

        checkbox.animation.play("trans " + Std.string(newValue), true);
    }
}

var optHoldTimer:Float = 0;
var optMaxHeldTime:Float = 0.5;
var optMaxFastHeldTime:Float = 1.5;
var optFrameDelayer:Int = 0;
var optMaxDelay:Int = 5;
function handleAdditions(position:Int, subtractBtn:FlxSprite, addBtn:FlxSprite, valueTxt:FunkinText) {
    if (usingKeyboard) {
        if (controls.LEFT) {
            subtractBtn.animation.play("press");
            if (optHoldTimer >= optMaxHeldTime) {
                if (optFrameDelayer >= optMaxDelay) {
                    playMenuSound("select");

                    var integer:Int = Std.parseInt(valueTxt.text);
                    var newValue:Int = integer - curCategoryOptions[position].change;
                    if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
                    valueTxt.text = Std.string(newValue);

                    curCategory.call("onChangeInt", [position, newValue]);

                    optFrameDelayer = 0;
                }
                else
                    optFrameDelayer++;

                if (optHoldTimer >= optMaxFastHeldTime)
                    optMaxDelay = 0;
            }
            optHoldTimer += FlxG.elapsed;
        }
        else if (controls.LEFT_R) {
            subtractBtn.animation.play("idle");
            playMenuSound("select");

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
                    playMenuSound("select");

                    var integer:Int = Std.parseInt(valueTxt.text);
                    var newValue:Int = integer + curCategoryOptions[position].change;
                    if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
                    valueTxt.text = Std.string(newValue);

                    curCategory.call("onChangeInt", [position, newValue]);

                    optFrameDelayer = 0;
                }
                else
                    optFrameDelayer++;

                if (optHoldTimer >= optMaxFastHeldTime)
                    optMaxDelay = 0;
            }
            optHoldTimer += FlxG.elapsed;
        }
        else if (controls.RIGHT_R) {
            addBtn.animation.play("idle");
            playMenuSound("select");

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

    if (touchOverlaps(subtractBtn)) {
        if (touchIsHolding()) {
            subtractBtn.animation.play("press");
            if (optHoldTimer >= optMaxHeldTime) {
                if (optFrameDelayer >= optMaxDelay) {
                    playMenuSound("select");

                    var integer:Int = Std.parseInt(valueTxt.text);
                    var newValue:Int = integer - curCategoryOptions[position].change;
                    if (newValue < curCategoryOptions[position].min) newValue = curCategoryOptions[position].min;
                    valueTxt.text = Std.string(newValue);

                    curCategory.call("onChangeInt", [position, newValue]);

                    optFrameDelayer = 0;
                }
                else
                    optFrameDelayer++;

                if (optHoldTimer >= optMaxFastHeldTime)
                    optMaxDelay = 0;
            }
            optHoldTimer += FlxG.elapsed;
        }
        else if (touchJustReleased()) {
            subtractBtn.animation.play("idle");
            playMenuSound("select");

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

    if (touchOverlaps(addBtn)) {
        if (touchIsHolding()) {
            addBtn.animation.play("press");
            if (optHoldTimer >= optMaxHeldTime) {
                if (optFrameDelayer >= optMaxDelay) {
                    playMenuSound("select");

                    var integer:Int = Std.parseInt(valueTxt.text);
                    var newValue:Int = integer + curCategoryOptions[position].change;
                    if (newValue > curCategoryOptions[position].max) newValue = curCategoryOptions[position].max;
                    valueTxt.text = Std.string(newValue);

                    curCategory.call("onChangeInt", [position, newValue]);

                    optFrameDelayer = 0;
                }
                else
                    optFrameDelayer++;

                if (optHoldTimer >= optMaxFastHeldTime)
                    optMaxDelay = 0;
            }
            optHoldTimer += FlxG.elapsed;
        }
        else if (touchJustReleased()) {
            addBtn.animation.play("idle");
            playMenuSound("select");

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

var barOffset:Float = 0;
var percentChangeDelay:Bool = false;
function handlePercentage(position:Int, bar:FlxSprite, theThing:FunkinSprite, percentTxt:FunkinText) {
    if (usingKeyboard) {
        if (controls.LEFT) {
            if (StringTools.contains(curCategoryOptions[position].name, "volume")) {
                volumeBeep.play();

                if (StringTools.endsWith(curCategoryOptions[position].name, "Music"))
                    volumeBeep.volume = Options.volumeMusic;
                else if (StringTools.endsWith(curCategoryOptions[position].name, "SFX"))
                    volumeBeep.volume = Options.volumeSFX;
                else
                    volumeBeep.volume = FlxG.sound.volume;
            }

            if (percentChangeDelay = !percentChangeDelay) {
                var percent:Float = Std.parseFloat(percentTxt.text) / 100;
                var newValue:Int = percent - 0.01;
                if (newValue < 0) newValue = 0;

                volumeBeep.pitch = newValue * 1.5;

                var barPos:Float = bar.frameWidth * newValue;
                bar.clipRect = new FlxRect(0, 0, barPos, bar.frameHeight);
                theThing.x = (bar.x + (bar.width * newValue)) - barOffset;
                percentTxt.text = Std.string(newValue * 100) + "%";

                curCategory.call("onChangeFloat", [position, newValue]);
            }
        }
        else if (controls.RIGHT) {
            if (StringTools.contains(curCategoryOptions[position].name, "volume")) {
                volumeBeep.play();

                if (StringTools.endsWith(curCategoryOptions[position].name, "Music"))
                    volumeBeep.volume = Options.volumeMusic;
                else if (StringTools.endsWith(curCategoryOptions[position].name, "SFX"))
                    volumeBeep.volume = Options.volumeSFX;
                else
                    volumeBeep.volume = FlxG.sound.volume;
            }

            if (percentChangeDelay = !percentChangeDelay) {
                var percent:Float = Std.parseFloat(percentTxt.text) / 100;
                var newValue:Int = percent + 0.01;
                if (newValue > 1) newValue = 1;

                volumeBeep.pitch = newValue * 1.5;

                var barPos:Float = bar.frameWidth * newValue;
                bar.clipRect = new FlxRect(0, 0, barPos, bar.frameHeight);
                theThing.x = (bar.x + (bar.width * newValue)) - barOffset;
                percentTxt.text = Std.string(newValue * 100) + "%";

                curCategory.call("onChangeFloat", [position, newValue]);
            }
        }
        else {
            if (volumeBeep.playing) {
                volumeBeep.stop();
                volumeBeep.pitch = 1;
            }
        }

        return;
    }

    if (touchJustReleased(theThing) && touchIsHolding()) {
        if (StringTools.contains(curCategoryOptions[position].name, "volume")) {
            volumeBeep.play();

            if (StringTools.endsWith(curCategoryOptions[position].name, "Music"))
                volumeBeep.volume = Options.volumeMusic;
            else if (StringTools.endsWith(curCategoryOptions[position].name, "SFX"))
                volumeBeep.volume = Options.volumeSFX;
            else
                volumeBeep.volume = FlxG.sound.volume;
        }

        var min:Float = bar.x - barOffset;
        var max:Float = bar.x + bar.width - barOffset;
        theThing.x = FlxMath.bound(FlxG.mouse.x - barOffset, min, max);
        var posCalc:Float = (theThing.x - min) / bar.width;
        var newValue:Float = FlxMath.roundDecimal(posCalc, 2);

        volumeBeep.pitch = newValue * 1.5;

        var barPos:Float = bar.frameWidth * newValue;
        bar.clipRect = new FlxRect(0, 0, barPos, bar.frameHeight);
        percentTxt.text = Std.string(newValue * 100) + "%";

        curCategory.call("onChangeFloat", [position, newValue]);
    }
    else {
        if (volumeBeep.playing) {
            volumeBeep.stop();
            volumeBeep.pitch = 1;
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
            playMenuSound("select");

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
            playMenuSound("select");

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
}

function handleFunction(position:Int) {
    if (usingKeyboard && controls.ACCEPT) {
        playMenuSound("select");
        curCategory.call("onCallFunction", [position]);
    }

    if (touchOverlaps(curCategoryGrp.members[position].members[0]) && touchJustPressed()) {
        playMenuSound("select");
        curCategory.call("onCallFunction", [position]);
    }
}

function handleLanguages(index:Int, dot:FlxSprite) {
    var language:String = curCategoryOptions[index].split("/");

    if (index == curOption) {
        if (usingKeyboard) {
            if (controls.ACCEPT) {
                if (language[0] != TranslationUtil.curLanguage) {
                    playMenuSound("select");
                    TranslationUtil.setLanguage(curCategoryOptions[index].split("/")[0]);
                    dot.animation.play(Std.string("trans true"));
                }
            }
            return;
        }
        if (isMobile) {
            for (touch in FlxG.touches.list) {
                if (touch.overlaps(curCategoryGrp.members[index].members[0])) {
                    if (touch.justReleased) {
                        if (language[0] != TranslationUtil.curLanguage) {
                            playMenuSound("select");
                            TranslationUtil.setLanguage(curCategoryOptions[index].split("/")[0]);
                            dot.animation.play(Std.string("trans true"));
                        }
                    }
                }
            }
        }
        else {
            if (FlxG.mouse.overlaps(curCategoryGrp.members[index].members[0])) {
                if (FlxG.mouse.justReleased) {
                    if (language[0] != TranslationUtil.curLanguage) {
                        playMenuSound("select");
                        TranslationUtil.setLanguage(curCategoryOptions[index].split("/")[0]);
                        dot.animation.play(Std.string("trans true"));
                    }
                }
            }
        }
    }

    if (language[0] == TranslationUtil.curLanguage) {
        if (StringTools.endsWith(dot.animation.name, "false") && !StringTools.startsWith(dot.animation.name, "true"))
            dot.animation.play(Std.string("trans true"));
    }
    else {
        if (StringTools.endsWith(dot.animation.name, "true") && !StringTools.startsWith(dot.animation.name, "false"))
            dot.animation.play("trans false");
    }
}

function playSound() {
    if (curOption != lastOption) {
        playMenuSound("scroll");
        lastOption = curOption;
    }
}

function changeCategory(change:Int) {
    curCategoryIndex = FlxMath.wrap(curCategoryIndex + change, 0, categories.length - 1);
    updateCategory();
}

function updateCategory() {
    if (lastCategoryIndex != curCategoryIndex) {
        playMenuSound("select");
        lastCategoryIndex = curCategoryIndex;
        curOption = 0;
        lastOption = 0;
        descriptionGroup.visible = true;

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

        if (categories[curCategoryIndex] == "Controls") {
            curCategory.call("createGroup");
            curCategory.get("group");
        }
        else if (categories[curCategoryIndex] == "Languages") {
            setupLanguages();
        }
        else
            createCategory(categories[curCategoryIndex]);
    }
    else {
        playMenuSound("cancel");
        lastCategoryIndex = -1;
        curCategoryIndex = -1;
        curOption = 0;
        lastOption = -1;
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

var globalHeight:Float = 30;
var labelSize:Float = 18;
var curCategoryOptions:Array<Dynamic> = [];
var optionsFont:String = Paths.font("pixelarial-bold.ttf");
var optionTypeScale:Float = 1.5;
var invisBoxWidth:Float = 48 * optionTypeScale;
var invisBoxHeight:Float = 17 * optionTypeScale;
function createCategory(category:String) {
    for (i in 0...curCategoryOptions.length) {
        var group:FlxSpriteGroup = new FlxSpriteGroup();
        curCategoryGrp.add(group);

        var height:Float = globalHeight;
        var iHeight:Float = height * i; // this is necessary otherwise positions will get fucked up
        var x:Float = 0;
        var bg:FlxSprite = new FlxSprite(x, iHeight).makeGraphic(categoryBounds[2], Std.int(height), FlxColor.BLACK);
        bg.alpha = 0;
        bg.blend = 9;
        group.add(bg);

        var labelOffset:Float = x + 12;
        var label:FunkinText = new FunkinText(labelOffset + 8, iHeight + bg.height / 2, 0, translate("options." + StringTools.replace(category.toLowerCase(), " ", "") + "." + curCategoryOptions[i].name + "-name"), labelSize);
        label.font = optionsFont;
        label.borderSize = 2.1;
        label.y -= label.height / 2 - 1;
        group.add(label);

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
            checkbox.x -= checkbox.width + 32 * optionTypeScale;
            checkbox.y -= checkbox.height / 1.5;
            group.add(checkbox);
        }
        else if (curCategoryOptions[i].type == "integer") {
            var thisX:Float = x + bg.width - 24 * optionTypeScale - invisBoxWidth;
            var thisY:Float = iHeight + bg.height / 2 - invisBoxHeight / 2;

            var rightBtn:FlxSprite = new FlxSprite(thisX + invisBoxWidth + 2 * optionTypeScale, thisY);
            rightBtn.frames = Paths.getFrames("menus/options/buttons");
            rightBtn.animation.addByIndices("idle", "add", [1], "", 0, true);
            rightBtn.animation.addByIndices("press", "add", [2], "", 0, true);
            rightBtn.animation.play("idle");
            rightBtn.scale.set(optionTypeScale, optionTypeScale);
            rightBtn.updateHitbox();
            rightBtn.visible = false;

            var leftBtn:FlxSprite = new FlxSprite(thisX - 2 * optionTypeScale, rightBtn.y);
            leftBtn.frames = Paths.getFrames("menus/options/buttons");
            leftBtn.animation.addByIndices("idle", "subtract", [1], "", 0, true);
            leftBtn.animation.addByIndices("press", "subtract", [2], "", 0, true);
            leftBtn.animation.play("idle");
            leftBtn.scale.set(optionTypeScale, optionTypeScale);
            leftBtn.updateHitbox();
            leftBtn.x -= leftBtn.width;
            leftBtn.visible = false;

            // change this when new codename update arrives
            var inputTxt:FunkinText = new FunkinText(thisX, thisY + invisBoxHeight / 2, invisBoxWidth, "", labelSize + 4);
            inputTxt.font = Paths.font("pixeloidsans.ttf");
            inputTxt.letterSpacing = -1;
            inputTxt.borderSize = 2.2;
            inputTxt.alignment = "center";
            inputTxt.text = Std.string(Reflect.getProperty(curCategoryOptions[i].savepoint, curCategoryOptions[i].savevar));
            inputTxt.y -= inputTxt.height / 2;

            group.add(leftBtn);
            group.add(rightBtn);
            group.add(inputTxt);
        }
        else if (curCategoryOptions[i].type == "percent") {
            var thisX:Float = x + bg.width - 2 * optionTypeScale - invisBoxWidth;
            var thisY:Float = iHeight + bg.height / 2;

            var value:Null<Float> = Reflect.getProperty(curCategoryOptions[i].savepoint, curCategoryOptions[i].savevar);
            if (value == null) value = FlxG.sound.volume;

            if (curCategoryOptions[i].savevar == "volume" && (FlxG.save.data.mute || FlxG.sound.muted))
                value = 0;

            var percentTxt:FunkinText = new FunkinText(thisX, thisY, invisBoxWidth, "", labelSize + 4);
            percentTxt.font = Paths.font("pixeloidsans.ttf");
            percentTxt.letterSpacing = -1;
            percentTxt.borderSize = 2.2;
            percentTxt.alignment = "center";
            percentTxt.text = Std.string(Math.round(value * 100));
            percentTxt.text += "%";
            percentTxt.y -= percentTxt.height / 2;

            var barBG:FlxSprite = new FlxSprite(thisX, thisY).loadGraphic(Paths.image("menus/options/barBack"));
            barBG.scale.set(optionTypeScale, optionTypeScale);
            barBG.updateHitbox();
            barBG.x -= barBG.width + 5 * optionTypeScale;
            barBG.y -= barBG.height / 2;

            var barPro:FlxSprite = new FlxSprite(barBG.x, barBG.y).loadGraphic(Paths.image("menus/options/barOverlay"));
            barPro.scale.set(optionTypeScale, optionTypeScale);
            barPro.updateHitbox();

            var barPos:Float = barPro.frameWidth * value;
            barPro.clipRect = new FlxRect(0, 0, barPos, barPro.frameHeight);

            barOffset = 7.5 * optionTypeScale;
            var whateverThisIsCalled:FunkinSprite = new FunkinSprite(barPro.x + (barPro.width * value), barPro.y + (barPro.height / 2)).loadGraphic(Paths.image("menus/options/barThing"), true, 15, 15);
            whateverThisIsCalled.animation.add("normal", [0], 0, false);
            whateverThisIsCalled.animation.add("fat", [1], 0, false);
            whateverThisIsCalled.playAnim("normal");
            whateverThisIsCalled.scale.set(optionTypeScale, optionTypeScale);
            whateverThisIsCalled.updateHitbox();
            whateverThisIsCalled.x -= barOffset;
            whateverThisIsCalled.y -= whateverThisIsCalled.height / 2;

            group.add(percentTxt);
            group.add(barBG);
            group.add(barPro);
            group.add(whateverThisIsCalled);
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
            var inputTxt:FunkinText = new FunkinText(inputBox.x, inputBox.y + inputBox.height / 2, inputBox.width, "", labelSize);
            inputTxt.font = Paths.font("retrogaming.ttf");
            inputTxt.borderSize = 2.2;
            inputTxt.alignment = "center";
            inputTxt.text = Std.string(Reflect.getProperty(curCategoryOptions[i].savepoint, curCategoryOptions[i].savevar));
            inputTxt.y -= inputTxt.height / 2;

            group.add(leftBtn);
            group.add(rightBtn);
            group.add(inputBox);
            group.add(inputTxt);
        }
    }
}

var langData:Array<Dynamic> = [];
function setupLanguages() {
    for (i in 0...curCategoryOptions.length) {
        var group:FlxSpriteGroup = new FlxSpriteGroup();
        curCategoryGrp.add(group);

        var language:String = curCategoryOptions[i].split("/");

        var height:Float = globalHeight;
        var iHeight:Float = height * i;
        var x:Float = 0;
        var bg:FlxSprite = new FlxSprite(x, iHeight).makeGraphic(categoryBounds[2], Std.int(height), FlxColor.BLACK);
        bg.alpha = 0;
        bg.blend = 9;
        group.add(bg);

        var labelOffset:Float = x + 12;
        var languageLabel:FunkinText = new FunkinText(labelOffset + 8, iHeight + (bg.height / 2), bg.width, translate("options.language." + language[0]), labelSize);
        languageLabel.font = optionsFont;
        languageLabel.borderSize = 2;
        languageLabel.y -= languageLabel.height / 2 - 1;
        group.add(languageLabel);

        var dot:FlxSprite = new FlxSprite(x + bg.width, iHeight + bg.height / 2);
        dot.frames = Paths.getFrames("menus/options/dotChoice");
        dot.animation.addByPrefix("false", "blank", 0, true);
        dot.animation.addByPrefix("trans true", "transition chosen", 24, false);
        dot.animation.addByPrefix("true", "chosen", 0, true);
        dot.animation.addByPrefix("trans false", "transition blank", 24, false);
        dot.animation.play(Std.string(language[0] == TranslationUtil.curLanguage));
        dot.scale.set(optionTypeScale, optionTypeScale);
        dot.updateHitbox();
        dot.x -= dot.width;
        dot.x -= 10 * optionTypeScale;
        dot.y -= dot.height / 1.6;
        group.add(dot);
    }
}

function checkVolume() {
    for (i => optionGrp in curCategoryGrp.members) {
        if (curCategoryOptions[i].type != "percent") continue;
        if (curCategoryOptions[i].savepoint != FlxG.save.data) continue;
        if (curCategoryOptions[i].savevar != "volume") continue;

        var value:Float = FlxG.sound.volume;
        if (FlxG.save.data.mute || FlxG.sound.muted) value = 0;
        var barPos:Float = optionGrp.members[4].frameWidth * value;
        optionGrp.members[4].clipRect = new FlxRect(0, 0, barPos, optionGrp.members[3].frameHeight);
        optionGrp.members[5].x = (optionGrp.members[4].x + (optionGrp.members[4].width * value)) - barOffset;
        optionGrp.members[2].text = Std.string(Math.round(value * 100)) + "%";
    }
}

var willDeleteData:Bool = false;
var dataDeletionScript:Script;
var dataDeleteSubmenuInit:Bool = false;
var willCloseScript:Bool = true;
var dataDeleteGroup:FlxSpriteGroup;
var ohNoDataWillRIP:Bool = false;
var mosaicShader:CustomShader;
function checkCurrentCategory(elapsed:Float) {
    if (categories[curCategoryIndex] == "Miscellaneous") {
        if (!willDeleteData)
            willDeleteData = curCategory.get("queuedDataDeletion");
        else {
            if (!dataDeleteSubmenuInit) {
                dataDeleteSubmenuInit = true;
                canInteract = false;

                dataDeletionScript = Script.create(Paths.script("data/states/warnings/dataDeletion"));
                dataDeletionScript.setParent(this);
                dataDeletionScript.load();
                dataDeletionScript.call("create");

                dataDeleteGroup = new FlxSpriteGroup();
                dataDeleteGroup.camera = optionsCam;
                add(dataDeleteGroup);

                dataDeleteGroup.add(dataDeletionScript.get("backGrp"));

                /*
                var maxScale:Float = 20;
                var daEmitter:FlxTypedEmitter = new FlxTypedEmitter(FlxG.width + maxScale * scale * 2, dataDeletionScript.get("backGradient").y);
                daEmitter.loadParticles(Paths.image("menus/dataDeletion/fade"), 100);
                daEmitter.launchAngle.set(180);
                daEmitter.angle.set(90);
                daEmitter.speed.set(4000);
                daEmitter.scale.set(2, maxScale / 4, 8, maxScale);
                daEmitter.height = dataDeletionScript.get("backGradient").height;
                daEmitter.blend = setBlendMode("add");
                daEmitter.alpha.set(0.1, 0.5);
                daEmitter.start(false, 0.005);
                dataDeleteGroup.add(daEmitter);
                */

                dataDeleteGroup.add(dataDeletionScript.get("frontGrp"));
            }
            else {
                dataDeletionScript.call("update", [elapsed]);

                if (!willCloseScript) {
                    willCloseScript = dataDeletionScript.get("wasDestroyed");
                }
                else {
                    ohNoDataWillRIP = dataDeletionScript.get("willEraseData");

                    if (ohNoDataWillRIP) {
                        curCategory.set("queuedDataDeletion", false);
                        willDeleteData = false;
                        willCloseScript = false;
                        dataDeleteSubmenuInit = false;

                        var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                        black.camera = optionsCam;
                        black.alpha = 0;
                        add(black);

                        var dur:Float = 2;
                        FlxTween.tween(black, {alpha: 1}, dur);

                        mosaicShader = new CustomShader("mosaic");
                        optionsCam.setFilters([new ShaderFilter(mosaicShader)]);

                        for (i in 0...60) {
                            setMosaicTimer(i, i + 1, i + 1);
                        }

                        new FlxTimer().start(dur + 0.25, _ -> {
                            FunkinSave.save.erase();
                            FunkinSave.highscores.clear();
                            FlxG.save.erase();
                            eraseImpostorSaveData();

                            FunkinSave.flush();
                            FlxG.save.flush();

                            FlxG.resetGame();

                            logTraceColored([
                                {text: "[VS IMPOSTOR Pixel] ", color: getLogColor("red")},
                                {text: "DATA HAS BEEN ERASED", color: getLogColor("red")}
                            ]);
                        });
                    }
                    else {
                        curCategory.set("queuedDataDeletion", false);
                        willDeleteData = false;
                        willCloseScript = false;
                        dataDeleteSubmenuInit = false;
                        canInteract = true;

                        remove(dataDeleteGroup);
                        dataDeletionScript.destroy();
                        dataDeleteGroup.destroy();
                    }
                }
            }
        }
    }
}

function setMosaicTimer(frame:Int, forceX:Float, forceY:Float) {
	var daX:Float = forceX ?? 10 * FlxG.random.int(1, 4);
	var daY:Float = forceY ?? 10 * FlxG.random.int(1, 4);

	new FlxTimer().start(frame / 30, () -> {
		mosaicShader.uBlocksize = [daX, daY];
	});
}

function deleteCategory() {
    curCategoryGrp.clear();
}

function closeOptions() {
    playMenuSound("cancel");
    canInteract = false;

    var duration:Float = FlxG.save.data.impPixelFastMenus ? 0.2 : 0.4;
    FlxTween.tween(theEntireThing, {y: FlxG.height}, duration, {ease: FlxEase.quartIn, onComplete: _ -> {
        close();
    }});
}

var openWarningDelay:Float = 0.01;
function destroy() {
    Options.save();
    FunkinSave.flush();
    FlxG.save.flush();

    volumeBeep.destroy();

    if (curCategory != null)
        curCategory.destroy();
    curCategoryGrp.destroy();

    descriptionGroup.destroy();
    categoriesGroup.destroy();
    phoneScreen.destroy();
    phoneSpr.destroy();
    theEntireThing.destroy();

    FlxG.cameras.remove(optionsCam);
    optionsCam.destroy();

    if (TranslationUtil.curLanguage != lastLang) {
        logTraceColored([
            {text: "[Language] ", color: getLogColor("blue")},
            {text: "New language detected! Changes can't take immediate effect!"}
        ], "warning");
        new FlxTimer().start(openWarningDelay, _ -> {
            FlxG.state.openSubState(new ModSubState("warnings/newLanguageWarning"));
        });
    }
    if (lastDev != Options.devMode) {
        logTraceColored([
            {text: "[Others] ", color: getLogColor("green")},
            {text: "Developer Mode has been set!"}
        ], "warning");
        new FlxTimer().start(openWarningDelay, _ -> {
            FlxG.state.openSubState(new ModSubState("warnings/devToolsWarning"));
        });
    }
}