package funkin.graphics;

import animate.FlxAnimate;
import animate.FlxAnimateFrames;

import flixel.animation.FlxAnimation;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;

import funkin.graphics.animation.FunkinAnimationController;
import funkin.system.FunkinMemory;

import openfl.display.BitmapData;

typedef AnimateAtlasSettings =
{
	> FlxAnimateSettings,

	/**
	 * An array of spritemaps for the atlas to load.
	 */
	@:optional
	var spritemaps:Array<SpritemapInput>;

	/**
	 * Meta data of the atlas, JSON-formatted.
	 */
	@:optional
	var metadata:String;

	/**
	 * Forces the cache to use a specific key to index the texture atlas.
	 */
	@:optional
	var cacheKey:String;

	/**
	 * Whether the atlas uses a unique slot in cache instead of reusing an existing identical one.
	 */
	@:optional
	var uniqueCache:Bool;

	/**
	 * Whether to apply the stage matrix.
	 *
	 * Makes the sprite render with the bounds set in Animate.
	 */
	@:optional
	var applyStageMatrix:Bool;

	/**
	 * When enabled, the graphic will render as one whole texture.
	 *
	 * Recommended to enable when modifying the opacity of the sprite, applying shaders or applying a blend mode.
	 */
	@:optional
	var useRenderTexture:Bool;
}

@:access(animate.FlxAnimateController)
class FunkinSprite extends FlxAnimate
{
	/**
	 * @return The default settings for a texture atlas sprite.
	 */
	public static function getDefaultAtlasSettings():AnimateAtlasSettings
	{
		return {
			swfMode: false,
			cacheOnLoad: false,
			filterQuality: MEDIUM,
			onSymbolCreate: null,
			spritemaps: null,
			metadata: null,
			cacheKey: null,
			uniqueCache: false,
			applyStageMatrix: false,
			useRenderTexture: false
		};
	}

	/**
	 * Whether the sprite should round its position like it's in a grid, using its scale as the grid size.
	 */
	public var useGridPosition:Bool = false;

	/**
	 * Dispatches each time an animation finishes playing.
	 *
	 * @param name The name of the animation.
	 */
	public var onFinishAnimation:FlxTypedSignal<(name:String) -> Void> = new FlxTypedSignal<(name:String) -> Void>();

	var animationOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	var animationOffset(default, set):Array<Float> = [0, 0];

	public function new(x:Float = 0, y:Float = 0, ?graphic:FlxGraphicAsset)
	{
		super(x, y);

		if (graphic != null)
		{
			loadSprite(graphic);
		}

		antialiasing = false;
	}

	override function initVars()
	{
		super.initVars();

		animation = anim = new FunkinAnimationController(this);

		animation.onFinish.add(onAnimationFinish);
	}

	override public function destroy()
	{
		super.destroy();

		FlxDestroyUtil.destroy(onFinishAnimation);

		animationOffsets = null;
		animationOffset = null;
	}

	/**
	 * Rescales the sprite and updates it's hitbox automatically.
	 *
	 * @param x How much to scale it horizontally.
	 * @param y How much to scale it vertically. If not set, it will use the same value as `x`.
	 */
	public function scaleSprite(x:Float = 1, ?y:Float)
	{
		if (y == null)
		{
			y = x;
		}

		this.scale.set(x, y);
		updateHitbox();
	}

	/**
	 * Loads an image to this `FunkinSprite` from an external or embedded graphic file and loads its frames
	 * if a valid file is found along side it at the same file directory path.
	 *
	 * @param graphic   The graphic to want to load and parse the frames from. Must be a file path (a `String`) in order to load the frames.
	 * @return This `FunkinSprite` instance, for chaining.
	 */
	public function loadSprite(graphic:FlxGraphicAsset, ?animateSettings:AnimateAtlasSettings):FunkinSprite
	{
		if ((graphic is String))
		{
			frames = Paths.getFrames(graphic, animateSettings);
		}
		else
		{
			loadGraphic(graphic);
		}

		if (animateSettings != null)
		{
			this.applyStageMatrix = animateSettings?.applyStageMatrix ?? false;
			this.useRenderTexture = animateSettings?.useRenderTexture ?? false;
		}

		return this;
	}

	/**
	 * Alternative to using `loadGraphicFromSprite` and inserting the same instance.
	 * @return A new instance of a copy of this `FunkinSprite` instance.
	 */
	override public function clone():FunkinSprite
	{
		return cast new FunkinSprite().loadGraphicFromSprite(this);
	}

	/**
	 * Loads an image to this sprite from an external or embedded graphic file.
	 *
	 * @param graphic       The graphic you want to load.
	 * @param animated      Whether the graphic is animated, if it is then `frameWidth` and `frameHeight` must be set.
	 * @param frameWidth    The width of the graphic, if not set then it just uses the width of the graphic.
	 * @param frameHeight   The height of the graphic, if not set then it just uses the height of the graphic.
	 * @param unique        Whether the graphic is unique to this sprite.
	 *                      This means that the graphic is a unique instance in HaxeFlixel's graphics cache, so whenever
	 *                      you change the `pixels` of this sprite, it wouldn't affect other sprites using the same graphic.
	 * @param key           Set this to force the cache backend to index it with a unique key.
	 * @return              This `FunkinSprite` instance, for chaining.
	 */
	override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):FunkinSprite
	{
		if ((graphic is String))
		{
			var graph:FlxGraphic = FunkinMemory.getGraphic(graphic);
			super.loadGraphic(graph, animated, frameWidth, frameHeight, unique);
		}
		else
		{
			super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
		}

		return this;
	}

	/**
	 * Loads an image to this sprite from an external or embedded graphic file asynchronously.
	 *
	 * @param graphic 			The graphic you want to load.
	 * @param animated      Whether the graphic is animated, if it is then `frameWidth` and `frameHeight` must be set.
	 * @param frameWidth    The width of the graphic, if not set then it just uses the width of the graphic.
	 * @param frameHeight   The height of the graphic, if not set then it just uses the height of the graphic.
	 * @param unique        Whether the graphic is unique to this sprite.
	 *                      This means that the graphic is a unique instance in HaxeFlixel's graphics cache, so whenever
	 *                      you change the `pixels` of this sprite, it wouldn't affect other sprites using the same graphic.
	 * @param key           Set this to force the cache backend to index it with a unique key.
	 * @return              This `FunkinSprite` instance, for chaining.
	 */
	public function loadGraphicAsync(graphic:String, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):FunkinSprite
	{
		this.graphic.persist = true;
		Assets.loadBitmapData(graphic).onComplete(function(bitmap:BitmapData)
		{
			loadGraphic(bitmap, animated, frameWidth, frameHeight, unique, key);
		}).onError(function(error:Dynamic)
		{
				FlxG.log.error('Couldn\'t load graphic asynchronously! (error: $error)');
		});

		return this;
	}

	/**
	 * Creates a rectangle graphic with a single color and loads it into the sprite.
	 *
	 * If you're not going to modify the sprite in any way, I recommend you use `makeSolid` instead of this function.
	 *
	 * @param width     The width of the rectangle.
	 * @param height    The height of the rectangle.
	 * @param color     The color of the rectangle.
	 * @param unique    Whether the graphic is unique to this sprite.
	 *                  This means that the graphic is a unique instance in HaxeFlixel's graphics cache, so whenever
	 *                  you change the `pixels` of this sprite, it wouldn't affect other sprites using the same graphic.
	 * @param key       Set this to force the cache backend to index it with a unique key.
	 * @return          This `FunkinSprite` instance, for chaining.
	 */
	override function makeGraphic(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String):FunkinSprite
	{
		super.makeGraphic(width, height, color, unique, key);
		return this;
	}

	/**
	 * Creates a rectangle graphic with a single color and loads it into this sprite.
	 *
	 * It's much more forgiving in terms of memory usage than `makeGraphic`, but with the cost of not being able to draw on it.
	 *
	 * @param width     The width of the rectangle.
	 * @param height    The height of the rectangle.
	 * @param color     The color of the rectangle.
	 * @return          This `FunkinSprite` instance, for chaining.
	 */
	public function makeSolid(width:Int, height:Int, color:FlxColor = FlxColor.WHITE):FunkinSprite
	{
		var graphic:FlxGraphic = FlxG.bitmap.create(1, 1, color, false, 'solid#${color.toHexString(true, false)}');
		frames = graphic.imageFrame;
		scaleSprite(width, height);
		return this;
	}

	/**
	 * Deletes all the animations stored in the sprite and restores the frame rect so it shows the entire loaded graphic.
	 * @return This `FunkinSprite` instance.
	 */
	public function restoreGraphic():FunkinSprite
	{
		animation.destroyAnimations();
		frames = graphic.imageFrame;
		return this;
	}

	/**
	 * Returns the screen position of this sprite.
	 *
	 * Accounts for animation offsets.
	 *
	 * @param result 	Optional argument for the returning point.
	 * @param camera 	The screen coordinate space. If `null`, fallbacks to `getDefaultCamera`.
	 * @return The screen position of this object.
	 */
	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		var output:FlxPoint = super.getScreenPosition(result, camera);
		output.x += animationOffset[0] * scale.x;
		output.y += animationOffset[1] * scale.y;
		return output;
	}

	override function preparePixelPerfectMatrix(matrix:FlxMatrix)
	{
		if (useGridPosition)
		{
			matrix.tx = MathUtil.roundToGrid(matrix.tx, scale.x);
			matrix.ty = MathUtil.roundToGrid(matrix.ty, scale.y);
		}
		else
		{
			super.preparePixelPerfectMatrix(matrix);
		}
	}

	@:access(flixel.FlxCamera)
	override function getBoundingBox(camera:FlxCamera):FlxRect
	{
		getScreenPosition(_point, camera);

		_rect.set(_point.x, _point.y, width, height);
		_rect = camera.transformRect(_rect);

		if (isPixelPerfectRender(camera))
		{
			if (useGridPosition)
			{
				_rect.x = MathUtil.roundToGrid(_rect.x, scale.x);
				_rect.y = MathUtil.roundToGrid(_rect.y, scale.y);
				_rect.width = MathUtil.roundToGrid(_rect.width, scale.x);
				_rect.height = MathUtil.roundToGrid(_rect.height, scale.y);
			}

			_rect.floor();
		}

		return _rect;
	}

	/**
	 * Plays an existing animation. Doesn't do anything if an animation with the same name is already playing.
	 *
	 * @param animation The name of the animation.
	 * @param force     Whether to force the animation to restart.
	 * @param reverse   Whether to play the animation in reverse.
	 * @param frame     From which frame to start playing the animation. If any number below `0` is set, it will play from a random frame.
	 */
	public function playAnimation(?animation:String, force:Bool = false, reverse:Bool = false, frame:Int = 0)
	{
		var validAnimation:Null<String> = null;

		if (animation != null && hasAnimation(animation))
		{
			validAnimation = animation;
		}
		else if (hasAnimation(getDefaultAnimation()))
		{
			validAnimation = getDefaultAnimation();
		}

		this.animation.play(validAnimation, force, reverse, frame);

		var animOffset:Array<Float> = getAnimationOffsets(validAnimation);

		if (animOffset == null)
		{
			animOffset = [0, 0];
		}

		animationOffset = animOffset;
	}

	/**
	 * Replays the current playing animation.
	 */
	public function replayAnimation()
	{
		var curAnimation:FlxAnimation = getCurrentAnimation();
		if (curAnimation != null)
		{
			curAnimation.play(true, curAnimation.reversed);
		}
	}

	/**
	 * Adds a new animation to the sprite.
	 *
	 * @param animation The animation name.
	 * @param frames    The frame indices of the animation.
	 * @param framerate The speed the animation should play at, in frames per second.
	 * @param looped    Whether or not the animation should loop indefinitely when it finishes playing.
	 * @param flipX     Whether the frames of the animation should be flipped horizontally.
	 * @param flipY     Whether the frames of the animation should be flipped vertically.
	 */
	public function addAnimationByFrameList(animation:String, ?frames:Array<Int>, framerate:Float = 24, looped:Bool = true, flipX:Bool = false, flipY:Bool = false)
	{
		if (frames == null)
		{
			frames = [0];
		}

		this.animation.add(animation, frames, framerate, looped, flipX, flipY);
	}

	/**
	 * Makes the whole sprite an animation.
	 *
	 * @param frames    The amount of frames the animation has.
	 * @param framerate The speed the animation should play at, in frames per second.
	 * @param looped    Whether or not the animation should loop indefinitely when it finishes playing.
	 * @param flipX     Whether the frames of the animation should be flipped horizontally.
	 * @param flipY     Whether the frames of the animation should be flipped vertically.
	 */
	public function addAnimationByFrameLength(frames:Int, framerate:Float = 24, looped:Bool = true, flipX:Bool = false, flipY:Bool = false)
	{
		if (hasAnimation(Constants.DEFAULT_ANIMATION_NAME))
		{
			FlxG.log.warn('Sprite already has the default animation set up!');
			return;
		}

		var framesLength:Array<Int> = [for (i in 0...frames) i];
		addAnimationByFrameList(Constants.DEFAULT_ANIMATION_NAME, framesLength, framerate, looped, flipX, flipY);
		playAnimation();
	}

	/**
	 * Adds a new animation to the sprite.
	 *
	 * @param animation The animation name.
	 * @param prefix    The name of the animation in the atlas.
	 * @param framerate The speed the animation should play at, in frames per second.
	 * @param looped    Whether or not the animation should loop indefinitely when it finishes playing.
	 * @param flipX     Whether the frames of the animation should be flipped horizontally.
	 * @param flipY     Whether the frames of the animation should be flipped vertically.
	 */
	public function addAnimationByPrefix(animation:String, prefix:String, framerate:Float = 24, looped:Bool = true, flipX:Bool = false, flipY:Bool = false)
	{
		this.animation.addByPrefix(animation, prefix, framerate, looped, flipX, flipY);
	}

	/**
	 * Adds offsets to an animation.
	 *
	 * @param animation The animation.
	 * @param x 				Horizontal offset.
	 * @param y 				Vertical offset.
	 */
	public function addAnimationOffsets(?animation:String, x:Float = 0, y:Float = 0)
	{
		if (animation == null)
		{
			animation = Constants.DEFAULT_ANIMATION_NAME;
		}

		animationOffsets.set(animation, [x, y]);
	}

	/**
	 * Gets called when an animation finishes playing.
	 * @param animation The animation name that just finished playing.
	 */
	public function onAnimationFinish(animation:String)
	{
		if (hasAnimation('$animation-loop'))
		{
			playAnimation('$animation-loop');
		}

		onFinishAnimation.dispatch(animation);
	}

	/**
	 * @param animation The animation name.
	 * @return The `FlxAnimation` instance. If it doesn't exists, returns `null`.
	 */
	public function getAnimation(animation:String):Null<FlxAnimation>
	{
		if (!hasAnimation(animation))
		{
			return null;
		}

		return this.animation.getByName(animation);
	}

	/**
	 * @return The default animation name.
	 */
	public function getDefaultAnimation():String
	{
		if (anim.hasAnimateAtlas)
		{
			return library.timeline.name;
		}

		return Constants.DEFAULT_ANIMATION_NAME;
	}

	/**
	 * @return The current playing `FlxAnimation`. Can be `null`!
	 */
	public function getCurrentAnimation():Null<FlxAnimation>
	{
		return animation.curAnim;
	}

	/**
	 * @param animation The animation name.
	 * @return The animation offsets. If it doesn't exists, returns `null`.
	 */
	public function getAnimationOffsets(animation:String):Null<Array<Float>>
	{
		return animationOffsets.get(animation);
	}

	/**
	 * @param animation The animation to check, by it's name.
	 * @return Whether if an animation with the matching name exists.
	 */
	public function hasAnimation(animation:String):Bool
	{
		return listAnimations().contains(animation);
	}

	/**
	 * @return An array containing all the animations the sprite has.
	 */
	public function listAnimations():Array<String>
	{
		return animation.getNameList().concat(listFrameLabels());
	}

	/**
	 * @return An array containing all the frame labels of the sprite. Only works if the sprite is a valid
	 * Animate Atlas, if it isn't, it will return an empty array.
	 */
	public function listFrameLabels():Array<String>
	{
		if (!anim.hasAnimateAtlas)
		{
			return [];
		}

		var labels:Array<String> = [];

		for (layer in library.timeline.layers)
		{
			for (frame in layer.frames)
			{
				if (frame.name.trim() != '')
				{
					labels.push(frame.name);
				}
			}
		}

		return labels;
	}

	/**
	 * Removes the specified animation, if it exists.
	 * @param animation The animation to remove.
	 */
	public function removeAnimation(animation:String)
	{
		if (!hasAnimation(animation))
		{
			FlxG.log.warn('You can\'t remove the animation "$animation" because it doesn\'t exists!');
			return;
		}

		getAnimation(animation).destroy();
		@:privateAccess this.animation._animations.remove(animation);
	}

	function set_animationOffset(value:Array<Float>):Array<Float>
	{
		if (value == null)
		{
			value = [0, 0];
		}

		if (value[0] == animationOffset[0] && value[1] == animationOffset[1])
		{
			return value;
		}

		return animationOffset = value;
	}
}
