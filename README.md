# AlyxLib

> [!WARNING]\
> this repository has been made public to create the wiki and may not work as intended until this message is removed!

AlyxLib provides a set of useful Lua libraries for scripting with Half-Life: Alyx, making your development process smoother and more efficient. Your addon is linked to AlyxLib via symbolic links, ensuring that every addon uses the same source and gets updated automatically whenever AlyxLib is updated. Plus, since your workshop item uses AlyxLib as a requirement, it will also receive any fixes without you having to reupload.

# Library overview

* Full VScript code completion using [Lua Language Server](https://luals.github.io/)
* Save/Load most data types easily to any entity.
* Custom class implementation for entities, including inheritence and automatic variable saving.
* Player interaction simplification and tracking of items.
* Panorama panel interaction, allowing sending and receiving data with Lua.
* Easy controller input tracking with function callbacks.
* Lots of useful debugging functions and console commands.

See the extensive wiki for full function reference and code examples.

# Quick setup guide

(For in-depth setup, see the [Installing AlyxLib](https://github.com/FrostSource/alyxlib/wiki/Installing-AlyxLib) wiki page)

1. Download or clone this GitHub repository to your hlvr_addons content folder

2. Run `alyxlib.py` from the root folder

3. Select your addon from the list of addons shown

4. Select the type of installation you want for your addon (can be changed later)

5. Before uploading to the workshop, run the `on_upload.bat` that was created in your addon content folder to temporarily remove symlinks, **but do not -exit the program**

6. Upload your addon to the workshop and set [AlyxLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3329679071) as a required item

7. Rename the `0000000000.lua` file in `scripts/vscripts/mods/init/` to have the same number as your new workshop item [(this is the same process outlined in Scalable Init Support)](https://github.com/PeterSHollander/scalable_init_support?tab=readme-ov-file#for-workshop-release)

8. Finish the instructions shown in the running `on_upload.bat` program to restore the symlinks for further development

# Need help?

Please feel free to create an issue with your problem, question or suggestion.

You can also join us on our [Discord server](https://discord.gg/42SC3Wyjv4) to get faster responses.

# Projects using AlyxLib

