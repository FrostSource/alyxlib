AlyxLib provides a simple way to communicate between Panorama panels and Lua scripts.

Make sure you have installed the "Panorama" option into your local addon and have the following files:

* `panorama/scripts/custom_game/panorama_lua.js`
* `panorama/scripts/custom_game/panoramadoc.js` [optional]
* `scripts/vscripts/alyxlib/panorama/core.lua`

## Quick setup example

!!! tip
    If you've installed the VSCode snippets file for AlyxLib, you can use the `Panorama XML` and `Panorama JS` snippets to quickly create templates.

Create a new layout file in the `panorama/layout/custom_game/` folder, e.g. `my_addon.xml`.

```xml
<root>
    <!-- You may add any style files here -->
    <scripts>
        <!-- panorama_lua must be included before your scripts -->
        <include src="s2r://panorama/scripts/custom_game/panorama_lua.vjs_c" />
        <!-- Your script file that will be created next -->
        <include src="s2r://panorama/scripts/custom_game/my_addon.vjs_c" />
    </scripts>

    <Panel class="root">
        <!-- We will change this label via Lua -->
        <Label id="label" text="Shoot count: 0" style="font-size: 125px;" /><!--(1)!-->
    </Panel>
</root>
```

1. Increasing the text size this way makes it easier to read without needing to create a separate style file.

Next step is to create the `my_addon.js` JavaScript file in the `panorama/scripts/custom_game/` folder. This script will listen to messages from Lua.

```js
/// This allows panorama intellisense for this file
/// <reference path="panoramadoc.js" />
"use strict";

/**
 * Changes the text of our label.
 * @param {string} text
 */
function ChangeLabelText(text) {
    const label = $('#label');

    if (label)
        label.text = text;
}

/**
 * Parses the incoming Lua command.
 * @param {string} command The name of the command
 * @param {string[]} args The array of arguments
 */
function ParseCommand(command, args)
{
    command = command.toLowerCase();

    switch (command)
    {
        case "changetext": {//(1)!
            const text = args[0];

            if (!text) {//(2)!
                $.Msg("Missing text argument");
                break;
            }

            ChangeLabelText(text);
            break;
        }
    }
}
```

1. Commands are written in lowercase to ensure there are no case sensitivity issues between Panorama and Lua.
2. It's good practice to validate the arguments, base on type you're expecting for each argument.

`ParseCommands` is called by the `panorama_lua.js` script whenever data is received.

Next you create your Lua file which will send commands to Panorama, e.g. `scripts/vscripts/my_addon/send_to_panorama.lua`.

For this example, the script will be attached directly to a `point_clientui_world_panel` entity in Hammer.

```lua
function Activate()
    Panorama:InitPanel(thisEntity)--(1)!
end

local shootCount = 0

ListenToGameEvent("player_shoot_weapon", function()
    shootCount = shootCount + 1

    Panorama:Send(thisEntity, "ChangeText", "Shoot count: " .. shootCount)--(2)!
end, nil)
```

1. The panel must be initialized before any commands can be sent.
2. The command name is always given first, followed by any arguments the command needs.

The final step is to create a `point_clientui_world_panel` entity in Hammer and attach the Lua script to it.

You may change the size and alignment of the panel if you wish, but for this example the two important changes are:

* "Layout XML" -> `file://{resources}/layout/custom_game/my_addon.xml`
* "Entity Scripts" -> `my_addon/send_to_panorama`

## Reference

View the full reference [here](../reference/panorama/core.md).
