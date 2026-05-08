package funkin.menus.title;

import flixel.util.FlxTimer;

import haxe.Int64;

import hxvlc.flixel.FlxVideoSprite;

class VideoSubState extends MusicBeatSubState
{
	var videoSprite:FlxVideoSprite;
	var video:String;

	var onComplete:Void -> Void;

	var videoCamera:FlxCamera;

	var videoEndTime:Int64 = 0;

	public function new(video:String, ?onComplete:Void -> Void)
	{
		super();

		this.video = video;
		this.onComplete = onComplete;
	}

	override function create()
	{
		#if FEATURE_DISCORD_API
		DiscordClient.changePresence({
			state: 'Navigating Menus',
			details: 'Watching a Secret Video'
		});
		#end

		super.create();

		videoCamera = new FlxCamera();
		videoCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(videoCamera, false);

		var bg:FunkinSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.camera = videoCamera;
		add(bg);

		videoSprite = new FlxVideoSprite();
		videoSprite.camera = videoCamera;
		videoSprite.bitmap.onFormatSetup.add(() ->
		{
			final scale:Float = Math.min(FlxG.width / videoSprite.bitmap.bitmapData.width, FlxG.height / videoSprite.bitmap.bitmapData.height);

			videoSprite.setGraphicSize(videoSprite.bitmap.bitmapData.width * scale, videoSprite.bitmap.bitmapData.height * scale);
			videoSprite.updateHitbox();
			videoSprite.screenCenter();

			// This is stored as a 64-bit integer???
			videoEndTime = Int64.sub(videoSprite.bitmap.length, haxe.Int64.ofInt(500));
		});
		videoSprite.bitmap.onPlaying.add(onStartVideo);
		videoSprite.bitmap.onEndReached.add(onFinishVideo);
		videoSprite.load(Paths.video('secrets/$video'));
		videoSprite.alpha = 0;
		add(videoSprite);

		FlxTimer.wait(0.1, () -> videoSprite.play());
	}

	override function destroy()
	{
		super.destroy();
		FlxG.cameras.remove(videoCamera);
	}

	var hasFaded:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Int64.compare(videoSprite.bitmap.time, videoEndTime) > 0 && !hasFaded)
		{
			FlxTween.tween(videoSprite, {alpha: 0}, 0.5);
			hasFaded = true;
		}
	}

	function onStartVideo()
	{
		FlxTween.tween(videoSprite, {alpha: 1}, 0.5);
	}

	function onFinishVideo()
	{
		if (onComplete != null)
		{
			onComplete();
		}

		FlxTimer.wait(0.2, () -> close());
	}
}
