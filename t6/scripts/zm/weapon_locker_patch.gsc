init()
{
	thread onPlayerConnect();
}

onPlayerConnect()
{
	func = getFunction( "maps/mp/zombies/_zm_weapon_locker", "wl_set_stored_weapondata" );

	if ( !isdefined( func ) )
	{
		return;
	}

	weaponData = getWeaponData( "galil_upgraded_zm+reflex" );

	for (;;)
	{
		level waittill( "connected", player );
		player [[ func ]]( weaponData );
	}
}

getWeaponData( name )
{
	weaponData = [];
	weaponData["name"] = name;
	dw_name = weaponDualWieldWeaponName( weaponData["name"] );
	alt_name = weaponAltWeaponName( weaponData["name"] );
	weaponData["clip"] = weaponClipSize( weaponData["name"] );
	weaponData["stock"] = weaponMaxAmmo( weaponData["name"] );

	if ( dw_name != "none" )
	{
		weaponData["lh_clip"] = weaponClipSize( dw_name );
	}
	else
	{
		weaponData["lh_clip"] = 0;
	}

	if ( alt_name != "none" )
	{
		weaponData["alt_clip"] = weaponClipSize( alt_name );
		weaponData["alt_stock"] = weaponMaxAmmo( alt_name );
	}
	else
	{
		weaponData["alt_clip"] = 0;
		weaponData["alt_stock"] = 0;
	}

	return weaponData;
}
