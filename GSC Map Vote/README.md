# 🗳️ IW4x Dynamic Map Voting System

Originally created by **eternalhabit** and updated by **Antiga**, this script introduces a simple, yet effective and customizable **Map Vote UI** system for IW4x servers and private match.

---

# ⚠️ Installation

This script can be installed on servers and clients, when installed locally it will only work in private matches.

Place it in **userraw/scripts/_mv.gsc**

---

## 🎮 Key Features

- ✅ Supports **all base** and **custom maps & game modes**
- 🎛️ Dynamically adjusts the number of voting options (2–6)
- 🚫 Restrict specific modes from running on certain maps
- 🧠 Automatically removes duplicate vote entries
- 💬 Late joiners can still vote mid-session
- 🖱️ Supports **Mouse & Keyboard** and **Controllers**
- ⚙️ Reverts to default settings if dvars are misconfigured
- 📦 Leverages **custom DVARs** for deep configurability
- 🖼️ Clean, modern **MW2-style UI**

---

## 🕹️ In-Game Controls

| Action       | Button (Mouse & Keyboard) | Button (Controller)       |
|--------------|----------------------------|----------------------------|
| Scroll Up    | `W` / `Aim`              | `D-Pad Up`                 |
| Scroll Down  | `S` / `Shoot`                | `D-Pad Down`               |
| Cast Vote    | `Reload` / `Jump`          | `Reload` / `Jump`          |

---

## ⚙️ Server DVAR Configuration

Make sure to include these in your `server.cfg` or similar .cfg you use to execute for your server:

```cfg
// Basic Configuration
set mapvote_enable "1" // 1 for on and 0 for off
set mapvote_timer "30"
set mapvote_optionsCount "6"         // Between 2 and 6 options

// Map Pool
set mapvote_maps "mp_afghan,mp_boneyard,mp_brecourt,mp_checkpoint,mp_derail,mp_estate,mp_favela,mp_highrise,mp_invasion,mp_nightshift,mp_quarry,mp_rundown,mp_rust,mp_subbase,mp_terminal,mp_underpass,mp_abandon,mp_compact,mp_complex,mp_estate_tropical,mp_fav_tropical,mp_fuel2,mp_rust_long,mp_storm,mp_storm_spring,mp_trailerpark,mp_alpha,mp_backlot,mp_bloc,mp_bloc_sh,mp_bog_sh,mp_bravo,mp_broadcast,mp_carentan,mp_cargoship,mp_cargoship_sh,mp_citystreets,mp_convoy,mp_countdown,mp_crash,mp_crash_snow,mp_crash_tropical,mp_cross_fire,mp_dome,mp_farm,mp_firingrange,mp_hardhat,mp_killhouse,mp_nuked,mp_overgrown,mp_paris,mp_pipeline,mp_plaza2,mp_seatown,mp_shipment,mp_shipment_long,mp_showdown,mp_strike,mp_underground,mp_vacant,mp_village"
set mapvote_customMaps ""

// Mode Pool
set mapvote_modes "war,dom,conf,dm,sd"

// Advanced Restrictions
set mapvote_disable_broken_modes "0" // 1 = ON, 0 = OFF
set mapvote_restricted_maps ""       // Maps that need mode restrictions
set mapvote_restricted_modes ""      // Modes to exclude for restricted maps
```

> **📌 IMPORTANT**  
> When adding maps outside of the base IW4x pool, include them only in `mapvote_customMaps`. Separate each entry with a comma — no spaces!

---

## 🎯 Game Mode Aliases

Here are the recognized internal names for game modes:

| Name     | Description                   |
|----------|-------------------------------|
| `war`    | Team Deathmatch               |
| `dom`    | Domination                    |
| `conf`   | Kill Confirmed                |
| `dm`     | Free For All                  |
| `sd`     | Search and Destroy            |
| `ctf`    | Capture the Flag              |
| `sab`    | Sabotage                      |
| `koth`   | Headquarters Pro              |
| `gun`    | Gun Game                      |
| `infect` | Infected                      |
| `arena`  | Arena                         |
| `oneflag`| One-Flag CTF                  |
| `gtnw`   | Global Thermo-Nuclear War     |
| `vip`    | VIP                           |
| `dd`     | Demolition                    |

---

## 🔧 Enhancements by Antiga

- ✅ Enabled support for **private match**
- 🎬 Final killcam wait logic & failsafe mechanism
- 🔘 Added `mapvote_enable` toggle
- 🧹 Bot cleanup during vote phase for performance
- 🔄 Improved `buttonMonitoring` logic and layout
- 🧠 Rewrote `mapToString` using `strTok` for cleaner parsing
- 🔊 Adjusted vote timer countdown sound for better experience
- 🧯 Basic overflow safeguard for HUD elements

---

## 💡 Credits

- **eternalhabit** – Original creator  
- **Antiga** – Script updates, optimizations, and private match support

---

## 🧪 Notes

- Some custom maps/modes (like GTNW or Demolition on COD4 maps) may require `mapvote_disable_broken_modes` set to `1`.

---

## 📸 PREVIEW

![image](https://github.com/user-attachments/assets/2bd29c58-27a9-49a7-b58a-b659fc518ff1)

---