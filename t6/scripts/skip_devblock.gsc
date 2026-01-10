main()
{
	if ( !getdvarint( #"developer_script" ) && !getdvarint( #"scr_skip_devblock" ) )
		setdvar( "scr_skip_devblock", "1" );
	else if ( getdvarint( #"developer_script" ) && getdvarint( #"scr_skip_devblock" ) )
		setdvar( "scr_skip_devblock", "0" );
}

init()
{
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connecting", player );

		if ( !getdvarint( #"developer_script" ) )
			player setclientdvar( "scr_skip_devblock", "1" );
	}
}
