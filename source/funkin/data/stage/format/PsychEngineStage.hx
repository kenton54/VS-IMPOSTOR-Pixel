package funkin.data.stage.format;

#if FEATURE_DEBUG_CONTENT
import haxe.io.Path;

import json2object.JsonParser;
import json2object.JsonWriter;

class PsychEngineStage
{
	/**
	 * Creates a Psych Engine 1.0 stage from stage data.
	 *
	 * @param data The stage data.
	 * @return The Psych Engine stage.
	 */
	public static function fromData(data:StageData):PsychEngineStage
	{
		var psychStage:PsychEngineStage = new PsychEngineStage();

		var foundPlayerPos:Array<Float> = [0, 0];
		var foundOpponentPos:Array<Float> = [0, 0];
		var foundPartnerPos:Array<Float> = [0, 0];

		var foundPlayerCameraOffset:Array<Float> = [0, 0];
		var foundOpponentCameraOffset:Array<Float> = [0, 0];
		var foundPartnerCameraOffset:Array<Float> = [0, 0];

		var girlfriendFound:Bool = false;

		for (object in data.objects)
		{
			switch (object.type)
			{
				case CHARACTER:
					if (StageData.isObjectIDPlayerCharacter(object.ID))
					{
						foundPlayerPos[0] = object.position[0] ?? 0;
						foundPlayerPos[1] = object.position[1] ?? 0;

						foundPlayerCameraOffset[0] = object.cameraOffsets[0] ?? 0;
						foundPlayerCameraOffset[1] = object.cameraOffsets[1] ?? 0;

						psychStage.objects.push({type: 'boyfriend'});
					}
					else if (StageData.isObjectIDOpponentCharacter(object.ID))
					{
						foundOpponentPos[0] = object.position[0] ?? 0;
						foundOpponentPos[1] = object.position[1] ?? 0;

						foundOpponentCameraOffset[0] = object.cameraOffsets[0] ?? 0;
						foundOpponentCameraOffset[1] = object.cameraOffsets[1] ?? 0;

						psychStage.objects.push({type: 'dad'});
					}
					else if (!girlfriendFound)
					{
						// we'll assume its girlfriend, and avoid setting it multiple times
						// if the stage contains more than 3 characters

						foundPartnerPos[0] = object.position[0] ?? 0;
						foundPartnerPos[1] = object.position[1] ?? 0;

						foundPartnerCameraOffset[0] = object.cameraOffsets[0] ?? 0;
						foundPartnerCameraOffset[1] = object.cameraOffsets[1] ?? 0;

						psychStage.objects.push({type: 'gf'});

						girlfriendFound = true;
					}

				case SPRITE:
					var isAnimated:Bool = object.animations != null && object.animations.length > 0;

					var objectData:PsychEngineStageObject = {
						name: object.ID,
						type: isAnimated ? ANIMATED_SPRITE : SPRITE,
						image: object.assets[0],
						x: object.position[0],
						y: object.position[1],
						scale: [Std.int(object.scale ?? 1), Std.int(object.scale ?? 1)],
						antialiasing: object.antialiasing ?? true,
						flipX: false,
						flipY: false,
						filters: 3,
						color: object.color ?? '#FFFFFF'
					};

					if (isAnimated)
					{
						objectData.firstAnimation = object.animations[0].name;
						objectData.animations = [];

						for (animation in object.animations)
						{
							if (animation.type != TILED)
							{
								objectData.animations.push({
									anim: animation.name,
									name: animation.prefix,
									fps: Std.int(animation.frameRate),
									loop: animation.loop ?? false,
									indices: animation.frameIndices ?? [],
									offsets: animation.offsets != null ? [Std.int(animation.offsets[0]), Std.int(animation.offsets[1])] : [0, 0]
								});
							}
						}
					}

					psychStage.objects.push(objectData);

				case RECTANGLE:
					psychStage.objects.push({
						name: object.ID,
						type: SQUARE,
						x: object.position[0],
						y: object.position[1],
						scale: [object.width ?? 1, object.height ?? 1],
						filters: 3,
						color: object.color ?? '#FFFFFF'
					});
			}
		}

		psychStage.defaultZoom = data.camZoom;

		psychStage.boyfriend = foundPlayerPos;
		psychStage.girlfriend = foundPartnerPos;
		psychStage.opponent = foundOpponentPos;

		psychStage.camera_boyfriend = foundPlayerCameraOffset;
		psychStage.camera_girlfriend = foundPartnerCameraOffset;
		psychStage.camera_opponent = foundOpponentCameraOffset;

		return psychStage;
	}

	/**
	 * Creates stage data from a Psych Engine 1.0 stage.
	 *
	 * @param stage The Psych Engine 1.0 stage.
	 * @return The stage data.
	 */
	public static function toData(stage:PsychEngineStage):StageData
	{
		var stageData:StageData = new StageData();

		return stageData;
	}

	/**
	 * Parses a JSON-encoded string formatted with the Psych Engine 1.0 stage format.
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

		var parser = new JsonParser<PsychEngineStage>();
		parser.fromJson(rawJson, Path.withoutDirectory(file));

		return toData(parser.value);
	}

	/**
	 * In what directory are the assets of the stage stored.
	 */
	@:default('')
	public var directory:String;

	/**
	 * The default camera zoom of the stage.
	 *
	 * Overrides PlayState's.
	 */
	@:default(1)
	public var defaultZoom:Float;

	/**
	 * Whether the stage gets loaded as a pixel stage.
	 */
	@:optional
	@:default(false)
	public var isPixelStage:Bool;

	/**
	 * The UI assets to load when this stage is loaded.
	 */
	@:default('normal')
	public var stageUI:String;

	/**
	 * The player's position inside the stage.
	 */
	@:default([0, 0])
	public var boyfriend:Array<Float>;

	/**
	 * The partner's position inside the stage.
	 */
	@:default([0, 0])
	public var girlfriend:Array<Float>;

	/**
	 * The opponent's position inside the stage.
	 */
	@:default([0, 0])
	public var opponent:Array<Float>;

	/**
	 * Whether to not create the partner character when the stage is loaded.
	 */
	@:default(false)
	public var hide_girlfriend:Bool;

	/**
	 * How much to offset the player's camera position in the stage.
	 */
	@:default([0, 0])
	public var camera_boyfriend:Array<Float>;

	/**
	 * How much to offset the opponent's camera position in the stage.
	 */
	@:default([0, 0])
	public var camera_opponent:Array<Float>;

	/**
	 * How much to offset the partner's camera position in the stage.
	 */
	@:default([0, 0])
	public var camera_girlfriend:Array<Float>;

	/**
	 * The speed of the game camera.
	 */
	@:optional
	@:default(1)
	public var camera_speed:Float;

	/**
	 * A list of assets to preload when the stage loads.
	 */
	@:optional
	@:default([])
	public var preload:Map<String, Int>;

	/**
	 * The objects the stage contains.
	 *
	 * The order of the objects inside the array matters, it doesn't get sorted.
	 */
	@:optional
	@:default([])
	public var objects:Array<PsychEngineStageObject>;

	/**
	 * Metadata used for the Stage Editor.
	 */
	@:optional
	public var _editorMeta:PsychEngineStageEditorMetaData;

	public function new()
	{
		this.directory = '';
		this.defaultZoom = 0.9;
		this.isPixelStage = false;
		this.stageUI = 'normal';

		this.boyfriend = [770, 100];
		this.girlfriend = [400, 130];
		this.opponent = [100, 100];
		this.hide_girlfriend = false;

		this.camera_boyfriend = [0, 0];
		this.camera_opponent = [0, 0];
		this.camera_girlfriend = [0, 0];
		this.camera_speed = 1;

		this.preload = [];
		this.objects = [
			{type: 'gf'},
			{type: 'dad'},
			{type: 'boyfriend'},
		];
		this._editorMeta = {
			dad: 'dad',
			boyfriend: 'bf',
			gf: 'gf'
		};
	}
}

typedef PsychEngineStageObject =
{
	/**
	 * The name of the object.
	 */
	@:optional
	var name:String;

	/**
	 * The type of object.
	 *
	 * Changes how the object is created and loaded onto the stage.
	 */
	var type:PsychEngineStageObjectType;

	/**
	 * The horizontal position of the object.
	 */
	@:optional
	@:default(0)
	var x:Float;

	/**
	 * The vertical position of the object.
	 */
	@:optional
	@:default(0)
	var y:Float;

	/**
	 * The asset the object uses to render on the stage.
	 *
	 * Used when the `type` is set to `sprite` or `animatedSprite`.
	 */
	@:optional
	@:default('')
	var image:String;

	/**
	 * The animation to play when the object is created.
	 */
	@:optional
	@:default('')
	var firstAnimation:String;

	/**
	 * An array holding various animations to load to the object.
	 *
	 * Used when the `type` is set to `animatedSprite`.
	 */
	@:optional
	@:default([])
	var animations:Array<PsychEngineAnimationData>;

	/**
	 * Whether the object should be anti-aliased when rendering.
	 */
	@:optional
	@:default(true)
	var antialiasing:Bool;

	/**
	 * Whether to flip the object horizontally.
	 */
	@:optional
	@:default(false)
	var flipX:Bool;

	/**
	 * Whether to flip the object vertically.
	 */
	@:optional
	@:default(false)
	var flipY:Bool;

	/**
	 * The scale of the object.
	 */
	@:optional
	@:default([1, 1])
	var scale:Array<Float>;

	/**
	 * How much the object scrolls relative to the camera.
	 */
	@:optional
	@:default([1, 1])
	var scroll:Array<Float>;

	/**
	 * The color of the object.
	 */
	@:optional
	@:default('#FFFFFF')
	var color:String;

	/**
	 * The opacity of the object.
	 */
	@:optional
	@:default(1)
	var alpha:Float;

	/**
	 * The angle of the object, in degrees.
	 */
	@:optional
	@:default(0)
	var angle:Float;

	/**
	 * Handles when the character gets created and added to the stage.
	 */
	@:optional
	@:default(3)
	var filters:Int;
}

enum abstract PsychEngineStageObjectType(String) from String to String
{
	var DAD:String = 'dad';

	var DAD_GROUP:String = 'dadGroup';

	var GIRLFRIEND:String = 'gf';

	var GIRLFRIEND_GROUP:String = 'gfGroup';

	var BOYFRIEND:String = 'boyfriend';

	var BOYFRIEND_GROUP:String = 'boyfriendGroup';

	var SQUARE:String = 'square';

	var SPRITE:String = 'sprite';

	var ANIMATED_SPRITE:String = 'animatedSprite';
}

typedef PsychEngineAnimationData =
{
	/**
	 * The name of the animation.
	 */
	var anim:String;

	/**
	 * The prefix of the name of the frames.
	 */
	var name:String;

	/**
	 * The frame rate of the animation.
	 *
	 * In other words, how many frames to play of the animation in 1 second.
	 */
	var fps:Int;

	/**
	 * Whether to loop the animation.
	 */
	var loop:Bool;

	/**
	 * The frames of the animation to play.
	 */
	var indices:Array<Int>;

	/**
	 * The offsets of the animation.
	 */
	var offsets:Array<Int>;
}

typedef PsychEngineStageEditorMetaData =
{
	/**
	 * The character to load with the opponent's positions.
	 */
	@:default('dad')
	var dad:String;

	/**
	 * The character to load with the player's positions.
	 */
	@:default('bf')
	var boyfriend:String;

	/**
	 * The character to load with the partner's positions.
	 */
	@:default('gf')
	var gf:String;
}
#end
