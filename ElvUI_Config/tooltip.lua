local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TT = E:GetModule('Tooltip')

local _G = _G
local GameTooltip = _G['GameTooltip']
local GameTooltipStatusBar = _G['GameTooltipStatusBar']

E.Options.args.tooltip = {
	type = "group",
	name = L["Tooltip"],
	childGroups = "tab",
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
				header = {
					order = 0,
					type = "header",
					name = L["General"],
				},
				cursorAnchor = {
					order = 1,
					type = 'toggle',
					name = L["Cursor Anchor"],
					desc = L["Should tooltip be anchored to mouse cursor"],
				},
				cursorAnchorType = {
					order = 2,
					type = 'select',
					name = L["Cursor Anchor Type"],
					values = {
						["ANCHOR_CURSOR"] = L["ANCHOR_CURSOR"],
						["ANCHOR_CURSOR_LEFT"] = L["ANCHOR_CURSOR_LEFT"],
						["ANCHOR_CURSOR_RIGHT"] = L["ANCHOR_CURSOR_RIGHT"],
					},
					disabled = function() return (not E.db.tooltip.cursorAnchor) end,
				},
				cursorAnchorX = {
					order = 3,
					name = L["Cursor Anchor Offset X"],
					type = "range",
					min = -128, max = 128, step = 1,
					disabled = function() return (not E.db.tooltip.cursorAnchor) or (E.db.tooltip.cursorAnchorType == "ANCHOR_CURSOR") end,
				},
				cursorAnchorY = {
					order = 4,
					type = "range",
					name = L["Cursor Anchor Offset Y"],
					min = -128, max = 128, step = 1,
					disabled = function() return (not E.db.tooltip.cursorAnchor) or (E.db.tooltip.cursorAnchorType == "ANCHOR_CURSOR") end,
				},
				targetInfo = {
					order = 5,
					type = 'toggle',
					name = L["Target Info"],
					desc = L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."],
				},
				alwaysShowRealm = {
					order = 6,
					type = 'toggle',
					name = L["Always Show Realm"],
				},
				playerTitles = {
					order = 7,
					type = 'toggle',
					name = L["Player Titles"],
					desc = L["Display player titles."],
				},
				guildRanks = {
					order = 8,
					type = 'toggle',
					name = L["Guild Ranks"],
					desc = L["Display guild ranks if a unit is guilded."],
				},
				inspectInfo = {
					order = 9,
					type = 'toggle',
					name = L["Inspect Info"],
					desc = L["Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit."],
				},
				spellID = {
					order = 10,
					type = 'toggle',
					name = L["Spell/Item IDs"],
					desc = L["Display the spell or item ID when mousing over a spell or item tooltip."],
				},
				npcID = {
					order = 11,
					type = 'toggle',
					name = L["NPC IDs"],
					desc = L["Display the npc ID when mousing over a npc tooltip."],
				},
				role = {
					order = 12,
					type = 'toggle',
					name = ROLE,
					desc = L["Display the unit role in the tooltip."],
				},
				itemCount = {
					order = 13,
					type = 'select',
					name = L["Item Count"],
					desc = L["Display how many of a certain item you have in your possession."],
					values = {
						["BAGS_ONLY"] = L["Bags Only"],
						["BANK_ONLY"] = L["Bank Only"],
						["BOTH"] = L["Both"],
						["NONE"] = NONE,
					},
				},
				colorAlpha = {
					order = 14,
					type = "range",
					name = OPACITY,
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				fontGroup = {
					order = 15,
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
								['NONE'] = NONE,
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
							min = 4, max = 212, step = 1,
							get = function(info) return E.db.tooltip.headerFontSize end,
							set = function(info, value) E.db.tooltip.headerFontSize = value; TT:SetTooltipFonts() end,
						},
						textFontSize = {
							order = 5,
							type = "range",
							name = L["Text Font Size"],
							min = 4, max = 212, step = 1,
							get = function(info) return E.db.tooltip.textFontSize end,
							set = function(info, value) E.db.tooltip.textFontSize = value; TT:SetTooltipFonts() end,
						},
						smallTextFontSize = {
							order = 6,
							type = "range",
							name = L["Comparison Font Size"],
							desc = L["This setting controls the size of text in item comparison tooltips."],
							min = 4, max = 212, step = 1,
							get = function(info) return E.db.tooltip.smallTextFontSize end,
							set = function(info, value) E.db.tooltip.smallTextFontSize = value; TT:SetTooltipFonts() end,
						},
					},
				},
				factionColors = {
					order = 16,
					type = "group",
					name = L["Custom Faction Colors"],
					guiInline = true,
					args = {
						useCustomFactionColors = {
							order = 0,
							type = 'toggle',
							name = L["Custom Faction Colors"],
							get = function(info) return E.db.tooltip.useCustomFactionColors end,
							set = function(info, value) E.db.tooltip.useCustomFactionColors = value; end,
						},
					},
					get = function(info)
						local t = E.db.tooltip.factionColors[ info[#info] ]
						local d = P.tooltip.factionColors[ info[#info] ]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
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
				header = {
					order = 0,
					type = "header",
					name = L["Visibility"],
				},
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
				header = {
					order = 0,
					type = "header",
					name = L["Health Bar"],
				},
				height = {
					order = 1,
					name = L["Height"],
					type = 'range',
					min = 1, max = 15, step = 1,
					set = function(info, value) E.db.tooltip.healthBar.height = value;
						if not GameTooltip:IsForbidden() then
							GameTooltipStatusBar:Height(value);
						end
					end,
				},
				statusPosition = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = {
						["BOTTOM"] = L["Bottom"],
						["TOP"] = L["Top"],
					},
				},
				text = {
					order = 3,
					type = "toggle",
					name = L["Text"],
					set = function(info, value)
						E.db.tooltip.healthBar.text = value;
						if not GameTooltip:IsForbidden() then
							if value then
								GameTooltipStatusBar.text:Show();
							else
								GameTooltipStatusBar.text:Hide()
							end
						end
					end,
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 4,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value)
						E.db.tooltip.healthBar.font = value;
						if not GameTooltip:IsForbidden() then
							GameTooltipStatusBar.text:FontTemplate(E.LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
						end
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end,
				},
				fontSize = {
					order = 5,
					name = FONT_SIZE,
					type = "range",
					min = 4, max = 500, step = 1,
					set = function(info, value)
						E.db.tooltip.healthBar.fontSize = value;
						if not GameTooltip:IsForbidden() then
							GameTooltipStatusBar.text:FontTemplate(E.LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
						end
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end,
				},
				fontOutline = {
					order = 6,
					name = L["Font Outline"],
					type = "select",
					values = {
						['NONE'] = NONE,
						['OUTLINE'] = 'OUTLINE',
						['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
					set = function(info, value)
						E.db.tooltip.healthBar.fontOutline = value;
						if not GameTooltip:IsForbidden() then
							GameTooltipStatusBar.text:FontTemplate(E.LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
						end
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end,
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
