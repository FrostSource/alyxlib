--[[
    v1.2.4
    https://github.com/FrostSource/alyxlib

    A stack is a data structure where elements are added to the top and removed from the top, with the most recently added item being the first to be removed.

    If not using `alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.data.stack"
]]

local version = "v1.2.4"

---
---Stack data structure.
---
---@class Stack
local StackClass =
{
    ---@type any[]
    items = {}
}
StackClass.__index = StackClass

if pcall(require, "alyxlib.storage") then
    Storage.RegisterType("Stack", StackClass)

    ---
    ---**Static Function**
    ---
    ---Helper function for saving the `stack`.
    ---
    ---@param handle EntityHandle # The entity to save on
    ---@param name string # The name to save as
    ---@param stack Stack # The stack to save
    ---@return boolean # If the save was successful
    ---@luadoc-ignore
    function StackClass.__save(handle, name, stack)
        return Storage.SaveTableCustom(handle, name, stack, "Stack")
    end

    ---
    ---**Static Function**
    ---
    ---Helper function for loading the `stack`.
    ---
    ---@param handle EntityHandle # Entity to load from
    ---@param name string # Name to load
    ---@return Stack|nil # The loaded stack
    ---@luadoc-ignore
    function StackClass.__load(handle, name)
        local stack = Storage.LoadTableCustom(handle, name, "Stack")
        if stack == nil then return nil end
        return setmetatable(stack, StackClass)
    end

    Storage.SaveStack = StackClass.__save
    CBaseEntity.SaveStack = Storage.SaveStack

    ---
    ---Loads a Stack.
    ---
    ---@generic T
    ---@param handle EntityHandle # Entity to load from
    ---@param name string # Name the Stack was saved as
    ---@param default? T # Optional default value
    ---@return Stack|T # The loaded stack
    ---@luadoc-ignore
    Storage.LoadStack = function(handle, name, default)
        local stack = StackClass.__load(handle, name)
        if stack == nil then
            return default
        end
        return stack
    end
    CBaseEntity.LoadStack = Storage.LoadStack
end


---
---Pushes values to the stack.
---
---@param ... any # Any number of values
function StackClass:Push(...)
    for i = 1, select("#", ...) do
        table.insert(self.items, 1, select(i, ...))
    end
end

---
---Pops values from the stack.
---
---@param count? number # Number of items to pop
---@return ...
function StackClass:Pop(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = 1, count do
        tbl[#tbl+1] = table.remove(self.items, 1)
    end
    return unpack(tbl)
end

---
---Peeks at a number of items on the top of the stack without removing them.
---
---@param count? number # Number of items to peek
---@return ...
function StackClass:Top(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = 1, count do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---
---Peeks at a number of items on the bottom of the stack without removing them.
---
---@param count? number # Number of items to peek
---@return ...
function StackClass:Bottom(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = #self.items, #self.items-count+1, -1 do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---
---Removes a value from the stack regardless of its position.
---
---@param value any # The value to remove
function StackClass:Remove(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            return
        end
    end
end

---
---Moves an existing value to the top of the stack.
---
---Only the first occurance will be moved.
---
---@param value any # The value to move
---@return boolean # True if value was found and moved
function StackClass:MoveToTop(value)
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
---Moves an existing value to the bottom of the stack.
---
---Only the first occurance will be moved.
---
---@param value any # The value to move
---@return boolean # True if value was found and moved
function StackClass:MoveToBottom(value)
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
---Gets if this stack contains a value.
---
---@param value any # The value to search for
---@return boolean # True if the value is in the stack
function StackClass:Contains(value)
    return vlua.find(self.items, value) ~= nil
end

---
---Returns the number of items in the stack.
---
---@return integer # The number of items
function StackClass:Length()
    return #self.items
end

---
---Gets if the stack is empty.
---
---@return boolean # True if the stack is empty
function StackClass:IsEmpty()
    return #self.items == 0
end

---
---Helper method for looping.
---
---@return fun(table: any[], i: integer):integer, any
---@return any[]
---@return number i
function StackClass:pairs()
    return ipairs(self.items)
end

function StackClass:__tostring()
    return "Stack ("..#self.items.." items)"
end


---
---Creates a new [Stack](lua://Stack) object.
---
---First value is at the top.
---
---E.g.
---
---    local stack = Stack(
---        "Top",
---        "Middle",
---        "Bottom"
---    )
---
---@param ... any
---@return Stack
function Stack(...)
    return setmetatable({
        items = {...}
    },
    StackClass)
end

return version