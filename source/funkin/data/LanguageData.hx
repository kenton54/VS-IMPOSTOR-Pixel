package funkin.data;

import haxe.Json;
import haxe.io.Path;

typedef LanguageFile =
{
	/**
	 * The readable name of the language.
	 */
	var name:String;

	/**
	 * All the translation IDs this language holds.
	 */
	var data:Dynamic;

	/**
	 * Whether this language loads unique assets when the game's active language is this one.
	 */
	var ?suffix:Bool;

	/**
	 * How much to resize fonts associated with this language.
	 */
	var ?sizeMult:Float;
}

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
		return fromData(fileName, Json.parse(Assets.getText(filePath)));
	}

	/**
	 * Loads and creates a `Language` object from a given data structure.
	 *
	 * @param id        The unique ID of the language.
	 * @param langData  The language's data.
	 * @return The loaded `Language`.
	 */
	public static function fromData(id:String, langData:LanguageFile):LanguageData
	{
		return new LanguageData(id, langData.name, langData.data, langData.suffix, langData.sizeMult);
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
	public var suffix(default, null):Bool;

	/**
	 * How much to resize fonts associated with this language.
	 */
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
