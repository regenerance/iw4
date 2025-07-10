#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
    Originally made by @eternalhabit

    Key Features:
        - Supports all base maps and gamemodes
        - Supports custom maps and gamemodes
        - You can choose how many options you want on screen
        - Ability to restrict certain modes from being played on certain maps
        - MW2 Style Design with Simple UI
        - Only works for dedicated servers (private match no longer rotates maps as of [r4838])
        - Makes use of custom dvars
        - The map vote system will check and remove any duplicates
        - If the user sets up the dvars incorrectly it will revert to default settings
        - People who join late while voting is in progress, will still be able to vote
        - Supports both Mouse & Keyboard as well as Controller

    Buttons:
        - Scroll Up - Shoot or Dpad Up or W
        - Scroll Down - Aim or Dpad Down or S
        - Vote - Jump Button Or Reload Button

    Server Config If You Want To Change Defaults:
        - set mapvote_enable "1"
        - set mapvote_maps "mp_afghan,mp_boneyard,mp_brecourt,mp_checkpoint,mp_derail,mp_estate,mp_favela,mp_highrise,mp_invasion,mp_nightshift,mp_quarry,mp_rundown,mp_rust,mp_subbase,mp_terminal,mp_underpass,mp_abandon,mp_compact,mp_complex,mp_estate_tropical,mp_fav_tropical,mp_fuel2,mp_rust_long,mp_storm,mp_storm_spring,mp_trailerpark,mp_alpha,mp_backlot,mp_bloc,mp_bloc_sh,mp_bog_sh,mp_bravo,mp_broadcast,mp_carentan,mp_cargoship,mp_cargoship_sh,mp_citystreets,mp_convoy,mp_countdown,mp_crash,mp_crash_snow,mp_crash_tropical,mp_cross_fire,mp_dome,mp_farm,mp_firingrange,mp_hardhat,mp_killhouse,mp_nuked,mp_overgrown,mp_paris,mp_pipeline,mp_plaza2,mp_seatown,mp_shipment,mp_shipment_long,mp_showdown,mp_strike,mp_underground,mp_vacant,mp_village"
        - set mapvote_modes "war,dom,conf,dm,sd"
        - set mapvote_customMaps ""
        - set mapvote_timer "30"
        - set mapvote_optionsCount "6" //Between 2 - 6
        - set mapvote_disable_broken_modes "0" //1 = ON, 0 = OFF || Turn on if adding "gtnw" or "dd" to mapvote_modes. This disables Global Thermonuclear War from the COD4 & MW3 Map Packs and Demolition from only the COD4 Map Pack. (IW4x Devs need to fix these gamemodes for these maps)
        - set mapvote_restricted_maps "" //A lot of custom maps don't work with certain modes. Put the maps you want to restrict gamemodes for here.
        - set mapvote_restricted_modes "" //These gamemodes must be in "mapvote_modes" as well. These gamemodes will NOT be added for voting on the restricted maps
    
    IMPORTANT: Any maps you add, outside of the IW4x base maps, go inside the mapvote_customMaps dvar. Each map must be followed by a comma as shown above! No spaces!

    Game Mode List Names (Only if you need them):
        - "conf"// Kill Confirmed
        - "ctf"// Capture The Flag
        - "dd"// Demolition
        - "dm"// Free For All
        - "dom"// Domination
        - "gun"// Gun Game
        - "infect"// Infected
        - "koth"// Headquarters Pro
        - "sab"// Sabotage
        - "sd"// Search And Destroy
        - "war"// Team Deathmatch
        - "arena"// Arena
        - "oneflag"// One-Flag CTF
        - "gtnw"// Global Thermo-Nuclear War
        - "vip"// VIP
    
    Updates by Antiga:
        - Made the script work on private match as well (simple fix)
        - Added a final killcam waiting support (failsafe mechanism)
        - Added mapvote_enable dvar to enable or disable map voting
        - Basic overflow support since it was never included (would prefer clearhudtext, but others may want to use it on other clients)
        - Kicks bots at during map vote which helps improve server performance
        - Improved buttonMonitoring function with a cleaner layout + additional button support
        - Improved mapToString function by using strTok to simplify additional arrays/case indexing
        - Quick change to timer countdown sound to be better on the ears
        - Added dvar mapvote_interruption for if people hit the endgame button to skip map voting
        - Added mapvote_instant_end_cmd to instant end if people type +endgame and skip to map voting
*/

init() 
{
    SetDvarIfUninitialized("mapvote_enable", 1); // Enables/Disables Map Voting
    SetDvarIfUninitialized("mapvote_interruption", 0); // Enables/Disables The Ability To Simply Interrupt Map Voting By Pressing End Game
    SetDvarIfUninitialized("mapvote_instant_end_cmd", 1); // Enables/Disables The Ability To Kickstart Instant Map Voting

    if(!getDvarInt("mapvote_enable")) // Stops anything else from running if it's not enabled
        return;
    
    shaders = strTok("popup_button_selection_bar,gradient_center,white,line_horizontal_scorebar,black",",");
	for(m = 0; m < shaders.size; m++)
		precacheShader(shaders[m]);

    //1024 DVAR character limit
    SetDvarIfUninitialized("mapvote_maps", "mp_afghan,mp_boneyard,mp_brecourt,mp_checkpoint,mp_derail,mp_estate,mp_favela,mp_highrise,mp_invasion,mp_nightshift,mp_quarry,mp_rundown,mp_rust,mp_subbase,mp_terminal,mp_underpass,mp_abandon,mp_compact,mp_complex,mp_estate_tropical,mp_fav_tropical,mp_fuel2,mp_rust_long,mp_storm,mp_storm_spring,mp_trailerpark,mp_alpha,mp_backlot,mp_bloc,mp_bloc_sh,mp_bog_sh,mp_bravo,mp_broadcast,mp_carentan,mp_cargoship,mp_cargoship_sh,mp_citystreets,mp_convoy,mp_countdown,mp_crash,mp_crash_snow,mp_crash_tropical,mp_cross_fire,mp_dome,mp_farm,mp_firingrange,mp_hardhat,mp_killhouse,mp_nuked,mp_overgrown,mp_paris,mp_pipeline,mp_plaza2,mp_seatown,mp_shipment,mp_shipment_long,mp_showdown,mp_strike,mp_underground,mp_vacant,mp_village");
    SetDvarIfUninitialized("mapvote_modes", "war,dom,conf,dm,sd");
    SetDvarIfUninitialized("mapvote_customMaps", "");
    SetDvarIfUninitialized("mapvote_timer", 30);
    SetDvarIfUninitialized("mapvote_optionsCount", 6);
    SetDvarIfUninitialized("mapvote_disable_broken_modes", false);
    SetDvarIfUninitialized("mapvote_restricted_maps", "");
    SetDvarIfUninitialized("mapvote_restricted_modes", "");

    // Intercept Lobby For Voting (Includes Final Killcam Support)
    replaceFunc(maps\mp\gametypes\_gamelogic::endGame, ::endGameHook);
    // Allows Clients To Spawn In End Game + Vote
    replaceFunc(maps\mp\gametypes\_playerlogic::spawnIntermission, ::spawnIntermissionHook);
    
    level thread initMapVote();
    level thread onPlayerConnectHook(); // Monitors End Game Button Pressed
}

onPlayerConnectHook()
{
    while(true)
    {
        level waittill("connected", player);
        if(!player isTestClient())
        {
            if(getDvarInt("mapvote_interruption") && !isDedicatedServer())
                player thread onMenuResponseHook();

            if(getDvarInt("mapvote_instant_end_cmd"))
                player thread onPlayerCommandHook();
        }
    }
}

initMapVote()
{
    level.mapvote = [];

    level.mapvote["maps"] = strtok(getDvar("mapvote_maps"), ",");
    level.mapvote["modes"] = strtok(getDvar("mapvote_modes"), ",");
    level.mapvote["timer"] = getDvarInt("mapvote_timer");

    if(!isInt(level.mapvote["timer"]) || level.mapvote["timer"] <= 0)
        level.mapvote["timer"] = 30;

    if(getDvar("mapvote_customMaps") != "")
    {
        level.mapvote["customMaps"] = strtok(getDvar("mapvote_customMaps"), ",");
        level.mapvote["maps"] = array_combine( level.mapvote["maps"], level.mapvote["customMaps"] ); //Workaround for DVAR character limit
    }

    if(level.mapvote["maps"].size != 0 && isString(getDvar("mapvote_maps")) && arrayHasDuplicates(level.mapvote["maps"], true))
        level.mapvote["maps"] = removeDuplicates(level.mapvote["maps"], true);
    if(level.mapvote["modes"].size != 0 && isString(getDvar("mapvote_modes")) && arrayHasDuplicates(level.mapvote["modes"], true))
        level.mapvote["modes"] = removeDuplicates(level.mapvote["modes"], true);

    if(level.mapvote["maps"].size == 0 || !isString(getDvar("mapvote_maps"))) //DO NOT TOUCH BELOW. We are setting defaults if the user setup our dvars incorrectly.
        level.mapvote["maps"] = strtok("mp_afghan,mp_boneyard,mp_brecourt,mp_checkpoint,mp_derail,mp_estate,mp_favela,mp_highrise,mp_invasion,mp_nightshift,mp_quarry,mp_rundown,mp_rust,mp_subbase,mp_terminal,mp_underpass,mp_abandon,mp_compact,mp_complex,mp_estate_tropical,mp_fav_tropical,mp_fuel2,mp_rust_long,mp_storm,mp_storm_spring,mp_trailerpark,mp_alpha,mp_backlot,mp_bloc,mp_bloc_sh,mp_bog_sh,mp_bravo,mp_broadcast,mp_carentan,mp_cargoship,mp_cargoship_sh,mp_citystreets,mp_convoy,mp_countdown,mp_crash,mp_crash_snow,mp_crash_tropical,mp_cross_fire,mp_dome,mp_farm,mp_firingrange,mp_hardhat,mp_killhouse,mp_nuked,mp_overgrown,mp_paris,mp_pipeline,mp_plaza2,mp_seatown,mp_shipment,mp_shipment_long,mp_showdown,mp_strike,mp_underground,mp_vacant,mp_village", ",");
    if(level.mapvote["modes"].size == 0 || !isString(getDvar("mapvote_modes")))
        level.mapvote["modes"] = strtok("war,dom,conf,dm,sd", ",");

    if(getDvarInt("mapvote_optionsCount") > 6)
        setDvar("mapvote_optionsCount", 6);
    else if(getDvarInt("mapvote_optionsCount") < 2)
        setDvar("mapvote_optionsCount", 2);

    if(getDvarInt("mapvote_enable") > 1)
        setDvar("mapvote_enable", 1);

    if (level.mapvote["maps"].size < 6)
        level.mapvote["menusize"] = level.mapvote["maps"].size;
    else
        level.mapvote["menusize"] = getDvarInt("mapvote_optionsCount");

	level thread generateMapVoteOptions();
}

generateMapVoteOptions()
{
    level.mapvote["index"] = [];

    if(getDvarInt("mapvote_disable_broken_modes") && (isInArray(level.mapvote["modes"], "gtnw") || isInArray(level.mapvote["modes"], "dd")))
	{
        level.mapvote["cod4pack"] = strtok("mp_farm,mp_backlot,mp_pipeline,mp_countdown,mp_crash_snow,mp_carentan,mp_broadcast,mp_showdown,mp_convoy,mp_citystreets", ",");
        level.mapvote["mw3pack"] = strtok("mp_alpha,mp_bravo,mp_dome,mp_hardhat,mp_paris,mp_plaza2,mp_seatown,mp_underground,mp_village", ",");
    }
    if((getDvar("mapvote_restricted_maps") != "" && isString(getDvar("mapvote_restricted_maps"))) && (getDvar("mapvote_restricted_modes") != "" && isString(getDvar("mapvote_restricted_modes"))))
	{
        level.mapvote["restrictedMaps"] = strtok(getDvar("mapvote_restricted_maps"), ",");
        level.mapvote["restrictedModes"] = strtok(getDvar("mapvote_restricted_modes"), ",");
    }

    while(true)
    {
        randomMap = random( level.mapvote["maps"] );
        randomMode = random( level.mapvote["modes"] );

        level.mapvote["index"][level.mapvote["index"].size] = randomMap + "," + randomMode;

        if(isDefined(level.mapvote["cod4pack"]) && isDefined(level.mapvote["mw3pack"]))
        {
            if((isInArray(level.mapvote["cod4pack"], randomMap) || isInArray(level.mapvote["mw3pack"], randomMap)) && randomMode == "gtnw")
                level.mapvote["index"] = array_remove( level.mapvote["index"], level.mapvote["index"][level.mapvote["index"].size - 1] );
            else if(isInArray(level.mapvote["cod4pack"], randomMap) && randomMode == "dd")
                level.mapvote["index"] = array_remove( level.mapvote["index"], level.mapvote["index"][level.mapvote["index"].size - 1] );
        }

        if(isDefined(level.mapvote["restrictedMaps"]) && (isInArray(level.mapvote["restrictedMaps"], randomMap) && isInArray(level.mapvote["restrictedModes"], randomMode)))
            level.mapvote["index"] = array_remove( level.mapvote["index"], level.mapvote["index"][level.mapvote["index"].size - 1] );

        if(arrayHasDuplicates(level.mapvote["index"], true))
            level.mapvote["index"] = removeDuplicates(level.mapvote["index"], true);

        if (level.mapvote["index"].size >= level.mapvote["menusize"])
            break;

        wait 0.1;
	}
}

mapVote()
{
    level.inVoting = true;
    level mapVoteUI();

    foreach(player in level.players)
	{
        if(!player isTestClient())
            player thread buttonMonitoring();
		else
			kick(player getEntityNumber(), "BOT KICKED");
    }

    level startVotingTimer();
	level thread OverflowFixInit(); // Would use clearhudtext, but some people may want to use this on non iw4x...
    level notify("mapvote_over");
    level.inVoting = false;
    level determineWinningMap();

    for(i = 0; i < level.mapvote["ui"].size; i++) 
		level.mapvote["ui"][i] destroyElem();
}

mapVoteUI()
{
    textYaxis = 170;
    bgHeight = level.mapvote["menusize"] * 20;
    hudsYaxis = 160 + bgHeight;

    level.mapvote["ui"] = [];
    level.mapvote["ui"][0] = createText(&"VOTING PHASE: ", "LEFT", "TOP", -90, 150, 0.8, "hudBig", (1,1,1), 1, 3, true, level.mapvote["timer"]);
    level.mapvote["ui"][1] = createShader("gradient_center", "TOP", "TOP", 0, 140, 350, 20, (0,0,0), 0.9, 1, true);
    level.mapvote["ui"][2] = createShader("line_horizontal_scorebar", "TOP", "TOP", 0, 160, 350, 2, (1,1,1), 1, 2, true);
    level.mapvote["ui"][3] = createShader("white", "TOP", "TOP", 0, 160, 350, bgHeight, (0.5, 0.5 ,0.5), 0.5, 1, true);
    level.mapvote["ui"][4] = createShader("line_horizontal_scorebar", "TOP", "TOP", 0, hudsYaxis - 2, 350, 2, (1,1,1), 1, 2, true);
    level.mapvote["ui"][5] = createShader("black", "TOP", "TOP", 0, hudsYaxis, 350, 20, (0,0,0), 0.7, 1, true);
    level.mapvote["ui"][6] = createText("Up [{+actionslot 1}]/[{+speed_throw}] - Down [{+actionslot 2}]/[{+attack}] - Vote [{+gostand}]/[{+reload}]", "LEFT", "TOP", -170, hudsYaxis + 10, 1, "objective", (1,1,1), 1, 3, true);
    for(i = 0; i < level.mapvote["menusize"]; i++){ level.mapvote["ui"][i + 7] = createText(mapToString(strTok(level.mapvote["index"][i],",")[0], strTok(level.mapvote["index"][i],",")[1]), "RIGHT", "TOP", 170, textYaxis, 1, "objective", (1,1,1), 1, 3, true); textYaxis += 20; }
}

startVotingTimer()
{
    for(i = 0; i <= level.mapvote["timer"]; i++)
    {
        if(i >= (level.mapvote["timer"] - 5))
        {
            level.mapvote["ui"][0].label = &"VOTING PHASE: ^1";
            playSoundOnPlayers("claymore_activated");
        }
        wait 1;
    }
}

determineWinningMap()
{
    level.num = -1;
    for(i = 0; i < level.mapvote["menusize"]; i++) 
    {
        if(level.mapvote["ui"][i + 7].value > level.num)
        {
            level.int = i;
            level.num = level.mapvote["ui"][i + 7].value;
        }
    }
	if(isDedicatedServer())
	{
		setDvar("sv_maprotation", "gametype " + strTok(level.mapvote["index"][level.int], ",")[1] + " map " + strTok(level.mapvote["index"][level.int], ",")[0]);   
		setDvar("sv_maprotationcurrent", "gametype " + strTok(level.mapvote["index"][level.int], ",")[1] + " map " + strTok(level.mapvote["index"][level.int], ",")[0]);		
	}
	else
	{
		setDvar("g_gametype", strTok(level.mapvote["index"][level.int], ",")[1]);
		wait 0.05; // Gives the game time to properly set the gametype
		map(strTok(level.mapvote["index"][level.int], ",")[0], false);
	}
}

buttonMonitoring() 
{
    self endon("disconnect");
    level endon("mapvote_over");

    index = 0;
    selected = -1;
    scrollbar = self createShader("popup_button_selection_bar", "TOP", "TOP", 0, 160, 347, 20, (0, 0, 0), 0.9, 2, false);

    self freezeControlsWrapper( true );
    self thread destroyScrollbar(scrollbar);

	/* 
		Shorter Button Monitoring 
	*/
	inputs = strTok(
		"up|+toggleads_throw;up|+speed_throw;up|+forward;up|+actionslot 1;" +
		"down|+attack;down|+back;down|+actionslot 2;" +
		"select|+activate;select|+gostand;select|+usereload",
		";"
	);

	foreach (bind in inputs)
	{
		splits = strTok(bind, "|");
		self notifyOnPlayerCommand(splits[0], splits[1]);
	}

    while(true)
    {
        command = self waittill_any_return("up", "down", "select"); 

        if(command == "up" && index >= 0) 
        {
            if(index < 1)
			{
                index = (level.mapvote["menusize"] - 1);
                scrollbar.y = 160 + (level.mapvote["menusize"] - 1) * 20;
            }
			else
			{
                index--;
                scrollbar.y -= 20;
            }
            self playLocalSound("mouse_over");
        } 
        else if(command == "down" && index <= (level.mapvote["menusize"] - 1))
        {   
            if(index > (level.mapvote["menusize"] - 2))
			{
                index = 0;
                scrollbar.y = 160;
            } 
			else
			{
                index++;
                scrollbar.y += 20;
            }
            self playLocalSound("mouse_over");
        } 
        else if(command == "select")
        {
            if(selected == -1) 
            {
                selected = index;
                self updateVoteSelection(selected, 1, "^1");
                self playLocalSound("mouse_click");
            } 
            else if(selected != index)
            {                
                updateVoteSelection(selected, -1, "^7");
                selected = index;
                updateVoteSelection(selected, 1, "^1");
                self playLocalSound("mouse_click");
            }
        }        
    }
}

destroyScrollbar(hud)
{
    self endon("disconnect");
    
    level waittill("mapvote_over");
    hud destroyElem();
}

updateVoteSelection(selected, valueChange, color)
{
    level.mapvote["ui"][selected + 7].value += valueChange;
    level.mapvote["ui"][selected + 7].text = strTok(level.mapvote["ui"][selected + 7].text, ":")[0] + ": " + color + level.mapvote["ui"][selected + 7].value;
    level.mapvote["ui"][selected + 7] _setText(level.mapvote["ui"][selected + 7].text);
}

/*
    Cleaned this up vs old version
*/

mapToString(map, type)
{
    mapNames = [];
    gameTypes = [];

    mapString = ""
    + "mp_abandon|[^3MW2^7] Carnival;mp_afghan|[^3MW2^7] Afghan;mp_boneyard|[^3MW2^7] Scrapyard;"
    + "mp_brecourt|[^3MW2^7] Wasteland;mp_checkpoint|[^3MW2^7] Karachi;mp_compact|[^3MW2^7] Salvage;"
    + "mp_complex|[^3MW2^7] Bailout;mp_derail|[^3MW2^7] Derail;mp_estate|[^3MW2^7] Estate;"
    + "mp_estate_tropical|[^3MW2^7] Estate Tropical;mp_favela|[^3MW2^7] Favela;"
    + "mp_fav_tropical|[^3MW2^7] Favela Tropical;mp_fuel2|[^3MW2^7] Fuel;mp_highrise|[^3MW2^7] Highrise;"
    + "mp_invasion|[^3MW2^7] Invasion;mp_nightshift|[^3MW2^7] Skidrow;oilrig|[^3MW2^7] Oil Rig;"
    + "mp_quarry|[^3MW2^7] Quarry;mp_rundown|[^3MW2^7] Rundown;mp_rust|[^3MW2^7] Rust;"
    + "mp_rust_long|[^3MW2^7] Rust Long;mp_subbase|[^3MW2^7] Sub Base;mp_terminal|[^3MW2^7] Terminal;"
    + "mp_trailerpark|[^3MW2^7] Trailer Park;mp_underpass|[^3MW2^7] Underpass;mp_storm|[^3MW2^7] Storm;"
    + "mp_storm_spring|[^3MW2^7] Chemical Plant;"
    + "mp_alpha|[^2MW3^7] Lockdown;mp_bravo|[^2MW3^7] Mission;mp_dome|[^2MW3^7] Dome;"
    + "mp_hardhat|[^2MW3^7] Hardhat;mp_paris|[^2MW3^7] Resistance;mp_plaza2|[^2MW3^7] Arkaden;"
    + "mp_seatown|[^2MW3^7] Seatown;mp_underground|[^2MW3^7] Underground;mp_village|[^2MW3^7] Village;"
    + "mp_backlot|[^6COD4^7] Backlot;mp_bloc|[^6COD4^7] Bloc;mp_bloc_sh|[^6COD4^7] Forgotten City;"
    + "mp_bog_sh|[^6COD4^7] Bog;mp_broadcast|[^6COD4^7] Broadcast;mp_carentan|[^6COD4^7] Chinatown;"
    + "mp_cargoship|[^6COD4^7] Wet Work;mp_cargoship_sh|[^6COD4^7] Freighter;mp_citystreets|[^6COD4^7] District;"
    + "mp_convoy|[^6COD4^7] Ambush;mp_countdown|[^6COD4^7] Countdown;mp_crash|[^6COD4^7] Crash;"
    + "mp_crash_snow|[^6COD4^7] Winter Crash;mp_crash_tropical|[^6COD4^7] Crash Tropical;"
    + "mp_cross_fire|[^6COD4^7] Crossfire;mp_farm|[^6COD4^7] Downpour;mp_killhouse|[^6COD4^7] Killhouse;"
    + "mp_overgrown|[^6COD4^7] Overgrown;mp_pipeline|[^6COD4^7] Pipeline;mp_shipment|[^6COD4^7] Shipment;"
    + "mp_shipment_long|[^6COD4^7] Shipment Long;mp_showdown|[^6COD4^7] Showdown;mp_strike|[^6COD4^7] Strike;"
    + "mp_vacant|[^6COD4^7] Vacant;mp_firingrange|[^5BO1^7] Firing Range;mp_nuked|[^5BO1^7] Nuketown;"
    + "mp_rasalem|Rasalem;mp_winter_rasalem|Rasalem Winter;mp_csgo_monastery|Monastery";

    mapList = strTok(mapString, ";");
    for (i = 0; i < mapList.size; i++)
    {
        parts = strTok(mapList[i], "|");
        if (isDefined(parts) && parts.size == 2)
            mapNames[parts[0]] = parts[1];
    }

    gameTypeString = "arena|(Arena);conf|(Kill Confirmed);ctf|(Capture The Flag);dd|(Demolition);dm|(Free For All);"
    + "dom|(Domination);gtnw|(Global ThermoNuclear War);gun|(Gun Game);infect|(Infected);"
    + "koth|(Headquarters);oneflag|(One Flag CTF);sab|(Sabotage);sd|(Search & Destroy);"
    + "vip|(VIP);war|(Team Deathmatch)";

    gameList = strTok(gameTypeString, ";");
    for (i = 0; i < gameList.size; i++)
    {
        parts = strTok(gameList[i], "|");
        if (isDefined(parts) && parts.size == 2)
            gameTypes[parts[0]] = " - " + parts[1] + " : 0";
    }

    mapName = map;
    if (isDefined(mapNames[map]))
        mapName = mapNames[map];

    gameTypeSuffix = " - (" + type + ") : 0";
    if (isDefined(gameTypes[type]))
        gameTypeSuffix = gameTypes[type];

    return mapName + gameTypeSuffix;
}

createText(text, align, relative, x, y, fontscale, font, color, alpha, sort, server, timer) 
{
    if(server)
    {
        if(isdefined(timer))
            fontElem = createServerTimer( font, fontscale );
        else
            fontElem = createServerFontString( font, fontscale ); 
    }
    else 
        fontElem = self createFontString( font, fontscale ); 

    fontElem.hidewheninmenu = true;
    fontElem.foreground = true;
    fontElem.color = color;
    fontElem.alpha = alpha;
    fontElem.sort = sort;
    fontElem setpoint(align, relative, x, y);

    if(isdefined(timer))
    {
        fontElem.label = text;
        fontElem setTimer(timer);
    } 
    else 
    {
        fontElem.text = text;
        fontElem.value = 0;
        fontElem _setText(text); 
    }
    return fontElem;
}

createShader(shader, align, relative, x, y, width, height, color, alpha, sort, server) 
{
    if(server) 
        iconElem = createServerIcon( shader, width, height );
    else
        iconElem = self createIcon( shader, width, height );

    iconElem.hidewheninmenu = true;
    iconElem.foreground = true;
    iconElem.align = align;
    iconElem.relative = relative;
    iconElem.sort = sort;
    iconElem.color = color;
    iconElem.alpha = alpha;
    iconElem setPoint(align, relative, x, y);

    return iconElem;
}

arrayHasDuplicates(array, isString)
{
    if (!isDefined(array) || array.size <= 1)
        return false;

    seen = [];

    foreach (item in array)
    {
        value = item;
        if (isDefined(isString) && isString)
            value = toLower(item);

        if (isDefined(seen[value]))
            return true;

        seen[value] = true;
    }
    return false;
}

removeDuplicates(array, isString)
{
    seen = [];
    result = [];

    foreach (item in array)
    {
        value = item;
        if (isDefined(isString) && isString)
            value = toLower(item);

        if (!isDefined(seen[value]))
        {
            seen[value] = true;
            result[result.size] = value;
        }
    }
    return result;
}

isDedicatedServer()
{
    if(!getDvarInt( "party_host" ))
        return true;
    
    return false;
}

isInt(value)
{
    if(int(value) == value)
        return true;
    
    return false;
}

isInArray(array, item) 
{
    if(!isDefined(array) || array.size == 0)
        return false;

    for(a = 0; a < array.size; a++)
        if(array[a] == item)
            return true;

    return false;
}

/*
	Rehooks
*/

endGameHook( winner, endReasonText, nukeDetonated )
{
	if ( !isDefined(nukeDetonated) )
		nukeDetonated = false;
	
	// return if already ending via host quit or victory, or nuke incoming
	if ( game["state"] == "postgame" || level.gameEnded || (isDefined(level.nukeIncoming) && !nukeDetonated) && ( !isDefined( level.gtnw ) || !level.gtnw ) )
		return;

	game["state"] = "postgame";

	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;
	level notify ( "game_ended", winner );
	levelFlagSet( "game_over" );
	levelFlagSet( "block_notifies" );
	waitframe(); // give "game_ended" notifies time to process
	
	setGameEndTime( 0 ); // stop/hide the timers
	
	maps\mp\gametypes\_playerlogic::printPredictedSpawnpointCorrectness();
	
	if ( isDefined( winner ) && isString( winner ) && winner == "overtime" )
		return maps\mp\gametypes\_gamelogic::endGameOvertime( winner, endReasonText );
	
	if ( isDefined( winner ) && isString( winner ) && winner == "halftime" )
		return maps\mp\gametypes\_gamelogic::endGameHalftime();

	game["roundsPlayed"]++;
	
	if ( level.teamBased )
	{
		if ( winner == "axis" || winner == "allies" )
			game["roundsWon"][winner]++;

		maps\mp\gametypes\_gamescore::updateTeamScore( "axis" );
		maps\mp\gametypes\_gamescore::updateTeamScore( "allies" );
	}
	else
	{
		if ( isDefined( winner ) && isPlayer( winner ) )
			game["roundsWon"][winner.guid]++;
	}
	
	maps\mp\gametypes\_gamescore::updatePlacement();

	maps\mp\gametypes\_gamelogic::rankedMatchUpdates( winner );

	foreach ( player in level.players )
		player setClientDvar( "ui_opensummary", 1 );
	
	setDvar( "g_deadChat", 1 );
	setDvar( "ui_allow_teamchange", 0 );

	// freeze players
	foreach ( player in level.players )
	{
		player thread maps\mp\gametypes\_gamelogic::freezePlayerForRoundEnd( 1.0 );
		player thread maps\mp\gametypes\_gamelogic::roundEndDoF( 4.0 );
		
		player maps\mp\gametypes\_gamelogic::freeGameplayHudElems();

		player setClientDvars( "cg_everyoneHearsEveryone", 1 );
		player setClientDvars( "cg_drawSpectatorMessages", 0,
							   "g_compassShowEnemies", 0 );
							   
		if ( player.pers["team"] == "spectator" )
			player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
	}

    if( !nukeDetonated )
		visionSetNaked( "mpOutro", 0.5 );
	
	// End of Round
	if ( !wasOnlyRound() && !nukeDetonated )
	{
		setDvar( "scr_gameended", 2 );
	
		maps\mp\gametypes\_gamelogic::displayRoundEnd( winner, endReasonText );

		if ( level.showingFinalKillcam )
		{
			foreach ( player in level.players )
				player notify ( "reset_outcome" );

			level notify ( "game_cleanup" );

			maps\mp\gametypes\_gamelogic::waittillFinalKillcamDone();
		}
				
		if ( !wasLastRound() )
		{
			levelFlagClear( "block_notifies" );
			if ( maps\mp\gametypes\_gamelogic::checkRoundSwitch() )
				maps\mp\gametypes\_gamelogic::displayRoundSwitch();

			foreach ( player in level.players )
				player.pers["stats"] = player.stats;

        	level notify ( "restarting" );
            game["state"] = "playing";
            map_restart( true );
            return;
		}
		
		if ( !level.forcedEnd )
			endReasonText = maps\mp\gametypes\_gamelogic::updateEndReasonText( winner );
	}

	setDvar( "scr_gameended", 1 );
	
	if ( !isDefined( game["clientMatchDataDef"] ) )
	{
		game["clientMatchDataDef"] = "mp/clientmatchdata.def";
		setClientMatchDataDef( game["clientMatchDataDef"] );
	}

	maps\mp\gametypes\_missions::roundEnd( winner );

	maps\mp\gametypes\_gamelogic::displayGameEnd( winner, endReasonText );

	if ( level.showingFinalKillcam && wasOnlyRound() )
	{
		foreach ( player in level.players )
			player notify ( "reset_outcome" );

		level notify ( "game_cleanup" );

		maps\mp\gametypes\_gamelogic::waittillFinalKillcamDone();
	}

	levelFlagClear( "block_notifies" );

	level.intermission = true;

	level notify ( "spawning_intermission" );
	
	foreach ( player in level.players )
	{
        player closeMenus();
		player notify ( "reset_outcome" );
    }

	while(level.showingFinalKillcam)
		waitframe();
    
    mapVote(); // Removed Dedicated Server Check

    foreach ( player in level.players )
		player thread maps\mp\gametypes\_playerlogic::spawnIntermission();

	maps\mp\gametypes\_gamelogic::processLobbyData();

	wait ( 1.0 );

	if ( matchMakingGame() )
		sendMatchData();

	foreach ( player in level.players )
		player.pers["stats"] = player.stats;

	logString( "game ended" );
	if( !nukeDetonated && !level.postGameNotifies )
	{
		if ( !wasOnlyRound() )
			wait 6.0;
		else
			wait 3.0;
	}
	else
		wait ( min( 10.0, 4.0 + level.postGameNotifies ) );

	level notify( "exitLevel_called" );
	exitLevel( false );
}

spawnIntermissionHook()
{
	self endon( "disconnect" );
	
	self notify( "spawned" );
	self notify( "end_respawn" );
	
	self maps\mp\gametypes\_playerlogic::setSpawnVariables();
	self closeMenus();
	
	self clearLowerMessages();
	
	self freezeControlsWrapper( true );
	
	self setClientDvar( "cg_everyoneHearsEveryone", 1 );

    if(isDefined(level.inVoting) && level.inVoting) // Late joiners after intermission
    {
        if(!self isTestClient())
            self thread buttonMonitoring();

        level waittill("mapvote_over");
    }
    else if(game["state"] == "postgame" && (isDefined(level.intermission) && !level.intermission)) // We're in the victory screen, but before intermission
		level waittill("mapvote_over");

	if ( level.rankedMatch && ( self.postGamePromotion || self.pers["postGameChallenges"] ) )
	{
		if ( self.postGamePromotion )
			self playLocalSound( "mp_level_up" );
		else
			self playLocalSound( "mp_challenge_complete" );

		if ( self.postGamePromotion > level.postGameNotifies )
			level.postGameNotifies = 1;

		if ( self.pers["postGameChallenges"] > level.postGameNotifies )
			level.postGameNotifies = self.pers["postGameChallenges"];

		self closeMenus();	

		self openMenu( game["menu_endgameupdate"] );

		waitTime = 4.0 + min( self.pers["postGameChallenges"], 3 );		
		while ( waitTime )
		{
			wait ( 0.25 );
			waitTime -= 0.25;

			self openMenu( game["menu_endgameupdate"] );
		}
		
		self closeMenu( game["menu_endgameupdate"] );
	}
	
	self.sessionstate = "intermission";
	self ClearKillcamState();
	self.friendlydamage = undefined;
	
	spawnPoints = getEntArray( "mp_global_intermission", "classname" );
	assertEx( spawnPoints.size, "NO mp_global_intermission SPAWNPOINTS IN MAP" );

	spawnPoint = spawnPoints[0];
	self spawn( spawnPoint.origin, spawnPoint.angles );
	
	self maps\mp\gametypes\_playerlogic::checkPredictedSpawnpointCorrectness( spawnPoint.origin );
	
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}

onMenuResponseHook()
{
	self endon("disconnect");
    level endon("round_end_finished"); // stops properly on round end
	
	while(true)
	{
		self waittill("menuresponse", menu, response);
		
		if ( response == "endround" )
            exitLevel( false );
    }
}

onPlayerCommandHook()
{
    self endon("disconnect");
    level endon("round_end_finished"); // stops properly on round end

    self notifyOnPlayerCommand("force_end", "+endgame");
    while(true)
    {
        self waittill("force_end");
        thread maps\mp\gametypes\_gamelogic::endGame( self.team, game["strings"]["time_limit_reached"], true );
    }
}

/*
	Overflow fix: Can be used on console - otherwise I'd use clearhudtext();
*/

OverflowFixInit() 
{
    level.strings = [];
    level.overflowElem = CreateServerFontString("default", 1.5);
    level.overflowElem _setText("");
    level.overflowElem.alpha = 0;
    level thread OverflowFixMonitor();
}

OverflowFixMonitor() 
{
    level endon("game_ended");
    while(true) 
    {
        level waittill("string_added");
        if(level.strings.size >= 55) 
        {
            level.overflowElem ClearAllTextAfterHudElem();
            level.strings = [];
            level notify("overflow_fixed");
            wait 0.05;
        }
    }
}

_setText(text) 
{
    self.string = text;
    self setText(text);
    self childthread fix_string();
    self add_string(text);
}

add_string(string) 
{
    level.strings[level.strings.size] = string;
    level notify("string_added");
}

fix_string() 
{
    self notify("new_string");
    self endon("new_string");
    while(isDefined(self)) 
    {
        level waittill("overflow_fixed");
        self _setText(self.string);
    }
}