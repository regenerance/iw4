<img width="848" height="412" alt="image" src="https://github.com/user-attachments/assets/a6308f58-c5ee-467a-be13-0163ca61b255" />

Tired of breaking weaponfiles with Notepad? This tool edits IW4x/MW2 weapon files safely while keeping **ALL fields + order intact** (including empty `\\` values).

**Features**
* :white_check_mark: Full field list editor (schema/order safe)
* :mag_right: **Find + Find Next** (case-insensitive)
* :repeat: **Search + Replace** (batch replace + undo support)
* :leftwards_arrow_with_hook: Undo / Redo
* :recycle: Reset Field / Reset All (factory reset to original)
* :brain: Handles empty values correctly (`dpadIcon\\` etc)
* :pencil: `hideTags` editor (multiline for easy spacing)
* :floppy_disk: Save overwrite + auto **.bak backup**
* :floppy_disk: Save_custom copy option
* :loud_sound: Success/Error sounds + splash screen

**How to use**
1. Put `WeaponFileEditor.py` (and optional `splash.png`) in a folder
2. Run: `python WeaponFileEditor.py` or use a IDE of your choice to run it.
3. **Open** your weapon file (ex: `riotshield_mp`)
4. Edit values → Apply / Replace → Save (backup made automatically)

**Optional Item: Build the script as an .exe (one line) **
`pyinstaller --onefile --noconsole --name "WeaponFileEditor" --icon=customiconhere WeaponFileEditor.py`

If you find bugs or want features added, feel free to respond to this thread.
