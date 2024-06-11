#include common_scripts\utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;

main()
{
	level.round_wait_func = ::custom_round_wait;
}

custom_round_wait()
{
	level endon( "restart_round" );
/#
	if ( getdvarint( #"zombie_rise_test" ) )
		level waittill( "forever" );
#/
/#
	if ( getdvarint( #"zombie_cheat" ) == 2 || getdvarint( #"zombie_cheat" ) >= 4 )
		level waittill( "forever" );
#/
	wait 1;

	if ( flag( "dog_round" ) )
	{
		wait 7;

		while ( level.dog_intermission )
			wait 0.5;

		increment_dog_round_stat( "finished" );
	}
	else
	{
		while ( true )
		{
			should_wait = 0;

			if ( isdefined( level.is_ghost_round_started ) && [[ level.is_ghost_round_started ]]() )
				should_wait = 1;
			else if ( !( isdefined( level.next_dog_round ) && level.next_dog_round == ( level.round_number + 1 ) ) && !( isdefined( level.next_leaper_round ) && level.next_leaper_round == ( level.round_number + 1 ) ) )
				should_wait = level.zombie_total > 0 || level.intermission;
			else
				should_wait = get_current_zombie_count() > 0 || level.zombie_total > 0 || level.intermission;

			if ( !should_wait )
				return;

			if ( flag( "end_round_wait" ) )
				return;

			wait 1.0;
		}
	}
}
