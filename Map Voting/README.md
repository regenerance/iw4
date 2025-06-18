# 🗳️ Simple Map Vote for IW4x

A clean and functional in-game map vote system designed for **dedicated servers** and **private matches**.

***THIS IS A MOD! Requires the files to be loaded via a mod so clients can download them!***

---

## 💡 Features

- 🎮 Simple UI using `.menu` (supports both controller & mouse input)
- 🖥️ Compatible with **servers** and **private matches**
- 📜 Loads maps from `scriptdata/map_list.cfg`
  - Add more maps as needed!
  - Just make sure to update `map_table.csv` to match
- ⚡ Minimal code for better performance and maintainability

---

## 🙌 Credits

- **Inphect** – For the clean look of his older map vote system
- **Simon** – Redux-inspired macros and menu architecture
- **Antiga (me)** – Fully rewritten, optimized, and tailored for Dedicated/Private Matches

---

## 📂 Setup

1. Add your desired map names to: **scriptdata/map_list.cfg**
- Format will be like: mp_mapnamehere
2. Make sure each entry has a corresponding line in: **tables/map_table.csv**
- **Key Note: You must open the IWD to edit this file!**
- Format will be like: mp_mapname,Map Name

✅ That’s it! Launch your server or host a private match and let the voting begin.

---

> Made with ❤️ for the IW4x community.