--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Profiler allows for easy profiling of functions.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.debug.profiling"
]]
local __enable_ffi = 0x666ULL

local ffi = require("ffi")

ffi.cdef[[
    typedef long long int64_t;
    typedef struct {
        int64_t QuadPart;
    } LARGE_INTEGER;
    int QueryPerformanceCounter(LARGE_INTEGER *lpPerformanceCount);
    int QueryPerformanceFrequency(LARGE_INTEGER *lpFrequency);
]]

local kernal32 = ffi.load("kernel32")

local freq = ffi.new("LARGE_INTEGER")
kernal32.QueryPerformanceFrequency(freq)

---
---Profiler class
---
---@class Profiler
local profiler = {

    ---Minimum elapsed time in seconds
    ---@type number
    min = 0,
    ---Maximum elapsed time in seconds
    ---@type number
    max = 0,

    ---Maximum measurements that can be tracked in `useRunningTotal` mode
    maxMeasurements = 10,

    ---Time from the last called `Profile` method
    previousTime = 0,

    ---If the profiler should track running values or all values
    ---Use `true` if profiling a long think or function
    useRunningTotal = false,
}
profiler.__index = profiler

---@private
profiler.updateIndex = 1

---Start time integer pointer
---@private
profiler.start = ffi.new("LARGE_INTEGER")
---Stop time integer pointer
---@private
profiler.stop = ffi.new("LARGE_INTEGER")

---Total elapsed time from all profiled functions.
---@private
profiler.totalTime = 0

---List of all elapsed times profiled. If `useRunningTotal` is true this will always be empty.
---@private
---@type number[]
profiler.measurements = {}

---Total number of measurements taken by the profiler.
---@private
profiler.numMeasurements = 0

---A running total of elapsed times squared.
---@private
profiler.runningSumSquares = 0

---
---Profile a single function.
---
---If profiling a single function, use `profiler.totalTime` to get the total time the function took to run.
---
---If profiling a think, use [profiler:GetMean()](lua://Profiler.GetMean) and other methods.
---
---@param func function # The function to profile
---@return any # Returns the result of `func`
function profiler:Profile(func)
    kernal32.QueryPerformanceCounter(self.start)
    local result = func()
    kernal32.QueryPerformanceCounter(self.stop)
    ---@diagnostic disable-next-line: undefined-field
    local elapsed = tonumber(ffi.cast("double", self.stop.QuadPart - self.start.QuadPart)) / tonumber(ffi.cast("double", freq.QuadPart))

    self.previousTime = elapsed
    self.min = min(self.min, elapsed)
    self.max = max(self.max, elapsed)
    self.numMeasurements = self.numMeasurements + 1
    self.totalTime = self.totalTime + elapsed
    if self.useRunningTotal then
        self.runningSumSquares = self.runningSumSquares + elapsed * elapsed
        -- Keep a running list of times
        self.measurements[self.updateIndex] = elapsed
        self.updateIndex = (self.updateIndex % self.maxMeasurements) + 1
    else
        table.insert(self.measurements, elapsed)
    end

    return result
end

---
---Get the mean (average) profiled time in seconds.
---
---@return number
function profiler:GetMean()
    return self.totalTime / self.numMeasurements
end

---
---Get the median profiled time in seconds.
---
---@return number
function profiler:GetMedian()
    if self.numMeasurements == 0 then
        return 0
    end

    local sortedValues = {unpack(self.measurements)}
    table.sort(sortedValues)
    local count = #sortedValues
    if count % 2 == 1 then
        return sortedValues[(count + 1) / 2]
    else
        local mid = count / 2
        return (sortedValues[mid] + sortedValues[mid + 1]) / 2
    end
end

---
---Calculate the standard deviation of the measurements.
---
---The standard deviation is used to determine how spread out the measurements are.
---The higher the value, the more the measurements deviate from the mean, indicating greater variability.
---A lower value means the measurements are closer to the mean, indicating more consistency.
---A result of 0 means there is no variability (either because all measurements are the same, or there are no measurements).
---
---@return number
function profiler:GetStandardDeviation()
    local mean = self:GetMean()
    if self.useRunningTotal then
        local variance = (self.runningSumSquares - self.numMeasurements * mean * mean) / (self.numMeasurements - 1)
        return math.sqrt(variance)
    else
        if self.numMeasurements == 0 then
            return 0
        end

        local squaredDifferencesSum = 0
        for _, value in ipairs(self.measurements) do
            squaredDifferencesSum = squaredDifferencesSum + (value - mean) ^ 2
        end
        local variance = squaredDifferencesSum / #self.measurements
        return math.sqrt(variance)
    end
end

---
---Creates a new profiler instance.
---
---@param useRunningTotal? boolean # If the profiler should keep a running total instead of keeping all profiled times in memory (use this if you run out of memory profiling)
---@return Profiler
function Profiler(useRunningTotal)
    return setmetatable({
        start = ffi.new("LARGE_INTEGER"),
        stop = ffi.new("LARGE_INTEGER"),
        totalTime =  0,
        measurements = {},

        useRunningTotal = useRunningTotal == true
    }, profiler)
end
