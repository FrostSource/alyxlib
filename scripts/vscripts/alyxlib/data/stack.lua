--[[
    v1.2.2
    https://github.com/FrostSource/alyxlib

    Adds stack behaviour for tables with index 1 as the top of the stack.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.data.stack"
    ```

    ======================================== Usage ==========================================

    ```lua
    -- Create a stack with 3 initial values.
    -- 1 is the top of the stack.
    local stack = Stack(1, 2, 3)

    -- Prints "1"
    print(stack:Pop())

    -- Pop multiple values
    local a,b = stack:Pop(2)

    -- Prints "2   3"
    print(a,b)

    -- Push any values
    stack:Push('a','b','c')

    -- To loop over the items, reference stack.items directly:
    for index, value in ipairs(stack.items) do
        print(index, value)
    end

    -- Or use the `pairs` helper function:
    for index, value in stack:pairs() do
        print(index, value)
    end
    ```

    =========================================== Notes =============================================

    This class supports `storage` with `Storage.SaveStack()`:

    ```lua
    Storage:SaveStack('stack', stack)
    stack = Storage:LoadStack('stack')
    ```

    Stacks are also natively saved using `Storage.Save()` or if encountered in a table being saved.
]]

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
    ---@param handle EntityHandle # The entity to save on.
    ---@param name string # The name to save as.
    ---@param stack Stack # The stack to save.
    ---@return boolean # If the save was successful.
    ---@luadoc-ignore
    function StackClass.__save(handle, name, stack)
        return Storage.SaveTableCustom(handle, name, stack, "Stack")
    end

    ---
    ---**Static Function**
    ---
    ---Helper function for loading the `stack`.
    ---
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name to load.
    ---@return Stack|nil
    ---@luadoc-ignore
    function StackClass.__load(handle, name)
        local stack = Storage.LoadTableCustom(handle, name, "Stack")
        if stack == nil then return nil end
        return setmetatable(stack, StackClass)
    end

    Storage.SaveStack = StackClass.__save
    CBaseEntity.SaveStack = Storage.SaveStack

    ---
    ---Load a Stack.
    ---
    ---@generic T
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name the Stack was saved as.
    ---@param default? T # Optional default value.
    ---@return Stack|T
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
---Push values to the stack.
---
---@param ... any
function StackClass:Push(...)
    for _, value in ipairs({...}) do
        table.insert(self.items, 1, value)
    end
end

---
---Pop a number of items from the stack.
---
---@param count? number # Default is 1
---@return any
function StackClass:Pop(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = 1, count do
        tbl[#tbl+1] = table.remove(self.items, 1)
    end
    return unpack(tbl)
end

---
---Peek at a number of items at the top of the stack without removing them.
---
---@param count? number # Default is 1
---@return any
function StackClass:Top(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = 1, count do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---
---Peek at a number of items at the bottom of the stack without removing them.
---
---@param count? number # Default is 1
---@return any
function StackClass:Bottom(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = #self.items, #self.items-count+1, -1 do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---
---Remove a value from the stack regardless of its position.
---
---@param value any
function StackClass:Remove(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            return
        end
    end
end

---
---Move an existing value to the top of the stack.
---Only the first occurance will be moved.
---
---@param value any # The value to move.
---@return boolean # True if value was found and moved.
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
---Move an existing value to the bottom of the stack.
---Only the first occurance will be moved.
---
---@param value any # The value to move.
---@return boolean # True if value was found and moved.
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
---Get if this stack contains a value.
---
---@param value any
---@return boolean
function StackClass:Contains(value)
    return vlua.find(self.items, value) ~= nil
end

---
---Return the number of items in the stack.
---
---@return integer
function StackClass:Length()
    return #self.items
end

---
---Get if the stack is empty.
---
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
---Create a new `Stack` object.
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
