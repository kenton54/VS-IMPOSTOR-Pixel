package funkin.input;

import flixel.FlxObject;
import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

class FunkinButton extends FunkinSprite implements IFlxInput
{
	/**
	 * Dispatches when the button is pressed.
	 */
	public var onPress:FlxSignal = new FlxSignal();

	/**
	 * Dispatches when the button has stopped being pressed.
	 */
	public var onRelease:FlxSignal = new FlxSignal();

	/**
	 * Dispatches when the button stops being hovered while pressed.
	 */
	public var onUnhover:FlxSignal = new FlxSignal();

	/**
	 * Whether the button was pressed.
	 */
	public var justPressed(get, never):Bool;

	/**
	 * Whether the button is being held.
	 */
	public var pressed(get, never):Bool;

	/**
	 * Whether the button stopped being pressed.
	 */
	public var justReleased(get, never):Bool;

	/**
	 * Whether the button is not being held.
	 */
	public var released(get, never):Bool;

	/**
	 * Whether the button's interaction logic can occur.
	 */
	public var enabled:Bool = true;

	/**
	 * Whether the button can be released when the pointer stops hovering over the button but it's still being pressed.
	 */
	public var allowSwipingAway:Bool = true;

	/**
	 * An array of deadzones to stop the button from being interacted with if a pointer happens to overlap any of them.
	 */
	public var deadzones:Array<FlxObject> = [];

	/**
	 * A radius for circular buttons.
	 *
	 * If the radius is bigger than `0` then the overlap functions will check if any pointer is within the radius.
	 */
	public var radius:Float = 0;

	/**
	 * The `FlxTouch` that's currently pressing the button.
	 */
	public var currentTouch(get, never):Null<FlxTouch>;

	var input:FlxInput<Int>;

	var touchID:Int = -1;

	var _isPressed:Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		solid = false;
		immovable = true;
		scrollFactor.set();

		input = new FlxInput(0);
	}

	override function destroy()
	{
		super.destroy();

		deadzones = FlxDestroyUtil.destroyArray(deadzones);
		input = null;

		FlxDestroyUtil.destroy(onPress);
		FlxDestroyUtil.destroy(onRelease);
		FlxDestroyUtil.destroy(onUnhover);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (visible && enabled)
		{
			final overlapping:Bool = FlxG.onMobile ? checkTouchOverlap() : checkMouseOverlap();
			final pointerReleased:Bool = (currentTouch != null && currentTouch.justReleased) || FlxG.mouse.justReleased;

			if ((pointerReleased || (!allowSwipingAway && pointerReleased)) && overlapping)
			{
				releaseHandler();
			}

			if (pointerReleased || !overlapping)
			{
				if (allowSwipingAway || (!allowSwipingAway && pointerReleased))
				{
					unhoverHandler();
				}
			}
		}

		input.update();
	}

	function checkMouseOverlap():Bool
	{
		for (camera in cameras)
		{
			final worldPoint:FlxPoint = FlxG.mouse.getWorldPosition(camera, _point);

			for (deadzone in deadzones)
			{
				if (deadzone != null && deadzone.overlapsPoint(worldPoint, true, camera))
				{
					return false;
				}
			}

			if (radius > 0)
			{
				if (circleOverlapsPoint(worldPoint, camera))
				{
					updateMouseStatus(FlxG.mouse);
					return true;
				}
			}
			else
			{
				if (overlapsPoint(worldPoint, true, camera))
				{
					updateMouseStatus(FlxG.mouse);
					return true;
				}
			}
		}

		return false;
	}

	function checkTouchOverlap():Bool
	{
		for (camera in cameras)
		{
			for (touch in FlxG.touches.list)
			{
				final worldPoint:FlxPoint = touch.getWorldPosition(camera, _point);

				for (deadzone in deadzones)
				{
					if (deadzone != null && deadzone.overlapsPoint(worldPoint, true, camera))
					{
						return false;
					}
				}

				function updateTouch()
				{
					touchID = FlxG.touches.list.indexOf(touch);
					updateInputStatus(touch);
				}

				if (radius > 0)
				{
					if (circleOverlapsPoint(worldPoint, camera))
					{
						updateTouch();
						return true;
					}
				}
				else
				{
					if (overlapsPoint(worldPoint, true, camera))
					{
						updateTouch();
						return true;
					}
				}
			}
		}

		return false;
	}

	function circleOverlapsPoint(point:FlxPoint, ?camera:FlxCamera):Bool
	{
		if (camera == null)
		{
			camera = FlxG.camera;
		}

		final xPos:Float = point.x - camera.scroll.x;
		final yPos:Float = point.y - camera.scroll.y;
		getScreenPosition(_point, camera);
		point.putWeak();

		final distanceX:Float = xPos - (_point.x + (width / 2));
		final distanceY:Float = yPos - (_point.y + (height / 2));
		final distance:Float = Math.sqrt((distanceX * distanceY) + (distanceX * distanceY));

		return distance <= radius;
	}

	function updateInputStatus(inpt:IFlxInput)
	{
		if (inpt.justPressed)
		{
			pressHandler();
		}
		else if (!_isPressed)
		{
			if (inpt.pressed)
			{
				pressHandler();
			}
		}
	}

	/**
	 * The exact same as `updateInputStatus`, but for `FlxMouse`.
	 *
	 * Thank you HaxeFlixel :sob:.
	 */
	function updateMouseStatus(mouse:flixel.input.mouse.FlxMouse)
	{
		if (mouse.justPressed)
		{
			pressHandler();
		}
		else if (!_isPressed)
		{
			if (mouse.pressed)
			{
				pressHandler();
			}
		}
	}

	function pressHandler()
	{
		_isPressed = true;

		input.press();

		onPress.dispatch();
	}

	function releaseHandler()
	{
		_isPressed = false;

		input.release();
		touchID = -1;

		onRelease.dispatch();
	}

	function unhoverHandler()
	{
		_isPressed = false;

		input.release();
		touchID = -1;

		onUnhover.dispatch();
	}

	function get_justPressed():Bool
	{
		return input.justPressed;
	}

	function get_pressed():Bool
	{
		return input.pressed;
	}

	function get_justReleased():Bool
	{
		return input.justReleased;
	}

	function get_released():Bool
	{
		return input.released;
	}

	function get_currentTouch():Null<FlxTouch>
	{
		return FlxG.touches.getByID(touchID);
	}
}
