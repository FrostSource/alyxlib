# Math Weighted_random

> scripts/vscripts/alyxlib/math/weighted_random.lua

## Methods

### Add

Adds a table value with an associated weight.

If `tbl` already has a weight key then `weight` parameter can be omitted.

**Note:** The table `tbl` is not cloned, the given reference is inserted into the list.

```lua
WeightedRandom:Add(tbl, weight)
```

**Parameters**

- **`tbl`**  
  `table`  
  Table of values that will be returned
- **`weight`** *(optional)*  
  `number`  
  Weight for this table

### TotalWeight

Gets the sum of all weights in the WeightedRandom.

```lua
WeightedRandom:TotalWeight()
```

**Returns**
- **`number`**
The sum of all weights

### Random

Picks a random table from the list of weighted tables.

```lua
WeightedRandom:Random()
```

**Returns**
- **`WeightedRandomItem|table`**
The randomly selected table

## Functions

### WeightedRandom

Creates a new WeightedRandom instance with given weights.

E.g.

??? example
    ```lua
    local wr = WeightedRandom({
        { weight = 1, name = "Common" },
        { weight = 0.75, name = "Semi-common" },
        { weight = 0.5, name = "Uncommon" },
        { weight = 0.25, name = "Rare" },
        { weight = 0.1, name = "Extremely rare" },
    })
    ```

```lua
WeightedRandom(weights)
```

**Parameters**

- **`weights`**  
  `WeightedRandomItem[]`  
  List of weighted tables

**Returns**
- **`WeightedRandom`**
The new WeightedRandom instance

## Types

### WeightedRandom

A list of tables with associated weights.

### WeightedRandomItem

Individual item in the list of weighted tables.

| Field | Type | Description |
| ---- | ---- | ----------- |
| weight | `number` | The weight of this item. |
