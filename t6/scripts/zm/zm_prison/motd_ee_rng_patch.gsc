#include common_scrips\utility;
#include maps\mp\_utility;
#include maps\mp\zm_alcatraz_sq;
#include maps\mp\zm_alcatraz_sq_nixie;
#include maps\mp\zombies\_zm_ai_brutus;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_utility;

main()
{
	if ( maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		replaceFunc( maps\mp\zm_alcatraz_sq::setup_master_key, ::setup_master_key );
		replaceFunc( maps\mp\zm_alcatraz_sq_nixie::generate_unrestricted_nixie_tube_solution, ::generate_unrestricted_nixie_tube_solution );
		replaceFunc( maps\mp\zombies\_zm_ai_brutus::brutus_death, ::brutus_death );
	}
}

init()
{
	if ( maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
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
	level.zombie_vars["zombie_powerup_drop_max_per_round"] -= 1;
	arrayremovevalue( level.zombie_powerup_array, "nuke" );
	arrayinsert( level.zombie_powerup_array, "nuke", level.zombie_powerup_array.size );
	arrayremovevalue( level.zombie_powerup_array, "double_points" );
	arrayinsert( level.zombie_powerup_array, "double_points", level.zombie_powerup_index );
	level.zombie_vars["zombie_drop_item"] = true;

	do
		level waittill( "zom_kill" );
	while ( get_current_zombie_count() > 0 || level.zombie_total > 0 );

	level.zombie_vars["zombie_powerup_drop_max_per_round"] += 1;
	arrayremovevalue( level.zombie_powerup_array, "nuke" );
	arrayinsert( level.zombie_powerup_array, "nuke", level.zombie_powerup_index );
	level.zombie_vars["zombie_drop_item"] = true;
}

setup_master_key()
{
	level.is_master_key_west = 0; // randomintrange( 0, 2 );
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
	a_restricted_solutions = [];
	a_restricted_solutions[0] = 115;
	a_restricted_solutions[1] = 935;
	a_restricted_solutions[2] = 386;
	a_restricted_solutions[3] = 481;
	a_restricted_solutions[4] = 101;
	a_restricted_solutions[5] = 872;
	a_numbers = [];

	for ( i = 0; i < 3; i++ )
		a_numbers[i] = i;

	for ( i = 1; i < 4; i++ )
	{
		n_index = randomint( a_numbers.size );
		level.a_nixie_tube_solution[i] = a_numbers[n_index];
		arrayremoveindex( a_numbers, n_index );
	}

	for ( i = 0; i < a_restricted_solutions.size; i++ )
	{
		b_is_restricted_solution = 1;
		restricted_solution = [];

		for ( j = 1; j < 4; j++ )
		{
			restricted_solution[j] = get_split_number( j, a_restricted_solutions[i] );

			if ( restricted_solution[j] != level.a_nixie_tube_solution[j] )
				b_is_restricted_solution = 0;
		}

		if ( b_is_restricted_solution )
		{
			n_index = randomint( a_numbers.size );
			level.a_nixie_tube_solution[3] = a_numbers[n_index];
		}
	}
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
