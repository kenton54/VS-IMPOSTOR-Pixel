package funkin.system;

import funkin.data.LanguageData;
import funkin.graphics.FunkinBitmapText;
import funkin.ui.MusicBeatState;

import haxe.Json;

import lime.system.CFFI;

/**
 * This class helps translate the mod to multiple languages.
 */
class Translations
{
	/**
	 * All loaded languages.
	 */
	public static var languages(default, null):Array<LanguageData>;

	/**
	 * The current loaded language.
	 */
	public static var curLanguageID(default, set):String;

	/**
	 * The current loaded language's data.
	 */
	public static var curLanguage(get, never):LanguageData;

	/**
	 * The current loaded language's name.
	 */
	public static var curLanguageName(get, never):String;

	/**
	 * The default language's data.
	 */
	static var defaultLanguage(get, never):LanguageData;

	/**
	 * If the engine somehow fails to load any languages, it falls back to this one.
	 *
	 * Used to prevent crashes.
	 *
	 * It just contains empty data.
	 */
	static var fallbackLanguage(default, null):LanguageData;

	/**
	 * Starts the Translation backend.
	 */
	@:allow(funkin.InitState)
	static function init()
	{
		languages = [];

		fallbackLanguage = new LanguageData('null', 'Unknown', {});

		for (language in Constants.LANGUAGES)
		{
			if (Assets.exists(Paths.impostor('data/languages/$language.json')))
			{
				languages.push(LanguageData.fromFile(Paths.impostor('data/languages/$language.json')));
			}
		}

		curLanguageID = Constants.DEFAULT_LANGUAGE;

		FlxG.signals.focusGained.add(checkSystemLanguage);
		FlxG.signals.postStateSwitch.add(checkSystemLanguage);
	}

	/**
	 * Gets the translation of a text with a translation ID from the current language.
	 *
	 * If it fails, it tries to get it from the default language.
	 *
	 * @param id            The translation ID.
	 * @param parameters    If the text has parameters that can be replaced with values.
	 * @return The translated text.
	 */
	public static function translate(id:String, ?parameters:Array<Dynamic>):String
	{
		if (curLanguage.exists(id))
		{
			return getText(curLanguage, id, parameters);
		}
		else if (defaultLanguage.exists(id))
		{
			return getText(defaultLanguage, id, parameters);
		}

		return id;
	}

	/**
	 * Gets the translation of a text with a translation ID.
	 *
	 * @param language      The language to use, must be the language's data.
	 * @param id            The translation ID.
	 * @param parameters    If the text has parameters that can be replaced with values.
	 * @return The translated text.
	 */
	public static function getText(language:LanguageData, id:String, ?parameters:Array<Dynamic>):String
	{
		var text:String = language.get(id);
		var regex:EReg = ~/{[0-9]}/g;

		var result:String = regex.map(text, function(reg:EReg)
		{
			var match:String = reg.matched(0);
			var matchID:Int = Std.parseInt(match.substr(1, match.lastIndexOf('}')));
			return parameters[matchID];
		});

		return result;
	}

	/**
	 * @return The system's current language in the Language Code format (e.g. `en-US`).
	 */
	public static function getUserLanguage():String
	{
		#if lime_cffi
		#if hl
		return @:privateAccess lime.system.Locale.lime_locale_get_system_locale();
		#else
		return CFFI.load('lime', 'lime_locale_get_system_locale', 0)();
		#end
		#elseif android
		return funkin.external.android.AndroidAPI.getUserLanguage();
		#elseif web
		return js.Browser.navigator.language;
		#else
		return 'en-US';
		#end
	}

	/**
	 * @param language  The language to shorten.
	 * @return The language's codename without its locale.
	 */
	public static function getLanguageShort(language:String):String
	{
		if (language.contains('-'))
		{
			return language.split('-')[0];
		}
		else if (language.contains('_'))
		{
			return language.split('_')[0];
		}
		else
		{
			return language;
		}
	}

	static function getLanguageFromID(langID:String):LanguageData
	{
		for (language in languages)
		{
			if (language.ID == langID)
			{
				return language;
			}
		}

		return null;
	}

	static function languageExists(langID:String):Bool
	{
		return getLanguageFromID(langID) != null;
	}

	static function checkSystemLanguage()
	{
		if (!funkin.data.ClientPreferences.syncSystemLanguage)
		{
			return;
		}

		var userLanguage:String = Translations.getLanguageShort(Translations.getUserLanguage());
		if (userLanguage != Translations.curLanguageID)
		{
			curLanguageID = userLanguage;
		}
	}

	/**
	 * Updates all text objects whenever the language changes.
	 */
	@:access(flixel.group.FlxTypedGroup)
	static function updateLanguage()
	{
		function updateTextObjects(group:FlxGroup)
		{
			for (member in group.members)
			{
				if (Std.isOfType(member, FunkinText))
				{
					var text:FunkinText = cast(member, FunkinText);
					if (text.translationData != null)
					{
						text.text = '';
					}
				}

				if (Std.isOfType(member, FunkinBitmapText))
				{
					var bitmapText:FunkinBitmapText = cast(member, FunkinBitmapText);
					if (bitmapText.translationData != null)
					{
						bitmapText.text = '';
					}
				}

				var group = FlxTypedGroup.resolveGroup(member);
				if (group != null)
				{
					updateTextObjects(group);
				}
			}
		}

		updateTextObjects(FlxG.state);

		if (Std.isOfType(FlxG.state, MusicBeatState))
		{
			cast(FlxG.state, MusicBeatState).onLanguageUpdate(Translations.curLanguageID);
		}
	}

	static function set_curLanguageID(language:String):String
	{
		if (language == curLanguageID)
		{
			return language;
		}

		if (languageExists(language))
		{
			curLanguageID = language;
			updateLanguage();
		}
		else
		{
			curLanguageID = Constants.DEFAULT_LANGUAGE;
			updateLanguage();
		}

		return language;
	}

	static function get_curLanguage():LanguageData
	{
		return getLanguageFromID(curLanguageID) ?? defaultLanguage;
	}

	static function get_curLanguageName():String
	{
		return curLanguage.name;
	}

	static function get_defaultLanguage():LanguageData
	{
		return getLanguageFromID(Constants.DEFAULT_LANGUAGE) ?? fallbackLanguage;
	}
}

typedef TranslationData =
{
	/**
	 * The ID of the translation inside the language data file.
	 */
	var id:String;

	/**
	 * An optional list of parameters that will be concantinated in the string result.
	 *
	 * Replaces the `{n}` inside the ID value with each parameter.
	 */
	var ?parameters:Array<Dynamic>;
}
