!!! info
    Registering with AlyxLib is completely optional.

See the [AlyxLib console commands](../console/alyxlib.md) for the user facing commands that interface with the addon registration system.

## Registering Your Addon

Registering your addon with AlyxLib allows the system to check for version conflicts and provide help to users of your addon.

Registration should be done once in a global (init) script when the map first loads.

Provide the following information in the `RegisterAlyxLibAddon` function:

- Full display name of the addon, e.g. "My New Addon"
- SemVer version string of the addon, e.g. "v1.2.3"
- Steam Workshop ID of the addon, e.g. "123456789"
- Short unique name of the addon without spaces, e.g. "myaddon"
  You can pass `nil` for this to use the addon name without spaces and converted to lowercase
- Minimum AlyxLib version that this addon works with, defaults to "v1.0.0"
- Maximum AlyxLib version that this addon works with, defaults to `ALYXLIB_VERSION`

```lua
local addonID = RegisterAlyxLibAddon(
    "Resin Watch (Item Tracker)",
    "v1.0.0",--(1)!
    "3145397582",--(2)!
    "resin_watch",--(3)!
    "v2.0.0"
    )
```

1. You can decide how you update your version, but it *must* be a valid SemVer version string in the format `vMAJOR.MINOR.PATCH`.

2. You will have to upload your addon to the Steam workshop first to get the ID, which you can find at the end of the URL of your workshop item. You can then enter the ID here and update your addon.

3. The short name helps AlyxLib commands find your addon without having to type the full name.

!!! tip
    Save the returned `addonID` for use with other AlyxLib registration functions.

If you want to find the current AlyxLib version you're using, look at the `ALYXLIB_VERSION` global variable in `scripts/vscripts/alyxlib/init.lua`. You can copy this string directly into the `minAlyxLibVersion` or `maxAlyxLibVersion` parameters.

## Setting Up Diagnostics

A diagnostic function provides the player with a friendly way of checking for "developer defined" issues with the addon, and any diagnostic messages that might be helpful to the developer, which the player can copy and send to the developer for debugging purposes.

The diagnostic function should registered once in a global (init) script when the map first loads.

Your function should return `false` if an issue is found, along with a message or list of messages describing the issue(s).

```lua
RegisterAlyxLibDiagnostic(addonID, function()

    if not Player.HMDAvatar then
        return false, "This addon requires VR or +vr_enable_fake_vr to be enabled"
    end

    if not IsAddonEnabled("123456789") then
        return false, "This addon requires another addon to be enabled, please enable it"
    end

    return true--(1)!
end)
```

1. Explicitly return `true` if there are no issues

!!! tip
    Perform as many checks as necessary to provide the most help to the user. If a user changeable value like a convar can cause issues then it's a good idea to check each one and explain acceptable ranges in the failure message.

!!! tip
    Feel free to print messages to the console using the `Msg` function as your diagnostic function runs, such as current convar values or entity states that might help you replicate and fix the issue.

!!! tip
    If an immediately fixable issue is found, consider applying the fix directly in the diagnostic function, or providing the user with a command to perform the fix.

### Real diagnostic examples

- [Resin Watch (Item Tracker)](https://github.com/FrostSource/resin_watch/blob/63b7ca912b7db7f2fb251681979d5e9edc60405e/scripts/vscripts/resin_watch/init.lua#L11)
- [Body Holsters](https://github.com/FrostSource/body_holsters/blob/838406a8b4d0e95f601013b067969bcb5416cfa5/scripts/vscripts/body_holsters/main.lua#L161)