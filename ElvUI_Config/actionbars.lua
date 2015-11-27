local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')
local group

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
}

local function BuildABConfig()
	for i=1, 6 do
		local name = L["Bar "]..i
		group['bar'..i] = {
			order = i,
			name = name,
			type = 'group',
			order = 200,
			guiInline = false,
			disabled = function() return not E.private.actionbar.enable end,
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
					type = 'range',
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					order = 8,
					disabled = function() return not E.private.actionbar.enable end,
				},
				buttonspacing = {
					type = 'range',
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = 1, max = 10, step = 1,
					order = 9,
					disabled = function() return not E.private.actionbar.enable end,
				},
				heightMult = {
					order = 10,
					type = 'range',
					name = L["Height Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				widthMult = {
					order = 11,
					type = 'range',
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				alpha = {
					order = 12,
					type = 'range',
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				paging = {
					type = 'input',
					order = 13,
					name = L["Action Paging"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"],
					width = 'full',
					multiline = true,
					get = function(info) return E.db.actionbar['bar'..i]['paging'][E.myclass] end,
					set = function(info, value)
						if not E.db.actionbar['bar'..i]['paging'][E.myclass] then
							E.db.actionbar['bar'..i]['paging'][E.myclass] = {}
						end

						E.db.actionbar['bar'..i]['paging'][E.myclass] = value
						AB:UpdateButtonSettings()
					end,
				},
				visibility = {
					type = 'input',
					order = 14,
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = 'full',
					multiline = true,
					set = function(info, value)
						E.db.actionbar['bar'..i]['visibility'] = value;
						AB:UpdateButtonSettings()
					end,
				},
			},
		}
	end

	group['barPet'] = {
		order = i,
		name = L["Pet Bar"],
		type = 'group',
		order = 200,
		guiInline = false,
		disabled = function() return not E.private.actionbar.enable end,
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
			buttons = {
				order = 6,
				type = 'range',
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsPerRow = {
				order = 7,
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
				order = 8,
				disabled = function() return not E.private.actionbar.enable end,
			},
			buttonspacing = {
				type = 'range',
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = 1, max = 10, step = 1,
				order = 9,
				disabled = function() return not E.private.actionbar.enable end,
			},
			heightMult = {
				order = 10,
				type = 'range',
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			widthMult = {
				order = 11,
				type = 'range',
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			alpha = {
				order = 12,
				type = 'range',
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			visibility = {
				type = 'input',
				order = 13,
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = 'full',
				multiline = true,
				set = function(info, value)
					E.db.actionbar['barPet']['visibility'] = value;
					AB:UpdateButtonSettings()
				end,
			},
		},
	}
	group['stanceBar'] = {
		order = i,
		name = L["Stance Bar"],
		type = 'group',
		order = 200,
		guiInline = false,
		disabled = function() return not E.private.actionbar.enable end,
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
			buttons = {
				order = 6,
				type = 'range',
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsPerRow = {
				order = 7,
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
				order = 8,
				disabled = function() return not E.private.actionbar.enable end,
			},
			buttonspacing = {
				type = 'range',
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = 1, max = 10, step = 1,
				order = 9,
				disabled = function() return not E.private.actionbar.enable end,
			},
			heightMult = {
				order = 10,
				type = 'range',
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			widthMult = {
				order = 11,
				type = 'range',
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			alpha = {
				order = 12,
				type = 'range',
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			style = {
				order = 13,
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
		toggleKeybind = {
			order = 2,
			type = "execute",
			name = L["Keybind Mode"],
			func = function() AB:ActivateBindMode(); E:ToggleConfig(); GameTooltip:Hide(); end,
			disabled = function() return not E.private.actionbar.enable end,
		},
		macrotext = {
			type = "toggle",
			name = L["Macro Text"],
			desc = L["Display macro names on action buttons."],
			order = 3,
			disabled = function() return not E.private.actionbar.enable end,
		},
		hotkeytext = {
			type = "toggle",
			name = L["Keybind Text"],
			desc = L["Display bind names on action buttons."],
			order = 4,
			disabled = function() return not E.private.actionbar.enable end,
		},
		keyDown = {
			type = 'toggle',
			name = L["Key Down"],
			desc = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
			order = 5,
			disabled = function() return not E.private.actionbar.enable end,
		},
		showGrid = {
			type = 'toggle',
			name = ALWAYS_SHOW_MULTIBARS_TEXT,
			desc = OPTION_TOOLTIP_ALWAYS_SHOW_MULTIBARS,
			order = 6,
			disabled = function() return not E.private.actionbar.enable end,
		},
		movementModifier = {
			type = 'select',
			name = PICKUP_ACTION_KEY_TEXT,
			desc = L["The button you must hold down in order to drag an ability to another action button."],
			disabled = function() return not E.private.actionbar.enable end,
			order = 8,
			values = {
				['NONE'] = NONE,
				['SHIFT'] = SHIFT_KEY,
				['ALT'] = ALT_KEY,
				['CTRL'] = CTRL_KEY,
			},
		},
		noRangeColor = {
			type = 'color',
			order = 9,
			name = L["Out of Range"],
			desc = L["Color of the actionbutton when out of range."],
			get = function(info)
				local t = E.db.actionbar[ info[#info] ]
				local d = P.actionbar[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				E.db.actionbar[ info[#info] ] = {}
				local t = E.db.actionbar[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				AB:UpdateButtonSettings();
			end,
		},
		noPowerColor = {
			type = 'color',
			order = 10,
			name = L["Out of Power"],
			desc = L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."],
			get = function(info)
				local t = E.db.actionbar[ info[#info] ]
				local d = P.actionbar[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				E.db.actionbar[ info[#info] ] = {}
				local t = E.db.actionbar[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				AB:UpdateButtonSettings();
			end,
		},
		hideCooldownBling = {
			order = 11,
			type = "toggle",
			name = L["Hide Cooldown Bling"],
			desc = L["Hides the bling animation on buttons at the end of the global cooldown."],
			get = function(info) return E.private.actionbar.hideCooldownBling end,
			set = function(info, value) E.private.actionbar.hideCooldownBling = value; E:StaticPopup_Show("CONFIG_RL") end,
		},
		fontGroup = {
			order = 12,
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
					name = L["Font Size"],
					type = "range",
					min = 4, max = 22, step = 1,
				},
				fontOutline = {
					order = 6,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						['NONE'] = L["None"],
						['OUTLINE'] = 'OUTLINE',

						['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
				},
			},
		},
		masque = {
			order = 13,
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
		microbar = {
			type = "group",
			name = L["Micro Bar"],
			disabled = function() return not E.private.actionbar.enable end,
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
					min = 1, max = #MICRO_BUTTONS - 1, step = 1,
				},
			},
		},
		extraActionButton = {
			type = "group",
			name = L["Boss Button"],
			disabled = function() return not E.private.actionbar.enable end,
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
		},
	},
}
group = E.Options.args.actionbar.args
BuildABConfig()