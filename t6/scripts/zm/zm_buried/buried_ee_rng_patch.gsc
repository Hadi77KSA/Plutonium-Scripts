#include common_scripts\utility;
#include maps\mp\zombies\_zm_perks;

main()
{
	if ( getdvar( "mapname" ) == "zm_buried" && maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		replaceFunc( ::give_random_perk, ::patch_give_random_perk );
		replaceFunc( maps\mp\zm_buried_sq_ctw::ctw_ric_get_next_wisp_struct, ::ctw_ric_get_next_wisp_struct );
	}
}

init()
{
	if ( getdvar( "mapname" ) == "zm_buried" && maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		setdvar( "scr_force_weapon", "" );
		setdvar( "scr_force_perk", "specialty_nomotionsensor" );
		thread onPlayerConnect();
		thread patch_box();

		if ( maps\mp\_utility::set_dvar_int_if_unset( "patch_max_ammo_richtofen", "1" ) )
			thread patch_max_ammo();

		thread patch_maze_levers();
	}
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread unpatch_random_perk_on_ghost_perk();
		player thread display_mod_message();
	}
}

display_mod_message()
{
	self endon( "disconnect" );
	flag_wait( "initial_players_connected" );
	self iPrintLn( "Script ''buried_ee_rng_patch.gsc'' loaded successfully" );
}

patch_box()
{
	patch_weapons = [];
	patch_weapons[patch_weapons.size] = "slowgun_zm";
	patch_weapons[patch_weapons.size] = "time_bomb_zm";
	patch_weapons = array_randomize( patch_weapons );
	flag_wait( "initial_players_connected" );
	// desired_max_target_of_hits = 2;

	// for ( i = 0; i < desired_max_target_of_hits - patch_weapons.size; i++ )
	// {
	// 	level waittill( "chest_has_been_used" );
	// 	wait 5;
	// }

	prev_func = level.custom_magic_box_selection_logic;
	level.custom_magic_box_selection_logic = ::force_patch_weapon;
	pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );

	foreach( weapon in patch_weapons )
	{
		if ( maps\mp\zombies\_zm_magicbox::treasure_chest_canplayerreceiveweapon( getPlayers()[0], weapon, pap_triggers ) )
			setdvar( "scr_force_weapon", weapon );

		level waittill( "chest_has_been_used" );
		wait 5;
		setdvar( "scr_force_weapon", "" );
	}

	level.custom_magic_box_selection_logic = prev_func;
}

force_patch_weapon( weapon, player, pap_triggers )
{
	forced_weapon = getdvar( #"scr_force_weapon" );

	if ( forced_weapon != "" && isdefined( level.zombie_weapons[forced_weapon] ) )
		return weapon == forced_weapon;

	return 1;
}

patch_max_ammo()
{
	flag_wait( "zombie_drop_powerups" );
	wait 0.05;
	arrayremovevalue( level.zombie_powerup_array, "full_ammo" );
	// prev_value = level.zombie_powerup_index;

	// do
	// 	level waittill( "powerup_dropped" );
	// while ( level.zombie_powerup_index == prev_value )

	level waittill( "sq_tpo_special_round_ended" );
	arrayinsert( level.zombie_powerup_array, "full_ammo", level.zombie_powerup_index );
}

unpatch_random_perk_on_ghost_perk()
{
	self endon( "disconnect" );
	self waittill( "player_received_ghost_round_free_perk" );
	wait 0.05;
	setdvar( "scr_force_perk", "" );
}

patch_give_random_perk()
{
	random_perk = undefined;
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	perks = [];

	for ( i = 0; i < vending_triggers.size; i++ )
	{
		perk = vending_triggers[i].script_noteworthy;

		if ( isdefined( self.perk_purchased ) && self.perk_purchased == perk )
			continue;

		if ( perk == "specialty_weapupgrade" )
			continue;

		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
			perks[perks.size] = perk;
	}

	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );

		forced_perk = getdvar( "scr_force_perk" );

		if ( forced_perk != "" && isinarray( perks, forced_perk ) )
			arrayinsert( perks, forced_perk, 0 );

		random_perk = perks[0];
		self give_perk( random_perk );
	}
	else
		self playsoundtoplayer( level.zmb_laugh_alias, self );

	return random_perk;
}

patch_maze_levers()
{
	level waittill( "sq_ip_started" );
	a_levers = getentarray( "sq_ml_lever", "targetname" );
	array_thread( a_levers, ::sq_ml_watch_trigger );
}

sq_ml_watch_trigger()
{
	while ( !isdefined( self.trig ) )
		wait 1;

	for (;;)
	{
		self.trig waittill( "trigger" );
		wait 0.05;
		self.n_flip_number = self.n_lever_order;
	}
}

ctw_ric_get_next_wisp_struct( s_current )
{
	if ( !isdefined( s_current.target ) )
		return undefined;

	if ( s_current.target == "pf729_auto71" )
		return getstruct( "pf729_auto70", "target" );

	a_structs = getstructarray( s_current.target, "targetname" );
	return array_randomize( a_structs )[0];
}
