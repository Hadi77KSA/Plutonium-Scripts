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
		player.characterindex = characterindex();
		player.entity_num = player.characterindex;
	}
}

characterindex()
{
	characterindex = [];
	characterindex[0] = 0;
	characterindex[1] = 1;
	characterindex[2] = 2;
	characterindex[3] = 3;
	players = getPlayers();

	if ( players.size == 1 )
	{
		return characterindex[randomInt( characterindex.size )];
	}
	else
	{
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( isdefined( player.characterindex ) )
			{
				characterindex = array_remove( characterindex, player.characterindex );
			}
		}

		if ( characterindex.size > 0 )
		{
			return characterindex[randomInt( characterindex.size )];
		}
	}

	return 0;
}
