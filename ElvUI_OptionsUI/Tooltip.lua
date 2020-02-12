local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local TT = E:GetModule('Tooltip')

local _G = _G
local tonumber = tonumber
local GameTooltip = _G.GameTooltip
local GameTooltipStatusBar = _G.GameTooltipStatusBar

E.Options.args.tooltip = {
	type = "group",
	name = L["Tooltip"],
	childGroups = "tree",
	order = 2,
	get = function(info) return E.db.tooltip[info[#info]] end,
	set = function(info, value) E.db.tooltip[info[#info]] = value; end,
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
			get = function(info) return E.private.tooltip[info[#info]] end,
			set = function(info, value) E.private.tooltip[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		role = {
			order = 3,
			type = 'toggle',
			name = L["ROLE"],
			desc = L["Display the unit role in the tooltip."],
		},
		targetInfo = {
			order = 4,
			type = 'toggle',
			name = L["Target Info"],
			desc = L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."],
		},
		npcID = {
			order = 5,
			type = 'toggle',
			name = L["NPC IDs"],
			desc = L["Display the npc ID when mousing over a npc tooltip."],
		},
		playerTitles = {
			order = 6,
			type = 'toggle',
			name = L["Player Titles"],
			desc = L["Display player titles."],
		},
		guildRanks = {
			order = 7,
			type = 'toggle',
			name = L["Guild Ranks"],
			desc = L["Display guild ranks if a unit is guilded."],
		},
		showMount = {
			order = 8,
			type = 'toggle',
			name = L["Current Mount"],
			desc = L["Display current mount the unit is riding."],
		},
		spellID = {
			order = 9,
			type = 'toggle',
			name = L["Spell/Item IDs"],
			desc = L["Display the spell or item ID when mousing over a spell or item tooltip."],
		},
		alwaysShowRealm = {
			order = 10,
			type = 'toggle',
			name = L["Always Show Realm"],
		},
		showElvUIUsers = {
			order = 11,
			type = 'toggle',
			name = L["Show ElvUI Users"],
			desc = L["Show ElvUI users and their version of ElvUI."]
		},
		cursorAnchor = {
			order = 12,
			type = 'toggle',
			name = L["Cursor Anchor"],
			desc = L["Should tooltip be anchored to mouse cursor"],
		},
		cursorAnchorType = {
			order = 13,
			type = 'select',
			name = L["Cursor Anchor Type"],
			values = {
				["ANCHOR_CURSOR"] = L["ANCHOR_CURSOR"],
				["ANCHOR_CURSOR_LEFT"] = L["ANCHOR_CURSOR_LEFT"],
				["ANCHOR_CURSOR_RIGHT"] = L["ANCHOR_CURSOR_RIGHT"],
			},
			disabled = function() return (not E.db.tooltip.cursorAnchor) end,
		},
		itemCount = {
			order = 14,
			type = 'select',
			name = L["Item Count"],
			desc = L["Display how many of a certain item you have in your possession."],
			values = {
				["BAGS_ONLY"] = L["Bags Only"],
				["BANK_ONLY"] = L["Bank Only"],
				["BOTH"] = L["Both"],
				["NONE"] = L["NONE"],
			},
		},
		colorAlpha = {
			order = 15,
			type = "range",
			name = L["OPACITY"],
			isPercent = true,
			min = 0, max = 1, step = 0.01,
		},
		cursorAnchorX = {
			order = 16,
			name = L["Cursor Anchor Offset X"],
			type = "range",
			min = -128, max = 128, step = 1,
			disabled = function() return (not E.db.tooltip.cursorAnchor) or (E.db.tooltip.cursorAnchorType == "ANCHOR_CURSOR") end,
		},
		cursorAnchorY = {
			order = 17,
			type = "range",
			name = L["Cursor Anchor Offset Y"],
			min = -128, max = 128, step = 1,
			disabled = function() return (not E.db.tooltip.cursorAnchor) or (E.db.tooltip.cursorAnchorType == "ANCHOR_CURSOR") end,
		},
		fontGroup = {
			order = 30,
			type = "group",
			name = L["Font"],
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
					values = C.Values.FontFlags,
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
		visibility = {
			order = 31,
			type = "group",
			name = L["Visibility"],
			get = function(info) return E.db.tooltip.visibility[info[#info]] end,
			set = function(info, value) E.db.tooltip.visibility[info[#info]] = value; end,
			args = {
				actionbars = {
					order = 1,
					type = 'select',
					name = L["ActionBars"],
					desc = L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."],
					values = {
						['ALL'] = L["Always Hide"],
						['NONE'] = L["Never Hide"],
						['SHIFT'] = L["SHIFT_KEY_TEXT"],
						['ALT'] = L["ALT_KEY_TEXT"],
						['CTRL'] = L["CTRL_KEY_TEXT"],
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
						['SHIFT'] = L["SHIFT_KEY_TEXT"],
						['ALT'] = L["ALT_KEY_TEXT"],
						['CTRL'] = L["CTRL_KEY_TEXT"],
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
						['SHIFT'] = L["SHIFT_KEY_TEXT"],
						['ALT'] = L["ALT_KEY_TEXT"],
						['CTRL'] = L["CTRL_KEY_TEXT"],
					},
				},
				combat = {
					order = 4,
					type = 'toggle',
					name = L["COMBAT"],
					desc = L["Hide tooltip while in combat."],
				},
				combatOverride = {
					order = 5,
					type = 'select',
					name = L["Combat Override Key"],
					desc = L["Choose when you want the tooltip to show in combat. If a modifer is chosen, then you need to hold that down to show the tooltip."],
					disabled = function() return not E.db.tooltip.visibility.combat end,
					values = {
						['ALL'] = L["Always Hide"],
						['SHIFT'] = L["SHIFT_KEY_TEXT"],
						['ALT'] = L["ALT_KEY_TEXT"],
						['CTRL'] = L["CTRL_KEY_TEXT"],
					},
				},
			},
		},
		healthBar = {
			order = 33,
			type = "group",
			name = L["Health Bar"],
			get = function(info) return E.db.tooltip.healthBar[info[#info]] end,
			set = function(info, value) E.db.tooltip.healthBar[info[#info]] = value; end,
			args = {
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
							GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
						end
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end,
				},
				fontSize = {
					order = 5,
					name = L["FONT_SIZE"],
					type = "range",
					min = 4, max = 500, step = 1,
					set = function(info, value)
						E.db.tooltip.healthBar.fontSize = value;
						if not GameTooltip:IsForbidden() then
							GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
						end
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end,
				},
				fontOutline = {
					order = 6,
					name = L["Font Outline"],
					type = "select",
					values = C.Values.FontFlags,
					set = function(info, value)
						E.db.tooltip.healthBar.fontOutline = value;
						if not GameTooltip:IsForbidden() then
							GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
						end
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end,
				},
			},
		},
		factionColors = {
			order = 34,
			type = "group",
			name = L["Custom Faction Colors"],
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
				local v = tonumber(info[#info])
				local t = E.db.tooltip.factionColors[v]
				local d = P.tooltip.factionColors[v]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				local v = tonumber(info[#info])
				local t = E.db.tooltip.factionColors[v]
				t.r, t.g, t.b = r, g, b
			end,
		},
	},
}

for i = 1, 8 do
	E.Options.args.tooltip.args.factionColors.args[""..i] = {
		order = i,
		type = "color",
		hasAlpha = false,
		name = L["FACTION_STANDING_LABEL"..i],
		disabled = function() return not E.Tooltip.Initialized or not E.db.tooltip.useCustomFactionColors end,
	}
end
