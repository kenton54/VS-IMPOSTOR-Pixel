package funkin.data.song;

import funkin.data.song.format.ImpostorPixelChart;

import haxe.io.Path;

class SongData
{
	public static var songs(default, null):Array<SongData> = [];

	@:allow(funkin.InitState)
	static function init()
	{
		songs = [];

		var chartFiles:Array<String> = Paths.readDirectory('data/charts').filter(file -> Path.extension(file) == 'imppixelc');

		for (chart in chartFiles)
		{
			songs.push(loadFromFile(chart));
		}
	}

	/**
	 * Loads song data from the specified file.
	 *
	 * Parses the data using the VS IMPOSTOR Pixel chart format.
	 * If you want to load a chart file from another engine, use the `SongParser` class.
	 *
	 * @param file The file to load.
	 * @return The loaded song data.
	 */
	public static function loadFromFile(file:String):SongData
	{
		return ImpostorPixelChart.parse(file);
	}

	/**
	 * @param id The song ID.
	 * @return The song data with the matching iD.
	 */
	public static function fromID(id:String):SongData
	{
		for (song in songs)
		{
			if (song.ID == id)
			{
				return song;
			}
		}

		return null;
	}

	/**
	 * @param id The song ID.
	 * @return Whether the song with the matching ID exists or its loaded, or not.
	 */
	public static function exists(id:String):Bool
	{
		return fromID(id) != null;
	}

	/**
	 * @return The metadata of all the loaded songs.
	 */
	public static function getMetaDatas():Array<SongMetaData>
	{
		return [for (song in songs) song.metadata];
	}

	/**
	 * @return The names of all the loaded songs.
	 */
	public static function getNames():Array<String>
	{
		return [for (song in songs) song.metadata.name];
	}

	/**
	 * The internal name of the song.
	 */
	public var ID:String;

	/**
	 * A map holding the song's charts.
	 *
	 * Key: difficulty ID.
	 * Value: The song difficulty's chart data.
	 */
	@:default([])
	public var charts:Map<String, SongChartData>;

	/**
	 * An array holding the song's events.
	 */
	@:default([])
	public var events:Array<SongEventData>;

	/**
	 * The information about the song.
	 */
	public var metadata:SongMetaData;

	public function new(id:String)
	{
		this.ID = id;

		this.charts = [];
		this.events = [];

		this.metadata = new SongMetaData();
		this.metadata.ID = this.ID;
	}

	/**
	 * @param id The event ID.
	 * @return Whether the song contains any events with the given ID. If it wasn't specified, it will check
	 * if the song has any events.
	 */
	public function hasEvents(?id:String):Bool
	{
		return id != null ? filterEvents(id).length > 0 : this.events.length > 0;
	}

	/**
	 * Retrieves only the events with the matching ID.
	 *
	 * @param id The event ID.
	 * @return An array holding all the events with the given ID. If it wasn't specified, it will return
	 * all the events the song has.
	 */
	public function filterEvents(?id:String):Array<SongEventData>
	{
		return id != null ? this.events.filter(eventData -> eventData.ID == id) : this.events;
	}
}

class SongChartData
{
	/**
	 * All the strumlines the chart contains.
	 */
	@:default([])
	public var strumlines:Array<SongStrumlineData>;

	/**
	 * How fast the notes scroll.
	 */
	@:default(1)
	public var scrollSpeed:Float;

	public function new(scrollSpeed:Float)
	{
		this.scrollSpeed = scrollSpeed;
	}
}

class SongStrumlineData
{
	/**
	 * Whether the strumline is controlled by a player.
	 */
	public var player:Bool;

	/**
	 * How many strums does the strumline contain.
	 */
	@:default(4)
	public var strumCount:Int;

	/**
	 * The character owner of the strumline.
	 */
	@:default('bf')
	public var character:String;

	/**
	 * The horizontal position of the strumline in the HUD, as a percentage value.
	 */
	@:default(0.5)
	public var position:Float;

	/**
	 * The vocals attached to the strumline.
	 */
	@:default('')
	public var vocalsSuffix:String;

	/**
	 * All the notes the strumline contains.
	 */
	@:default([])
	public var notes:Array<SongNoteData>;

	/**
	 * How much to multiply the base scroll speed.
	 */
	@:optional
	@:default(1)
	public var scrollSpeedMult:Float;

	public function new(player:Bool, strumCount:Int, character:String, position:Float)
	{
		this.player = player;
		this.strumCount = strumCount;
		this.character = character;
		this.position = position;
		this.notes = [];
		this.scrollSpeedMult = 1;
	}
}

class SongNoteData
{
	/**
	 * The note ID.
	 */
	public var ID:Int;

	/**
	 * The time, in milliseconds, of when the note is supposed to be hit.
	 */
	public var time:Float;

	/**
	 * The length of the note.
	 */
	@:optional
	@:default(0)
	public var length:Float;

	/**
	 * The type of note.
	 */
	@:optional
	public var type:Null<String>;

	public function new(id:Int, time:Float, ?length:Float, ?type:String)
	{
		this.ID = id;
		this.time = time;
		this.length = length != null ? length : 0;
		this.type = type;
	}
}

class SongEventData
{
	/**
	 * The event ID.
	 */
	public var ID:String;

	/**
	 * The time, in milliseconds, of when the event is supposed to be triggered.
	 */
	public var time:Float;

	/**
	 * The data the event contains.
	 */
	public var data:Dynamic;

	public function new(id:String, time:Float, data:Dynamic)
	{
		this.ID = id;
		this.time = time;
		this.data = data;
	}
}

class SongMetaData
{
	/**
	 * The internal name of the song.
	 */
	@:optional
	public var ID:String;

	/**
	 * The readable name of the song.
	 */
	@:default('Unknown')
	public var name:String;

	/**
	 * A list holding the types of difficulties the song can be played with.
	 */
	@:default(['normal'])
	public var difficulties:Array<String>;

	/**
	 * A list holding the different variants the song can be played with.
	 */
	@:default([])
	public var variants:Array<String>;

	/**
	 * The icon ID to display in the Freeplay Menu.
	 */
	@:default('bf')
	public var icon:String;

	/**
	 * The portrait ID to display in the Freeplay Menu.
	 */
	@:default('bf')
	public var portrait:String;

	/**
	 * The color to display in the Freeplay Menu.
	 */
	@:default(0xFFFFFFFF)
	public var color:FlxColor;

	/**
	 * The people that helped create the song.
	 */
	@:optional
	@:default([])
	public var credits:Array<SongCredits>;

	/**
	 * The stage the song is meant to be played on.
	 */
	@:default('lobby')
	public var stage:String;

	/**
	 * The UI style to display when playing.
	 */
	@:optional
	public var uiStyle:Null<String>;

	/**
	 * The chart rating of each difficulty.
	 */
	@:noCompletion
	@:optional
	@:default(['normal' => 1])
	var chartsRating:Map<String, Int>;

	public function new()
	{
		this.name = 'Unknown';
		this.difficulties = [];
		this.variants = [];
		this.icon = 'red';
		this.color = FlxColor.WHITE;
		this.credits = [];
		this.stage = 'lobby';
		this.uiStyle = null;

		this.chartsRating = [];
	}

	/**
	 * Safely retrieves the difficulty scale of the chart's difficulty.
	 *
	 * @param difficulty The difficulty ID.
	 * @return The difficulty scale of the chart.
	 */
	public function getChartRating(difficulty:String):Int
	{
		return chartsRating.get(difficulty) ?? 0;
	}
}

typedef SongCredits =
{
	/**
	 * The name of the user who helped create the song.
	 */
	var name:String;

	/**
	 * What the user did.
	 */
	var job:String;
}
