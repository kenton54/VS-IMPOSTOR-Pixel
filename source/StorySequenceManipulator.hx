import funkin.backend.system.framerate.Framerate;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

class ImpostorStorySequence {
    public var sprite:Sprite

    private var title:TextField;
    private var bgSprite:Bitmap;

    private var daListener:Void;

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

        daListener = toggler;

        FlxG.stage.addEventListener("keyUp", daListener);
    }

    private static function toggler(event:KeyboardEvent) {
        if (event.keyCode == 115) { // F4
            trace("new boo");
        }
    }

    private var debugAlpha:Float = 0;
    public override function __enterFrame(t:Int) {
        //alpha = CoolUtil.fpsLerp(alpha, Framerate.debugMode > 0 ? 1 : 0, 0.5);
		//debugAlpha = CoolUtil.fpsLerp(debugAlpha, Framerate.debugMode > 1 ? 1 : 0, 0.5);

        /*
		_text = 'Current Song Position: ${Math.floor(Conductor.songPosition * 1000) / 1000}';
		_text += '\n - ${Conductor.curBeat} beats';
		_text += '\n - ${Conductor.curStep} steps';
		_text += '\n - ${Conductor.curMeasure} measures';
		_text += '\nCurrent BPM: ${Conductor.bpm}';
		_text += '\nTime Signature: ${Conductor.beatsPerMeasure}/${Conductor.stepsPerBeat}';

		this.text.text = _text;
        */
		super.__enterFrame(t);
	}

    public function destroy() {
        title = null;
        bgSprite = null;
        sprite = null;
        FlxG.stage.removeEventListener("keyUp", daListener);
        trace("Ended StorySequenceManipulator debug tool");
    }
}