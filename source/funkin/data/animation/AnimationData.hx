package funkin.data.animation;

typedef AnimationData =
{
	/**
	 * The name of the animation.
	 */
	var name:String;

	/**
	 * The type of animation.
	 *
	 * Changes how the animation is loaded.
	 */
	var type:AnimationType;

	/**
	 * The prefix of the name of the frames.
	 *
	 * Optional only when `type` is set to `tiled`.
	 */
	@:optional
	var prefix:String;

	/**
	 * The frame rate of the animation.
	 *
	 * In other words, how many frames to play of the animation in 1 second.
	 */
	@:default(24)
	var frameRate:Float;

	/**
	 * Whether to loop the animation.
	 */
	@:optional
	@:default(false)
	var loop:Bool;

	/**
	 * The offsets of the animation.
	 */
	@:optional
	@:default([0, 0])
	var offsets:Array<Float>;

	/**
	 * The frames of the animation to play.
	 *
	 * Mandatory when `type` is set to `tiled`.
	 */
	@:optional
	@:default([])
	var frameIndices:Array<Int>;

	/**
	 * Whether to flip the animation horizontally.
	 */
	@:optional
	@:default(false)
	var flipX:Bool;

	/**
	 * Whether to flip the animation vertically.
	 */
	@:optional
	@:default(false)
	var flipY:Bool;
}

enum abstract AnimationType(String) from String to String
{
	var TILED:String = 'tiled';

	var SPARROW:String = 'sparrow';

	var ASEPRITE:String = 'aseprite';

	var PACKER:String = 'packer';

	var ANIMATE_ATLAS:String = 'animateatlas';
}
