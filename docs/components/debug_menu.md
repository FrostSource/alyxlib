# Debug Menu

The **AlyxLib Debug Menu** is a customizable panorama panel that provides quick access to developer-defined console commands and other actions for AlyxLib and its addons.

## Using The Menu

!!! info ""
    **In its current release, the debug menu requires adding `-dev` to the *Half-Life: Alyx* launch parameters in Steam.**

Once in a map with AlyxLib enabled:

- Press the **menu button** on your controller **three times in a row** to open the menu.
- The menu appears attached to your **primary hand** by default.

### Interacting with the Menu

- **Physically press** buttons with your finger, or
- **Aim at buttons** from a distance and use the **menu activate button** (usually the shooting trigger).

### Navigating the Menu

- Options are grouped into **category tabs**; select a tab to see its related options.
- To scroll **from a distance**, hover your finger over the **top  or bottom scroll zones**.
- To close the menu, press the **"Close Menu"** button at the top.

!!! note
    There is limited interactivity from a distance due to Valve induced limitations. You can press buttons and change slider values but you **cannot drag** or **scroll using the sidebar** remotely.

## Customizing the Menu

Adding your own controls to the menu for testing or addon settings is incredibly easy.

Start by creating a script to contain your menu logic, e.g. `scripts/vscripts/my_addon/debug_menu.lua`

Then add a category tab to the menu using `DebugMenu:AddCategory()`. The first parameter is the unique ID for the category; it should not be **"alyxlib"** or any common name that's likely to clash with another category. The second parameter is the display text.

```lua
DebugMenu:AddCategory("my_addon", "My Addon")
```

```lua
DebugMenu:AddButton("my_addon", "impulse_button_id", "Give Impulse 101", "impulse 101")
```

### Buttons

### Toggles

### Sliders

### Cyclers

### Labels

### Separators