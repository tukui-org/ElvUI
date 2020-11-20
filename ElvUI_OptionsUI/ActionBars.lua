local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local AB = E:GetModule('ActionBars')
local ACH = E.Libs.ACH

local _G = _G
local pairs = pairs
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

SharedBarOptions.barGroup.inline = true
SharedBarOptions.barGroup.args.point = ACH:Select(L["Anchor Point"], L["The first button anchors itself to this point on the bar."], 1, { TOPLEFT = 'TOPLEFT', TOPRIGHT = 'TOPRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT' })
SharedBarOptions.barGroup.args.alpha = ACH:Range(L["Alpha"], nil, 2, { min = 0, max = 1, step = 0.01, isPercent = true })
SharedBarOptions.barGroup.args.spacer1 = ACH:Spacer(15, 'full')
SharedBarOptions.barGroup.args.hideHotkey = ACH:Toggle(L["Hide Keybind Text"], nil, 16, nil, nil, nil,
	function(info)
		return E.db.actionbar[info[#info-2]][info[#info]]
	end,
	function(info, value)
		E.db.actionbar[info[#info-2]][info[#info]] = value

		for _, bar in pairs(AB.handledBars) do
			AB:UpdateButtonConfig(bar, bar.bindButtons)
		end
	end
)

SharedBarOptions.barGroup.args.customCountFont = ACH:Toggle(L["Count Font"], nil, 20)
SharedBarOptions.barGroup.args.countTextPosition = ACH:Select(L["Text Anchor"], nil, 21, { BOTTOMRIGHT = 'BOTTOMRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', TOPLEFT = 'TOPLEFT', BOTTOM = 'BOTTOM', TOP = 'TOP' })
SharedBarOptions.barGroup.args.countTextXOffset = ACH:Range(L["X-Offset"], nil, 22, { min = -24, max = 24, step = 1 })
SharedBarOptions.barGroup.args.countTextYOffset = ACH:Range(L["Y-Offset"], nil, 23, { min = -24, max = 24, step = 1 })
SharedBarOptions.barGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 24)
SharedBarOptions.barGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 25)
SharedBarOptions.barGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 26, C.Values.FontSize)
SharedBarOptions.barGroup.args.spacer2 = ACH:Spacer(27, 'full')
SharedBarOptions.barGroup.args.customHotkeyFont = ACH:Toggle(L["Keybind Font"], nil, 40)
SharedBarOptions.barGroup.args.hotkeyTextPosition = ACH:Select(L["Text Anchor"], nil, 41, { BOTTOMRIGHT = 'BOTTOMRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', TOPLEFT = 'TOPLEFT', BOTTOM = 'BOTTOM', TOP = 'TOP' })
SharedBarOptions.barGroup.args.hotkeyTextXOffset = ACH:Range(L["X-Offset"], nil, 42, { min = -24, max = 24, step = 1 })
SharedBarOptions.barGroup.args.hotkeyTextYOffset = ACH:Range(L["Y-Offset"], nil, 43, { min = -24, max = 24, step = 1 })
SharedBarOptions.barGroup.args.hotkeyFont = ACH:SharedMediaFont(L["Font"], nil, 44)
SharedBarOptions.barGroup.args.hotkeyFontOutline = ACH:FontFlags(L["Font Outline"], nil, 45)
SharedBarOptions.barGroup.args.hotkeyFontSize = ACH:Range(L["Font Size"], nil, 46, C.Values.FontSize)

SharedBarOptions.barGroup.args.spacer3 = ACH:Spacer(50, 'full')
SharedBarOptions.barGroup.args.useCountColor = ACH:Toggle(L["Count Text Color"], nil, 51)
SharedBarOptions.barGroup.args.countColor = ACH:Color('', nil, 52, nil, nil,
	function(info)
		local c = E.db.actionbar[info[#info-2]][info[#info]]
		local p = P.actionbar[info[#info-2]][info[#info]]
		return c.r, c.g, c.b, c.a, p.r, p.g, p.b, p.a
	end,
	function(info, r, g, b, a)
		local c = E.db.actionbar[info[#info-2]][info[#info]]
		c.r, c.g, c.b, c.a = r, g, b, a
		AB:UpdateButtonSettings()
	end,
	nil,
	function(info)
		return not E.db.actionbar[info[#info-2]].useCountColor
	end
)
SharedBarOptions.barGroup.args.spacer4 = ACH:Spacer(55, 'full')
SharedBarOptions.barGroup.args.useHotkeyColor = ACH:Toggle(L["Keybind Text Color"], nil, 56)
SharedBarOptions.barGroup.args.hotkeyColor = ACH:Color('', nil, 57, nil, nil,
	function(info)
		local c = E.db.actionbar[info[#info-2]][info[#info]]
		local p = P.actionbar[info[#info-2]][info[#info]]
		return c.r, c.g, c.b, c.a, p.r, p.g, p.b, p.a
	end,
	function(info, r, g, b, a)
		local c = E.db.actionbar[info[#info-2]][info[#info]]
		c.r, c.g, c.b, c.a = r, g, b, a
		AB:UpdateButtonSettings()
	end,
	nil,
	function(info)
		return not E.db.actionbar[info[#info-2]].useHotkeyColor
	end
)
SharedBarOptions.barGroup.args.spacer5 = ACH:Spacer(60, 'full')
SharedBarOptions.barGroup.args.useMacroColor = ACH:Toggle(L["Macro Text Color"], nil, 61)
SharedBarOptions.barGroup.args.macroColor = ACH:Color('', nil, 62, nil, nil,
	function(info)
		local c = E.db.actionbar[info[#info-2]][info[#info]]
		local p = P.actionbar[info[#info-2]][info[#info]]
		return c.r, c.g, c.b, c.a, p.r, p.g, p.b, p.a
	end,
	function(info, r, g, b, a)
		local c = E.db.actionbar[info[#info-2]][info[#info]]
		c.r, c.g, c.b, c.a = r, g, b, a
		AB:UpdateButtonSettings()
	end,
	nil,
	function(info)
		return not E.db.actionbar[info[#info-2]].useMacroColor
	end
)

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

E.Options.args.actionbar = ACH:Group(L["ActionBars"], nil, 2, 'tab', function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end)
E.Options.args.actionbar.args.intro = ACH:Description(L["ACTIONBARS_DESC"], 0)
E.Options.args.actionbar.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function(info) return E.private.actionbar[info[#info]] end, function(info, value) E.private.actionbar[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)

E.Options.args.actionbar.args.general = {
			order = 3,
			type = 'group',
			name = L["General"],
			disabled = function() return not E.ActionBars.Initialized; end,
			args = {
				toggleKeybind = {
					order = 0,
					type = 'execute',
					name = L["Keybind Mode"],
					func = function() AB:ActivateBindMode(); E:ToggleOptionsUI(); GameTooltip:Hide(); end,
				},
				movementModifier = {
					order = 1,
					type = 'select',
					name = L["PICKUP_ACTION_KEY_TEXT"],
					desc = L["The button you must hold down in order to drag an ability to another action button."],
					hidden = function() return not E.db.actionbar.lockActionBars end,
					values = {
						NONE = L["NONE"],
						SHIFT = L["SHIFT_KEY_TEXT"],
						ALT = L["ALT_KEY_TEXT"],
						CTRL = L["CTRL_KEY_TEXT"],
					},
				},
				flyoutSize = {
					order = 2,
					type = 'range',
					name = L["Flyout Button Size"],
					min = 15, max = 60, step = 1,
				},
				globalFadeAlpha = {
					order = 3,
					type = 'range',
					name = L["Global Fade Transparency"],
					desc = L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."],
					min = 0, max = 1, step = 0.01,
					isPercent = true,
					set = function(info, value) E.db.actionbar[info[#info]] = value; AB.fadeParent:SetAlpha(1-value) end,
				},
				generalGroup = {
					order = 20,
					type = 'group',
					name = L["General"],
					inline = true,
					get = function(info) return E.db.actionbar[info[#info]] end,
					set = function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end,
					args = {
						keyDown = {
							order = 13,
							type = 'toggle',
							name = L["Key Down"],
							desc = L["OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN"],
						},
						lockActionBars = {
							order = 14,
							type = 'toggle',
							name = L["LOCK_ACTIONBAR_TEXT"],
							desc = L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."],
							set = function(info, value)
								E.db.actionbar[info[#info]] = value;
								AB:UpdateButtonSettings()

								--Make it work for PetBar too
								SetCVar('lockActionBars', (value == true and 1 or 0))
								LOCK_ACTIONBAR = (value == true and '1' or '0')
							end,
						},
						hideCooldownBling = {
							order = 15,
							type = 'toggle',
							name = L["Hide Cooldown Bling"],
							desc = L["Hides the bling animation on buttons at the end of the global cooldown."],
							get = function() return E.db.actionbar.hideCooldownBling end,
							set = function(_, value) E.db.actionbar.hideCooldownBling = value;
								for _, bar in pairs(AB.handledBars) do
									AB:UpdateButtonConfig(bar, bar.bindButtons)
								end
								AB:UpdatePetCooldownSettings()
							end,
						},
						addNewSpells = {
							order = 16,
							type = 'toggle',
							name = L["Auto Add New Spells"],
							desc = L["Allow newly learned spells to be automatically placed on an empty actionbar slot."],
							set = function(_, value) E.db.actionbar.addNewSpells = value; AB:IconIntroTracker_Toggle() end,
						},
						rightClickSelfCast = {
							order = 17,
							type = 'toggle',
							name = L["RightClick Self-Cast"],
							set = function(_, value)
								E.db.actionbar.rightClickSelfCast = value;
								for _, bar in pairs(AB.handledBars) do
									AB:UpdateButtonConfig(bar, bar.bindButtons)
								end
							end,
						},
						useDrawSwipeOnCharges = {
							order = 18,
							type = 'toggle',
							name = L["Charge Draw Swipe"],
							desc = L["Shows a swipe animation when a spell is recharging but still has charges left."],
							get = function() return E.db.actionbar.useDrawSwipeOnCharges end,
							set = function(_, value)
								E.db.actionbar.useDrawSwipeOnCharges = value;
								for _, bar in pairs(AB.handledBars) do
									AB:UpdateButtonConfig(bar, bar.bindButtons)
								end
							end,
						},
						chargeCooldown = {
							order = 19,
							type = 'toggle',
							name = L["Charge Cooldown Text"],
							set = function(_, value)
								E.db.actionbar.chargeCooldown = value;
								AB:ToggleCooldownOptions()
							end,
						},
						desaturateOnCooldown = {
							order = 20,
							type = 'toggle',
							name = L["Desaturate Cooldowns"],
							set = function(_, value)
								E.db.actionbar.desaturateOnCooldown = value;
								AB:ToggleCooldownOptions()
							end,
						},
						transparent = {
							order = 21,
							type = 'toggle',
							name = L["Transparent"],
							set = function(_, value)
								E.db.actionbar.transparent = value
								E:StaticPopup_Show('PRIVATE_RL')
							end,
						},
						flashAnimation = {
							order = 22,
							type = 'toggle',
							name = L["Button Flash"],
							desc = L["Use a more visible flash animation for Auto Attacks."],
							set = function(_, value)
								E.db.actionbar.flashAnimation = value
								E:StaticPopup_Show('PRIVATE_RL')
							end,
						},
						equippedItem = {
							order = 23,
							type = 'toggle',
							name = L["Equipped Item"],
						},
						macrotext = {
							order = 24,
							type = 'toggle',
							name = L["Macro Text"],
							desc = L["Display macro names on action buttons."],
						},
						hotkeytext = {
							order = 25,
							type = 'toggle',
							name = L["Keybind Text"],
							desc = L["Display bind names on action buttons."],
						},
						useRangeColorText = {
							order = 26,
							type = 'toggle',
							name = L["Color Keybind Text"],
							desc = L["Color Keybind Text when Out of Range, instead of the button."],
						},
						handleOverlay = {
							order = 27,
							type = 'toggle',
							name = L["Action Button Glow"],
						},
					}
				},
				textGroup = {
					type = 'group',
					order = 50,
					name = L["Text Position"],
					disabled = function() return (E.Masque and E.private.actionbar.masque.actionbars) end,
					inline = true,
					args = {
						countTextPosition = {
							type = 'select',
							order = 1,
							name = L["Stack Text Position"],
							values = {
								BOTTOMRIGHT = 'BOTTOMRIGHT',
								BOTTOMLEFT = 'BOTTOMLEFT',
								TOPRIGHT = 'TOPRIGHT',
								TOPLEFT = 'TOPLEFT',
								BOTTOM = 'BOTTOM',
								TOP = 'TOP',
							},
						},
						countTextXOffset = {
							type = 'range',
							order = 2,
							name = L["Stack Text X-Offset"],
							min = -24, max = 24, step = 1,
						},
						countTextYOffset = {
							type = 'range',
							order = 3,
							name = L["Stack Text Y-Offset"],
							min = -24, max = 24, step = 1,
						},
						spacer1 = ACH:Spacer(5, 'full'),
						hotkeyTextPosition = {
							type = 'select',
							order = 10,
							name = L["Keybind Text Position"],
							values = {
								BOTTOMRIGHT = 'BOTTOMRIGHT',
								BOTTOMLEFT = 'BOTTOMLEFT',
								TOPRIGHT = 'TOPRIGHT',
								TOPLEFT = 'TOPLEFT',
								BOTTOM = 'BOTTOM',
								TOP = 'TOP',
							},
						},
						hotkeyTextXOffset = {
							type = 'range',
							order = 11,
							name = L["Keybind Text X-Offset"],
							min = -24, max = 24, step = 1,
						},
						hotkeyTextYOffset = {
							type = 'range',
							order = 12,
							name = L["Keybind Text Y-Offset"],
							min = -24, max = 24, step = 1,
						},
					},
				},
			},
		}

E.Options.args.actionbar.args.general.args.colorGroup = ACH:Group(L["COLORS"], nil, 30, nil, function(info) local t = E.db.actionbar[info[#info]] local d = P.actionbar[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.actionbar[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a AB:UpdateButtonSettings() end, function() return (E.Masque and E.private.actionbar.masque.actionbars) end)
E.Options.args.actionbar.args.general.args.colorGroup.inline = true
E.Options.args.actionbar.args.general.args.colorGroup.args.fontColor = ACH:Color(L["Text"], nil, 0)
E.Options.args.actionbar.args.general.args.colorGroup.args.noRangeColor = ACH:Color(L["Out of Range"], L["Color of the actionbutton when out of range."], 1)
E.Options.args.actionbar.args.general.args.colorGroup.args.noPowerColor = ACH:Color(L["Out of Power"], L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."], 2)
E.Options.args.actionbar.args.general.args.colorGroup.args.usableColor = ACH:Color(L["Usable"], L["Color of the actionbutton when usable."], 3)
E.Options.args.actionbar.args.general.args.colorGroup.args.notUsableColor = ACH:Color(L["Not Usable"], L["Color of the actionbutton when not usable."], 4)
E.Options.args.actionbar.args.general.args.colorGroup.args.colorSwipeNormal = ACH:Color(L["Swipe: Normal"], nil, 5, true)
E.Options.args.actionbar.args.general.args.colorGroup.args.colorSwipeLOC = ACH:Color(L["Swipe: Loss of Control"], nil, 6, true)
E.Options.args.actionbar.args.general.args.colorGroup.args.equippedItemColor = ACH:Color(L["Equipped Item Color"], nil, 7)

E.Options.args.actionbar.args.general.args.fontGroup = ACH:Group(L["Fonts"], nil, 40)
E.Options.args.actionbar.args.general.args.fontGroup.inline = true
E.Options.args.actionbar.args.general.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
E.Options.args.actionbar.args.general.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
E.Options.args.actionbar.args.general.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

E.Options.args.actionbar.args.general.args.masqueGroup = ACH:Group(L["Masque Support"], nil, -1, nil, function(info) return E.private.actionbar.masque[info[#info]] end, function(info, value) E.private.actionbar.masque[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end, function() return not E.Masque end)
E.Options.args.actionbar.args.general.args.masqueGroup.inline = true
E.Options.args.actionbar.args.general.args.masqueGroup.args.actionbars = ACH:Toggle(L["ActionBars"], nil, 1)
E.Options.args.actionbar.args.general.args.masqueGroup.args.petBar = ACH:Toggle(L["Pet Bar"], nil, 2)
E.Options.args.actionbar.args.general.args.masqueGroup.args.stanceBar = ACH:Toggle(L["Stance Bar"], nil, 3)

E.Options.args.actionbar.args.barPet = ACH:Group(L["Pet Bar"], nil, 14, nil, function(info) return E.db.actionbar.barPet[info[#info]] end, function(info, value) E.db.actionbar.barPet[info[#info]] = value; AB:PositionAndSizeBarPet() end, function() return not E.ActionBars.Initialized end)
E.Options.args.actionbar.args.barPet.args = CopyTable(SharedBarOptions)
E.Options.args.actionbar.args.barPet.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.barPet, P.actionbar.barPet); E:ResetMovers('Pet Bar'); AB:PositionAndSizeBarPet() end
E.Options.args.actionbar.args.barPet.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouse Over"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.barPet[key] end, function(_, key, value) E.db.actionbar.barPet[key] = value; AB:PositionAndSizeBarPet() end)
E.Options.args.actionbar.args.barPet.args.buttonGroup.args.buttonsize.name = function() return E.db.actionbar.barPet.keepSizeRatio and L["Button Size"] or L["Button Width"] end
E.Options.args.actionbar.args.barPet.args.buttonGroup.args.buttonsize.desc = function() return E.db.actionbar.barPet.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
E.Options.args.actionbar.args.barPet.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.barPet.keepSizeRatio end
E.Options.args.actionbar.args.barPet.args.buttonGroup.args.buttonsPerRow.max = NUM_PET_ACTION_SLOTS
E.Options.args.actionbar.args.barPet.args.buttonGroup.args.buttons.max = NUM_PET_ACTION_SLOTS
E.Options.args.actionbar.args.barPet.args.visibility.set = function(_, value) if value and value:match('[\n\r]') then value = value:gsub('[\n\r]','') end E.db.actionbar.barPet.visibility = value; AB:UpdateButtonSettings() end

E.Options.args.actionbar.args.stanceBar = ACH:Group(L["Stance Bar"], nil, 15, nil, function(info) return E.db.actionbar.stanceBar[info[#info]] end, function(info, value) E.db.actionbar.stanceBar[info[#info]] = value; AB:PositionAndSizeBarShapeShift() end, function() return not E.ActionBars.Initialized end)
E.Options.args.actionbar.args.stanceBar.args = CopyTable(SharedBarOptions)
E.Options.args.actionbar.args.stanceBar.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.stanceBar, P.actionbar.stanceBar); E:ResetMovers('Stance Bar'); AB:PositionAndSizeBarShapeShift() end
E.Options.args.actionbar.args.stanceBar.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouse Over"], clickThrough = L["Click Through"], inheritGlobalFade = L["Inherit Global Fade"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.stanceBar[key] end, function(_, key, value) E.db.actionbar.stanceBar[key] = value; AB:PositionAndSizeBarShapeShift() end)
E.Options.args.actionbar.args.stanceBar.args.buttonGroup.args.buttonsize.name = function() return E.db.actionbar.stanceBar.keepSizeRatio and L["Button Size"] or L["Button Width"] end
E.Options.args.actionbar.args.stanceBar.args.buttonGroup.args.buttonsize.desc = function() return E.db.actionbar.stanceBar.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
E.Options.args.actionbar.args.stanceBar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.stanceBar.keepSizeRatio end
E.Options.args.actionbar.args.stanceBar.args.buttonGroup.args.buttonsPerRow.max = NUM_STANCE_SLOTS
E.Options.args.actionbar.args.stanceBar.args.buttonGroup.args.buttons.max = NUM_STANCE_SLOTS
E.Options.args.actionbar.args.stanceBar.args.barGroup.args.style = ACH:Select(L["Style"], L["This setting will be updated upon changing stances."], 12, { darkenInactive = L["Darken Inactive"], classic = L["Classic"] })
E.Options.args.actionbar.args.stanceBar.args.visibility.set = function(_, value) if value and value:match('[\n\r]') then value = value:gsub('[\n\r]','') end E.db.actionbar.stanceBar.visibility = value; AB:UpdateButtonSettings() end

E.Options.args.actionbar.args.microbar = ACH:Group(L["Micro Bar"], nil, 16, nil, function(info) return E.db.actionbar.microbar[info[#info]] end, function(info, value) E.db.actionbar.microbar[info[#info]] = value; AB:UpdateMicroPositionDimensions() end, function() return not E.ActionBars.Initialized end)
E.Options.args.actionbar.args.microbar.args = CopyTable(SharedBarOptions)
E.Options.args.actionbar.args.microbar.args.restorePosition.func = function() E:CopyTable(E.db.actionbar.microbar, P.actionbar.microbar); E:ResetMovers('Micro Bar'); AB:UpdateMicroPositionDimensions() end
E.Options.args.actionbar.args.microbar.args.generalOptions = ACH:MultiSelect('', nil, 3, { backdrop = L["Backdrop"], mouseover = L["Mouse Over"], keepSizeRatio = L["Keep Size Ratio"] }, nil, nil, function(_, key) return E.db.actionbar.microbar[key] end, function(_, key, value) E.db.actionbar.microbar[key] = value; AB:UpdateMicroPositionDimensions() end)
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttons = nil
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonSize = CopyTable(E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonsize)
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonsize = nil
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonSpacing = CopyTable(E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonspacing)
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonspacing = nil
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonsPerRow.max = #MICRO_BUTTONS-1
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonSize.name = function() return E.db.actionbar.microbar.keepSizeRatio and L["Button Size"] or L["Button Width"] end
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonSize.desc = function() return E.db.actionbar.microbar.keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
E.Options.args.actionbar.args.microbar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar.microbar.keepSizeRatio end
E.Options.args.actionbar.args.microbar.args.visibility.set = function(_, value) if value and value:match('[\n\r]') then value = value:gsub('[\n\r]','') end E.db.actionbar.microbar.visibility = value; AB:UpdateMicroPositionDimensions() end

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
		options.hideHotkey.set = function(info, value)
			E.db.actionbar[info[#info-2]][info[#info]] = value
			AB:UpdateStanceBindings()
		end
	elseif name == 'barPet' then
		options.hideHotkey.set = function(info, value)
			E.db.actionbar[info[#info-2]][info[#info]] = value
			AB:UpdatePetBindings()
		end
	end
end


local SharedButtonOptions = {
	alpha = ACH:Range(L["Alpha"], L["Change the alpha level of the frame."], 1, { min = 0, max = 1, step = 0.01, isPercent = true }),
	scale = ACH:Range(L["Scale"], nil, 2, { min = 0.2, max = 2, step = 0.01, isPercent = true }),
	inheritGlobalFade = ACH:Toggle(L["Inherit Global Fade"], nil, 3),
	clean = ACH:Toggle(L["Clean Button"], nil, 4),
}

E.Options.args.actionbar.args.extraButtons = ACH:Group(L["Extra Buttons"], nil, 18, nil, nil, nil, function() return not E.ActionBars.Initialized end)

E.Options.args.actionbar.args.extraButtons.args.extraActionButton = ACH:Group(L["Boss Button"], nil, 1, nil, function(info) return E.db.actionbar.extraActionButton[info[#info]] end, function(info, value) local key = info[#info] E.db.actionbar.extraActionButton[key] = value; if key == 'inheritGlobalFade' then AB:ExtraButtons_GlobalFade() elseif key == 'scale' then AB:ExtraButtons_UpdateScale() else AB:ExtraButtons_UpdateAlpha() end end)
E.Options.args.actionbar.args.extraButtons.args.extraActionButton.inline = true
E.Options.args.actionbar.args.extraButtons.args.extraActionButton.args = CopyTable(SharedButtonOptions)

E.Options.args.actionbar.args.extraButtons.args.zoneButton = ACH:Group(L["Zone Button"], nil, 2, nil, function(info) return E.db.actionbar.zoneActionButton[info[#info]] end, function(info, value) local key = info[#info] E.db.actionbar.zoneActionButton[key] = value; if key == 'inheritGlobalFade' then AB:ExtraButtons_GlobalFade() elseif key == 'scale' then AB:ExtraButtons_UpdateScale() else AB:ExtraButtons_UpdateAlpha() end end)
E.Options.args.actionbar.args.extraButtons.args.zoneButton.inline = true
E.Options.args.actionbar.args.extraButtons.args.zoneButton.args = CopyTable(SharedButtonOptions)

E.Options.args.actionbar.args.extraButtons.args.vehicleExitButton = ACH:Group(L["Vehicle Exit"], nil, 3, nil, function(info) return E.db.actionbar.vehicleExitButton[info[#info]] end, function(info, value) E.db.actionbar.vehicleExitButton[info[#info]] = value; AB:UpdateVehicleLeave() end)
E.Options.args.actionbar.args.extraButtons.args.vehicleExitButton.inline = true
E.Options.args.actionbar.args.extraButtons.args.vehicleExitButton.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.actionbar.vehicleExitButton[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.actionbar.args.extraButtons.args.vehicleExitButton.args.size = ACH:Range(L["Size"], nil, 2, { min = 16, max = 50, step = 1 })
E.Options.args.actionbar.args.extraButtons.args.vehicleExitButton.args.strata = ACH:Select(L["Frame Strata"], nil, 3, { BACKGROUND = 'BACKGROUND', LOW = 'LOW', MEDIUM = 'MEDIUM', HIGH = 'HIGH' })
E.Options.args.actionbar.args.extraButtons.args.vehicleExitButton.args.level = ACH:Range(L["Frame Level"], nil, 4, { min = 1, max = 128, step = 1 })

E.Options.args.actionbar.args.playerBars = ACH:Group(L["Player Bars"], nil, 4, 'tree', nil, nil, function() return not E.ActionBars.Initialized end)

for i = 1, 10 do
	local bar = ACH:Group(L["Bar "]..i, nil, i, 'group', function(info) return E.db.actionbar['bar'..i][info[#info]] end, function(info, value) E.db.actionbar['bar'..i][info[#info]] = value; AB:PositionAndSizeBar('bar'..i) end)

	E.Options.args.actionbar.args.playerBars.args['bar'..i] = bar
	bar.args = CopyTable(SharedBarOptions)

	bar.args.enabled.set = function(info, value) E.db.actionbar['bar'..i][info[#info]] = value AB:PositionAndSizeBar('bar'..i) end
	bar.args.restorePosition.func = function() E:CopyTable(E.db.actionbar['bar'..i], P.actionbar['bar'..i]) E:ResetMovers('Bar '..i) AB:PositionAndSizeBar('bar'..i) end

	bar.args.generalOptions.get = function(_, key) return E.db.actionbar['bar'..i][key] end
	bar.args.generalOptions.set = function(_, key, value) E.db.actionbar['bar'..i][key] = value AB:PositionAndSizeBar('bar'..i) AB:UpdateButtonSettingsForBar('bar'..i) end
	bar.args.generalOptions.values.showGrid = L["Show Empty Buttons"]
	bar.args.generalOptions.values.keepSizeRatio = L["Keep Size Ratio"]

	bar.args.barGroup.args.flyoutDirection = ACH:Select(L["Flyout Direction"], nil, 2, { UP = L["Up"], DOWN = L["Down"], LEFT = L["Left"], RIGHT = L["Right"], AUTOMATIC = L["Automatic"] }, nil, nil, nil, function(info, value) E.db.actionbar['bar'..i][info[#info]] = value AB:PositionAndSizeBar('bar'..i) AB:UpdateButtonSettingsForBar('bar'..i) end)

	bar.args.buttonGroup.args.buttonsize.name = function() return E.db.actionbar['bar'..i].keepSizeRatio and L["Button Size"] or L["Button Width"] end
	bar.args.buttonGroup.args.buttonsize.desc = function() return E.db.actionbar['bar'..i].keepSizeRatio and L["The size of the action buttons."] or L["The width of the action buttons."] end
	bar.args.buttonGroup.args.buttonHeight.hidden = function() return E.db.actionbar['bar'..i].keepSizeRatio end

	bar.args.backdropGroup.hidden = function() return not E.db.actionbar['bar'..i].backdrop end

	bar.args.paging = ACH:Input(L["Action Paging"], L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"], 7, 4, 'full', function() return E.db.actionbar['bar'..i].paging[E.myclass] end, function(_, value) if value and value:match('[\n\r]') then value = value:gsub('[\n\r]','') end E.db.actionbar['bar'..i].paging[E.myclass] = value AB:UpdateButtonSettings() end)

	bar.args.visibility.set = function(_, value) if value and value:match('[\n\r]') then value = value:gsub('[\n\r]','') end E.db.actionbar['bar'..i].visibility = value AB:UpdateButtonSettings() end

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

E.Options.args.actionbar.args.playerBars.args.bar1.args.pagingReset = ACH:Execute(L["Reset Action Paging"], nil, 2, function() E.db.actionbar.bar1.paging[E.myclass] = P.actionbar.bar1.paging[E.myclass] AB:UpdateButtonSettings() end, nil, L["You are about to reset paging. Are you sure?"])
E.Options.args.actionbar.args.playerBars.args.bar6.args.enabled.set = function(_, value) E.db.actionbar.bar6.enabled = value; AB:PositionAndSizeBar('bar6') AB:UpdateBar1Paging() AB:PositionAndSizeBar('bar1') end
