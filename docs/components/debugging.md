
Debugging and testing mods in Half-Life Alyx can be challenging and often requires 

The [debug menu](debug_menu.md) is also a very useful tool for debugging in VR.

Many debug functions have dedicated console commands so be sure to check the [console](console.md) page.

## Common functions

```lua
-- Recursively print a table with pretty formatting
Debug.PrintTable(tbl)

-- Get the class name of an entity, e.g. CBaseEntity
Debug.GetClassname(ent)

-- Prints a visual ASCII graph showing the distribution of values between a min/max bound
Debug.PrintGraph(height, min_val, max_val, name_value_pairs)

-- Gets the vector as a simple string representation with decimal places truncated
Debug.SimpleVector(vec)
-- Or use the global alias
vecstr(vec)

-- Returns a string made up of an entity's class and name in the format "[class, name]"
Debug.EntStr(ent)
-- Or use the global alias
entstr(ent)

-- Print a list of convars and their values to the console
Debug.DumpConvars(convarList)

-- Returns an entity hscript handle from its handle string, e.g. "table: 0x0012b03"
Debug.FindEntityByHandleString(handleString)

-- Converts a number to its ordinal string representation (e.g., 1 → "1st", 2 → "2nd", 3 → "3rd")
Debug.ToOrdinalString(n)

-- Get the script name and line number of a function or traceback level
Debug.GetSourceLine(functionOrLevel)

-- Safely calls a function while handling any errors
Debug.Try(func, arg1, arg2, ...)
```

## NoVR debugging

!!! warning
    NoVR debugging is a work in progress and might change in the future.

Putting on a VR headset to test every small change you make can be tiresome, so AlyxLib tries to improve the NoVR experience with easy bindings and interactions for both common and specific tasks that would otherwise require a VR headset.

TODO: add here after pushing latest novr

## Profiling

!!! warning
    Profiling might not exist in future versions of AlyxLib if Valve patches FFI.

!!! note
    Profiling only works on Windows for now.

The profiler is an accurate way of testing the performance of a function.

```lua
-- Create a profiler
local p = Profiler()

local function sumNumbers()
    local s = 0
    for i = 1, 1e6 do
        s = s + i
    end
    return s
end

-- Run it 10 times
for i = 1, 10 do
    p:Profile(sumNumbers)
end

-- Print the results
print("Mean:   ", p:GetMean())
print("Median: ", p:GetMedian())
print("Stddev: ", p:GetStandardDeviation())
print("Min:    ", p.min)
print("Max:    ", p.max)
```

You can also profile inside a think function using the "running total" mode.

```lua
-- Create profiler set for running totals
local thinkProfiler = Profiler(true)
local lastPrintTotal = 0

function Think()
    -- Do stuff
end

function ProfileThink()
    thinkProfiler:Profile(Think)

    -- Print results every 5 seconds
    if thinkProfiler.totalTime - lastPrintTotal >= 5 then
        print("Mean:   ", p:GetMean())
        print("Median: ", p:GetMedian())
        print("Stddev: ", p:GetStandardDeviation())
        print("Min:    ", p.min)
        print("Max:    ", p.max)
        lastPrintTotal = thinkProfiler.totalTime
    end
end

thisEntity:SetThink("ProfileThink", ProfileThink, 0)
```

## References

[Common Debugging](../reference/debug/common.md).

[VR Debugging](../reference/debug/vr.md).

[NoVR Debugging](../reference/debug/novr.md).

[Profiling](../reference/debug/profiling.md).