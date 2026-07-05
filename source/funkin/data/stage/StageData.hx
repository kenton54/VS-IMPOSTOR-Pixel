package funkin.data.stage;

import funkin.data.animation.AnimationData;

class StageData
{
	public static var stages(default, null):Array<StageData> = [];

	/**
	 * @param id The ID of the stage object with the `type` set as `character`.
	 * @return Whether the stage object can be considered a player character.
	 */
	public static function isObjectIDPlayerCharacter(id:String):Bool
	{
		return id == 'player' || id == 'player1' || id == 'boyfriend' || id == 'bf';
	}

	/**
	 * @param id The ID of the stage object with the `type` set as `character`.
	 * @return Whether the stage object can be considered an opponent character.
	 */
	public static function isObjectIDOpponentCharacter(id:String):Bool
	{
		return id == 'opponent' || id == 'player2' || id == 'dad';
	}

	/**
	 * The internal name of the stage.
	 */
	@:optional
	public var ID:String;

	/**
	 * The readable name of the stage.
	 */
	public var name:String;

	/**
	 * The default camera zoom of the stage.
	 *
	 * Overrides PlayState's.
	 */
	@:optional
	@:default(1)
	public var camZoom:Float;

	/**
	 * The objects the stage contains.
	 *
	 * The order of the objects inside the array matters, it doesn't get sorted.
	 */
	@:default([])
	public var objects:Array<StageObjectData> = [];

	public function new()
	{
		this.objects = defaultStageObjects();
	}

	function defaultStageObjects():Array<StageObjectData>
	{
		return [
			{
				ID: 'player',
				type: 'character',
				character: 'bf',
				position: [0, 0]
			}
		];
	}
}

typedef StageObjectData =
{
	/**
	 * The internal name of the object.
	 *
	 * Used for the object to be retrieved by scripts.
	 */
	var ID:String;

	/**
	 * The type of object.
	 *
	 * Changes how the object is created and loaded onto the stage.
	 */
	var type:StageObjectType;

	/**
	 * The position of the object inside the stage.
	 */
	@:default([0, 0])
	var position:Array<Float>;

	/**
	 * The character to load in the object.
	 *
	 * Used when the `type` is set to `character`.
	 */
	@:optional
	@:default('bf')
	var character:String;

	/**
	 * All the assets the object uses to render on the stage.
	 *
	 * Used when the `type` is set to `sprite`.
	 */
	@:optional
	@:default([])
	var assets:Array<String>;

	/**
	 * How often the bopper plays the dance animation every beat.
	 */
	@:optional
	@:default(0)
	var danceEvery:Float;

	/**
	 * The width of the object.
	 *
	 * Used when the `type` is set to `rect`.
	 */
	@:optional
	var width:Int;

	/**
	 * The height of the object.
	 *
	 * Used when the `type` is set to `rect`.
	 */
	@:optional
	var height:Int;

	/**
	 * The scale of the object.
	 */
	@:optional
	@:default(1)
	var scale:Float;

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
	 * Whether the object should be anti-aliased when rendering.
	 */
	@:optional
	@:default(false)
	var antialiasing:Bool;

	/**
	 * The blend mode of the object.
	 */
	@:optional
	@:default('')
	var blend:String;

	/**
	 * The color of the object.
	 */
	@:optional
	@:default('#FFFFFF')
	var color:String;

	/**
	 * How much the object scrolls relative to the camera.
	 */
	@:optional
	@:default([1, 1])
	var scrollFactor:Array<Float>;

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
	 * An array holding various animations to load to the object.
	 *
	 * Used when the `type` is set to `sprite`.
	 */
	@:optional
	@:default([])
	var animations:Array<AnimationData>;

	/**
	 * How much to offset the character's camera focus position.
	 *
	 * Used when the `type` is set to `character`.
	 */
	@:optional
	@:default([0, 0])
	var cameraOffsets:Array<Float>;
}

enum abstract StageObjectType(String) from String to String
{
	var CHARACTER:String = 'character';

	var SPRITE:String = 'sprite';

	var RECTANGLE:String = 'rect';
}
