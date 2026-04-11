package funkin.utils.macro;

#if macro
/**
 * Provides a macro to include a XML build file into a Class metadata.
 */
class IncludeMacro
{
	/**
	 * Adds an XML `<include>` element to the class's metadata.
	 * @param file The path that leads to the XML that you wish to include.
	 * @return An array of fields that are processed during the build.
	 */
	public static macro function xml(?file:String = 'Build.xml'):Array<haxe.macro.Expr.Field>
	{
		final fields:Array<haxe.macro.Expr.Field> = haxe.macro.Context.getBuildFields();
		final clss:haxe.macro.Type.ClassType = haxe.macro.Context.getLocalClass().get();
		final position:haxe.macro.Expr.Position = haxe.macro.Context.currentPos();

		final sourcePath:String = haxe.io.Path.directory(haxe.macro.Context.getPosInfos(position).file);
		final absolutePath:String = haxe.io.Path.removeTrailingSlashes(sys.FileSystem.absolutePath(sourcePath));
		final file2Include:String = haxe.io.Path.join([absolutePath, file.length > 0 ? file : 'Build.xml']);

		if (!sys.FileSystem.exists(file2Include))
		{
			haxe.macro.Context.error('The specified file "$file2Include" could not be found.', position);
		}

		final includeElement:Xml = Xml.createElement('include');
		includeElement.set('name', file2Include);

		clss.meta.add(':buildXml', [
			{
				expr: EConst(CString(haxe.xml.Printer.print(includeElement, true))),
				pos: position
			}
		], position);

		return fields;
	}
}
#end
