init()
{
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread toggle_hud_watch();
	}
}

toggle_hud_watch()
{
	self endon( "disconnect" );
	toggle = 1;

	for (;;)
	{
		level waittill( "say", message, player );

		if ( message == "tog_hud" && isPlayer( player ) && player == self )
		{
			toggle = !toggle;
			self setClientUIVisibilityFlag( "hud_visible", toggle );
		}
	}
}
