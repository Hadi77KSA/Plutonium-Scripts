//This script modifies the score colours as well as the gamertag colours based on the player.entity_num of each player
init()
{
	level.score_colours = [];
	level.score_colours[0] = "1 1 1 0";                         //white
	level.score_colours[1] = "0.486275 0.811765 0.933333 0";    //blue
	level.score_colours[2] = "0.964706 0.792157 0.313726 0";    //yellow
	level.score_colours[3] = "0.513726 0.92549 0.533333 0";     //green
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread setScoresColors();
	}
}

setScoresColors()
{
	self endon( "disconnect" );
	common_scripts\utility::flag_wait( "all_players_spawned" );

	for (;;)
	{
		players = getPlayers();

		for ( i = 0; i < 4 && i < players.size; i++ )
			self setClientDvar( "cg_ScoresColor_Gamertag_" + i, level.score_colours[players[i].entity_num] );

		level waittill( "connected" );
		wait 0.05;
	}
}
