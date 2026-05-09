package funkin.play;

import flixel.math.FlxPoint;

import haxe.Json;

class Character extends FunkinSprite
{
	/**
	 * The current loaded character's ID.
	 */
	public var character(default, null):String;

	public var positionOffsets(default, null):FlxPoint;

	public var cameraOffsets(default, null):FlxPoint;

	public var singDuration(default, null):Float;

	public var bioID(default, null):Null<String>;

	public var comboNoteCounts(default, null):Array<Int> = [];

	public var dropNoteCounts(default, null):Array<Int> = [];

	var _data:CharacterData;

	public function new(x:Float = 0, y:Float = 0, ?character:String)
	{
		super(x, y);

		if (character != null)
		{
			loadCharacter(character);
		}
	}

	public function loadCharacter(character:String):Character
	{
		var rawCharacterData:CharacterData = null;

		if (Assets.exists(Paths.json('characters/$character')))
		{
			rawCharacterData = Json.parse(Assets.getText(Paths.json('characters/$character')));
		}
		else
		{
			FlxG.log.warn('Couldn\'t find character with an ID of "$character"!');
			rawCharacterData = Json.parse(Assets.getText(Paths.json('characters/${Constants.DEFAULT_CHARACTER}')));
		}

		var characterData:CharacterData = {
			assets: rawCharacterData.assets,
			scale: rawCharacterData.scale ?? 1.0,
			offsets: rawCharacterData.offsets ?? [0, 0],
			flipX: rawCharacterData.flipX ?? false,
			flipY: rawCharacterData.flipY ?? false,
			cameraOffsets: rawCharacterData.cameraOffsets ?? [0, 0],
			singDuration: rawCharacterData.singDuration ?? 8.0,
			antialiasing: rawCharacterData.antialiasing ?? false,
			bioID: rawCharacterData.bioID ?? null,
			healthIcon: {
				icon: rawCharacterData.healthIcon.icon,
				scale: rawCharacterData.healthIcon.scale ?? 1.0,
				offsets: rawCharacterData.healthIcon.offsets ?? [0, 0],
				flipX: rawCharacterData.healthIcon.flipX ?? false,
				flipY: rawCharacterData.healthIcon.flipY ?? false,
				antialiasing: rawCharacterData.healthIcon.antialiasing ?? false,
			},
			animations: rawCharacterData.animations
		};

		positionOffsets = FlxPoint.get(characterData.offsets[0], characterData.offsets[1]);
		cameraOffsets = FlxPoint.get(characterData.cameraOffsets[0], characterData.cameraOffsets[1]);

		singDuration = characterData.singDuration;
		antialiasing = characterData.antialiasing;
		bioID = characterData.bioID;

		flipX = characterData.flipX;
		flipY = characterData.flipY;

		frames = Paths.getMultipleFrames(characterData.assets);

		for (animationData in characterData.animations)
		{
			addCharacterAnimation(animationData.name, animationData.prefix, animationData.frameRate, animationData.looped, FlxPoint.get(animationData.offsets[0], animationData.offsets[1]), animationData.flipX, animationData.flipY);
		}

		playAnimation(animation.getNameList()[0]);
		scaleSprite(characterData.scale);

		_data = characterData;

		return this;
	}

	function addCharacterAnimation(animation:String, prefix:String, framerate:Float = 24, looped:Bool = true, ?offsets:FlxPoint, flipX:Bool = false, flipY:Bool = false)
	{
		if (offsets == null)
		{
			offsets = FlxPoint.get();
		}

		addAnimationByPrefix(animation, prefix, framerate, looped, flipX, flipY);
		addAnimationOffsets(animation, offsets.x, offsets.y);
	}
}

typedef CharacterData =
{
	var assets:Array<String>;
	var ?scale:Float;
	var ?offsets:Array<Float>;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?cameraOffsets:Array<Float>;
	var ?singDuration:Float;
	var ?antialiasing:Bool;
	var ?bioID:Null<String>;
	var ?healthIcon:HealthIconData;
	var animations:Array<CharacterAnimationData>;
}

typedef HealthIconData =
{
	var icon:String;
	var ?scale:Float;
	var ?offsets:Array<Float>;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?antialiasing:Bool;
}

typedef CharacterAnimationData =
{
	var name:String;
	var prefix:String;
	var frameRate:Float;
	var ?offsets:Array<Float>;
	var ?looped:Bool;
	var ?flipX:Bool;
	var ?flipY:Bool;
}
