#include maps\mp\_utility;
#include maps\mp\gametypes\_damagefeedback;
#include maps\mp\gametypes\_globallogic_player;

main()
{
	replaceFunc( ::updatedamagefeedback, ::custom_updatedamagefeedback );
}

init()
{
	level.callbackplayerdamage = ::callback_playerdamage;
}

custom_updatedamagefeedback( mod, inflictor, perkfeedback, victim )
{
	if ( !isplayer( self ) || sessionmodeiszombiesgame() )
		return;

	if ( isdefined( mod ) && mod != "MOD_CRUSH" && mod != "MOD_GRENADE_SPLASH" && mod != "MOD_HIT_BY_OBJECT" )
	{
		if ( isdefined( inflictor ) && isdefined( inflictor.soundmod ) )
		{
			switch ( inflictor.soundmod )
			{
				case "player":
					self playlocalsound( "mpl_hit_alert" );
					break;
				case "heli":
					self thread playhitsound( mod, "mpl_hit_alert_air" );
					break;
				case "hpm":
					self thread playhitsound( mod, "mpl_hit_alert_hpm" );
					break;
				case "taser_spike":
					self thread playhitsound( mod, "mpl_hit_alert_taser_spike" );
					break;
				case "dog":
				case "straferun":
					break;
				case "default_loud":
					self thread playhitsound( mod, "mpl_hit_heli_gunner" );
					break;
				default:
					self thread playhitsound( mod, "mpl_hit_alert_low" );
					break;
			}
		}
		else
			self playlocalsound( "mpl_hit_alert_low" );
	}

	if ( isdefined( perkfeedback ) )
	{
		switch ( perkfeedback )
		{
			case "flakjacket":
				self.hud_damagefeedback setshader( "damage_feedback_flak", 24, 48 );
				break;
			case "tacticalMask":
				self.hud_damagefeedback setshader( "damage_feedback_tac", 24, 48 );
				break;
		}
	}
	else
		self.hud_damagefeedback setshader( "damage_feedback", 24, 48 );

	if ( isdefined( victim ) && isplayer( victim ) && damage_feedback_get_dead( victim, mod ) )
		self.hud_damagefeedback.color = ( 1, 0, 0 );
	else if ( isdefined( self.hud_damagefeedback.color ) )
		self.hud_damagefeedback.color = ( 1, 1, 1 );

	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback fadeovertime( 1 );
	self.hud_damagefeedback.alpha = 0;
}

// modified from shiversoftdev's t7-source repository
damage_feedback_get_dead( victim, mod )
{
	return ( isdefined( victim.laststand ) && victim.laststand || !( victim.health > 0 ) ) /* && ( mod == "MOD_BULLET" || mod == "MOD_RIFLE_BULLET" || mod == "MOD_PISTOL_BULLET" || mod == "MOD_HEAD_SHOT" ) */;
}

callback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    profilelog_begintiming( 6, "ship" );

    if ( game["state"] == "postgame" )
        return;

    if ( self.sessionteam == "spectator" )
        return;

    if ( isdefined( self.candocombat ) && !self.candocombat )
        return;

    if ( isdefined( eattacker ) && isplayer( eattacker ) && isdefined( eattacker.candocombat ) && !eattacker.candocombat )
        return;

    if ( isdefined( level.hostmigrationtimer ) )
        return;

    if ( ( sweapon == "ai_tank_drone_gun_mp" || sweapon == "ai_tank_drone_rocket_mp" ) && !level.hardcoremode )
    {
        if ( isdefined( eattacker ) && eattacker == self )
        {
            if ( isdefined( einflictor ) && isdefined( einflictor.from_ai ) )
                return;
        }

        if ( isdefined( eattacker ) && isdefined( eattacker.owner ) && eattacker.owner == self )
            return;
    }

    if ( sweapon == "emp_grenade_mp" )
    {
        if ( self hasperk( "specialty_immuneemp" ) )
            return;

        self notify( "emp_grenaded", eattacker );
    }

    if ( isdefined( eattacker ) )
        idamage = maps\mp\gametypes\_class::cac_modified_damage( self, eattacker, idamage, smeansofdeath, sweapon, einflictor, shitloc );

    idamage = custom_gamemodes_modified_damage( self, eattacker, idamage, smeansofdeath, sweapon, einflictor, shitloc );
    idamage = int( idamage );
    self.idflags = idflags;
    self.idflagstime = gettime();
    eattacker = figureoutattacker( eattacker );
    pixbeginevent( "PlayerDamage flags/tweaks" );

    if ( !isdefined( vdir ) )
        idflags = idflags | level.idflags_no_knockback;

    friendly = 0;

    if ( self.health != self.maxhealth )
        self notify( "snd_pain_player" );

    if ( isdefined( einflictor ) && isdefined( einflictor.script_noteworthy ) )
    {
        if ( einflictor.script_noteworthy == "ragdoll_now" )
            smeansofdeath = "MOD_FALLING";

        if ( isdefined( level.overrideweaponfunc ) )
            sweapon = [[ level.overrideweaponfunc ]]( sweapon, einflictor.script_noteworthy );
    }

    if ( maps\mp\gametypes\_globallogic_utils::isheadshot( sweapon, shitloc, smeansofdeath, einflictor ) && isplayer( eattacker ) )
        smeansofdeath = "MOD_HEAD_SHOT";

    if ( level.onplayerdamage != maps\mp\gametypes\_globallogic::blank )
    {
        modifieddamage = [[ level.onplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );

        if ( isdefined( modifieddamage ) )
        {
            if ( modifieddamage <= 0 )
                return;

            idamage = modifieddamage;
        }
    }

    if ( level.onlyheadshots )
    {
        if ( smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET" )
            return;
        else if ( smeansofdeath == "MOD_HEAD_SHOT" )
            idamage = 150;
    }

    if ( self maps\mp\_vehicles::player_is_occupant_invulnerable( smeansofdeath ) )
        return;

    if ( isdefined( eattacker ) && isplayer( eattacker ) && self.team != eattacker.team )
        self.lastattackweapon = sweapon;

    sweapon = figureoutweapon( sweapon, einflictor );
    pixendevent();

    if ( idflags & level.idflags_penetration && isplayer( eattacker ) && eattacker hasperk( "specialty_bulletpenetration" ) )
        self thread maps\mp\gametypes\_battlechatter_mp::perkspecificbattlechatter( "deepimpact", 1 );

    attackerishittingteammate = isplayer( eattacker ) && self isenemyplayer( eattacker ) == 0;

    if ( shitloc == "riotshield" )
    {
        if ( attackerishittingteammate && level.friendlyfire == 0 )
            return;

        if ( ( smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET" ) && !maps\mp\killstreaks\_killstreaks::iskillstreakweapon( sweapon ) && !attackerishittingteammate )
        {
            if ( self.hasriotshieldequipped )
            {
                if ( isplayer( eattacker ) )
                {
                    eattacker.lastattackedshieldplayer = self;
                    eattacker.lastattackedshieldtime = gettime();
                }

                previous_shield_damage = self.shielddamageblocked;
                self.shielddamageblocked = self.shielddamageblocked + idamage;

                if ( self.shielddamageblocked % 400 < previous_shield_damage % 400 )
                {
                    score_event = "shield_blocked_damage";

                    if ( self.shielddamageblocked > 2000 )
                        score_event = "shield_blocked_damage_reduced";

                    if ( isdefined( level.scoreinfo[score_event]["value"] ) )
                        self addweaponstat( "riotshield_mp", "score_from_blocked_damage", level.scoreinfo[score_event]["value"] );

                    thread maps\mp\_scoreevents::processscoreevent( score_event, self );
                }
            }
        }

        if ( idflags & level.idflags_shield_explosive_impact )
        {
            shitloc = "none";

            if ( !( idflags & level.idflags_shield_explosive_impact_huge ) )
                idamage = idamage * 0.0;
        }
        else if ( idflags & level.idflags_shield_explosive_splash )
        {
            if ( isdefined( einflictor ) && isdefined( einflictor.stucktoplayer ) && einflictor.stucktoplayer == self )
                idamage = 101;

            shitloc = "none";
        }
        else
            return;
    }

    if ( !( idflags & level.idflags_no_protection ) )
    {
        if ( isdefined( einflictor ) && ( smeansofdeath == "MOD_GAS" || maps\mp\gametypes\_class::isexplosivedamage( undefined, smeansofdeath ) ) )
        {
            if ( ( einflictor.classname == "grenade" || sweapon == "tabun_gas_mp" ) && self.lastspawntime + 3500 > gettime() && distancesquared( einflictor.origin, self.lastspawnpoint.origin ) < 62500 )
                return;

            if ( self isplayerimmunetokillstreak( eattacker, sweapon ) )
                return;

            self.explosiveinfo = [];
            self.explosiveinfo["damageTime"] = gettime();
            self.explosiveinfo["damageId"] = einflictor getentitynumber();
            self.explosiveinfo["originalOwnerKill"] = 0;
            self.explosiveinfo["bulletPenetrationKill"] = 0;
            self.explosiveinfo["chainKill"] = 0;
            self.explosiveinfo["damageExplosiveKill"] = 0;
            self.explosiveinfo["chainKill"] = 0;
            self.explosiveinfo["cookedKill"] = 0;
            self.explosiveinfo["weapon"] = sweapon;
            self.explosiveinfo["originalowner"] = einflictor.originalowner;
            isfrag = sweapon == "frag_grenade_mp";

            if ( isdefined( eattacker ) && eattacker != self )
            {
                if ( isdefined( eattacker ) && isdefined( einflictor.owner ) && ( sweapon == "satchel_charge_mp" || sweapon == "claymore_mp" || sweapon == "bouncingbetty_mp" ) )
                {
                    self.explosiveinfo["originalOwnerKill"] = einflictor.owner == self;
                    self.explosiveinfo["damageExplosiveKill"] = isdefined( einflictor.wasdamaged );
                    self.explosiveinfo["chainKill"] = isdefined( einflictor.waschained );
                    self.explosiveinfo["wasJustPlanted"] = isdefined( einflictor.wasjustplanted );
                    self.explosiveinfo["bulletPenetrationKill"] = isdefined( einflictor.wasdamagedfrombulletpenetration );
                    self.explosiveinfo["cookedKill"] = 0;
                }

                if ( ( sweapon == "sticky_grenade_mp" || sweapon == "explosive_bolt_mp" ) && isdefined( einflictor ) && isdefined( einflictor.stucktoplayer ) )
                    self.explosiveinfo["stuckToPlayer"] = einflictor.stucktoplayer;

                if ( sweapon == "proximity_grenade_mp" || sweapon == "proximity_grenade_aoe_mp" )
                {
                    self.laststunnedby = eattacker;
                    self.laststunnedtime = self.idflagstime;
                }

                if ( isdefined( eattacker.lastgrenadesuicidetime ) && eattacker.lastgrenadesuicidetime >= gettime() - 50 && isfrag )
                    self.explosiveinfo["suicideGrenadeKill"] = 1;
                else
                    self.explosiveinfo["suicideGrenadeKill"] = 0;
            }

            if ( isfrag )
            {
                self.explosiveinfo["cookedKill"] = isdefined( einflictor.iscooked );
                self.explosiveinfo["throwbackKill"] = isdefined( einflictor.threwback );
            }

            if ( isdefined( eattacker ) && isplayer( eattacker ) && eattacker != self )
                self maps\mp\gametypes\_globallogic_score::setinflictorstat( einflictor, eattacker, sweapon );
        }

        if ( smeansofdeath == "MOD_IMPACT" && isdefined( eattacker ) && isplayer( eattacker ) && eattacker != self )
        {
            if ( sweapon != "knife_ballistic_mp" )
                self maps\mp\gametypes\_globallogic_score::setinflictorstat( einflictor, eattacker, sweapon );

            if ( sweapon == "hatchet_mp" && isdefined( einflictor ) )
                self.explosiveinfo["projectile_bounced"] = isdefined( einflictor.bounced );
        }

        if ( isplayer( eattacker ) )
            eattacker.pers["participation"]++;

        prevhealthratio = self.health / self.maxhealth;

        if ( level.teambased && isplayer( eattacker ) && self != eattacker && self.team == eattacker.team )
        {
            pixmarker( "BEGIN: PlayerDamage player" );

            if ( level.friendlyfire == 0 )
            {
                if ( sweapon == "artillery_mp" || sweapon == "airstrike_mp" || sweapon == "napalm_mp" || sweapon == "mortar_mp" )
                    self damageshellshockandrumble( eattacker, einflictor, sweapon, smeansofdeath, idamage );

                return;
            }
            else if ( level.friendlyfire == 1 )
            {
                if ( idamage < 1 )
                    idamage = 1;

                if ( level.friendlyfiredelay && level.friendlyfiredelaytime >= ( gettime() - level.starttime - level.discardtime ) / 1000 )
                {
                    eattacker.lastdamagewasfromenemy = 0;
                    eattacker.friendlydamage = 1;
                    eattacker finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
                    eattacker.friendlydamage = undefined;
                }
                else
                {
                    self.lastdamagewasfromenemy = 0;
                    self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
                }
            }
            else if ( level.friendlyfire == 2 && isalive( eattacker ) )
            {
                idamage = int( idamage * 0.5 );

                if ( idamage < 1 )
                    idamage = 1;

                eattacker.lastdamagewasfromenemy = 0;
                eattacker.friendlydamage = 1;
                eattacker finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
                eattacker.friendlydamage = undefined;
            }
            else if ( level.friendlyfire == 3 && isalive( eattacker ) )
            {
                idamage = int( idamage * 0.5 );

                if ( idamage < 1 )
                    idamage = 1;

                self.lastdamagewasfromenemy = 0;
                eattacker.lastdamagewasfromenemy = 0;
                self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
                eattacker.friendlydamage = 1;
                eattacker finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
                eattacker.friendlydamage = undefined;
            }

            friendly = 1;
            pixmarker( "END: PlayerDamage player" );
        }
        else
        {
            if ( idamage < 1 )
                idamage = 1;

            if ( isdefined( eattacker ) && isplayer( eattacker ) && allowedassistweapon( sweapon ) )
                self trackattackerdamage( eattacker, idamage, smeansofdeath, sweapon );

            giveinflictorownerassist( eattacker, einflictor, idamage, smeansofdeath, sweapon );

            if ( isdefined( eattacker ) )
                level.lastlegitimateattacker = eattacker;

            if ( isdefined( eattacker ) && isplayer( eattacker ) && isdefined( sweapon ) && !issubstr( smeansofdeath, "MOD_MELEE" ) )
                eattacker thread maps\mp\gametypes\_weapons::checkhit( sweapon );

            if ( ( smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" ) && isdefined( einflictor.iscooked ) )
                self.wascooked = gettime();
            else
                self.wascooked = undefined;

            self.lastdamagewasfromenemy = isdefined( eattacker ) && eattacker != self;

            if ( self.lastdamagewasfromenemy )
            {
                if ( isplayer( eattacker ) )
                {
                    if ( isdefined( eattacker.damagedplayers[self.clientid] ) == 0 )
                        eattacker.damagedplayers[self.clientid] = spawnstruct();

                    eattacker.damagedplayers[self.clientid].time = gettime();
                    eattacker.damagedplayers[self.clientid].entity = self;
                }
            }

            self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
        }

        if ( isdefined( eattacker ) && isplayer( eattacker ) && eattacker != self )
        {
            if ( dodamagefeedback( sweapon, einflictor, idamage, smeansofdeath ) )
            {
                if ( idamage > 0 )
                {
                    if ( self.health > 0 )
                        perkfeedback = doperkfeedback( self, sweapon, smeansofdeath, einflictor );

                    eattacker thread custom_updatedamagefeedback( smeansofdeath, einflictor, perkfeedback, self );
                }
            }
        }

        self.hasdonecombat = 1;
    }

    if ( isdefined( eattacker ) && eattacker != self && !friendly )
        level.usestartspawns = 0;

    pixbeginevent( "PlayerDamage log" );
/#
    if ( getdvarint( #"g_debugDamage" ) )
        println( "client:" + self getentitynumber() + " health:" + self.health + " attacker:" + eattacker.clientid + " inflictor is player:" + isplayer( einflictor ) + " damage:" + idamage + " hitLoc:" + shitloc );
#/

    if ( self.sessionstate != "dead" )
    {
        lpselfnum = self getentitynumber();
        lpselfname = self.name;
        lpselfteam = self.team;
        lpselfguid = self getguid();
        lpattackerteam = "";
        lpattackerorigin = ( 0, 0, 0 );

        if ( isplayer( eattacker ) )
        {
            lpattacknum = eattacker getentitynumber();
            lpattackguid = eattacker getguid();
            lpattackname = eattacker.name;
            lpattackerteam = eattacker.team;
            lpattackerorigin = eattacker.origin;
            bbprint( "mpattacks", "gametime %d attackerspawnid %d attackerweapon %s attackerx %d attackery %d attackerz %d victimspawnid %d victimx %d victimy %d victimz %d damage %d damagetype %s damagelocation %s death %d", gettime(), getplayerspawnid( eattacker ), sweapon, lpattackerorigin, getplayerspawnid( self ), self.origin, idamage, smeansofdeath, shitloc, 0 );
        }
        else
        {
            lpattacknum = -1;
            lpattackguid = "";
            lpattackname = "";
            lpattackerteam = "world";
            bbprint( "mpattacks", "gametime %d attackerweapon %s victimspawnid %d victimx %d victimy %d victimz %d damage %d damagetype %s damagelocation %s death %d", gettime(), sweapon, getplayerspawnid( self ), self.origin, idamage, smeansofdeath, shitloc, 0 );
        }

        logprint( "D;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sweapon + ";" + idamage + ";" + smeansofdeath + ";" + shitloc + "\\n" );
    }

    pixendevent();
    profilelog_endtiming( 6, "gs=" + game["state"] + " zom=" + sessionmodeiszombiesgame() );
}