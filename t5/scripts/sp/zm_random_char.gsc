#include common_scripts\utility;
#include maps\_utility;

init()
{
	if ( isSubStr( getdvar( #"mapname" ), "zombie_" ) )
		thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player.zm_random_char = characterindex();
		player.entity_num = player.zm_random_char;
	}
}

characterindex()
{
	characterindex = [];
	characterindex[0] = 0;
	characterindex[1] = 1;
	characterindex[2] = 2;
	characterindex[3] = 3;
	players = get_players();

	if ( players.size == 1 )
	{
		return characterindex[randomInt( characterindex.size )];
	}
	else
	{
		n_characters_defined = 0;

		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( isdefined( player.zm_random_char ) )
			{
				characterindex = array_remove( characterindex, player.zm_random_char );
				n_characters_defined++;
			}
		}

		if ( characterindex.size > 0 )
		{
			if ( getdvar( #"mapname" ) == "zombie_moon" && ( n_characters_defined == players.size - 1 ) && is_in_array( characterindex, 3 ) )
			{
				return 3;
			}

			return characterindex[randomInt( characterindex.size )];
		}
	}

	return 0;
}
