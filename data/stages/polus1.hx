import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.util.FlxGradient;
import funkin.backend.shaders.CustomShader;
import openfl.filters.ShaderFilter;
import openfl.display.Shader;
import PixelStars;

public var snowParticles:FlxTypedEmitter;

var stars:PixelStars;

var skyGradient:FlxSprite;

function create() {
    snowParticles = new FlxTypedEmitter(-1600, -800, 180);
    snowParticles.makeParticles(5, 5, FlxColor.WHITE, 100);
    snowParticles.launchAngle.set(120, 60);
    snowParticles.speed.set(80, 250, 200, 800);
    snowParticles.scale.set(1, 1, 3, 3);
    snowParticles.lifespan.set(1800, 1800);
    snowParticles.keepScaleRatio = true;
    snowParticles.width = FlxG.width * 2.5;
    snowParticles.camera = camGame;
    add(snowParticles);

    stars = new PixelStars(0, 0, -20, 3);
    stars.setScrollFactor(0.05, 0.05);
    stars.addStars(0);

    skyGradient = FlxGradient.createGradientFlxSprite(FlxG.width * 3, FlxG.height * 4, [0x004D3357, 0xFF4D3357]);
    skyGradient.x = -1400;
    skyGradient.y = -1000;
    skyGradient.scrollFactor.set(0.15, 0.15);
    insert(0, skyGradient);
}