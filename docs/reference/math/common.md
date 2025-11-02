# Math Common

> scripts/vscripts/alyxlib/math/common.lua

## Methods

### sign

Get the sign of a number.

```lua
math:sign(x)
```

**Parameters**

- **`x`**  
  `number`  
  The input number.

**Returns**
- **`1|0|-1`**
Returns 1 if the number is positive, -1 if the number is negative, or 0 if the number is zero.

### trunc

Truncates a number to the specified number of decimal places.

```lua
math:trunc(number, places)
```

**Parameters**

- **`number`**  
  `number`  
  The input number.The input number.
- **`places`** *(optional)*  
  `integer`  
  The number of decimal places to keep.

**Returns**
- **`number`**
The input number truncated to the specified decimal places.

### round

Rounds a number to the specified number of decimal places.

```lua
math:round(number, decimals)
```

**Parameters**

- **`number`**  
  `number`  
  The input number to be rounded.
- **`decimals`** *(optional)*  
  `integer`  
  The number of decimal places to round to. If not provided, the number will be rounded to the nearest whole number.

**Returns**
- **`number`**
The input number rounded to the specified decimal places or nearest whole number.

### isclose

Checks if two numbers are close to each other within a specified tolerance.


**Examples:**

1. **Relative Tolerance (`rel_tol`)**:
```lua
local result1 = math.isclose(1000, 1020, 0.02)

    -- Expected Output: true

    -- Explanation: The difference (20) is within 2% of the larger number (1020), which allows a maximum difference of 20.4.
```

2. **Absolute Tolerance (`abs_tol`)**:
```lua
local result2 = math.isclose(1000, 1015, nil, 15)

    -- Expected Output: true

    -- Explanation: The difference (15) is within the fixed absolute tolerance of 15.
```

```lua
math:isclose(a, b, rel_tol, abs_tol)
```

**Parameters**

- **`a`**  
  `number`  
  The first number to compare.
- **`b`**  
  `number`  
  The second number to compare.
- **`rel_tol`** *(optional)*  
  `number`  
  The relative tolerance (optional). Defines the maximum allowed relative difference between `a` and `b` as a percentage of the larger of the two values.
- **`abs_tol`** *(optional)*  
  `number`  
  The absolute tolerance (optional). Defines the maximum allowed fixed difference between `a` and `b`, regardless of their magnitudes.

**Returns**
- **`boolean`**
Returns `true` if the numbers are considered close based on the specified tolerances; otherwise, returns `false`.

### has_frac

Checks if a given number has a fractional part (decimal part).

```lua
math:has_frac(number)
```

**Parameters**

- **`number`**  
  `number`  
  The number to check for fractional part.

**Returns**
- **`boolean`**
True if the number has a fractional part, false otherwise.

### get_frac

Returns the fractional part of a number.

```lua
math:get_frac(number)
```

**Parameters**

- **`number`**  
  `number`  
  The number to get the fractional part of.

**Returns**
- **`number`**
The fractional part of the number.
