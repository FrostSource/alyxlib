# Extensions String

> scripts/vscripts/alyxlib/extensions/string.lua

## Methods

### startswith

Checks if a string starts with a substring.

```lua
string:startswith(s, substr)
```

**Parameters**

- **`s`**  
  `string`  
  The string to check
- **`substr`**  
  `string`  
  The substring to check

**Returns**
- **`boolean`**
`true` if the string starts with the substring, `false` otherwise

### endswith

Checks if a string ends with a substring.

```lua
string:endswith(s, substr)
```

**Parameters**

- **`s`**  
  `string`  
  The string to check
- **`substr`**  
  `string`  
  The substring to check

**Returns**
- **`boolean`**
`true` if the string ends with the substring, `false` otherwise

### splitraw

Splits a string using a raw pattern string. No changes are made to the pattern.

```lua
string:splitraw(s, pattern)
```

**Parameters**

- **`s`**  
  `string`  
  String to split.
- **`pattern`**  
  `string`  
  Split pattern

**Returns**
- **`string[]`**
Array of split strings

### split

Splits a string using a separator string.

If `sep` is omitted, splits on whitespace (`%s`).

Uses Lua pattern matching; escape special characters if needed.

```lua
string:split(s, sep)
```

**Parameters**

- **`s`**  
  `string`  
  String to split
- **`sep`**  
  `string?`  
  String to split by

**Returns**
- **`string[]`**
Array of split strings

### truncate

Truncates a string to a maximum length.

If the string is shorter than `len` the original string is returned.

```lua
string:truncate(s, len, replacement)
```

**Parameters**

- **`s`**  
  `string`  
  String to truncate
- **`len`**  
  `integer`  
  Maximum length the string can be
- **`replacement`** *(optional)*  
  `string`  
  Suffix for long strings. Default is `...`

**Returns**
- **`string`**
The truncated string

### trimleft

Trims characters from the left side of a string.

```lua
string:trimleft(s, chars)
```

**Parameters**

- **`s`**  
  `string`  
  String to trim
- **`chars`** *(optional)*  
  `string`  
  Characters to trim (defaults to whitespace)

**Returns**
- **`string`**
The trimmed string

### trimright

Trims characters from the right side of a string.

```lua
string:trimright(s, chars)
```

**Parameters**

- **`s`**  
  `string`  
  String to trim
- **`chars`** *(optional)*  
  `string`  
  Characters to trim (defaults to whitespace)

**Returns**
- **`string`**
The trimmed string

### capitalize

Capitalizes letters in the input string.

If `onlyFirstLetter` is true, it capitalizes only the first letter.

If `onlyFirstLetter` is false or not provided, it capitalizes all letters.

```lua
string:capitalize(s, onlyFirstLetter)
```

**Parameters**

- **`s`**  
  `string`  
  The string to be capitalized
- **`onlyFirstLetter`** *(optional)*  
  `boolean`  
  If true, only the first letter is capitalized

**Returns**
- **`string`**
The capitalized string
