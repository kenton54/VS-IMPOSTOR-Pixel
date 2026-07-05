package funkin.data.song.format;

import json2object.JsonParser;
import json2object.JsonWriter;

class ImpostorPixelChart extends SongData
{
	/**
	 * Creates a VS IMPOSTOR Pixel chart from song data.
	 *
	 * @param data The song data.
	 * @return The VS IMPOSTOR Pixel chart.
	 */
	public static function fromData(data:SongData):ImpostorPixelChart
	{
		return cast data;
	}

	/**
	 * Creates song data from a VS IMPOSTOR Pixel chart.
	 *
	 * @param chart The VS IMPOSTOR Pixel stage.
	 * @return The song data.
	 */
	public static function toData(chart:ImpostorPixelChart):SongData
	{
		return cast chart;
	}

	/**
	 * Parses a JSON-encoded string formatted with the VS IMPOSTOR Pixel chart format.
	 *
	 * @param file The path towards the JSON file.
	 * @return The song data.
	 */
	public static function parse(file:String):SongData
	{
		if (!Assets.exists(file) || !SongParser.isFormatValid(file, IMPOSTORPIXEL))
		{
			return null;
		}

		var rawJson:String = Assets.getText(file).trim();

		var parser = new JsonParser<ImpostorPixelChart>();
		parser.fromJson(rawJson, haxe.io.Path.withoutDirectory(file));

		var songData:SongData = toData(parser.value);
		songData.metadata.ID = songData.ID;

		return songData;
	}

	/**
	 * Writes a song data to VS IMPOSTOR Pixel chart format as a JSON-encoded string.
	 *
	 * @param data The song data.
	 * @return The JSON-encoded string.
	 */
	public static function stringify(data:SongData):String
	{
		if (data == null)
		{
			return '';
		}

		var writer = new JsonWriter<ImpostorPixelChart>();
		return writer.write(fromData(data), ' ');
	}
}
