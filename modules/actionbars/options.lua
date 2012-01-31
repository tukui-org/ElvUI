local E, L, DF = unpack(select(2, ...)); --Engine
local AB = E:GetModule('ActionBars')
local group

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
}

local function BuildABConfig()
	for i=1, 5 do
		local name = L['Bar ']..i
		group['bar'..i] = {
			order = i,
			name = name,
			type = 'group',
			order = 200,
			guiInline = false,
			disabled = function() return not E.db.actionbar.enable end,
			get = function(info) return E.db.actionbar['bar'..i][ info[#info] ] end,
			set = function(info, value) E.db.actionbar['bar'..i][ info[#info] ] = value; AB:UpdateButtonSettings() end,
			args = {
				enabled = {
					order = 1,
					type = 'toggle',
					name = L['Enable'],
				},
				restorePosition = {
					order = 2,
					type = 'execute',
					name = L['Restore Bar'],
					desc = L['Restore the actionbars default settings'],
					func = function() E.db.actionbar['bar'..i] = DF.actionbar['bar'..i]; AB:ResetMovers('bar'..i); AB:UpdateButtonSettings() end,
				},	
				point = {
					order = 3,
					type = 'select',
					name = L['Anchor Point'],
					desc = L['The first button anchors itself to this point on the bar.'],
					values = points,
				},				
				backdrop = {
					order = 4,
					type = "toggle",
					name = L['Backdrop'],
					desc = L['Toggles the display of the actionbars backdrop.'],
				},	
				mouseover = {
					order = 5,
					name = L['Mouse Over'],
					desc = L['The frame is not shown unless you mouse over the frame.'],
					type = "toggle",
				},
				buttons = {
					order = 6,
					type = 'range',
					name = L['Buttons'],
					desc = L['The ammount of buttons to display.'],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,				
				},
				buttonsPerRow = {
					order = 7,
					type = 'range',
					name = L['Buttons Per Row'],
					desc = L['The ammount of buttons to display per row.'],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,					
				},
				buttonsize = {
					type = 'range',
					name = L['Button Size'],
					desc = L['The size of the action buttons.'],
					min = 15, max = 60, step = 1,
					order = 8,
					disabled = function() return not E.db.actionbar.enable end,
				},
				buttonspacing = {
					type = 'range',
					name = L['Button Spacing'],
					desc = L['The spacing between buttons.'],
					min = 1, max = 10, step = 1,	
					order = 9, 
					disabled = function() return not E.db.actionbar.enable end,
				},				
				heightMult = {
					order = 10,
					type = 'range',
					name = L['Height Multiplier'],
					desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
					min = 1, max = 5, step = 1,					
				},
				widthMult = {
					order = 11,
					type = 'range',
					name = L['Width Multiplier'],
					desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
					min = 1, max = 5, step = 1,					
				},
				paging = {
					type = 'input',
					order = 12,
					name = L['Action Paging'],
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
					order = 13,
					name = L['Visibility State'],
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
		name = L['Pet Bar'],
		type = 'group',
		order = 200,
		guiInline = false,
		disabled = function() return not E.db.actionbar.enable end,
		get = function(info) return E.db.actionbar['barPet'][ info[#info] ] end,
		set = function(info, value) E.db.actionbar['barPet'][ info[#info] ] = value; AB:UpdateButtonSettings() end,
		args = {
			enabled = {
				order = 1,
				type = 'toggle',
				name = L['Enable'],
			},
			restorePosition = {
				order = 2,
				type = 'execute',
				name = L['Restore Bar'],
				desc = L['Restore the actionbars default settings'],
				func = function() E.db.actionbar['barPet'] = DF.actionbar['barPet']; AB:ResetMovers('barPet'); AB:UpdateButtonSettings() end,
			},	
			point = {
				order = 3,
				type = 'select',
				name = L['Anchor Point'],
				desc = L['The first button anchors itself to this point on the bar.'],
				values = points,
			},				
			backdrop = {
				order = 4,
				type = "toggle",
				name = L['Backdrop'],
				desc = L['Toggles the display of the actionbars backdrop.'],
			},	
			mouseover = {
				order = 5,
				name = L['Mouse Over'],
				desc = L['The frame is not shown unless you mouse over the frame.'],
				type = "toggle",
			},
			buttons = {
				order = 6,
				type = 'range',
				name = L['Buttons'],
				desc = L['The ammount of buttons to display.'],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,				
			},
			buttonsPerRow = {
				order = 7,
				type = 'range',
				name = L['Buttons Per Row'],
				desc = L['The ammount of buttons to display per row.'],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,					
			},
			buttonsize = {
				type = 'range',
				name = L['Button Size'],
				desc = L['The size of the action buttons.'],
				min = 15, max = 60, step = 1,
				order = 8,
				disabled = function() return not E.db.actionbar.enable end,
			},
			buttonspacing = {
				type = 'range',
				name = L['Button Spacing'],
				desc = L['The spacing between buttons.'],
				min = 1, max = 10, step = 1,	
				order = 9, 
				disabled = function() return not E.db.actionbar.enable end,
			},				
			heightMult = {
				order = 10,
				type = 'range',
				name = L['Height Multiplier'],
				desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
				min = 1, max = 5, step = 1,					
			},
			widthMult = {
				order = 11,
				type = 'range',
				name = L['Width Multiplier'],
				desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
				min = 1, max = 5, step = 1,					
			},
			visibility = {
				type = 'input',
				order = 12,
				name = L['Visibility State'],
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
	group['barShapeShift'] = {
		order = i,
		name = L['ShapeShift Bar'],
		type = 'group',
		order = 200,
		guiInline = false,
		disabled = function() return not E.db.actionbar.enable end,
		get = function(info) return E.db.actionbar['barShapeShift'][ info[#info] ] end,
		set = function(info, value) E.db.actionbar['barShapeShift'][ info[#info] ] = value; AB:UpdateButtonSettings() end,
		args = {
			enabled = {
				order = 1,
				type = 'toggle',
				name = L['Enable'],
			},
			restorePosition = {
				order = 2,
				type = 'execute',
				name = L['Restore Bar'],
				desc = L['Restore the actionbars default settings'],
				func = function() E.db.actionbar['barShapeShift'] = DF.actionbar['barShapeShift']; AB:ResetMovers('barShapeShift'); AB:UpdateButtonSettings() end,
			},	
			point = {
				order = 3,
				type = 'select',
				name = L['Anchor Point'],
				desc = L['The first button anchors itself to this point on the bar.'],
				values = points,
			},				
			backdrop = {
				order = 4,
				type = "toggle",
				name = L['Backdrop'],
				desc = L['Toggles the display of the actionbars backdrop.'],
			},	
			mouseover = {
				order = 5,
				name = L['Mouse Over'],
				desc = L['The frame is not shown unless you mouse over the frame.'],
				type = "toggle",
			},
			buttons = {
				order = 6,
				type = 'range',
				name = L['Buttons'],
				desc = L['The ammount of buttons to display.'],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,				
			},
			buttonsPerRow = {
				order = 7,
				type = 'range',
				name = L['Buttons Per Row'],
				desc = L['The ammount of buttons to display per row.'],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,					
			},
			buttonsize = {
				type = 'range',
				name = L['Button Size'],
				desc = L['The size of the action buttons.'],
				min = 15, max = 60, step = 1,
				order = 8,
				disabled = function() return not E.db.actionbar.enable end,
			},
			buttonspacing = {
				type = 'range',
				name = L['Button Spacing'],
				desc = L['The spacing between buttons.'],
				min = 1, max = 10, step = 1,	
				order = 9, 
				disabled = function() return not E.db.actionbar.enable end,
			},				
			heightMult = {
				order = 10,
				type = 'range',
				name = L['Height Multiplier'],
				desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
				min = 1, max = 5, step = 1,					
			},
			widthMult = {
				order = 11,
				type = 'range',
				name = L['Width Multiplier'],
				desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
				min = 1, max = 5, step = 1,					
			},
		},
	}
	
	group['cdgroup'] = {
		type = "group",
		order = 500,
		name = L['Cooldown Text'],
		disabled = function() return not E.db.actionbar.enable or not E.db.actionbar.enablecd end,
		set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB:UpdateCooldownSettings() end,
		args = {
			enablecd = {
				type = "toggle",
				order = 1,
				name = L['Enable'],
				desc = L['Display cooldown text on anything with the cooldown spiril.'],
				disabled = function() return not E.db.actionbar.enable end,
			},			
			treshold = {
				type = 'range',
				name = L['Low Threshold'],
				desc = L['Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red'],
				min = -1, max = 20, step = 1,	
				order = 2, 					
			},
			restoreColors = {
				type = 'execute',
				name = L["Restore Defaults"],
				order = 3,
				func = function() 
					self.db.expiringcolor = DF['actionbar'].expiringcolor;
					self.db.secondscolor = DF['actionbar'].secondscolor;
					self.db.minutescolor = DF['actionbar'].minutescolor;
					self.db.hourscolor = DF['actionbar'].hourscolor;
					self.db.dayscolor = DF['actionbar'].dayscolor;
					AB:UpdateCooldownSettings();
				end,
			},
			expiringcolor = {
				type = 'color',
				order = 4,
				name = L['Expiring'],
				desc = L['Color when the text is about to expire'],
				get = function(info)
					local t = E.db.actionbar[ info[#info] ]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.actionbar[ info[#info] ] = {}
					local t = E.db.actionbar[ info[#info] ]
					t.r, t.g, t.b = r, g, b
					AB:UpdateCooldownSettings();
				end,					
			},
			secondscolor = {
				type = 'color',
				order = 5,
				name = L['Seconds'],
				desc = L['Color when the text is in the seconds format.'],
				get = function(info)
					local t = E.db.actionbar[ info[#info] ]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.actionbar[ info[#info] ] = {}
					local t = E.db.actionbar[ info[#info] ]
					t.r, t.g, t.b = r, g, b
					AB:UpdateCooldownSettings();
				end,				
			},
			minutescolor = {
				type = 'color',
				order = 6,
				name = L['Minutes'],
				desc = L['Color when the text is in the minutes format.'],
				get = function(info)
					local t = E.db.actionbar[ info[#info] ]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.actionbar[ info[#info] ] = {}
					local t = E.db.actionbar[ info[#info] ]
					t.r, t.g, t.b = r, g, b
					AB:UpdateCooldownSettings();
				end,				
			},
			hourscolor = {
				type = 'color',
				order = 7,
				name = L['Hours'],
				desc = L['Color when the text is in the hours format.'],
				get = function(info)
					local t = E.db.actionbar[ info[#info] ]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.actionbar[ info[#info] ] = {}
					local t = E.db.actionbar[ info[#info] ]
					t.r, t.g, t.b = r, g, b
					AB:UpdateCooldownSettings();
				end,				
			},	
			dayscolor = {
				type = 'color',
				order = 8,
				name = L['Days'],
				desc = L['Color when the text is in the days format.'],
				get = function(info)
					local t = E.db.actionbar[ info[#info] ]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.actionbar[ info[#info] ] = {}
					local t = E.db.actionbar[ info[#info] ]
					t.r, t.g, t.b = r, g, b
					AB:UpdateCooldownSettings();
				end,				
			},				
		},
	}	
	
	if E.myclass == "SHAMAN" then
		group['barTotem'] = {
			order = i,
			name = L['Totem Bar'],
			type = 'group',
			order = 200,
			guiInline = false,
			disabled = function() return not E.db.actionbar.enable or not E.myclass == "SHAMAN" end,
			get = function(info) return E.db.actionbar['barTotem'][ info[#info] ] end,
			set = function(info, value) E.db.actionbar['barTotem'][ info[#info] ] = value; AB:AdjustTotemSettings() end,
			args = {
				enabled = {
					order = 1,
					type = 'toggle',
					name = L['Enable'],
				},
				restorePosition = {
					order = 2,
					type = 'execute',
					name = L['Restore Bar'],
					desc = L['Restore the actionbars default settings'],
					func = function() E.db.actionbar['barTotem'] = DF.actionbar['barTotem']; AB:ResetMovers('barTotem'); AB:AdjustTotemSettings() end,
				},			
				mouseover = {
					order = 3,
					name = L['Mouse Over'],
					desc = L['The frame is not shown unless you mouse over the frame.'],
					type = "toggle",
				},				
			},
		}
	end
end

E.Options.args.actionbar = {
	type = "group",
	name = L["ActionBars"],
	childGroups = "select",
	get = function(info) return E.db.actionbar[ info[#info] ] end,
	set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB:UpdateButtonSettings() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			set = function(info, value) E.db.actionbar[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end
		},
		toggleAnchors = {
			order = 2,
			type = "execute",
			name = L["Toggle Anchors"],
			func = function() E:MoveUI(true, 'actionbars'); end,
			disabled = function() return not E.db.actionbar.enable end,
		},
		toggleKeybind = {
			order = 3,
			type = "execute",
			name = L["Keybind Mode"],
			func = function() AB:ActivateBindMode(); E:ToggleConfig(); GameTooltip:Hide(); end,
			disabled = function() return not E.db.actionbar.enable; end,
		},		
		macrotext = {
			type = "toggle",
			name = L['Macro Text'],
			desc = L['Display macro names on action buttons.'],
			order = 4,
			disabled = function() return not E.db.actionbar.enable end,
		},
		hotkeytext = {
			type = "toggle",
			name = L['Keybind Text'],
			desc = L['Display bind names on action buttons.'],	
			order = 5,
			disabled = function() return not E.db.actionbar.enable end,
		},
		fontsize = {
			type = 'range',
			name = L['Font Size'],
			desc = L['Set the font size of the action buttons.'],
			min = 5, max = 18, step = 1,
			order = 6,
			disabled = function() return not E.db.actionbar.enable end,
		},		
	},
}
group = E.Options.args.actionbar.args
BuildABConfig()