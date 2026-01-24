local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local AB = E:GetModule('ActionBars')
local ACH = E.Libs.ACH

local _G = _G
local pairs = pairs
local ipairs = ipairs
local format = format

local CopyTable = CopyTable
local GameTooltip = GameTooltip
local GetModifiedClick = GetModifiedClick
local SetModifiedClick = SetModifiedClick
local GetCurrentBindingSet = GetCurrentBindingSet
local SaveBindings = SaveBindings

local GetCVarBool = C_CVar.GetCVarBool

local MICRO_SLOTS = 12
local STANCE_SLOTS = _G.NUM_STANCE_SLOTS or 10
local ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS or 10

local SharedBarOptions = {
	enabled = ACH:Toggle(L["Enable"], nil, 0),
	restorePosition = ACH:Execute(L["Restore Bar"], L["Restore the actionbars default settings"], 1),
	generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouseover"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"] }),
	buttonGroup = ACH:Group(L["Button Settings"], nil, 4),
	backdropGroup = ACH:Group(L["Backdrop Settings"], nil, 5),
	barGroup = ACH:Group(L["Bar Settings"], nil, 6),
	strataAndLevel = ACH:Group(L["Strata and Level"], nil, 7),
	visibilityGroup = ACH:Group(L["Visibility State"], nil, 8),
	pagingGroup = ACH:Group(L["Action Paging"], nil, 9)
}

SharedBarOptions.pagingGroup.args.defaults = ACH:Execute(L["Restore Defaults"], nil, 1, nil, nil, L["You are about to reset paging. Are you sure?"])
SharedBarOptions.pagingGroup.args.paging = ACH:Input('', L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"], 2, 4, 'full')

SharedBarOptions.visibilityGroup.args.defaults = ACH:Execute(L["Restore Defaults"], nil, 1, nil, nil, true)
SharedBarOptions.visibilityGroup.args.visibility = ACH:Input('', L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"], 2, 4, 'full')

local castKeyValues = { NONE = L["None"], SHIFT = L["SHIFT_KEY_TEXT"], CTRL = L["CTRL_KEY_TEXT"], ALT = L["ALT_KEY_TEXT"] }

local getTextColor = function(info) local t = E.db.actionbar[info[#info-2]][info[#info]] local d = P.actionbar[info[#info-2]][info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
local setTextColor = function(info, r, g, b, a) local t = E.db.actionbar[info[#info-2]][info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdateButtonSettings(info[#info-2]) end

SharedBarOptions.buttonGroup.inline = true
SharedBarOptions.buttonGroup.args.buttons = ACH:Range(L["Buttons"], L["The amount of buttons to display."], 1, { min = 1, max = _G.NUM_ACTIONBAR_BUTTONS, step = 1 })
SharedBarOptions.buttonGroup.args.buttonsPerRow = ACH:Range(L["Buttons Per Row"], L["The amount of buttons to display per row."], 2, { min = 1, max = _G.NUM_ACTIONBAR_BUTTONS, step = 1 })
SharedBarOptions.buttonGroup.args.buttonSpacing = ACH:Range(L["Button Spacing"], L["The spacing between buttons."], 3, { min = -3, max = 20, step = 1 })
SharedBarOptions.buttonGroup.args.buttonSize = ACH:Range('', nil, 4, { softMin = 14, softMax = 64, min = 12, max = 128, step = 1 })
SharedBarOptions.buttonGroup.args.buttonHeight = ACH:Range(L["Button Height"], L["The height of the action buttons."], 5, { softMin = 14, softMax = 64, min = 12, max = 128, step = 1 })

SharedBarOptions.barGroup.inline = true
SharedBarOptions.barGroup.args.point = ACH:Select(L["Anchor Point"], L["The first button anchors itself to this point on the bar."], 1, { TOPLEFT = L["TOPLEFT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMLEFT = L["BOTTOMLEFT"], BOTTOMRIGHT = L["BOTTOMRIGHT"] })
SharedBarOptions.barGroup.args.alpha = ACH:Range(L["Alpha"], nil, 2, { min = 0, max = 1, step = 0.01, isPercent = true })

SharedBarOptions.strataAndLevel.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 3, { BACKGROUND = L["BACKGROUND"], LOW = L["LOW"], MEDIUM = L["MEDIUM"], HIGH = L["HIGH"] })
SharedBarOptions.strataAndLevel.args.frameLevel = ACH:Range(L["Frame Level"], nil, 4, { min = 1, max = 256, step = 1 })

local hotkeyTextGroup = ACH:Group(L["Keybind Text"], nil, 40, nil, function(info) return E.db.actionbar[info[#info-2]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-2]][info[#info]] = value AB:UpdateButtonSettings(info[#info-2]) end)
hotkeyTextGroup.args.hotkeytext = ACH:Toggle(L["Enable"], L["Display bind names on action buttons."], 0, nil, nil, nil, nil, nil, nil, false)
hotkeyTextGroup.args.useHotkeyColor = ACH:Toggle(L["Custom Color"], nil, 1)
hotkeyTextGroup.args.hotkeyColor = ACH:Color('', nil, 2, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-2]].useHotkeyColor or not E.db.actionbar[info[#info-2]].hotkeytext end)
hotkeyTextGroup.args.spacer1 = ACH:Spacer(3, 'full')
hotkeyTextGroup.args.hotkeyTextPosition = ACH:Select(L["Position"], nil, 4, C.Values.TextPositions, nil, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
hotkeyTextGroup.args.hotkeyTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
hotkeyTextGroup.args.hotkeyTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
hotkeyTextGroup.args.spacer2 = ACH:Spacer(7, 'full')
hotkeyTextGroup.args.hotkeyFont = ACH:SharedMediaFont(L["Font"], nil, 8)
hotkeyTextGroup.args.hotkeyFontOutline = ACH:FontFlags(L["Font Outline"], nil, 9)
hotkeyTextGroup.args.hotkeyFontSize = ACH:Range(L["Font Size"], nil, 10, C.Values.FontSize)
SharedBarOptions.hotkeyTextGroup = hotkeyTextGroup

local countTextGroup = ACH:Group(L["Count Text"], nil, 50, nil, function(info) return E.db.actionbar[info[#info-2]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-2]][info[#info]] = value AB:UpdateButtonSettings(info[#info-2]) end)
countTextGroup.args.counttext = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, nil, nil, false)
countTextGroup.args.useCountColor = ACH:Toggle(L["Custom Color"], nil, 1)
countTextGroup.args.countColor = ACH:Color('', nil, 2, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-2]].useCountColor or not E.db.actionbar[info[#info-2]].counttext end)
countTextGroup.args.spacer1 = ACH:Spacer(3, 'full')
countTextGroup.args.countTextPosition = ACH:Select(L["Position"], nil, 4, C.Values.TextPositions, nil, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
countTextGroup.args.countTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
countTextGroup.args.countTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
countTextGroup.args.spacer2 = ACH:Spacer(7, 'full')
countTextGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 8)
countTextGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 9)
countTextGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 10, C.Values.FontSize)
SharedBarOptions.countTextGroup = countTextGroup

local macroTextGroup = ACH:Group(L["Macro Text"], nil, 60, nil, function(info) return E.db.actionbar[info[#info-2]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-2]][info[#info]] = value AB:UpdateButtonSettings(info[#info-2]) end)
macroTextGroup.args.macrotext = ACH:Toggle(L["Enable"], L["Display macro names on action buttons."], 0, nil, nil, nil, nil, nil, nil, false)
macroTextGroup.args.useMacroColor = ACH:Toggle(L["Custom Color"], nil, 1)
macroTextGroup.args.macroColor = ACH:Color('', nil, 2, nil, nil, getTextColor, setTextColor, nil, function(info) return not E.db.actionbar[info[#info-2]].useMacroColor or not E.db.actionbar[info[#info-2]].macrotext end)
macroTextGroup.args.spacer1 = ACH:Spacer(3, 'full')
macroTextGroup.args.macroTextPosition = ACH:Select(L["Position"], nil, 4, C.Values.TextPositions, nil, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
macroTextGroup.args.macroTextXOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
macroTextGroup.args.macroTextYOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -24, max = 24, step = 1 }, nil, nil, nil, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
macroTextGroup.args.spacer2 = ACH:Spacer(7, 'full')
macroTextGroup.args.macroFont = ACH:SharedMediaFont(L["Font"], nil, 8)
macroTextGroup.args.macroFontSize = ACH:Range(L["Font Size"], nil, 9, C.Values.FontSize)
macroTextGroup.args.macroFontOutline = ACH:FontFlags(L["Font Outline"], nil, 10)
SharedBarOptions.macroTextGroup = macroTextGroup

local professionQuality = ACH:Group(L["Profession Quality"], nil, 70, nil, function(info) return E.db.actionbar[info[#info-2]].professionQuality[info[#info]] end, function(info, value) E.db.actionbar[info[#info-2]].professionQuality[info[#info]] = value AB:UpdateButtonSettings(info[#info-2]) end, nil, not E.Retail)
professionQuality.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, nil, nil, false)
professionQuality.args.spacer1 = ACH:Spacer(3, 'full')
professionQuality.args.alpha = ACH:Range(L["Alpha"], L["Change the alpha level of the frame."], 1, { min = 0, max = 1, step = 0.01, isPercent = true })
professionQuality.args.scale = ACH:Range(L["Scale"], nil, 2, { min = 0.1, max = 2, step = 0.01, isPercent = true })
professionQuality.args.point = ACH:Select(L["Position"], nil, 3, C.Values.TextPositions)
professionQuality.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -24, max = 24, step = 1 })
professionQuality.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -24, max = 24, step = 1 })
SharedBarOptions.professionQuality = professionQuality

SharedBarOptions.backdropGroup.args.backdropSpacing = ACH:Range(L["Backdrop Spacing"], L["The spacing between the backdrop and the buttons."], 1, { min = 0, max = 10, step = 1 })
SharedBarOptions.backdropGroup.args.heightMult = ACH:Range(L["Height Multiplier"], L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."], 2, { min = 1, max = 5, step = 1 })
SharedBarOptions.backdropGroup.args.widthMult = ACH:Range(L["Width Multiplier"], L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."], 2, { min = 1, max = 5, step = 1 })

-- Start ActionBar Config
local ActionBar = ACH:Group(L["ActionBars"], nil, 2, 'tab', function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() end)
E.Options.args.actionbar = ActionBar

ActionBar.args.intro = ACH:Description(L["ACTIONBARS_DESC"], 0)
ActionBar.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function(info) return E.private.actionbar[info[#info]] end, function(info, value) E.private.actionbar[info[#info]] = value E.ShowPopup = true end)
ActionBar.args.toggleKeybind = ACH:Execute(L["Keybind Mode"], nil, 2, function() AB:ActivateBindMode() E:ToggleOptions() GameTooltip:Hide() end, nil, nil, 160)
ActionBar.args.cooldownShortcut = ACH:Execute(L["Cooldown Text"], nil, 3, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'cooldown', 'actionbar') end, nil, nil, 160)

local generalGroup = ACH:Group(L["General"], nil, 3, nil, nil, nil, function() return not E.ActionBars.Initialized end)
ActionBar.args.general = generalGroup
generalGroup.args.movementModifier = ACH:Select(L["PICKUP_ACTION_KEY_TEXT"], L["The button you must hold down in order to drag an ability to another action button."], 1, { NONE = L["None"], SHIFT = L["SHIFT_KEY_TEXT"], ALT = L["ALT_KEY_TEXT"], CTRL = L["CTRL_KEY_TEXT"] }, nil, nil, nil, nil, nil, function() return not E.db.actionbar.lockActionBars end)
generalGroup.args.flyoutSize = ACH:Range(L["Flyout Button Size"], nil, 2, { min = 15, max = 60, step = 1 })
generalGroup.args.globalFadeAlpha = ACH:Range(L["Global Fade Transparency"], L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."], 3, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB.fadeParent:SetAlpha(1-value) end)
generalGroup.args.customGlowShortcut = ACH:Execute(L["Custom Glow"], nil, 4, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'general', 'cosmetic') end)

generalGroup.args.generalOptions = ACH:Group(L["General"], nil, 20, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() end)
generalGroup.args.generalOptions.inline = true
generalGroup.args.generalOptions.args.keyDown = ACH:Toggle(L["Key Down"], L["OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN"], 1, nil, nil, nil, function() return GetCVarBool('ActionButtonUseKeyDown') end, function(_, value) E:SetCVar('ActionButtonUseKeyDown', value and 1 or 0) AB:UpdateButtonSettings() end)
generalGroup.args.generalOptions.args.lockActionBars = ACH:Toggle(L["LOCK_ACTIONBAR_TEXT"], L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."], 2, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value E:SetCVar('lockActionBars', value and 1 or 0) _G.LOCK_ACTIONBAR = (value and '1' or '0') AB:UpdateButtonSettings() end)
generalGroup.args.generalOptions.args.addNewSpells = ACH:Toggle(L["Auto Add New Spells"], L["Allow newly learned spells to be automatically placed on an empty actionbar slot."], 4, nil, nil, nil, function() return GetCVarBool('AutoPushSpellToActionBar') end, function(_, value) E:SetCVar('AutoPushSpellToActionBar', value and 1 or 0) end, nil, not E.Retail)
generalGroup.args.generalOptions.args.desaturateOnCooldown = ACH:Toggle(L["Desaturate Cooldowns"], nil, 11, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value AB:ToggleCooldownOptions() end)
generalGroup.args.generalOptions.args.transparent = ACH:Toggle(L["Transparent"], nil, 12, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value E.ShowPopup = true end)
generalGroup.args.generalOptions.args.flashAnimation = ACH:Toggle(L["Button Flash"], L["Use a more visible flash animation for Auto Attacks."], 13, nil, nil, nil, nil, function(info, value) E.db.actionbar[info[#info]] = value E.ShowPopup = true end)
generalGroup.args.generalOptions.args.equippedItem = ACH:Toggle(L["Equipped Item"], nil, 14)
generalGroup.args.generalOptions.args.useRangeColorText = ACH:Toggle(L["Color Keybind Text"], L["Color Keybind Text when Out of Range, instead of the button."], 15)
generalGroup.args.generalOptions.args.handleOverlay = ACH:Toggle(L["Action Button Glow"], nil, 16)

-- MIDNIGHT API OPTIONS GROUP
generalGroup.args.midnight = {
	order = 50,
	type = 'group',
	name = L["Midnight API"],
	inline = true,
	args = {
		enableSafeGlow = ACH:Toggle(L["Safe Button Glow"], L["Only glow buttons for non-SECRET auras."], 1, nil, nil, nil, function() return E.db.actionbar.midnight.enableSafeGlow end, function(_, value) E.db.actionbar.midnight.enableSafeGlow = value AB:UpdateButtonSettings() end),
		skipSecretBuffs = ACH:Toggle(L["Skip Secret Buffs"], L["Skip SECRET-flagged buffs when checking player buffs."], 2, nil, nil, nil, function() return E.db.actionbar.midnight.skipSecretBuffs end, function(_, value) E.db.actionbar.midnight.skipSecretBuffs = value end),
	}
}
