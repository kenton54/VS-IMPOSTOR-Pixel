package funkin.system;

import flixel.graphics.FlxGraphic;

import openfl.media.Sound;

class FunkinMemory
{
	static var cachedGraphics:Map<String, FlxGraphic> = [];
	static var cachedSounds:Map<String, Sound> = [];

	/**
	 * Caches a graphic found in the specified directory.
	 *
	 * @param key The stored key of the graphic (99.9% of the time will be the path leading to it).
	 * @return The `FlxGraphic` with the loaded graphic file, or `null` if it doesn't exist.
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
		return newGraphic;
	}

	/**
	 * Caches a sound found in the specified directory.
	 *
	 * @param key The stored key of the sound (99.9% of the time will be the path leading to it).
	 * @return The `Sound` with the loaded sound file, or `null` if it doesn't exist.
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
		return newSound;
	}

	/**
	 * Caches a music found in the specified directory.
	 *
	 * @param key The stored key of the music (99.9% of the time will be the path leading to it).
	 * @return The `Sound` with the loaded music file, or `null` if it doesn't exist.
	 */
	public static function getMusic(key:String):Sound
	{
		if (isSoundCached(key))
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
}
