package funkin.graphics;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxSort;

typedef FunkinSpriteGroup = FunkinGroup<FlxSprite>;

/**
 * `FlxSpriteGroup` but better. Works like `DisplayObjectContainer` or `FlxNestedSprite`.
 */
@:access(flixel.FlxSprite)
class FunkinGroup<T:FlxSprite> extends FlxSprite
{
	/**
	 * Where all the sprites are stored.
	 */
	public var children(default, null):Array<T>;

	/**
	 * The maximum capacity of this group.
	 *
	 * If the maximum capacity is `0` (the default), the group can grow indefinitively.
	 */
	public var maxSize(default, set):Int;

	/**
	 * The amount of sprites the group contains.
	 */
	public var length(get, never):Int;

	public var preciseScale:Bool = true;

	public var preciseAngle:Bool = true;

	var _recycleCycle:Int = 0;

	/**
	 * @param x         The X position of the group.
	 * @param y         The Y position of the group.
	 * @param maxSize   The maximum amount of children allowed in this group.
	 */
	public function new(x:Float = 0, y:Float = 0, maxSize:Int = 0)
	{
		super(x, y);

		this.children = [];

		this.maxSize = maxSize;
	}

	override function destroy()
	{
		super.destroy();

		flixel.util.FlxDestroyUtil.destroyArray(children);
		children = null;
	}

	override function clone():FunkinGroup<T>
	{
		var newGroup:FunkinGroup<T> = new FunkinGroup<T>(x, y, maxSize);

		for (child in children)
		{
			if (child != null)
			{
				newGroup.add(cast child.clone());
			}
		}

		return newGroup;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (child in children)
		{
			if (child != null && child.exists && child.active)
			{
				updateChild(cast child);
				child.update(elapsed);
			}
		}
	}

	override function draw()
	{
		for (child in children)
		{
			if (child != null && child.exists && child.visible)
			{
				child.draw();
			}
		}
	}

	function updateChild(child:T)
	{
		child.alpha = this.alpha * child.parentAlpha;
		child.angle = this.angle + child.parentAngle;
		child.visible = this.visible && child.parentVisible;
		child.scale.x = this.scale.x * child.parentScale.x;
		child.scale.y = this.scale.y * child.parentScale.y;

		var displace:FlxPoint = FlxPoint.get(child.parentX, child.parentY);

		var dx:Float = origin.x - child.width / 2;
		var dy:Float = origin.y - child.height / 2;

		if (preciseScale && !preciseAngle)
		{
			dx += scale.x + (child.parentX - origin.x + child.width / 2);
			dy += scale.y + (child.parentY - origin.y + child.height / 2);
		}
		else if (!preciseScale && preciseAngle)
		{
			var cos:Float = MathUtil.cos(this.angle);
			var sin:Float = MathUtil.sin(this.angle);

			dx += cos * (child.parentX - origin.x + child.width / 2);
			dx -= sin * (child.parentY - origin.y + child.height / 2);

			dy += cos * (child.parentY - origin.y + child.height / 2);
			dy += sin * (child.parentX - origin.x + child.width / 2);
		}
		else if (preciseScale && preciseAngle)
		{
			var cos:Float = MathUtil.cos(this.angle);
			var sin:Float = MathUtil.sin(this.angle);

			dx += scale.x * cos * (child.parentX - origin.x + child.width / 2);
			dx -= scale.y * sin * (child.parentY - origin.y + child.height / 2);

			dy += scale.y * cos * (child.parentY - origin.y + child.height / 2);
			dy += scale.x * sin * (child.parentX - origin.x + child.width / 2);
		}

		if (preciseScale || preciseAngle)
		{
			displace.set(dx, dy);
		}

		child.x = this.x + displace.x;
		child.y = this.y + displace.y;

		if (child.cameras != this.cameras)
		{
			child.cameras = this.cameras;
		}
	}

	/**
	 * Adds a `FlxSprite` subclass to the group.
	 *
	 * @param sprite The sprite to add to the group.
	 * @return The same sprite.
	 */
	public function add(sprite:T):Null<T>
	{
		if (sprite == null)
		{
			FlxG.log.warn('Cannot add a "null" object to a FunkinGroup!');
			return null;
		}

		if (children.indexOf(sprite) >= 0)
		{
			return sprite;
		}

		sprite.parentX = sprite.x;
		sprite.parentY = sprite.y;
		sprite.parentAlpha = sprite.alpha;
		sprite.parentAngle = sprite.angle;
		sprite.parentVisible = sprite.visible;
		sprite.parentScale.x = sprite.scale.x;
		sprite.parentScale.y = sprite.scale.y;

		final index:Int = getFirstNull();

		if (index >= 0)
		{
			children[index] = sprite;
			return sprite;
		}

		if (maxSize > 0 && length >= maxSize)
		{
			return sprite;
		}

		children.push(sprite);
		return sprite;
	}

	/**
	 * Adds a `FlxSprite` subclass to the group at the specified position.
	 *
	 * @param pos     The position in the group where you want to insert the object.
	 * @param sprite  The sprite to add to the group.
	 * @return The same sprite.
	 */
	public function insert(pos:Int, sprite:T):Null<T>
	{
		if (sprite == null)
		{
			FlxG.log.warn('Cannot add a "null" object to a FunkinGroup!');
			return null;
		}

		if (children.indexOf(sprite) >= 0)
		{
			return sprite;
		}

		if (maxSize > 0 && length >= maxSize)
		{
			return sprite;
		}

		sprite.parentX = sprite.x;
		sprite.parentY = sprite.y;
		sprite.parentAlpha = sprite.alpha;
		sprite.parentAngle = sprite.angle;
		sprite.parentVisible = sprite.visible;
		sprite.parentScale.x = sprite.scale.x;
		sprite.parentScale.y = sprite.scale.y;

		children.insert(pos, sprite);
		return sprite;
	}

	/**
	 * Creates a new child and adds it to the group immediately, if they're any slots available inside the group of course.
	 * @return The created sprite.
	 */
	public function make():T
	{
		var newChild:T = cast new FlxSprite();

		if (maxSize > 0 && length < maxSize)
		{
			add(newChild);
		}

		return newChild;
	}

	/**
	 * Retreives a previously killed sprite.
	 *
	 * Avoids reallocating a new instance of an already-used sprite.
	 *
	 * It behaves differently depending on whether `maxSize` equals `0` or is bigger than `0`.
	 *
	 * @param objectClass   The class you want to recycle.
	 * @param objectFactory Optional function to create a new sprite if there aren't any dead children to recycle.
	 * @param force         Force the object to be a class of `objectClass` and not a super class of `objectClass`.
	 * @param revive        Whether the recycled sprite should be revived.
	 * @return The recycled sprite.
	 */
	public function recycle(?objectClass:Class<T>, ?objectFactory:Void -> T, force:Bool = false, revive:Bool = true):Null<T>
	{
		inline function createObject():Null<T>
		{
			if (objectFactory != null)
			{
				return add(objectFactory());
			}

			if (objectClass != null)
			{
				return add(Type.createInstance(objectClass, []));
			}

			return null;
		}

		if (maxSize > 0)
		{
			if (length < maxSize)
			{
				return createObject();
			}

			final sprite:T = children[_recycleCycle++];

			if (_recycleCycle >= maxSize)
			{
				_recycleCycle = 0;
			}

			if (revive)
			{
				sprite.revive();
			}

			return cast sprite;
		}

		final sprite:T = getFirstAvailable(objectClass, force);

		if (sprite != null)
		{
			if (revive)
			{
				sprite.revive();
			}

			return cast sprite;
		}

		return createObject();
	}

	/**
	 * Removes a sprite from the group.
	 *
	 * @param sprite  The `FlxSprite` you want to remove.
	 * @param splice  Whether to cut it entirely from the group or not.
	 * @return The removed sprite.
	 */
	public function remove(sprite:T, splice:Bool = false):Null<T>
	{
		final index:Int = children.indexOf(sprite);

		if (index < 0)
		{
			return null;
		}

		sprite.parentX = 0;
		sprite.parentY = 0;
		sprite.parentAlpha = 1;
		sprite.parentAngle = 0;
		sprite.parentVisible = true;
		sprite.parentScale.set(1, 1);

		if (splice)
		{
			children.splice(index, 1);
		}
		else
		{
			children[index] = null;
		}

		return sprite;
	}

	/**
	 * Sorts the children of this group according to a particular value and order.
	 *
	 * @param func  		The sorting function to use.
	 * @param setGroup 	Whether the sorting should affect the children order. If `false`, returns a
	 * 									sorted copy of the group's children, but doesn't sort the group's children.
	 * @param order 		The sort order.
	 * @return The sorted children.
	 */
	public inline function sort(func:(Int, T, T) -> Int, setGroup:Bool = true, order:Int = flixel.util.FlxSort.ASCENDING):Array<T>
	{
		if (setGroup)
		{
			children.sort(func.bind(order));
			return children;
		}
		else
		{
			var childrenCopy:Array<T> = children.copy();
			childrenCopy.sort(func.bind(order));
			return childrenCopy;
		}
	}

	/**
	 * Searches for the first child that satifies the function.
	 *
	 * @param func The function that all children must pass.
	 * @return The first sprite that satisfied the function.
	 */
	public function getFirst(func:T -> Bool):Null<T>
	{
		for (child in children)
		{
			if (child != null && func(child))
			{
				return child;
			}
		}

		return null;
	}

	/**
	 * Tests whether any child satisfies the function.
	 *
	 * @param func The function to test the children with.
	 * @return Whether any child satisfied the function.
	 */
	public function any(func:T -> Bool):Bool
	{
		for (child in children)
		{
			if (child != null && func(child))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * Tests whether every child satisfies the function.
	 *
	 * @param func The function to test the children with.
	 * @return Whether every child satisfied the function.
	 */
	public function every(func:T -> Bool):Bool
	{
		for (child in children)
		{
			if (child != null && !func(child))
			{
				return false;
			}
		}

		return true;
	}

	/**
	 * Returns the first sprite that's not alive (`exists == false`) inside the group.
	 *
	 * @param objectClass An optional parameter that lets you narrow the results to instances of this particular class.
	 * @param force       Force the object to be a class of `objectClass` and not a super class of `objectClass`.
	 * @return The first available killed sprite.
	 */
	public function getFirstAvailable(?objectClass:Class<T>, force:Bool = false):Null<T>
	{
		for (child in children)
		{
			if (child != null && !child.exists && (objectClass == null || Std.isOfType(child, objectClass)))
			{
				if (force && Type.getClassName(Type.getClass(child)) != Type.getClassName(objectClass))
				{
					continue;
				}

				return child;
			}
		}

		return null;
	}

	/**
	 * @return The index of the first `null` entry inside the group.
	 */
	public function getFirstNull():Int
	{
		return children.indexOf(null);
	}

	/**
	 * Calls `kill()` on every child.
	 */
	public function killChildren()
	{
		for (child in children)
		{
			if (child != null && child.exists)
			{
				child.kill();
			}
		}
	}

	override function kill()
	{
		killChildren();
		super.kill();
	}

	/**
	 * Calls `revive()` on every child.
	 */
	public function reviveChildren()
	{
		for (child in children)
		{
			if (child != null && !child.exists)
			{
				child.revive();
			}
		}
	}

	override function revive()
	{
		reviveChildren();
		super.revive();
	}

	/**
	 * Applies a function to all children.
	 *
	 * @param func      The function to apply to each child.
	 * @param recursive Whether to apply the function to children of subgroups as well.
	 */
	public function forEach(func:T -> Void, recursive:Bool = false)
	{
		for (child in children)
		{
			if (child != null)
			{
				if (recursive)
				{
					final group:FlxGroup = @:privateAccess FlxGroup.resolveGroup(child);
					if (group != null)
					{
						group.forEach(cast func, recursive);
					}
				}

				func(child);
			}
		}
	}

	override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):FunkinGroup<T>
	{
		return this;
	}

	override function loadRotatedGraphic(graphic:FlxGraphicAsset, rotations:Int = 16, frame:Int = -1, antiAliasing:Bool = false, autoBuffer:Bool = false, ?key:String):FunkinGroup<T>
	{
		return this;
	}

	override function get_width():Float
	{
		if (length < 1)
		{
			return 0;
		}

		var leftMostSprite:T = sort((o:Int, a:T, b:T) ->
		{
			if (a == null || b == null)
			{
				return 0;
			}
			return FlxSort.byValues(o, x + a.parentX, x + b.parentX);
		}, false)[0];

		var rightMostSprite:T = sort((o:Int, a:T, b:T) ->
		{
			if (a == null || b == null)
			{
				return 0;
			}
			return FlxSort.byValues(o, (x + a.parentX) + a.width, (x + b.parentX) + b.width);
		}, false, FlxSort.DESCENDING)[0];

		return Math.abs(((x + rightMostSprite.parentX) + rightMostSprite.width) - (x + leftMostSprite.parentX));
	}

	override function set_width(value:Float):Float
	{
		return value;
	}

	override function get_height():Float
	{
		if (length < 1)
		{
			return 0;
		}

		var downwardMostSprite:T = sort((o:Int, a:T, b:T) ->
		{
			if (a == null || b == null)
			{
				return 0;
			}
			return FlxSort.byValues(o, (y + a.parentY) + a.height, (y + b.parentY) + b.height);
		}, false, FlxSort.DESCENDING)[0];

		var upwardMostSprite:T = sort((o:Int, a:T, b:T) ->
		{
			if (a == null || b == null)
			{
				return 0;
			}
			return FlxSort.byValues(o, y + a.parentY, y + b.parentY);
		}, false)[0];

		return Math.abs(((y + downwardMostSprite.parentY) + downwardMostSprite.height) - (y + upwardMostSprite.parentY));
	}

	override function set_height(value:Float):Float
	{
		return value;
	}

	function set_maxSize(size:Int):Int
	{
		maxSize = size.clamp(0);

		if (_recycleCycle >= maxSize)
		{
			_recycleCycle = 0;
		}

		if (maxSize > 0)
		{
			for (i in 0...length)
			{
				if (i > maxSize)
				{
					children.remove(children[i]);
				}
			}
		}

		return maxSize;
	}

	function get_length():Int
	{
		return children.length;
	}
}
