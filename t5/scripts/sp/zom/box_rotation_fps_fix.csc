main()
{
	func = getFunction( "clientscripts\\_zombiemode_weapons", "weapon_floats_up" );

	if ( isdefined( func ) )
	{
		replaceFunc( func, ::weapon_floats_up );
	}
}

weapon_floats_up()
{
	self endon("end_float");
	
	[[ getFunction( "clientscripts\\_zombiemode_weapons", "cleanup_weapon_models" ) ]]();

	self.weapon_models = [];

	number_cycles = 39;
	floatHeight = 64;

	rand = [[ getFunction( "clientscripts\\_zombiemode_weapons", "treasure_chest_ChooseRandomWeapon" ) ]]();
	modelname = GetWeaponModel( rand );
	
	players = getlocalplayers();
	for( i = 0; i < players.size; i ++)
	{
		self.weapon_models[i] = spawn(i, self.origin, "script_model"); 
		self.weapon_models[i].angles = self.angles+( 0, 180, 0 );
		self.weapon_models[i].dw = spawn(i, self.weapon_models[i].origin - ( 3, 3, 3 ), "script_model");
		self.weapon_models[i].dw.angles = self.weapon_models[i].angles;
		self.weapon_models[i].dw Hide();
	
		self.weapon_models[i] SetModel( modelname ); 
		self.weapon_models[i].dw SetModel(modelname);
		self.weapon_models[i] useweaponhidetags( rand );

		//move it up
		self.weapon_models[i] moveto( self.origin +( 0, 0, floatHeight ), 3, 2, 0.9 ); 	
		self.weapon_models[i].dw MoveTo(self.origin + (0,0,floatHeight) - ( 3, 3, 3 ), 3, 2, 0.9);
	}
	
	for( i = 0; i < number_cycles; i++ )
	{

		if( i < 20 )
		{
			clientscripts\_utility::realWait( 0.05 ); 
		}
		else if( i < 30 )
		{
			clientscripts\_utility::realWait( 0.1 ); 
		}
		else if( i < 35 )
		{
			clientscripts\_utility::realWait( 0.2 ); 
		}
		else if( i < 38 )
		{
			clientscripts\_utility::realWait( 0.3 ); 
		}

		//debugstar(self.weapon_models[0].origin, 20, (0,1,0));

		rand = [[ getFunction( "clientscripts\\_zombiemode_weapons", "treasure_chest_ChooseRandomWeapon" ) ]]();
		modelname = GetWeaponModel( rand );
		
		players = getlocalplayers();
		for( index = 0; index < players.size; index++)
		{
			if(IsDefined(self.weapon_models[index]))
			{
				self.weapon_models[index] SetModel( modelname ); 
				self.weapon_models[index] useweaponhidetags( rand );
				
				if([[ getFunction( "clientscripts\\_zombiemode_weapons", "weapon_is_dual_wield" ) ]](rand))
				{
					self.weapon_models[index].dw SetModel( [[ getFunction( "clientscripts\\_zombiemode_weapons", "get_left_hand_weapon_model_name" ) ]]( rand ) );
					self.weapon_models[index].dw useweaponhidetags(rand);
					self.weapon_models[index].dw show();
				}
				else
				{
					self.weapon_models[index].dw Hide();
				}
			}
		}
	}

	[[ getFunction( "clientscripts\\_zombiemode_weapons", "cleanup_weapon_models" ) ]]();
}
