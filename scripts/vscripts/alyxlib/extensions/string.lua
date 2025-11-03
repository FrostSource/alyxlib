--[[
    v1.3.1
    https://github.com/FrostSource/alyxlib

    Provides string class extension methods.

    If not using `alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.extensions.string"
]]

local version = "v1.3.1"

---Escapes special characters in a string.
---@param s string # The string to escape
---@return string # The escaped string
local function escape(s)
    return (s:gsub("([^%w])", "%%%1"))
end

---
---Checks if a string starts with a substring.
---
---@param s string # The string to check
---@param substr string # The substring to check
---@return boolean # `true` if the string starts with the substring, `false` otherwise
function string.startswith(s, substr)
    return s:sub(1, #substr) == substr
end

---
---Checks if a string ends with a substring.
---
---@param s string # The string to check
---@param substr string # The substring to check
---@return boolean # `true` if the string ends with the substring, `false` otherwise
function string.endswith(s, substr)
    return substr == "" or s:sub(-#substr) == substr
end

---
---Splits a string using a raw pattern string. No changes are made to the pattern.
---
---@param s string # String to split.
---@param pattern string # Split pattern
---@return string[] # Array of split strings
function string.splitraw(s, pattern)
    local t = {}
    for str in s:gmatch(pattern) do
        table.insert(t, str)
    end
    return t
end

---
---Splits a string using a separator string.
---
---If `sep` is omitted, splits on whitespace (`%s`).
---
---Uses Lua pattern matching; escape special characters if needed.
---
---@link https://stackoverflow.com/a/7615129
---
---@param s string # String to split
---@param sep string? # String to split by
---@return string[] # Array of split strings
function string.split(s, sep)
    if sep == nil then
        sep = '%s'
    else
        sep = escape(sep)
    end
    return string.splitraw(s, '([^'..sep..']+)')
end

---
---Truncates a string to a maximum length.
---
---If the string is shorter than `len` the original string is returned.
---
---@param s string # String to truncate
---@param len integer # Maximum length the string can be
---@param replacement? string # Suffix for long strings. Default is `...`
---@return string # The truncated string
function string.truncate(s, len, replacement)
    replacement = replacement or "..."
    if #s > len then
        return s:sub(1, len - #replacement) .. replacement
    end
    return tostring(s)
end

---
---Slices the string from the left, returning everything after the last occurrence of a specified character.
---
---@param s string # The string to slice
---@param char string # The character to trim the string at the last occurrence
---@return string # The trimmed string
function string.sliceleft(s, char)
    local index = s:match(".*" .. escape(char) .. "()")
    return index and s:sub(index) or s
end


---
---Slices the string from the right, returning everything before the first occurrence of a specified character.
---
---@param s string # The string to slice
---@param char string # The character to trim the string at the last occurrence
---@return string # The trimmed string
function string.sliceright(s, char)
    local index = s:find(escape(char))
    return index and s:sub(1, index - 1) or s
end

---
---Trims characters from the left side of a string.
---
---@param s string # String to trim
---@param chars? string # Characters to trim (defaults to whitespace)
---@return string # The trimmed string
function string.trimleft(s, chars)
    if chars == nil then
        chars = "%s"
    else
        chars = escape(chars)
    end
    return (s:gsub("^[" .. chars .. "]+", ""))
end

---
---Trims characters from the right side of a string.
---
---@param s string # String to trim
---@param chars? string # Characters to trim (defaults to whitespace)
---@return string # The trimmed string
function string.trimright(s, chars)
    if chars == nil then
        chars = "%s"
    else
        chars = escape(chars)
    end
    return (s:gsub("[" .. chars .. "]+$", ""))
end

---
---Trims characters from both sides of a string.
---
---@param s string # String to trim
---@param chars? string # Characters to trim (defaults to whitespace)
---@return string # The trimmed string
function string.trim(s, chars)
    return string.trimleft(string.trimright(s, chars), chars)
end

---
---Capitalizes letters in the input string.
---
---If `onlyFirstLetter` is true, it capitalizes only the first letter.
---
---If `onlyFirstLetter` is false or not provided, it capitalizes all letters.
---
---@param s string # The string to be capitalized
---@param onlyFirstLetter? boolean # If true, only the first letter is capitalized
---@return string # The capitalized string
function string.capitalize(s, onlyFirstLetter)
    if onlyFirstLetter then
        local upper = s:gsub("^%l", string.upper)
        return upper
    else
        local upper = s:gsub("%a", string.upper)
        return upper
    end
end

return version