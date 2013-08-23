local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TT = E:GetModule('Tooltip')


E.Options.args.tooltip = {
	type = "group",
	name = L["Tooltip"],
	childGroups = "select",
	get = function(info) return E.db.tooltip[ info[#info] ] end,
	set = function(info, value) E.db.tooltip[ info[#info] ] = value; end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["TOOLTIP_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.tooltip[ info[#info] ] end,
			set = function(info, value) E.private.tooltip[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			disabled = function() return not E.Tooltip; end,
			args = {
				cursorAnchor = {
					order = 1,
					type = 'toggle',
					name = L['Cursor Anchor'],
					desc = L['Should tooltip be anchored to mouse cursor'],
				},
				targetInfo = {
					order = 2,
					type = 'toggle',
					name = L["Target Info"],
					desc = L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."],
				},	
				playerTitles = {
					order = 3,
					type = 'toggle',
					name = L['Player Titles'],
					desc = L['Display player titles.'],
				},				
				guildRanks = {
					order = 4,
					type = 'toggle',
					name = L['Guild Ranks'],
					desc = L['Display guild ranks if a unit is guilded.'],
				},
				talentInfo = {
					order = 5,
					type = 'toggle',
					name = L['Talent Spec'],
					desc = L['Display the players talent spec in the tooltip, this may not immediately update when mousing over a unit.'],
				},
				itemCount = {
					order = 6,
					type = 'toggle',
					name = L['Item Count'],
					desc = L['Display how many of a certain item you have in your possession.'],				
				},				
				spellID = {
					order = 7,
					type = 'toggle',
					name = L['Spell/Item IDs'],
					desc = L['Display the spell or item ID when mousing over a spell or item tooltip.'],				
				},
			},
		},
		visibility = {
			order = 100,
			type = "group",
			name = L["Visibility"],
			get = function(info) return E.db.tooltip.visibility[ info[#info] ] end,
			set = function(info, value) E.db.tooltip.visibility[ info[#info] ] = value; end,
			args = {
				unitFrames = {
					order = 1,
					type = 'select',
					name = L['Unitframes'],
					desc = L["Don't display the tooltip when mousing over a unitframe."],
					values = {
						['ALL'] = L['Always Hide'],
						['NONE'] = L['Never Hide'],
						['SHIFT'] = SHIFT_KEY,
						['ALT'] = ALT_KEY,
						['CTRL'] = CTRL_KEY					
					},
				},
				combat = {
					order = 2,
					type = 'toggle',
					name = COMBAT,
					desc = L["Hide tooltip while in combat."],
				},						
			},
		},
		healthBar = {
			order = 200,
			type = "group",
			name = L["Health Bar"],
			get = function(info) return E.db.tooltip.healthBar[ info[#info] ] end,
			set = function(info, value) E.db.tooltip.healthBar[ info[#info] ] = value; end,			
			args = {
				height = {
					order = 1,
					name = L['Height'],
					type = 'range',
					min = 1, max = 15, step = 1,
					set = function(info, value) E.db.tooltip.healthBar.height = value; GameTooltipStatusBar:Height(value); end,
				},
				fontGroup = {
					order = 2,
					name = L["Fonts"],
					type = "group",
					guiInline = true,
					args = {
						text = {
							order = 1,
							type = "toggle",
							name = L["Text"],
							set = function(info, value) E.db.tooltip.healthBar.text = value; if value then GameTooltipStatusBar.text:Show(); else GameTooltipStatusBar.text:Hide() end  end,
						},
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 2,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) 
								E.db.tooltip.healthBar.font = value; 
								GameTooltipStatusBar.text:FontTemplate(E.LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, "OUTLINE")
							end,
						},
						fontSize = {
							order = 3,
							name = L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1,
							set = function(info, value) 
								E.db.tooltip.healthBar.fontSize = value; 
								GameTooltipStatusBar.text:FontTemplate(E.LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, "OUTLINE")
							end,								
						},
					},
				},
			},
		},		
	},
}