init()
{
	precacheshader( "damage_feedback" );
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connecting", player );
		player.hud_kill_damagefeedback = newdamageindicatorhudelem( player );
		player.hud_kill_damagefeedback.horzalign = "center";
		player.hud_kill_damagefeedback.vertalign = "middle";
		player.hud_kill_damagefeedback.x = -12;
		player.hud_kill_damagefeedback.y = -12;
		player.hud_kill_damagefeedback.color = ( 1, 0, 0 );
		player.hud_kill_damagefeedback.alpha = 0;
		player.hud_kill_damagefeedback.archived = 1;
		player.hud_kill_damagefeedback setshader( "damage_feedback", 24, 48 );
		player thread onPlayerDamage();
	}
}

onPlayerDamage()
{
	self endon( "disconnect" );
	for (;;)
	{
		self waittill( "damage", damage, attacker, direction_vec, point, meansofdeath );
		if ( damage_feedback_get_dead( self, meansofdeath ) && isdefined( attacker ) && isplayer( attacker ) && self != attacker )
			attacker thread kill_hitmarker_fade();
	}
}

// modified from shiversoftdev's t7-source repository
damage_feedback_get_dead( victim, mod )
{
	return ( isdefined( victim.laststand ) && victim.laststand || !( victim.health > 0 ) ) /* && ( mod == "MOD_BULLET" || mod == "MOD_RIFLE_BULLET" || mod == "MOD_PISTOL_BULLET" || mod == "MOD_HEAD_SHOT" ) */;
}

// modified from shiversoftdev's t7-source repository
kill_hitmarker_fade()
{
	self notify( "kill_hitmarker_fade" );
	self endon( "kill_hitmarker_fade");
	self endon( "disconnect" );

	self.hud_kill_damagefeedback.alpha = 1;
	wait 0.25;
	self.hud_kill_damagefeedback fadeovertime( 1 );
	self.hud_kill_damagefeedback.alpha = 0;
}
