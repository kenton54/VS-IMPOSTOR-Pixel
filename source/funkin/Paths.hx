package funkin;

import flixel.graphics.frames.FlxAtlasFrames;

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
	 * @param path 			Where the `.png` graphic file is located at.
	 * @param library 	What library to reference.
	 * @return The full directory to the file.
	 */
	public static function image(path:String, ?library:String, ?ignoreLanguage:Bool = true):String
	{
		var path:String = getPath('images/$path.png', library);
		var pathLang:String = getPath('images/' + getLanguageSuffix(path) + '.png', library);

		if (!ignoreLanguage && Assets.exists(pathLang, IMAGE))
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
		var pathLang:String = getPath('sounds/' + getLanguageSuffix(path) + '.ogg', library);

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
		return getLibraryPath('$path.mp4', 'videos');
	}

	public inline static function getSparrowFrames(path:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(path, library), file('images/$path.xml', library));
	}

	public inline static function getAsepriteFrames(path:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromAseprite(image(path, library), file('images/$path.json', library));
	}

	public inline static function getPackerFrames(path:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(path, library), file('images/$path.json', library));
	}

	public static function getFrames(path:String, ?library:String):FlxAtlasFrames
	{
		if (Assets.exists(file('images/$path.xml')))
		{
			return getSparrowFrames(path, library);
		}
		else if (Assets.exists(file('images/$path.json')))
		{
			return getAsepriteFrames(path, library);
		}
		else if (Assets.exists(file('images/$path.txt')))
		{
			return getPackerFrames(path, library);
		}

		return null;
	}

	public static function getMultipleFrames(paths:Array<String>, ?library):FlxAtlasFrames
	{
		var mainAtlas:FlxAtlasFrames = getFrames(paths[0], library);
		if (paths.length > 1)
		{
			for (i in 1...paths.length)
				mainAtlas.addAtlas(getFrames(paths[i], library));
		}

		return mainAtlas;
	}

	static function getLanguageSuffix(path:String):String
	{
		if (Translations.curLanguageID == Defaults.DEFAULT_LANGUAGE)
		{
			return path;
		}
		else
		{
			return '$path-${Translations.curLanguageID}';
		}
	}
}
