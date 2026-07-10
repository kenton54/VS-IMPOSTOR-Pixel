package funkin;

import animate.FlxAnimateFrames;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;

import funkin.graphics.animation.FlxAssetsFrames;
import funkin.system.FunkinMemory;
import funkin.system.Translations;

/**
 * Helper class to get the location of files inside the assets folder.
 */
class Paths
{
	/**
	 * Gets the full directory of the specified path.
	 *
	 * @param path 			Where you want the directory to lead to.
	 * @param library 	The library to reference.
	 * @return The full directory.
	 */
	public static function getPath(path:String, ?library:String):String
	{
		if (library != null)
		{
			return getDynamicPath(path, library);
		}

		return getMainPath(path);
	}

	/**
	 * Gets the full directory of the specified path.
	 *
	 * Checks whether `library` is set to any of the default ones.
	 *
	 * @param path 			Where you want the directory to lead to.
	 * @param library 	The library to reference.
	 * @return The full directory.
	 */
	public static function getDynamicPath(path:String, library:String):String
	{
		return switch (library)
		{
			case 'default' | 'main': getMainPath(path);
			case 'impostor': getImpostorPath(path);
			case 'flixel': getFlixelPath(path);
			default: getLibraryPath(path, library);
		}
	}

	/**
	 * Gets the full directory of the specified path, along side it's library.
	 *
	 * @param path 			Where you want the directory to lead to.
	 * @param library 	The library to reference.
	 * @return The full directory.
	 */
	public static function getLibraryPath(path:String, library:String):String
	{
		return '$library:assets/$library/$path';
	}

	/**
	 * Gets the full directory of the specified path.
	 *
	 * Will always return the main assets directory.
	 *
	 * @param path 	Where you want the directory to lead to.
	 * @return The full directory.
	 */
	public inline static function getMainPath(path:String):String
	{
		return 'assets/$path';
	}

	/**
	 * Gets the full directory of the specified path, referencing the embedded `impostor` directory.
	 *
	 * @param path 	Where you want the directory to lead to.
	 * @return The full directory.
	 */
	public inline static function getImpostorPath(path:String):String
	{
		return 'impostor/$path';
	}

	/**
	 * Gets the full directory of the specified path, referencing the embedded `flixel` directory.
	 * @param path 	Where you want the directory to lead to.
	 * @return The full directory.
	 */
	public inline static function getFlixelPath(path:String):String
	{
		return 'flixel/$path';
	}

	/**
	 * @param path 			Where the `.json` data file is located at.
	 * @param library 	What library to reference.
	 * @return The full directory to the file.
	 */
	public inline static function json(path:String, ?library:String):String
	{
		return getPath('data/$path.json', library);
	}

	/**
	 * @param path 						Where the `.png` graphic file is located at.
	 * @param library 				What library to reference.
	 * @param ignoreLanguage	Whether the language suffix should be ignored.
	 * @return The full directory to the file.
	 */
	public static function image(path:String, ?library:String, ?ignoreLanguage:Bool = true):String
	{
		var path:String = getPath('images/$path.png', library);
		var pathLang:String = getPath('images/${getLanguageSuffix(path)}.png', library);

		if (!ignoreLanguage && Assets.exists(pathLang, IMAGE))
		{
			return pathLang;
		}

		return path;
	}

	/**
	 * @param path 						Where the `.xml` sprite data is located at.
	 * @param library 				What library to reference.
	 * @param ignoreLanguage 	Whether the language suffix should be ignored.
	 * @return The full directory to the file.
	 */
	public static function sparrow(path:String, ?library:String, ?ignoreLanguage:Bool = true):String
	{
		var path:String = getPath('images/$path.xml', library);
		var pathLang:String = getPath('images/${getLanguageSuffix(path)}.xml', library);

		if (!ignoreLanguage && Assets.exists(pathLang, TEXT))
		{
			return pathLang;
		}

		return path;
	}

	/**
	 * @param path 						Where the `.json` sprite data is located at.
	 * @param library 				What library to reference.
	 * @param ignoreLanguage 	Whether the language suffix should be ignored.
	 * @return The full directory to the file.
	 */
	public static function aseprite(path:String, ?library:String, ?ignoreLanguage:Bool = true):String
	{
		var path:String = getPath('images/$path.json', library);
		var pathLang:String = getPath('images/${getLanguageSuffix(path)}.json', library);

		if (!ignoreLanguage && Assets.exists(pathLang, TEXT))
		{
			return pathLang;
		}

		return path;
	}

	/**
	 * @param path 						Where the `.txt` sprite data is located at.
	 * @param library 				What library to reference.
	 * @param ignoreLanguage 	Whether the language suffix should be ignored.
	 * @return The full directory to the file.
	 */
	public static function packer(path:String, ?library:String, ?ignoreLanguage:Bool = true):String
	{
		var path:String = getPath('images/$path.txt', library);
		var pathLang:String = getPath('images/${getLanguageSuffix(path)}.txt', library);

		if (!ignoreLanguage && Assets.exists(pathLang, TEXT))
		{
			return pathLang;
		}

		return path;
	}

	/**
	 * @param path 			Where the `.ogg` sound file is located at.
	 * @param library 	The library to reference.
	 * @return The full directory to the file.
	 */
	public inline static function sound(path:String, ?library:String, ?ignoreLanguage:Bool = true):String
	{
		var path:String = getPath('sounds/$path.ogg', library);
		var pathLang:String = getPath('sounds/${getLanguageSuffix(path)}.ogg', library);

		if (!ignoreLanguage && Assets.exists(pathLang, SOUND))
		{
			return pathLang;
		}

		return path;
	}

	/**
	 * @param path 			Where the `.ogg` music file is located at.
	 * @param library 	The library to reference.
	 * @return The full directory to the file.
	 */
	public inline static function music(path:String, ?library:String):String
	{
		return getPath('music/$path.ogg', library);
	}

	/**
	 * @param path 	Where the font file is located at. Must include the extension.
	 * @return The full directory to the file.
	 */
	public inline static function font(path:String):String
	{
		return getMainPath('fonts/$path');
	}

	/**
	 * @param path 	Where the video file is located at.
	 * @return The full directory to the file.
	 */
	public inline static function video(path:String):String
	{
		return getPath('videos/$path.mp4');
	}

	public inline static function getSparrowFrames(path:String, ?library:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FunkinMemory.getGraphic(image(path, library));
		return FlxAtlasFrames.fromSparrow(graphic, sparrow(path, library));
	}

	public inline static function getAsepriteFrames(path:String, ?library:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FunkinMemory.getGraphic(image(path, library));
		return FlxAtlasFrames.fromAseprite(graphic, aseprite(path, library));
	}

	public inline static function getPackerFrames(path:String, ?library:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FunkinMemory.getGraphic(image(path, library));
		return FlxAtlasFrames.fromSpriteSheetPacker(graphic, Assets.getText(packer(path, library)));
	}

	public inline static function getTiledFrames(path:String, ?library:String, width:Int, height:Int, spacing:Int = 0):FlxTileFrames
	{
		var graphic:FlxGraphic = FunkinMemory.getGraphic(image(path, library));
		return FlxTileFrames.fromGraphic(graphic, FlxPoint.get(width, height), null, spacing > 0 ? FlxPoint.get(spacing, spacing) : null);
	}

	public inline static function getAssetsFrames(folder:String, ?library:String):FlxAssetsFrames
	{
		return FlxAssetsFrames.fromAssets(readDirectory(folder, library, true));
	}

	public inline static function getAnimateFrames(folder:String, ?library:String, ?animateSettings:AnimateAtlasSettings):FlxAnimateFrames
	{
		var path:String = getPath('images/$folder', library);

		if (animateSettings == null)
		{
			animateSettings = FunkinSprite.getDefaultAtlasSettings();
		}

		var validSettings:AnimateAtlasSettings = {
			swfMode: animateSettings?.swfMode ?? false,
			cacheOnLoad: animateSettings?.cacheOnLoad ?? false,
			filterQuality: animateSettings?.filterQuality ?? MEDIUM,
			onSymbolCreate: animateSettings?.onSymbolCreate ?? null,
			spritemaps: animateSettings?.spritemaps ?? null,
			metadata: animateSettings?.metadata ?? null,
			cacheKey: animateSettings?.cacheKey ?? null,
			uniqueCache: animateSettings?.uniqueCache ?? false,
			applyStageMatrix: animateSettings?.applyStageMatrix ?? false,
			useRenderTexture: animateSettings?.useRenderTexture ?? false
		};

		return FlxAnimateFrames.fromAnimate(path, validSettings.spritemaps, validSettings.metadata, validSettings.cacheKey, validSettings.uniqueCache, {
			swfMode: validSettings.swfMode,
			cacheOnLoad: validSettings.cacheOnLoad,
			filterQuality: validSettings.filterQuality,
			onSymbolCreate: validSettings.onSymbolCreate
		});
	}

	/**
	 * Dynamically retrieves the frames of a sprite in the given path.
	 *
	 * @param path 						Where you want the directory to lead to.
	 * @param library 				The library to reference.
	 * @param animateSettings Settings to set when loading an Animate Atlas.
	 * @return The Sparrow, Aseprite, Packer or Animate Atlas frames.
	 */
	public static function getFrames(path:String, ?library:String, ?animateSettings:AnimateAtlasSettings):FlxAtlasFrames
	{
		var fullPath:String = getPath('images/$path', library);

		if (Assets.exists('$fullPath/Animation.json', TEXT))
		{
			return getAnimateFrames(path, library, animateSettings);
		}
		else if (Assets.exists('$fullPath.xml', TEXT))
		{
			return getSparrowFrames(path, library);
		}
		else if (Assets.exists('$fullPath.json', TEXT))
		{
			return getAsepriteFrames(path, library);
		}
		else if (Assets.exists('$fullPath.txt', TEXT))
		{
			return getPackerFrames(path, library);
		}

		return null;
	}

	/**
	 * Dynamically retrieves the frames of multiple sprites in the multiple given paths.
	 *
	 * @param paths 					Where all the directories lead to.
	 * @param library					The library to reference.
	 * @param animateSettings Settings to set when loading an Animate Atlas.
	 * @return All the Sparrow, Aseprite, Packer or Animate Atlas frames.
	 */
	public static function getMultipleFrames(paths:Array<String>, ?library:String, ?animateSettings:AnimateAtlasSettings):FlxAtlasFrames
	{
		var mainAtlas:FlxAtlasFrames = getFrames(paths[0]);

		if (paths.length > 1)
		{
			for (i in 1...paths.length)
			{
				mainAtlas.addAtlas(getFrames(paths[i]));
			}
		}

		return mainAtlas;
	}

	/**
	 * @param path 				The path to the directory.
	 * @param library 		The library to reference.
	 * @param includePath Whether to include the path that leads to the files.
	 * @return The list of files inside the directory.
	 */
	public static function readDirectory(path:String, ?library:String, includePath:Bool = false):Array<String>
	{
		var assetPath:String = getPath(path, library);

		if (!assetPath.endsWith('/'))
		{
			assetPath += '/';
		}

		var directory:Array<String> = Assets.list().filter(file -> file.startsWith(assetPath));

		if (!includePath)
		{
			directory = directory.map(file -> file.replace(path, ''));
		}

		return directory;
	}

	static function getLanguageSuffix(path:String):String
	{
		if (Translations.curLanguageID == Constants.DEFAULT_LANGUAGE)
		{
			return path;
		}
		else
		{
			return '$path-${Translations.curLanguageID}';
		}
	}
}
