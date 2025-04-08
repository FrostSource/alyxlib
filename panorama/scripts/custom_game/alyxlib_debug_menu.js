"use strict";

///TODO: Add pop up for warnings and errors

if(false)p=require("./panoramadoc");

function FireOutput(outputName, ...args) {
    if (args === undefined) args = [];
    const formattedArgs = args.map(arg =>
        typeof arg === "string" ? `'${arg}'` : String(arg)
    );
    const callString = `${outputName}(${formattedArgs.join(",")})`;
    $.DispatchEvent("ClientUI_FireOutputStr", 0, callString);

    $.Msg(callString);
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

function TurnButtonIntoDebugMenuButton(button)
{
    if (button == null) return;

    button.SetPanelEvent("onmouseover", () => currentlyActiveButton = button);
    button.SetPanelEvent("onmouseout", () => {
        if (currentlyActiveButton == button) currentlyActiveButton = null;
    });
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
    if (callback !== null && callback !== undefined)
        button.SetPanelEvent("onactivate", callback);

    TurnButtonIntoDebugMenuButton(button);

    return button;
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
        // this.button = $.CreatePanel("Button", $("#CategoryBar"), `${this.id}_button`);
        // this.button.AddClass("CategoryButton");
        // this.button.SetPanelEvent("onactivate", () => SetCategoryVisible(this.id));
        this.button = CreateDebugMenuButton($("#CategoryBar"), () => SetCategoryVisible(this.id), "CategoryButton", `${this.id}_button`);
        let label = $.CreatePanel("Label", this.button, `${this.id}_label`);
        label.text = this.name;
    }

    // AddToPanel(panel)
    // {
    //     if (this.panel == null)
    //     {
    //         this.panel = $.CreatePanel("Panel", panel, this.id);
    //         this.panel.AddClass("submenu");
    //         this.panel.AddClass("scroll");
    //         this.content = $.CreatePanel("Panel", this.panel, `${this.id}_content`);
    //         this.content.AddClass("content");
    //     }
    //     else
    //         this.panel.SetParent(panel);

    //     this.root = panel;
    // }

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

    /**
     * Adds a button to this category.
     * @param {string} id Unique identifier for the button.
     * @param {string} text Text to display on the button.
     * @param {function} callback Function to call when the button is pressed.
     * @example
     * let button = myCategory.AddButton("my_button", "My Button", () => {
     *     $.Msg("Button pressed!");
     * });
     */
    // _AddButtonInternal(id, text, callback)
    // {
    //     if (this.content == null)
    //     {
    //         // Display warning
    //         $.Msg(`You must call AddToPanel() before adding buttons to a category!`);
    //         return;
    //     }
    //     //

    //     // let button = $.CreatePanel("Button", this.content, `${id}_button`);
    //     // button.AddClass("ButtonTest");
    //     // if (callback != null)
    //     //     button.SetPanelEvent("onactivate", callback);
    //     let button = CreateDebugMenuButton(this.content, callback, "ButtonTest", `${this.id}_${id}`);

    //     let buttonLabel = $.CreatePanel("Label", button, `${id}_label`);
    //     buttonLabel.AddClass("button_label");
    //     buttonLabel.text = text;
        
    //     let buttonBullet = $.CreatePanel("Image", button, `${id}_bullet`);
    //     buttonBullet.AddClass("button_bullet");
    //     buttonBullet.SetImage("s2r://panorama/images/game_menu_ui/btn_bullet_child_page_png.vtex")

    // }

    SetItemText(id, text)
    {
        // let option = this.content.FindChildTraverse(`${this.id}_${id}`);
        // if (option === null)
        // {
        //     // Display warning
        //     $.Msg(`Option ${id} does not exist! Did you call AddToPanel()?`);
        //     return;
        // }

        // option

        // Find item with id in this.options
        let combinedId = `${this.id}_${id}`;
        let item = this.items.find(o => o.id === combinedId);
        if (item === undefined)
        {
            this.items.forEach((o) => $.Msg(o.id));
            // Display warning
            $.Msg(`Item ${id} does not exist!`);
            return;
        }

        // text-transform: uppercase; doesn't affect js set text?
        text = text.toLocaleUpperCase();

        item.SetText(text);
    }

    AddButton(id, text)
    {
        // this._AddButtonInternal(id, text, () => {
        //     // $.DispatchEvent("ClientUI_FireOutputStr", 0, `_DebugMenuCallbackButton('${id}')`);
        //     FireOutput("_DebugMenuCallbackButton", id);
        // });

        let button = new SubMenuButton(`${this.id}_${id}`, text, () => {
            FireOutput("_DebugMenuCallbackButton", id);
        });
        button.AddToPanel(this.content);
        this.items.push(button);
    }

    // _AddToggleInternal(id, text, callback, startsOn)
    // {
    //     let toggle = new SubMenuToggle(id, text, callback, startsOn);
    //     toggle.AddToPanel(this.content);
    // }

    AddToggle(id, text, startsOn)
    {
        // this._AddToggleInternal(id, text, startsOn, (on) => {
        //     // $.DispatchEvent("ClientUI_FireOutputStr", 0, `_DebugMenuCallbackToggle('${this.id}',${on})`);
        //     FireOutput("_DebugMenuCallbackToggle", id, on);
        // });

        let toggle = new SubMenuToggle(`${this.id}_${id}`, text, startsOn, (on) => {
            FireOutput("_DebugMenuCallbackToggle", id, on);
        });
        toggle.AddToPanel(this.content);
        this.items.push(toggle);
    }

    AddSeparator()
    {
        let rowDivider = $.CreatePanel("Panel", this.content, undefined);
        rowDivider.AddClass("row_divider");

        let rowDividerLabel = $.CreatePanel("Panel", rowDivider, undefined);
        rowDividerLabel.AddClass("button_label");

        let rowDividerLine = $.CreatePanel("Panel", rowDividerLabel, undefined);
        rowDividerLine.AddClass("row_divider_line");

        let rowDividerBullet = $.CreatePanel("Panel", rowDivider, undefined);
        rowDividerBullet.AddClass("button_bullet");
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
            // this.panel = $.CreatePanel("Button", panel, `${this.id}_button`);
            // this.panel.AddClass("ButtonTest");
            // if (this.callback != null)
            //     this.panel.SetPanelEvent("onactivate", () => this.Toggle());
                // this.panel.SetPanelEvent("onactivate", this.callback);

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
 * Virtually clicks the currently active button.
 */
function ClickHoveredButton()
{
    if (currentlyActiveButton !== null)
    {
        $.DispatchEvent("Activated", currentlyActiveButton, "mouse");
    }
}

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
            $.Msg("ID: " + buttonId + ", Text: " + buttonText);
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

        case "addseparator": {
            let category = GetCategory(args[0]);
            if (category === null)
            {
                $.Msg(`Category ${args[0]} does not exist!`);
                break;
            }

            category.AddSeparator();
            break;
        }

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
    }
}

(function()
{
    // Modify preset layout buttons to work with controller trigger
    TurnButtonIntoDebugMenuButton($("#CloseMenuButton"));
    TurnButtonIntoDebugMenuButton($("#CycleCategoryLeftButton"));
    TurnButtonIntoDebugMenuButton($("#CycleCategoryRightButton"));
})();