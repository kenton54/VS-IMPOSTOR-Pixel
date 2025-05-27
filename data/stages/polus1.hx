import funkin.game.PlayState;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;

public var snowParticles:FlxTypedEmitter;

function create() {
    snowParticles = new FlxTypedEmitter(-1600, -800, 100);
    snowParticles.makeParticles(5, 5, FlxColor.WHITE, 100);
    snowParticles.launchAngle.set(120, 60);
    snowParticles.speed.set(80, 100, 150, 300);
    snowParticles.scale.set(1, 1, 3, 3);
    snowParticles.lifespan.set(1800, 1800);
    snowParticles.keepScaleRatio = true;
    snowParticles.width = FlxG.width * 2.5;
    snowParticles.camera = camGame;
    add(snowParticles);
}