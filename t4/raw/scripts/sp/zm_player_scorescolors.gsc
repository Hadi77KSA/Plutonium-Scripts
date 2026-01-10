//This script modifies the score colours as well as the gamertag colours based on the player.entity_num of each player
init()
{
	level.color_order = [];
	level.color_order[0] = "1 1 1 0";                         //white
	level.color_order[1] = "0.486275 0.811765 0.933333 0";    //blue
	level.color_order[2] = "0.964706 0.792157 0.313726 0";    //yellow
	level.color_order[3] = "0.513726 0.92549 0.533333 0";     //green
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread color_order();
	}
}

color_order()
{
	self endon( "disconnect" );
	common_scripts\utility::flag_wait( "all_players_spawned" );

	for (;;)
	{
		players = getPlayers();

		switch ( players.size )
		{
			case 4:
				self setClientDvar( "cg_ScoresColor_Gamertag_3", level.color_order[players[3].entity_num] );
			case 3:
				self setClientDvar( "cg_ScoresColor_Gamertag_2", level.color_order[players[2].entity_num] );
			case 2:
				self setClientDvar( "cg_ScoresColor_Gamertag_1", level.color_order[players[1].entity_num] );
			case 1:
				self setClientDvar( "cg_ScoresColor_Gamertag_0", level.color_order[players[0].entity_num] );
				break;
		}

		level waittill( "connected" );
		wait 0.05;
	}
}
