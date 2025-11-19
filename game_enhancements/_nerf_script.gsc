/*
	Debug Script to nerf explosive weapon damage and certain perks by @mp_rust on twitch (aka Antiga)
*/

init()
{
    level.calldamage = level.callbackplayerdamage; // Rehook damage...
    level.callbackplayerdamage = ::monitor_damage; // Rehook damage...
	level thread onPlayerConnectHook(); // Monitor player connections...
}

onPlayerConnectHook()
{
	while(true)
	{
		level waittill("connected", player);
		player thread giveLoadoutMonitor(); // Start loadout monitor thread...
	}
}

/*
	Threads for looping actions on player connection
*/

giveLoadoutMonitor()
{
	self endon("disconnect");
	level endon("game_ended");

	while(true)
	{
		// Checks spawn + giveLoadout notify
		self common_scripts\utility::waittill_any("giveLoadout", "spawned_player");

		// Nerf specific perks
		nerfed_perks = strTok("specialty_finalstand|specialty_laststand|specialty_pistoldeath|specialty_combathigh|specialty_grenadepulldeath", "|");
		foreach(item in nerfed_perks)
			self maps\mp\_utility::_unsetPerk(item);
		
	}
}

/*
	Damage Monitor
*/

monitor_damage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if(nerfed_weapons(sWeapon) || isSubStr(sWeapon, "gl_") && sMeansOfDeath == "MOD_GRENADE_SPLASH")
		iDamage = 10; // Nerf damage to 10

    [[level.calldamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}


/*
	Utilities
*/

nerfed_weapons(sWeapon)
{
	if(!isDefined(sWeapon))
		return false;

	if(sWeapon == "rpg_mp" || sWeapon == "at4_mp" || sWeapon == "m79_mp" || sWeapon == "javelin_mp")
		return true;
	
	return false;
}