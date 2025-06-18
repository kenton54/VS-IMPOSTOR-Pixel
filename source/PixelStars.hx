import flixel.addons.display.FlxBackdrop;

class PixelStars {
    public var starArray:Array<FunkinBackdrop> = [];

    public var speed:Float = 0;

    /**
     * Creates a set of backdrops filled with a star field, it automatically adds them to the current state
     * @param x The horizontal position of each backdrop
     * @param y The vertical position of each backdrop
     * @param speed The speed the stars travel
     * @param layerAmount How many layers of star fields should there be
     */
    public function new(x:Float, y:Float, speed:Float = -50, layerAmount:Int = 3) {
        super();

        this.speed = speed;

        for (i in 0...layerAmount) {
            var star:FlxBackdrop = new FlxBackdrop(Paths.image("menus/stars"));
            star.scale.set(4 / i, 4 / i);
            star.updateHitbox();
            star.setPosition(x + (60 * i), y + (60 * i));
            star.scrollFactor.set(0, 0);
            star.velocity.x = speed / (i + 1);

            var fuckingEquation:Float = (i * 2) * 0.1;
            var alphaAmount:Float = FlxMath.remapToRange(fuckingEquation, 0, 1, 1, 0);
            star.alpha = alphaAmount;

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