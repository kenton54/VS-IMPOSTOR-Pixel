package funkin.data.song;

import funkin.data.song.format.*;

import haxe.Json;

enum ChartFormat
{
	#if FEATURE_DEBUG_CONTENT
	LUDUMDARE;
	LEGACY;
	PSYCH;
	CODENAME;
	NMV;
	VSLICE;
	#end

	IMPOSTORPIXEL;
	NONE;
}

class SongParser
{
	public static function detectChartFormat(data:Dynamic):ChartFormat
	{
		var fields:Array<String> = Reflect.fields(data);

		if (fields.length == 4 && fields.contains('ID') && fields.contains('chart') && fields.contains('events') && fields.contains('metadata'))
		{
			return IMPOSTORPIXEL;
		}
		#if FEATURE_DEBUG_CONTENT
		else if (fields.length == 3 && fields.contains('song') && fields.contains('bpm') && fields.contains('sections'))
		{
			return LUDUMDARE;
		}
		else if (fields.contains('version'))
		{
			return VSLICE;
		}
		#end

		return NONE;
	}

	/**
	 * @param file 		The file containing the chart data.
	 * @param format 	The format to check for match, optional.
	 * @return Whether the given data matches the given format.
	 */
	public static function isFormatValid(file:String, ?format:ChartFormat = NONE):Bool
	{
		var data:Dynamic = Json.parse(Assets.getText(file));
		var foundFormat:ChartFormat = detectChartFormat(data);
		return format == NONE ? foundFormat != NONE : foundFormat == format;
	}

	public static function fromFile(file:String)
	{
		var data:Dynamic = Json.parse(Assets.getText(file));
		var chartFormat:ChartFormat = detectChartFormat(data);
	}

	public static function saveToFormat(data:SongData, format:ChartFormat = IMPOSTORPIXEL) {}
}
