--[[
    v4.0.0
    https://github.com/FrostSource/alyxlib

    The main initializer script loads any standard libraries that it can find.

    Load this script into the global scope using the following line:

    ```lua
    require "alyxlib.init"
    ```

]]

local version = "v4.0.0"

print("Initializing AlyxLib core system ".. version .." ...")

require "alyxlib.globals"

-- Base libraries

ifrequire "alyxlib.debug.common"
ifrequire "alyxlib.debug.controller"
if IsVREnabled() then
    ifrequire "alyxlib.debug.vr"
else
    ifrequire "alyxlib.debug.novr"
end
ifrequire "alyxlib.utils.enums"
ifrequire "alyxlib.utils.common"
ifrequire "alyxlib.extensions.string"
ifrequire "alyxlib.extensions.vector"
ifrequire "alyxlib.extensions.qangle"
ifrequire "alyxlib.extensions.entity"
ifrequire "alyxlib.extensions.entities"
ifrequire "alyxlib.extensions.npc"
ifrequire "alyxlib.math.common"
ifrequire "alyxlib.data.queue"
ifrequire "alyxlib.data.stack"
ifrequire "alyxlib.data.inventory"
ifrequire "alyxlib.data.color"

-- Useful libraries

ifrequire "alyxlib.player.core"
ifrequire "alyxlib.player.wrist_attachments"
ifrequire "alyxlib.precache"
ifrequire "alyxlib.class"

ifrequire "alyxlib.controls.input"
ifrequire "alyxlib.controls.gesture"
ifrequire "alyxlib.controls.haptics"

ifrequire "alyxlib.helpers.easyconvars"

-- Common third-party libraries

ifrequire "wrist_pocket.core"

--#endregion

print("...finished intializing AlyxLib")

return version