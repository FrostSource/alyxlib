
<p align="center">
<picture>
    <source srcset="https://github.com/user-attachments/assets/5888846f-88b6-4a35-bf83-51e31cdfdcff" media="(prefers-color-scheme: light)">
    <source srcset="https://github.com/user-attachments/assets/27af88d4-265f-4c58-83ef-d68cba14f1f9" media="(prefers-color-scheme: dark)">
    <img alt="AlyxLib Logo" src="https://github.com/user-attachments/assets/27af88d4-265f-4c58-83ef-d68cba14f1f9" width="250">
</picture>
</p>

&nbsp;

<div align="center">

[![License](https://img.shields.io/badge/License-MIT-04663E)](#license)
[![issues](https://img.shields.io/github/issues/FrostSource/alyxlib?color=04663E)](https://github.com/FrostSource/alyxlib/issues)
![GitHub commit activity](https://img.shields.io/github/commit-activity/w/FrostSource/alyxlib?color=04663E)

[![Discord](https://img.shields.io/discord/825047476146012261?style=for-the-badge&logo=discord&logoColor=white&label=discord&logoSize=auto&labelColor=5865F2&color=2ea44f)](https://discord.gg/42SC3Wyjv4 "Join the Discord")
[![Steam](https://img.shields.io/steam/downloads/3329679071?style=for-the-badge&logo=steam&label=steam&logoSize=auto&labelColor=black&color=2ea44f)](https://steamcommunity.com/sharedfiles/filedetails/?id=3329679071 "AlyxLib workshop")

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://github.com/FrostSource/alyxlib/wiki "Go to project documentation")

</div>

---

> [!CAUTION]\
> This repository has been made public to create the wiki and may not work as intended until this message is removed!

AlyxLib provides a set of useful Lua libraries for scripting with Half-Life: Alyx, making your development process smoother and more efficient.

Your addon is linked to AlyxLib via symbolic links, ensuring that every addon uses the same source and gets updated automatically whenever AlyxLib is updated. Plus, since your workshop item uses AlyxLib as a requirement, it will also receive any fixes without you having to reupload.

## 📚Library overview

* Full VScript code completion using [Lua Language Server](https://luals.github.io/)
* Save/Load most data types easily to any entity.
* Custom class implementation for entities, including inheritence and automatic variable saving.
* Player interaction simplification and tracking of items.
* Panorama panel interaction, allowing sending and receiving data with Lua.
* Easy controller input tracking with function callbacks.
* Lots of useful debugging functions and console commands.

See the extensive wiki for full function reference and code examples.

## 🚀Quick setup guide

> [!NOTE]\
> For in-depth setup, see the [Installing AlyxLib](https://github.com/FrostSource/alyxlib/wiki/Installing-AlyxLib) wiki page

1. Download or clone this GitHub repository to your hlvr_addons content folder

2. Run `alyxlib.py` from the root folder

3. Select your addon from the list of addons shown

4. Select the type of installation you want for your addon (can be changed later)

5. Before uploading to the workshop, run the `on_upload.bat` that was created in your addon content folder to temporarily remove symlinks, **but do not -exit the program**

6. Upload your addon to the workshop and set [AlyxLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3329679071) as a required item

7. Rename the `0000000000.lua` file in `scripts/vscripts/mods/init/` to have the same number as your new workshop item [(this is the same process outlined in Scalable Init Support)](https://github.com/PeterSHollander/scalable_init_support?tab=readme-ov-file#for-workshop-release)

8. Finish the instructions shown in the running `on_upload.bat` program to restore the symlinks for further development

## ❓Need help?

Please feel free to create an issue with your problem, question or suggestion.

You can also join us on our [Discord server](https://discord.gg/42SC3Wyjv4) to get faster responses.

## 🌟Projects using AlyxLib

<p align="center">
<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3144612716"><img src="https://steamuserimages-a.akamaihd.net/ugc/2318858611175367914/A9DF9C6F4BDAD028C899210A34ECB1573674D6B7/" width="23%"></img></a>
<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3145397582"><img src="https://steamuserimages-a.akamaihd.net/ugc/2397692528303465396/EC70CA957F433DBD8E9D1BCB19E12E7B896EFDE6/" width="23%"></img></a>
<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3329684800"><img src="https://steamuserimages-a.akamaihd.net/ugc/2397692528303495590/700AD9E3DD1C2984BCD4F2D588ACDD8BE2EB6EAD/" width="23%"></img></a>
<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=2703180455"><img src="https://steamuserimages-a.akamaihd.net/ugc/2397692528303482230/73852A6226202BAA79D1D7E3C88083D71F356D87/" width="23%"></img></a>
</p>
