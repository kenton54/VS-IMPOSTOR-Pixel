package funkin.data;

import haxe.io.Path;

import json2object.JsonParser;

class LanguageData
{
	/**
	 * Loads and creates a `Language` object from a json file.
	 *
	 * It uses the json file name as the ID of the language.
	 *
	 * @param filePath The directory where the language json file is located.
	 * @return The loaded `Language`.
	 */
	public static function fromFile(filePath:String):LanguageData
	{
		var fileName:String = new Path(filePath).file;
		var parser = new JsonParser<LanguageData>();
		parser.fromJson(Assets.getText(filePath), fileName);

		return parser.value;
	}

	/**
	 * The unique ID of the language, usually it's a Language Code.
	 */
	public var ID(default, null):String;

	/**
	 * The readable name of the language.
	 */
	public var name(default, null):String;

	/**
	 * Whether this language loads unique assets when the game's active language is this one.
	 */
	@:optional
	public var suffix(default, null):Bool;

	/**
	 * How much to resize fonts associated with this language.
	 */
	@:optional
	public var sizeMult(default, null):Float;

	/**
	 * All the translation IDs this language holds.
	 */
	public var data(default, null):Dynamic;

	public function new(id:String, name:String, data:Dynamic, ?suffix:Bool = false, ?sizeMult:Float = 1)
	{
		this.ID = id;
		this.name = name;
		this.data = data;
		this.suffix = suffix;
		this.sizeMult = sizeMult;
	}

	/**
	 * @param id The translation ID.
	 * @return The translated text from the specified ID. If it didn't find any matches, it returns `null`.
	 */
	public function get(id:String):Null<String>
	{
		return cast thx.Objects.getPath(data, id);
	}

	/**
	 * @param id The translation ID.
	 * @return Whether the specified ID exists inside the language's data or not.
	 */
	public function exists(id:String):Bool
	{
		return get(id) != null;
	}
}
