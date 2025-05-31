import sys.FileSystem;
import haxe.io.Path;

class PlayableData {
    /**
     * The name of the character
     */
    public var id:String = "unknown";

    /**
     * The readable name of the character
     */
    public var name:String = "Unknown";

    /**
     * The character's ID list this playable owns
     */
    public var ownedChars:Array<String> = [];

    /**
     * Whether the character is unlocked or not
     */
    public var unlocked:Bool = false;

    /**
     * Whether it should show songs that this character isn't associated with
     * For example Boyfriend
     */
    public var showUnownedChars:Bool = true;

    /**
     * What freeplay style corresponds to the character
     */
    public var freeplayStyle:String = "bf";

    public var suffix:String = "";

    /**
     * Retrieves the specified character's data
     * @param character The character to load the data from
     */
    public function new(character:String) {
        var data:Array<Dynamic> = {};
        if (Assets.exists(Paths.json("playables/" + character)))
            data = Json.parse(Assets.getText(Paths.json("playables/" + character)));
        else {
            throw "Cannot fetch character data with this value [" + character + "]! Does the file exist?";
            return;
        }

        if (data.length < 1) {
            throw "This character data is empty!";
        }

        this.id = new Path(FileSystem.fullPath(Assets.getPath(Paths.json("playables/" + character)))).file ?? "unknown";
        this.name = data.name ?? "Unknown";
        this.ownedChars = data.ownedChars == [];
        this.unlocked = data.unlocked ?? false;
        this.showUnownedChars = data.showUnownedChars ?? true;
        this.freeplayStyle = data.freeplayStyle ?? "bf";
        this.suffix = data.suffix ?? "";
    }

    public function shouldShowUnownedChars():Bool {
        return showUnownedChars ?? false;
    }

    public function hasCharacter(id:String):Bool {
        if (ownedChars.contains(id)) {
            return true;
        }
        return false;
    }

    public function getSongName(songName:String):String {
        if (suffix != "" && suffix.length > 0) {
            return songName + "-" + suffix;
        }
        return songName;
    }

    public function getCharInst(inst:String):String {
        if (id != "" && id.length > 0) {
            return inst + "-" + id;
        }
        return inst;
    }

    public function buildDataFile(data:Array<Dynamic>) {
    }
}