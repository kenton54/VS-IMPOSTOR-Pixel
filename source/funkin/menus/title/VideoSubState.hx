package funkin.menus.title;

import flixel.util.FlxTimer;

import funkin.graphics.video.FunkinVideo;

class VideoSubState extends MusicBeatState
{
	var videoSprite:FunkinVideo;
	var video:String;

	var miniCrewmate:FunkinSprite;

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
		videoSprite.onPlay.add(onStartVideo);
		videoSprite.onFinish.add(onFinishVideo);
		videoSprite.onBufferEmpty.add(onBufferLoad);
		videoSprite.alpha = 0;
		add(videoSprite);

		miniCrewmate = new FunkinSprite().loadGraphic(Paths.image('ui/loading/mini-crewmate'), true, 32, 32);
		miniCrewmate.addAnimationByFrameLength(10, 18);
		miniCrewmate.playAnimation();
		miniCrewmate.scaleSprite(4);
		miniCrewmate.x = FlxG.width - miniCrewmate.width - 16;
		miniCrewmate.y = FlxG.height - miniCrewmate.height - 16;
		add(miniCrewmate);

		FlxTimer.wait(0.1, () -> videoSprite.play());
	}

	override function destroy()
	{
		super.destroy();
		FlxG.cameras.remove(videoCamera);
	}

	function onStartVideo()
	{
		onBufferFinish();
		FlxTween.tween(videoSprite, {alpha: 1}, 0.5);
	}

	function onFinishVideo()
	{
		FlxTween.tween(videoSprite, {alpha: 0}, 0.5, {onComplete: _ -> goBack()});
	}

	function onBufferLoad()
	{
		miniCrewmate.animation.resume();
		miniCrewmate.visible = true;
	}

	function onBufferFinish()
	{
		miniCrewmate.animation.pause();
		miniCrewmate.visible = false;
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
