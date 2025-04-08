--[[
    v1.2.1
    https://github.com/FrostSource/alyxlib

    The main initializer script loads any standard libraries that it can find.

    Load this script into the global scope using the following line:

    require "alyxlib.init"

]]

-- Version of this file
local version = "v1.2.1"

---ID of AlyxLib in the Steam workshop
ALYXLIB_WORKSHOP_ID = "3329679071"
---The current version of AlyxLib as a whole
ALYXLIB_VERSION = "v1.3.1"

print("Initializing AlyxLib system ".. ALYXLIB_VERSION .." ...")

---Prints the version of a library.
---@param name string # The path to the library
---@param lib_version? any # The version of the library
local function print_version(name, lib_version)
    if type(lib_version) == "string" then
        if name:sub(1, 8) == "alyxlib." then
            name = name:sub(9)
        end
        name = name:gsub("%.", "/")
        devprint(string.format("\t%-26s %s", name, lib_version))
    end
end

---Loads a library if it exists and prints version.
---@param path string # The path to the library
local function alyxlib_require(path, required)
    if required then
        print_version(path, require(path))
    else
        ifrequire(path, function (lib_version)
            print_version(path, lib_version)
        end)
    end
end

alyxlib_require("alyxlib.globals", true)

-- Base libraries

alyxlib_require "alyxlib.utils.enums"
alyxlib_require "alyxlib.utils.common"
alyxlib_require "alyxlib.extensions.string"
alyxlib_require "alyxlib.extensions.vector"
alyxlib_require "alyxlib.extensions.qangle"
alyxlib_require "alyxlib.extensions.entity"
alyxlib_require "alyxlib.extensions.entities"
alyxlib_require "alyxlib.extensions.npc"
alyxlib_require "alyxlib.extensions.template"
alyxlib_require "alyxlib.math.common"
alyxlib_require "alyxlib.math.weighted_random"
alyxlib_require "alyxlib.data.queue"
alyxlib_require "alyxlib.data.stack"
alyxlib_require "alyxlib.data.inventory"
alyxlib_require "alyxlib.data.color"

-- Useful libraries

alyxlib_require "alyxlib.player.core"
alyxlib_require "alyxlib.player.events"
alyxlib_require "alyxlib.player.hands"
alyxlib_require "alyxlib.player.wrist_attachments"
alyxlib_require "alyxlib.precache"
alyxlib_require "alyxlib.class"

alyxlib_require "alyxlib.controls.input"
alyxlib_require "alyxlib.controls.gesture"
alyxlib_require "alyxlib.controls.haptics"

alyxlib_require "alyxlib.helpers.animation"
alyxlib_require "alyxlib.helpers.easyconvars"
alyxlib_require "alyxlib.panorama.core"

-- Debug

alyxlib_require "alyxlib.debug.common"
alyxlib_require "alyxlib.debug.commands"
alyxlib_require "alyxlib.debug.controller"
if IsVREnabled() then
    alyxlib_require "alyxlib.debug.vr"
else
    alyxlib_require "alyxlib.debug.novr"
end
alyxlib_require "alyxlib.debug.debug_menu"

-- Common third-party libraries

alyxlib_require "wrist_pocket.core"

--#endregion

print("...finished intializing AlyxLib")

return version