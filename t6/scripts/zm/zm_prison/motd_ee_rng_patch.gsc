#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zm_alcatraz_sq;
#include maps\mp\zm_alcatraz_sq_nixie;
#include maps\mp\zombies\_zm_ai_brutus;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_utility;

main()
{
	if ( maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		replaceFunc( maps\mp\zombies\_zm_powerups::powerup_drop, ::powerup_drop );
		replaceFunc( maps\mp\zm_alcatraz_sq::setup_master_key, ::setup_master_key );
		replaceFunc( maps\mp\zm_alcatraz_sq_nixie::generate_unrestricted_nixie_tube_solution, ::generate_unrestricted_nixie_tube_solution );
		replaceFunc( maps\mp\zombies\_zm_ai_brutus::brutus_death, ::brutus_death );
	}
}

init()
{
	if ( maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		level.struct_class_names["targetname"]["infirmary_player_spawn"] = array( getStructArray( "infirmary_player_spawn", "targetname" )[3] );
		thread onPlayerConnect();
		thread first_round_powerups_patch();
	}
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread display_mod_message();
	}
}

display_mod_message()
{
	self endon( "disconnect" );
	flag_wait( "initial_players_connected" );
	self iprintln( "Script ''motd_ee_rng_patch.gsc'' loaded successfully" );
}

first_round_powerups_patch()
{
	// level.zombie_vars["zombie_powerup_drop_max_per_round"] -= 1;
	arrayremovevalue( level.zombie_powerup_array, "double_points" );
	arrayinsert( level.zombie_powerup_array, "double_points", level.zombie_powerup_index );
	arrayremovevalue( level.zombie_powerup_array, "full_ammo" );
	arrayinsert( level.zombie_powerup_array, "full_ammo", level.zombie_powerup_index + 1 );
	arrayremovevalue( level.zombie_powerup_array, "nuke" );
	arrayinsert( level.zombie_powerup_array, "nuke", level.zombie_powerup_index + 2 );
	level.zombie_vars["zombie_drop_item"] = true;
	flag_wait( "initial_blackscreen_passed" );
	wait 1;
	level waittill( "powerup_dropped" );
	level waittill( "powerup_dropped" );
	level endon( "powerup_dropped" );

	do
		level waittill( "zom_kill" );
	while ( get_current_zombie_count() > 0 || level.zombie_total > 0 );

	// level.zombie_vars["zombie_powerup_drop_max_per_round"] += 1;
	// arrayremovevalue( level.zombie_powerup_array, "nuke" );
	// arrayinsert( level.zombie_powerup_array, "nuke", level.zombie_powerup_index );
	level.zombie_vars["zombie_drop_item"] = true;
}

powerup_drop( drop_point )
{
	if ( level.powerup_drop_count >= level.zombie_vars["zombie_powerup_drop_max_per_round"] )
	{
/#
		println( "^3POWERUP DROP EXCEEDED THE MAX PER ROUND!" );
#/
		return;
	}

	if ( !isdefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size == 0 )
		return;

	rand_drop = 3; // randomint( 100 );

	if ( rand_drop > 2 )
	{
		if ( !level.zombie_vars["zombie_drop_item"] )
			return;

		debug = "score";
	}
	else
		debug = "random";

	playable_area = getentarray( "player_volume", "script_noteworthy" );
	level.powerup_drop_count++;
	powerup = maps\mp\zombies\_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + vectorscale( ( 0, 0, 1 ), 40.0 ) );
	valid_drop = 0;

	for ( i = 0; i < playable_area.size; i++ )
	{
		if ( powerup istouching( playable_area[i] ) )
			valid_drop = 1;
	}

	if ( valid_drop && level.rare_powerups_active )
	{
		pos = ( drop_point[0], drop_point[1], drop_point[2] + 42 );

		if ( check_for_rare_drop_override( pos ) )
		{
			level.zombie_vars["zombie_drop_item"] = 0;
			valid_drop = 0;
		}
	}

	if ( !valid_drop )
	{
		level.powerup_drop_count--;
		powerup delete();
		return;
	}

	powerup powerup_setup();
	print_powerup_drop( powerup.powerup_name, debug );
	powerup thread powerup_timeout();
	powerup thread powerup_wobble();
	powerup thread powerup_grab();
	powerup thread powerup_move();
	powerup thread powerup_emp();
	level.zombie_vars["zombie_drop_item"] = 0;
	level notify( "powerup_dropped", powerup );
}

setup_master_key()
{
	level.is_master_key_west = 0; // 0 = cafe, 1 = warden
	setclientfield( "fake_master_key", level.is_master_key_west + 1 );

	if ( level.is_master_key_west )
	{
		level thread key_pulley( "west" );
		exploder( 101 );
		array_delete( getentarray( "wires_pulley_east", "script_noteworthy" ) );
	}
	else
	{
		level thread key_pulley( "east" );
		exploder( 100 );
		array_delete( getentarray( "wires_pulley_west", "script_noteworthy" ) );
	}
}

generate_unrestricted_nixie_tube_solution()
{
	level.a_nixie_tube_solution[1] = 0;
	level.a_nixie_tube_solution[2] = 1;
	level.a_nixie_tube_solution[3] = 2;
}

brutus_death()
{
	self endon( "brutus_cleanup" );
	self thread brutus_cleanup();

	if ( level.brutus_in_grief )
		self thread brutus_cleanup_at_end_of_grief_round();

	self waittill( "death" );
	self thread sndbrutusvox( "vox_brutus_brutus_defeated" );
	level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "brutus_death" );
	level.brutus_count--;
	playfx( level._effect["brutus_death"], self.origin );
	playsoundatposition( "zmb_ai_brutus_death", self.origin );

	if ( get_current_zombie_count() == 0 && level.zombie_total == 0 )
	{
		level.last_brutus_origin = self.origin;
		level notify( "last_brutus_down" );

		if ( isdefined( self.brutus_round_spawn_failsafe ) && self.brutus_round_spawn_failsafe )
			level.next_brutus_round = level.round_number + 1;
	}
	else if ( isdefined( self.brutus_round_spawn_failsafe ) && self.brutus_round_spawn_failsafe )
	{
		level.zombie_total++;
		level.zombie_total_subtract++;
		level thread brutus_round_spawn_failsafe_respawn();
	}

	if ( !( isdefined( self.suppress_brutus_powerup_drop ) && self.suppress_brutus_powerup_drop ) )
	{
		if ( !( isdefined( level.global_brutus_powerup_prevention ) && level.global_brutus_powerup_prevention ) )
		{
			if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_golden_gate_bridge" ) )
			{
				level.global_brutus_powerup_prevention = 1;
				level.zombie_powerup_ape = "insta_kill";
			}

			if ( level.powerup_drop_count >= level.zombie_vars["zombie_powerup_drop_max_per_round"] )
				level.powerup_drop_count = level.zombie_vars["zombie_powerup_drop_max_per_round"] - 1;

			level.zombie_vars["zombie_drop_item"] = 1;
			level thread maps\mp\zombies\_zm_powerups::powerup_drop( self.origin );
		}
	}

	if ( isplayer( self.attacker ) )
	{
		event = "death";

		if ( issubstr( self.damageweapon, "knife_ballistic_" ) )
			event = "ballistic_knife_death";

		self.attacker thread do_player_general_vox( "general", "brutus_killed", 20, 20 );

		if ( level.brutus_in_grief )
		{
			team_points = level.brutus_team_points_for_death;
			player_points = level.brutus_player_points_for_death;
			a_players = getplayers( self.team );
		}
		else
		{
			multiplier = maps\mp\zombies\_zm_score::get_points_multiplier( self );
			team_points = multiplier * round_up_score( level.brutus_team_points_for_death, 5 );
			player_points = multiplier * round_up_score( level.brutus_player_points_for_death, 5 );
			a_players = getplayers();
		}

		foreach ( player in a_players )
		{
			if ( !is_player_valid( player ) )
				continue;

			player add_to_player_score( team_points );

			if ( player == self.attacker )
			{
				player add_to_player_score( player_points );
				level notify( "brutus_killed", player );
			}

			player.pers["score"] = player.score;
			player maps\mp\zombies\_zm_stats::increment_client_stat( "prison_brutus_killed", 0 );
		}
	}

	self notify( "brutus_cleanup" );
}
