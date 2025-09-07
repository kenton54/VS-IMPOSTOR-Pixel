import flixel.util.FlxBaseSignal;

class BackButton extends FunkinSprite {
    /**
     * Triggered when the button gets pressed.
     */
    public var onConfirm:FlxBaseSignal<Void->Void> = new FlxBaseSignal();

    /**
     * Triggered when the button animation finished playing, unless it's instant.
     */
    public var onConfirmEnd:FlxBaseSignal<Void->Void> = new FlxBaseSignal();

    /**
     * If the button fades when it's being hovered or not.
     */
    public var fade:Bool = false;

    /**
     * Whether the button can be interacted
     */
    public var enabled:Bool = true;

    /**
     * If the button ignores the animation when it's pressed.
     */
    public var instant:Bool = false;

    public var restOpacity:Float = 0.3;

    var _isHovering:Bool = false;
    var _isBeingHeld:Bool = false;
    var _confirmed:Bool = false;

    public function new(x:Float, y:Float, confirmCallback:Void->Void, size:Float, ?fade:Bool, ?sprite:String, ?instant:Bool = false, ?color:FlxColor = FlxColor.WHITE) {
        super(x, y);

        size ??= 2;
        fade ??= false;
        color ??= FlxColor.WHITE;
        instant ??= false;

        this.color = color;
        this.fade = fade;
        this.instant = instant;
        this.alpha = fade ? restOpacity : 1;

        loadSprite(Paths.image(sprite == null ? "app/backButton" : sprite));
        addAnim("idle", "idle", 0, false);
        addAnim("hold", "hold", 0, false);
        addAnim("press", "press", FlxG.save.data.impPixelFastMenus ? 48 : 24, false);
        playAnim("idle");

        this.scale.set(size, size);
        updateHitbox();

        onConfirmEnd.add(confirmCallback);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (visible) {
            var isOverlapping:Bool = checkHover();

            if (isOverlapping) {
                if (!_isHovering)
                    hoverButton();
                else {
                    if (_isBeingHeld) {
                        if (touchJustReleased())
                            confirmButton();
                    }

                    if (touchIsHolding()) {
                        if (!_isBeingHeld)
                            holdButton();
                    }
                    else {
                        if (_isBeingHeld)
                            unholdButton();
                    }
                }
            }
            else {
                if (_isHovering) unhoverButton();
                if (_isBeingHeld) unholdButton();
            }
        }
    }

    function checkHover():Bool {
        for (camera in cameras) {
            final worldPoint:FlxPoint = getTouch().getWorldPosition(camera);

            if (overlapsPoint(worldPoint)) {
                return true;
            }
        }

        return false;
    }

    function hoverButton() {
        if (_confirmed || _isBeingHeld || !enabled) return;

        _isHovering = true;

        playAnim("idle");

        if (fade) {
            FlxTween.cancelTweensOf(this);
            FlxTween.tween(this, {alpha: 1}, 0.5, {ease: FlxEase.expoOut});
        }
    }

    function unhoverButton() {
        if (_confirmed || !enabled) return;

        _isHovering = false;

        playAnim("idle");

        if (fade) {
            FlxTween.cancelTweensOf(this);
            FlxTween.tween(this, {alpha: restOpacity}, 0.5, {ease: FlxEase.expoOut});
        }
    }

    function holdButton() {
        if (_confirmed || !enabled) return;

        _isBeingHeld = true;

        playAnim("hold");

        FlxTween.cancelTweensOf(this);
        alpha = 1;
    }

    function unholdButton() {
        if (_confirmed || !enabled) return;

        _isBeingHeld = false;

        playAnim("idle");
    }

    function confirmButton() {
        if (!enabled) return;

        if (instant) {
            _confirmed = true;
            enabled = false;

            dispatchSignal(onConfirmEnd);
            return;
        }
        else if (_confirmed) return;

        _confirmed = true;
        enabled = false;

        FlxTween.cancelTweensOf(this);
        playAnim("press");
        alpha = 1;

        playMenuSound("cancel");

        dispatchSignal(onConfirm);

        //vibrateDevice(0.1, 0.5);

        animation.onFinish.add(function(name:String) {
            if (name != "press") return;
            dispatchSignal(onConfirmEnd);
        });
    }

    override public function destroy() {
        super.destroy();

        onConfirm.removeAll();
        onConfirmEnd.removeAll();

        if (animation != null && animation.onFinish != null) animation.onFinish.removeAll();
    }
}