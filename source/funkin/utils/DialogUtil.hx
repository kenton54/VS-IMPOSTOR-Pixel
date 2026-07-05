package funkin.utils;

import haxe.io.Path;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;

#if sys
import sys.FileSystem;
#end

enum abstract SaveFileStatus(String) from String to String
{
	var SUCCESS = 'success';

	var CANCEL = 'cancel';

	var ERROR = 'error';
}

class DialogUtil
{
	/**
	 * Whether any file dialog is open.
	 */
	public static var isDialogOpen(default, null):Bool = false;

	/**
	 * The directory of the application inside the user's file system.
	 */
	public static var gameDirectory(get, never):String;

	static function get_gameDirectory():String
	{
		#if sys
		return FileSystem.fullPath(Path.directory(Sys.programPath()));
		#else
		return '';
		#end
	}

	/**
	 * File filter for files with the `.json` format.
	 */
	public static final FILTER_JSON_FILE:FileFilter = new FileFilter('JSON Data File', '*.json');

	/**
	 * File filter for files with the `.imppixelc` format.
	 */
	public static final FILTER_IMPPIXELC_FILE:FileFilter = new FileFilter('VS IMPOSTOR Pixel Chart', '*.imppixelc');

	/**
	 * Opens the specified folder path in the file explorer.
	 *
	 * @param folder              The path of the folder to open.
	 * @param createIfNotExists   Create the directory if it doesn't exist.
	 */
	public static function openFolder(folder:String, createIfNotExists:Bool = true)
	{
		#if sys
		folder = folder.trim();

		if (createIfNotExists && !FileSystem.exists(folder))
		{
			FileSystem.createDirectory(folder);
		}
		else if (!FileSystem.exists(folder))
		{
			FlxG.log.error("Cannot open a folder that doesn't exist!");
			return;
		}

		#if windows
		Sys.command('explorer', [folder.replace('/', '\\')]);
		#elseif mac
		Sys.command('open', [folder]);
		#elseif linux
		var exitCode:Int = Sys.command('xdg-open', [folder]);
		if (exitCode == 0)
		{
			return;
		}

		for (fileManager in ['dolphin', 'nautilus', 'nemo', 'thunar', 'caja', 'konqueror', 'spacefm', 'pcmanfm'])
		{
			if (Sys.command('which', [fileManager]) == 0)
			{
				exitCode = Sys.command(fileManager, [folder]);
				if (exitCode == 0)
				{
					return;
				}
			}
		}

		FlxG.log.warn('No compatible file manager found for Linux.');
		#end
		#else
		FlxG.log.warn("Platform doesn't support openning folders from the user's file system!");
		#end
	}

	/**
	 * Opens a file dialog requesting a file from the user's file system.
	 *
	 * @param onFile  A function to run when the file gets loaded.
	 * @param filters File formats to filter.
	 */
	public static function browseFile(onFile:FileReference -> Void, ?filters:Array<FileFilter>)
	{
		var fileRef:FileReference = new FileReference();

		fileRef.addEventListener(Event.SELECT, function(refEv:Event)
		{
			var selectFile:FileReference = refEv.target;

			selectFile.addEventListener(Event.COMPLETE, function(fileEv:Event)
			{
				var loadedFile:FileReference = fileEv.target;
				onFile(loadedFile);

				isDialogOpen = false;
			});

			selectFile.load();
		});

		fileRef.browse(filters);

		isDialogOpen = true;
	}

	/**
	 * Saves the specified data to the user's file system as a file.
	 *
	 * @param data      The data to save.
	 * @param filename  The name of the file.
	 * @param onStatus  An optional function to run when the data upload is complete, was cancelled or had an error.
	 */
	public static function saveFile(data:Dynamic, ?filename:String, ?onStatus:SaveFileStatus -> Void)
	{
		var fileRef:FileReference = new FileReference();

		fileRef.addEventListener(Event.COMPLETE, _ ->
		{
			if (onStatus != null)
			{
				onStatus(SUCCESS);
			}

			isDialogOpen = false;
		});

		fileRef.addEventListener(Event.CANCEL, _ ->
		{
			if (onStatus != null)
			{
				onStatus(CANCEL);
			}

			isDialogOpen = false;
		});

		fileRef.addEventListener(IOErrorEvent.IO_ERROR, _ ->
		{
			if (onStatus != null)
			{
				onStatus(ERROR);
			}

			isDialogOpen = false;
		});

		fileRef.save(data, filename);

		isDialogOpen = true;
	}
}
