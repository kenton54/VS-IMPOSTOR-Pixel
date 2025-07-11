import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxVelocity;

class PixelStars {
    private var starArray:Array<FlxBackdrop> = [];
    private var starBasePos:Array<Array<Float>> = [];
    private var scale:Float = 0;

    public var speed:Float = 0;
    public var layers:Int = 3;

    private var currentPosition:Float = 0;

    /**
     * Creates a set of backdrops filled with a star field, it automatically adds them to the current state
     * @param speed The speed the stars travel
     * @param layerAmount How many layers of star fields should there be
     * @param baseScale The scaling of each layer
     */
    public function new(speed:Float = -50, layerAmount:Int = 3, ?baseScale:Float = 1) {
        if (baseScale == null) baseScale = 4;

        this.speed = speed;
        this.layers = layerAmount;
        this.scale = baseScale;

        createStars();
    }

    private function createStars() {
        for (i in 0...layers) {
            var star:FlxBackdrop = new FlxBackdrop(Paths.image("menus/stars"));
            star.scale.set(scale / i, scale / i);
            star.updateHitbox();
            star.setPosition(60 * i, 60 * i);
            star.scrollFactor.set(0, 0);
            star.velocity.x = speed / (i * 2);

            var fuckingEquation:Float = (i * 2) * 0.1;
            var alphaAmount:Float = FlxMath.remapToRange(fuckingEquation, 0, 1, 1, 0);
            star.alpha = alphaAmount;

            star.color = FlxColor.WHITE;

            starArray.push(star);
        }
    }

    public function addStars(?fromPos:Int) {
        if (fromPos == null) {
            for (star in starArray) {
                FlxG.state.add(star);
            }
        }
        else {
            for (star in starArray) {
                FlxG.state.insert(fromPos, star);
            }
        }
    }

    public function setSpeed(newSpeed:Float = 50) {
        speed = newSpeed;

        for (starGraphic in starArray) {
            starGraphic.velocity.x = newSpeed;
        }
    }

    public function setScrollFactor(x:Float = 0, y:Float = 0) {
        for (starGraphic in starArray) {
            starGraphic.scrollFactor.set(x, y);
        }
    }

    public function setCamera(camera:FlxCamera) {
        for (starGraphic in starArray) {
            starGraphic.camera = camera;
        }
    }

    public function destroy() {
        for (starGraphic in starArray) {
            starGraphic.destroy();
        }

        stars = [];
    }
}