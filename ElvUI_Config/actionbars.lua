local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')
local group

local _G = _G
local pairs = pairs
local SetCVar = SetCVar
local GameTooltip = _G['GameTooltip']
local NONE, COLOR = NONE, COLOR
local SHIFT_KEY, ALT_KEY, CTRL_KEY = SHIFT_KEY, ALT_KEY, CTRL_KEY
local OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN
local LOCK_ACTIONBAR_TEXT = LOCK_ACTIONBAR_TEXT
local PICKUP_ACTION_KEY_TEXT = PICKUP_ACTION_KEY_TEXT

-- GLOBALS: NUM_ACTIONBAR_BUTTONS, NUM_PET_ACTION_SLOTS
-- GLOBALS: LOCK_ACTIONBAR, MICRO_BUTTONS
-- GLOBALS: AceGUIWidgetLSMlists

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
}

local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

local function BuildABConfig()
	group['general'] = {
		order = 1,
		type = "group",
		name = L["General Options"],
		childGroups = "tab",
		disabled = function() return not E.ActionBars; end,
		args = {
			toggleKeybind = {
				order = 1,
				type = "execute",
				name = L["Keybind Mode"],
				func = function() AB:ActivateBindMode(); E:ToggleConfig(); GameTooltip:Hide(); end,
				disabled = function() return not E.private.actionbar.enable end,
			},
			cooldownText = {
				order = 2,
				type = "execute",
				name = L["Cooldown Text"],
				func = function() ACD:SelectGroup("ElvUI", "general", "cooldown") end,
			},
			spacer = {
				order = 3,
				type = "description",
				name = "",
			},
			macrotext = {
				order = 4,
				type = "toggle",
				name = L["Macro Text"],
				desc = L["Display macro names on action buttons."],
				disabled = function() return not E.private.actionbar.enable end,
			},
			hotkeytext = {
				order = 5,
				type = "toggle",
				name = L["Keybind Text"],
				desc = L["Display bind names on action buttons."],
				disabled = function() return not E.private.actionbar.enable end,
			},
			keyDown = {
				order = 6,
				type = 'toggle',
				name = L["Key Down"],
				desc = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
				disabled = function() return not E.private.actionbar.enable end,
			},
			lockActionBars = {
				order = 7,
				type = "toggle",
				name = LOCK_ACTIONBAR_TEXT,
				desc = L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."],
				set = function(info, value)
					E.db.actionbar[ info[#info] ] = value;
					AB:UpdateButtonSettings()

					--Make it work for PetBar too
					SetCVar('lockActionBars', (value == true and 1 or 0))
					LOCK_ACTIONBAR = (value == true and "1" or "0")
				end,
			},
			hideCooldownBling = {
				order = 8,
				type = "toggle",
				name = L["Hide Cooldown Bling"],
				desc = L["Hides the bling animation on buttons at the end of the global cooldown."],
				get = function(info) return E.db.actionbar.hideCooldownBling end,
				set = function(info, value) E.db.actionbar.hideCooldownBling = value;
					for _, bar in pairs(AB["handledBars"]) do
						AB:UpdateButtonConfig(bar, bar.bindButtons)
					end
					AB:UpdatePetCooldownSettings()
				end,
			},
			useDrawSwipeOnCharges = {
				order = 9,
				type = "toggle",
				name = L["Use Draw Swipe"],
				desc = L["Shows a swipe animation when a spell is recharging but still has charges left."],
				get = function(info) return E.db.actionbar.useDrawSwipeOnCharges end,
				set = function(info, value) E.db.actionbar.useDrawSwipeOnCharges = value;
					for _, bar in pairs(AB["handledBars"]) do
						AB:UpdateButtonConfig(bar, bar.bindButtons)
					end
				end,
			},
			movementModifier = {
				order = 10,
				type = 'select',
				name = PICKUP_ACTION_KEY_TEXT,
				desc = L["The button you must hold down in order to drag an ability to another action button."],
				disabled = function() return (not E.private.actionbar.enable or not E.db.actionbar.lockActionBars) end,
				values = {
					['NONE'] = NONE,
					['SHIFT'] = SHIFT_KEY,
					['ALT'] = ALT_KEY,
					['CTRL'] = CTRL_KEY,
				},
			},
			globalFadeAlpha = {
				order = 11,
				type = 'range',
				name = L["Global Fade Transparency"],
				desc = L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."],
				min = 0, max = 1, step = 0.01,
				isPercent = true,
				set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB.fadeParent:SetAlpha(1-value) end,
			},
			colorGroup = {
				order = 12,
				type = "group",
				name = COLORS,
				guiInline = true,
				get = function(info)
					local t = E.db.actionbar[ info[#info] ]
					local d = P.actionbar[info[#info]]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.actionbar[ info[#info] ]
					t.r, t.g, t.b = r, g, b
					AB:UpdateButtonSettings();
				end,
				args = {
					noRangeColor = {
						type = 'color',
						order = 1,
						name = L["Out of Range"],
						desc = L["Color of the actionbutton when out of range."],
					},
					noPowerColor = {
						type = 'color',
						order = 2,
						name = L["Out of Power"],
						desc = L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."],

					},
					usableColor = {
						type = 'color',
						order = 3,
						name = L["Usable"],
						desc = L["Color of the actionbutton when usable."],
					},
					notUsableColor = {
						type = 'color',
						order = 4,
						name = L["Not Usable"],
						desc = L["Color of the actionbutton when not usable."],
					},
				},
			},
			fontGroup = {
				order = 13,
				type = 'group',
				guiInline = true,
				disabled = function() return not E.private.actionbar.enable end,
				name = L["Fonts"],
				args = {
					font = {
						type = "select", dialogControl = 'LSM30_Font',
						order = 4,
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
					},
					fontSize = {
						order = 5,
						name = FONT_SIZE,
						type = "range",
						min = 4, max = 212, step = 1,
					},
					fontOutline = {
						order = 6,
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						type = "select",
						values = {
							['NONE'] = NONE,
							['OUTLINE'] = 'OUTLINE',

							['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
							['THICKOUTLINE'] = 'THICKOUTLINE',
						},
					},
					fontColor = {
						type = 'color',
						order = 7,
						name = COLOR,
						get = function(info)
							local t = E.db.actionbar[ info[#info] ]
							local d = P.actionbar[info[#info]]
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.actionbar[ info[#info] ]
							t.r, t.g, t.b = r, g, b
							AB:UpdateButtonSettings();
						end,
					},
				},
			},
			masque = {
				order = 14,
				type = "group",
				guiInline = true,
				name = L["Masque Support"],
				get = function(info) return E.private.actionbar.masque[info[#info]] end,
				set = function(info, value) E.private.actionbar.masque[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL") end,
				disabled = function() return not E.private.actionbar.enable end,
				args = {
					actionbars = {
						order = 1,
						type = "toggle",
						name = L["ActionBars"],
						desc = L["Allow Masque to handle the skinning of this element."],
					},
					petBar = {
						order = 1,
						type = "toggle",
						name = L["Pet Bar"],
						desc = L["Allow Masque to handle the skinning of this element."],
					},
					stanceBar = {
						order = 1,
						type = "toggle",
						name = L["Stance Bar"],
						desc = L["Allow Masque to handle the skinning of this element."],
					},
				},
			},
		},
	}
	group['barPet'] = {
		name = L["Pet Bar"],
		type = 'group',
		order = 2,
		guiInline = false,
		disabled = function() return not E.ActionBars; end,
		get = function(info) return E.db.actionbar['barPet'][ info[#info] ] end,
		set = function(info, value) E.db.actionbar['barPet'][ info[#info] ] = value; AB:PositionAndSizeBarPet() end,
		args = {
			enabled = {
				order = 1,
				type = 'toggle',
				name = L["Enable"],
			},
			restorePosition = {
				order = 2,
				type = 'execute',
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar['barPet'], P.actionbar['barPet']); E:ResetMovers('Pet Bar'); AB:PositionAndSizeBarPet() end,
			},
			point = {
				order = 3,
				type = 'select',
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = points,
			},
			backdrop = {
				order = 4,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
			},
			mouseover = {
				order = 5,
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				type = "toggle",
			},
			inheritGlobalFade = {
				order = 6,
				type = 'toggle',
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
			},
			buttons = {
				order = 7,
				type = 'range',
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsPerRow = {
				order = 8,
				type = 'range',
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsize = {
				type = 'range',
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				order = 9,
				disabled = function() return not E.private.actionbar.enable end,
			},
			buttonspacing = {
				type = 'range',
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = 0, max = 20, step = 1,
				order = 10,
				disabled = function() return not E.private.actionbar.enable end,
			},
			backdropSpacing = {
				order = 11,
				type = 'range',
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			heightMult = {
				order = 12,
				type = 'range',
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			widthMult = {
				order = 13,
				type = 'range',
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			alpha = {
				order = 14,
				type = 'range',
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			visibility = {
				type = 'input',
				order = 15,
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = 'full',
				multiline = true,
				set = function(info, value)
					if value and value:match('[\n\r]') then
						value = value:gsub('[\n\r]','')
					end
					E.db.actionbar['barPet']['visibility'] = value;
					AB:UpdateButtonSettings()
				end,
			},
		},
	}
	group['stanceBar'] = {
		name = L["Stance Bar"],
		type = 'group',
		order = 3,
		guiInline = false,
		disabled = function() return not E.ActionBars; end,
		get = function(info) return E.db.actionbar['stanceBar'][ info[#info] ] end,
		set = function(info, value) E.db.actionbar['stanceBar'][ info[#info] ] = value; AB:PositionAndSizeBarShapeShift() end,
		args = {
			enabled = {
				order = 1,
				type = 'toggle',
				name = L["Enable"],
			},
			restorePosition = {
				order = 2,
				type = 'execute',
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar['stanceBar'], P.actionbar['stanceBar']); E:ResetMovers('Stance Bar'); AB:PositionAndSizeBarShapeShift() end,
			},
			point = {
				order = 3,
				type = 'select',
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = {
					["TOPLEFT"] = "TOPLEFT",
					["TOPRIGHT"] = "TOPRIGHT",
					["BOTTOMLEFT"] = "BOTTOMLEFT",
					["BOTTOMRIGHT"] = "BOTTOMRIGHT",
					["BOTTOM"] = "BOTTOM",
					["TOP"] = "TOP",
				},
			},
			backdrop = {
				order = 4,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
			},
			mouseover = {
				order = 5,
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				type = "toggle",
			},
			usePositionOverride = {
				order = 6,
				type = "toggle",
				name = L["Use Position Override"],
				desc = L["When enabled it will use the Anchor Point setting to determine growth direction, otherwise it will be determined by where the bar is positioned."],
			},
			inheritGlobalFade = {
				order = 7,
				type = 'toggle',
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
			},
			buttons = {
				order = 8,
				type = 'range',
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsPerRow = {
				order = 9,
				type = 'range',
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsize = {
				type = 'range',
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				order = 10,
				disabled = function() return not E.private.actionbar.enable end,
			},
			buttonspacing = {
				type = 'range',
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = 0, max = 20, step = 1,
				order = 11,
				disabled = function() return not E.private.actionbar.enable end,
			},
			backdropSpacing = {
				order = 12,
				type = 'range',
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			heightMult = {
				order = 13,
				type = 'range',
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			widthMult = {
				order = 14,
				type = 'range',
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			alpha = {
				order = 15,
				type = 'range',
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			style = {
				order = 16,
				type = 'select',
				name = L["Style"],
				desc = L["This setting will be updated upon changing stances."],
				values = {
					['darkenInactive'] = L["Darken Inactive"],
					['classic'] = L["Classic"],
				},
			},
		},
	}
	group['microbar'] = {
		type = "group",
		name = L["Micro Bar"],
		order = 4,
		disabled = function() return not E.ActionBars; end,
		get = function(info) return E.db.actionbar.microbar[ info[#info] ] end,
		set = function(info, value) E.db.actionbar.microbar[ info[#info] ] = value; AB:UpdateMicroPositionDimensions() end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
			},
			alpha = {
				order = 2,
				type = 'range',
				name = L["Alpha"],
				isPercent = true,
				desc = L["Change the alpha level of the frame."],
				min = 0, max = 1, step = 0.1,
			},
			mouseover = {
				order = 3,
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				type = "toggle",
			},
			buttonsPerRow = {
				order = 4,
				type = 'range',
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = #MICRO_BUTTONS, step = 1,
			},
		},
	}
	for i=1, 6 do
		local name = L["Bar "]..i
		group['bar'..i] = {
			order = 4+i,
			name = name,
			type = 'group',
			guiInline = false,
			disabled = function() return not E.ActionBars; end,
			get = function(info) return E.db.actionbar['bar'..i][ info[#info] ] end,
			set = function(info, value) E.db.actionbar['bar'..i][ info[#info] ] = value; AB:PositionAndSizeBar('bar'..i) end,
			args = {
				enabled = {
					order = 1,
					type = 'toggle',
					name = L["Enable"],
					set = function(info, value)
						E.db.actionbar['bar'..i][ info[#info] ] = value;
						AB:PositionAndSizeBar('bar'..i)
					end,
				},
				restorePosition = {
					order = 2,
					type = 'execute',
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar['bar'..i], P.actionbar['bar'..i]); E:ResetMovers('Bar '..i); AB:PositionAndSizeBar('bar'..i) end,
				},
				spacer = {
					order = 3,
					type = "description",
					name = " ",
				},
				backdrop = {
					order = 4,
					type = "toggle",
					name = L["Backdrop"],
					desc = L["Toggles the display of the actionbars backdrop."],
				},
				showGrid = {
					type = 'toggle',
					name = L["Show Empty Buttons"],
					order = 5,
					set = function(info, value) E.db.actionbar['bar'..i][ info[#info] ] = value; AB:UpdateButtonSettingsForBar('bar'..i) end,
				},
				mouseover = {
					order = 6,
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					type = "toggle",
				},
				inheritGlobalFade = {
					order = 7,
					type = 'toggle',
					name = L["Inherit Global Fade"],
					desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
				},
				point = {
					order = 8,
					type = 'select',
					name = L["Anchor Point"],
					desc = L["The first button anchors itself to this point on the bar."],
					values = points,
				},
				flyoutDirection = {
					order = 9,
					type = "select",
					name = L["Flyout Direction"],
					set = function(info, value) E.db.actionbar['bar'..i][ info[#info] ] = value; AB:PositionAndSizeBar('bar'..i); AB:UpdateButtonSettingsForBar("bar"..i) end,
					values = {
						["UP"] = L["Up"],
						["DOWN"] = L["Down"],
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["AUTOMATIC"] = L["Automatic"],
					},
				},
				buttons = {
					order = 10,
					type = 'range',
					name = L["Buttons"],
					desc = L["The amount of buttons to display."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				buttonsPerRow = {
					order = 11,
					type = 'range',
					name = L["Buttons Per Row"],
					desc = L["The amount of buttons to display per row."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				buttonsize = {
					order = 12,
					type = 'range',
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					disabled = function() return not E.private.actionbar.enable end,
				},
				buttonspacing = {
					order = 13,
					type = 'range',
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = 0, max = 20, step = 1,
					disabled = function() return not E.private.actionbar.enable end,
				},
				backdropSpacing = {
					order = 14,
					type = 'range',
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0, max = 10, step = 1,
					disabled = function() return not E.private.actionbar.enable end,
				},
				heightMult = {
					order = 15,
					type = 'range',
					name = L["Height Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				widthMult = {
					order = 16,
					type = 'range',
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				alpha = {
					order = 17,
					type = 'range',
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				paging = {
					type = 'input',
					order = 18,
					name = L["Action Paging"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"],
					width = 'full',
					multiline = true,
					get = function(info) return E.db.actionbar['bar'..i]['paging'][E.myclass] end,
					set = function(info, value)
						if value and value:match('[\n\r]') then
							value = value:gsub('[\n\r]','')
						end

						if not E.db.actionbar['bar'..i]['paging'][E.myclass] then
							E.db.actionbar['bar'..i]['paging'][E.myclass] = {}
						end

						E.db.actionbar['bar'..i]['paging'][E.myclass] = value
						AB:UpdateButtonSettings()
					end,
				},
				visibility = {
					type = 'input',
					order = 19,
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = 'full',
					multiline = true,
					set = function(info, value)
						if value and value:match('[\n\r]') then
							value = value:gsub('[\n\r]','')
						end
						E.db.actionbar['bar'..i]['visibility'] = value;
						AB:UpdateButtonSettings()
					end,
				},
			},
		}

		if i == 6 then
			group['bar'..i].args.enabled.set = function(info, value)
				E.db.actionbar['bar'..i].enabled = value;
				AB:PositionAndSizeBar("bar6")

				--Update Bar 1 paging when Bar 6 is enabled/disabled
				AB:UpdateBar1Paging()
				AB:PositionAndSizeBar("bar1")
			end
		end
	end
	group['extraActionButton'] = {
		type = "group",
		name = L["Boss Button"],
		order = 11,
		disabled = function() return not E.ActionBars; end,
		get = function(info) return E.db.actionbar.extraActionButton[ info[#info] ] end,
		args = {
			alpha = {
				order = 1,
				type = 'range',
				name = L["Alpha"],
				desc = L["Change the alpha level of the frame."],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
				set = function(info, value) E.db.actionbar.extraActionButton[ info[#info] ] = value; AB:Extra_SetAlpha() end,
			},
			scale = {
				order = 2,
				type = "range",
				name = L["Scale"],
				isPercent = true,
				min = 0.2, max = 2, step = 0.01,
				set = function(info, value) E.db.actionbar.extraActionButton[ info[#info] ] = value; AB:Extra_SetScale() end,
			},
		},
	}
end

E.Options.args.actionbar = {
	type = "group",
	name = L["ActionBars"],
	childGroups = "tree",
	get = function(info) return E.db.actionbar[ info[#info] ] end,
	set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB:UpdateButtonSettings() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.actionbar[ info[#info] ] end,
			set = function(info, value) E.private.actionbar[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		intro = {
			order = 2,
			type = "description",
			name = L["ACTIONBARS_DESC"],
		},
		header = {
			order = 3,
			type = "header",
			name = L["Shortcuts"],
		},
		spacer1 = {
			order = 4,
			type = "description",
			name = " ",
		},
		generalShortcut = {
			order = 5,
			type = "execute",
			name = L["General"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "general") end,
			disabled = function() return not E.ActionBars; end,
		},
		petBarShortcut = {
			order = 6,
			type = "execute",
			name = L["Pet Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "barPet") end,
			disabled = function() return not E.ActionBars; end,
		},
		stanceBarShortcut = {
			order = 7,
			type = "execute",
			name = L["Stance Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "stanceBar") end,
			disabled = function() return not E.ActionBars; end,
		},
		spacer2 = {
			order = 8,
			type = "description",
			name = " ",
		},
		microbarShortcut = {
			order = 9,
			type = "execute",
			name = L["Micro Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "microbar") end,
			disabled = function() return not E.ActionBars; end,
		},
		bar1Shortcut = {
			order = 10,
			type = "execute",
			name = L["Bar "]..1,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar1") end,
			disabled = function() return not E.ActionBars; end,
		},
		bar2Shortcut = {
			order = 11,
			type = "execute",
			name = L["Bar "]..2,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar2") end,
			disabled = function() return not E.ActionBars; end,
		},
		spacer3 = {
			order = 12,
			type = "description",
			name = " ",
		},
		bar3Shortcut = {
			order = 13,
			type = "execute",
			name = L["Bar "]..3,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar3") end,
			disabled = function() return not E.ActionBars; end,
		},
		bar4Shortcut = {
			order = 14,
			type = "execute",
			name = L["Bar "]..4,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar4") end,
			disabled = function() return not E.ActionBars; end,
		},
		bar5Shortcut = {
			order = 15,
			type = "execute",
			name = L["Bar "]..5,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar5") end,
			disabled = function() return not E.ActionBars; end,
		},
		spacer4 = {
			order = 16,
			type = "description",
			name = " ",
		},
		bar6Shortcut = {
			order = 17,
			type = "execute",
			name = L["Bar "]..6,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar6") end,
			disabled = function() return not E.ActionBars; end,
		},
		extraActionButtonShortcut = {
			order = 18,
			type = "execute",
			name = L["Boss Button"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "extraActionButton") end,
			disabled = function() return not E.ActionBars; end,
		},
	},
}
group = E.Options.args.actionbar.args
BuildABConfig()