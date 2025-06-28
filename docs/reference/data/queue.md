# Data Queue

> scripts/vscripts/alyxlib/data/queue.lua

## Methods

### Enqueue

Add values to the queue in the order they appear.

```lua
Queue:Enqueue(...)
```

**Parameters**

- **`...`**  

### Dequeue

Get a number of values in reverse order of the queue.

```lua
Queue:Dequeue(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Default is 1

**Returns**
- **`...`**

### Front

Peek at a number of items at the front of the queue without removing them.

```lua
Queue:Front(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Default is 1

**Returns**
- **`...`**

### Back

Peek at a number of items at the back of the queue without removing them.

```lua
Queue:Back(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Default is 1

**Returns**
- **`...`**

### Remove

Remove a value from the queue regardless of its position.

```lua
Queue:Remove(value)
```

**Parameters**

- **`value`**  
  `any`  

### MoveToBack

Move an existing value to the front of the queue.
Only the first occurance will be moved.

```lua
Queue:MoveToBack(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to move.

**Returns**
- **`boolean`**
  True if value was found and moved.

### MoveToFront

Move an existing value to the bottom of the stack.
Only the first occurance will be moved.

```lua
Queue:MoveToFront(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to move.

**Returns**
- **`boolean`**
  True if value was found and moved.

### Contains

Get if this queue contains a value.

```lua
Queue:Contains(value)
```

**Parameters**

- **`value`**  
  `any`  

**Returns**
- **`boolean`**

### Length

Return the number of items in the queue.

```lua
Queue:Length()
```

**Returns**
- **`integer`**

### IsEmpty

Get if the stack is empty.

```lua
Queue:IsEmpty()
```

### pairs

Helper method for looping.

```lua
Queue:pairs()
```

**Returns**
- **`fun(table:`**
  any[], i: integer):integer, any
- **`any[]`**
- **`number`**
  i

## Functions

### Queue

Create a new `Queue` object.
Last value is at the front of the queue.

E.g.

`local queue = Queue(`
"Back",
"Middle",
"Front"
)

```lua
Queue(...)
```

**Parameters**

- **`...`**  

**Returns**
- **`Queue`**

## Types

### Queue
