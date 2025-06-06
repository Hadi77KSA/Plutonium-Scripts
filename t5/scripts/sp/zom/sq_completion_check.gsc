init()
{
	thread completionCheck( "COTD" );
	thread completionCheck( "EOA" );
}

completionCheck( id )
{
	common_scripts\utility::flag_wait( "all_players_spawned" );
	waittillframeend;

	if ( isdefined( level.zombie_sidequest_previously_completed[id] ) )
	{
		msg = "sq_completion_check " + id + ": " + [[ getFunction( "maps/_zombiemode", "is_sidequest_previously_completed" ) ]]( id );
		iPrintLn( msg );
		printf( msg );
		msg = "sq_completion_check " + id + " solo: " + ( isdefined( level.zombie_sidequest_solo_collectible[id] ) && HasCollectible( level.zombie_sidequest_solo_collectible[id] ) );
		iPrintLn( msg );
		printf( msg );

		if ( !isdefined( level.zombie_sidequest_coop_stat[id] ) )
		{
			return;
		}

		players = getPlayers();

		for ( i = 0; i < players.size; i++ )
		{
			msg = "sq_completion_check " + id + " " + level.zombie_sidequest_coop_stat[id] + " " + players[i].playername + ": " + players[i] [[ getFunction( "maps/_zombiemode", "zombieStatGet" ) ]]( level.zombie_sidequest_coop_stat[id] );
			iPrintLn( msg );
			printf( msg );
		}
	}
}
