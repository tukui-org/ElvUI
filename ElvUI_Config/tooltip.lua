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
					name = L["Cursor Anchor"],
					desc = L["Should tooltip be anchored to mouse cursor"],
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
					name = L["Player Titles"],
					desc = L["Display player titles."],
				},
				guildRanks = {
					order = 4,
					type = 'toggle',
					name = L["Guild Ranks"],
					desc = L["Display guild ranks if a unit is guilded."],
				},
				inspectInfo = {
					order = 5,
					type = 'toggle',
					name = L["Inspect Info"],
					desc = L["Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit."],
				},
				spellID = {
					order = 6,
					type = 'toggle',
					name = L["Spell/Item IDs"],
					desc = L["Display the spell or item ID when mousing over a spell or item tooltip."],
				},
				itemCount = {
					order = 7,
					type = 'select',
					name = L["Item Count"],
					desc = L["Display how many of a certain item you have in your possession."],
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
					name = L["Custom Faction Colors"],
				},
				fontGroup = {
					order = 9,
					type = "group",
					guiInline = true,
					name = L["Tooltip Font Settings"],
					args = {
						font = {
							order = 1,
							type = "select", dialogControl = 'LSM30_Font',
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.db.tooltip.font end,
							set = function(info, value) E.db.tooltip.font = value; TT:SetTooltipFonts() end,
						},
						fontOutline = {
							order = 2,
							name = L["Font Outline"],
							type = "select",
							values = {
								['NONE'] = L["None"],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
							get = function(info) return E.db.tooltip.fontOutline end,
							set = function(info, value) E.db.tooltip.fontOutline = value; TT:SetTooltipFonts() end,
						},
						spacer = {
							order = 3,
							type = "description",
							name = "",
						},
						headerFontSize = {
							order = 4,
							type = "range",
							name = L["Header Font Size"],
							min = 4, max = 50, step = 1,
							get = function(info) return E.db.tooltip.headerFontSize end,
							set = function(info, value) E.db.tooltip.headerFontSize = value; TT:SetTooltipFonts() end,
						},
						textFontSize = {
							order = 5,
							type = "range",
							name = L["Text Font Size"],
							min = 4, max = 30, step = 1,
							get = function(info) return E.db.tooltip.textFontSize end,
							set = function(info, value) E.db.tooltip.textFontSize = value; TT:SetTooltipFonts() end,
						},
						smallTextFontSize = {
							order = 6,
							type = "range",
							name = L["Comparison Font Size"],
							desc = L["This setting controls the size of text in item comparison tooltips."],
							min = 4, max = 30, step = 1,
							get = function(info) return E.db.tooltip.smallTextFontSize end,
							set = function(info, value) E.db.tooltip.smallTextFontSize = value; TT:SetTooltipFonts() end,
						},
					},
				},
				factionColors = {
					order = 10,
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
				actionbars = {
					order = 1,
					type = 'select',
					name = L["ActionBars"],
					desc = L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."],
					values = {
						['ALL'] = L["Always Hide"],
						['NONE'] = L["Never Hide"],
						['SHIFT'] = SHIFT_KEY,
						['ALT'] = ALT_KEY,
						['CTRL'] = CTRL_KEY
					},
				},
				bags = {
					order = 2,
					type = 'select',
					name = L["Bags/Bank"],
					desc = L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."],
					values = {
						['ALL'] = L["Always Hide"],
						['NONE'] = L["Never Hide"],
						['SHIFT'] = SHIFT_KEY,
						['ALT'] = ALT_KEY,
						['CTRL'] = CTRL_KEY
					},
				},
				unitFrames = {
					order = 3,
					type = 'select',
					name = L["UnitFrames"],
					desc = L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."],
					values = {
						['ALL'] = L["Always Hide"],
						['NONE'] = L["Never Hide"],
						['SHIFT'] = SHIFT_KEY,
						['ALT'] = ALT_KEY,
						['CTRL'] = CTRL_KEY
					},
				},
				combat = {
					order = 4,
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
					name = L["Height"],
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
							min = 4, max = 22, step = 1,
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