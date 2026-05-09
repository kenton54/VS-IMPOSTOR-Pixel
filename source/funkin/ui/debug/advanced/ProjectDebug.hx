package funkin.ui.debug.advanced;

import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * Shows information about the mod.
 */
class ProjectDebug extends DebugCategory
{
	var projectTitle:TextField;

	var projectInfo:TextField;

	public function new(backgroundColor:Int)
	{
		super(null, 472, 62, backgroundColor, TOP_RIGHT);

		projectInfo = createTextField();
		projectInfo.y = 38;
		addChild(projectInfo);

		projectTitle = new TextField();
		projectTitle.x = 8;
		projectTitle.y = 2;
		projectTitle.width = overlayWidth - 16;
		projectTitle.height = overlayHeight;
		projectTitle.selectable = false;
		projectTitle.mouseEnabled = false;
		projectTitle.defaultTextFormat = new TextFormat(Constants.DEFAULT_FONT, 28, 0xFFFFFF, null, null, null, null, null, getTextAlignFromCategoryAlignment());
		projectTitle.text = '${Constants.TITLE} - ${Constants.VERSION}';
		addChild(projectTitle);

		/*
			final modStuff:Array<String> = [];

			projectInfo.text = modStuff.join('\n');
		 */
	}
}
