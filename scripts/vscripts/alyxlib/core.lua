--[[
    v3.1.0
    https://github.com/FrostSource/alyxlib

    The main core script provides useful global functions as well as loading any standard libraries that it can find.

    The two main purposes are:
    
    1. Automatically load libraries to simplify the process for users.
    2. Provide entity class functions to emulate OOP programming.

    Load this script into the global scope using the following line:

    ```lua
    require "alyxlib.core"
    ```

]]

local version = "v3.1.0"

print("Initializing AlyxLib core system ".. version .." ...")

require "alyxlib.util.globals"

-- Base libraries

ifrequire "alyxlib.debug.common"
ifrequire "alyxlib.debug.controller"
if not IsVREnabled() then
    ifrequire "alyxlib.debug.novr"
end
ifrequire "alyxlib.util.enums"
ifrequire "alyxlib.util.common"
ifrequire "alyxlib.extensions.string"
ifrequire "alyxlib.extensions.vector"
ifrequire "alyxlib.extensions.entity"
ifrequire "alyxlib.extensions.entities"
ifrequire "alyxlib.extensions.npc"
ifrequire "alyxlib.math.common"
ifrequire "alyxlib.data.queue"
ifrequire "alyxlib.data.stack"
ifrequire "alyxlib.data.inventory"
ifrequire "alyxlib.data.color"

-- Useful libraries

ifrequire "alyxlib.player"
ifrequire "alyxlib.precache"
ifrequire "alyxlib.class"

ifrequire "alyxlib.input.input"
ifrequire "alyxlib.input.gesture"
ifrequire "alyxlib.input.haptics"

ifrequire "alyxlib.helpers.easyconvars"

-- Common third-party libraries

ifrequire "wrist_pocket.core"

--#endregion

print("...finished intializing AlyxLib")

return version