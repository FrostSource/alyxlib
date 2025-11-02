!!! warning
    Python installation is not currently maintained and may not install correctly. Please use [App Installation](app_installation.md) or [Manual Installation](manual_installation.md) instead.

!!! info "Important"
    This is a scripting library, not a scripting guide. This setup page will assume you are already somewhat familiar with scripting basics in Half-Life: Alyx. If you still need further help with setting up AlyxLib see [Getting Help](#) to contact me.

!!! note ""
    This guide uses [Visual Studio Code](https://code.visualstudio.com/), as this is the program used to develop AlyxLib. If you use another text editor you will need to find instructions for your specific editor for some of the steps.

*If you don't want to use installation programs, see the [Setup without Python](#setup-without-python) section.*

## Cloning AlyxLib

!!! tip ""
    If you don't want to use Git you can download AlyxLib as a zip file by [clicking here](https://github.com/FrostSource/alyxlib/archive/refs/heads/main.zip).  
    **It is important to rename the downloaded folder from `alyxlib-main` to `alyxlib`.**

AlyxLib needs to be on your computer in order to create symbolic links (symlinks) to the files. It is recommended to clone AlyxLib to your `Half-Life Alyx\content\hlvr_addons\` folder to allow the setup script to function without issues. It can technically be anywhere on your computer as long as the location exists while you are developing, but you will not be able to use the easy setup script if it is placed outside of the addons directory.

To clone with Visual Studio Code follow the official [Clone a repository locally](https://code.visualstudio.com/docs/sourcecontrol/intro-to-git#_clone-a-repository-locally) guide.

Choose your `hlvr_addons` folder for the repository destination (this is usually at  `C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx\content\hlvr_addons\`.  
After cloning, the cloned folder path should be `C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx\content\hlvr_addons\alyxlib`.  
**It is important that the name of the folder is `alyxlib`.**

## Installing AlyxLib into your addon

The AlyxLib setup script requires at least Python 3.6 to run. You can download the latest python release here: https://www.python.org/downloads/

> If you can't or don't want to install Python you can still manually set up AlyxLib by following the [Setup without Python](#setup-without-python) section.

Your addon must already exist prior to running AlyxLib. If it does not exist yet you can simply create a bare addon using the Half-Life: Alyx workshop tools startup screen before proceeding.

Run `alyxlib.py` by double clicking it. You should be presented with a numbered list of all your current addons (if no list is shown or you experience an error, please see Getting Help to contact us). Select the addon you want to set up by typing the number next to the name, or by typing the name of the addon. Part-names are accepted too, i.e. `lib` can select `alyxlib`. If multiple addons match the name given you will prompted to specify.

After selecting your addon you will be presented with a list of setup options to choose from:

1. **Full Setup**
:   Every feature of AlyxLib is integrated with your addon, including a basic git initialization. This is the standard option for most addons. You do not have to use all the features but they will be there if you want them.

2. **Full Setup (no Git)**
:   Every feature of AlyxLib is integrated with your addon. No Git initialization is done for your addon.

3. **VScript Setup**
:   Basic scripting features are integrated.

4. **Git Setup**
:   A Git repository is initialized in your addon folder.

> You can rerun the setup script at any point to change the setup type. You cannot revert to a lesser setup type without removing AlyxLib from your addon first.

Wait for the script to complete its process. You can now continue developing your addon normally.

## Manual installation

Without Python you will have to manually create the symlinks yourself to each desired AlyxLib file/folder. I recommend using [Link Shell Extension](https://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html) which adds linking operations directly to your Windows right-click context menu, making links much easier to create.

For a full setup the following files/folder should be linked to your addon *content* folder in their respective locations:

* `scripts/vscripts/alyxlib`
* `scripts/vlua_globals.lua`
* `scripts/vscripts/game`
* `.vscode`
* `panorama/scripts/custom_game/panorama_lua.js`
* `panorama/scripts/custom_game/panoramadoc.js`

You will also need to create a symlink from your addon *content* folder `scripts` to your addon *game* folder `scripts` due to the way the game consumes scripts directly and does not compile them.

Before uploading your addon to the workshop you **must manually** remove the following symlinks and then add them back after uploading:

* `scripts/vscripts/alyxlib`
* `scripts/vlua_globals.lua`
* `scripts/vscripts/game`

