# Debug Debug_menu

> scripts/vscripts/alyxlib/debug/debug_menu.lua

## Properties

### version

```lua
DebugMenu.version = value
```

**Default value**
  `"v1.1.0"`

### panel

```lua
DebugMenu.panel = value
```

**Default value**
  `nil`

### categories

```lua
DebugMenu.categories = value
```

**Default value**
  `table`

## Methods

### UpdateMenuAttachment

Updates the physical menu by attaching it to the correct hand.

```lua
DebugMenu:UpdateMenuAttachment()
```

### ShowMenu

Creates and displays the debug menu panel on the player's chosen hand.

```lua
DebugMenu:ShowMenu()
```

### CloseMenu

Closes the debug menu panel.

```lua
DebugMenu:CloseMenu()
```

### IsOpen

Returns whether the debug menu is currently open.

```lua
DebugMenu:IsOpen()
```

**Returns**
- **`boolean`**
True if the debug menu is open

### ClickHoveredButton

Clicks the active button on the debug menu panel (the one highlighted by the finger).

This is handled automatically in most cases.

```lua
DebugMenu:ClickHoveredButton()
```

### GetItem

Gets a debug menu item by id.

```lua
DebugMenu:GetItem(id, categoryId)
```

**Parameters**

- **`id`**  
  `string`  
  The item ID
- **`categoryId`** *(optional)*  
  `string`  
  Optionally specify a category to look in. If not specified, will look in all categories

**Returns**
- **`DebugMenuItem?`**
The item if it exists

### GetCategory

Gets a debug menu category by id.

```lua
DebugMenu:GetCategory(id)
```

**Parameters**

- **`id`**  
  `string`  
  The category ID

**Returns**

- **`DebugMenuCategory?`**  
    
The category if it exists

- **`number?`**  
    
The index of the category in the categories table

### AddCategory

Adds a category to the debug menu.

```lua
DebugMenu:AddCategory(id, name)
```

**Parameters**

- **`id`**  
  `string`  
  The unique ID for this category
- **`name`**  
  `string`  
  The display name for this category

### RemoveCategory

Removes a category from the debug menu.

This does not update the menu if it's already open;
use [DebugMenu:Refresh()](lua://DebugMenu.Refresh) to update manually.

```lua
DebugMenu:RemoveCategory(id)
```

**Parameters**

- **`id`**  
  `string`  
  The ID of the category to remove

### AddSeparator

Adds a separator line to a category.

```lua
DebugMenu:AddSeparator(categoryId, separatorId, text)
```

**Parameters**

- **`categoryId`**  
  `string`  
  The category ID to add the separator to
- **`separatorId`** *(optional)*  
  `string`  
  Optional ID for the separator if you want to modify it later
- **`text`** *(optional)*  
  `string`  
  Optional title text to display on the separator

### AddButton

Adds a button to a category.

```lua
DebugMenu:AddButton(categoryId, buttonId, text, command)
```

**Parameters**

- **`categoryId`**  
  `string`  
  The category ID to add the button to
- **`buttonId`**  
  `string`  
  The unique ID for this button
- **`text`**  
  `string`  
  The text to display on this button
- **`command`**  
  `string`, `function`  
  The console command or function to run when this button is pressed

### AddToggle

Adds a toggle to a category.

```lua
DebugMenu:AddToggle(categoryId, toggleId, text, convar, callback, startsOn)
```

**Parameters**

- **`categoryId`**  
  `string`  
  The category ID to add the toggle to
- **`toggleId`**  
  `string`  
  The unique ID for this toggle
- **`text`**  
  `string`  
  The text to display on this toggle
- **`convar`** *(optional)*  
  `string`  
  The console variable tied to this toggle
- **`callback`** *(optional)*  
  `function`  
  Function to run when this toggle is toggled
- **`startsOn`** *(optional)*  
  `boolean`, `function`  
  Whether the toggle is on by default

### AddLabel

Adds a center aligned label to a category.

```lua
DebugMenu:AddLabel(categoryId, labelId, text)
```

**Parameters**

- **`categoryId`**  
  `string`  
  The category ID to add the label to
- **`labelId`**  
  `string`  
  The unique ID for this label
- **`text`**  
  `string`  
  The text to display on this label

### AddSlider

Adds value slider to a category.

```lua
DebugMenu:AddSlider(categoryId, sliderId, text, convar, min, max, isPercentage, truncate, increment, callback, defaultValue)
```

**Parameters**

- **`categoryId`**  
  `string`  
  The ID of the category to add this slider to
- **`sliderId`**  
  `string`  
  A unique ID for this slider
- **`text`**  
  `string`  
  Display text for the slider
- **`convar`**  
  `string`  
  The console variable to tie this slider to
- **`min`**  
  `number`  
  Minimum allowed value
- **`max`**  
  `number`  
  Maximum allowed value
- **`isPercentage`**  
  `boolean`  
  If true, value will be displayed as a percentage (0-100)
- **`truncate`** *(optional)*  
  `number`  
  Number of decimal places (0 = integer, -1 = no truncating)
- **`increment`** *(optional)*  
  `number`  
  Snap increment (0 disables snapping)
- **`callback`** *(optional)*  
  `function`  
  Callback function
- **`defaultValue`** *(optional)*  
  `number`, `function`  
  Starting value. Set nil to use the convar value whenever the menu opens

### AddCycle

Adds a value cycler to a category.

Cyclers allow users to choose from a set of values.

```lua
DebugMenu:AddCycle(categoryId, cycleId, title, convar, values, callback, defaultValue)
```

**Parameters**

- **`categoryId`**  
  `string`  
  The id of the category to add this cycle to
- **`cycleId`**  
  `string`  
  The unique id for this new cycle
- **`title`**  
  `string`, `nil`  
  The text to display next to each value
- **`convar`** *(optional)*  
  `string`  
  The console variable tied to this cycle
- **`values`**  
  `{text:string,value:any}[]`, `string[]`  
  List of text/value pairs for this cycle, or a list of values
- **`callback`** *(optional)*  
  `function`  
  Function callback
- **`defaultValue`** *(optional)*  
  `any`, `function`  
  Value for this cycle to start with

### ShowDialog

Shows a dialog box with the specified text and a "CLOSE" button.

```lua
DebugMenu:ShowDialog(text)
```

**Parameters**

- **`text`**  
  `string`  
  The text to display in the dialog

### SetItemText

Sets the text of an item.

Only works on the following types:

 - button

 - toggle

 - slider

```lua
DebugMenu:SetItemText(categoryId, itemId, text)
```

**Parameters**

- **`categoryId`**  
  `string`  
  The ID of the category that contains the item
- **`itemId`**  
  `string`  
  The ID of the item to modify
- **`text`**  
  `string`  
  The new text

### SetCategoryIndex

Sets the index of a category in the debug menu.
Categories are ordered by their index, starting from 1.

This is an advanced function and should be used with caution.

```lua
DebugMenu:SetCategoryIndex(categoryId, index)
```

**Parameters**

- **`categoryId`**  
  `string`  
  Id of the category to change
- **`index`**  
  `number`  
  New index for the category

### SetSize

Sets the size of the debug menu panel if it's open.

This does not change any convars and is not persisted.

```lua
DebugMenu:SetSize(width, height)
```

**Parameters**

- **`width`** *(optional)*  
  `number`  
  Width in "panel units"
- **`height`** *(optional)*  
  `number`  
  Height in "panel units"

### SendCategoryToPanel

Sends a category and all its elements to the panel.

This should only be used if modifying the menu in a non-standard way.

```lua
DebugMenu:SendCategoryToPanel(category)
```

**Parameters**

- **`category`**  
  `DebugMenuCategory`  
  The category to send

### SendCategoriesToPanel

Forces the debug menu panel to add all categories and items.

This should only be used if modifying the menu in a non-standard way.

```lua
DebugMenu:SendCategoriesToPanel()
```

### ClearMenu

Clears all categories and items from the debug menu panel.

```lua
DebugMenu:ClearMenu()
```

### Refresh

Forces the debug menu panel to refresh by removing and re-adding all categories and items.

```lua
DebugMenu:Refresh()
```

### SetItemVisibilityCondition

Sets the visibility condition for an item.

If the condition is not met when the menu opens, the item will not appear in the menu.

```lua
DebugMenu:SetItemVisibilityCondition(categoryId, itemId, condition)
```

**Parameters**

- **`categoryId`**  
  `string`  
  The category ID
- **`itemId`**  
  `string`  
  The item ID
- **`condition`**  
  `string`, `function`  
  Convar name, function, or `nil` to remove the condition

### GetLinkedConvars

Gets a list of all convars linked to debug menu items.

```lua
DebugMenu:GetLinkedConvars()
```

**Returns**
- **`DebugMenuDumpedCategory[]`**
A list of all convars

### StartListeningForMenuActivation

Starts listening for the debug menu activation button.

```lua
DebugMenu:StartListeningForMenuActivation()
```

### StopListeningForMenuActivation

```lua
DebugMenu:StopListeningForMenuActivation()
```

## Types

### DebugMenuCategory

A category of items in the debug menu.

| Field | Type | Description |
| ---- | ---- | ----------- |
| id | `string` | The unique ID for this category |
| name | `string` | The display name for this category |
| items | `DebugMenuItem[]` | The items in this category |

### DebugMenuItem

An item in the debug menu.

| Field | Type | Description |
| ---- | ---- | ----------- |
| categoryId | `string` | The ID of the category this item is in |
| id | `string` | The unique ID for this item |
| text | `string` | The text to display for this item (if applicable) |
| callback | `function` | The function to call when this item is clicked |
| type | `"button"|"toggle"|"separator"|"slider"|"cycle"` | Type of menu element this item is. |
| default | `any|function` | The default value sent to the menu. If this is a function the return value will be used |
| min | `number` | Minimum value of this slider |
| max | `number` | Maxmimum value of this slider |
| isPercentage | `boolean` | If true, this slider displays its value as a percentage of min/max |
| convar | `string` | The console variable associated with this element |
| values | `{text:string,value:any}[]` | Text/value pairs for this cycler |
| truncate | `number` | The number of decimal places to truncate the slider value to (-1 for no truncating) |
| increment | `number` | The increment value to snap the slider value to (0 for no snapping) |
| condition? | `string|function` | The condition that must be met for this item to be visible |
