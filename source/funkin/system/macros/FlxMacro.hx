package funkin.system.macros;

#if macro
class FlxMacro
{
	/**
	 * Adds more variables to the `FlxObject` class.
	 *
	 * @return The array of fields that the class contains.
	 */
	public static macro function buildFlxObject():Array<haxe.macro.Expr.Field>
	{
		var position:haxe.macro.Expr.Position = haxe.macro.Context.currentPos();
		var clss:haxe.macro.Type.ClassType = haxe.macro.Context.getLocalClass().get();
		var fields:Array<haxe.macro.Expr.Field> = haxe.macro.Context.getBuildFields();

		var hasCursorMode:Bool = false;

		for (field in fields)
		{
			if (field.name == 'cursorMode')
			{
				hasCursorMode = true;
			}
		}

		if (!hasCursorMode)
		{
			fields.push({
				name: 'cursorMode',
				doc: 'The `CursorMode` to set to the pointer cursor when it hovers this object.',
				access: [haxe.macro.Expr.Access.APublic],
				kind: haxe.macro.Expr.FieldType.FVar(macro :Null<funkin.input.Pointer.CursorMode>, macro $v{null}),
				pos: position
			});
		}

		return fields;
	}

	/**
	 * Adds more variables to the `FlxSprite` class.
	 *
	 * @return The array of fields that the class contains.
	 */
	public static macro function buildFlxSprite():Array<haxe.macro.Expr.Field>
	{
		var position:haxe.macro.Expr.Position = haxe.macro.Context.currentPos();
		var clss:haxe.macro.Type.ClassType = haxe.macro.Context.getLocalClass().get();
		var fields:Array<haxe.macro.Expr.Field> = haxe.macro.Context.getBuildFields();

		var fields2Add = [
			{
				name: 'parentX',
				doc: 'The horizontal position of this sprite relative to its parent group.',
				kind: haxe.macro.Expr.FieldType.FVar(macro :Float, macro $v{0}),
				access: [haxe.macro.Expr.Access.APublic]
			},
			{
				name: 'parentY',
				doc: 'The vertical position of this sprite relative to its parent group.',
				kind: haxe.macro.Expr.FieldType.FVar(macro :Float, macro $v{0}),
				access: [haxe.macro.Expr.Access.APublic]
			},
			{
				name: 'parentAlpha',
				doc: 'The opacity of this sprite relative to its parent group.',
				kind: haxe.macro.Expr.FieldType.FVar(macro :Float, macro $v{1}),
				access: [haxe.macro.Expr.Access.APublic]
			},
			{
				name: 'parentAngle',
				doc: 'The angle of this sprite relative to its parent group.',
				kind: haxe.macro.Expr.FieldType.FVar(macro :Float, macro $v{0}),
				access: [haxe.macro.Expr.Access.APublic]
			},
			{
				name: 'parentScale',
				doc: 'The scale of this sprite relative to its parent group.',
				kind: haxe.macro.Expr.FieldType.FVar(macro :flixel.math.FlxPoint, macro new flixel.math.FlxPoint(1, 1)),
				access: [haxe.macro.Expr.Access.APublic]
			},
			{
				name: 'parentVisible',
				doc: 'The visibility of this sprite relative to its parent group.',
				kind: haxe.macro.Expr.FieldType.FVar(macro :Bool, macro $v{true}),
				access: [haxe.macro.Expr.Access.APublic]
			}
		];

		var alreadyAddedFields:Array<String> = [];

		for (field in fields)
		{
			for (fld2Add in fields2Add)
			{
				if (fld2Add.name == field.name)
				{
					alreadyAddedFields.push(fld2Add.name);
				}
			}
		}

		for (field in fields2Add)
		{
			if (alreadyAddedFields.contains(field.name))
			{
				continue;
			}

			fields.push({
				name: field.name,
				doc: field.doc,
				access: field.access,
				kind: field.kind,
				pos: position
			});
		}

		return fields;
	}
}
#end
