init()
{
	thread network_frame_value();
}

network_frame_value()
{
	common_scripts\utility::flag_wait( "all_players_connected" );
	oldtime = gettime();
	maps\_utility::wait_network_frame();
	message = "Network frame: " + ( gettime() - oldtime ) / 1000;
	iPrintLn( message );
	println( message );
}
