package funkin.ui;

import flixel.FlxBasic;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;

/**
 * Used to show a starry night sky.
 */
class StarsBackdrop extends FlxBasic
{
	/**
	 * The amount of layers the backdrop has.
	 */
	public var layers(default, set):Int;

	/**
	 * The speed at which each layer moves horizontally.
	 */
	public var horizontalSpeed(default, set):Float;

	/**
	 * The speed at which each layer moves vertically
	 */
	public var verticalSpeed(default, set):Float;

	/**
	 * The scale of all the layers.
	 */
	public var scale(default, set):Float;

	/**
	 * How much each layer is affected by camera scrolling.
	 */
	public var scrollFactor(default, set):Float;

	public var clipRect(default, set):FlxRect;

	var starsArray:Array<FlxBackdrop> = [];
	var shootingStars:Array<FunkinSprite> = [];

	public function new(speed:Float = 20, layerAmount:Int = 3, scale:Float = 2)
	{
		super();

		layers = layerAmount;
		horizontalSpeed = speed;
		verticalSpeed = 0;
		scrollFactor = 0.5;
		this.scale = scale;
	}

	override public function destroy()
	{
		super.destroy();

		for (stars in starsArray)
		{
			if (stars != null)
			{
				stars.destroy();
			}
		}

		for (shootingStar in shootingStars)
		{
			if (shootingStar != null)
			{
				shootingStar.destroy();
			}
		}

		starsArray = null;
		shootingStars = null;
	}

	var spawnBordersThreshold:Float = 40;

	/**
	 * Spawns a shooting star.
	 * @return The `FunkinSprite` instance of the shooting star.
	 */
	public function spawnShootingStar():FunkinSprite
	{
		var shootingStar:FunkinSprite = new FunkinSprite().loadGraphic(Paths.image('shooting-star'));
		shootingStar.moves = true;

		var ssScale:Float = FlxG.random.float(scale / 8, scale / 2);
		shootingStar.scaleSprite(ssScale);

		var launchFromRight:Bool = FlxG.random.bool(50);

		// horizontal position gets randomized
		shootingStar.x = FlxG.random.float(camera.viewX - shootingStar.width - spawnBordersThreshold, camera.viewX + camera.viewWidth + spawnBordersThreshold);

		// vertical position gets randomized
		shootingStar.y = FlxG.random.float(camera.viewY - shootingStar.height - spawnBordersThreshold, camera.viewY + camera.viewHeight / 2);

		if (shootingStar.x > camera.viewX && shootingStar.x + shootingStar.width < camera.viewX + camera.viewWidth)
		{
			shootingStar.y = camera.viewY - shootingStar.height;
		}

		// speed gets randomized
		var minSpeed:Float = Defaults.DEFAULT_SHOOTING_STAR_SPEED * ssScale;
		var maxSpeed:Float = minSpeed * 2;
		var choosenSpeed:Float = FlxG.random.float(minSpeed, maxSpeed);

		// launch angle gets randomized
		var minAngle:Float = Defaults.DEFAULT_SHOOTING_STAR_LAUNCH_ANGLE_MIN;
		var maxAngle:Float = Defaults.DEFAULT_SHOOTING_STAR_LAUNCH_ANGLE_MAX;

		if (launchFromRight)
		{
			minAngle = 90 + MathUtil.distanceBetweenFloats(minAngle, 90);
			maxAngle = 90 + MathUtil.distanceBetweenFloats(maxAngle, 90);
		}

		var choosenAngle:Float = FlxG.random.float(minAngle, maxAngle);
		shootingStar.angle = choosenAngle;

		// velocity gets calculated depending on the angle
		var velocity:FlxPoint = FlxVelocity.velocityFromAngle(choosenAngle, choosenSpeed);
		shootingStar.velocity.x = velocity.x;
		shootingStar.velocity.y = velocity.y;

		// shooting star gets stretched depending on how fast it's going
		var absSpeed:Float = Math.abs(choosenSpeed) * 2;
		var absVelocity:Float = Math.abs(velocity.x);
		var xStretch:Float = absSpeed / absVelocity;
		var yStretch:Float = absVelocity / absSpeed;
		shootingStar.scale.x *= xStretch;
		shootingStar.scale.y *= yStretch;

		shootingStars.push(shootingStar);

		return shootingStar;
	}

	/**
	 * Removes a shooting star from the backdrop.
	 * @param shooringStar The shooting star to remove.
	 */
	public function removeShootingStar(shooringStar:FunkinSprite)
	{
		if (shootingStars == null || shooringStar == null)
		{
			return;
		}

		shootingStars.remove(shooringStar);
		shooringStar.destroy();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (stars in starsArray)
		{
			if (stars != null && stars.exists)
			{
				stars.update(elapsed);
			}
		}

		for (shootingStar in shootingStars)
		{
			if (shootingStar != null && shootingStar.exists)
			{
				shootingStar.update(elapsed);

				if (shootingStar.velocity.x > 0 && shootingStar.x > camera.viewX + camera.viewWidth)
				{
					removeShootingStar(shootingStar);
				}
				else if (shootingStar.velocity.x < 0 && shootingStar.x + shootingStar.width < camera.viewX)
				{
					removeShootingStar(shootingStar);
				}

				if (shootingStar.y > camera.viewY + camera.viewHeight)
				{
					removeShootingStar(shootingStar);
				}
			}
		}

		if (FlxG.random.bool(Defaults.SHOOTING_STAR_SPAWN_CHANCE * 100))
		{
			spawnShootingStar();
		}
	}

	override public function draw()
	{
		super.draw();

		final oldDefaultCameras = @:privateAccess FlxCamera._defaultCameras;
		if (_cameras != null)
		{
			@:privateAccess FlxCamera._defaultCameras = _cameras;
		}

		for (stars in starsArray)
		{
			if (stars != null)
			{
				stars.draw();
			}
		}

		for (shootingStar in shootingStars)
		{
			if (shootingStar != null)
			{
				shootingStar.draw();
			}
		}

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}

	function set_layers(value:Int):Int
	{
		layers = value;

		for (i in 0...layers)
		{
			if (starsArray[i] == null)
			{
				var stars:FlxBackdrop = cast new FlxBackdrop().loadGraphic(Paths.image('stars'), true, 400, 200);
				stars.animation.add(Defaults.DEFAULT_ANIMATION_NAME, [0, 1, 2, 3], 4);
				stars.animation.play(Defaults.DEFAULT_ANIMATION_NAME);
				stars.velocity.x = (horizontalSpeed / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;
				stars.velocity.y = (verticalSpeed / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;
				stars.scale.x = stars.scale.y = scale / (i + 1);
				stars.scrollFactor.x = stars.scrollFactor.y = scrollFactor / (i + 1);

				var opacity:Float = (1 / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0);
				stars.alpha = opacity;

				stars.updateHitbox();

				starsArray[i] = stars;
			}
			else
			{
				var stars:FlxBackdrop = starsArray[i];
				stars.velocity.x = (horizontalSpeed / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;
				stars.velocity.y = (verticalSpeed / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;
				stars.scale.x = stars.scale.y = scale / (i + 1);
				stars.scrollFactor.x = stars.scrollFactor.y = scrollFactor / (i + 1);

				var opacity:Float = (1 / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0);
				stars.alpha = opacity;

				stars.updateHitbox();
			}
		}

		// delete layers that go above the new limit
		for (i in 0...starsArray.length)
		{
			if (starsArray[i] != null)
			{
				if (i > layers - 1)
				{
					starsArray[i].destroy();
					starsArray[i] = null;
				}
			}
		}

		return layers;
	}

	function set_horizontalSpeed(value:Float):Float
	{
		horizontalSpeed = value;

		for (i => stars in starsArray)
		{
			stars.velocity.x = (horizontalSpeed / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;
		}

		return horizontalSpeed;
	}

	function set_verticalSpeed(value:Float):Float
	{
		verticalSpeed = value;

		for (i => stars in starsArray)
		{
			stars.velocity.y = (verticalSpeed / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;
		}

		return verticalSpeed;
	}

	function set_scale(value:Float):Float
	{
		scale = value;

		for (i => stars in starsArray)
		{
			stars.scale.x = stars.scale.y = scale / (i + 1);
			stars.updateHitbox();
		}

		return scale;
	}

	function set_scrollFactor(value:Float):Float
	{
		scrollFactor = value;

		for (i => stars in starsArray)
		{
			stars.scrollFactor.x = stars.scrollFactor.y = scrollFactor / (i + 1);
		}

		return scrollFactor;
	}

	function set_clipRect(rect:FlxRect):FlxRect
	{
		if (rect != null)
		{
			clipRect = rect.round();

			for (stars in starsArray)
			{
				if (stars != null)
				{
					stars.clipRect = clipRect;
				}
			}

			for (shootingStar in shootingStars)
			{
				if (shootingStar != null)
				{
					shootingStar.clipRect = clipRect;
				}
			}
		}
		else
		{
			clipRect = null;

			for (stars in starsArray)
			{
				if (stars != null)
				{
					stars.clipRect = null;
				}
			}

			for (shootingStar in shootingStars)
			{
				if (shootingStar != null)
				{
					shootingStar.clipRect = null;
				}
			}
		}

		return clipRect;
	}
}
