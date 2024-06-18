#include common_scripts\utility;
#include maps\_utility;

init()
{
	if ( getdvar( "mapname" ) == "zombie_moon" )
		thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player.zm_random_char = assign_lowest_unused_character_index();
	}
}

assign_lowest_unused_character_index()
{
	charindexarray = [];
	charindexarray[0] = 0;
	charindexarray[1] = 1;
	charindexarray[2] = 2;
	charindexarray[3] = 3;
	players = get_players();

	if ( players.size == 1 )
	{
		charindexarray = array_randomize( charindexarray );
		return charindexarray[0];
	}
	else
	{
		n_characters_defined = 0;

		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];
			if ( isdefined( player.zm_random_char ) )
			{
				charindexarray = array_remove( charindexarray, player.zm_random_char );
				n_characters_defined++;
			}
		}

		if ( charindexarray.size > 0 )
		{
			if ( n_characters_defined == players.size - 1 )
			{
				if ( is_in_array( charindexarray, 3 ) )
					return 3;
			}

			charindexarray = array_randomize( charindexarray );
			return charindexarray[0];
		}
	}

	return 0;
}
