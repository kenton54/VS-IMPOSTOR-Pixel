package funkin.utils;

import lime.utils.AssetLibrary as LimeAssetLibrary;
import lime.utils.Assets as LimeAssets;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.ByteArray;
import openfl.utils.Future;
import openfl.utils.IAssetCache;

class Assets
{
	@:inheritDoc(openfl.utils.Assets.cache)
	public static var cache(get, never):IAssetCache;

	@:inheritDoc(openfl.utils.Assets.exists)
	public static function exists(id:String, ?type:AssetType):Bool
	{
		return OpenFLAssets.exists(id, type);
	}

	@:inheritDoc(openfl.utils.Assets.getPath)
	public static function getPath(id:String):String
	{
		return OpenFLAssets.getPath(id);
	}

	@:inheritDoc(openfl.utils.Assets.getBitmapData)
	public static function getBitmapData(id:String, useCache:Bool = true):BitmapData
	{
		return OpenFLAssets.getBitmapData(id, useCache);
	}

	@:inheritDoc(openfl.utils.Assets.getBytes)
	public static function getBytes(id:String):ByteArray
	{
		return OpenFLAssets.getBytes(id);
	}

	@:inheritDoc(openfl.utils.Assets.getText)
	public static function getText(id:String):String
	{
		return OpenFLAssets.getText(id);
	}

	@:inheritDoc(openfl.utils.Assets.getFont)
	public static function getFont(id:String, useCache:Bool = true):Font
	{
		return OpenFLAssets.getFont(id, useCache);
	}

	@:inheritDoc(openfl.utils.Assets.getMusic)
	public static function getMusic(id:String, useCache:Bool = true):Sound
	{
		return OpenFLAssets.getMusic(id, useCache);
	}

	@:inheritDoc(openfl.utils.Assets.getSound)
	public static function getSound(id:String, useCache:Bool = true):Sound
	{
		return OpenFLAssets.getSound(id, useCache);
	}

	@:inheritDoc(openfl.utils.Assets.getLibrary)
	public static function getLibrary(name:String):#if lime LimeAssetLibrary #else AssetLibrary #end
	{
		return OpenFLAssets.getLibrary(name);
	}

	@:inheritDoc(openfl.utils.Assets.list)
	public static function list(?type:AssetType):Array<String>
	{
		return OpenFLAssets.list(type);
	}

	/**
	 * Returns all the assets inside the specified directory.
	 * @param path The path to the directory.
	 * @return The list of files inside the directory.
	 */
	public static function readDirectory(path:String):Array<String>
	{
		var directory:Array<String> = list().filter(file -> file.startsWith(path));
		return directory.map(file -> file.replace(path, '').replace('/', ''));
	}

	@:inheritDoc(openfl.utils.Assets.loadBitmapData)
	public static function loadBitmapData(id:String, useCache:Bool = true):Future<BitmapData>
	{
		return OpenFLAssets.loadBitmapData(id, useCache);
	}

	@:inheritDoc(openfl.utils.Assets.loadBytes)
	public static function loadBytes(id:String):Future<ByteArray>
	{
		return OpenFLAssets.loadBytes(id);
	}

	@:inheritDoc(openfl.utils.Assets.loadFont)
	public static function loadFont(id:String, useCache:Bool = true):Future<Font>
	{
		return OpenFLAssets.loadFont(id, useCache);
	}

	@:inheritDoc(openfl.utils.Assets.loadMusic)
	public static function loadMusic(id:String, useCache:Bool = true):Future<Sound>
	{
		return OpenFLAssets.loadMusic(id, useCache);
	}

	@:inheritDoc(openfl.utils.Assets.loadSound)
	public static function loadSound(id:String, useCache:Bool = true):Future<Sound>
	{
		return OpenFLAssets.loadSound(id, useCache);
	}

	@:inheritDoc(openfl.utils.Assets.loadLibrary)
	public static function loadLibrary(name:String):#if lime Future<LimeAssetLibrary> #else Future<AssetLibrary> #end
	{
		#if lime
		return cast LimeAssets.loadLibrary(name).then(function(library:LimeAssetLibrary)
		{
			var _library:AssetLibrary = null;

			if (library != null)
			{
				if ((library is AssetLibrary))
				{
					_library = cast library;
				}
				else
				{
					LimeAssets.removeLibrary(name, false);
					_library = new AssetLibrary();
					@:privateAccess _library.__proxy = library;
					LimeAssets.registerLibrary(name, _library);
				}
			}

			return Future.withValue(_library);
		});
		#else
		return cast Future.withError("Cannot load library");
		#end
	}

	@:inheritDoc(openfl.utils.Assets.loadText)
	public static function loadText(id:String):Future<String>
	{
		return OpenFLAssets.loadText(id);
	}

	static function get_cache():IAssetCache
	{
		return OpenFLAssets.cache;
	}
}
