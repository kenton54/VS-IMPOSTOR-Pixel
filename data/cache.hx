import flixel.util.typeLimit.OneOfTwo;
import openfl.display.BitmapData;
import openfl.media.Sound;

var initialized:Bool = false;

public static var cachedMenuSounds:Map<String, Sound> = [];
public static var cachedMenuMusic:Map<String, Sound> = [];

public static var titleScreenCache:Map<String, BitmapData> = [];
public static var mainMenuCache:Map<String, BitmapData> = [];
public static var freeplayMenuCache:Map<String, BitmapData> = [];
public static var playstateCache:Map<String, BitmapData> = [];

public static var publicCachedAssets:Map<String, OneOfTwo<BitmapData, Sound>> = [];

public static function startCache() {
    if (!initialized) {
        initialized = true;

        precacheMenuSounds();
    }
}

function precacheMenuSounds() {
    for (soundAsset in Paths.getFolderContent("sounds/menu", false, 1, true)) {
        var path:String = Paths.sound("menu/" + soundAsset);
        cachedMenuSounds.set(soundAsset, Assets.getSound(path));
    }
}

function precacheMenuAssets() {
    for (titleAsset in Paths.getFolderContent("images/menus/title", false, 1, true)) {
        var path:String = Paths.image("menus/title/" + titleAsset);
        titleScreenCache.set(titleAsset, Assets.getBitmapData(path));
    }
}

function precachePlayState() {
}

/**
 * Puts in cache any assets you desire, can be images, sounds or music, so it can be retrieve any time you want without stutters.
 * @param assets an array holding the assets to cache, holding information on how to cache it. (each array must have the following values in it: `path`, `type` ("image", "sound" or "music"))
 */
function cacheAssets(assets:Array<Dynamic>) {
    for (asset in assets) {
        var assetToCache:OneOfTwo<BitmapData, Sound> = null;
        if (asset.type == "image") {
            var path:String = Paths.image(asset.path);
            assetToCache = Assets.getBitmap(path);
        }
        else if (asset.type == "sound") {
            var path:String = Paths.image(asset.path);
            assetToCache = Assets.getSound(path);
        }
        else {
            logTraceColored([
                {text: "[VS IMPOSTOR Pixel] ", color: getLogColor("red")},
                {text: "Data saved!", color: getLogColor("green")}
            ], "verbose");
            return;
        }

        publicCachedAssets.set(asset.path, assetToCache);
    }
}

/**
 * Recommended to do this in order to not break cached bitmap datas (HaxeFlixel destroys these automatically when switching states).
 * @param bitmapData The `BitmapData` to copy
 * @return A new `BitmapData` instance that can be used with FlxSprite.
 */
public static function cloneBitmapData(bitmapData:BitmapData) {
    return bitmapData.clone();
}

public static function clearCache() {
    initialized = false;

    cachedMenuSounds.clear();
    cachedMenuMusic.clear();

    titleScreenCache.clear();
    mainMenuCache.clear();
    freeplayMenuCache.clear();
}