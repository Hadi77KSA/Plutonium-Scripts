#include maps\mp\zombies\_zm_utility;

main()
{
	switch ( getdvar( "mapname" ) )
	{
		case "zm_transit":
			replaceFunc( getFunction( "maps/mp/zm_transit", "init_persistent_abilities" ), ::custom_transit_init_persistent_abilities );
			break;

		case "zm_highrise":
			replaceFunc( getFunction( "maps/mp/zm_highrise", "init_persistent_abilities" ), ::custom_highrise_init_persistent_abilities );
			break;

		case "zm_buried":
			replaceFunc( getFunction( "maps/mp/zm_buried", "init_persistent_abilities" ), ::custom_buried_init_persistent_abilities );
			break;
	}
}

custom_transit_init_persistent_abilities()
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

custom_highrise_init_persistent_abilities()
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

custom_buried_init_persistent_abilities()
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
