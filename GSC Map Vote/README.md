I am sharing a new **map voting script** for the IW4x community. This has the most common gametypes: TDM, DOM, S&D, and FFA. It is super easy to add new gametypes, maps, etc too, I have included instructions below.

## Features :100: 
- End-game map voting (nuke + killcam support)
- Clean HUD with blurred cinematic background + animation
- Random Map option
- Vote counting + disconnect cleanup
- Base maps + optional DLC
- Optional S&D / FFA gametype support
- Dedicated server rotation support
- Recent maps are not filtered, selection is fully random
- Controls are: Ads, Reload, and Fire Buttons (Controller and Keyboard) agnostic
- Overflow fix for clients implemented

## Server DVARs
Add/edit these in your server config:
```
set scr_mapvote_enable 1
set scr_mapvote_time 20
set scr_mapvote_allow_dlc 0
set scr_mapvote_options 6
set scr_mapvote_change_delay 3
set scr_mapvote_snd_allowed 0
set scr_mapvote_ffa_allowed 0
```
## DVAR Info
```
scr_mapvote_enable        // 1 = enabled, 0 = disabled
scr_mapvote_time          // voting time in seconds
scr_mapvote_allow_dlc     // 1 = allow DLC maps, 0 = base maps only
scr_mapvote_options       // number of vote options, clamped between 2-6
scr_mapvote_change_delay  // delay before changing map after winner
scr_mapvote_snd_allowed   // 1 = allow Search & Destroy
scr_mapvote_ffa_allowed   // 1 = allow Free-for-All
```
## Adding Maps :map: 
Find the function: ***mapvote_add_map *** - Edit the map pool function and add maps like this:
```
mapvote_add_map("mp_terminal", "Terminal", false);
```
Maps marked as true only appear when DLC maps are enabled:
```
set scr_mapvote_allow_dlc 1
```
## Adding Gametypes :tools: 
Find the function: ***mapvote_add_gametype*** - Edit the gametype function and add modes like this:
```
mapvote_add_gametype("war", "TDM");
```
## Install :white_check_mark: 
Place the script in your userraw\scripts setup

## Report Bugs Or Request Feature Enhancements :lady_beetle: 
Please report any bugs or issues in this post.
