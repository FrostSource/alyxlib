---
hide:
  - navigation
---

# 
<p align="center">
<picture>
    <img alt="AlyxLib Logo" src="assets/alyxlib_logo.svg" width="128">
</picture>
</p>


AlyxLib provides a set of useful Lua libraries for scripting with Half-Life: Alyx, making your code development process smooth and efficient.

Your addon is linked to AlyxLib via symbolic links, ensuring that every addon uses the same source and gets updated automatically whenever AlyxLib is updated. Plus, since your workshop item uses AlyxLib as a requirement, it will also receive any fixes without you having to reupload.

## 📚Library overview

* Full VScript code completion using [Lua Language Server](https://luals.github.io/)
* Save/Load most data types easily to any entity. [:octicons-link-external-16:](components/storage.md)
* Custom class implementation for entities, including inheritance and automatic variable saving. [:octicons-link-external-16:](components/classes.md)
* Player interaction simplification and tracking of items. [:octicons-link-external-16:](components/player.md)
* Panorama panel interaction, allowing sending and receiving data with Lua. [:octicons-link-external-16:](components/panorama.md)
* Easy controller input tracking with function callbacks. [:octicons-link-external-16:](components/input.md)
* Lots of useful debugging functions and console commands. [:octicons-link-external-16:](components/debugging.md)
* A fully customizable in-game debug menu. [:octicons-link-external-16:](components/debug_menu.md)

See the [Components](components) section for a more detailed overview.

!!! tip "Code completion"
    AlyxLib uses the [HLA-VScript](https://github.com/FrostSource/HLA-VScript) definition files to provide full VScript code completion. It can be installed using the [Lua Language Server addon manager](https://luals.github.io/wiki/addons/#addon-manager)

## 🚀Quick setup guide

!!! note ""
    For in-depth setup, see the [Installation](getting_started/installation.md) guide.

1. Download or clone the [AlyxLib GitHub repository](https://github.com/FrostSource/alyxlib) to your hlvr_addons content folder

2. Run `alyxlib.py` from the root folder

3. Select your addon from the list of addons shown

4. Select the type of installation you want for your addon (can be changed later)

5. Before uploading to the workshop, run the `on_upload.bat` that was created in your addon content folder to temporarily remove symlinks, **but do not exit the program**

6. Upload your addon to the workshop and set [AlyxLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3329679071) as a required item

7. Rename the `0000000000.lua` file in `scripts/vscripts/mods/init/` to have the same number as your new workshop item [(this is the same process outlined in Scalable Init Support)](https://github.com/PeterSHollander/scalable_init_support?tab=readme-ov-file#for-workshop-release)

8. Finish the instructions shown in the running `on_upload.bat` program to restore the symlinks for further development

## ❓Need help?

Please feel free to [create an issue](https://github.com/FrostSource/alyxlib/issues/new?body=Please%20describe%20what%20happened%2C%20steps%20to%20reproduce%2C%20and%20any%20relevant%20details%20here.) (requires GitHub account)
 with your problem, question or suggestion.

You can also join the <img src="https://github.com/user-attachments/assets/347c331b-4105-4d13-ba90-d4dec3952c75" width="16"> [Discord server](https://discord.gg/42SC3Wyjv4) to get faster responses.

