# Data Color

> scripts/vscripts/alyxlib/data/color.lua

## Methods

### ToHexString

Converts this `Color` to a hexadecimal representation.

The hexadecimal string is in the format #RRGGBB.

```lua
Color:ToHexString()
```

**Returns**
- **`string`**
The hexadecimal representation of this [Color](lua://Color)

### ToVector

Returns a [Vector](lua://Vector) from this [Color](lua://Color).
In the form of [x=r, y=g, z=b], with ranges [0-255].

```lua
Color:ToVector()
```

**Returns**
- **`Vector`**
The vector representation of this [Color](lua://Color)

### ToDecimalVector

Returns a [Vector](lua://Vector) from this [Color](lua://Color).
In the form of [x=r, y=g, z=b], with ranges [0-1].

```lua
Color:ToDecimalVector()
```

**Returns**
- **`Vector`**
The decimal vector representation of this [Color](lua://Color)

### SetRGB

Sets the RGBA components of this [Color](lua://Color).

If any of the provided values have fractional parts, they will all be normalized to the range [0, 255].
If any of the provided values are nil or omitted, the corresponding component of the color will remain unchanged.

```lua
Color:SetRGB(r, g, b, a)
```

**Parameters**

- **`r`** *(optional)*  
  `number`  
  The red component of the color
- **`g`** *(optional)*  
  `number`  
  The green component of the color
- **`b`** *(optional)*  
  `number`  
  The blue component of the color
- **`a`** *(optional)*  
  `number`  
  The alpha component of the color

### GetHSL

Gets the HSL color values for this [Color](lua://Color).

```lua
Color:GetHSL()
```

**Returns**

- **`number`**  
   *`h`*  
Hue color value in range [0-360]

- **`number`**  
   *`s`*  
Saturation color value in range [0-100]

- **`number`**  
   *`l`*  
Lightness color value in range [0-100]

### SetHSL

Sets the HSL (Hue, Saturation, Lightness) components of this [Color](lua://Color).

If any of the provided values have fractional parts, they will be normalized to their appropriate ranges (0 to 360 for hue, 0 to 100 for saturation and lightness).
If any of the provided values are nil or omitted, the corresponding component of the color will remain unchanged.

```lua
Color:SetHSL(h, s, l)
```

**Parameters**

- **`h`** *(optional)*  
  `number`  
  The hue value of the color (0 to 360), representing the color's position on the color wheel
- **`s`** *(optional)*  
  `number`  
  The saturation value of the color (0 to 100), determining the intensity of the color
- **`l`** *(optional)*  
  `number`  
  The lightness value of the color (0 to 100), affecting the brightness of the color

## Functions

### Color

Creates a new [Color](lua://Color) instance using range [0-255] or [0-1].

```lua
Color(r, g, b, a)
```

**Parameters**

- **`r`** *(optional)*  
  `number`  
  Red color value
- **`g`** *(optional)*  
  `number`  
  Green color value
- **`b`** *(optional)*  
  `number`  
  Blue color value
- **`a`** *(optional)*  
  `number`  
  Alpha value

**Returns**
- **`Color`**
The new [Color](lua://Color)

### IsColor

Checks if a value is a `Color`.

```lua
IsColor(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to check

**Returns**
- **`boolean`**
`true` if the value is a [Color](lua://Color), `false` otherwise

## Types

### Color

Represents a color object with RGB and HSL components.

| Field | Type | Description |
| ---- | ---- | ----------- |
| r | `integer` | Red component |
| g | `integer` | Green component |
| b | `integer` | Blue component |
| a | `integer` | Alpha component |
| hue | `integer` | Hue component |
| saturation | `integer` | Saturation component |
| lightness | `integer` | Lightness component |
