The base API allows asset precaching at runtime with the entity Precache hook like so:

```lua
function Precache(context)
    PrecacheModel("models/my_model.vmdl", context)
end
```

There are cases where precaching in a global script is necessary, so AlyxLib skirts this entity-only requirement by letting you queue up assets when your scripts first load to be precached when the player spawns.

```lua
GlobalPrecache("model", "models/my_model.vmdl")

GlobalPrecache("entity", "item_item_crate", {
	ItemClass = "item_hlvr_clip_shotgun_shells_pair"
})
```

## Runtime precache

Precaching after the player spawns is similar but requires you to tell the system when to "flush" the cache list.

```lua
-- Declare the assets you want to precache
GlobalPrecache("model", "models/hands/flash_light_glove.vmdl")
GlobalPrecache("particle", "particles/weapon_fx/vr_flashlight.vpcf")

-- Flush the precache list and do some work afterwards
GlobalPrecacheFlush(function()
    SendToConsole("hlvr_give_flashlight")
end)
```

!!! note
    Precaching is an asynchronous process; the assets won't be immediately available after calling `GlobalPrecacheFlush`.
    Use the `GlobalPrecacheFlush` callback to do work after the precache is complete.

## Precache types

| Type            | Description |
|-----------------|-------------|
| model_folder    | Precaches a folder of models.    |
| sound           | Precaches a sound event.         |
| soundfile       | |
| particle        | Precaches a single particle.     |
| particle_folder | Precaches a folder of particles. |
| model           | Precaches a single model.        |
| entity          | Precaches an entity class.       |

## Reference

View the full reference [here](../reference/precache.md).