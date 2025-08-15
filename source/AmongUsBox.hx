import flixel.group.FlxSpriteGroup;

class AmongUsBox {
    public var box:FlxSpriteGroup;

    public var width:Int;
    public var height:Int;

    public function new(x:Float, y:Float, width:Int, height:Int, ?style:String, ?scale:Float) {
        if (style == null) style = "simple";
        if (scale == null) scale = 4;

        box = new FlxSpriteGroup(x, y);

        var topLeftCorner:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/amongusBoxCorner-"+style));
        var startingX:Float = x + topLeftCorner.width * scale;
        var startingY:Float = y + topLeftCorner.height * scale;

        var maxWidth:Int = Std.int(FlxG.width - topLeftCorner.width * scale * 2);
        if (width > maxWidth) width = maxWidth;

        var maxHeight:Int = Std.int(FlxG.height - topLeftCorner.height * scale * 2);
        if (height > maxHeight) height = maxHeight;

        var boxBack:FlxSprite = new FlxSprite(startingX, startingY).makeGraphic(width, height, FlxColor.BLACK);
        box.add(boxBack);

        width = boxBack.width;
        height = boxBack.height;

        topLeftCorner.setPosition(boxBack.x, boxBack.y);
        topLeftCorner.scale.set(scale, scale);
        topLeftCorner.updateHitbox();
        topLeftCorner.x -= topLeftCorner.width;
        topLeftCorner.y -= topLeftCorner.height;
        box.add(topLeftCorner);

        var topRightCorner:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/amongusBoxCorner-"+style));
        topRightCorner.scale.set(scale, scale);
        topRightCorner.updateHitbox();
        topRightCorner.x += boxBack.width;
        topRightCorner.y -= topRightCorner.height;
        topRightCorner.angle = 90;
        box.add(topRightCorner);

        var botLeftCorner:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/amongusBoxCorner-"+style));
        botLeftCorner.scale.set(scale, scale);
        botLeftCorner.updateHitbox();
        botLeftCorner.x -= botLeftCorner.width;
        botLeftCorner.y += boxBack.height;
        botLeftCorner.angle = 270;
        box.add(botLeftCorner);

        var botRightCorner:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/amongusBoxCorner-"+style));
        botRightCorner.scale.set(scale, scale);
        botRightCorner.updateHitbox();
        botRightCorner.x += boxBack.width;
        botRightCorner.y += boxBack.height;
        botRightCorner.angle = 180;
        box.add(botRightCorner);

        var horizontalDistance:Float = FlxMath.distanceBetween(topLeftCorner, topRightCorner) - topRightCorner.width;
        var topBorder:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/amongusBoxTopBorder-"+style));
        var horizontalYScale:Float = topBorder.height * scale;
        topBorder.setGraphicSize(width, horizontalYScale);
        topBorder.updateHitbox();
        topBorder.y -= topBorder.height;
        box.add(topBorder);

        var bottomBorder:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/amongusBoxTopBorder-"+style));
        bottomBorder.setGraphicSize(width, horizontalYScale);
        bottomBorder.updateHitbox();
        bottomBorder.y += boxBack.height;
        bottomBorder.flipY = true;
        box.add(bottomBorder);

        var verticalDistance:Float = FlxMath.distanceBetween(topLeftCorner, botLeftCorner) - botLeftCorner.height;
        var leftBorder:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/amongusBoxSideBorder-"+style));
        var verticalXScale:Float = leftBorder.width * scale;
        leftBorder.setGraphicSize(verticalXScale, height);
        leftBorder.updateHitbox();
        leftBorder.x -= leftBorder.width;
        box.add(leftBorder);

        var rightBorder:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/amongusBoxSideBorder-"+style));
        rightBorder.setGraphicSize(verticalXScale, height);
        rightBorder.updateHitbox();
        rightBorder.x += boxBack.width;
        rightBorder.flipX = true;
        box.add(rightBorder);
    }

    public function destroy() {
        box.destroy();
    }
}