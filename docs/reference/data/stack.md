# Data Stack

> scripts/vscripts/alyxlib/data/stack.lua

## Methods

### Push

Push values to the stack.

```lua
Stack:Push(...)
```

**Parameters**

- **`...`**  

### Pop

Pop a number of items from the stack.

```lua
Stack:Pop(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Default is 1

**Returns**
- **`...`**

### Top

Peek at a number of items at the top of the stack without removing them.

```lua
Stack:Top(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Default is 1

**Returns**
- **`...`**

### Bottom

Peek at a number of items at the bottom of the stack without removing them.

```lua
Stack:Bottom(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Default is 1

**Returns**
- **`...`**

### Remove

Remove a value from the stack regardless of its position.

```lua
Stack:Remove(value)
```

**Parameters**

- **`value`**  
  `any`  

### MoveToTop

Move an existing value to the top of the stack.
Only the first occurance will be moved.

```lua
Stack:MoveToTop(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to move.

**Returns**
- **`boolean`**
True if value was found and moved.

### MoveToBottom

Move an existing value to the bottom of the stack.
Only the first occurance will be moved.

```lua
Stack:MoveToBottom(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to move.

**Returns**
- **`boolean`**
True if value was found and moved.

### Contains

Get if this stack contains a value.

```lua
Stack:Contains(value)
```

**Parameters**

- **`value`**  
  `any`  

**Returns**
- **`boolean`**

### Length

Return the number of items in the stack.

```lua
Stack:Length()
```

**Returns**
- **`integer`**

### IsEmpty

Get if the stack is empty.

```lua
Stack:IsEmpty()
```

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

Create a new `Stack` object.
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
