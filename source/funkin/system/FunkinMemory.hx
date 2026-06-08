package funkin.system;

import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;

class FunkinMemory
{
	/**
	 * The total amount of bytes stored in-memory.
	 */
	public static var bytesLoaded(default, null):Int = 0;

	static var cachedGraphics:Map<String, FlxGraphic> = [];
	static var cachedSounds:Map<String, Sound> = [];

	static var temporalCachedGraphics:Map<String, FlxGraphic> = [];

	static var trackedBytes:Map<String, ByteArray> = [];

	/**
	 * Caches a graphic asset from a `BitmapData` source.
	 *
	 * It needs a key so it can be retrieved later.
	 *
	 * @param bitmap 	The `BitmapData` source.
	 * @param key 		The stored key of the graphic asset.
	 */
	public static function cacheFromBitmap(bitmap:BitmapData, key:String)
	{
		if (isGraphicCached(key) || bitmap == null)
		{
			return;
		}

		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		cachedGraphics.set(key, newGraphic);
		trackGraphicBytes(key);
		updateBytesTracker();
	}

	/**
	 * Caches a sound asset from a `Sound` source.
	 *
	 * It needs a key so it can be retrieved later.
	 *
	 * @param sound 	The `Sound` source.
	 * @param key 		The stored key of the sound asset.
	 */
	public static function cacheFromSound(sound:Sound, key:String)
	{
		if (isSoundCached(key) || sound == null)
		{
			return;
		}

		cachedSounds.set(key, sound);
		trackGraphicBytes(key);
		updateBytesTracker();
	}

	/**
	 * Caches a graphic asset found in the specified directory.
	 *
	 * @param key The stored key of the graphic asset (99.9% of the time will be the path leading to it).
	 * @return The `FlxGraphic` with the loaded graphic asset, or `null` if it doesn't exist.
	 */
	public static function getGraphic(key:String):FlxGraphic
	{
		if (isGraphicCached(key))
		{
			return cachedGraphics.get(key);
		}

		var newGraphic:FlxGraphic = FlxGraphic.fromAssetKey(key);
		if (newGraphic == null)
		{
			FlxG.log.error('Couldn\'t cache graphic with key "$key"!');
			return null;
		}

		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		forceGraphicRender(newGraphic);
		cachedGraphics.set(key, newGraphic);
		trackGraphicBytes(key);
		updateBytesTracker();
		return newGraphic;
	}

	/**
	 * Caches a sound asset found in the specified directory.
	 *
	 * @param key The stored key of the sound asset (99.9% of the time will be the path leading to it).
	 * @return The `Sound` with the loaded sound asset, or `null` if it doesn't exist.
	 */
	public static function getSound(key:String):Sound
	{
		if (isSoundCached(key))
		{
			return cachedSounds.get(key);
		}

		var newSound:Sound = Assets.getSound(key);
		if (newSound == null)
		{
			FlxG.log.error('Couldn\'t cache sound with key "$key"!');
			return null;
		}

		cachedSounds.set(key, newSound);
		trackGraphicBytes(key);
		updateBytesTracker();
		return newSound;
	}

	/**
	 * Caches a music asset found in the specified directory.
	 *
	 * @param key The stored key of the music asset (99.9% of the time will be the path leading to it).
	 * @return The `Sound` with the loaded music asset, or `null` if it doesn't exist.
	 */
	public static function getMusic(key:String):Sound
	{
		if (isMusicCached(key))
		{
			return cachedSounds.get(key);
		}

		var newSound:Sound = Assets.getMusic(key);
		if (newSound == null)
		{
			FlxG.log.error('Couldn\'t cache sound with key "$key"!');
			return null;
		}

		cachedSounds.set(key, newSound);
		trackGraphicBytes(key);
		updateBytesTracker();
		return newSound;
	}

	/**
	 * @param key The key the graphic is stored with.
	 * @return Whether the graphic is cached or not.
	 */
	public static function isGraphicCached(key:String):Bool
	{
		return cachedGraphics.exists(key);
	}

	/**
	 * @param key The key the sound is stored with.
	 * @return Whether the sound is cached or not.
	 */
	public static function isSoundCached(key:String):Bool
	{
		return cachedSounds.exists(key);
	}

	/**
	 * @param key The key the music is stored with.
	 * @return Whether the music is cached or not.
	 */
	public static function isMusicCached(key:String):Bool
	{
		return isSoundCached(key);
	}

	static function forceGraphicRender(graphic:FlxGraphic)
	{
		if (graphic == null)
		{
			return;
		}

		var sprite:flixel.FlxSprite = new flixel.FlxSprite().loadGraphic(graphic);
		sprite.draw();
		graphic.bitmap.getTexture(FlxG.stage.context3D);
		sprite.destroy();
	}

	static function trackGraphicBytes(file:String)
	{
		#if web
		ByteArray.loadFromFile(file).onComplete(function(bytes:ByteArray)
		{
			if (bytes != null)
			{
				trackedBytes.set(file, bytes);
			}
			updateBytesTracker();
		});
		#else
		var byteArray:ByteArray = ByteArray.fromFile(file);

		if (byteArray != null)
		{
			trackedBytes.set(file, byteArray);
		}
		#end
	}

	static function updateBytesTracker()
	{
		bytesLoaded = 0;

		for (key => graphic in cachedGraphics)
		{
			bytesLoaded += trackedBytes.get(key)?.length ?? 0;
		}

		for (key => graphic in temporalCachedGraphics)
		{
			bytesLoaded += trackedBytes.get(key)?.length ?? 0;
		}

		for (key => sound in cachedSounds)
		{
			bytesLoaded += sound.bytesTotal;
		}
	}
}
