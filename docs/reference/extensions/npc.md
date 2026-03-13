# Extensions Npc

> scripts/vscripts/alyxlib/extensions/npc.lua

## Methods

### StartSchedule

Creates and starts a new schedule for this NPC.

```lua
CAI_BaseNPC:StartSchedule(state, type, interruptability, reacquire, goal)
```

**Parameters**

- **`state`**  
  `ScheduleState`  
  The NPC state that should be set
- **`type`**  
  `ScheduleType`  
  The type of schedule to perform
- **`interruptability`**  
  `ScheduleInterruptability`  
  What should interrupt the NPC from the schedule
- **`reacquire`**  
  `boolean`  
  If the NPC should reacquire the schedule after being interrupted
- **`goal`**  
  `EntityHandle`, `Vector`  
  Worldspace position or entity goal (entity origin will be used)

**Returns**
- **`EntityHandle`**
The new `aiscripted_schedule`

### StopSchedule

Stops the given schedule for this NPC.

```lua
CAI_BaseNPC:StopSchedule(schedule, dontKill)
```

**Parameters**

- **`schedule`**  
  `EntityHandle`  
  The previously created schedule
- **`dontKill`** *(optional)*  
  `boolean`  
  If true the schedule will not be killed at the same time

### SetState

Sets the state of the NPC by creating a new schedule.

```lua
CAI_BaseNPC:SetState(state)
```

**Parameters**

- **`state`**  
  `ScheduleState`  
  The NPC state that should be set

### HasEnemyTarget

Gets if this NPC has an enemy target.

This function only works with entities that have `enemy` or `distancetoenemy` criteria.

```lua
CAI_BaseNPC:HasEnemyTarget()
```

**Returns**
- **`boolean`**
True if the NPC has an enemy target

### EstimateEnemyTarget

Estimates the enemy that this NPC is fighting using its criteria values

This function only works with entities that have `enemy` criteria, e.g. "npc_combine_s", "npc_zombine", "npc_zombie_blind".

```lua
CAI_BaseNPC:EstimateEnemyTarget(distanceTolerance)
```

**Parameters**

- **`distanceTolerance`** *(optional)*  
  `number`  
  Discrepancy allowed when comparing distance to enemy; default is `1`

**Returns**
- **`EntityHandle?`**
Estimated enemy target

### SetRelationship

Sets the relationship of this NPC with another entity.

```lua
CAI_BaseNPC:SetRelationship(target, disposition, priority)
```

**Parameters**

- **`target`**  
  `string`, `EntityHandle`  
  Targetname, classname or entity.
- **`disposition`**  
  `RelationshipDisposition`  
  Type of relationship with `target`.
- **`priority`** *(optional)*  
  `number`  
  How much the Subject(s) should Like/Hate/Fear the Target(s). Higher priority = stronger feeling; default is 0.

### IsCreature

Checks if this NPC is a creature, e.g. combine, headcrab, player

Will return false for all other class types, such as npc_turret and npc_manhack.

```lua
CAI_BaseNPC:IsCreature()
```

**Returns**
- **`boolean`**
True if this NPC is a creature

### IsCombine

Checks if this NPC is a Combine creature.

```lua
CAI_BaseNPC:IsCombine()
```

**Returns**
- **`boolean`**
True if this NPC is Combine

### IsXen

Checks if this NPC is a Xen creature.

```lua
CAI_BaseNPC:IsXen()
```

**Returns**
- **`boolean`**
True if this NPC is Xen

### GetSquadMembers

Gets all members of the same squad as this NPC, including this NPC.

```lua
CAI_BaseNPC:GetSquadMembers()
```

**Returns**
- **`CAI_BaseNPC[]`**
List of NPC members

## Aliases

### RelationshipDisposition

Relationship disposition types.

| Value | Description |
| ----- | ----------- |
| `"D_HT"` | Hate |
| `"D_FR"` | Fear |
| `"D_LI"` | Like |
| `"D_NU"` | Neutral |
