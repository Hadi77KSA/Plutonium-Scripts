#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;

main()
{
	if ( getdvar( "mapname" ) == "zm_highrise" && maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		replaceFunc( maps\mp\zm_highrise_buildables::include_buildables, ::include_buildables );
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

init()
{
	if ( getdvar( "mapname" ) == "zm_highrise" && maps\mp\zombies\_zm_sidequests::is_sidequest_allowed( "zclassic" ) )
	{
		maps\mp\_utility::set_dvar_if_unset( "scr_force_weapon", "knife_ballistic_zm" );
		hud_elem();
		thread onPlayerConnect();
		thread patch_box();
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
