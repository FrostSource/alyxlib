/// <reference path="panoramadoc.js" />
"use strict";

///TODO: Add pop up for warnings and errors

let panelReady = false;

/**
 * Fires a Panorama output with the given name and arguments.
 * The output is routed to the panel's input 'RunScriptCode'.
 * 
 * @param {string} outputName - The name of the output to fire.
 * @param {...*} args - The arguments to pass to the output.
 */
function FireOutput(outputName, ...args) {
    if (args === undefined) args = [];
    const formattedArgs = args.map(arg =>
        typeof arg === "string" ? `'${arg}'` : String(arg)
    );
    const callString = `${outputName}(${formattedArgs.join(",")})`;
    $.DispatchEvent("ClientUI_FireOutputStr", 0, callString);

    // $.Msg(callString);
}

/**
 * Maps category id to category object.
 * @type {Category[]}
 */
let categories = [];

const numberOfVisibleCategories = 5;

let categoryBarCycleIndex = 0;

/**
 * @type {Category}
 */
let currentlySelectedCategory = null;

/**
 * @type {Panel}
 */
let currentlyActiveButton = null;

function TurnButtonIntoDebugMenuButton(button, callback)
{
    if (button == null) return;

    button.SetPanelEvent("onmouseover", () => currentlyActiveButton = button);
    button.SetPanelEvent("onmouseout", () => {
        if (currentlyActiveButton == button) currentlyActiveButton = null;
    });

    if (callback !== null && callback !== undefined)
        if (button.paneltype == "HLVR_SettingsSlider")
            button.SetPanelEvent("onvaluechanged", callback);
        else
            button.SetPanelEvent("onactivate", callback);
}

/**
 * Creates a new debug menu button.
 * @param {Panel} parent Panel that the button will be added to.
 * @param {function} callback Function to call when the button is pressed.
 * @param {string} _class Class to apply to the button.
 * @param {string} [id] Unique ID for the button.
 * @returns {Panel} The newly created button.
 */
function CreateDebugMenuButton(parent, callback, _class, id)
{
    let button = $.CreatePanel("Button", parent, id);
    button.AddClass(_class);

    TurnButtonIntoDebugMenuButton(button, callback);

    return button;
}

/**
 * Create a panel, optionally with a set of classes.
 * @param {string} type Type of panel (e.g. Panel, Button).
 * @param {Panel} parent Parent of this new panel.
 * @param {string?} id Id of this new panel.
 * @param {string?} classes Classes for this panel.
 * @returns {Panel}
 */
function CreatePanel(type, parent, id, classes)
{
    id = id || '';
    const panel = $.CreatePanel(type, parent, id);
    if (classes !== undefined) {
        for (let _class of classes.split(' ')) {
            panel.AddClass(_class);
        }
    }
    return panel;
}

/**
 * @interface
 * @typedef {Object} SubMenuItem
 * @property {(text: string) => void} SetText
 * @property {(panel: Panel) => void} AddToPanel
 */

class Category
{
    constructor(id, name)
    {
        this.id = id;
        /**
         * @type {string}
         */
        this.name = name;

        /**
         * @type {SubMenuItem[]}
         */
        this.items = [];

        // Main submenu panel
        this.panel = null;
        // Content panel where items are added
        this.content = null;
        // Root panel that this category is attached to
        this.root = null;

        // Create content panels
        this.panel = $.CreatePanel("Panel", $("#CategoriesContainer"), this.id);
        this.panel.AddClass("submenu");
        this.panel.AddClass("scroll");
        this.content = $.CreatePanel("Panel", this.panel, `${this.id}_content`);
        this.content.AddClass("content");

        // Create category button
        this.button = CreateDebugMenuButton($("#CategoryBar"), () => SetCategoryVisible(this.id), "CategoryButton", `${this.id}_button`);
        
        // Animate this new tab if being added after the menu is open
        if (panelReady)
            this.button.AddClass("flash");
        
        let label = $.CreatePanel("Label", this.button, `${this.id}_label`);
        label.text = this.name;

        // Scale text size to fit button

        // Width of CategoryButton
        let containerWidth = 150;
        // Good factor for AlyxLib text
        let baseFactor = 5;
        // Calculate a scaled factor that grows slowly
        let factor = baseFactor * Math.max(label.text.length / 17, 1); // never less than 1, so no shrinking below base
        // Clamp to avoid too small or too big
        factor = Math.min(Math.max(factor, baseFactor), 10);
        label.style.fontSize = `${containerWidth / factor}px`;
    }

    /**
     * Deletes this category and all of its items.
     */
    Delete()
    {
        this.panel.DeleteAsync(0);
        this.button.DeleteAsync(0);
    }

    SetVisible(visible)
    {
        if (visible)
        {
            this.panel.AddClass("Visible");
            this.button.AddClass("Selected");
        }
        else
        {
            this.panel.RemoveClass("Visible");
            this.button.RemoveClass("Selected");
        }
    }

    SetBarButtonVisible(visible)
    {
        if (visible)
            this.button.visible = true;
        else
            this.button.visible = false;
    }

    SetItemText(id, text)
    {
        // Find item with id in this.options
        let combinedId = `${this.id}_${id}`;
        let item = this.items.find(o => o.id === combinedId);
        if (item === undefined)
        {
            $.Msg(`Item ${id} does not exist!`);
            return;
        }

        if (!item.SetText) {
            $.Msg(`Item ${id} does not support SetItemText!`);
            return;
        }

        // text-transform: uppercase; doesn't affect js set text?
        text = text.toLocaleUpperCase();

        item.SetText(text);
    }

    AddButton(id, text)
    {
        let button = new SubMenuButton(`${this.id}_${id}`, text, () => {
            FireOutput("_DebugMenuCallbackButton", id);
        });
        button.AddToPanel(this.content);
        this.items.push(button);
    }

    AddToggle(id, text, startsOn)
    {
        let toggle = new SubMenuToggle(`${this.id}_${id}`, text, startsOn, (on) => {
            FireOutput("_DebugMenuCallbackToggle", id, on);
        });
        toggle.AddToPanel(this.content);
        this.items.push(toggle);
    }

    AddLabel(id, text)
    {
        const label = new SubMenuLabel(`${this.id}_${id}`, text);
        label.AddToPanel(this.content);

        this.items.push(label);
    }

    /**
     * Adds a new separator to the menu with optional text.
     * @param {string} id Id for this separator.
     * @param {string?} text Text displayed on the separator.
     */
    AddSeparator(id, text = "")
    {
        const separator = new SubMenuSeparator(`${this.id}_${id}`, text);
        separator.AddToPanel(this.content);
        this.items.push(separator);
    }

    /**
     * **CURRENTLY NOT SUPPORTED IN DEBUG_MENU.LUA**
     * Adds a solid header to the category.
     * @param {string} title Text displayed in the header.
     */
    AddHeader(title)
    {
        const header = CreatePanel("Panel", this.content, null, "header");
        const label = CreatePanel("Label", header, null);
        label.text = "This be header";
    }

    /**
     * Adds a new slider to this category.
     * @param {string} id The id for this slider.
     * @param {string} text Text to display in the slider.
     * @param {string} convar The convar to tie this slider to.
     * @param {number} min Minimum value this slider can have.
     * @param {number} max Maximum value this slider can have.
     * @param {number} value Starting value for this slider.
     * @param {boolean} isPercentage Value is displayed as a percentage instead of raw value.
     * @param {number} truncate Number of decimal places the value can be set to (-1 for no truncating).
     * @param {number} increment Increment value to snap to.
     */
    AddSlider(id, text, convar, min, max, value, isPercentage = true, truncate = -1, increment = 0)
    {
        
        let slider = new SubMenuSlider(`${this.id}_${id}`, convar, text, min, max, isPercentage, (value) => {
            FireOutput("_DebugMenuCallbackSlider", id, value);
        }, value, truncate, increment);
        slider.AddToPanel(this.content);
        this.items.push(slider);
    }

    /**
     * Adds a new value cycler to this category.
     * @param {string} id String id for this cycle.
     * @param {string} convar Convar to tie this cycle to (currently unsued in JS).
     * @param {SubMenuCycleItem[]} values Text/value pairs for this cycle.
     * @param {string?} selectedValue Starting selected value.
     */
    AddCycle(id, convar, values, selectedValue)
    {
        let cycle = new SubMenuCycle(`${this.id}_${id}`, convar, values, (index) => {
            FireOutput("_DebugMenuCallbackCycle", id, index + 1);
        });
        cycle.AddToPanel(this.content);
        cycle.SetSelectedValueNoFire(selectedValue);
        this.items.push(cycle);
    }
}

class SubMenuButton
{
    constructor(id, text, callback)
    {
        this.id = id;
        this.text = text;
        this.callback = callback;
    }

    AddToPanel(panel)
    {
        this.panel = CreateDebugMenuButton(panel, this.callback, "ButtonTest", this.id);

        let buttonLabel = $.CreatePanel("Label", this.panel, `${this.id}_label`);
        buttonLabel.AddClass("button_label");
        buttonLabel.text = this.text;
        
        let buttonBullet = $.CreatePanel("Image", this.panel, `${this.id}_bullet`);
        buttonBullet.AddClass("button_bullet");
        buttonBullet.SetImage("s2r://panorama/images/game_menu_ui/btn_bullet_child_page_png.vtex")
    }

    SetText(text)
    {
        if (this.panel === undefined) return;

        this.text = text;
        let label = this.panel.FindChildTraverse(`${this.id}_label`);
        label.text = text;
    }
}

class SubMenuToggle
{
    
    constructor(id, text, startsOn, callback)
    {
        this.id = id;
        this.text = text;
        this.callback = callback;

        this.isOn = startsOn;
    }

    /**
     * Adds this toggle button to a panel.
     * @param {Panel} panel The panel to add this button to.
     */
    AddToPanel(panel)
    {
        if (this.panel == null)
        {
            this.panel = CreateDebugMenuButton(panel, () => this.Toggle(), "ButtonTest", this.id);

            this.panel.AddClass("custom_switch");
            if (!this.isOn)
                this.panel.AddClass("switch_off");

            let row = $.CreatePanel("Panel", this.panel, undefined);
            row.AddClass("row");

            let switchButton = $.CreatePanel("Panel", row, undefined);
            switchButton.AddClass("switch_button");
            
            // Seems too much of a hassle to change Valve's styles so keeping two different labels
            let labelOn = $.CreatePanel("Label", switchButton, `${this.id}_label_on`);
            labelOn.AddClass("switch_label");
            labelOn.AddClass("switch_label_on")
            labelOn.text = `${this.text}`;
            let labelOff = $.CreatePanel("Label", switchButton, `${this.id}_label_off`);
            labelOff.AddClass("switch_label");
            labelOff.AddClass("switch_label_off")
            labelOff.text = `${this.text}`;

            let switchButtonImage = $.CreatePanel("Panel", row, undefined);
            switchButtonImage.AddClass("switch_button_image");
            let switchImage = $.CreatePanel("Panel", switchButtonImage, undefined);
            switchImage.AddClass("switch_image");
        }
        else
        {
            this.panel.SetParent(panel);
        }

        this.root = panel;
    }

    /**
     * Sets the text of the toggle button on/off labels.
     * @param {string} text The new text.
     */
    SetText(text)
    {
        if (this.panel === null) return;

        this.text = text;
        let labels = this.panel.FindChildrenWithClassTraverse("switch_label");
        for (const label of labels)
        {
            label.text = text;
        }
    }

    /**
     * Sets the state of this toggle button.
     * If the toggle button has a callback, it is called with the new state.
     * @param {boolean} on If the toggle button should be on or off.
     */
    SetState(on)
    {
        this.isOn = on;
        if (this.isOn)
        {
            this.panel.AddClass("switch_on")
            this.panel.RemoveClass("switch_off")
        }
        else
        {
            this.panel.RemoveClass("switch_on")
            this.panel.AddClass("switch_off")
        }

        if (this.callback != null)
        {
            this.callback(this.isOn);
        }
    }

    /**
     * Toggles the state of this toggle button.
     * If the toggle button has a callback, it is called with the new state.
     */
    Toggle()
    {
        this.SetState(!this.isOn);
    }
}

class SubMenuSlider
{
    constructor(id, convar, text, min, max, isPercentage, callback, currentValue = 0, truncate = -1, increment = 0) {
        this.id = id;
        this.convar = convar;
        this.text = text;
        this.min = min;
        this.max = max;
        this.isPercentage = false;
        this.callback = callback;

        this.truncate = truncate;
        this.increment = increment;

        this.value = currentValue;//Clamp(currentValue  || 0, this.min, this.max);
        /**@type {Panel} */
        this.panel = null;
        /**@type {Slider} */
        this.slider = null;
    }

    AddToPanel(panel) {
        this.panel = CreatePanel("Panel", panel, this.id, "SubMenuSlider");
        this.slider = $.CreatePanelWithProperties("Slider", this.panel, "Slider", { class:"OptionsSlider", direction:"horizontal", });
        this.slider.min = this.min;
        this.slider.max = this.max;
        const container = CreatePanel("Panel", this.slider, null, "SliderContainer");
        const row = CreatePanel("Panel", container, "SliderRow", "SliderRow");
        const textLabel = CreatePanel("Label", row, "Title", "slider_label");
        textLabel.text = this.text;
        CreatePanel("Panel", row, null, "slider_divider");
        const valueLabel = CreatePanel("Label", row, "Value", "slider_value");

        this.SetValue(this.value);

        // This only works in VR
        TurnButtonIntoDebugMenuButton(this.panel, () => {
            const pos = GetAffordancePosition();
            if (pos !== null) {
                // Slider does not have actualxoffset or actuallayoutwidth THANKS AGAIN VALVE
                // These magic numbers are estimates of where the slider is in relation to the parent panel
                const xoffset = this.panel.actualxoffset + 25;
                const width = this.panel.actuallayoutwidth - 25;
                const val = RemapValueClamped(pos.x,
                    xoffset,
                    width,
                    this.slider.min,
                    this.slider.max
                );
                // Changing value automatically fires "onvaluechanged"
                this.slider.value = val;
            }
        });

        this.slider.SetPanelEvent("onvaluechanged", () => {
            let prevValue = this.value;
            this._SetValueInternal(this.slider.value);
            if (this.value !== prevValue)
                this.callback(this.value);
        });
    }

    /**
     * Sets the slider to a given value.
     * @param {number} value 
     */
    SetValue(value) {
        this._SetValueInternal(value);
        this.slider.SetValueNoEvents(this.value);
        // this.slider.value = this.value;
    }

    /**
     * Sets the internal value of the slider and updates labels.
     * The visible slider is not updated.
     * @param {number} value 
     */
    _SetValueInternal(value) {
        const valueLabel = this.panel.FindChildTraverse("Value");
        if (this.increment > 0) value = Math.round(value / this.increment) * this.increment;
        if (this.truncate > -1) value = parseFloat(value.toFixed(this.truncate));
        value = Clamp(value, this.min, this.max);
        this.value = value;
        
        if (this.isPercentage)
            valueLabel.text = this.GetValueAsPercentage().toFixed(0);
        else
            valueLabel.text = this.value.toFixed(this.truncate);
    }

    /**
     * 
     * @returns {number}
     */
    GetValueAsPercentage() {
        return RemapValueClamped(this.value, this.min, this.max, 0, 100);
    }

    SetText(text) {
        const /**@type {Label} */ title = this.panel.FindChildTraverse("Title");
        if (title)
            title.text = text;
    }
}

/**
 * @typedef {Object} SubMenuCycleItem
 * @property {string} text
 * @property {string?} value
 */

class SubMenuCycle
{
    /**
     * 
     * @param {string} id 
     * @param {string} convar 
     * @param {SubMenuCycleItem[]} values Maximum of 6 items
     * @param {function} callback 
     * @param {number} selectedIndex
     */
    constructor(id, convar, values, callback, selectedIndex) {
        this.id = id;
        this.convar = convar;
        this.values = values;//values.slice(0, 6);
        this.callback = callback;

        /** @type {Panel} */
        this.panel = null;

        this.selectedIndex = selectedIndex || 0;
    }

    AddToPanel(panel) {
        /// Recreate GameMenuOptionCyclePanel hierarchy to preserve styles, with dynamically added items

        this.panel = CreatePanel("Panel", panel, this.id, "cycler");
        const row = CreatePanel("Panel", this.panel, null, "row");
        const btnLeft = CreateDebugMenuButton(row, () => this.CycleLeft(), "cycle_button_left", "button_left");
        CreatePanel("Panel", btnLeft, null, "cycle_image cycle_image_left");
        const btnRight = CreateDebugMenuButton(row, () => this.CycleRight(), "cycle_button_right", "button_right");
        const col = CreatePanel("Panel", btnRight, null, "cycle_button_right_col");
        for (let [index,item] of this.values.entries()) {
            /**@type {Label} */
            const text = CreatePanel("Label", col, "item"+index, "cycle_label");
            text.text = item.text;
        }
        CreatePanel("Label", col, "custom", "cycle_label").text = "Custom";
        const dotRow = CreatePanel("Panel", col, null, "dot_row");
        for (let [index,item] of this.values.entries()) {
            /**@type {Label} */
            const dot = CreatePanel("Label", dotRow, "dot"+index, "cycle_dots");
            dot.text = " ■ ";
        }
        CreatePanel("Panel", dotRow);
        const imgCont = CreatePanel("Panel", btnRight, null, "cycle_button_right_image");
        CreatePanel("Panel", imgCont, null, "cycle_image cycle_image_right");
        CreatePanel("Panel", this.panel);

        this.SetSelectedIndexNoFire(this.selectedIndex);
    }

    /**
     * Cycles to the left, wrapping around to the right if below `0`.
     */
    CycleLeft() {
        if (this.selectedIndex == -1) this.selectedIndex = 0;
        this.SetSelectedIndex(this.selectedIndex - 1);
    }

    /**
     * Cycles to the right, wrapping around to the left if above `this.values.length`.
     */
    CycleRight() {
        this.SetSelectedIndex(this.selectedIndex + 1);
    }

    /**
     * Sets the selected option without firing the callback.
     * @param {number} index The index of the option to select, starting from 0.
     */
    SetSelectedIndexNoFire(index) {
        index = (index + this.values.length) % this.values.length;

        for (let i = 0; i < this.values.length; i++) {
            if (i == index) {
                this.SetSelectedValueNoFire(this.values[i].value);
                return;
            }
        }
    }

    /**
     * Sets the selected option.
     * @param {number} index The index of the option to select, starting from 0.
     */
    SetSelectedIndex(index) {
        this.SetSelectedIndexNoFire(index);
        this.callback(this.selectedIndex);
    }

    SetSelectedValueNoFire(value) {
        let foundValue = false;
        
        // Find the matching value index
        for (let i = 0; i < this.values.length; i++) {
            const _value = this.values[i].value;
            const item = this.panel.FindChildTraverse("item" + i);
            const dot = this.panel.FindChildTraverse("dot" + ((this.values.length-1) - i));
            if (_value === value) {
                item.visible = true;
                dot.SetHasClass("cycle_dots_selected", true);
                foundValue = true;
                this.selectedIndex = i;
            } else {
                item.visible = false;
                dot.SetHasClass("cycle_dots_selected", false);
            }
        }

        // Reveal custom value if needed
        const custom = this.panel.FindChildTraverse("custom");
        if (foundValue) {
            custom.visible = false;
        } else {
            this.selectedIndex = -1;
            custom.text = `Custom (${value})`;
            custom.visible = true;
        }
    }

    SetSelectedValue(value) {
        this.SetSelectedValueNoFire(value);
        this.callback(this.selectedIndex);
    }

    /**
     * Gets the left cycle button.
     * @returns {Button}
     */
    GetLeftButton() {
        return this.panel.FindChildTraverse("button_left");
    }
    
    /**
     * Gets the right cycle button.
     * @returns {Button}
     */
    GetRightButton() {
        return this.panel.FindChildTraverse("button_right");
    }

    /**
     * Gets the currently selected item.
     * @returns {Panel}
     */
    GetSelectedItem() {
        for (let i = 0; i < this.values.length; i++) {
            const item = this.panel.FindChildTraverse("item" + i);
            if (item.visible) return item;
        }
    }

    /**
     * Gets the currently selected index.
     * @returns {number}
     */
    GetSelectedIndex() {
        return this.selectedIndex;
    }
}

class SubMenuSeparator
{
    /**
     * Creates a new sub menu separator instance.
     * @param {string} id Id for this separator.
     * @param {string?} text Text to display with this separator.
     */
    constructor(id, text = "")
    {
        this.id = id;
        this.text = text;

        /**@type {Panel} */
        this.panel = null;
    }

    /**
     * Creates all required elements as children of `panel`.
     * @param {Panel} panel Panel to add this separator to.
     */
    AddToPanel(panel)
    {
        this.panel = CreatePanel("Panel", panel, this.id, "options_divider");
        const label = CreatePanel("Label", this.panel, null);
        label.text = this.text;
        CreatePanel("Panel", this.panel, null, "horizontal_line");
    }

    /**
     * Sets or removes the text displayed with this separator.
     * @param {string?} text The text to display with this separator.
     */
    SetText(text = "")
    {
        this.text = text;
        const label = this.panel.GetChild(0);
        if (label) {
            label.text = text;
        }
    }

    /**
     * Gets the text displayed with this separator.
     * @returns {string}
     */
    GetText()
    {
        return this.text;
    }
}

class SubMenuLabel
{
    /**
     * Creates a new sub menu label instance.
     * @param {string} id Id for this label.
     * @param {string} text Text to display with this label.
     */
    constructor(id, text)
    {
        this.id = id;
        this.text = text;

        /**@type {Panel} */
        this.panel = null;
    }

    /**
     * Creates all required elements as children of `panel`.
     * @param {Panel} panel Panel to add this label to.
     */
    AddToPanel(panel)
    {
        this.panel = CreatePanel("Label", this.content, this.id, "custom_label");
        this.panel.text = this.text;
    }

    /**
     * Sets or removes the text displayed with this label.
     * @param {string?} text The text to display with this label.
     */
    SetText(text = "")
    {
        this.text = text;
        this.panel.text = text;
    }
}

/**
 * Shows a specific category and hides all others.
 * @param {string} id ID of the category to show.
 */
function SetCategoryVisible(id)
{
    for (const category of categories)
    {
        if (category.id == id)
        {
            // category.AddClass("Visible");
            category.SetVisible(true);
            currentlySelectedCategory = category;
        }
        else
        {
            // category.RemoveClass("Visible");
            category.SetVisible(false);
        }
    }
}


/**
 * Cycles the visible category in the direction given.
 * @param {number} direction -1 to cycle left, 1 to cycle right.
 * @see alyxlib_debug_menu.xml CategoryCycler for its usage.
 */
function CycleCategories(direction)
{
    direction = Math.sign(direction);
    if (direction === 0) return;

    const currentIndex = categories.indexOf(currentlySelectedCategory);
    const previousCategory = categories[(currentIndex + direction + categories.length) % categories.length];
    SetCategoryVisible(previousCategory.id);

    UpdateCategoryBarVisibility();
}

/**
 * Updates the visibility of the category bar buttons so that the selected category is
 * within the visible range.
 */
function UpdateCategoryBarVisibility()
{
    const selectedIndex = categories.indexOf(currentlySelectedCategory);
    if (selectedIndex < categoryBarCycleIndex) {
        categoryBarCycleIndex = selectedIndex;
    } else if (selectedIndex >= categoryBarCycleIndex + numberOfVisibleCategories) {
        categoryBarCycleIndex = selectedIndex - numberOfVisibleCategories + 1;
    }

    categories.forEach((category, index) => {
        const isVisible = index >= categoryBarCycleIndex && index < categoryBarCycleIndex + numberOfVisibleCategories;
        category.SetBarButtonVisible(isVisible);
    })
}

/**
 * Creates a new category and sets it as the currently selected category if no category is currently selected.
 * 
 * @param {string} id - The unique identifier for the category.
 * @param {string} name - The display name for the category.
 * @returns {Category} The newly created category.
 */

function CreateCategory(id, name)
{
    let category = new Category(id, name);

    categories.push(category);

    if (currentlySelectedCategory == null)
        SetCategoryVisible(category.id);

    return category;
}

/**
 * Finds a category by its ID.
 * @param {string} id - The unique identifier for the category.
 * @returns {Category} The category with the given ID, or null if none is found.
 */
function GetCategory(id)
{
    for (const category of categories)
    {
        if (category.id == id) return category;
    }

    return null;
}

/**
 * Sends the _CloseMenu command to Lua.
 * @see alyxlib_debug_menu.xml CloseMenuButton for its usage.
 */
function CloseMenu()
{
    FireOutput("_CloseMenu");
}

/**
 * Gets the position of the left or right 'affordance' circle for the VR finger interacting with the menu.
 * @returns {{x:number,y:number}?}
 */
function GetAffordancePosition() {
    const left = $('#vr_affordance_left');
    if (left.visible)
        return { x: left.actualxoffset, y: left.actualyoffset };

    const right = $('#vr_affordance_left');
    if (right.visible)
        return { x: right.actualxoffset, y: right.actualyoffset };

    return null;
}

/**
 * Remaps a number from one range to another.
 * @param {number} value - The input value to remap.
 * @param {number} low1 - Lower bound of the input range.
 * @param {number} high1 - Upper bound of the input range.
 * @param {number} low2 - Lower bound of the output range.
 * @param {number} high2 - Upper bound of the output range.
 * @returns {number} The remapped value in the output range.
 */
function RemapValue(value, low1, high1, low2, high2) {
    return low2 + (high2 - low2) * (value - low1) / (high1 - low1);
}

/**
 * Remaps a number from one range to another while clamping within the range.
 * @param {number} value - The input value to remap.
 * @param {number} low1 - Lower bound of the input range.
 * @param {number} high1 - Upper bound of the input range.
 * @param {number} low2 - Lower bound of the output range.
 * @param {number} high2 - Upper bound of the output range.
 * @returns {number} The remapped value in the output range.
 */
function RemapValueClamped(value, low1, high1, low2, high2){
    return RemapValue(Clamp(value, low1, high1), low1, high1, low2, high2);
}

/**
 * Clamps a number between a minimum and maximum value.
 * @param {number} value - The value to clamp.
 * @param {number} min - The minimum allowable value.
 * @param {number} max - The maximum allowable value.
 * @returns {number} The clamped value.
 */
function Clamp(value, min, max) {
    return Math.min(Math.max(value, min), max);
}

/**
 * Virtually clicks the currently active button.
 */
function ClickHoveredButton()
{
    if (currentlyActiveButton !== null)
    {
        const button = currentlyActiveButton;
        // $.Msg(`Pressing ${button.id} : ${button.paneltype}`);
        $.DispatchEvent("Activated", button, "mouse");
    }
}

/**
 * Parses the incoming Lua command.
 * @param {string} command 
 * @param {string[]} args 
 */
function ParseCommand(command, args)
{
    command = command.toLowerCase();

    switch (command)
    {
        case "addcategory": {
            let id = args[0];
            let name = args[1];
            CreateCategory(id, name);
            break;
        }

        case "addbutton": {
            let category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }
            
            let buttonId = args[1];
            let buttonText = args[2];
            category.AddButton(buttonId, buttonText);
            break;
        }

        case "addtoggle": {
            let category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }
            
            let toggleId = args[1];
            let toggleText = args[2] || args[1];
            let toggleStartsOn = args[3] === "true";
            category.AddToggle(toggleId, toggleText, toggleStartsOn);
            break;
        }

        case "addlabel": {
            let category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }

            let labelId = args[1];
            let labelText = args[2] || args[1];
            category.AddLabel(labelId, labelText);
            break;
        }

        case "addseparator": {
            let category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }

            const id = args[1];
            const text = args[2];
            category.AddSeparator(id, text);
            break;
        }

        case "addslider": {
            const category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }
            
            const id = args[1];
            const text = args[2] || args[3];
            const convar = args[3];
            const min = parseFloat(args[4]);
            const max = parseFloat(args[5]);
            const value = parseFloat(args[6]);
            const isPercentage = args[7] == "true";
            const truncate = parseInt(args[8]);
            const increment = parseFloat(args[9]);
            category.AddSlider(id, text, convar, min, max, value, isPercentage, truncate, increment);
            break;
        }

        case "addcycle":
            const category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }

            const id = args[1];
            const convar = args[2];
            const currentValue = args[3];
            const rawValues = args.slice(4);
            /**@type {SubMenuCycleItem[]} */
            const values = [];
            for (let i = 0; i < rawValues.length; i+=2) {
                values.push({
                    text: rawValues[i],
                    value: rawValues[i+1]
                });
            }

            category.AddCycle(id, convar, values, currentValue);
            break;

        case "setitemtext": {
            let category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }

            let id = args[1];
            let text = args[2];
            category.SetItemText(id, text);
            break;
        }

        case "clickhoveredbutton": {
            ClickHoveredButton();
            break;
        }

        case "removeallcategories": {
            categories.forEach((category) => category.Delete());
            categories = [];
            break;
        }

        case "setcategoryindex": {
            let category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }

            const index = parseInt(args[1]);
            const categoryBar = $("#CategoryBar");
            const childToMove = category.button;
            if (index <= 0){
                // Move to front
                let firstChild = categoryBar.GetChild(0);
                categoryBar.MoveChildBefore(childToMove, firstChild);
            } else {
                // Move after the previous child
                let prevChild = categoryBar.GetChild(index - 1);
                categoryBar.MoveChildAfter(childToMove, prevChild)
            }

            const currentPos = categories.indexOf(category);
            if (currentPos !== -1 && index >= 0 && index < categories.length) {
                categories.splice(currentPos, 1);
                categories.splice(index, 0, category);
            }
        }
    }
}

let scrollHelperScheduleCancel = false;
let scrollHelperScheduleEvent = "";
let scrollHelperSpeed = 0.1;

/**
 * Scroll logic for the scroll helper schedule.
 */
function ScrollHelperSchedule() {
    if (scrollHelperScheduleCancel || scrollHelperScheduleEvent === "" || currentlySelectedCategory === null) {
        scrollHelperScheduleCancel = false;
        return;
    }

    $.DispatchEvent(scrollHelperScheduleEvent, currentlySelectedCategory.panel);
    $.Schedule(scrollHelperSpeed, ScrollHelperSchedule);
}

/**
 * Start scrolling the category page in a direction.
 * @param {"ScrollDown"|"ScrollUp"|string} eventName Name of the event to fire on the current category.
 */
function StartScrollHelper(eventName) {
    if (scrollHelperScheduleEvent !== eventName) {
        scrollHelperScheduleEvent = eventName;
        $.Schedule(scrollHelperSpeed, ScrollHelperSchedule);
    }
}

/**
 * Stop scroll the category page.
 */
function StopScrollHelper() {
    scrollHelperScheduleCancel = true;
    scrollHelperScheduleEvent = "";
}

function ScrollHelperClick() {
    if (currentlySelectedCategory === null) return;

    switch (scrollHelperScheduleEvent){
        case "ScrollDown":
            $.DispatchEvent("ScrollToBottom", currentlySelectedCategory.panel);
            break;

        case "ScrollUp":
            $.DispatchEvent("ScrollToTop", currentlySelectedCategory.panel);
            break;
    }
    
}

(function()
{
    // Modify preset layout buttons to work with controller trigger
    TurnButtonIntoDebugMenuButton($("#CloseMenuButton"));
    TurnButtonIntoDebugMenuButton($("#CycleCategoryLeftButton"));
    TurnButtonIntoDebugMenuButton($("#CycleCategoryRightButton"));
    TurnButtonIntoDebugMenuButton($("#ScrollHelperDown"));
    TurnButtonIntoDebugMenuButton($("#ScrollHelperUp"));

    // Tells Lua that the menu has been reloaded so it can repopulate the menu
    // This helps with hot reloading panel changes
    $.Schedule(0.1, () => FireOutput("_DebugMenuReloaded"));

    // Scroll helpers for sub-menus
    // Valve kindly didn't allow us to raytrace click panels like the main menu
    // so this is a work around for scrolling
    $('#ScrollHelperDown').SetPanelEvent("onmouseover", () => StartScrollHelper("ScrollDown"));
    $('#ScrollHelperDown').SetPanelEvent("onmouseout", () => StopScrollHelper());
    $('#ScrollHelperDown').SetPanelEvent("onactivate", ScrollHelperClick);
    $('#ScrollHelperUp').SetPanelEvent("onmouseover", () => StartScrollHelper("ScrollUp"));
    $('#ScrollHelperUp').SetPanelEvent("onmouseout", () => StopScrollHelper());
    $('#ScrollHelperUp').SetPanelEvent("onactivate", ScrollHelperClick);

    $.Schedule(1.0, () => panelReady = true);

})();