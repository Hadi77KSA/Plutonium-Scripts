#include maps\_utility;

init()
{
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player.characterindex = assign_lowest_unused_character_index();
		player.entity_num = player.characterindex;
	}
}

assign_lowest_unused_character_index()
{
	charindexarray = [];
	charindexarray[0] = 0;
	charindexarray[1] = 1;
	charindexarray[2] = 2;
	charindexarray[3] = 3;
	players = getPlayers();

	if ( players.size == 1 )
	{
		charindexarray = array_randomize( charindexarray );
		return charindexarray[0];
	}
	else
	{
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( isdefined( player.characterindex ) )
				charindexarray = array_remove( charindexarray, player.characterindex );
		}

		if ( charindexarray.size > 0 )
		{
			charindexarray = array_randomize( charindexarray );
			return charindexarray[0];
		}
	}

	return 0;
}
