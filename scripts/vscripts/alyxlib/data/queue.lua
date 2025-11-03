--[[
    v1.5.1
    https://github.com/FrostSource/alyxlib

    A queue is a data structure where items are added at one end and removed from the other, so the first item added is the first one taken out.

    If not using `alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.data.queue"
]]

local version = "v1.5.1"

---
---Queue data structure.
---
---@class Queue
local QueueClass =
{
    ---@type any[]
    items = {}
}
QueueClass.__index = QueueClass

if pcall(require, "alyxlib.storage") then
    Storage.RegisterType("Queue", QueueClass)

    ---
    ---**Static Function**
    ---
    ---Helper function for saving the `queue`.
    ---
    ---@param handle EntityHandle # The entity to save on
    ---@param name string # The name to save as
    ---@param queue Queue # The stack to save
    ---@return boolean # If the save was successful
    ---@luadoc-ignore
    function QueueClass.__save(handle, name, queue)
        return Storage.SaveTableCustom(handle, name, queue, "Queue")
    end

    ---
    ---**Static Function**
    ---
    ---Helper function for loading the `stack`.
    ---
    ---@param handle EntityHandle # Entity to load from
    ---@param name string # Name to load
    ---@return Queue|nil # The loaded stack
    ---@luadoc-ignore
    function QueueClass.__load(handle, name)
        local queue = Storage.LoadTableCustom(handle, name, "Queue")
        if queue == nil then return nil end
        return setmetatable(queue, QueueClass)
    end

    Storage.SaveQueue = QueueClass.__save
    CBaseEntity.SaveQueue = Storage.SaveQueue

    ---
    ---Loads a Queue.
    ---
    ---@generic T
    ---@param handle EntityHandle # Entity to load from
    ---@param name string # Name the Queue was saved as
    ---@param default? T # Optional default value
    ---@return Queue|T # The loaded Queue
    ---@luadoc-ignore
    Storage.LoadQueue = function(handle, name, default)
        local queue = QueueClass.__load(handle, name)
        if queue == nil then
            return default
        end
        return queue
    end
    CBaseEntity.LoadQueue = Storage.LoadQueue
end

---
---Adds values to the queue in the order they are provided.
---
---@param ... any # Any number of values
function QueueClass:Enqueue(...)
    for i = select("#", ...), 1, -1 do
        table.insert(self.items, 1, select(i, ...))
    end
end

---
---Removes and returns one or more items from the front of the queue.
---
---If `count` is omitted, a single item will is dequeued.
---
---@param count? number # Number of items to dequeue
---@return ... # The dequeued items in the original insertion order
function QueueClass:Dequeue(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = #self.items, #self.items-count+1, -1 do
        tbl[#tbl+1] = table.remove(self.items, i)
    end
    return unpack(tbl)
end

---
---Peeks at a number of items at the front of the queue without removing them.
---
---@param count? number # Number of items to peek at
---@return ... # The peeked items
function QueueClass:Front(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = #self.items, #self.items-count+1, -1 do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---
---Peeks at a number of items at the back of the queue without removing them.
---
---@param count? number # Number of items to peek at
---@return ... # The peeked items
function QueueClass:Back(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = 1, count do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---
---Removes a value from the queue regardless of its position.
---
---@param value any # The value to remove
function QueueClass:Remove(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            return
        end
    end
end

---
---Moves an existing value to the back of the queue.
---
---Only the furthest back occurance will be moved.
---
---@param value any # The value to move
---@return boolean # True if value was found and moved
function QueueClass:MoveToBack(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            table.insert(self.items, 1, value)
            return true
        end
    end
    return false
end

---
---Moves an existing value to the front of the queue.
---
---Only the furthest back occurance will be moved.
---
---@param value any # The value to move
---@return boolean # True if value was found and moved
function QueueClass:MoveToFront(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            table.insert(self.items, value)
            return true
        end
    end
    return false
end

---
---Gets if this queue contains a value.
---
---@param value any # The value to search for
---@return boolean # True if the value is in the queue
function QueueClass:Contains(value)
    return vlua.find(self.items, value) ~= nil
end

---
---Returns the number of items in the queue.
---
---@return integer # The number of items
function QueueClass:Length()
    return #self.items
end

---
---Gets if the stack is empty.
---
---@return boolean # True if the stack is empty
function QueueClass:IsEmpty()
    return #self.items == 0
end

---
---Helper method for looping.
---
---@return fun(table: any[], i: integer):integer, any
---@return any[]
---@return number i
function QueueClass:pairs()
    return ipairs(self.items)
end

function QueueClass:__tostring()
    return "Queue ("..#self.items.." items)"
end


---
---Create a new [Queue](lua://Queue) instance.
---
---Last value is at the front of the queue.
---
---E.g.
---
---    local queue = Queue(
---        "Back",
---        "Middle",
---        "Front"
---    )
---
---@param ... any # Starting values
---@return Queue # The new queue
function Queue(...)
    return setmetatable({
        items = {...}
    },
    QueueClass)
end

return version
