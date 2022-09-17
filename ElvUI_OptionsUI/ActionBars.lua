local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.OptionsUI)
local AB = E:GetModule('ActionBars')
local ACH = E.Libs.ACH

local _G = _G
local ipairs = ipairs
local format = format
local SetCVar = SetCVar
local CopyTable = CopyTable
local GameTooltip = GameTooltip
local GetCVarBool = GetCVarBool
local GetModifiedClick = GetModifiedClick
local SetModifiedClick = SetModifiedClick
local GetCurrentBindingSet = GetCurrentBindingSet
local SaveBindings = SaveBindings

-- GLOBALS: LOCK_ACTIONBAR

local SharedBarOptions = {
	enabled = ACH:Toggle(L["Enable"], nil, 0),
	restorePosition = ACH:Execute(L["Restore Bar"], L["Restore the actionbars default settings"], 1),
	generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouseover"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"] }),
	buttonGroup = ACH:Group(L["Button Settings"], nil, 4),
	backdropGroup = ACH:Group(L["Backdrop Settings"], nil, 5),
	barGroup = ACH:Group(L["Bar Settings"], nil, 6),
	visibility = ACH:Input(L["Visibility State"], L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"], 8, 4, 'full')
}

local castKeyValues = { NONE = L["NONE"], SHIFT = L["SHIFT_KEY_TEXT"], CTRL = L["CTRL_KEY_TEXT"], ALT = L["ALT_KEY_TEXT"] }

local textAnchors = { BOTTOMRIGHT = 'BOTTOMRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', TOPLEFT = 'TOPLEFT', BOTTOM = 'BOTTOM', TOP = 'TOP' }
local getTextColor = function(info) local t = E.db.actionbar[info[#info-3]][info[#info]] local d = P.actionbar[info[#info-3]][info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
local setTextColor = function(info, r, g, b, a) local t = E.db.actionbar[info[#info-3]][info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdateButtonSettings(info[#info-3]) end

SharedBarOptions.buttonGroup.inline = true
SharedBarOptions.buttonGroup.args.buttons = ACH:Range(L["Buttons"], L["The amount of buttons to display."], 1, { min = 1, max = _G.NUM_ACTIONBAR_BUTTONS, step = 1 })
SharedBarOptions.buttonGroup.args.buttonsPerRow = ACH:Range(L["Buttons Per Row"], L["The amount of buttons to display per row."], 2, { min = 1, max = _G.NUM_ACTIONBAR_BUTTONS, step = 1 })
SharedBarOptions.buttonGroup.args.buttonSpacing = ACH:Range(L["Button Spacing"], L["The spacing between buttons."], 3, { min = -3, max = 20, step = 1 })
SharedBarOptions.buttonGroup.args.buttonSize = ACH:Range('', nil, 4, { softMin = 14, softMax = 64, min = 12, max = 128, step = 1 })
SharedBarOptions.buttonGroup.args.buttonHeight = ACH:Range(L["Button Height"], L["The height of the action buttons."], 5, { softMin = 14, softMax = 64, min = 12, max = 128, step = 1 })

SharedBarOptions.barGroup.inline = true
SharedBarOptions.barGroup.args.point = ACH:Select(L["Anchor Point"], L["The first button anchors itself to this point on the bar."], 1, { TOPLEFT = 'TOPLEFT', TOPRIGHT = 'TOPRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT' })
SharedBarOptions.barGroup.args.alpha = ACH:Range(L["Alpha"], nil, 2, { min = 0, max = 1, step = 0.01, isPercent = true })

local strataAndLevel = ACH:Group(L["Strata and Level"], nil, 30)
strataAndLevel.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 3, { BACKGROUND = 'BACKGROUND', LOW = 'LOW', MEDIUM = 'MEDIUM', HIGH = 'HIGH' })
strataAndLevel.args.frameLevel = ACH:Range(L["Frame Level"], nil, 4, { min = 1, max = 256, step = 1 })
SharedBarOptions.barGroup.args.strataAndLevel = strataAndLevel

local hotkeyTextGroup = ACH:Group(L["Keybind Text"], nil, 40, nil, function(info) return E.db.actionbar[info[#info-3]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-3]][info[#info]] = value AB:UpdateButtonSettings(info[#info-3]) end)
hotkeyTextGroup.inline = true
hotkeyTextGroup.args.hotkeytext = ACH:Toggle(L["Enable"], L["Display bind names on action buttons."], 0, nil, nil, nil, nil, nil, nil, false)
hotkeyTextGroup.args.useHotkeyColor = ACH:Toggle(L["Custom Color"], nil, 1)
hotkeyTextGroup.args.hotkeyColor = ACH:Color('', nil, 2, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-3]].useHotkeyColor or not E.db.actionbar[info[#info-3]].hotkeytext end)
hotkeyTextGroup.args.spacer1 = ACH:Spacer(3, 'full')
hotkeyTextGroup.args.hotkeyTextPosition = ACH:Select(L["Position"], nil, 4, textAnchors, nil, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
hotkeyTextGroup.args.hotkeyTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
hotkeyTextGroup.args.hotkeyTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
hotkeyTextGroup.args.spacer2 = ACH:Spacer(7, 'full')
hotkeyTextGroup.args.hotkeyFont = ACH:SharedMediaFont(L["Font"], nil, 8)
hotkeyTextGroup.args.hotkeyFontOutline = ACH:FontFlags(L["Font Outline"], nil, 9)
hotkeyTextGroup.args.hotkeyFontSize = ACH:Range(L["Font Size"], nil, 10, C.Values.FontSize)
SharedBarOptions.barGroup.args.hotkeyTextGroup = hotkeyTextGroup

local countTextGroup = ACH:Group(L["Count Text"], nil, 50, nil, function(info) return E.db.actionbar[info[#info-3]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-3]][info[#info]] = value AB:UpdateButtonSettings(info[#info-3]) end)
countTextGroup.inline = true
countTextGroup.args.counttext = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, nil, nil, false)
countTextGroup.args.useCountColor = ACH:Toggle(L["Custom Color"], nil, 1)
countTextGroup.args.countColor = ACH:Color('', nil, 2, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-3]].useCountColor or not E.db.actionbar[info[#info-3]].counttext end)
countTextGroup.args.spacer1 = ACH:Spacer(3, 'full')
countTextGroup.args.countTextPosition = ACH:Select(L["Position"], nil, 4, textAnchors, nil, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
countTextGroup.args.countTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
countTextGroup.args.countTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
countTextGroup.args.spacer2 = ACH:Spacer(7, 'full')
countTextGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 8)
countTextGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 9)
countTextGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 10, C.Values.FontSize)
SharedBarOptions.barGroup.args.countTextGroup = countTextGroup

local macroTextGroup = ACH:Group(L["Macro Text"], nil, 60, nil, function(info) return E.db.actionbar[info[#info-3]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-3]][info[#info]] = value AB:UpdateButtonSettings(info[#info-3]) end)
macroTextGroup.inline = true
macroTextGroup.args.macrotext = ACH:Toggle(L["Enable"], L["Display macro names on action buttons."], 0, nil, nil, nil, nil, nil, nil, false)
macroTextGroup.args.useMacroColor = ACH:Toggle(L["Custom Color"], nil, 1)
macroTextGroup.args.macroColor = ACH:Color('', nil, 2, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-3]].useMacroColor or not E.db.actionbar[info[#info-3]].macrotext end)
macroTextGroup.args.spacer1 = ACH:Spacer(3, 'full')
macroTextGroup.args.macroTextPosition = ACH:Select(L["Position"], nil, 4, textAnchors, nil, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
macroTextGroup.args.macroTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
macroTextGroup.args.macroTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
macroTextGroup.args.spacer2 = ACH:Spacer(7, 'full')
macroTextGroup.args.macroFont = ACH:SharedMediaFont(L["Font"], nil, 8)
macroTextGroup.args.macroFontSize = ACH:Range(L["Font Size"], nil, 9, C.Values.FontSize)
macroTextGroup.args.macroFontOutline = ACH:FontFlags(L["Font Outline"], nil, 10)
SharedBarOptions.barGroup.args.macroTextGroup = macroTextGroup

SharedBarOptions.backdropGroup.inline = true
SharedBarOptions.backdropGroup.args.backdropSpacing = ACH:Range(L["Backdrop Spacing"], L["The spacing between the backdrop and the buttons."], 1, { min = 0, max = 10, step = 1 })
SharedBarOptions.backdropGroup.args.heightMult = ACH:Range(L["Height Multiplier"], L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."], 2, { min = 1, max = 5, step = 1 })
SharedBarOptions.backdropGroup.args.widthMult = ACH:Range(L["Width Multiplier"], L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."], 2, { min = 1, max = 5, step = 1 })

-- Start ActionBar Config
local ActionBar = ACH:Group(L["ActionBars"], nil, 2, 'tab', function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end)
E.Options.args.actionbar = ActionBar

ActionBar.args.intro = ACH:Description(L["ACTIONBARS_DESC"], 0)
ActionBar.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function(info) return E.private.actionbar[info[#info]] end, function(info, value) E.private.actionbar[info[#info]] = value; E.ShowPopup = true end)
ActionBar.args.toggleKeybind = ACH:Execute(L["Keybind Mode"], nil, 2, function() AB:ActivateBindMode() E:ToggleOptionsUI() GameTooltip:Hide() end)
ActionBar.args.cooldownShortcut = ACH:Execute(L["Cooldown Text"], nil, 3, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'cooldown', 'actionbar') end)

local general = ACH:Group(L["General"], nil, 3, nil, nil, nil, function() return not E.ActionBars.Initialized end)
ActionBar.args.general = general
general.args.movementModifier = ACH:Select(L["PICKUP_ACTION_KEY_TEXT"], L["The button you must hold down in order to drag an ability to another action button."], 1, { NONE = L["None"], SHIFT = L["SHIFT_KEY_TEXT"], ALT = L["ALT_KEY_TEXT"], CTRL = L["CTRL_KEY_TEXT"] }, nil, nil, nil, nil, nil, function() return not E.db.actionbar.lockActionBars end)
general.args.flyoutSize = ACH:Range(L["Flyout Button Size"], nil, 2, { min = 15, max = 60, step = 1 })
general.args.globalFadeAlpha = ACH:Range(L["Global Fade Transparency"], L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."], 3, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value; AB.fadeParent:SetAlpha(1-value) end)
general.args.customGlowShortcut = ACH:Execute(L["Custom Glow"], nil, 4, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'general', 'cosmetic') end)

general.args.generalGroup = ACH:Group(L["General"], nil, 20, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end)
general.args.generalGroup.inline = true
general.args.generalGroup.args.keyDown = ACH:Toggle(L["Key Down"], L["OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN"], 1)
general.args.generalGroup.args.lockActionBars = ACH:Toggle(L["LOCK_ACTIONBAR_TEXT"], L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."], 2, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() SetCVar('lockActionBars', (value == true and 1 or 0)) LOCK_ACTIONBAR = (value == true and '1' or '0') end)
general.args.generalGroup.args.hideCooldownBling = ACH:Toggle(L["Hide Cooldown Bling"], L["Hides the bling animation on buttons at the end of the global cooldown."], 3, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() AB:UpdatePetCooldownSettings() end)
general.args.generalGroup.args.addNewSpells = ACH:Toggle(L["Auto Add New Spells"], L["Allow newly learned spells to be automatically placed on an empty actionbar slot."], 4, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:IconIntroTracker_Toggle() end, nil, not E.Retail)
general.args.generalGroup.args.useDrawSwipeOnCharges = ACH:Toggle(L["Charge Draw Swipe"], L["Shows a swipe animation when a spell is recharging but still has charges left."], 9)
general.args.generalGroup.args.chargeCooldown = ACH:Toggle(L["Charge Cooldown Text"], nil, 10, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:ToggleCooldownOptions() end)
general.args.generalGroup.args.desaturateOnCooldown = ACH:Toggle(L["Desaturate Cooldowns"], nil, 11, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:ToggleCooldownOptions() end)
general.args.generalGroup.args.transparent = ACH:Toggle(L["Transparent"], nil, 12, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value E.ShowPopup = true end)
general.args.generalGroup.args.flashAnimation = ACH:Toggle(L["Button Flash"], L["Use a more visible flash animation for Auto Attacks."], 13, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value E.ShowPopup = true end)
general.args.generalGroup.args.equippedItem = ACH:Toggle(L["Equipped Item Color"], nil, 14)
general.args.generalGroup.args.useRangeColorText = ACH:Toggle(L["Color Keybind Text"], L["Color Keybind Text when Out of Range, instead of the button."], 15)
general.args.generalGroup.args.handleOverlay = ACH:Toggle(L["Action Button Glow"], nil, 16)

general.args.castGroup = ACH:Group(L["Casting"], nil, 25)
general.args.castGroup.args.mouseoverCastKey = ACH:Select(L["Mouseover Cast Key"], nil, 1, castKeyValues, nil, nil, function() return GetModifiedClick('MOUSEOVERCAST') end, function(_, value) SetModifiedClick('MOUSEOVERCAST', value); SaveBindings(GetCurrentBindingSet()) end, nil, not E.Retail)
general.args.castGroup.args.checkMouseoverCast = ACH:Toggle(L["Check Mouseover Cast"], nil, 2, nil, nil, nil, function() return GetCVarBool('enableMouseoverCast') end, function(_, value) SetCVar('enableMouseoverCast', value and 1 or 0); AB:UpdateButtonSettings() end, nil, not E.Retail)
general.args.castGroup.args.spacer1 = ACH:Spacer(3, 'full', not E.Retail)
general.args.castGroup.args.focusCastKey = ACH:Select(L["Focus Cast Key"], nil, 10, castKeyValues, nil, nil, function() return GetModifiedClick('FOCUSCAST') end, function(_, value) SetModifiedClick('FOCUSCAST', value); SaveBindings(GetCurrentBindingSet()) end, nil, E.Classic)
general.args.castGroup.args.checkFocusCast = ACH:Toggle(L["Check Focus Cast"], nil, 11, nil, nil, nil, nil, nil, nil, E.Classic)
general.args.castGroup.args.spacer2 = ACH:Spacer(12, 'full', E.Classic)
general.args.castGroup.args.selfCastKey = ACH:Select(L["Self Cast Key"], nil, 20, castKeyValues, nil, nil, function() return GetModifiedClick('SELFCAST') end, function(_, value) SetModifiedClick('SELFCAST', value); SaveBindings(GetCurrentBindingSet()) end)
general.args.castGroup.args.checkSelfCast = ACH:Toggle(L["Check Self Cast"], nil, 21)
general.args.castGroup.args.autoSelfCast = ACH:Toggle(L["Auto Self Cast"], nil, 22, nil, nil, nil, function() return GetCVarBool('autoSelfCast') end, function(_, value) SetCVar('autoSelfCast', value and 1 or 0) end)
general.args.castGroup.args.rightClickSelfCast = ACH:Toggle(L["Right Click Self Cast"], nil, 23, nil, nil, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end)

general.args.colorGroup = ACH:Group(L["Colors"], nil, 30, nil, function(info) local t = E.db.actionbar[info[#info]] local d = P.actionbar[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.actionbar[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdateButtonSettings() end, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
general.args.colorGroup.inline = true
general.args.colorGroup.args.fontColor = ACH:Color(L["Text"], nil, 0)
general.args.colorGroup.args.noRangeColor = ACH:Color(L["Out of Range"], L["Color of the actionbutton when out of range."], 1)
general.args.colorGroup.args.noPowerColor = ACH:Color(L["Out of Power"], L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."], 2)
general.args.colorGroup.args.usableColor = ACH:Color(L["Usable"], L["Color of the actionbutton when usable."], 3)
general.args.colorGroup.args.notUsableColor = ACH:Color(L["Not Usable"], L["Color of the actionbutton when not usable."], 4)
general.args.colorGroup.args.colorSwipeNormal = ACH:Color(L["Swipe: Normal"], nil, 5, true)
general.args.colorGroup.args.colorSwipeLOC = ACH:Color(L["Swipe: Loss of Control"], nil, 6, true, nil, nil, nil, nil, not E.Retail)
general.args.colorGroup.args.equippedItemColor = ACH:Color(L["Equipped Item Color"], nil, 7)

general.args.applyGroup = ACH:Group(L["Apply To All"], nil, 35)
general.args.applyGroup.args.fontGroup = ACH:Group(L["Font Group"], nil, 1, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB:ApplyTextOption(info[#info], value, true) end)
general.args.applyGroup.args.fontGroup.inline = true
general.args.applyGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
general.args.applyGroup.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
general.args.applyGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

general.args.applyGroup.args.hotkeyTextGroup = ACH:Group(L["Keybind Text"], nil, 2, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB:ApplyTextOption(info[#info], value) end)
general.args.applyGroup.args.hotkeyTextGroup.inline = true
general.args.applyGroup.args.hotkeyTextGroup.args.hotkeyTextPosition = ACH:Select(L["Position"], nil, 4, textAnchors)
general.args.applyGroup.args.hotkeyTextGroup.args.hotkeyTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 })
general.args.applyGroup.args.hotkeyTextGroup.args.hotkeyTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 })

general.args.applyGroup.args.countTextGroup = ACH:Group(L["Count Text"], nil, 3, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB:ApplyTextOption(info[#info], value) end)
general.args.applyGroup.args.countTextGroup.inline = true
general.args.applyGroup.args.countTextGroup.args.countTextPosition = ACH:Select(L["Position"], nil, 4, textAnchors)
general.args.applyGroup.args.countTextGroup.args.countTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 })
general.args.applyGroup.args.countTextGroup.args.countTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 })

general.args.applyGroup.args.macroTextGroup = ACH:Group(L["Macro Text"], nil, 4, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB:ApplyTextOption(info[#info], value) end)
general.args.applyGroup.args.macroTextGroup.inline = true
general.args.applyGroup.args.macroTextGroup.args.macroTextPosition = ACH:Select(L["Position"], nil, 4, textAnchors)
general.args.applyGroup.args.macroTextGroup.args.macroTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 })
general.args.applyGroup.args.macroTextGroup.args.macroTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 })

ActionBar.args.barPet = ACH:Group(L["Pet Bar"], nil, 14, nil, function(info) return E.db.actionbar.barPet[info[#info]] end, function(info, value) E.db.actionbar.barPet[info[#info]] = value; AB:PositionAndSizeBarPet() end, function() return not E.ActionBars.Initialized end)
ActionBar.args.barPet.args = CopyTable(SharedBarOptions)
ActionBar.args.barPet.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.barPet, P.actionbar.barPet); E:ResetMovers('Pet Bar'); AB:PositionAndSizeBarPet() end
ActionBar.args.barPet.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouseover"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.barPet[key] end, function(_, key, value) E.db.actionbar.barPet[key] = value; AB:PositionAndSizeBarPet() end)
ActionBar.args.barPet.args.buttonGroup.args.buttonSize.name = function() return E.db.actionbar.barPet.keepSizeRatio and L["Button Size"] or L["Button Width"] end
ActionBar.args.barPet.args.buttonGroup.args.buttonSize.desc = function() return E.db.actionbar.barPet.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
ActionBar.args.barPet.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.barPet.keepSizeRatio end
ActionBar.args.barPet.args.buttonGroup.args.buttonsPerRow.max = _G.NUM_PET_ACTION_SLOTS
ActionBar.args.barPet.args.buttonGroup.args.buttons.max = _G.NUM_PET_ACTION_SLOTS
ActionBar.args.barPet.args.visibility.set = function(_, value) E.db.actionbar.barPet.visibility = value; AB:PositionAndSizeBarPet() end

ActionBar.args.stanceBar = ACH:Group(L["Stance Bar"], nil, 15, nil, function(info) return E.db.actionbar.stanceBar[info[#info]] end, function(info, value) E.db.actionbar.stanceBar[info[#info]] = value; AB:PositionAndSizeBarShapeShift() end, function() return not E.ActionBars.Initialized end)
ActionBar.args.stanceBar.args = CopyTable(SharedBarOptions)
ActionBar.args.stanceBar.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.stanceBar, P.actionbar.stanceBar); E:ResetMovers('Stance Bar'); AB:PositionAndSizeBarShapeShift() end
ActionBar.args.stanceBar.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouseover"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.stanceBar[key] end, function(_, key, value) E.db.actionbar.stanceBar[key] = value; AB:PositionAndSizeBarShapeShift() end)
ActionBar.args.stanceBar.args.buttonGroup.args.buttonSize.name = function() return E.db.actionbar.stanceBar.keepSizeRatio and L["Button Size"] or L["Button Width"] end
ActionBar.args.stanceBar.args.buttonGroup.args.buttonSize.desc = function() return E.db.actionbar.stanceBar.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
ActionBar.args.stanceBar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.stanceBar.keepSizeRatio end
ActionBar.args.stanceBar.args.buttonGroup.args.buttonsPerRow.max = _G.NUM_STANCE_SLOTS
ActionBar.args.stanceBar.args.buttonGroup.args.buttons.max = _G.NUM_STANCE_SLOTS
ActionBar.args.stanceBar.args.barGroup.args.style = ACH:Select(L["Style"], L["This setting will be updated upon changing stances."], 12, { darkenInactive = L["Darken Inactive"], classic = L["Classic"] }, nil, nil, nil, function(info, value) E.db.actionbar.stanceBar[info[#info]] = value; AB:PositionAndSizeBarShapeShift(); AB:StyleShapeShift() end)
ActionBar.args.stanceBar.args.visibility.set = function(_, value) E.db.actionbar.stanceBar.visibility = value; AB:PositionAndSizeBarShapeShift() end

ActionBar.args.microbar = ACH:Group(L["Micro Bar"], nil, 16, nil, function(info) return E.db.actionbar.microbar[info[#info]] end, function(info, value) E.db.actionbar.microbar[info[#info]] = value; AB:UpdateMicroButtons() end, function() return not E.ActionBars.Initialized end)
ActionBar.args.microbar.args = CopyTable(SharedBarOptions)
ActionBar.args.microbar.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.microbar, P.actionbar.microbar); E:ResetMovers('Micro Bar'); AB:UpdateMicroButtons() end
ActionBar.args.microbar.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouseover"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.microbar[key] end, function(_, key, value) E.db.actionbar.microbar[key] = value; AB:UpdateMicroButtons() end)
ActionBar.args.microbar.args.buttonGroup.args.buttons = nil
ActionBar.args.microbar.args.buttonGroup.args.buttonsPerRow.max = #_G.MICRO_BUTTONS - (E.Retail and 1 or 0)
ActionBar.args.microbar.args.buttonGroup.args.buttonSize.name = function() return E.db.actionbar.microbar.keepSizeRatio and L["Button Size"] or L["Button Width"] end
ActionBar.args.microbar.args.buttonGroup.args.buttonSize.desc = function() return E.db.actionbar.microbar.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
ActionBar.args.microbar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.microbar.keepSizeRatio end
ActionBar.args.microbar.args.visibility.set = function(_, value) E.db.actionbar.microbar.visibility = value; AB:UpdateMicroButtons() end

ActionBar.args.totemBar = ACH:Group(E.NewSign..L["Totem Bar"], nil, 16, nil, function(info) return E.db.actionbar.totemBar[info[#info]] end, function(info, value) E.db.actionbar.totemBar[info[#info]] = value; AB:PositionAndSizeTotemBar() end, function() return not E.ActionBars.Initialized end, not E.Wrath)
ActionBar.args.totemBar.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.actionbar.totemBar[info[#info]] = value; E.ShowPopup = true end)
ActionBar.args.totemBar.args.mouseover = ACH:Toggle(L["Mouseover"], nil, 2)
ActionBar.args.totemBar.args.spacer1 = ACH:Spacer(3, 'full')
ActionBar.args.totemBar.args.spacing = ACH:Range(L["Button Spacing"], nil, 5, { min = 1, max = 10, step = 1 })
ActionBar.args.totemBar.args.buttonSize = ACH:Range(L["Button Size"], nil, 6, { min = 24, max = 60, step = 1 })
ActionBar.args.totemBar.args.alpha = ACH:Range(L["Alpha"], L["Change the alpha level of the frame."], 7, { min = 0, max = 1, step = 0.01, isPercent = true })

ActionBar.args.totemBar.args.visibility = ACH:Input(L["Visibility State"], L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"], 10, nil, 'full')

ActionBar.args.totemBar.args.fontGroup = ACH:Group(L["Font Group"], nil, 15, nil, function(info) return E.db.actionbar.totemBar[info[#info]] end, function(info, value) E.db.actionbar.totemBar[info[#info]] = value AB:UpdateTotemBindings(info[#info], value, true) end)
ActionBar.args.totemBar.args.fontGroup.inline = true
ActionBar.args.totemBar.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
ActionBar.args.totemBar.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
ActionBar.args.totemBar.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

ActionBar.args.totemBar.args.flyoutGroup = ACH:Group("Flyout Options", nil, 20)
ActionBar.args.totemBar.args.flyoutGroup.inline = true
ActionBar.args.totemBar.args.flyoutGroup.args.flyoutSize = ACH:Range("Flyout Size", nil, 1, { min = 24, max = 60, step = 1 })
ActionBar.args.totemBar.args.flyoutGroup.args.flyoutSpacing = ACH:Range("Flyout Spacing", nil, 2, { min = 1, max = 10, step = 1 })
ActionBar.args.totemBar.args.flyoutGroup.args.flyoutDirection = ACH:Select(L["Flyout Direction"], nil, 3, { UP = L["Up"], DOWN = L["Down"] })

--Remove options on bars that don't have those settings.
for _, name in ipairs({'microbar', 'barPet', 'stanceBar'}) do
	local options = E.Options.args.actionbar.args[name].args.barGroup.args

	if name == 'microbar' then
		options.countTextGroup = nil
		options.hotkeyTextGroup = nil
		options.macroTextGroup = nil
	elseif name == 'stanceBar' then
		options.countTextGroup = nil
		options.hotkeyTextGroup.set = function(info, value) E.db.actionbar[info[#info-3]][info[#info]] = value AB:UpdateStanceBindings() end
		options.hotkeyTextGroup.args.hotkeyColor.set = function(info, r, g, b, a) local t = E.db.actionbar[info[#info-3]][info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdateStanceBindings() end
		options.macroTextGroup = nil
	elseif name == 'barPet' then
		options.countTextGroup = nil
		options.hotkeyTextGroup.set = function(info, value) E.db.actionbar[info[#info-3]][info[#info]] = value AB:UpdatePetBindings() end
		options.hotkeyTextGroup.args.hotkeyColor.set = function(info, r, g, b, a) local t = E.db.actionbar[info[#info-3]][info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdatePetBindings() end
		options.macroTextGroup = nil
	end
end

local SharedButtonOptions = {
	alpha = ACH:Range(L["Alpha"], L["Change the alpha level of the frame."], 1, { min = 0, max = 1, step = 0.01, isPercent = true }),
	scale = ACH:Range(L["Scale"], nil, 2, { min = 0.2, max = 2, step = 0.01, isPercent = true }),
	inheritGlobalFade = ACH:Toggle(L["Inherit Global Fade"], nil, 3),
	clean = ACH:Toggle(L["Clean Button"], nil, 4),
}

ActionBar.args.masqueGroup = ACH:Group(L["Masque"], nil, -1, nil, nil, nil, function() return not E.Masque end)
ActionBar.args.masqueGroup.args.masque = ACH:MultiSelect(L["Masque Support"], L["Allow Masque to handle the skinning of this element."], 10, { actionbars = L["ActionBars"], petBar = L["Pet Bar"], stanceBar = L["Stance Bar"] }, nil, nil, function(_, key) return E.private.actionbar.masque[key] end, function(_, key, value) E.private.actionbar.masque[key] = value; E.ShowPopup = true end)

ActionBar.args.extraButtons = ACH:Group(L["Extra Buttons"], nil, 18, nil, nil, nil, function() return not E.ActionBars.Initialized end)
ActionBar.args.extraButtons.args.extraActionButton = ACH:Group(L["Boss Button"], nil, 1, nil, function(info) return E.db.actionbar.extraActionButton[info[#info]] end, function(info, value) local key = info[#info] E.db.actionbar.extraActionButton[key] = value; if key == 'inheritGlobalFade' then AB:ExtraButtons_GlobalFade() elseif key == 'scale' then AB:ExtraButtons_UpdateScale() else AB:ExtraButtons_UpdateAlpha() end end, nil, not E.Retail)
ActionBar.args.extraButtons.args.extraActionButton.inline = true
ActionBar.args.extraButtons.args.extraActionButton.args = CopyTable(SharedButtonOptions)

ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup = ACH:Group(L["Keybind Text"], nil, 40, nil, function(info) return E.db.actionbar[info[#info-2]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-2]][info[#info]] = value AB:UpdateExtraBindings() end)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.inline = true
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.hotkeytext = ACH:Toggle(L["Enable"], L["Display bind names on action buttons."], 0, nil, nil, nil, nil, nil, nil, false)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.useHotkeyColor = ACH:Toggle(L["Custom Color"], nil, 1)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.hotkeyColor = ACH:Color('', nil, 2, nil, nil, function(info) local t = E.db.actionbar[info[#info-2]][info[#info]] local d = P.actionbar[info[#info-2]][info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.actionbar[info[#info-2]][info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdateExtraBindings() end, nil, function(info) return not E.db.actionbar[info[#info-2]].useHotkeyColor or not E.db.actionbar[info[#info-2]].hotkeytext end)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.spacer1 = ACH:Spacer(3, 'full')
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.hotkeyTextPosition = ACH:Select(L["Position"], nil, 4, textAnchors, nil, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.hotkeyTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.hotkeyTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.spacer2 = ACH:Spacer(7, 'full')
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.hotkeyFont = ACH:SharedMediaFont(L["Font"], nil, 8)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.hotkeyFontOutline = ACH:FontFlags(L["Font Outline"], nil, 9)
ActionBar.args.extraButtons.args.extraActionButton.args.hotkeyTextGroup.args.hotkeyFontSize = ACH:Range(L["Font Size"], nil, 10, C.Values.FontSize)

ActionBar.args.extraButtons.args.zoneActionButton = ACH:Group(L["Zone Button"], nil, 2, nil, function(info) return E.db.actionbar.zoneActionButton[info[#info]] end, function(info, value) local key = info[#info] E.db.actionbar.zoneActionButton[key] = value; if key == 'inheritGlobalFade' then AB:ExtraButtons_GlobalFade() elseif key == 'scale' then AB:ExtraButtons_UpdateScale() else AB:ExtraButtons_UpdateAlpha() end end, nil, not E.Retail)
ActionBar.args.extraButtons.args.zoneActionButton.inline = true
ActionBar.args.extraButtons.args.zoneActionButton.args = CopyTable(SharedButtonOptions)

ActionBar.args.extraButtons.args.vehicleExitButton = ACH:Group(L["Vehicle Exit"], nil, 3, nil, function(info) return E.db.actionbar.vehicleExitButton[info[#info]] end, function(info, value) E.db.actionbar.vehicleExitButton[info[#info]] = value; AB:UpdateVehicleLeave() end)
ActionBar.args.extraButtons.args.vehicleExitButton.inline = true
ActionBar.args.extraButtons.args.vehicleExitButton.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.actionbar.vehicleExitButton[info[#info]] = value; E.ShowPopup = true end)
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

	bar.args.barGroup.args.flyoutDirection = ACH:Select(L["Flyout Direction"], nil, 3, { UP = L["Up"], DOWN = L["Down"], LEFT = L["Left"], RIGHT = L["Right"], AUTOMATIC = L["Automatic"] }, nil, nil, nil, function(info, value) E.db.actionbar['bar'..i][info[#info]] = value AB:UpdateButtonSettings('bar'..i) end)

	bar.args.buttonGroup.args.buttonSize.name = function() return E.db.actionbar['bar'..i].keepSizeRatio and L["Button Size"] or L["Button Width"] end
	bar.args.buttonGroup.args.buttonSize.desc = function() return E.db.actionbar['bar'..i].keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
	bar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar['bar'..i].keepSizeRatio end

	bar.args.backdropGroup.hidden = function() return not E.db.actionbar['bar'..i].backdrop end

	bar.args.paging = ACH:Input(L["Action Paging"], L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"], 7, 4, 'full', function() return E.db.actionbar['bar'..i].paging[E.myclass] end, function(_, value) E.db.actionbar['bar'..i].paging[E.myclass] = value AB:UpdateButtonSettings('bar'..i) end)

	bar.args.visibility.set = function(_, value) E.db.actionbar['bar'..i].visibility = value AB:UpdateButtonSettings('bar'..i) end

	for group, func in pairs({ countTextGroup = function() return not E.db.actionbar['bar'..i].counttext end, hotkeyTextGroup = function() return not E.db.actionbar['bar'..i].hotkeytext end, macroTextGroup = function() return not E.db.actionbar['bar'..i].macrotext end}) do
		for _, optionTable in pairs(bar.args.barGroup.args[group].args) do
			if optionTable.hidden == nil then -- This needs to be nil.
				optionTable.hidden = func
			end
		end
	end

	if E.myclass == 'DRUID' and i >= 7 or E.myclass == 'ROGUE' and i == 7 then
		bar.args.enabled.confirm = function() return format(L["Bar %s is used for stance or forms.|N You will have to adjust paging to use this bar.|N Are you sure?"], i) end
	end
end

ActionBar.args.playerBars.args.bar1.args.pagingReset = ACH:Execute(L["Reset Action Paging"], nil, 2, function() E.db.actionbar.bar1.paging[E.myclass] = P.actionbar.bar1.paging[E.myclass] AB:UpdateButtonSettings('bar1') end, nil, L["You are about to reset paging. Are you sure?"])
