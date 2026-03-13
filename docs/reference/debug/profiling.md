# Debug Profiling

> scripts/vscripts/alyxlib/debug/profiling.lua

## Methods

### Profile

Profile a single function.

If profiling a single function, use `profiler.totalTime` to get the total time the function took to run.

If profiling a think, use [profiler:GetMean()](lua://Profiler.GetMean) and other methods.

```lua
Profiler:Profile(func)
```

**Parameters**

- **`func`**  
  `function`  
  The function to profile

**Returns**
- **`any`**
Returns the result of `func`

### GetMean

Gets the mean (average) profiled time in seconds.

```lua
Profiler:GetMean()
```

**Returns**
- **`number`**
The mean profiled time

### GetMedian

Gets the median profiled time in seconds.

```lua
Profiler:GetMedian()
```

**Returns**
- **`number`**
The median profiled time

### GetStandardDeviation

Calculates the standard deviation of the measurements.

The standard deviation is used to determine how spread out the measurements are.
The higher the value, the more the measurements deviate from the mean, indicating greater variability.
A lower value means the measurements are closer to the mean, indicating more consistency.
A result of 0 means there is no variability (either because all measurements are the same, or there are no measurements).

```lua
Profiler:GetStandardDeviation()
```

**Returns**
- **`number`**
The standard deviation

## Functions

### Profiler

Creates a new profiler instance.

```lua
Profiler(useRunningTotal)
```

**Parameters**

- **`useRunningTotal`** *(optional)*  
  `boolean`  
  If the profiler should keep a running total instead of keeping all profiled times in memory (use this if you run out of memory profiling)

**Returns**
- **`Profiler`**

## Types

### Profiler

Profiler class.
