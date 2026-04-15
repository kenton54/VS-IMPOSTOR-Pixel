package funkin.system.macro;

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
}
#end
