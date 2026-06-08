package funkin;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxAsepriteJsonAsset;
import flixel.system.FlxAssets.FlxXmlAsset;

import funkin.system.FunkinMemory;
import funkin.system.Translations;

import haxe.io.Path;

/**
 * Helper class to get the location of files inside the assets folder.
 */
class Paths
{
	/**
	 * Gets the full directory of the specified path.
	 *
	 * @param path 			Where you want the directory to lead to.
	 * @param library 	What library to reference.
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
	 * @param library 	What library to reference.
	 * @return The full directory.
	 */
	public static function getDynamicPath(path:String, library:String = 'default'):String
	{
		return (library == 'default' || library == 'main') ? getMainPath(path) : getLibraryPath(path, library);
	}

	/**
	 * Gets the full directory of the specified path, along side it's library.
	 *
	 * @param path 			Where you want the directory to lead to.
	 * @param library 	What library to reference.
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
	 * @param path 			Where you want the directory to lead to.
	 * @return The full directory.
	 */
	public inline static function getMainPath(path:String):String
	{
		return 'assets/$path';
	}

	/**
	 * Gets the full directory of the specified path, referencing the embedded `impostor` directory.
	 *
	 * @param path 			Where you want the directory to lead to.
	 * @return The full directory.
	 */
	public inline static function impostor(path:String):String
	{
		return 'impostor/$path';
	}

	/**
	 * @param path 			Where you want the directory to lead to.
	 * @param library 	What library to reference.
	 * @return The full directory to the file.
	 */
	public inline static function file(path:String, ?library:String):String
	{
		return getPath(path, library);
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
	 * @param path						Where the `.xml` sprite data is located at.
	 * @param library					What library to reference.
	 * @param ignoreLanguage	Whether the language suffix should be ignored.
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
	 * @param path						Where the `.json` sprite data is located at.
	 * @param library					What library to reference.
	 * @param ignoreLanguage	Whether the language suffix should be ignored.
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
	 * @param path						Where the `.txt` sprite data is located at.
	 * @param library					What library to reference.
	 * @param ignoreLanguage	Whether the language suffix should be ignored.
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
	 * @param library 	What library to reference.
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
	 * @param library 	What library to reference.
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

	public inline static function getSparrowFrames(graphic:FlxGraphic, xml:FlxXmlAsset):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(graphic, xml);
	}

	public inline static function getAsepriteFrames(graphic:FlxGraphic, json:FlxAsepriteJsonAsset):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromAseprite(graphic, json);
	}

	public inline static function getPackerFrames(graphic:FlxGraphic, txt:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(graphic, txt);
	}

	public static function getFrames(path:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FunkinMemory.getGraphic(path);
		var pathNoExt:String = Path.withoutExtension(path);

		if (Assets.exists('$pathNoExt.xml', TEXT))
		{
			return getSparrowFrames(graphic, '$pathNoExt.xml');
		}
		else if (Assets.exists('$pathNoExt.json', TEXT))
		{
			return getAsepriteFrames(graphic, '$pathNoExt.json');
		}
		else if (Assets.exists('$pathNoExt.txt', TEXT))
		{
			return getPackerFrames(graphic, '$pathNoExt.txt');
		}

		return null;
	}

	public static function getMultipleFrames(paths:Array<String>):FlxAtlasFrames
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
	 * Returns all the assets inside the specified directory.
	 * @param path 				The path to the directory.
	 * @param recursive		Whether to check for subdirectories as well.
	 * @return The list of files inside the directory.
	 */
	public static function readDirectory(path:String, ?library:String, recursive:Bool = false):Array<String>
	{
		var assetPath:String = getPath(path, library);

		if (!assetPath.endsWith('/'))
		{
			assetPath += '/';
		}

		var directory:Array<String> = Assets.list().filter(file -> file.startsWith(assetPath));

		if (recursive)
		{
			for (file in directory)
			{
				if (Path.extension(file) == '')
				{
					directory = directory.concat(readDirectory(file));
				}
			}
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
