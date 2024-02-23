main()
{
	if ( !getdvarint( "developer_script" ) && !getdvarint( "scr_skip_devblock" ) )
		setdvar( "scr_skip_devblock", "1" );
	else if ( getdvarint( "developer_script" ) && getdvarint( "scr_skip_devblock" ) )
		setdvar( "scr_skip_devblock", "0" );
}
