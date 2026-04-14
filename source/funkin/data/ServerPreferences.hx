package funkin.data;

import funkin.system.FunkinSave;

class ServerPreferences
{
	/**
	 * The last IP Adress the user used.
	 *
	 * For quick connectivity.
	 */
	public static var ipAdress(get, set):String;

	/**
	 * The last port the user used.
	 *
	 * For quick connectivity.
	 */
	public static var port(get, set):Int;

	/**
	 * The user's nickname.
	 */
	public static var nickname(get, set):String;

	static function get_ipAdress():String
	{
		return FunkinSave.serverPreferences?.ipAdress ?? '127.0.0.1';
	}

	static function set_ipAdress(value:String):String
	{
		FunkinSave.serverPreferences.ipAdress = value;
		FunkinSave.flush();
		return value;
	}

	static function get_port():Int
	{
		return FunkinSave.serverPreferences?.port ?? 3000;
	}

	static function set_port(value:Int):Int
	{
		FunkinSave.serverPreferences.port = value.clamp(1024, 65535);
		FunkinSave.flush();
		return value;
	}

	static function get_nickname():String
	{
		return FunkinSave.serverPreferences?.nickname ?? 'player';
	}

	static function set_nickname(value:String):String
	{
		FunkinSave.serverPreferences.nickname = value;
		FunkinSave.flush();
		return value;
	}
}
