package funkin.menus;

import flixel.util.FlxSpriteUtil;

import funkin.system.FunkinMemory;

import haxe.io.Path;

class StartupState extends MusicBeatState
{
	var curCache:CacheAssetType = None;

	var miniCrewmate:FunkinSprite;

	var imagesToCache:Array<String> = [];
	var soundsToCache:Array<String> = [];
	var musicsToCache:Array<String> = [];

	var cachePos:Int = 0;
	var isCachingAsset:Bool = false;

	override function create()
	{
		imagesToCache.push(Paths.image('stars'));
		imagesToCache.push(Paths.image('ui/backButton'));
		imagesToCache.push(Paths.image('ui/x'));
		imagesToCache = imagesToCache.concat(Paths.readDirectory('images/menus/title', null, true).filter(file -> Path.extension(file) == 'png'));
		imagesToCache = imagesToCache.concat(Paths.readDirectory('images/menus/mainmenu', null, true).filter(file -> Path.extension(file) == 'png'));

		soundsToCache = soundsToCache.concat(Paths.readDirectory('sounds/menu', null, true).filter(file -> Path.extension(file) == 'ogg'));

		musicsToCache.push(Paths.music('mainMenu'));

		super.create();

		miniCrewmate = new FunkinSprite().loadGraphic(Paths.image('ui/loading/mini-crewmate'), true, 32, 32);
		miniCrewmate.addAnimationByFrameLength(10, 18);
		miniCrewmate.playAnimation();
		miniCrewmate.scaleSprite(4);
		miniCrewmate.x = FlxG.width;
		miniCrewmate.y = FlxG.height - miniCrewmate.height - 4;
		miniCrewmate.velocity.x = -500;
		add(miniCrewmate);

		var loadingTxt:FunkinText = new FunkinText(100, 0, FlxG.width - 200, '', 32);
		loadingTxt.translationData = {id: 'generic.loading'};
		loadingTxt.alignment = RIGHT;
		loadingTxt.y = FlxG.height * 0.85 - loadingTxt.height;
		add(loadingTxt);

		var logo:FunkinSprite = new FunkinSprite().loadGraphic(Paths.image('ui/loading/logo'));
		logo.scaleSprite(2);
		logo.x = loadingTxt.x + loadingTxt.width - logo.width;
		logo.y = loadingTxt.y - logo.height - 8;
		add(logo);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxSpriteUtil.cameraWrap(miniCrewmate, null, LEFT);

		if (!isCachingAsset)
		{
			cacheNextAsset();
		}
	}

	function cacheNextAsset()
	{
		switch (curCache)
		{
			case None:
				// makes the assets start getting cached on the next update call
				curCache = Images;

			case Images:
				if (cachePos >= imagesToCache.length)
				{
					cachePos = 0;
					curCache = Sounds;
					return;
				}

				isCachingAsset = true;

				FunkinMemory.getGraphic(imagesToCache[cachePos]);

				cachePos++;
				isCachingAsset = false;

			case Sounds:
				if (cachePos >= soundsToCache.length)
				{
					cachePos = 0;
					curCache = Musics;
					return;
				}

				isCachingAsset = true;

				FunkinMemory.getSound(soundsToCache[cachePos]);

				cachePos++;
				isCachingAsset = false;

			case Musics:
				if (cachePos >= musicsToCache.length)
				{
					cachePos = 0;
					curCache = Done;
					return;
				}

				isCachingAsset = true;

				FunkinMemory.getMusic(musicsToCache[cachePos]);

				cachePos++;
				isCachingAsset = false;

			case Done:
				// just so this function stops getting called every frame
				isCachingAsset = true;
				startGame();
		}
	}

	function startGame()
	{
		MusicBeatState.setTransitions(Fade);
		FlxG.switchState(() -> new funkin.menus.title.TitleState());
	}
}

enum CacheAssetType
{
	None;
	Images;
	Sounds;
	Musics;
	Done;
}
