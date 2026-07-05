package funkin.data.stage.format;

import haxe.io.Path;

import json2object.JsonParser;
import json2object.JsonWriter;

class ImpostorPixelStage extends StageData
{
	/**
	 * Creates a VS IMPOSTOR Pixel stage from stage data.
	 *
	 * @param data The stage data.
	 * @return The VS IMPOSTOR Pixel stage.
	 */
	public static function fromData(data:StageData):ImpostorPixelStage
	{
		return cast data;
	}

	/**
	 * Creates stage data from a VS IMPOSTOR Pixel stage.
	 *
	 * @param stage The VS IMPOSTOR Pixel stage.
	 * @return The stage data.
	 */
	public static function toData(stage:ImpostorPixelStage):StageData
	{
		return cast stage;
	}

	/**
	 * Parses a JSON-encoded string formatted with the VS IMPOSTOR Pixel stage format.
	 *
	 * @param file The path towards the JSON file.
	 * @return The stage data.
	 */
	public static function parse(file:String):StageData
	{
		if (!Assets.exists(file) || Path.extension(file) != 'json')
		{
			return null;
		}

		var rawJson:String = Assets.getText(file).trim();

		var parser = new JsonParser<ImpostorPixelStage>();
		parser.fromJson(rawJson, Path.withoutDirectory(file));

		return toData(parser.value);
	}

	/**
	 * Writes a stage data to VS IMPOSTOR Pixel stage format as a JSON-encoded string.
	 *
	 * @param data The stage data.
	 * @return The JSON-encoded string.
	 */
	public static function stringify(data:StageData):String
	{
		if (data == null)
		{
			return '';
		}

		var writer = new JsonWriter<ImpostorPixelStage>();
		return writer.write(fromData(data), ' ');
	}
}
