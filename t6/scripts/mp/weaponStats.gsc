// IMPORTANT NOTES
//
// Reticles: in order to unlock optic reticles, the optic needs to be equipped on
// a weapon that has it unlocked. Additionally, upon loading in, you would need to aim down sight.
//
// Camos: in order to unlock a weapon camo, the weapon needs to be unlocked/purchased.
//
// This script will generate a "weaponStats.txt" file containing entries for all weapons with the generic structure of
// how the data must be entered.
// Open that file and change the 0 to whichever value you wish the value of the stat to increase by.
// e.g. if headshots in-game is 10 and you want it to go to 200, go to weaponStats.txt and change the 0 to 190 or more.
//
// The default path of weaponStats.txt is as follows:
// "%localappdata%\Plutonium\storage\t6\raw\scriptdata\weaponStats.txt"
// or if you have a fs_game mod loaded, then it would go to this directory instead
// "%localappdata%\Plutonium\storage\t6\mods\MODNAME\scriptdata\weaponStats.txt"
//
// In order for the script to work, start a match using these commands while in the main lobby:
// "set increaseWeaponStats on; xstartpartyhost; wait 500; xpartygo"

init()
{
	maps\mp\_utility::set_dvar_if_unset( "increaseWeaponStats", "off" );
	thread onPlayerConnect();
}

onPlayerConnect()
{
	level waittill( "connected", player );

	if ( getDvarInt( "scr_allowFileIo" ) )
	{
		if ( player isHost() )
		{
			player thread weaponStats();
		}
	}
	else
	{
		assertMsg( "Unable to write weaponStats file because scr_allowFileIo is disabled" );
	}
}

weaponStats()
{
	self endon( "disconnect" );

	if ( !fs_testFile( "weaponStats.txt" ) )
	{
		file = fs_fopen( "weaponStats.txt", "write" );
		//reticles
		fs_writeLine( file, "mk48_mp+reflex;attachment" );
		fs_writeLine( file, "kills"                   + " = 0" );
		fs_writeLine( file, "headshots"               + " = 0" );
		fs_writeLine( file, "multikill_2"             + " = 0" );
		fs_writeLine( file, "longshot_kill"           + " = 0" );
		fs_writeLine( file, "killstreak_5_attachment" + " = 0" );
		fs_writeLine( file, "" );
		fs_writeLine( file, "mk48_mp+acog;attachment" );
		fs_writeLine( file, "kills"                   + " = 0" );
		fs_writeLine( file, "headshots"               + " = 0" );
		fs_writeLine( file, "multikill_2"             + " = 0" );
		fs_writeLine( file, "longshot_kill"           + " = 0" );
		fs_writeLine( file, "killstreak_5_attachment" + " = 0" );
		fs_writeLine( file, "" );
		fs_writeLine( file, "mk48_mp+holo;attachment" );
		fs_writeLine( file, "kills"                   + " = 0" );
		fs_writeLine( file, "headshots"               + " = 0" );
		fs_writeLine( file, "multikill_2"             + " = 0" );
		fs_writeLine( file, "longshot_kill"           + " = 0" );
		fs_writeLine( file, "killstreak_5_attachment" + " = 0" );
		fs_writeLine( file, "" );
		fs_writeLine( file, "mk48_mp+dualoptic;attachment" );
		fs_writeLine( file, "kills"                   + " = 0" );
		fs_writeLine( file, "headshots"               + " = 0" );
		fs_writeLine( file, "multikill_2"             + " = 0" );
		fs_writeLine( file, "longshot_kill"           + " = 0" );
		fs_writeLine( file, "killstreak_5_attachment" + " = 0" );
		fs_writeLine( file, "" );
		//weapons
		keys = getArrayKeys( level.tbl_weaponids );

		for ( j = keys.size - 1; j >= 0; j-- )
		{
			i = keys[j];

			if ( !isdefined( level.tbl_weaponids[i] ) || level.tbl_weaponids[i]["group"] == "" || level.tbl_weaponids[i]["reference"] == "" || level.tbl_weaponids[i]["reference"] == "weapon_null" )
			{
				continue;
			}

			switch ( level.tbl_weaponids[i]["group"] )
			{
				case "weapon_cqb":
					statName = "kill_enemy_one_bullet_shotgun";
					break;
				case "weapon_sniper":
					statName = "kill_enemy_one_bullet_sniper";
					break;
				case "weapon_launcher":
					if ( level.tbl_weaponids[i]["reference"] != "usrpg" )
					{
						statName = "destroyed_aircraft";
						break;
					}

				//"usrpg" is kills
				case "weapon_special":
					statName =  ( level.tbl_weaponids[i]["reference"] == "knife_ballistic" ) ? "ballistic_knife_kill" : "kills";
					break;
				case "weapon_pistol":
				case "weapon_smg":
				case "weapon_assault":
				case "weapon_lmg":
					statName = "headshots";
					break;
				default:
					continue;
			}

			fs_writeLine( file, level.tbl_weaponids[i]["reference"] + "_mp" );
			fs_writeLine( file, statName + " = 0" );

			switch ( level.tbl_weaponids[i]["group"] )
			{
				case "weapon_launcher":
					if ( level.tbl_weaponids[i]["reference"] == "fhj18" )
					{
						string1 = "destroyed_aircraft_under20s";
						string2 = "destroyed_5_aircraft";
						string3 = "destroyed_2aircraft_quickly";
						string4 = "destroyed_controlled_killstreak";
						string5 = "destroyed_aitank";
					}
					else
					{
						string1 = "direct_hit_kills";
						string3 = "kills_from_cars";
						string4 = "multikill_2";

						if ( level.tbl_weaponids[i]["reference"] == "usrpg" )
						{
							string2 = "destroyed_aircraft";
							string5 = "multikill_3";
						}
						else if ( level.tbl_weaponids[i]["reference"] == "smaw" )
						{
							string2 = "destroyed_5_aircraft";
							string5 = "destroyed_qrdrone";
						}
					}

					break;
				case "weapon_special":
					switch ( level.tbl_weaponids[i]["reference"] )
					{
						case "riotshield":
							string1 = "score_from_blocked_damage";
							string2 = "shield_melee_while_enemy_shooting";
							string3 = "hatchet_kill_with_shield_equiped";
							string4 = "noPerkKills";
							string5 = "noLethalKills";
							break;
						case "knife_ballistic":
							string1 = "revenge_kill";
							string2 = "kill_retrieved_blade";
							string3 = "ballistic_knife_melee";
							string4 = "multikill_2";
							string5 = "killstreak_5";
							break;
						case "crossbow":
							string1 = "multikill_2";
							string2 = "revenge_kill";
							string3 = "kills_from_cars";
							string4 = "killstreak_5";
							string5 = "crossbow_kill_clip";
							break;
						case "knife_held":
							string1 = "backstabber_kill";
							string2 = "kill_enemy_when_injured";
							string3 = "revenge_kill";
							string4 = "kill_enemy_with_their_weapon";
							string5 = "killstreak_5";
							break;
					}

					break;
				case "weapon_pistol":
				case "weapon_smg":
				case "weapon_cqb":
				case "weapon_assault":
				case "weapon_lmg":
				case "weapon_sniper":
					string1 = ( level.tbl_weaponids[i]["group"] == "weapon_pistol" || level.tbl_weaponids[i]["group"] == "weapon_smg" || level.tbl_weaponids[i]["group"] == "weapon_cqb" ) ? "revenge_kill" : "longshot_kill";
					string2 = "noAttKills";
					string3 = "noPerkKills";
					string4 = "multikill_2";
					string5 = "killstreak_5";
					break;
			}

			fs_writeLine( file, "CARBON;"   + string1 + " = 0" );
			fs_writeLine( file, "BLOSSOM;"  + string2 + " = 0" );
			fs_writeLine( file, "ARTOFWAR;" + string3 + " = 0" );
			fs_writeLine( file, "RONIN;"    + string4 + " = 0" );
			fs_writeLine( file, "SKULLS;"   + string5 + " = 0" );
			fs_writeLine( file, "" );
		}

		fs_fclose( file );
	}

	while ( level.inprematchperiod )
	{
		wait 1;
	}

	if ( getDvar( "increaseWeaponStats" ) != "off" )
	{
		file = fs_fopen( "weaponStats.txt", "read" );

		for ( line = fs_readLine( file ); isdefined( line ); line = fs_readLine( file ) )
		{
			weapon = strTok( line, ";" );

			for ( i = ( isdefined( weapon[1] ) && weapon[1] == "attachment" ) ? 1 : 0; i < 6; i++ )
			{
				data = strTok( fs_readLine( file ), " = " );

				if ( !isdefined( weapon[1] ) || weapon[1] != "attachment" || self adsButtonPressed() )
				{ 
					if ( isSubStr( data[0], ";" ) )
					{
						data[0] = strTok( data[0], ";" )[1];
					}

					self addWeaponStat( weapon[0], data[0], int( data[1] ) );
				}
			}

			line = fs_readLine( file );
			wait 0.05;
		}

		fs_fclose( file );
		setDvar( "increaseWeaponStats", "off" );
	}
}
