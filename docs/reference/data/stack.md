# Data Stack

> scripts/vscripts/alyxlib/data/stack.lua

## Methods

### Push

Pushes values to the stack.

```lua
Stack:Push(...)
```

**Parameters**

- **`...`**  

### Pop

Pops values from the stack.

```lua
Stack:Pop(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Number of items to pop

**Returns**
- **`...`**

### Top

Peeks at a number of items on the top of the stack without removing them.

```lua
Stack:Top(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Number of items to peek

**Returns**
- **`...`**

### Bottom

Peeks at a number of items on the bottom of the stack without removing them.

```lua
Stack:Bottom(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Number of items to peek

**Returns**
- **`...`**

### Remove

Removes a value from the stack regardless of its position.

```lua
Stack:Remove(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to remove

### MoveToTop

Moves an existing value to the top of the stack.

Only the first occurance will be moved.

```lua
Stack:MoveToTop(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to move

**Returns**
- **`boolean`**
True if value was found and moved

### MoveToBottom

Moves an existing value to the bottom of the stack.

Only the first occurance will be moved.

```lua
Stack:MoveToBottom(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to move

**Returns**
- **`boolean`**
True if value was found and moved

### Contains

Gets if this stack contains a value.

```lua
Stack:Contains(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to search for

**Returns**
- **`boolean`**
True if the value is in the stack

### Length

Returns the number of items in the stack.

```lua
Stack:Length()
```

**Returns**
- **`integer`**
The number of items

### IsEmpty

Gets if the stack is empty.

```lua
Stack:IsEmpty()
```

**Returns**
- **`boolean`**
True if the stack is empty

### pairs

Helper method for looping.

```lua
Stack:pairs()
```

**Returns**

- **`function`**  
    

- **`any[]`**  
    

- **`number`**  
   *`i`*  

## Functions

### Stack

Creates a new [Stack](lua://Stack) object.

First value is at the top.

E.g.

??? example
    ```lua
    local stack = Stack(
        "Top",
        "Middle",
        "Bottom"
    )
    ```

```lua
Stack(...)
```

**Parameters**

- **`...`**  

**Returns**
- **`Stack`**

## Types

### Stack

Stack data structure.
