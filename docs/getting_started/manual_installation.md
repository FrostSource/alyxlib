This page walks you through manually installing individual components of AlyxLib for your addon if you are not using any setup applications.

!!! info ""
    Wherever you see `{addon_name}` replace it with the name of your addon.

!!! note ""
    Please take note of which addon directory is mentioned for each file list (**content** vs **game**).  
    **content** refers to `Half-Life Alyx/content/hlvr_addons/{addon_name}/`  
    **game** refers to `Half-Life Alyx/game/hlvr_addons/{addon_name}/`

## AlyxLib scripting

Copy the following AlyxLib folders/files to your addon **game** folder:

* `scripts/vscripts/alyxlib`
* `scripts/vscripts/game/gameinit.lua` [for auto loading during testing]

!!! danger "Important"
    Always remove the above files before uploading your addon to the workshop. Uploading these files might cause your addon to break future versions of AlyxLib for players using your addon.

If using VSCode, you can copy the snippet files to your `.vscode` folder:

* `.vscode/alyxlib.code-snippets` (for VSCode snippets)
* `.vscode/vlua_snippets.code-snippets` (for VSCode snippets)

Create the main init file for your addon in the **game** folder:

* `scripts/vscripts/{addon_name}/init.lua`
    ```lua  
    -- alyxlib can only run on server  
    if IsServer() then  
        -- Load alyxlib before using it, in case this mod loads before the alyxlib mod.  
        require("alyxlib.init")  

        -- execute code or load mod libraries here  

    end  
    ```

Create the scalable init support files for your addon in the **game** folder:

* `scripts/vscripts/mods/init/000000000.lua` [workshop init file]
    ```lua
    -- Rename this file to the ID of your workshop item after upload.
    require("{addon_name}.init")
    ```
* `scripts/vscripts/mods/init/{addon_name}.lua` [local init file]
    ```lua
    require("{addon_name}.init")
    ```

If using VSCode, add the following settings to your `.vscode/settings.json` file:

```json
{
    "Lua.workspace.library": [
        "${addons}/HLA-VScript/module/library"
    ],
    "Lua.runtime.version": "LuaJIT",
    "Lua.runtime.builtin": {
        "coroutine": "enable",
        "debug": "enable",
        "io": "disable",
        "math": "enable",
        "os": "disable",
        "package": "enable",
        "string": "enable",
        "table": "enable",
        "utf8": "disable",
        "bit": "enable",
        "bit32": "disable",
        "jit": "disable"
    },
    "Lua.type.weakUnionCheck": true,
    "Lua.type.weakNilCheck": true,
    "Lua.diagnostics.disable": [
        "inject-field"
    ],
    "Lua.workspace.checkThirdParty": false,
    "Lua.diagnostics.ignoredFiles": "Enable",
    "Lua.workspace.useGitIgnore": false
}
```

## Debug menu

If you want to use or develop the debug menu while testing, you will need to copy the following files into your addon **content** directory:

* `panorama/layout/custom_game/alyxlib_debug_menu.xml`
* `panorama/scripts/custom_game/alyxlib_debug_menu.js`
* `panorama/scripts/custom_game/panorama_lua.js`
* `panorama/styles/custom_game/alyxlib_debug_menu.css`

## Panorama

To develop your own Panorama panels with AlyxLib, copy the following files into your addon **content** directory:

!!! note ""
    You will also need to install AlyxLib scripting files to send data to the panels.

* `panorama/scripts/custom_game/panorama_lua.js`
* `panorama/scripts/custom_game/panoramadoc.js` [for intellisense]

## Git

If you are using Git (or other source control), you should add the following paths to your `.gitignore` file to keep your repository clean:

```gitignore
# Source 2 ignores

/_bakeresourcecache/
*bakeresourcecache.vpk
__pycache__

# AlyxLib ignores

scripts/vscripts/alyxlib
scripts/vscripts/game/gameinit.lua
.vscode/alyxlib.code-snippets
.vscode/vlua_snippets.code-snippets
panorama/scripts/custom_game/panorama_lua.js
panorama/scripts/custom_game/panoramadoc.js

panorama/layout/custom_game/alyxlib_debug_menu.xml
panorama/scripts/custom_game/alyxlib_debug_menu.js
panorama/styles/custom_game/alyxlib_debug_menu.css
```