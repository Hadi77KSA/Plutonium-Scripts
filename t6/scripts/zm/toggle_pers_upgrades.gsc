#include maps\mp\zombies\_zm_ffotd;
#include maps\mp\zombies\_zm_utility;

/*

To disable a persistent upgrade, navigate to the function "*_init_persistent_abilities" of the desired map that
you wish to disable the upgrade on, and apply any of the following to the "level.pers_upgrade_*" of the upgrade
you wish to disable:

- Place double slashes (//) at the start of the line. Example:
// level.pers_upgrade_pistol_points = 1;

- Replace the 1 that's after the equal sign (=) with undefined. Example:
level.pers_upgrade_jugg = undefined;

- Replace the 1 that's after the equal sign (=) with 0. Example:
level.pers_upgrade_sniper = 0;

Note: Leave the "main_start" function as it currently is to avoid having your toggles be overwritten.

*/

main()
{
	replaceFunc( maps\mp\zombies\_zm_ffotd::main_start, ::main_start );

	switch ( getdvar( #"mapname" ) )
	{
		case "zm_transit":
			replaceFunc( getFunction( "maps/mp/zm_transit", "init_persistent_abilities" ), ::transit_init_persistent_abilities );
			break;
		case "zm_highrise":
			replaceFunc( getFunction( "maps/mp/zm_highrise", "init_persistent_abilities" ), ::highrise_init_persistent_abilities );
			break;
		case "zm_buried":
			replaceFunc( getFunction( "maps/mp/zm_buried", "init_persistent_abilities" ), ::buried_init_persistent_abilities );
			break;
	}
}

transit_init_persistent_abilities()
{
	if ( is_classic() )
	{
		level.pers_upgrade_boards = 1;
		level.pers_upgrade_revive = 1;
		level.pers_upgrade_multi_kill_headshots = 1;
		level.pers_upgrade_cash_back = 1;
		level.pers_upgrade_insta_kill = 1;
		level.pers_upgrade_jugg = 1;
		level.pers_upgrade_carpenter = 1;
		level.pers_upgrade_box_weapon = 1;
		level.pers_magic_box_firesale = 1;
		level.pers_treasure_chest_get_weapons_array_func = getFunction( "maps/mp/zm_transit", "pers_treasure_chest_get_weapons_array_transit" );
		level.pers_upgrade_sniper = 1;
		level.pers_upgrade_pistol_points = 1;
		level.pers_upgrade_perk_lose = 1;
		level.pers_upgrade_double_points = 1;
		level.pers_upgrade_nube = 1;
	}
}

highrise_init_persistent_abilities()
{
	if ( is_classic() )
	{
		level.pers_upgrade_boards = 1;
		level.pers_upgrade_revive = 1;
		level.pers_upgrade_multi_kill_headshots = 1;
		level.pers_upgrade_cash_back = 1;
		level.pers_upgrade_insta_kill = 1;
		level.pers_upgrade_jugg = 1;
		level.pers_upgrade_carpenter = 1;
		level.pers_upgrade_box_weapon = 1;
		level.pers_magic_box_firesale = 1;
		level.pers_treasure_chest_get_weapons_array_func = getFunction( "maps/mp/zm_highrise", "pers_treasure_chest_get_weapons_array_highrise" );
		level.pers_upgrade_sniper = 1;
		level.pers_upgrade_pistol_points = 1;
		level.pers_upgrade_perk_lose = 1;
		level.pers_upgrade_double_points = 1;
		level.pers_upgrade_nube = 1;
	}
}

buried_init_persistent_abilities()
{
	if ( is_classic() )
	{
		level.pers_upgrade_boards = 1;
		level.pers_upgrade_revive = 1;
		level.pers_upgrade_multi_kill_headshots = 1;
		level.pers_upgrade_cash_back = 1;
		level.pers_upgrade_insta_kill = 1;
		level.pers_upgrade_jugg = 1;
		level.pers_upgrade_carpenter = 1;
		level.pers_upgrade_flopper = 1;
		level.divetonuke_precache_override_func = maps\mp\zombies\_zm_pers_upgrades_functions::divetonuke_precache_override_func;
		level.pers_flopper_divetonuke_func = maps\mp\zombies\_zm_pers_upgrades_functions::pers_flopper_explode;
		level.pers_flopper_network_optimized = 1;
		level.pers_upgrade_sniper = 1;
		level.pers_upgrade_pistol_points = 1;
		level.pers_upgrade_perk_lose = 1;
		level.pers_upgrade_double_points = 1;
		level.pers_upgrade_box_weapon = 1;
		level.pers_magic_box_firesale = 1;
		level.pers_treasure_chest_get_weapons_array_func = getFunction( "maps/mp/zm_buried", "pers_treasure_chest_get_weapons_array_buried" );
		level.pers_upgrade_nube = 1;
	}
}

main_start()
{
	mapname = tolower( getdvar( #"mapname" ) );
	gametype = getdvar( #"ui_gametype" );

	if ( "zm_transit" == tolower( getdvar( #"mapname" ) ) && "zclassic" == getdvar( #"ui_gametype" ) )
		level thread transit_navcomputer_remove_card_on_success();

	if ( "zm_prison" == tolower( getdvar( #"mapname" ) ) && "zgrief" == getdvar( #"ui_gametype" ) )
		level.zbarrier_script_string_sets_collision = 1;

/* 	if ( ( "zm_transit" == mapname || "zm_highrise" == mapname ) && "zclassic" == gametype )
	{
		level.pers_upgrade_sniper = 1;
		level.pers_upgrade_pistol_points = 1;
		level.pers_upgrade_perk_lose = 1;
		level.pers_upgrade_double_points = 1;
		level.pers_upgrade_nube = 1;
	} */
}
