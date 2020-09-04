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

local points = {
	TOPLEFT = 'TOPLEFT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
}

E.Options.args.actionbar = {
	type = 'group',
	name = L["ActionBars"],
	childGroups = 'tab',
	order = 2,
	get = function(info) return E.db.actionbar[info[#info]] end,
	set = function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end,
	args = {
		intro = ACH:Description(L["ACTIONBARS_DESC"], 0),
		enable = {
			order = 1,
			type = 'toggle',
			name = L["Enable"],
			get = function(info) return E.private.actionbar[info[#info]] end,
			set = function(info, value) E.private.actionbar[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end
		},
		general = {
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
					disabled = function() return not E.private.actionbar.enable end,
				},
				movementModifier = {
					order = 1,
					type = 'select',
					name = L["PICKUP_ACTION_KEY_TEXT"],
					desc = L["The button you must hold down in order to drag an ability to another action button."],
					disabled = function() return (not E.private.actionbar.enable or not E.db.actionbar.lockActionBars) end,
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
					args = {
						keyDown = {
							order = 13,
							type = 'toggle',
							name = L["Key Down"],
							desc = L["OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN"],
							disabled = function() return not E.private.actionbar.enable end,
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
							get = function(info) return E.db.actionbar.hideCooldownBling end,
							set = function(info, value) E.db.actionbar.hideCooldownBling = value;
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
							set = function(info, value) E.db.actionbar.addNewSpells = value; AB:IconIntroTracker_Toggle() end,
						},
						rightClickSelfCast = {
							order = 17,
							type = 'toggle',
							name = L["RightClick Self-Cast"],
							set = function(info, value)
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
							get = function(info) return E.db.actionbar.useDrawSwipeOnCharges end,
							set = function(info, value) E.db.actionbar.useDrawSwipeOnCharges = value;
								for _, bar in pairs(AB.handledBars) do
									AB:UpdateButtonConfig(bar, bar.bindButtons)
								end
							end,
						},
						chargeCooldown = {
							order = 19,
							type = 'toggle',
							name = L["Charge Cooldown Text"],
							set = function(info, value)
								E.db.actionbar.chargeCooldown = value;
								AB:ToggleCooldownOptions()
							end,
						},
						desaturateOnCooldown = {
							order = 20,
							type = 'toggle',
							name = L["Desaturate Cooldowns"],
							set = function(info, value)
								E.db.actionbar.desaturateOnCooldown = value;
								AB:ToggleCooldownOptions()
							end,
						},
						transparent = {
							order = 21,
							type = 'toggle',
							name = L["Transparent"],
							set = function(info, value)
								E.db.actionbar.transparent = value
								E:StaticPopup_Show('PRIVATE_RL')
							end,
						},
						flashAnimation = {
							order = 22,
							type = 'toggle',
							name = L["Button Flash"],
							desc = L["Use a more visible flash animation for Auto Attacks."],
							set = function(info, value)
								E.db.actionbar.flashAnimation = value
								E:StaticPopup_Show('PRIVATE_RL')
							end,
						},
						equippedItem = {
							order = 23,
							type = 'toggle',
							name = L["Equipped Item"],
							get = function(info) return E.db.actionbar[info[#info]] end,
							set = function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end
						},
						macrotext = {
							order = 24,
							type = 'toggle',
							name = L["Macro Text"],
							desc = L["Display macro names on action buttons."],
							disabled = function() return not E.private.actionbar.enable end,
						},
						hotkeytext = {
							order = 25,
							type = 'toggle',
							name = L["Keybind Text"],
							desc = L["Display bind names on action buttons."],
							disabled = function() return not E.private.actionbar.enable end,
						},
						useRangeColorText = {
							order = 26,
							type = 'toggle',
							name = L["Color Keybind Text"],
							desc = L["Color Keybind Text when Out of Range, instead of the button."],
						},
					}
				},
				colorGroup = {
					order = 30,
					type = 'group',
					name = L["COLORS"],
					disabled = function() return E.Masque or not E.private.actionbar.enable end,
					get = function(info)
						local t = E.db.actionbar[info[#info]]
						local d = P.actionbar[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local t = E.db.actionbar[info[#info]]
						t.r, t.g, t.b, t.a = r, g, b, a
						AB:UpdateButtonSettings();
					end,
					args = {
						fontColor = {
							type = 'color',
							order = 0,
							name = L["Text"],
						},
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
						colorSwipeNormal = {
							type = 'color',
							order = 5,
							hasAlpha = true,
							name = L["Swipe: Normal"],
						},
						colorSwipeLOC = {
							type = 'color',
							order = 6,
							hasAlpha = true,
							name = L["Swipe: Loss of Control"],
						},
						equippedItemColor = {
							order = 7,
							type = 'color',
							name = L["Equipped Item Color"]
						},
					},
				},
				fontGroup = {
					order = 40,
					type = 'group',
					disabled = function() return not E.private.actionbar.enable end,
					name = L["Fonts"],
					args = {
						font = {
							type = 'select', dialogControl = 'LSM30_Font',
							order = 2,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontSize = {
							order = 3,
							name = L["FONT_SIZE"],
							type = 'range',
							min = 4, max = 212, step = 1,
						},
						fontOutline = {
							order = 4,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = 'select',
							values = C.Values.FontFlags,
						},
					},
				},
				textGroup = {
					type = 'group',
					order = 50,
					name = L["Text Position"],
					disabled = function() return E.Masque or not E.private.actionbar.enable end,
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
							min = -10, max = 10, step = 1,
						},
						countTextYOffset = {
							type = 'range',
							order = 3,
							name = L["Stack Text Y-Offset"],
							min = -10, max = 10, step = 1,
						},
						hotkeyTextPosition  = {
							type = 'select',
							order = 4,
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
							order = 5,
							name = L["Keybind Text X-Offset"],
							min = -10, max = 10, step = 1,
						},
						hotkeyTextYOffset = {
							type = 'range',
							order = 6,
							name = L["Keybind Text Y-Offset"],
							min = -10, max = 10, step = 1,
						},
					},
				},
				masqueGroup = {
					order = 60,
					type = 'group',
					name = L["Masque Support"],
					get = function(info) return E.private.actionbar.masque[info[#info]] end,
					set = function(info, value) E.private.actionbar.masque[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end,
					disabled = function() return not E.Masque or not E.private.actionbar.enable end,
					--hidden = function() return not E.Masque end,
					args = {
						actionbars = {
							order = 1,
							type = 'toggle',
							name = L["ActionBars"]
						},
						petBar = {
							order = 1,
							type = 'toggle',
							name = L["Pet Bar"]
						},
						stanceBar = {
							order = 1,
							type = 'toggle',
							name = L["Stance Bar"]
						}
					}
				},
			},
		},
		barPet = {
			name = L["Pet Bar"],
			type = 'group',
			order = 14,
			disabled = function() return not E.ActionBars.Initialized; end,
			get = function(info) return E.db.actionbar.barPet[info[#info]] end,
			set = function(info, value) E.db.actionbar.barPet[info[#info]] = value; AB:PositionAndSizeBarPet() end,
			args = {
				enabled = {
					order = 0,
					type = 'toggle',
					name = L["Enable"],
				},
				restorePosition = {
					order = 1,
					type = 'execute',
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar.barPet, P.actionbar.barPet); E:ResetMovers('Pet Bar'); AB:PositionAndSizeBarPet() end,
				},
				point = {
					order = 2,
					type = 'select',
					name = L["Anchor Point"],
					desc = L["The first button anchors itself to this point on the bar."],
					values = points,
				},
				generalOptions = {
					order = 3,
					type = 'multiselect',
					name = '',
					get = function(info, key) return E.db.actionbar.barPet[key] end,
					set = function(info, key, value) E.db.actionbar.barPet[key] = value; AB:PositionAndSizeBarPet() end,
					values = {
						backdrop = L["Backdrop"],
						mouseover = L["Mouse Over"],
						clickThrough = L["Click Through"],
						inheritGlobalFade = L["Inherit Global Fade"],
					}
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
					min = -3, max = 20, step = 1,
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
				widthMult = {
					order = 12,
					type = 'range',
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				heightMult = {
					order = 13,
					type = 'range',
					name = L["Height Multiplier"],
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
						E.db.actionbar.barPet.visibility = value;
						AB:UpdateButtonSettings()
					end,
				},
			},
		},
		stanceBar = {
			name = L["Stance Bar"],
			type = 'group',
			order = 15,
			disabled = function() return not E.ActionBars.Initialized; end,
			get = function(info) return E.db.actionbar.stanceBar[info[#info]] end,
			set = function(info, value) E.db.actionbar.stanceBar[info[#info]] = value; AB:PositionAndSizeBarShapeShift() end,
			args = {
				enabled = {
					order = 0,
					type = 'toggle',
					name = L["Enable"],
				},
				restorePosition = {
					order = 1,
					type = 'execute',
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar.stanceBar, P.actionbar.stanceBar); E:ResetMovers('Stance Bar'); AB:PositionAndSizeBarShapeShift() end,
				},
				point = {
					order = 2,
					type = 'select',
					name = L["Anchor Point"],
					desc = L["The first button anchors itself to this point on the bar."],
					values = {
						TOPLEFT = 'TOPLEFT',
						TOPRIGHT = 'TOPRIGHT',
						BOTTOMLEFT = 'BOTTOMLEFT',
						BOTTOMRIGHT = 'BOTTOMRIGHT',
						BOTTOM = 'BOTTOM',
						TOP = 'TOP',
					},
				},
				generalOptions = {
					order = 3,
					type = 'multiselect',
					name = '',
					get = function(info, key) return E.db.actionbar.stanceBar[key] end,
					set = function(info, key, value) E.db.actionbar.stanceBar[key] = value; AB:PositionAndSizeBarShapeShift() end,
					values = {
						backdrop = L["Backdrop"],
						mouseover = L["Mouse Over"],
						clickThrough = L["Click Through"],
						inheritGlobalFade = L["Inherit Global Fade"],
					}
				},
				buttons = {
					order = 4,
					type = 'range',
					name = L["Buttons"],
					desc = L["The amount of buttons to display."],
					min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				},
				buttonsPerRow = {
					order = 5,
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
					order = 6,
					disabled = function() return not E.private.actionbar.enable end,
				},
				buttonspacing = {
					type = 'range',
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -3, max = 20, step = 1,
					order = 7,
					disabled = function() return not E.private.actionbar.enable end,
				},
				backdropSpacing = {
					order = 8,
					type = 'range',
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0, max = 10, step = 1,
					disabled = function() return not E.private.actionbar.enable end,
				},
				heightMult = {
					order = 9,
					type = 'range',
					name = L["Height Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				widthMult = {
					order = 10,
					type = 'range',
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				alpha = {
					order = 11,
					type = 'range',
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				style = {
					order = 12,
					type = 'select',
					name = L["Style"],
					desc = L["This setting will be updated upon changing stances."],
					values = {
						darkenInactive = L["Darken Inactive"],
						classic = L["Classic"],
					},
				},
				visibility = {
					type = 'input',
					order = 13,
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = 'full',
					multiline = true,
					set = function(info, value)
						if value and value:match('[\n\r]') then
							value = value:gsub('[\n\r]','')
						end
						E.db.actionbar.stanceBar.visibility = value;
						AB:UpdateButtonSettings()
					end,
				},
			},
		},
		microbar = {
			type = 'group',
			name = L["Micro Bar"],
			order = 16,
			disabled = function() return not E.ActionBars.Initialized; end,
			get = function(info) return E.db.actionbar.microbar[info[#info]] end,
			set = function(info, value) E.db.actionbar.microbar[info[#info]] = value; AB:UpdateMicroPositionDimensions() end,
			args = {
				enabled = {
					order = 1,
					type = 'toggle',
					name = L["Enable"],
				},
				mouseover = {
					order = 2,
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					type = 'toggle',
				},
				alpha = {
					order = 3,
					type = 'range',
					name = L["Alpha"],
					isPercent = true,
					desc = L["Change the alpha level of the frame."],
					min = 0, max = 1, step = 0.01,
				},
				buttonSize = {
					order = 5,
					type = 'range',
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 40, step = 1,
				},
				buttonSpacing = {
					order = 6,
					type = 'range',
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -3, max = 10, step = 1,
				},
				buttonsPerRow = {
					order = 7,
					type = 'range',
					name = L["Buttons Per Row"],
					desc = L["The amount of buttons to display per row."],
					min = 1, max = #MICRO_BUTTONS, step = 1,
				},
				visibility = {
					type = 'input',
					order = 9,
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = 'full',
					multiline = true,
					set = function(info, value)
						if value and value:match('[\n\r]') then
							value = value:gsub('[\n\r]','')
						end
						E.db.actionbar.microbar.visibility = value;
						AB:UpdateMicroPositionDimensions()
					end,
				},
			},
		},
		extraActionButton = {
			type = 'group',
			name = L["Boss Button"],
			order = 17,
			disabled = function() return not E.ActionBars.Initialized; end,
			get = function(info) return E.db.actionbar.extraActionButton[info[#info]] end,
			args = {
				alpha = {
					order = 1,
					type = 'range',
					name = L["Alpha"],
					desc = L["Change the alpha level of the frame."],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
					set = function(info, value) E.db.actionbar.extraActionButton[info[#info]] = value; AB:Extra_SetAlpha() end,
				},
				scale = {
					order = 2,
					type = 'range',
					name = L["Scale"],
					isPercent = true,
					min = 0.2, max = 2, step = 0.01,
					set = function(info, value) E.db.actionbar.extraActionButton[info[#info]] = value; AB:Extra_SetScale() end,
				},
			},
		},
		vehicleExitButton = {
			type = 'group',
			name = L["Vehicle Exit"],
			order = 18,
			disabled = function() return not E.ActionBars.Initialized; end,
			get = function(info) return E.db.actionbar.vehicleExitButton[info[#info]] end,
			set = function(info, value) E.db.actionbar.vehicleExitButton[info[#info]] = value; AB:UpdateVehicleLeave() end,
			args = {
				enable = {
					order = 1,
					type = 'toggle',
					name = L["Enable"],
					set = function(info, value) E.db.actionbar.vehicleExitButton[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end
				},
				size = {
					order = 2,
					type = 'range',
					name = L["Size"],
					min = 16, max = 50, step = 1,
				},
				level = {
					order = 3,
					type = 'range',
					name = L["Frame Level"],
					min = 1, max = 128, step = 1,
				},
				strata = {
					order = 4,
					type = 'select',
					name = L["Frame Strata"],
					values = {
						BACKGROUND = 'BACKGROUND',
						LOW = 'LOW',
						MEDIUM = 'MEDIUM',
						HIGH = 'HIGH',
						DIALOG = 'DIALOG',
						TOOLTIP = 'TOOLTIP',
					},
				},
			},
		},
		playerBars = {
			order = 4,
			name = L["Player Bars"],
			type = 'group',
			childGroups = 'tree',
			args = {},
		},
	},
}

for i = 1, 10 do
	local name = L["Bar "]..i
	E.Options.args.actionbar.args.playerBars.args['bar'..i] = {
		order = 3 + i,
		name = name,
		type = 'group',
		disabled = function() return not E.ActionBars.Initialized; end,
		get = function(info) return E.db.actionbar['bar'..i][info[#info]] end,
		set = function(info, value) E.db.actionbar['bar'..i][info[#info]] = value; AB:PositionAndSizeBar('bar'..i) end,
		args = {
			enabled = {
				order = 0,
				type = 'toggle',
				name = L["Enable"],
				set = function(info, value)
					E.db.actionbar['bar'..i][info[#info]] = value;
					AB:PositionAndSizeBar('bar'..i)
				end,
			},
			restorePosition = {
				order = 1,
				type = 'execute',
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar['bar'..i], P.actionbar['bar'..i]); E:ResetMovers('Bar '..i); AB:PositionAndSizeBar('bar'..i) end,
			},
			generalOptions = {
				order = 3,
				type = 'multiselect',
				name = '',
				get = function(info, key) return E.db.actionbar['bar'..i][key] end,
				set = function(info, key, value) E.db.actionbar['bar'..i][key] = value; AB:PositionAndSizeBar('bar'..i) AB:UpdateButtonSettingsForBar('bar'..i) end,
				values = {
					backdrop = L["Backdrop"],
					showGrid = L["Show Empty Buttons"],
					mouseover = L["Mouse Over"],
					clickThrough = L["Click Through"],
					inheritGlobalFade = L["Inherit Global Fade"],
				}
			},
			point = {
				order = 4,
				type = 'select',
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = points,
			},
			flyoutDirection = {
				order = 5,
				type = 'select',
				name = L["Flyout Direction"],
				set = function(info, value) E.db.actionbar['bar'..i][info[#info]] = value; AB:PositionAndSizeBar('bar'..i); AB:UpdateButtonSettingsForBar('bar'..i) end,
				values = {
					UP = L["Up"],
					DOWN = L["Down"],
					LEFT = L["Left"],
					RIGHT = L["Right"],
					AUTOMATIC = L["Automatic"],
				},
			},
			buttons = {
				order = 6,
				type = 'range',
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
			},
			buttonsPerRow = {
				order = 7,
				type = 'range',
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
			},
			buttonsize = {
				order = 8,
				type = 'range',
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			buttonspacing = {
				order = 9,
				type = 'range',
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -3, max = 20, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			backdropSpacing = {
				order = 10,
				type = 'range',
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			heightMult = {
				order = 11,
				type = 'range',
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			widthMult = {
				order = 12,
				type = 'range',
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			alpha = {
				order = 13,
				type = 'range',
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			paging = {
				type = 'input',
				order = 14,
				name = L["Action Paging"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"],
				width = 'full',
				multiline = true,
				get = function(info) return E.db.actionbar['bar'..i].paging[E.myclass] end,
				set = function(info, value)
					if value and value:match('[\n\r]') then
						value = value:gsub('[\n\r]','')
					end

					if not E.db.actionbar['bar'..i].paging[E.myclass] then
						E.db.actionbar['bar'..i].paging[E.myclass] = {}
					end

					E.db.actionbar['bar'..i].paging[E.myclass] = value
					AB:UpdateButtonSettings()
				end,
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
					E.db.actionbar['bar'..i].visibility = value;
					AB:UpdateButtonSettings()
				end,
			},
		},
	}

	if (E.myclass == 'DRUID' and i >= 7 or E.myclass == 'ROGUE' and i == 7) then
		E.Options.args.actionbar.args.playerBars.args['bar'..i].args.enabled.confirm = function(info, value)
			return format(L["Bar %s is used for stance or forms.|N You will have to adjust paging to use this bar.|N Are you sure?"], i)
		end
	end
end

E.Options.args.actionbar.args.playerBars.args.bar1.args.pagingReset = {
	type = 'execute',
	name = L["Reset Action Paging"],
	order = 2,
	confirm = true,
	confirmText = L["You are about to reset paging. Are you sure?"],
	func = function() E.db.actionbar.bar1.paging[E.myclass] = P.actionbar.bar1.paging[E.myclass] AB:UpdateButtonSettings() end,
}

E.Options.args.actionbar.args.playerBars.args.bar6.args.enabled.set = function(info, value)
	E.db.actionbar.bar6.enabled = value;
	AB:PositionAndSizeBar('bar6')

	--Update Bar 1 paging when Bar 6 is enabled/disabled
	AB:UpdateBar1Paging()
	AB:PositionAndSizeBar('bar1')
end
