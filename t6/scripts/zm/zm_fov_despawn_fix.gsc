main()
{
	replaceFunc( maps\mp\zombies\_zm_ai_faller::in_player_fov, ::in_player_fov );
	str = getDvar( #"mapname" );
	func = getFunction( "maps\\mp\\" + ( ( str == "zm_prison" ) ? "zm_alcatraz" : str ) + "_distance_tracking", "player_can_see_me" );

	if ( isdefined( func ) )
	{
		replaceFunc( func, ::player_can_see_me );
	}
}

in_player_fov( player )
{
	playerangles = player getplayerangles();
	playerforwardvec = anglestoforward( playerangles );
	playerunitforwardvec = vectornormalize( playerforwardvec );
	banzaipos = self.origin;
	playerpos = player getorigin();
	playertobanzaivec = banzaipos - playerpos;
	playertobanzaiunitvec = vectornormalize( playertobanzaivec );
	forwarddotbanzai = vectordot( playerunitforwardvec, playertobanzaiunitvec );
	anglefromcenter = acos( forwarddotbanzai );
	playerfov = getdvarfloat( #"cg_fov" );

	if ( playerfov > 90 )
	{
		playerfov = 90;
	}
	else if ( playerfov < 65 )
	{
		playerfov = 65;
	}

	banzaivsplayerfovbuffer = getdvarfloat( #"g_banzai_player_fov_buffer" );

	if ( banzaivsplayerfovbuffer <= 0 )
		banzaivsplayerfovbuffer = 0.2;

	inplayerfov = anglefromcenter <= playerfov * 0.5 * ( 1 - banzaivsplayerfovbuffer );
	return inplayerfov;
}

player_can_see_me( player )
{
	playerangles = player getplayerangles();
	playerforwardvec = anglestoforward( playerangles );
	playerunitforwardvec = vectornormalize( playerforwardvec );
	banzaipos = self.origin;
	playerpos = player getorigin();
	playertobanzaivec = banzaipos - playerpos;
	playertobanzaiunitvec = vectornormalize( playertobanzaivec );
	forwarddotbanzai = vectordot( playerunitforwardvec, playertobanzaiunitvec );

	if ( forwarddotbanzai >= 1 )
		anglefromcenter = 0;
	else if ( forwarddotbanzai <= -1 )
		anglefromcenter = 180;
	else
		anglefromcenter = acos( forwarddotbanzai );

	playerfov = getdvarfloat( #"cg_fov" );

	if ( playerfov > 90 )
	{
		playerfov = 90;
	}
	else if ( playerfov < 65 )
	{
		playerfov = 65;
	}

	banzaivsplayerfovbuffer = getdvarfloat( #"g_banzai_player_fov_buffer" );

	if ( banzaivsplayerfovbuffer <= 0 )
		banzaivsplayerfovbuffer = 0.2;

	playercanseeme = anglefromcenter <= playerfov * 0.5 * ( 1 - banzaivsplayerfovbuffer );
	return playercanseeme;
}
