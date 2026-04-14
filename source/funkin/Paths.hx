package funkin;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import haxe.io.Path;

#if sys
import sys.FileSystem;
#end

class Paths
{
	public static function getPath(path:String, ?library:String):String
	{
		return library != null ? '$library:assets/$library/$path' : 'assets/$path';
	}

	public inline static function file(path:String, ?library:String):String
	{
		return getPath(path, library);
	}

	public inline static function json(path:String, ?library:String):String
	{
		return getPath('data/$path.json', library);
	}

	public static function image(path:String, ?library:String):String
	{
		var path:String = getPath('images/$path.png', library);
		var pathNoExt:String = Path.withoutExtension(path);
		var extension:String = Path.extension(path);

		if (Assets.exists('$pathNoExt-${funkin.system.Translations.curLanguageID}'))
		{
			return '$pathNoExt-${funkin.system.Translations.curLanguageID}.$extension';
		}
		else
		{
			return path;
		}
	}

	public inline static function sound(path:String, ?library:String):String
	{
		return getPath('sounds/$path.ogg', library);
	}

	public inline static function music(path:String, ?library:String):String
	{
		return getPath('music/$path.ogg', library);
	}

	public inline static function font(path:String):String
	{
		return getPath('fonts/$path');
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
}
