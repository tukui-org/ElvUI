local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local AB = E:GetModule('ActionBars')
local ACH = E.Libs.ACH

local _G = _G
local ipairs = ipairs
local format = format
local SetCVar = SetCVar
local GameTooltip = _G.GameTooltip

-- GLOBALS: NUM_ACTIONBAR_BUTTONS, NUM_PET_ACTION_SLOTS, LOCK_ACTIONBAR, MICRO_BUTTONS, AceGUIWidgetLSMlists

local SharedBarOptions = {
	enabled = ACH:Toggle(L["Enable"], nil, 0),
	restorePosition = ACH:Execute(L["Restore Bar"], L["Restore the actionbars default settings"], 1),
	generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouse Over"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"] }),
	barGroup = ACH:Group(L["Bar Settings"], nil, 4),
	buttonGroup = ACH:Group(L["Button Settings"], nil, 5),
	backdropGroup = ACH:Group(L["Backdrop Settings"], nil, 6),
	visibility = ACH:Input(L["Visibility State"], L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"], 8, 4, 'full')
}

local textAnchors = { BOTTOMRIGHT = 'BOTTOMRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', TOPLEFT = 'TOPLEFT', BOTTOM = 'BOTTOM', TOP = 'TOP' }

SharedBarOptions.barGroup.inline = true
SharedBarOptions.barGroup.args.point = ACH:Select(L["Anchor Point"], L["The first button anchors itself to this point on the bar."], 1, { TOPLEFT = 'TOPLEFT', TOPRIGHT = 'TOPRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT' })
SharedBarOptions.barGroup.args.alpha = ACH:Range(L["Alpha"], nil, 2, { min = 0, max = 1, step = 0.01, isPercent = true })
SharedBarOptions.barGroup.args.spacer1 = ACH:Spacer(15, 'full')
SharedBarOptions.barGroup.args.hideHotkey = ACH:Toggle(L["Hide Keybind Text"], nil, 16, nil, nil, nil, function(info) return E.db.actionbar[info[#info-2]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-2]][info[#info]] = value AB:UpdateButtonSettings(info[#info-2]) end)

SharedBarOptions.barGroup.args.customCountFont = ACH:Toggle(L["Count Font"], nil, 20)
SharedBarOptions.barGroup.args.countTextPosition = ACH:Select(L["Text Anchor"], nil, 21, textAnchors)
SharedBarOptions.barGroup.args.countTextXOffset = ACH:Range(L["X-Offset"], nil, 22, { min = -24, max = 24, step = 1 })
SharedBarOptions.barGroup.args.countTextYOffset = ACH:Range(L["Y-Offset"], nil, 23, { min = -24, max = 24, step = 1 })
SharedBarOptions.barGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 24)
SharedBarOptions.barGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 25)
SharedBarOptions.barGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 26, C.Values.FontSize)
SharedBarOptions.barGroup.args.spacer2 = ACH:Spacer(27, 'full')
SharedBarOptions.barGroup.args.customHotkeyFont = ACH:Toggle(L["Keybind Font"], nil, 40)
SharedBarOptions.barGroup.args.hotkeyTextPosition = ACH:Select(L["Text Anchor"], nil, 41, textAnchors)
SharedBarOptions.barGroup.args.hotkeyTextXOffset = ACH:Range(L["X-Offset"], nil, 42, { min = -24, max = 24, step = 1 })
SharedBarOptions.barGroup.args.hotkeyTextYOffset = ACH:Range(L["Y-Offset"], nil, 43, { min = -24, max = 24, step = 1 })
SharedBarOptions.barGroup.args.hotkeyFont = ACH:SharedMediaFont(L["Font"], nil, 44)
SharedBarOptions.barGroup.args.hotkeyFontOutline = ACH:FontFlags(L["Font Outline"], nil, 45)
SharedBarOptions.barGroup.args.hotkeyFontSize = ACH:Range(L["Font Size"], nil, 46, C.Values.FontSize)

local getTextColor = function(info) local t = E.db.actionbar[info[#info-2]][info[#info]] local d = P.actionbar[info[#info-2]][info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
local setTextColor = function(info, r, g, b, a) local t = E.db.actionbar[info[#info-2]][info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdateButtonSettings(info[#info-2]) end

SharedBarOptions.barGroup.args.spacer3 = ACH:Spacer(50, 'full')
SharedBarOptions.barGroup.args.useCountColor = ACH:Toggle(L["Count Text Color"], nil, 51)
SharedBarOptions.barGroup.args.countColor = ACH:Color('', nil, 52, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-2]].useCountColor end)
SharedBarOptions.barGroup.args.spacer4 = ACH:Spacer(55, 'full')
SharedBarOptions.barGroup.args.useHotkeyColor = ACH:Toggle(L["Keybind Text Color"], nil, 56)
SharedBarOptions.barGroup.args.hotkeyColor = ACH:Color('', nil, 57, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-2]].useHotkeyColor end)
SharedBarOptions.barGroup.args.spacer5 = ACH:Spacer(60, 'full')
SharedBarOptions.barGroup.args.useMacroColor = ACH:Toggle(L["Macro Text Color"], nil, 61)
SharedBarOptions.barGroup.args.macroColor = ACH:Color('', nil, 62, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-2]].useMacroColor end)

SharedBarOptions.buttonGroup.inline = true
SharedBarOptions.buttonGroup.args.buttons = ACH:Range(L["Buttons"], L["The amount of buttons to display."], 1, { min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1 })
SharedBarOptions.buttonGroup.args.buttonsPerRow = ACH:Range(L["Buttons Per Row"], L["The amount of buttons to display per row."], 2, { min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1 })
SharedBarOptions.buttonGroup.args.buttonspacing = ACH:Range(L["Button Spacing"], L["The spacing between buttons."], 3, { min = -3, max = 20, step = 1 })
SharedBarOptions.buttonGroup.args.buttonsize = ACH:Range('', nil, 4, { softMin = 14, softMax = 64, min = 12, max = 128, step = 1 })
SharedBarOptions.buttonGroup.args.buttonHeight = ACH:Range(L["Button Height"], L["The height of the action buttons."], 5, { softMin = 14, softMax = 64, min = 12, max = 128, step = 1 })

SharedBarOptions.backdropGroup.inline = true
SharedBarOptions.backdropGroup.args.backdropSpacing = ACH:Range(L["Backdrop Spacing"], L["The spacing between the backdrop and the buttons."], 1, { min = 0, max = 10, step = 1 })
SharedBarOptions.backdropGroup.args.heightMult = ACH:Range(L["Height Multiplier"], L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."], 2, { min = 1, max = 5, step = 1 })
SharedBarOptions.backdropGroup.args.widthMult = ACH:Range(L["Width Multiplier"], L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."], 2, { min = 1, max = 5, step = 1 })

-- Start ActionBar Config
local ActionBar = ACH:Group(L["ActionBars"], nil, 2, 'tab', function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end)
E.Options.args.actionbar = ActionBar

ActionBar.args.intro = ACH:Description(L["ACTIONBARS_DESC"], 0)
ActionBar.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function(info) return E.private.actionbar[info[#info]] end, function(info, value) E.private.actionbar[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
ActionBar.args.toggleKeybind = ACH:Execute(L["Keybind Mode"], nil, 2, function() AB:ActivateBindMode() E:ToggleOptionsUI() GameTooltip:Hide() end)
ActionBar.args.cooldownShortcut = ACH:Execute(L["Cooldown Text"], nil, 3, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'cooldown', 'actionbar') end)

ActionBar.args.general = ACH:Group(L["General"], nil, 3, nil, nil, nil, function() return not E.ActionBars.Initialized end)
ActionBar.args.general.args.movementModifier = ACH:Select(L["PICKUP_ACTION_KEY_TEXT"], L["The button you must hold down in order to drag an ability to another action button."], 1, { NONE = L["NONE"], SHIFT = L["SHIFT_KEY_TEXT"], ALT = L["ALT_KEY_TEXT"], CTRL = L["CTRL_KEY_TEXT"] }, nil, nil, nil, nil, nil, function() return not E.db.actionbar.lockActionBars end)
ActionBar.args.general.args.flyoutSize = ACH:Range(L["Flyout Button Size"], nil, 2, { min = 15, max = 60, step = 1 })
ActionBar.args.general.args.globalFadeAlpha = ACH:Range(L["Global Fade Transparency"], L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."], 3, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value; AB.fadeParent:SetAlpha(1-value) end)

ActionBar.args.general.args.generalGroup = ACH:Group(L["General"], nil, 20, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end)
ActionBar.args.general.args.generalGroup.inline = true

ActionBar.args.general.args.generalGroup.args.keyDown = ACH:Toggle(L["Key Down"], L["OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN"], 1)
ActionBar.args.general.args.generalGroup.args.lockActionBars = ACH:Toggle(L["LOCK_ACTIONBAR_TEXT"], L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."], 2, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() SetCVar('lockActionBars', (value == true and 1 or 0)) LOCK_ACTIONBAR = (value == true and '1' or '0') end)
ActionBar.args.general.args.generalGroup.args.hideCooldownBling = ACH:Toggle(L["Hide Cooldown Bling"], L["Hides the bling animation on buttons at the end of the global cooldown."], 3, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() AB:UpdatePetCooldownSettings() end)
ActionBar.args.general.args.generalGroup.args.addNewSpells = ACH:Toggle(L["Auto Add New Spells"], L["Allow newly learned spells to be automatically placed on an empty actionbar slot."], 4, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:IconIntroTracker_Toggle() end)
ActionBar.args.general.args.generalGroup.args.rightClickSelfCast = ACH:Toggle(L["RightClick Self-Cast"], nil, 5)
ActionBar.args.general.args.generalGroup.args.useDrawSwipeOnCharges = ACH:Toggle(L["Charge Draw Swipe"], L["Shows a swipe animation when a spell is recharging but still has charges left."], 6)
ActionBar.args.general.args.generalGroup.args.chargeCooldown = ACH:Toggle(L["Charge Cooldown Text"], nil, 7, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:ToggleCooldownOptions() end)
ActionBar.args.general.args.generalGroup.args.desaturateOnCooldown = ACH:Toggle(L["Desaturate Cooldowns"], nil, 8, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:ToggleCooldownOptions() end)
ActionBar.args.general.args.generalGroup.args.transparent = ACH:Toggle(L["Transparent"], nil, 9, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value E:StaticPopup_Show('PRIVATE_RL') end)
ActionBar.args.general.args.generalGroup.args.flashAnimation = ACH:Toggle(L["Button Flash"], L["Use a more visible flash animation for Auto Attacks."], 10, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value E:StaticPopup_Show('PRIVATE_RL') end)
ActionBar.args.general.args.generalGroup.args.equippedItem = ACH:Toggle(L["Equipped Item Color"], nil, 11)
ActionBar.args.general.args.generalGroup.args.macrotext = ACH:Toggle(L["Macro Text"], L["Display macro names on action buttons."], 12)
ActionBar.args.general.args.generalGroup.args.hotkeytext = ACH:Toggle(L["Keybind Text"], L["Display bind names on action buttons."], 13)
ActionBar.args.general.args.generalGroup.args.useRangeColorText = ACH:Toggle(L["Color Keybind Text"], L["Color Keybind Text when Out of Range, instead of the button."], 14)
ActionBar.args.general.args.generalGroup.args.handleOverlay = ACH:Toggle(L["Action Button Glow"], nil, 15)

ActionBar.args.general.args.colorGroup = ACH:Group(L["COLORS"], nil, 30, nil, function(info) local t = E.db.actionbar[info[#info]] local d = P.actionbar[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.actionbar[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdateButtonSettings() end, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
ActionBar.args.general.args.colorGroup.inline = true
ActionBar.args.general.args.colorGroup.args.fontColor = ACH:Color(L["Text"], nil, 0)
ActionBar.args.general.args.colorGroup.args.noRangeColor = ACH:Color(L["Out of Range"], L["Color of the actionbutton when out of range."], 1)
ActionBar.args.general.args.colorGroup.args.noPowerColor = ACH:Color(L["Out of Power"], L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."], 2)
ActionBar.args.general.args.colorGroup.args.usableColor = ACH:Color(L["Usable"], L["Color of the actionbutton when usable."], 3)
ActionBar.args.general.args.colorGroup.args.notUsableColor = ACH:Color(L["Not Usable"], L["Color of the actionbutton when not usable."], 4)
ActionBar.args.general.args.colorGroup.args.colorSwipeNormal = ACH:Color(L["Swipe: Normal"], nil, 5, true)
ActionBar.args.general.args.colorGroup.args.colorSwipeLOC = ACH:Color(L["Swipe: Loss of Control"], nil, 6, true)
ActionBar.args.general.args.colorGroup.args.equippedItemColor = ACH:Color(L["Equipped Item Color"], nil, 7)

ActionBar.args.general.args.fontGroup = ACH:Group(L["Fonts"], nil, 40)
ActionBar.args.general.args.fontGroup.inline = true
ActionBar.args.general.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
ActionBar.args.general.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
ActionBar.args.general.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

ActionBar.args.general.args.countTextGroup = ACH:Group(L["Count Text"], nil, 50, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
ActionBar.args.general.args.countTextGroup.inline = true
ActionBar.args.general.args.countTextGroup.args.countTextPosition = ACH:Select(L["Position"], nil, 1, textAnchors)
ActionBar.args.general.args.countTextGroup.args.countTextXOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -24, max = 24, step = 1 })
ActionBar.args.general.args.countTextGroup.args.countTextYOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -24, max = 24, step = 1 })

ActionBar.args.general.args.hotkeyTextGroup = ACH:Group(L["Keybind Text"], nil, 60, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
ActionBar.args.general.args.hotkeyTextGroup.inline = true
ActionBar.args.general.args.hotkeyTextGroup.args.hotkeyTextPosition = ACH:Select(L["Position"], nil, 1, textAnchors)
ActionBar.args.general.args.hotkeyTextGroup.args.hotkeyTextXOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -24, max = 24, step = 1 })
ActionBar.args.general.args.hotkeyTextGroup.args.hotkeyTextYOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -24, max = 24, step = 1 })

ActionBar.args.general.args.masqueGroup = ACH:Group(L["Masque Support"], nil, -1, nil, function(info) return E.private.actionbar.masque[info[#info]] end, function(info, value) E.private.actionbar.masque[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end, function() return not E.Masque end)
ActionBar.args.general.args.masqueGroup.inline = true
ActionBar.args.general.args.masqueGroup.args.actionbars = ACH:Toggle(L["ActionBars"], nil, 1)
ActionBar.args.general.args.masqueGroup.args.petBar = ACH:Toggle(L["Pet Bar"], nil, 2)
ActionBar.args.general.args.masqueGroup.args.stanceBar = ACH:Toggle(L["Stance Bar"], nil, 3)

ActionBar.args.barPet = ACH:Group(L["Pet Bar"], nil, 14, nil, function(info) return E.db.actionbar.barPet[info[#info]] end, function(info, value) E.db.actionbar.barPet[info[#info]] = value; AB:PositionAndSizeBarPet() end, function() return not E.ActionBars.Initialized end)
ActionBar.args.barPet.args = CopyTable(SharedBarOptions)
ActionBar.args.barPet.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.barPet, P.actionbar.barPet); E:ResetMovers('Pet Bar'); AB:PositionAndSizeBarPet() end
ActionBar.args.barPet.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouse Over"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.barPet[key] end, function(_, key, value) E.db.actionbar.barPet[key] = value; AB:PositionAndSizeBarPet() end)
ActionBar.args.barPet.args.buttonGroup.args.buttonsize.name = function() return E.db.actionbar.barPet.keepSizeRatio and L["Button Size"] or L["Button Width"] end
ActionBar.args.barPet.args.buttonGroup.args.buttonsize.desc = function() return E.db.actionbar.barPet.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
ActionBar.args.barPet.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.barPet.keepSizeRatio end
ActionBar.args.barPet.args.buttonGroup.args.buttonsPerRow.max = NUM_PET_ACTION_SLOTS
ActionBar.args.barPet.args.buttonGroup.args.buttons.max = NUM_PET_ACTION_SLOTS
ActionBar.args.barPet.args.visibility.set = function(_, value) E.db.actionbar.barPet.visibility = value; AB:PositionAndSizeBarPet() end

ActionBar.args.stanceBar = ACH:Group(L["Stance Bar"], nil, 15, nil, function(info) return E.db.actionbar.stanceBar[info[#info]] end, function(info, value) E.db.actionbar.stanceBar[info[#info]] = value; AB:PositionAndSizeBarShapeShift() end, function() return not E.ActionBars.Initialized end)
ActionBar.args.stanceBar.args = CopyTable(SharedBarOptions)
ActionBar.args.stanceBar.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.stanceBar, P.actionbar.stanceBar); E:ResetMovers('Stance Bar'); AB:PositionAndSizeBarShapeShift() end
ActionBar.args.stanceBar.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouse Over"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.stanceBar[key] end, function(_, key, value) E.db.actionbar.stanceBar[key] = value; AB:PositionAndSizeBarShapeShift() end)
ActionBar.args.stanceBar.args.buttonGroup.args.buttonsize.name = function() return E.db.actionbar.stanceBar.keepSizeRatio and L["Button Size"] or L["Button Width"] end
ActionBar.args.stanceBar.args.buttonGroup.args.buttonsize.desc = function() return E.db.actionbar.stanceBar.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
ActionBar.args.stanceBar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.stanceBar.keepSizeRatio end
ActionBar.args.stanceBar.args.buttonGroup.args.buttonsPerRow.max = NUM_STANCE_SLOTS
ActionBar.args.stanceBar.args.buttonGroup.args.buttons.max = NUM_STANCE_SLOTS
ActionBar.args.stanceBar.args.barGroup.args.style = ACH:Select(L["Style"], L["This setting will be updated upon changing stances."], 12, { darkenInactive = L["Darken Inactive"], classic = L["Classic"] })
ActionBar.args.stanceBar.args.visibility.set = function(_, value) E.db.actionbar.stanceBar.visibility = value; AB:PositionAndSizeBarShapeShift() end

ActionBar.args.microbar = ACH:Group(L["Micro Bar"], nil, 16, nil, function(info) return E.db.actionbar.microbar[info[#info]] end, function(info, value) E.db.actionbar.microbar[info[#info]] = value; AB:UpdateMicroPositionDimensions() end, function() return not E.ActionBars.Initialized end)
ActionBar.args.microbar.args = CopyTable(SharedBarOptions)
ActionBar.args.microbar.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.microbar, P.actionbar.microbar); E:ResetMovers('Micro Bar'); AB:UpdateMicroPositionDimensions() end
ActionBar.args.microbar.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouse Over"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.microbar[key] end, function(_, key, value) E.db.actionbar.microbar[key] = value; AB:UpdateMicroPositionDimensions() end)
ActionBar.args.microbar.args.buttonGroup.args.buttons = nil
ActionBar.args.microbar.args.buttonGroup.args.buttonSize = CopyTable(E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonsize)
ActionBar.args.microbar.args.buttonGroup.args.buttonsize = nil
ActionBar.args.microbar.args.buttonGroup.args.buttonSpacing = CopyTable(E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonspacing)
ActionBar.args.microbar.args.buttonGroup.args.buttonspacing = nil
ActionBar.args.microbar.args.buttonGroup.args.buttonsPerRow.max = #MICRO_BUTTONS-1
ActionBar.args.microbar.args.buttonGroup.args.buttonSize.name = function() return E.db.actionbar.microbar.keepSizeRatio and L["Button Size"] or L["Button Width"] end
ActionBar.args.microbar.args.buttonGroup.args.buttonSize.desc = function() return E.db.actionbar.microbar.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
ActionBar.args.microbar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.microbar.keepSizeRatio end
ActionBar.args.microbar.args.visibility.set = function(_, value) E.db.actionbar.microbar.visibility = value; AB:UpdateMicroPositionDimensions() end

--Remove these as these bars doesnt have these options
for _, name in ipairs({'microbar', 'barPet', 'stanceBar'}) do
	local options = E.Options.args.actionbar.args[name].args.barGroup.args
	options.countFont = nil
	options.countFontOutline = nil
	options.countFontSize = nil
	options.countTextXOffset = nil
	options.countTextYOffset = nil
	options.countTextPosition = nil
	options.customCountFont = nil
	options.customHotkeyFont = nil
	options.hotkeyFont = nil
	options.hotkeyFontOutline = nil
	options.hotkeyFontSize = nil
	options.hotkeyTextPosition = nil
	options.hotkeyTextXOffset = nil
	options.hotkeyTextYOffset = nil
	options.spacer1 = nil
	options.spacer2 = nil
	options.spacer3 = nil
	options.spacer4 = nil
	options.useHotkeyColor = nil
	options.hotkeyColor = nil
	options.useCountColor = nil
	options.countColor = nil
	options.useMacroColor = nil
	options.macroColor = nil

	if name == 'microbar' then
		options.hideHotkey = nil
	elseif name == 'stanceBar' then
		options.hideHotkey.set = function(info, value) E.db.actionbar[info[#info-2]][info[#info]] = value AB:UpdateStanceBindings() end
	elseif name == 'barPet' then
		options.hideHotkey.set = function(info, value) E.db.actionbar[info[#info-2]][info[#info]] = value AB:UpdatePetBindings() end
	end
end

local SharedButtonOptions = {
	alpha = ACH:Range(L["Alpha"], L["Change the alpha level of the frame."], 1, { min = 0, max = 1, step = 0.01, isPercent = true }),
	scale = ACH:Range(L["Scale"], nil, 2, { min = 0.2, max = 2, step = 0.01, isPercent = true }),
	inheritGlobalFade = ACH:Toggle(L["Inherit Global Fade"], nil, 3),
	clean = ACH:Toggle(L["Clean Button"], nil, 4),
}

ActionBar.args.extraButtons = ACH:Group(L["Extra Buttons"], nil, 18, nil, nil, nil, function() return not E.ActionBars.Initialized end)

ActionBar.args.extraButtons.args.extraActionButton = ACH:Group(L["Boss Button"], nil, 1, nil, function(info) return E.db.actionbar.extraActionButton[info[#info]] end, function(info, value) local key = info[#info] E.db.actionbar.extraActionButton[key] = value; if key == 'inheritGlobalFade' then AB:ExtraButtons_GlobalFade() elseif key == 'scale' then AB:ExtraButtons_UpdateScale() else AB:ExtraButtons_UpdateAlpha() end end)
ActionBar.args.extraButtons.args.extraActionButton.inline = true
ActionBar.args.extraButtons.args.extraActionButton.args = CopyTable(SharedButtonOptions)

ActionBar.args.extraButtons.args.zoneButton = ACH:Group(L["Zone Button"], nil, 2, nil, function(info) return E.db.actionbar.zoneActionButton[info[#info]] end, function(info, value) local key = info[#info] E.db.actionbar.zoneActionButton[key] = value; if key == 'inheritGlobalFade' then AB:ExtraButtons_GlobalFade() elseif key == 'scale' then AB:ExtraButtons_UpdateScale() else AB:ExtraButtons_UpdateAlpha() end end)
ActionBar.args.extraButtons.args.zoneButton.inline = true
ActionBar.args.extraButtons.args.zoneButton.args = CopyTable(SharedButtonOptions)

ActionBar.args.extraButtons.args.vehicleExitButton = ACH:Group(L["Vehicle Exit"], nil, 3, nil, function(info) return E.db.actionbar.vehicleExitButton[info[#info]] end, function(info, value) E.db.actionbar.vehicleExitButton[info[#info]] = value; AB:UpdateVehicleLeave() end)
ActionBar.args.extraButtons.args.vehicleExitButton.inline = true
ActionBar.args.extraButtons.args.vehicleExitButton.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.actionbar.vehicleExitButton[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
ActionBar.args.extraButtons.args.vehicleExitButton.args.size = ACH:Range(L["Size"], nil, 2, { min = 16, max = 50, step = 1 })
ActionBar.args.extraButtons.args.vehicleExitButton.args.strata = ACH:Select(L["Frame Strata"], nil, 3, { BACKGROUND = 'BACKGROUND', LOW = 'LOW', MEDIUM = 'MEDIUM', HIGH = 'HIGH' })
ActionBar.args.extraButtons.args.vehicleExitButton.args.level = ACH:Range(L["Frame Level"], nil, 4, { min = 1, max = 128, step = 1 })

ActionBar.args.playerBars = ACH:Group(L["Player Bars"], nil, 4, 'tree', nil, nil, function() return not E.ActionBars.Initialized end)

for i = 1, 10 do
	local bar = ACH:Group(L["Bar "]..i, nil, i, 'group', function(info) return E.db.actionbar['bar'..i][info[#info]] end, function(info, value) E.db.actionbar['bar'..i][info[#info]] = value; AB:PositionAndSizeBar('bar'..i) end)
	ActionBar.args.playerBars.args['bar'..i] = bar

	bar.args = CopyTable(SharedBarOptions)

	bar.args.enabled.set = function(info, value) E.db.actionbar['bar'..i][info[#info]] = value AB:PositionAndSizeBar('bar'..i) end
	bar.args.restorePosition.func = function() E:CopyTable(E.db.actionbar['bar'..i], P.actionbar['bar'..i]) E:ResetMovers('Bar '..i) AB:PositionAndSizeBar('bar'..i) end

	bar.args.generalOptions.get = function(_, key) return E.db.actionbar['bar'..i][key] end
	bar.args.generalOptions.set = function(_, key, value) E.db.actionbar['bar'..i][key] = value AB:UpdateButtonSettings('bar'..i) end
	bar.args.generalOptions.values.showGrid = L["Show Empty Buttons"]
	bar.args.generalOptions.values.keepSizeRatio = L["Keep Size Ratio"]

	bar.args.barGroup.args.flyoutDirection = ACH:Select(L["Flyout Direction"], nil, 2, { UP = L["Up"], DOWN = L["Down"], LEFT = L["Left"], RIGHT = L["Right"], AUTOMATIC = L["Automatic"] }, nil, nil, nil, function(info, value) E.db.actionbar['bar'..i][info[#info]] = value AB:UpdateButtonSettings('bar'..i) end)

	bar.args.buttonGroup.args.buttonsize.name = function() return E.db.actionbar['bar'..i].keepSizeRatio and L["Button Size"] or L["Button Width"] end
	bar.args.buttonGroup.args.buttonsize.desc = function() return E.db.actionbar['bar'..i].keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
	bar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar['bar'..i].keepSizeRatio end

	bar.args.backdropGroup.hidden = function() return not E.db.actionbar['bar'..i].backdrop end

	bar.args.paging = ACH:Input(L["Action Paging"], L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"], 7, 4, 'full', function() return E.db.actionbar['bar'..i].paging[E.myclass] end, function(_, value) E.db.actionbar['bar'..i].paging[E.myclass] = value AB:UpdateButtonSettings('bar'..i) end)

	bar.args.visibility.set = function(_, value) E.db.actionbar['bar'..i].visibility = value AB:UpdateButtonSettings('bar'..i) end

	local countHidden = function() return not E.db.actionbar['bar'..i].customCountFont end
	bar.args.barGroup.args.countFont.hidden = countHidden
	bar.args.barGroup.args.countFontOutline.hidden = countHidden
	bar.args.barGroup.args.countFontSize.hidden = countHidden
	bar.args.barGroup.args.countTextXOffset.hidden = countHidden
	bar.args.barGroup.args.countTextYOffset.hidden = countHidden
	bar.args.barGroup.args.countTextPosition.hidden = countHidden

	bar.args.barGroup.args.spacer2.hidden = countHidden

	local hotkeyHide = function() return E.db.actionbar['bar'..i].hideHotkey or not E.db.actionbar['bar'..i].customHotkeyFont end
	bar.args.barGroup.args.customHotkeyFont.hidden = function() return E.db.actionbar['bar'..i].hideHotkey end
	bar.args.barGroup.args.hotkeyFont.hidden = hotkeyHide
	bar.args.barGroup.args.hotkeyFontOutline.hidden = hotkeyHide
	bar.args.barGroup.args.hotkeyFontSize.hidden = hotkeyHide
	bar.args.barGroup.args.hotkeyTextPosition.hidden = hotkeyHide
	bar.args.barGroup.args.hotkeyTextXOffset.hidden = hotkeyHide
	bar.args.barGroup.args.hotkeyTextYOffset.hidden = hotkeyHide

	if (E.myclass == 'DRUID' and i >= 7 or E.myclass == 'ROGUE' and i == 7) then
		bar.args.enabled.confirm = function() return format(L["Bar %s is used for stance or forms.|N You will have to adjust paging to use this bar.|N Are you sure?"], i) end
	end
end

ActionBar.args.playerBars.args.bar1.args.pagingReset = ACH:Execute(L["Reset Action Paging"], nil, 2, function() E.db.actionbar.bar1.paging[E.myclass] = P.actionbar.bar1.paging[E.myclass] AB:UpdateButtonSettings('bar1') end, nil, L["You are about to reset paging. Are you sure?"])
ActionBar.args.playerBars.args.bar6.args.enabled.set = function(_, value) E.db.actionbar.bar6.enabled = value; AB:PositionAndSizeBar('bar6') AB:UpdateBar1Paging() AB:PositionAndSizeBar('bar1') end
