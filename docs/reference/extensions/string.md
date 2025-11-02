# Extensions String

> scripts/vscripts/alyxlib/extensions/string.lua

## Methods

### startswith

Gets if a string starts with a substring.

```lua
string:startswith(s, substr)
```

**Parameters**

- **`s`**  
  `string`  
- **`substr`**  
  `string`  

**Returns**
- **`boolean`**

### endswith

Gets if a string ends with a substring.

```lua
string:endswith(s, substr)
```

**Parameters**

- **`s`**  
  `string`  
- **`substr`**  
  `string`  

**Returns**
- **`boolean`**

### splitraw

Split an input string using a raw pattern string. No changes are made to the pattern.

```lua
string:splitraw(s, pattern)
```

**Parameters**

- **`s`**  
  `string`  
- **`pattern`**  
  `string`  
  Split pattern.

**Returns**
- **`string[]`**

### split

Split an input string using a separator string.

```lua
string:split(s, sep)
```

**Parameters**

- **`s`**  
  `string`  
- **`sep`**  
  `string?`  
  String to split by. Default is whitespace.

**Returns**
- **`string[]`**

### truncate

Truncates a string to a maximum length.
If the string is shorter than `len` the original string is returned.

```lua
string:truncate(s, len, replacement)
```

**Parameters**

- **`s`**  
  `string`  
- **`len`**  
  `integer`  
  Maximum length the string can be.
- **`replacement`** *(optional)*  
  `string`  
  Suffix for long strings. Default is '...'

**Returns**
- **`string`**

### trimleft

Trims characters from the left side of the string up to the last occurrence of a specified character.

```lua
string:trimleft(s, char)
```

**Parameters**

- **`s`**  
  `string`  
- **`char`**  
  `string`  
  The character to trim the string at the last occurrence.

**Returns**
- **`string`**
The trimmed string.

### trimright

Trims characters from the right side of the string up to the last occurrence of a specified character.

```lua
string:trimright(s, char)
```

**Parameters**

- **`s`**  
  `string`  
- **`char`**  
  `string`  
  The character to trim the string at the last occurrence.

**Returns**
- **`string`**
The trimmed string.

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
  The input string to be capitalized.
- **`onlyFirstLetter`**  
  `boolean`  
  (optional) If true, only the first letter is capitalized. Default is false.

**Returns**
- **`string`**
The capitalized string.
