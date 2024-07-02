
/**
 * v1.0.0
 * This is the base script that handles all incoming data
 * and should be included in the layout file as such:
 * 
 *  <scripts>
 *      <include src="s2r://panorama/scripts/custom_game/panorama_lua.vjs_c" />
 *      <!--Custom script should come after panorama_lua-->
 *      <!--<include src="s2r://panorama/scripts/custom_game/.vjs_c" />-->
 *  </scripts>
 * 
 */
"use strict";
// Used to import panorama typedefs
// This is purely for VSCode to recognize Valve functions for code completion.
// @ts-ignore
if(false)p=require("./panoramadoc");

/**
 * 
 * @param {null} _ Unused variable.
 * @param {string} encoded String of data separated by a pipe.
 */
function LuaCallback(_,encoded)
{
    $.Msg(encoded)
    let decoded = encoded.split("|");
    let panel = $.GetContextPanel();
    //$.Msg(decoded[0], panel.BHasClass(decoded[0]))
    // Check if the data being sent belongs to this panel
    if (panel.BHasClass(decoded[0]))
    {
        //$.Msg(decoded[0] + " recieved Lua data.")
        if (decoded.length > 1)
        {
            let command = decoded[1];
            if (command == "json")
            {
                let data = JSON.parse(decoded[2])
                for (const commander of data) {
                    if (Array.isArray(commander.args))
                        ParseCommand(commander.command, commander.args);
                    else
                        ParseCommand(commander.command, [commander.args]);
                }
            }
            else
            {
                let data = decoded.slice(2);
                //$.Msg(command, data);
                ParseCommand(command, data);
            }
        }
    }
    panel.RemoveClass(encoded)
}

(function()
{
    $.Msg("panorama_lua.js loaded")
    $.RegisterForUnhandledEvent('AddStyleToEachChild',LuaCallback);
})();

