#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;

main()
{
	if ( getdvar( #"mapname" ) == "zm_highrise" && maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		replaceFunc( maps\mp\zm_highrise_buildables::include_buildables, ::include_buildables );
		replaceFunc( maps\mp\zm_highrise_sq::mahjong_tiles_setup, ::mahjong_tiles_setup );
	}
}

include_buildables()
{
	// patch Trample Steam part locations
	level.struct_class_names["targetname"]["springpad_zm" + "_" + "p6_zm_buildable_tramplesteam_door"] = array( getstructarray( "springpad_zm" + "_" + "p6_zm_buildable_tramplesteam_door", "targetname" )[0] );                // 0 = spawn,                       1 = QR
	level.struct_class_names["targetname"]["springpad_zm" + "_" + "p6_zm_buildable_tramplesteam_bellows"] = array( getstructarray( "springpad_zm" + "_" + "p6_zm_buildable_tramplesteam_bellows", "targetname" )[0] );          // 0 = QR,                          1 = spawn
	level.struct_class_names["targetname"]["springpad_zm" + "_" + "p6_zm_buildable_tramplesteam_compressor"] = array( getstructarray( "springpad_zm" + "_" + "p6_zm_buildable_tramplesteam_compressor", "targetname" )[0] );    // 0 = spawn,                       1 = QR
	level.struct_class_names["targetname"]["springpad_zm" + "_" + "p6_zm_buildable_tramplesteam_flag"] = array( getstructarray( "springpad_zm" + "_" + "p6_zm_buildable_tramplesteam_flag", "targetname" )[0] );                // 0 = QR,                          1 = spawn
	// patch Sliquifier part locations
	level.struct_class_names["targetname"]["slipgun_zm" + "_" + "t6_zmb_buildable_slipgun_extinguisher"] = array( getstructarray( "slipgun_zm" + "_" + "t6_zmb_buildable_slipgun_extinguisher", "targetname" )[1] );            // 0 = power,                       1 = Sliquifier buildable floor
	level.struct_class_names["targetname"]["slipgun_zm" + "_" + "t6_zmb_buildable_slipgun_cooker"] = array( getstructarray( "slipgun_zm" + "_" + "t6_zmb_buildable_slipgun_cooker", "targetname" )[1] );                        // 0 = power,                       1 = Sliquifier buildable floor
	level.struct_class_names["targetname"]["slipgun_zm" + "_" + "t6_zmb_buildable_slipgun_throttle"] = array( getstructarray( "slipgun_zm" + "_" + "t6_zmb_buildable_slipgun_throttle", "targetname" )[0] );                    // 0 = Sliquifier buildable floor,  1 = power
	removeDetour( maps\mp\zm_highrise_buildables::include_buildables );
	maps\mp\zm_highrise_buildables::include_buildables();
}

mahjong_tiles_setup()
{
	a_winds = array( "north", "west", "south", "east" ); //patch tower order
	//a_winds = array_randomize( array( "north", "south", "east", "west" ) );
	a_colors = array_randomize( array( "blk", "blu", "grn", "red" ) );
	a_locs = array_randomize( getstructarray( "sq_tile_loc_random", "targetname" ) );
	assert( a_locs.size > a_winds.size, "zm_highrise_sq: not enough locations for mahjong tiles!" );
	a_wind_order = array( "none" );

	for ( i = 0; i < a_winds.size; i++ )
	{
		a_wind_order[a_wind_order.size] = a_winds[i];
		m_wind_tile = getent( "tile_" + a_winds[i] + "_" + a_colors[i], "targetname" );
		m_wind_tile.script_noteworthy = undefined;
		s_spot = a_locs[i];

		if ( a_winds[i] == "north" )
			s_spot = getstruct( "sq_tile_loc_north", "targetname" );

		m_wind_tile.origin = s_spot.origin;
		m_wind_tile.angles = s_spot.angles;
	}

	for ( i = 0; i < a_colors.size; i++ )
	{
		m_num_tile = getent( "tile_" + ( i + 1 ) + "_" + a_colors[i], "targetname" );
		m_num_tile.script_noteworthy = undefined;
		s_spot = a_locs[i + a_winds.size];
		m_num_tile.origin = s_spot.origin;
		m_num_tile.angles = s_spot.angles;
	}

	a_tiles = getentarray( "mahjong_tile", "script_noteworthy" );
	array_delete( a_tiles );
	level.a_wind_order = a_winds;
}

init()
{
	if ( getdvar( #"mapname" ) == "zm_highrise" && maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		maps\mp\_utility::set_dvar_if_unset( "scr_force_weapon", "knife_ballistic_zm" );
		hud_elem();
		thread onPlayerConnect();
		thread patch_box();
		thread sq_atd_drg_puzzle(); //patch floor symbols
	}
}

hud_elem()
{
	text = createServerFontString( "default", 1.5 );
	text setPoint( "BOTTOM", "CENTER", 0, 200 );
	text setText( "^6die_rise_ee_rng_patch.gsc" );
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread msg();
	}
}

msg()
{
	self endon( "disconnect" );
	flag_wait( "initial_players_connected" );
	self iPrintLn( "Script ''die_rise_ee_rng_patch.gsc'' loaded successfully" );
}

patch_box()
{
	flag_wait( "initial_players_connected" );
	prev_func = level.custom_magic_box_selection_logic;
	level.custom_magic_box_selection_logic = ::force_patch_weapon;
	level waittill( "chest_has_been_used" );
	wait 5;
	setdvar( "scr_force_weapon", "" );
	level.custom_magic_box_selection_logic = prev_func;
}

force_patch_weapon( weapon, player, pap_triggers )
{
	forced_weapon = getdvar( #"scr_force_weapon" );

	if ( forced_weapon != "" && isdefined( level.zombie_weapons[forced_weapon] ) )
		return weapon == forced_weapon;

	return 1;
}

sq_atd_drg_puzzle()
{
	flag_wait( "sq_atd_elevator_activated" );

	while ( !isdefined( level.sq_atd_cur_drg ) )
	{
		wait 0.25;
	}

	a_puzzle_trigs = getEntArray( "trig_atd_drg_puzzle", "targetname" );

	for ( i = 0; i < a_puzzle_trigs.size; i++ )
	{
		a_puzzle_trigs[i] thread drg_puzzle_trig_think();
	}
}

drg_puzzle_trig_think()
{
	drg_active = 0;
	m_unlit = getent( self.target, "targetname" );
	m_lit = m_unlit.lit_icon;
	v_top = m_unlit.origin;
	v_hidden = m_lit.origin;
	self waittill( "trigger", e_who );

	while ( !flag( "sq_atd_drg_puzzle_complete" ) )
	{
		waittillframeend;

		if ( drg_active || !self.drg_active )
		{
			m_lit.origin = v_top;
			m_unlit.origin = v_hidden;
			m_lit playsound( "zmb_sq_symbol_light" );
			self.drg_active = 1;
			level thread maps\mp\zm_highrise_sq_atd::vo_richtofen_atd_order( level.sq_atd_cur_drg );
			level.sq_atd_cur_drg++;
		}

		drg_active = 1;

		while ( e_who istouching( self ) )
			wait 0.5;

		level maps\mp\_utility::waittill_either( "sq_atd_drg_puzzle_complete", "drg_puzzle_reset" );
	}
}
