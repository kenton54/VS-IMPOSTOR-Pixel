package funkin.graphics.animation;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.system.FlxAssets.FlxGraphicAsset;

import haxe.io.Path;

/**
 * Makes it possible for frames to hold a unique graphic.
 */
class FlxAssetsFrames extends FlxAtlasFrames
{
	var assetsGraphics:Array<FlxGraphic> = [];

	public function new(parent:FlxGraphic)
	{
		super(parent);
	}

	override function destroy()
	{
		super.destroy();

		while (assetsGraphics.length > 0)
		{
			assetsGraphics.shift().decrementUseCount();
		}
	}

	/**
	 * Loads a frame collection from a list of graphic assets.
	 *
	 * @param paths The assets to create the frame collection from.
	 * @return Newly created `FlxAssetsFrames` collection.
	 */
	public static function fromAssets(paths:Array<FlxGraphicAsset>):FlxAssetsFrames
	{
		var initialGraphic:FlxGraphic = FlxG.bitmap.add(paths[0]);
		if (initialGraphic == null)
		{
			return null;
		}

		var assetsFrames:FlxAssetsFrames = cast FlxAtlasFrames.findFrame(initialGraphic);
		if (assetsFrames != null)
		{
			return assetsFrames;
		}

		var frames:FlxAssetsFrames = new FlxAssetsFrames(initialGraphic);

		for (i => path in paths)
		{
			var assFile:Path = new Path(path);

			var graphic:FlxGraphic = i == 0 ? initialGraphic : FlxG.bitmap.add(path);
			frames.addAssetFrame(graphic, assFile.file);
		}

		return frames;
	}

	/**
	 * Adds a new frame to this frame collection.
	 *
	 * @param graphic The graphic to bind to the frame.
	 * @param name 		Name of the frame, usually it's the filename.
	 * @return Newly created and added frame.
	 */
	public function addAssetFrame(graphic:FlxGraphic, name:String):FlxFrame
	{
		if (exists(name))
		{
			return getByName(name);
		}

		assetsGraphics.push(graphic);

		var assFrame:FlxFrame = new FlxFrame(graphic);
		assFrame.name = name;
		assFrame.sourceSize.set(graphic.width, graphic.height);
		return pushFrame(assFrame);
	}
}
