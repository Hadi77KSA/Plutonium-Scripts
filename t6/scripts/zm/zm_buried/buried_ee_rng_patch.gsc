#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zm_buried_sq_ip;
#include maps\mp\zombies\_zm_perks;

main()
{
	if ( getdvar( "mapname" ) == "zm_buried" && maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		replaceFunc( maps\mp\zombies\_zm_perks::give_random_perk, ::give_random_perk );
		replaceFunc( maps\mp\zm_buried_sq_ip::sq_ml_spawn_lever, ::sq_ml_spawn_lever );
	}
}

init()
{
	if ( getdvar( "mapname" ) == "zm_buried" && maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		setdvar( "scr_force_weapon", "" );
		setdvar( "scr_force_perk", "specialty_nomotionsensor" );
		level.customspawnlogic = ::spawn_host_closest_to_hole; //patch host initial spawn

		//patch wisp code to always be DLC
		foreach ( m_sign in getentarray( "sq_tunnel_sign", "targetname" ) )
		{
			switch ( m_sign.model )
			{
				case "p6_zm_bu_sign_tunnel_bone":
				case "p6_zm_bu_sign_tunnel_lunger":
				case "p6_zm_bu_sign_tunnel_ground":
					m_sign.is_max_sign = 1;
					m_sign.is_ric_sign = 1;
					break;
				default:
					m_sign.is_max_sign = undefined;
					m_sign.is_ric_sign = undefined;
					break;
			}
		}

		level.struct_class_names["targetname"]["pf729_auto71"] = array( getstructarray( "pf729_auto71", "targetname" )[0] ); //patch Richtofen wisp to always go from General Store to Candy Store
		level._maze._perms = array( array( "blocker_1", "blocker_10", "blocker_6", "blocker_4", "blocker_11" ) ); //patch Maze doors
		hud_elem();
		thread onPlayerConnect();
		thread patch_box();
		thread patch_powerups();
		thread patch_maze_levers();
	}
}

hud_elem()
{
	text = createServerFontString( "default", 1.5 );
	text setPoint( "BOTTOM", "CENTER", 0, 200 );
	text settext( "^6buried_ee_rng_patch.gsc" );
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

spawn_host_closest_to_hole( predictedspawn )
{
	spawnpoint = getstructarray( "initial_spawn_points", "targetname" )[7]; //4 is also a close spawn

	if ( predictedspawn )
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
	else
		self spawn( spawnpoint.origin, spawnpoint.angles, "zsurvival" );

	level.customspawnlogic = undefined;
	return spawnpoint;
}

patch_box()
{
	patch_weapons = [];
	patch_weapons[patch_weapons.size] = "slowgun_zm";
	patch_weapons[patch_weapons.size] = "time_bomb_zm";
	// patch_weapons = array_randomize( patch_weapons );
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

patch_powerups()
{
	arrayremovevalue( level.zombie_powerup_array, "nuke" );
	arrayinsert( level.zombie_powerup_array, "nuke", level.zombie_powerup_index );
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
give_random_perk()
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

sq_ml_spawn_lever( n_index )
{
	m_lever = spawn( "script_model", ( 0, 0, 0 ) );
	m_lever setmodel( self.model );
	m_lever.targetname = "sq_ml_lever";

	while ( true )
	{
		v_spot = self.origin;
		v_angles = self.angles;

		if ( isdefined( level._maze._active_perm_list[n_index] ) )
		{
			is_flip = level._maze._active_perm_list[n_index] == "blocker_1" || level._maze._active_perm_list[n_index] == "blocker_6"; //patch levers sides
			s_spot = getstruct( level._maze._active_perm_list[n_index], "script_noteworthy" );
			v_right = anglestoright( s_spot.angles );
			v_offset = vectornormalize( v_right ) * 2;

			if ( is_flip )
				v_offset = v_offset * -1;

			v_spot = s_spot.origin + vectorscale( ( 0, 0, 1 ), 48.0 ) + v_offset;
			v_angles = s_spot.angles + vectorscale( ( 0, 1, 0 ), 90.0 );

			if ( is_flip )
				v_angles = s_spot.angles - vectorscale( ( 0, 1, 0 ), 90.0 );
		}

		m_lever.origin = v_spot;
		m_lever.angles = v_angles;
/#
		m_lever thread sq_ml_show_lever_debug( v_spot, n_index );
#/
		level waittill( "zm_buried_maze_changed" );
	}
}
