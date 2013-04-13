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
			guiInline = true,
			disabled = function() return not E.Tooltip; end,
			args = {
				anchor = {
					order = 1,
					type = 'select',
					name = L['Anchor Mode'],
					desc = L['Set the type of anchor mode the tooltip should use.'],
					values = {
						['SMART'] = L['Smart'],
						['CURSOR'] = L['Cursor'],
						['ANCHOR'] = L['Anchor'],
					},
				},
				ufhide = {
					order = 2,
					type = 'select',
					name = L['UF Hide'],
					desc = L["Don't display the tooltip when mousing over a unitframe."],
					values = {
						['ALL'] = L['Always Hide'],
						['NONE'] = L['Never Hide'],
						['SHIFT'] = SHIFT_KEY,
						['ALT'] = ALT_KEY,
						['CTRL'] = CTRL_KEY					
					},
				},
				whostarget = {
					order = 3,
					type = 'toggle',
					name = L["Who's targeting who?"],
					desc = L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."],
				},
				combathide = {
					order = 4,
					type = 'toggle',
					name = L["Combat Hide"],
					desc = L["Hide tooltip while in combat."],
				},
				guildranks = {
					order = 5,
					type = 'toggle',
					name = L['Guild Ranks'],
					desc = L['Display guild ranks if a unit is guilded.'],
				},
				titles = {
					order = 6,
					type = 'toggle',
					name = L['Player Titles'],
					desc = L['Display player titles.'],
				},
				talentSpec = {
					order = 7,
					type = 'toggle',
					name = L['Talent Spec'],
					desc = L['Display the players talent spec in the tooltip, this may not immediately update when mousing over a unit.'],
				},
				spellid = {
					order = 8,
					type = 'toggle',
					name = L['Spell/Item IDs'],
					desc = L['Display the spell or item ID when mousing over a spell or item tooltip.'],				
				},
				count = {
					order = 9,
					type = 'toggle',
					name = L['Item Count'],
					desc = L['Display how many of a certain item you have in your possession.'],				
				},		
				health = {
					order = 10,
					type = 'toggle',
					name = L['Health Text'],
					desc = L['Display the health text on the tooltip.'],
					set = function(info, value) E.db.tooltip[ info[#info] ] = value; if value then GameTooltipStatusBar.text:Show(); else GameTooltipStatusBar.text:Hide() end  end,
				},
				healthHeight = {
					order = 11,
					type = 'range',
					name = L['Health Height'],
					desc = L['Set the height of the tooltip healthbar.'],
					min = 1, max = 15, step = 1,
					set = function(info, value) E.db.tooltip[ info[#info] ] = value; GameTooltipStatusBar:Height(value); end,
				},				
			},
		},
	},
}