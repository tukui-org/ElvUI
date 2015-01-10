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
				inspectInfo = {
					order = 5,
					type = 'toggle',
					name = L['Inspect Info'],
					desc = L['Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit.'],
				},
				spellID = {
					order = 6,
					type = 'toggle',
					name = L['Spell/Item IDs'],
					desc = L['Display the spell or item ID when mousing over a spell or item tooltip.'],
				},
				itemCount = {
					order = 7,
					type = 'select',
					name = L['Item Count'],
					desc = L['Display how many of a certain item you have in your possession.'],
					values = {
						["BAGS_ONLY"] = L["Bags Only"],
						["BANK_ONLY"] = L["Bank Only"],
						["BOTH"] = L["Both"],
						["NONE"] = L["None"],
					},
				},
				useCustomFactionColors = {
					order = 8,
					type = 'toggle',
					name = L['Custom Faction Colors'],
				},
				factionColors = {
					order = 9,
					type = "group",
					name = L["Custom Faction Colors"],
					guiInline = true,
					args = {},
					get = function(info)
						local t = E.db.tooltip.factionColors[ info[#info] ]
						local d = P.tooltip.factionColors[ info[#info] ]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.tooltip.factionColors[ info[#info] ] = {}
						local t = E.db.tooltip.factionColors[ info[#info] ]
						t.r, t.g, t.b = r, g, b
					end,
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

for i = 1, 8 do
	E.Options.args.tooltip.args.general.args.factionColors.args[""..i] = {
		order = i,
		type = "color",
		hasAlpha = false,
		name = _G["FACTION_STANDING_LABEL"..i],
		disabled = function() return not E.Tooltip or not E.db.tooltip.useCustomFactionColors end,
	}
end