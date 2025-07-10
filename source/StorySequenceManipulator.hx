import funkin.backend.system.framerate.Framerate;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;
import openfl.Lib;

class ImpostorStorySequence {
    public var sprite:Sprite

    private var title:TextField;
    private var bgSprite:Bitmap;

    public function new() {
        sprite = new Sprite();

        bgSprite = new Bitmap(new BitmapData(1, 1, 0xFF000000));
		bgSprite.alpha = 0.5;
		sprite.addChild(bgSprite);

        title = new TextField();
        title.defaultTextFormat = new TextFormat("Consolas", 18);
        title.selectable = title.multiline = title.wordWrap = false;
        title.text = "IMPOSTOR Pixel Story Sequence";
        sprite.addChild(title);

        FlxG.stage.addEventListener("keyUp", toolToggler);
        FlxG.stage.addEventListener("enterFrame", onEnterFrame);
    }

    private function toolToggler(event:KeyboardEvent) {
        if (event.keyCode == 115) { // F4
            trace("new boo");
        }
    }

    private var _lastTime:Int = 0;
    private function onEnterFrame(event:Event) {
        var time:Int = Lib.getTimer();
        var delta:Int = time - _lastTime;
        _lastTime = time;
	}

    public function destroy() {
        title = null;
        bgSprite = null;
        sprite = null;
        FlxG.stage.removeEventListener("keyUp", toolToggler);
        FlxG.stage.removeEventListener("enterFrame", onEnterFrame);
        trace("Ended StorySequenceManipulator debug tool");
    }
}