package funkin.menus.title;

import flixel.util.FlxTimer;

import funkin.graphics.video.FunkinVideo;

class VideoSubState extends MusicBeatSubState
{
	var videoSprite:FunkinVideo;
	var video:String;

	var onComplete:Void -> Void;

	var videoCamera:FlxCamera;

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

		videoSprite = new FunkinVideo().loadVideo(Paths.video('secrets/$video'));
		videoSprite.camera = videoCamera;
		videoSprite.onFormatSetup.add(() ->
		{
			final scale:Float = Math.min(FlxG.width / videoSprite.frameWidth, FlxG.height / videoSprite.frameHeight);

			videoSprite.setGraphicSize(videoSprite.frameWidth * scale, videoSprite.frameHeight * scale);
			videoSprite.updateHitbox();
			videoSprite.screenCenter();
		});
		videoSprite.onFinish.add(onFinishVideo);
		videoSprite.alpha = 0;
		add(videoSprite);

		FlxTween.tween(videoSprite, {alpha: 1}, 0.5);

		FlxTimer.wait(0.1, () -> videoSprite.play());
	}

	override function destroy()
	{
		super.destroy();
		FlxG.cameras.remove(videoCamera);
	}

	function onFinishVideo()
	{
		FlxTween.tween(videoSprite, {alpha: 0}, 0.5, {onComplete: _ -> goBack()});
	}

	function goBack()
	{
		if (onComplete != null)
		{
			onComplete();
		}

		FlxTimer.wait(0.2, () -> close());
	}
}
