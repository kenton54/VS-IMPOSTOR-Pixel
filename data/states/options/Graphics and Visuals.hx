import funkin.options.Options;

var options:Array<Dynamic> = [
    {
        name: "Framerate",
        description: "Pretty self explanatory, isn't it?",
        type: "integer",
        min: 30,
        max: 300,
        change: 10,
        savevar: "framerate",
        savepoint: Options
    },
    {
        name: "Colored Health Bar",
        description: "If unchecked, the game will use the orginal red and green health bar from the Base Game (also known as V-Slice).",
        type: "bool",
        savevar: "colorHealthBar",
        savepoint: Options
    },
    {
        name: "Intensive Shaders",
        description: 'If checked, songs that use shaders that have more impact on the framerate will be loaded.\nLeave unchecked for a smoother experience.',
        type: "bool",
        savevar: "gameplayShaders",
        savepoint: Options
    },
    {
        name: "Flashing Lights",
        description: 'If unchecked, will make flashes less "flashy".\nLeave unchecked if you\'re sentitive to these.',
        type: "bool",
        savevar: "flashingMenu",
        savepoint: Options
    },
    {
        name: "Low Memory Mode",
        description: "If checked, will reduce the amount of detail each part of the mod has to reduce memory usage.",
        type: "bool",
        savevar: "lowMemoryMode",
        savepoint: Options
    },
    {
        name: "GPU Sprite Storing",
        description: "If checked, will store loaded bitmaps (or more known as sprites) in the GPU, heavily reducing memory usage.",
        type: "bool",
        savevar: "gpuOnlyBitmaps",
        savepoint: Options
    },
    {
        name: "Freeze Game on Unfocus",
        description: FlxG.onMobile ? "If checked, opening the notification bar will freeze the game until you come back." : "If checked, going to another window will freeze the game until you come back.",
        type: "bool",
        savevar: "autoPause",
        savepoint: Options
    }
];