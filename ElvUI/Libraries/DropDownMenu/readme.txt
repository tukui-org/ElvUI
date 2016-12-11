Standard UIDropDownMenu global functions using protected frames and causing taints when used by third-party addons. But it is possible to avoid taints by using same functionality with that library.

== What is it ==
Library is standard code from Blizzard's files EasyMenu.lua, UIDropDownMenu.lua and UIDropDownMenuTemplates.xml with frames, tables, variables and functions renamed to:
* constants (typed with all CAPS): "LIB_" added at the start
* functions: "Lib_" added at the start

== Constants ==
* LIB_UIDROPDOWNMENU_MINBUTTONS
* LIB_UIDROPDOWNMENU_MAXBUTTONS
* LIB_UIDROPDOWNMENU_MAXLEVELS
* LIB_UIDROPDOWNMENU_BUTTON_HEIGHT
* LIB_UIDROPDOWNMENU_BORDER_HEIGHT
* LIB_UIDROPDOWNMENU_OPEN_MENU
* LIB_UIDROPDOWNMENU_INIT_MENU
* LIB_UIDROPDOWNMENU_MENU_LEVEL
* LIB_UIDROPDOWNMENU_MENU_VALUE
* LIB_UIDROPDOWNMENU_SHOW_TIME
* LIB_UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
* LIB_OPEN_DROPDOWNMENUS

== Functions ==
* Lib_EasyMenu
* Lib_EasyMenu_Initialize

* Lib_UIDropDownMenuDelegate_OnAttributeChanged
* Lib_UIDropDownMenu_InitializeHelper
* Lib_UIDropDownMenu_Initialize
* Lib_UIDropDownMenu_OnUpdate
* Lib_UIDropDownMenu_StartCounting
* Lib_UIDropDownMenu_StopCounting
* Lib_UIDropDownMenu_CreateInfo
* Lib_UIDropDownMenu_CreateFrames
* Lib_UIDropDownMenu_AddButton
* Lib_UIDropDownMenu_Refresh
* Lib_UIDropDownMenu_RefreshAll
* Lib_UIDropDownMenu_SetIconImage
* Lib_UIDropDownMenu_SetSelectedName
* Lib_UIDropDownMenu_SetSelectedValue
* Lib_UIDropDownMenu_SetSelectedID
* Lib_UIDropDownMenu_GetSelectedName
* Lib_UIDropDownMenu_GetSelectedID
* Lib_UIDropDownMenu_GetSelectedValue
* Lib_UIDropDownMenuButton_OnClick
* Lib_HideDropDownMenu
* Lib_ToggleDropDownMenu
* Lib_CloseDropDownMenus
* Lib_UIDropDownMenu_OnHide
* Lib_UIDropDownMenu_SetWidth
* Lib_UIDropDownMenu_SetButtonWidth
* Lib_UIDropDownMenu_SetText
* Lib_UIDropDownMenu_GetText
* Lib_UIDropDownMenu_ClearAll
* Lib_UIDropDownMenu_JustifyText
* Lib_UIDropDownMenu_SetAnchor
* Lib_UIDropDownMenu_GetCurrentDropDown
* Lib_UIDropDownMenuButton_GetChecked
* Lib_UIDropDownMenuButton_GetName
* Lib_UIDropDownMenuButton_OpenColorPicker
* Lib_UIDropDownMenu_DisableButton
* Lib_UIDropDownMenu_EnableButton
* Lib_UIDropDownMenu_SetButtonText
* Lib_UIDropDownMenu_DisableDropDown
* Lib_UIDropDownMenu_EnableDropDown
* Lib_UIDropDownMenu_IsEnabled
* Lib_UIDropDownMenu_GetValue

== How to use it ==

* Add it to your toc. 
* Like ordinal code for UIDropDownMenu with "Lib_" instead.