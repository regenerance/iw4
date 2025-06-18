#include common_scripts\utility;
#include maps\mp\_utility;

/*
	Simple Map Vote Developed By Antiga
		- Credits:
			- Inphect: Loved the simplistic look of his old map voting, make it look similar 
			- Simon: For making redux in the past, I made similar macros for the .menu to function (inspired by redux.inc)
			- Myself: For re-writting, simplifying, and making this work for servers/private match
		
		- Features:
			- Simple UI for .menu (allows controller + mouse input)
			- Works on Server or Private Matches
			- Loads the maps of your choice in scriptdata\map_list.cfg - you may add more (but must update the map_table.csv to match)
			- Minimal code to ensure better performance
*/

init()
{
	game["voting_active"] = false;
	game["vote_maps"] = [];
	game["vote_timing"] = 25;

	if ( !fileExists( "map_list.cfg" ) )
		return format_console_print( "Voting Call", "map_list.cfg not found - stopping function..." );

	map_config = strTok( fileRead( "map_list.cfg" ), "\r\n" );
	map_config = array_remove( map_config, level.script );

	if ( map_config.size < 3 )
		return format_console_print( "Voting Call", "map_list.cfg does not have enough maps listed - stopping function..." );

	for ( i = 0; i < 3; i++ )
	{
		possible_map = map_config[ randomInt( map_config.size ) ];
		game["vote_maps"][i] = spawnStruct();
		game["vote_maps"][i].ID = possible_map;
		game["vote_maps"][i].votes = 0;

		map_config = array_remove( map_config, possible_map );
		makeDvarServerInfo( "map_vote_id_" + i, game["vote_maps"][i].ID );
		makeDvarServerInfo( "map_vote_count_" + i, 0 );
	}

	// Precache's Our Map Vote Menu
	preCacheMenu("map_vote");

	// Auto Triggers Map Voting Menu On Game End
    replaceFunc( maps\mp\gametypes\_gamelogic::processLobbyData, ::processLobbyDataHook );
	
	// Safety for buttons not working duing init_map_vote (rare, but happened during testing...)
	level thread onPlayerConnectHook();
}

onPlayerConnectHook()
{
	while(true)
	{
		level waittill("connected", player);
		if(!player isTestClient())
			player thread menu_response();
	}
}

init_map_vote()
{
	game["voting_active"] = true;

	foreach ( player in level.players )
	{
		if ( player isTestClient() )
			kick( player getEntityNumber() ); // Kicks bots for safety reasons

		player.vote_id = undefined;
		player.sessionstate = "spectator";
		player thread monitor_disconnect();
		waitframe();
		player openPopupMenu( "map_vote" );
	}

	thread vote_timer(game["vote_timing"]);
	wait game["vote_timing"];
	map( get_winning_map() ); // Allows Map Voting to work in Private Match or Servers
}

vote_timer(time)
{
	while(time)
	{
		makeDvarServerInfo("timer_text", "VOTING ENDS IN: " + time);

		foreach(player in level.players)
			player PlaySoundToPlayer( "ui_mp_timer_countdown", player );

		wait 1;
		time--;
	}
}

get_winning_map()
{
	game["voting_active"] = false;
	winner = game["vote_maps"][0];

	for ( i = 1; i < 3; i++ )
	{
		if ( isDefined( game["vote_maps"][i] ) && game["vote_maps"][i].votes > winner.votes )
			winner = game["vote_maps"][i];
	}

	if(is_dedicated_server()) // Only sets SERVER DVARS if it's a dedicated server
	{
		setDvar( "sv_mapRotation", "map " + winner.ID );
		setDvar( "sv_mapRotationCurrent", "map " + winner.ID );		
	}

	return winner.ID;
}

monitor_disconnect()
{
	self waittill( "disconnect" );

	if ( isDefined( self.vote_id ) )
	{
		game["vote_maps"][self.vote_id].votes--;
		makeDvarServerInfo( "map_vote_count_" + self.vote_id, game["vote_maps"][self.vote_id].votes );
	}
}

record_vote( idx )
{
	if ( !game["voting_active"] )
		return;

	if ( isDefined( self.vote_id ) && idx == self.vote_id )
		return;

	if ( idx > 3 || idx < 0 )
		return;

	game["vote_maps"][self.vote_id].votes--;
	game["vote_maps"][idx].votes++;

	makeDvarServerInfo( "map_vote_count_" + self.vote_id, game["vote_maps"][self.vote_id].votes );
	makeDvarServerInfo( "map_vote_count_" + idx, game["vote_maps"][idx].votes );

	self.vote_id = idx;
}

menu_response()
{
    self endon( "disconnect" );
    
    while(true)
    {
        self waittill( "menuresponse", menu, response );

        if ( isSubStr( response, "record_vote" ) )
            self record_vote( int( strTok( response, ":" )[1] ) );
	}
}

/*
	Hooks
*/

processLobbyDataHook()
{
	curPlayer = 0;

	foreach ( player in level.players )
	{
		if ( !isDefined( player ) )
			continue;

		player.clientMatchDataId = curPlayer;
		curPlayer++;

		setClientMatchData( "players", player.clientMatchDataId, "xuid", player.name );
	}

	maps\mp\_awards::assignAwards();
	maps\mp\_scoreboard::processLobbyScoreboards();

	sendClientMatchData();
	waitframe();
	
	if ( matchMakingGame() )
		sendMatchData();

	foreach ( player in level.players )
		player.pers["stats"] = player.stats;

	// Allows killcam to fully play through
	while(level.showingFinalKillcam)
		waitframe();

	init_map_vote(); // Calls our Map Voting Function
}

/*
	Utilities
*/

format_console_print( topic, msg )
{
	assertMsg("[" + topic + "] - " + "[" + msg + "]");
}

is_dedicated_server()
{
    if(!getDvarInt( "party_host" ))
        return true;
	
    return false;
}