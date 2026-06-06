import tkinter as tk
from tkinter import filedialog, messagebox
from collections import OrderedDict
import copy
import os
import winsound

# ================= THEME (MW2 GREEN) =================
BG = "#0f1410"
GLASS_BG = "#151b16"
BORDER = "#2e3b31"
LIST_BG = "#121812"

FIELD_BG = "#0d120e"
CURRENT_BG = "#141a15"
ORIGINAL_BG = "#101511"

FIELD_FG = "#8fa68f"
VALUE_FG = "#c7e3c7"
ORIGINAL_FG = "#9bb39b"

FG = "#d6e6d6"
ACCENT = "#5fbf7a"
ACCENT_ACTIVE = "#4aa364"

MODIFIED = "#b5e853"
EMPTY_COLOR = "#e0c070"

BUTTON_BG = "#1a221c"
BUTTON_HOVER = "#25352a"
BUTTON_ACTIVE = ACCENT_ACTIVE

EMPTY_DISPLAY = "<empty>"
MULTI_VALUE_FIELDS = {"hideTags"}


# ================= SPLASH SCREEN =================
def show_splash(root):
    splash = tk.Toplevel()
    splash.overrideredirect(True)
    splash.configure(bg=BG)

    width, height = 420, 220
    x = (splash.winfo_screenwidth() - width) // 2
    y = (splash.winfo_screenheight() - height) // 2
    splash.geometry(f"{width}x{height}+{x}+{y}")

    try:
        splash.iconbitmap("sesh.ico")
    except Exception:
        pass

    frame = tk.Frame(
        splash,
        bg=GLASS_BG,
        highlightbackground=BORDER,
        highlightthickness=1
    )
    frame.pack(expand=True, fill="both", padx=8, pady=8)

    try:
        img = tk.PhotoImage(file="splash.png")
        lbl = tk.Label(frame, image=img, bg=GLASS_BG)
        lbl.image = img
        lbl.pack(pady=(15, 10))
    except Exception:
        tk.Label(
            frame,
            text="IW4x Weapon File Editor",
            fg=ACCENT,
            bg=GLASS_BG,
            font=("Segoe UI", 16, "bold")
        ).pack(pady=(35, 10))

    tk.Label(
        frame,
        text="by Antiga",
        fg=FIELD_FG,
        bg=GLASS_BG,
        font=("Segoe UI", 10)
    ).pack()

    tk.Label(
        frame,
        text="Loading...",
        fg=ORIGINAL_FG,
        bg=GLASS_BG,
        font=("Segoe UI", 9)
    ).pack(pady=(10, 0))

    splash.update()
    return splash


# ================= MAIN APP =================
class WeaponEditorGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("IW4x Weapon File Editor by Antiga")
        self.root.configure(bg=BG)

        icon_path = os.path.join(os.path.dirname(__file__), "sesh.ico")
        if os.path.exists(icon_path):
            self.root.iconbitmap(icon_path)

        self.fields = OrderedDict()
        self.original_fields = OrderedDict()
        self.file_path = None

        self.undo_stack = []
        self.redo_stack = []

        self.search_matches = []
        self.search_pos = -1
        self.current_index = None

        self.build_ui()

    # ---------- SOUNDS ----------
    def sound_success(self):
        winsound.MessageBeep(winsound.MB_ICONASTERISK)

    def sound_error(self):
        winsound.MessageBeep(winsound.MB_ICONHAND)

    def sound_warning(self):
        winsound.MessageBeep(winsound.MB_ICONEXCLAMATION)

    # ---------- UI HELPERS ----------
    def entry(self, parent, width=20, fg=FG, bg=CURRENT_BG, readonly=False):
        e = tk.Entry(
            parent,
            bg=bg,
            fg=fg,
            insertbackground=fg,
            relief=tk.FLAT,
            highlightthickness=1,
            highlightbackground=BORDER,
            highlightcolor=ACCENT,
            readonlybackground=bg,
            disabledbackground=bg,
            width=width
        )
        if readonly:
            e.configure(state="readonly")
        return e

    def glass_button(self, parent, text, cmd):
        btn = tk.Button(
            parent,
            text=text,
            command=cmd,
            bg=BUTTON_BG,
            fg=FG,
            activebackground=BUTTON_ACTIVE,
            activeforeground="#000000",
            relief=tk.FLAT,
            padx=10,
            pady=4,
            highlightthickness=1,
            highlightbackground=BORDER,
            borderwidth=0
        )
        btn.bind("<Enter>", lambda e: btn.configure(bg=BUTTON_HOVER))
        btn.bind("<Leave>", lambda e: btn.configure(bg=BUTTON_BG))
        return btn

    def separator(self, parent):
        tk.Frame(parent, height=1, bg=BORDER).pack(fill=tk.X, pady=6)

    # ---------- BUILD UI ----------
    def build_ui(self):
        top = tk.Frame(self.root, bg=GLASS_BG, highlightbackground=BORDER, highlightthickness=1)
        top.pack(fill=tk.X, padx=8, pady=8)

        self.glass_button(top, "Open", self.open_file).pack(side=tk.LEFT)
        self.glass_button(top, "Save", self.save_overwrite).pack(side=tk.LEFT, padx=4)
        self.glass_button(top, "Save_custom", self.save_custom).pack(side=tk.LEFT, padx=4)
        self.glass_button(top, "Undo", self.undo).pack(side=tk.LEFT, padx=12)
        self.glass_button(top, "Redo", self.redo).pack(side=tk.LEFT)
        self.glass_button(top, "Reset ALL", self.reset_all).pack(side=tk.RIGHT)

        self.separator(self.root)

        sr = tk.Frame(self.root, bg=GLASS_BG, highlightbackground=BORDER, highlightthickness=1)
        sr.pack(fill=tk.X, padx=8)

        tk.Label(sr, text="Find", bg=GLASS_BG, fg=FG).pack(side=tk.LEFT)
        self.find_entry = self.entry(sr, width=25)
        self.find_entry.pack(side=tk.LEFT, padx=4)

        tk.Label(sr, text="Replace", bg=GLASS_BG, fg=FG).pack(side=tk.LEFT)
        self.replace_entry = self.entry(sr, width=25)
        self.replace_entry.pack(side=tk.LEFT, padx=4)

        self.glass_button(sr, "Find", self.start_search).pack(side=tk.LEFT, padx=6)
        self.glass_button(sr, "Find Next", self.find_next).pack(side=tk.LEFT)
        self.glass_button(sr, "Apply Replace", self.apply_replace).pack(side=tk.LEFT, padx=6)

        self.match_label = tk.Label(sr, text="Found: 0", bg=GLASS_BG, fg=FG)
        self.match_label.pack(side=tk.LEFT, padx=12)

        self.separator(self.root)

        self.listbox = tk.Listbox(
            self.root,
            bg=LIST_BG,
            fg=FG,
            selectbackground=ACCENT,
            selectforeground="#000000",
            font=("Consolas", 9),
            width=120,
            relief=tk.FLAT,
            highlightbackground=BORDER,
            highlightthickness=1
        )
        self.listbox.pack(fill=tk.BOTH, expand=True, padx=8)
        self.listbox.bind("<<ListboxSelect>>", self.on_select)

        self.separator(self.root)

        edit = tk.Frame(self.root, bg=GLASS_BG, highlightbackground=BORDER, highlightthickness=1)
        edit.pack(fill=tk.X, padx=8, pady=6)

        tk.Label(edit, text="Field", bg=GLASS_BG, fg=FIELD_FG).grid(row=0, column=0, sticky="e", padx=(0, 6))
        self.field_name = self.entry(edit, width=45, fg=FIELD_FG, bg=FIELD_BG, readonly=True)
        self.field_name.grid(row=0, column=1, padx=6)

        tk.Label(edit, text="Current Value", bg=GLASS_BG, fg=VALUE_FG).grid(row=1, column=0, sticky="e", padx=(0, 6))
        self.field_value_entry = self.entry(edit, width=65, fg=VALUE_FG, bg=CURRENT_BG)
        self.field_value_entry.grid(row=1, column=1, padx=6)

        self.field_value_text = tk.Text(
            edit,
            bg=CURRENT_BG,
            fg=VALUE_FG,
            height=3,
            width=65,
            relief=tk.FLAT,
            highlightthickness=1,
            highlightbackground=BORDER,
            highlightcolor=ACCENT,
            insertbackground=VALUE_FG
        )

        tk.Label(edit, text="Original Value", bg=GLASS_BG, fg=ORIGINAL_FG).grid(row=2, column=0, sticky="e", padx=(0, 6))
        self.original_value = self.entry(edit, width=65, fg=ORIGINAL_FG, bg=ORIGINAL_BG, readonly=True)
        self.original_value.grid(row=2, column=1, padx=6)

        btns = tk.Frame(edit, bg=GLASS_BG)
        btns.grid(row=3, column=1, sticky="e", pady=6)

        self.glass_button(btns, "Apply", self.apply_change).pack(side=tk.LEFT, padx=4)
        self.glass_button(btns, "Reset Field", self.reset_field).pack(side=tk.LEFT)

    # ---------- SEARCH / REPLACE ----------
    def start_search(self):
        term = self.find_entry.get().lower()
        self.search_matches.clear()
        self.search_pos = -1

        if not term:
            self.match_label.config(text="Found: 0")
            return

        for i, (k, v) in enumerate(self.fields.items()):
            if term in k.lower() or term in v.lower():
                self.search_matches.append(i)

        self.match_label.config(text=f"Found: {len(self.search_matches)}")
        self.find_next()

    def find_next(self):
        if not self.search_matches:
            return

        self.search_pos = (self.search_pos + 1) % len(self.search_matches)
        idx = self.search_matches[self.search_pos]

        self.listbox.selection_clear(0, tk.END)
        self.listbox.select_set(idx)
        self.listbox.see(idx)
        self.current_index = idx

    def apply_replace(self):
        if not self.search_matches:
            return

        find = self.find_entry.get()
        replace = self.replace_entry.get()
        changes = []

        for idx in self.search_matches:
            key = list(self.fields.keys())[idx]
            old = self.fields[key]
            new = old.replace(find, replace)
            if old != new:
                self.fields[key] = new
                changes.append((key, old, new))

        if changes:
            self.undo_stack.append(("BATCH", changes))
            self.redo_stack.clear()
            self.refresh_list()
            self.sound_success()

    # ---------- FILE / EDIT / UNDO ----------
    def open_file(self):
        path = filedialog.askopenfilename()
        if not path:
            return

        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            data = f.read()

        if not data.startswith("WEAPONFILE"):
            self.sound_error()
            messagebox.showerror("Error", "Invalid IW4x weapon file")
            return

        tokens = data[len("WEAPONFILE"):].split("\\")
        if tokens and tokens[0] == "":
            tokens = tokens[1:]

        self.fields.clear()
        for i in range(0, len(tokens), 2):
            self.fields[tokens[i]] = tokens[i + 1]

        self.original_fields = copy.deepcopy(self.fields)
        self.undo_stack.clear()
        self.redo_stack.clear()
        self.file_path = path

        self.refresh_list()
        self.sound_success()

    def _backup_file(self, path):
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as src:
                data = src.read()
            with open(path + ".bak", "w", encoding="utf-8") as bak:
                bak.write(data)
        except Exception:
            self.sound_error()
            return False
        return True

    def save_overwrite(self):
        if not self.file_path:
            return

        self.sound_warning()
        if not messagebox.askyesno("Overwrite", "Overwrite file? Backup will be created."):
            return

        if not self._backup_file(self.file_path):
            return

        self._write_file(self.file_path)
        self.sound_success()
        messagebox.showinfo("Saved", "File overwritten successfully.")

    def save_custom(self):
        if not self.file_path:
            return
        self._write_file(self.file_path + "_custom")
        self.sound_success()

    def _write_file(self, path):
        with open(path, "w", encoding="utf-8") as f:
            f.write("WEAPONFILE")
            for k, v in self.fields.items():
                f.write(f"\\{k}\\{v}")

    def refresh_list(self):
        self.listbox.delete(0, tk.END)
        for i, (k, v) in enumerate(self.fields.items()):
            display = EMPTY_DISPLAY if v == "" else v
            mark = "*" if self.original_fields[k] != v else " "
            idx = self.listbox.size()
            self.listbox.insert(tk.END, f"{i:03d}{mark}  {k} = {display}")

            if v == "":
                self.listbox.itemconfig(idx, fg=EMPTY_COLOR)
            elif self.original_fields[k] != v:
                self.listbox.itemconfig(idx, fg=MODIFIED)

    def on_select(self, _):
        if not self.listbox.curselection():
            return

        self.current_index = self.listbox.curselection()[0]
        key = list(self.fields.keys())[self.current_index]
        value = self.fields[key]

        self.field_name.configure(state="normal")
        self.field_name.delete(0, tk.END)
        self.field_name.insert(0, key)
        self.field_name.configure(state="readonly")

        self.original_value.configure(state="normal")
        self.original_value.delete(0, tk.END)
        self.original_value.insert(0, self.original_fields[key])
        self.original_value.configure(state="readonly")

        if key in MULTI_VALUE_FIELDS:
            self.field_value_entry.grid_remove()
            self.field_value_text.grid(row=1, column=1, padx=6)
            self.field_value_text.delete("1.0", tk.END)
            self.field_value_text.insert("1.0", value.replace(" ", "\n"))
        else:
            self.field_value_text.grid_remove()
            self.field_value_entry.grid(row=1, column=1, padx=6)
            self.field_value_entry.delete(0, tk.END)
            self.field_value_entry.insert(0, value)

    def apply_change(self):
        if self.current_index is None:
            return

        key = list(self.fields.keys())[self.current_index]
        new = (
            self.field_value_text.get("1.0", tk.END).strip().replace("\n", " ")
            if key in MULTI_VALUE_FIELDS
            else self.field_value_entry.get()
        )

        old = self.fields[key]
        if old != new:
            self.undo_stack.append(("SINGLE", key, old, new))
            self.redo_stack.clear()
            self.fields[key] = new
            self.refresh_list()

    def reset_field(self):
        if self.current_index is None:
            return

        key = list(self.fields.keys())[self.current_index]
        self.fields[key] = self.original_fields[key]
        self.refresh_list()

    def reset_all(self):
        self.fields = copy.deepcopy(self.original_fields)
        self.refresh_list()

    def undo(self):
        if not self.undo_stack:
            return
        action = self.undo_stack.pop()
        if action[0] == "SINGLE":
            _, k, old, _ = action
            self.fields[k] = old
        else:
            for k, old, _ in action[1]:
                self.fields[k] = old
        self.redo_stack.append(action)
        self.refresh_list()

    def redo(self):
        if not self.redo_stack:
            return
        action = self.redo_stack.pop()
        if action[0] == "SINGLE":
            _, k, _, new = action
            self.fields[k] = new
        else:
            for k, _, new in action[1]:
                self.fields[k] = new
        self.undo_stack.append(action)
        self.refresh_list()


# ================= ENTRY POINT =================
if __name__ == "__main__":
    root = tk.Tk()
    root.withdraw()

    splash = show_splash(root)

    def start():
        splash.destroy()
        root.deiconify()
        WeaponEditorGUI(root)

    root.after(1200, start)
    root.mainloop()