# 📁 Material Home Folder
### Android-style draggable app folders for Hyprland

---

## ⚡ TL;DR — Just want it running?

1. Copy the folder to `~/.config/quickshell/materialHomeFolder/`
2. Open **`shell.qml`** and change `/home/hashib/` to your username on line 20
3. Open **`FolderCircle.qml`** and **`FolderPopup.qml`** and swap out the apps list
4. Run it: `qs -p ~/.config/quickshell/materialHomeFolder/`

That's it. Read on only if something doesn't look right.

---

## 📋 Requirements

| Thing | Why |
|---|---|
| [QuickShell](https://quickshell.outfoxxed.me) (latest) | Runs the widget |
| Hyprland | Window manager (Wayland layer-shell) |
| [DankMaterialShell](https://danklinux.com) | Optional — for automatic color theming |
| A proper icon theme | So app icons show up (Papirus recommended) |

---

## 🔧 The Two Things You'll Always Need to Change

### 1. Your username — `shell.qml` line ~20

```
path: "/home/hashib/.cache/DankMaterialShell/dms-colors.json"
```

Change `hashib` to your username. If you don't use DMS at all, just delete this line and the colors will use the built-in defaults (still looks fine).

---

### 2. Your apps — in both `FolderCircle.qml` and `FolderPopup.qml`

Find this block in **both** files (they need to match):

```
readonly property string folderName: "Games"
readonly property var apps: [
    { name: "Chess",    icon: "gnome-chess",           exec: "gnome-chess" },
    { name: "Lutris",   icon: "lutris",                exec: "lutris"      },
    { name: "Steam",    icon: "steam",                 exec: "steam"       },
    { name: "Heroic",   icon: "heroic-games-launcher", exec: "heroic"      },
    { name: "Bottles",  icon: "bottles",               exec: "bottles"     },
]
```

- **`folderName`** — the label shown under the circle and at the top of the open folder
- **`name`** — label shown under each icon
- **`icon`** — the icon theme name (see below how to find it)
- **`exec`** — the command to run (same as what you'd type in a terminal)

> ⚠️ Edit this in **both** `FolderCircle.qml` and `FolderPopup.qml` — they both need the same list.

#### How to find the right icon name

Open a terminal and run:
```bash
gtk3-icon-browser
```
Search for your app and use the name shown. Or just use the app's package name — it usually works (e.g. `firefox`, `spotify`, `discord`, `code`).

---

## 🎨 Colors

If you use **DankMaterialShell**, colors update automatically every time you change your wallpaper. Nothing to configure.

If you **don't use DMS**, the widget uses a built-in dark Material You palette that looks decent with any dark theme. You can manually set colors by editing the fallback values at the bottom of the color list in `shell.qml` — they're plain hex codes like `"#1b2122"`.

---

## 🖥️ Multi-monitor

Currently the folder only appears on your primary monitor (the first one Hyprland reports). If you want it on a different screen, open `shell.qml` and change:

```
screen: Quickshell.screens[0]   ← 0 = first monitor, 1 = second, etc.
```

Change both occurrences (there are two `PanelWindow` blocks).

---

## 📂 Multiple Folders

Want a "Dev Tools" folder and a "Games" folder? You'll need to duplicate the setup. This isn't polished into a one-click thing yet — it's on the to-do list. For now, run two separate quickshell instances pointing to two copies of the config with different app lists and starting positions.

---

## 🗂️ What Each File Does (quick reference)

| File | What it is |
|---|---|
| `shell.qml` | The main entry point. Handles colors and creates the two windows |
| `FolderCircle.qml` | The collapsed circle you see on the desktop. Also handles dragging |
| `FolderPopup.qml` | The folder that pops open when you click the circle |
| `AppIconDelegate.qml` | A single app icon inside the open folder — don't need to edit this |

---

## ❓ Things That Might Go Wrong

**Widget is stuck above all my windows**
→ This shouldn't happen with the current version. If it does, make sure `aboveWindows: false` is set in the first `PanelWindow` block in `shell.qml`.

**Icons aren't showing, just letters**
→ You either don't have an icon theme installed, or the icon name is wrong. Install Papirus (`sudo pacman -S papirus-icon-theme`) and make sure your icon theme is set in `~/.config/gtk-3.0/settings.ini`.

**Colors aren't updating when I change wallpaper**
→ DMS needs to be running and matugen needs to be enabled. Check with `dms status` in a terminal.

**Can't drag the folder**
→ You need to click and hold on the circle itself (not the label underneath) and then move. A quick click opens it, a click-and-drag moves it.

**The folder opens in the wrong spot / off-screen**
→ Edit `folderX` and `folderY` in `shell.qml` under the `QtObject { id: folderState }` block to set the starting position.

```
property real folderX: 120   ← pixels from left edge
property real folderY: 160   ← pixels from top edge
```
