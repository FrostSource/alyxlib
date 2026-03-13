# Data Queue

> scripts/vscripts/alyxlib/data/queue.lua

## Methods

### Enqueue

Adds values to the queue in the order they are provided.

```lua
Queue:Enqueue(...)
```

**Parameters**

- **`...`**  

### Dequeue

Removes and returns one or more items from the front of the queue.

If `count` is omitted, a single item will is dequeued.

```lua
Queue:Dequeue(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Number of items to dequeue

**Returns**
- **`...`**
The dequeued items in the original insertion order

### Front

Peeks at a number of items at the front of the queue without removing them.

```lua
Queue:Front(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Number of items to peek at

**Returns**
- **`...`**
The peeked items

### Back

Peeks at a number of items at the back of the queue without removing them.

```lua
Queue:Back(count)
```

**Parameters**

- **`count`** *(optional)*  
  `number`  
  Number of items to peek at

**Returns**
- **`...`**
The peeked items

### Remove

Removes a value from the queue regardless of its position.

```lua
Queue:Remove(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to remove

### MoveToBack

Moves an existing value to the back of the queue.

Only the furthest back occurance will be moved.

```lua
Queue:MoveToBack(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to move

**Returns**
- **`boolean`**
True if value was found and moved

### MoveToFront

Moves an existing value to the front of the queue.

Only the furthest back occurance will be moved.

```lua
Queue:MoveToFront(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to move

**Returns**
- **`boolean`**
True if value was found and moved

### Contains

Gets if this queue contains a value.

```lua
Queue:Contains(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to search for

**Returns**
- **`boolean`**
True if the value is in the queue

### Length

Returns the number of items in the queue.

```lua
Queue:Length()
```

**Returns**
- **`integer`**
The number of items

### IsEmpty

Gets if the stack is empty.

```lua
Queue:IsEmpty()
```

**Returns**
- **`boolean`**
True if the stack is empty

### pairs

Helper method for looping.

```lua
Queue:pairs()
```

**Returns**

- **`function`**  
    

- **`any[]`**  
    

- **`number`**  
   *`i`*  

## Functions

### Queue

Create a new [Queue](lua://Queue) instance.

Last value is at the front of the queue.

E.g.

??? example
    ```lua
    local queue = Queue(
        "Back",
        "Middle",
        "Front"
    )
    ```

```lua
Queue(...)
```

**Parameters**

- **`...`**  

**Returns**
- **`Queue`**
The new queue

## Types

### Queue

Queue data structure.
