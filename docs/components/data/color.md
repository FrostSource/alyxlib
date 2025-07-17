## color.lua

> Easy modification of colors between RGB and HSL systems
>
> This class registers with `Storage` for easy saving/loading

```lua
-- Create a red color with full alpha
local red = Color(255, 0, 0, 255)

-- Or by just providing the red. Blue and green will implicitly be 0, and alpha will implicitly be 255
red = Color(255)

-- Same implicit values but with green
local green = Color(nil, 255)

-- Make the color 50% darker
green:SetHSL(nil, nil, green.lightness * 0.5)

-- Get/Set any value individually
green.r = 128 -- Accepts a range of [0-255]
green.g = 0 -- Accepts a range of [0-255]
green.b = 255 -- Accepts a range of [0-255]
green.a = 0 -- Accepts a range of [0-255]
green.hue = 300 -- Accepts a range of [0-360]
green.saturation = 50 -- Accepts a range of [0-100]%
green.lightness = 25 -- Accepts a range of [0-100]%

-- Get the hexadecimal version of a color
print(green:ToHexString())

-- Check if any value is an instance of the color class
if IsColor(green) then
    print("Is a color")
end
```