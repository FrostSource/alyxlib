
/**
 * EVENTS
 * 
 * When event requires panel, must be id name without #
 * 
 * Activated panel(string) unknown
 * ActivateMainWindow value_that_equals_true_or_false(true,false,1,0,"true","false","1","0")
 * 
 * AddStyle panel(string) class(string)
 * AddStyleAfterDelay panel(string) class(string) delay(number)
 * AddStyleToEachChild panel(string) class(string)
 * AddTimedStyle
 *      Adds a class to a panel for a duration of time and optionally with a delay.
 *      panel(string)
 *      class(string)
 *      duration(number)
 *      [delay](number)
 * 
 * ClientUI_CloseDialog
 *      Closes the panorama panel making it not visible but the entity still exists.
 * 
 * CopyStringToClipboard
 *      Copies a string to the user's clipboard.
 *      panel(string) Unknown why needed.
 *      text(string) Text to copy to clipboard.
 *      unknown(*) Unknown what this is for but text won't copy unless it's here.
 * 
 * DeletePanel
 *      Seems to cause hard crash from testing.
 *      panel(string)
 */

/**
 * @typedef {("onactivate" | "oncancel" | "onclick" | "oncontextmenu" | "ondblclick" | "ondeselect" |
* "ondragdrop" | "ondragenter" | "ondragleave" | "ondragover" | "ondragstart" | "ondrop" | "onfocus" |
* "oninput" | "onkeydown" | "onkeyup" | "onload" | "onmouseenter" | "onmouseleave" | "onmousedown" |
* "onmousemove" | "onmouseout" | "onmouseover" | "onmouseup" | "onmousewheel" | "onscroll" | "onselect" |
* "onsubmit" | "onunload" | "onvaluechanged" | "onfocuschanged" | "oncontextdatachanged" |
* "oncontextmenu_hide" | "oncontextmenu_show" | "oncontextmenu_query" | "oncontextmenu_refresh" |
* "ondatechanged" | "onmodalaccepted" | "onmodalcanceled" | "onmodalprompt" | "onmodalselect" |
* "onmodalsubmit" | "onselectionchange" | "onselectquery" | "onsliding" | "onsubmenuswitch" |
* "ontooltiphide" | "ontooltipshow")} Event
*/


/**
 * {Panel|Label}
 */

/**
 * PANORAMA MAIN CLASS
 */
// @ts-ignore
class $ {
    /**
     * Log a message.
     * @param {...*} message Value to be logged.
     */
    static Msg(message){arguments}

    /**
     * Trigger an assert
     * @param {...*} [unknown1] Unknown.
     */
    static AssertHelper(unknown1){arguments}

    /**
     * Log a warning message.
     * @param {...*} [message] Value to be logged.
     */
    static Warning(message){arguments}

    /**
     * Dispatch an event with given arguments. Some events require the first arg to be a panel ID.
     * The panel can either be a panel object or string ID.
     * See {@link https://github.com/chrjen/panorama-javascript} for a list of events.
     * @param {(string|'ClientUI_FireOutput')} event Name of the event.
     * @param {...*} args
     * @returns {boolean} If the event was successfully dispatched?
     */
    static DispatchEvent(event, args){arguments; return}

    /**
     * Dispatch an event asynchronously with given arguments. Some events require the first arg to be a panel ID.
     * See {@link https://github.com/chrjen/panorama-javascript} for a list of events.
     * **Could not get this to work!**
     * @param {(string|'ClientUI_FireOutput')} event Name of the event.
     * @param {...*} args
     */
    static DispatchEventAsync(callback, event, args){arguments; return}

    /**
     * Register a callback function with an event name to be called whenever the event is fired.
     * @param {string} event Name of the event to listen for.
     * @param {string|Panel} panel Context panel to listen on.
     * @param {function} callback Function to call when the event is heard.
     */
    static RegisterEventHandler(event, panel, callback){}

    /**
     * Register a callback function for an event that is not otherwise handled.
     * @param {string} event Name of the event to listen for.
     * @param {function} callback Function to call when the event is heard.
     * @returns {number} ID of callback handler.
     */
    static RegisterForUnhandledEvent(event, callback){return}

    /**
     * 
     * @param {string} event Name of the event to unregister.
     * @param {number} id ID of the registered handler that was returned by {@link RegisterForUnhandledEvent}
     */
    static UnregisterForUnhandledEvent(event, id){}

    /**
     * Appears to be equivalent to {@link $}
     * @param {string} searchString String used to find a panel.
     * @returns {Panel}
     * @example
     * let panel = $.FindChildInContext('#MyPanelID');
     */
    static FindChildInContext(searchString){return}

    /**
     * Supposedly sends a web request, unknown how to use.
     * @param {string} url URL to send the request.
     * @param {object} settings Unknown.
     */
    static AsyncWebRequest(url, settings){}

    /**
     * Create a new {@link Panel}.
     * @param {string} type Case sensitive panel type name.
     * @param {Panel} parent Panel parent that this new panel will be added to.
     * @param {string} id Unique ID for this new panel.
     * @returns {Panel} The newly created panel.
     * @example
     * let panel = $.CreatePanel("Button", $.GetContextPanel(), "newButton")
     */
    static CreatePanel(type, parent, id){return}

    /**
     * Create a new {@link Panel}.
     * @param {string} type Case sensitive panel type name.
     * @param {Panel} parent Panel parent that this new panel will be added to.
     * @param {string} id Unique ID for this new panel.
     * @param {object} properties Initial properties for the new panel.
     * @returns {Panel} The newly created panel.
     * @example
     * let panel = $.CreatePanel("Button", $.GetContextPanel(), "newButton", {
     *     class: "MyClass",
     *     text: "Button",
     *     onactivate: "$.Msg('Button Pressed')"
     * })
     */
    static CreatePanelWithProperties(type, parent, id, properties){return}

    /**
     * Supposedly localizes text. Unknown how this works.
     * @param {string} text Text to localize.
     * @param {Panel} [panel] Optional panel as context.
     * @returns {string} Localized text.
     */
    static Localize(text, panel){return}

    /**
     * Does not exist in {@link $}.
     * @param {string} text Text to localize.
     * @param {Panel} [panel] Optional panel as context.
     * @returns {string} Localized text.
     * @deprecated
     */
    static LocalizePlural(text, panel){return}

    /**
     * Get the current language for panorama.
     * @returns {string} The current language.
     */
    static Language (){return}

    /**
     * Schedule a function to be called after a number of seconds.
     * @param {number} delay Number of seconds before callback is called.
     * @param {function} callback The function to call after a delay.
     * @returns {number} ID for this schedule.
     */
    static Schedule(delay, callback){return}

    /**
     * Cancel a started schedule before it fires.
     * @param {number} id ID of the schedule returned by {@link Schedule}.
     */
    static CancelScheduled(id){}

    /**
     * Get the current panel context.
     * @returns {Panel}
     */
    static GetContextPanel(){return}

    /**
     * Supposedly binds a key but could not get this to work.
     * @param {Panel|string} context Context for the binding, use blank string for global binding.
     * @param {string} key Name of key to bind, may be comma delimited list.
     * @param {function|string} callback Event name or callback function.
     */
    static RegisterKeyBind(context, key, callback){}

    /**
     * Iterate over an array or object by passing each element to a function.
     * @param {array|object} object The array or object to iterate.
     * @param {function} callback Function to call on each element.
     * @returns {array|object} The initial object that was given.
     */
    static Each(object, callback){return}

    /**
     * Presumably returns if the script is being reloaded.
     * @returns {boolean}
     */
    static DbgIsReloadingScript(){return}

    /**
     * Does not exist in {@link $}.
     * @deprecated
     */
    static HTMLEscape(){}

    /**
     * Unknown.
     */
    static LogChannel(){}
}

/**
 * Global selector function used to find panels by id.
 * @param {string} searchString String used to find a panel.
 * @returns {Panel}
 * @example
 * let panel = $('#MyPanelID')
 */
// @ts-ignore
function $(searchString){return}

/**
 * Panel class.
 */
class Panel {

    /**
     * The visibility of this panel.
     * @type {boolean} True for visible, false for not visible.
     */
    visible;

    /**
     * If the panel is enabled.
     * When disabled the panel will no longer receive input but JavaScript will still run.
     * @type {boolean} True for enabled, false for disabled.
     */
    enabled;

    /**
     * The checked state of this checkbox panel.
     * @type {boolean} 
     */
    checked;

    /**
     * Unknown.
     * @type {string}
     */
    defaultfocus;

    /**
     * Unknown.
     * @type {string}
     */
    inputnamespace;

    /**
     * Unknown.
     * @type {boolean}
     */
    hittest;

    /**
     * Unknown.
     * @type {boolean}
     */
    hittestchildren;

    /**
     * Unknown.
     * @type {number}
     */
    tabindex;

    /**
     * Unknown.
     * @type {number}
     */
    selectionpos_x;

    /**
     * Unknown.
     * @type {number}
     */
    selectionpos_y;

    
    /**
     * ID name of the panel.
     * @type {string}
     */
    id;
    
    /**
     * The layout file path for this panel.
     * @type {string}
     */
    layoutfile;
    
    /**
     * Width of the panel in pixels, taking DPI into account.
     * @type {number}
     */
    contentwidth;
    
    /**
     * Height of the panel in pixels, taking DPI into account.
     * @type {number}
     */
    contentheight;
    
    /**
     * Width that the panel wants to be.
     * @type {number}
     */
    desiredlayoutwidth;
    
    /**
     * Width that the panel wants to be.
     * @type {number}
     */
    desiredlayoutheight;
    
    /**
     * Actual width of the panel after being positioned by other panels.
     * @type {number}
     */
    actuallayoutwidth;
    
    /**
     * Actual height of the panel after being positioned by other panels.
     * @type {number}
     */
    actuallayoutheight;
    
    /**
     * X offset from the parent.
     * @type {number}
     */
    actualxoffset;
    
    /**
     * Y offset from the parent.
     * @type {number}
     */
    actualyoffset;

    /**
     * Y offset during a scroll?
     * @type {number}
     */
    scrolloffset_x;

    /**
     * X offset during a scroll?
     * @type {number}
     */
    scrolloffset_y;
    
    /**
     * Scale of the panel?
     * @type {number}
     */
    actualuiscale_x;
    
    /**
     * Scale of the panel?
     * @type {number}
     */
    actualuiscale_y;
    
    /**
     * Set individual styles of the panel. Style names are the same as css but in camelCase format.
     * @type {object}
     * @example
     * panel.style.backgroundColor = "red";
     * panel.style.fontFamily = "Raju";
     */
    style;
    
    /**
     * Unknown.
     * @type {undefined}
     */
    isValid;

    /**
     * Adds a class to this panel.
     * @param {string} className Name of class to add.
     */
    AddClass(className){}

    /**
     * Removes a class from this panel.
     * @param {string} className Name of class to remove.
     */
    RemoveClass(className){}

    /**
     * Returns if this panel currently has a class name.
     * @param {string} className Name of class to check for.
     * @returns {boolean}
     */
    BHasClass(className){return}

    /**
     * Returns if the parent? of this panel currently has a class name.
     * @param {string} className Name of class to check for.
     * @returns {boolean}
     */
    BAscendantHasClass(className){return}

    /**
     * Sets if this panel has a given class or not.
     * @param {string} className Name of class.
     * @param {boolean} hasClass If the class should be on or off.
     */
    SetHasClass(className, hasClass){}

    /**
     * Toggles a class on/off for this panel.
     * @param {string} className Name of class to toggle.
     */
    ToggleClass(className){return}

    /**
     * Changes an existing class name on this panel to a new given name.
     * @param {string} currentClass Current class on this panel that should be changed.
     * @param {string} newClass Name of new class that the current class should be changed to.
     */
    SwitchClass(currentClass, newClass){}

    /**
     * Remove then immediately add back a CSS class from a panel. Useful to re-trigger events like animations or sound effects.
     * @param {string} className Class to trigger.
     */
    TriggerClass(className){}

    
    ClearPanelEvent(str){}
    SetDraggable(bool){}
    IsDraggable(){}
    IsSizeValid(){}
    GetChildCount(){}
    GetChild(int){}
    GetChildIndex(unknown){}
    Children(){}
    FindChildrenWithClassTraverse(className){}

    /**
     * Gets the parent panel.
     * @returns {Panel}
     */
    GetParent(){return}

    /**
     * Sets the parent panel.
     * @param {Panel} panel
     */
    SetParent(panel){}

    FindChild(str){}
    FindChildTraverse(str){}
    FindChildInLayoutFile(str){}
    FindPanelInLayoutFile(str){}
    FindAncestor(str){}
    RemoveAndDeleteChildren(){}
    MoveChildBefore(unknown1, unknown2){}
    MoveChildAfter(unknown1, unknown2){}
    GetPositionWithinWindow(){}
    GetPositionWithinAncestor(unknown){}
    ApplyStyles(bool){}
    ClearPropertyFromCode(unknown){}
    DeleteAsync(float){}
    BIsTransparent(){}
    BAcceptsInput(){}
    BAcceptsFocus(){}
    SetFocus(){}
    UpdateFocusInContext(){}
    BHasHoverStyle(){}
    SetAcceptsFocus(bool){}
    SetDisableFocusOnMouseDown(bool){}
    BHasKeyFocus(){}
    SetScrollParentToFitWhenFocused(){}
    IsSelected(){}
    BHasDescendantKeyFocus(){}
    BLoadLayout(str, bool, bool2){}
    BLoadLayoutSnippet(str){}
    BHasLayoutSnipper(str){}
    SetTopOfInputContext(bool){}
    SetDialogVariable(str1, str2){}
    SetDialogVariableInt(str, int){}
    SetDialogVariableTime(str, int64){}
    SetDialogVariableLocString(str1, str2){}
    SetDialogVariablePluralLocStringInt(str1, str2, int64){}
    ScrollToTop(){}
    ScrollToBottom(){}
    ScrollToLeftEdge(){}
    ScrollToRightEdge(){}
    ScrollParentToMakePanelFit(unknown, bool){}
    BCanSeeInParentScroll(){}
    GetAttributeInt(str, int){}
    GetAttributeString(str1, str2){}
    GetAttributeUInt32(str, unsigned){}
    SetAttributeInt(str, int){}
    SetAttributeString(str1, str2){}
    SetAttributeUInt32(str, unsigned){}
    SetInputNamespace(str){}
    RegisterForReadyEvents(bool){}
    BReadyForDisplay(){}
    SetReadyForDisplay(bool){}
    SetPositionInPixels(float1, float2, float3){}
    Data(unknown){}
    SetPanelEvent(unknown){}
    RunScriptInPanelContext(unknown){}
    rememberchildfocus(bool){}
    paneltype(){}


    /**
     * Label members.
     */

    /**
     * Text of the panel.
     * @type {string}
     */
    text;

    /**
     * Unknown.
     * @type {boolean}
     */
    html;

    /**
     * Unknown.
     * @param {string} unknown 
     */
    SetLocString(unknown){}

    /**
     * Set the text of the panel. Unknown how it differs from {@link Panel.text}.
     * @param {string} text 
     */
    SetAlreadyLocalizedText(text){}

    /**
     * ToggleButton members.
     */

    /**
     * Set if the button is selected or not.
     * @param {boolean} selected 
     */
    SetSelected(selected){}


    /**
     * DropDown members.
     */


    AddOption(){}
    HasOption(){}
    RemoveOption(){}
    RemoveAllOptions(){}
    GetSelected(){}
    FindDropDownMenuChild(){}
    AccessDropDownMenu(){}
    
    /**
     * ProgressBar members.
     */

    /**
     * @type {number}
     */
    value;

    /**
     * @type {number}
     */
    min;

    /**
     * @type {number}
     */
    max;


    /**
     * TextEntry members.
     */

    SetMaxChars(){}
    GetMaxCharCount(){}
    GetCursorOffset(){}
    SetCursorOffset(){}
    ClearSelection(){}
    SelectAll(){}
    RaiseChangeEvents(){}
    

    /**
     * SlottedSlider/Slider members.
     */

    increment;
    default;
    mousedown;
    SetDirection(){}
    SetShowDefaultValue(){}
    SetRequiresSelection(){}
    SetValueNoEvents(){}
    

    /**
     * Image members.
     */

    SetImage(){}
    SetScaling(){}
    

    /**
     * Carousel members.
     */

    SetSelectedChild(){}
    GetFocusChild(){}
    GetFocusIndex(){}
    

    /**
     * Movie members.
     */

    SetMovie(){}
    SetControls(){}
    SetTitle(){}
    Play(){}
    Pause(){}
    Stop(){}
    SetRepeat(){}
    SetPlaybackVolume(){}
    BAdjustingVolume(){}
    

}

// class Label extends Panel
// {
//     /**
//      * Text of the panel, if the panel is a Label.
//      * @type {string}
//      */
//      text;
// }

// /**
//  * @alias $
//  */
// class Panorama
