package funkin.input;

import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import flixel.input.mouse.FlxMouse;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxPoint;

import funkin.system.FunkinMemory;

import openfl.display.BitmapData;

class Pointer
{
	/**
	 * Whether the pointer can recieve input from the mouse or any active touch.
	 */
	public static var enabled(default, set):Bool = true;

	/**
	 * The scale of the cursor.
	 */
	public static var cursorScale(default, set):Int = 3;

	/**
	 * The current cursor mode.
	 *
	 * Only applicable for mouse cursors.
	 */
	public static var cursorMode(default, set):Null<CursorMode> = null;

	/**
	 * Checks if the mouse or the screen just got pressed.
	 */
	public static var justPressed(get, never):Bool;

	/**
	 * Checks if the mouse or the screen is being pressed.
	 */
	public static var pressed(get, never):Bool;

	/**
	 * Checks if the mouse or the screen has stopped being pressed.
	 */
	public static var justReleased(get, never):Bool;

	/**
	 * Checks if the mouse or the screen is not being pressed.
	 */
	public static var released(get, never):Bool;

	/**
	 * Checks if the mouse or a touch moved to any direction.
	 */
	public static var justMoved(get, never):Bool;

	/**
	 * Checks if the mouse or a touch moved leftwards.
	 */
	public static var justMovedLeft(get, never):Bool;

	/**
	 * Checks if the mouse or a touch moved downwards.
	 */
	public static var justMovedDown(get, never):Bool;

	/**
	 * Checks if the mouse or a touch moved rightwards.
	 */
	public static var justMovedUp(get, never):Bool;

	/**
	 * Checks if the mouse or a touch moved upwards.
	 */
	public static var justMovedRight(get, never):Bool;

	/**
	 * The current active pointer.
	 *
	 * On desktop, it returns `FlxMouse`.
	 *
	 * On mobile, it returns the most recent `FlxTouch`. If none found, returns `null`.
	 */
	public static var pointer(get, never):#if mobile Null<FlxTouch> #else FlxMouse #end;

	/**
	 * Shows the pointer's cursor.
	 */
	public static function show()
	{
		#if !mobile
		FlxG.mouse.visible = true;
		cursorMode = Normal;
		#else
		hide();
		#end
	}

	/**
	 * Hides the pointer's cursor.
	 */
	public static function hide()
	{
		FlxG.mouse.visible = false;
		cursorMode = null;
	}

	/**
	 * Checks if the pointer is overlapping a `FlxObject` or `FlxGroup`.
	 *
	 * @param object        The object or group to check for overlap.
	 * @param camera        Helps determine the world position. If none is set, `FlxG.camera` will be used instead.
	 * @param updateCursor  Whether to update `cursorMode` or not.
	 * @return Whether the pointer overlaps the object or group or not.
	 */
	public static function overlaps(object:flixel.FlxBasic, ?camera:FlxCamera, ?updateCursor:Bool = false):Bool
	{
		if (pointer == null || object == null)
		{
			return false;
		}

		var result:Bool = pointer.overlaps(object, camera);

		if (updateCursor && Std.isOfType(object, FlxObject))
		{
			var sprite:FlxObject = cast object;
			if (sprite.cursorMode != null && result)
			{
				Pointer.cursorMode = sprite.cursorMode;
			}
			else
			{
				Pointer.cursorMode = Normal;
			}
		}

		return result;
	}

	/**
	 * Checks if the pointer is overlapping a `FlxObject`.
	 *
	 * Uses a more accurate approach than the `overlaps` function.
	 *
	 * @param object        The object to check for overlap.
	 * @param camera        Helps determine the world position. If none is set, `FlxG.camera` will be used instead.
	 * @param updateCursor  Whether to update `cursorMode` or not.
	 * @return Whether the pointer overlaps the object or not.
	 */
	public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera, ?updateCursor:Bool = false):Bool
	{
		if (pointer == null || object == null)
		{
			return false;
		}

		if (camera == null)
		{
			camera = object.camera;
		}

		var result:Bool = object.overlapsPoint(pointer.getWorldPosition(camera), true, camera);

		if (updateCursor && result)
		{
			if (object.cursorMode != null)
			{
				Pointer.cursorMode = object.cursorMode;
			}
			else
			{
				Pointer.cursorMode = Normal;
			}
		}

		return result;
	}

	/**
	 * Checks if the pointer is overlapping a `FlxObject` or `FlxGroup` and if the pointer was stopped being pressed.
	 *
	 * This is a shortcut of doing:
	 *
	 * ```haxe
	 * if (Pointer.overlaps(object, camera) && Pointer.justReleased)
	 * {
	 * 	// code here
	 * }
	 * ```
	 *
	 * Pretty neat, huh?
	 *
	 * @param object 					The object or group to check for overlap.
	 * @param camera 					Helps determine the world position. If none is set, `FlxG.camera` will be used instead.
	 * @param preciseOverlap 	Whether to use the precise overlap calculation rather than the simple one.
	 * @return Whether the pointer overlaps the object or group and was stopped being pressed.
	 */
	public static function pressAction(object:flixel.FlxBasic, ?camera:FlxCamera, ?preciseOverlap:Bool = false):Bool
	{
		if (pointer == null || object == null)
		{
			return false;
		}

		var overlap:Bool = (preciseOverlap && Std.isOfType(object, FlxObject)) ? overlapsComplex(cast object, camera) : overlaps(object, camera);
		return overlap && justReleased;
	}

	/**
	 * Fetches the pointer's position relative to any given camera.
	 *
	 * @param camera  The camera to calculate the pointer's position.
	 *                If none is set, `FlxG.camera` will be used instead.
	 * @param point   An existing point to store the results, if unspecified, one is created.
	 * @return The pointer's position relative to the camera.
	 */
	public static function getWorldPosition(?camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (pointer == null)
		{
			return null;
		}

		return pointer.getWorldPosition(camera, point);
	}

	/**
	 * The position relative to the game's position in the window, where `(0, 0)` is the
	 * top-left edge of the game and `(FlxG.width, FlxG.height)` is the bottom-right.
	 *
	 * @param point An existing point to store the results, if unspecified, one is created.
	 * @return The pointer's position relative to the game's position in the stage.
	 */
	public static function getGamePosition(?point:FlxPoint):FlxPoint
	{
		if (pointer == null)
		{
			return null;
		}

		return pointer.getGamePosition(point);
	}

	/**
	 * Fetches the world position relative to the main camera's `scroll` position, where
	 * `(cam.viewMarginLeft, cam.viewMarginTop)` is the top-left of the camera and
	 * `(cam.viewMarginRight, cam.viewMarginBottom)` is the bottom right.
	 *
	 * @param camera  The camera to calculate the pointer's position.
	 *                If none is set, `FlxG.camera` will be used instead.
	 * @param point   An existing point to store the results, if unspecified, one is created.
	 * @return The pointer's position relative to the camera.
	 */
	public static function getViewPosition(?camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (pointer == null)
		{
			return null;
		}

		return pointer.getViewPosition(camera, point);
	}

	/**
	 * @param point An existing point to store the results, if unspecified, one is created.
	 * @return The pointer's position.
	 */
	public static function getPosition(?point:FlxPoint):FlxPoint
	{
		if (pointer == null)
		{
			return null;
		}

		return pointer.getPosition(point);
	}

	static final cursor_default:CursorGraphic = {
		graphic: 'cursor/normal',
		offsetX: 0,
		offsetY: 0
	};

	static final cursor_hover:CursorGraphic = {
		graphic: 'cursor/hover',
		offsetX: -3,
		offsetY: 0
	};

	static final cursor_text:CursorGraphic = {
		graphic: 'cursor/text',
		offsetX: -3,
		offsetY: -7
	};

	static final cursor_crosshair:CursorGraphic = {
		graphic: 'cursor/crosshair',
		offsetX: -6,
		offsetY: -6
	};

	static final cursor_grab:CursorGraphic = {
		graphic: 'cursor/grab',
		offsetX: -4,
		offsetY: 0
	};

	static final cursor_hold:CursorGraphic = {
		graphic: 'cursor/hold',
		offsetX: -3,
		offsetY: 2
	};

	static function setCursorGraphic(?mode:CursorMode)
	{
		if (mode == null)
		{
			FlxG.mouse.unload();
			return;
		}

		var graphic:FlxGraphic = null;
		var offsetX:Int = 0;
		var offsetY:Int = 0;

		switch (mode)
		{
			case Normal:
				graphic = FunkinMemory.getGraphic(Paths.impostor('images/' + cursor_default.graphic + '.png'));
				offsetX = cursor_default.offsetX;
				offsetY = cursor_default.offsetY;

			case Hover:
				graphic = FunkinMemory.getGraphic(Paths.impostor('images/' + cursor_hover.graphic + '.png'));
				offsetX = cursor_hover.offsetX;
				offsetY = cursor_hover.offsetY;

			case Text:
				graphic = FunkinMemory.getGraphic(Paths.impostor('images/' + cursor_text.graphic + '.png'));
				offsetX = cursor_text.offsetX;
				offsetY = cursor_text.offsetY;

			case Crosshair:
				graphic = FunkinMemory.getGraphic(Paths.impostor('images/' + cursor_crosshair.graphic + '.png'));
				offsetX = cursor_crosshair.offsetX;
				offsetY = cursor_crosshair.offsetY;

			case Grab:
				graphic = FunkinMemory.getGraphic(Paths.impostor('images/' + cursor_grab.graphic + '.png'));
				offsetX = cursor_grab.offsetX;
				offsetY = cursor_grab.offsetY;

			case Hold:
				graphic = FunkinMemory.getGraphic(Paths.impostor('images/' + cursor_hold.graphic + '.png'));
				offsetX = cursor_hold.offsetX;
				offsetY = cursor_hold.offsetY;
		}

		if (graphic != null && graphic.bitmap != null)
		{
			applyCursor(graphic.bitmap, offsetX, offsetY);
		}
		else
		{
			setCursorGraphic();
		}
	}

	static function applyCursor(graphic:BitmapData, offsetX:Int, offsetY:Int)
	{
		FlxG.mouse.load(graphic, cursorScale, offsetX * cursorScale, offsetY * cursorScale);
	}

	static function set_cursorMode(value:CursorMode):CursorMode
	{
		if (value != cursorMode)
		{
			cursorMode = value;
			setCursorGraphic(cursorMode);
		}

		return cursorMode;
	}

	static function set_cursorScale(value:Int):Int
	{
		cursorScale = value.clamp(1, 10);

		if (FlxG.mouse.cursor != null)
		{
			FlxG.mouse.cursor.scaleX = FlxG.mouse.cursor.scaleY = cursorScale;
		}

		return cursorScale;
	}

	static function set_enabled(value:Bool):Bool
	{
		enabled = value;
		hide();

		FlxG.mouse.enabled = value;

		return value;
	}

	#if mobile
	static function get_pointer():Null<FlxTouch>
	{
		for (touch in FlxG.touches.list)
		{
			if (touch != null)
			{
				return touch;
			}
		}

		return FlxG.touches.getFirst();
	}
	#else
	static function get_pointer():FlxMouse
	{
		return FlxG.mouse;
	}
	#end

	static function get_justPressed():Bool
	{
		return pointer != null && pointer.justPressed;
	}

	static function get_pressed():Bool
	{
		return pointer != null && pointer.pressed;
	}

	static function get_justReleased():Bool
	{
		return pointer != null && pointer.justReleased;
	}

	static function get_released():Bool
	{
		return pointer != null && pointer.released;
	}

	static function get_justMoved():Bool
	{
		return pointer != null && pointer.justMoved;
	}

	static function get_justMovedLeft():Bool
	{
		return pointer != null && pointer.justMovedLeft;
	}

	static function get_justMovedDown():Bool
	{
		return pointer != null && pointer.justMovedDown;
	}

	static function get_justMovedUp():Bool
	{
		return pointer != null && pointer.justMovedUp;
	}

	static function get_justMovedRight():Bool
	{
		return pointer != null && pointer.justMovedRight;
	}
}

enum CursorMode
{
	Normal;
	Hover;
	Text;
	Crosshair;
	Grab;
	Hold;
}

typedef CursorGraphic =
{
	/**
	 * The graphic to load onto the cursor.
	 */
	var graphic:String;

	/**
	 * Horizontal offset.
	 */
	var offsetX:Int;

	/**
	 * Vertical offset.
	 */
	var offsetY:Int;
}
