package;

import haxe.Json;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

class Setup
{
	public static function main()
	{
		if (!FileSystem.exists('.haxelib'))
		{
			FileSystem.createDirectory('.haxelib');
		}

    final libraries:Array<Library> = Json.parse(File.getContent('./hmm.json')).dependencies;

		Sys.println('Installing libraries...');

		for (library in libraries)
		{
			var arguments:String = '--never --skip-dependencies --quiet';

			switch (library.type)
			{
				case haxelib:
					var version:String = (library.version != null ? library.version : '') + ' ';
					Sys.println('Installing library "${library.name}" ${version != '' ? 'Version $version ' : ''}');
					Sys.command('haxelib install ${library.name} ${version}${arguments}');

				case git:
					var branch:String = (library.ref != null ? library.ref : '') + ' ';
					Sys.println('Installing library "${library.name}" from git URL "${library.url}" ${branch != '' ? 'branch "$branch" ' : ''}');
					Sys.command('haxelib git ${library.name} ${library.url} ${branch}${arguments}');

				case mercurial:
          var branch:String = (library.ref != null ? library.ref : '') + ' ';
					Sys.command('haxelib hg ${library.name} ${library.url} ${branch}${arguments}');

				case dev:
					Sys.command('haxelib dev ${library.name} "${library.path}"');
			}
		}

    /*
		if (checkVisualStudio && getSystem() == 'windows')
		{
			Sys.println('Checking for Visual Studio... (Required dependency for Windows)');

			if (!hasVisualStudioInstalled())
			{
				Sys.println('Installing Visual Studio...');

				Sys.command('curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe');
				Sys.command('vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p');
				FileSystem.deleteFile('vs_Community.exe');

				Sys.println('Installed Visual Studio successfully!');
			}
			else
			{
				Sys.println('You already have Visual Studio installed!');
			}
		}
    */
	}

	static function checkHaxeVersion(minimum:String):Bool
	{
		final process:Process = new Process('haxe', ['--version']);
		final haxeVersion:String = process.stdout.readLine();
		process.exitCode(true);

		final installedVersion:Array<Int> = [for (version in haxeVersion.split('.')) Std.parseInt(version)];
		final minimumVersion:Array<Int> = [for (version in minimum.split('.')) Std.parseInt(version)];

		for (i in 0...minimumVersion.length)
		{
			if (installedVersion[i] > minimumVersion[i])
			{
				return true;
			}
		}

		return false;
	}
}

class Arguments
{
	public var length(get, never):Int;

	var arguments:Array<String> = [];

	public function new(args:Array<String>)
	{
		for (rawArg in args)
		{
			if (rawArg.startsWith('-'))
			{
				var argument:String = rawArg.substr(0, 1);

				if (argument.startsWith('-'))
				{
					argument = argument.substr(0, 1);
				}

				arguments.push(argument);
			}
		}
	}

	public function exists(arg:String):Bool
	{
		return arguments.indexOf(arg) >= 0;
	}

	public function getArgument(index:Int):String
	{
		return arguments[index];
	}

	public function getArgumentIndex(argument:String):Int
	{
		return arguments.indexOf(argument);
	}

	function get_length():Int
	{
		return arguments.length;
	}
}

typedef Library =
{
	/**
	 * The name of the library in haxelib.
	 */
	var name:String;

	/**
	 * The way the library will install, through `haxelib`, `git`, `mercurial` or through a custom library (set as `dev`).
	 */
	var type:LibraryType;

	/**
	 * The version of the library to install, Must be set if the type is set to `haxelib`.
	 */
	var ?version:String;

	/**
	 * The directory name where the source of the library resides in, can be left as `null`, used in `git` or `mercurial`.
	 */
	var ?dir:String;

	/**
	 * The branch of the repository to reference, Must be set if the type is set to `git` or `mercurial`.
	 */
	var ?ref:String;

	/**
	 * The URL of the repository to clone, Must be set if the type is set to `git` or `mercurial`.
	 */
	var ?url:String;

	/**
	 * The path to the repository to set as a haxe library. Must be set if the type is set to `dev`.
	 */
	var ?path:String;
}

enum abstract LibraryType(String)
{
	var haxelib;

	var git;

	var mercurial;

	var dev;
}
