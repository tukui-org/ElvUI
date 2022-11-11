local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local TT = E:GetModule('Tooltip')
local Skins = E:GetModule('Skins')
local ACH = E.Libs.ACH

local tonumber = tonumber
local GameTooltip = GameTooltip
local GameTooltipStatusBar = GameTooltipStatusBar

local modifierValues = { SHOW = L["Show"], HIDE = L["Hide"], SHIFT = L["SHIFT_KEY_TEXT"], CTRL = L["CTRL_KEY_TEXT"], ALT = L["ALT_KEY_TEXT"] }

E.Options.args.tooltip = ACH:Group(L["Tooltip"], nil, 2, 'tab', function(info) return E.db.tooltip[info[#info]] end, function(info, value) E.db.tooltip[info[#info]] = value; end)
local Tooltip = E.Options.args.tooltip.args

Tooltip.intro = ACH:Description(L["TOOLTIP_DESC"], 1)
Tooltip.enable = ACH:Toggle(L["Enable"], nil, 2, nil, nil, nil, function(info) return E.private.tooltip[info[#info]] end, function(info, value) E.private.tooltip[info[#info]] = value; E.ShowPopup = true end)

Tooltip.general = ACH:Group(L["General"], nil, 6, 'tree')
local General = Tooltip.general.args

General.targetInfo = ACH:Toggle(L["Target Info"], L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."], 1)
General.playerTitles = ACH:Toggle(L["Player Titles"], L["Display player titles."], 2)
General.guildRanks = ACH:Toggle(L["Guild Ranks"], L["Display guild ranks if a unit is guilded."], 3)
General.alwaysShowRealm = ACH:Toggle(L["Always Show Realm"], nil, 4)
General.role = ACH:Toggle(L["ROLE"], L["Display the unit role in the tooltip."], 5, nil, nil, nil, nil, nil, nil, not E.Retail)
General.showMount = ACH:Toggle(L["Current Mount"], L["Display current mount the unit is riding."], 6, nil, nil, nil, nil, nil, nil, not E.Retail)
General.gender = ACH:Toggle(L["Gender"], L["Displays the gender of players."], 7)
General.showElvUIUsers = ACH:Toggle(L["Show ElvUI Users"], L["Show ElvUI users and their version of ElvUI."], 8)
General.itemQuality = ACH:Toggle(L["Item Quality"], L["Color tooltip border based on Item Quality."], 9)
General.inspectDataEnable = ACH:Toggle(L["Inspect Data"], L["Display the item level and current specialization of the unit on modifier press."], 10, nil, nil, nil, nil, nil, nil, not E.Retail)
General.colorAlpha = ACH:Range(L["OPACITY"], nil, 11, { isPercent = true, min = 0, max = 1, step = 0.01 }, nil, nil, function(info, value) E.db.tooltip[info[#info]] = value; Skins:StyleTooltips() end)

General.modifierGroup = ACH:Group(L["Spell/Item IDs"], nil, -2)
General.modifierGroup.args.modifierID = ACH:Select(L["Modifier for IDs"], nil, 1, modifierValues)
General.modifierGroup.args.itemCount = ACH:Select(L["Item Count"], L["Display how many of a certain item you have in your possession."], 2, { BAGS_ONLY = L["Bags Only"], BANK_ONLY = L["Bank Only"], BOTH = L["Both"], NONE = L["None"] })
General.modifierGroup.args.modifierCount = ACH:Toggle(L["Modifier Count"], L["Use Modifier for Item Count"], 3, nil, nil, nil, nil, nil, function() return E.db.tooltip.itemCount == 'NONE' end)
General.modifierGroup.inline = true

General.mythicPlus = ACH:Group(L["Mythic+ Data"], nil, -1, nil, nil, nil, nil, not E.Retail)
General.mythicPlus.args.mythicDataEnable = ACH:Toggle(L["Enable"], nil, 1)
General.mythicPlus.args.dungeonScore = ACH:Toggle(L["Mythic+ Score"], L["Display the current Mythic+ Dungeon Score."], 2, nil, nil, nil, nil, nil, function() return not E.db.tooltip.mythicDataEnable end)
General.mythicPlus.args.mythicBestRun = ACH:Toggle(L["Mythic+ Best Run"], nil, 3, nil, nil, nil, nil, nil, function() return not E.db.tooltip.mythicDataEnable end)
General.mythicPlus.args.dungeonScoreColor = ACH:Toggle(L["Color Score"], L["Color score based on Blizzards API."], 4, nil, nil, nil, nil, nil, function() return not E.db.tooltip.mythicDataEnable end)
General.mythicPlus.inline = true

General.anchorGroup = ACH:Group(L["Cursor Anchor"], nil, 50)
General.anchorGroup.args.cursorAnchor = ACH:Toggle(L["Enable"], L["Should tooltip be anchored to mouse cursor"], 1)
General.anchorGroup.args.spacer = ACH:Spacer(2)
General.anchorGroup.args.cursorAnchorType = ACH:Select(L["Cursor Anchor Type"], nil, 6, { ANCHOR_CURSOR = L["CURSOR"], ANCHOR_CURSOR_LEFT = L["CURSOR_LEFT"], ANCHOR_CURSOR_RIGHT = L["CURSOR_RIGHT"] }, nil, nil, nil, nil, function() return not E.db.tooltip.cursorAnchor end)
General.anchorGroup.args.cursorAnchorX = ACH:Range(L["Cursor Anchor Offset X"], nil, 7, { min = -128, max = 128, step = 1 }, nil, nil, nil, function() return not E.db.tooltip.cursorAnchor or E.db.tooltip.cursorAnchorType == 'ANCHOR_CURSOR' end)
General.anchorGroup.args.cursorAnchorY = ACH:Range(L["Cursor Anchor Offset Y"], nil, 8, { min = -128, max = 128, step = 1 }, nil, nil, nil, function() return not E.db.tooltip.cursorAnchor or E.db.tooltip.cursorAnchorType == 'ANCHOR_CURSOR' end)

General.factionColors = ACH:Group(L["Custom Faction Colors"], nil, 60, nil, function(info) local v = tonumber(info[#info]) local t = E.db.tooltip.factionColors[v] local d = P.tooltip.factionColors[v] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local v = tonumber(info[#info]); local t = E.db.tooltip.factionColors[v]; t.r, t.g, t.b = r, g, b end)
General.factionColors.args.useCustomFactionColors = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function() return E.db.tooltip.useCustomFactionColors end, function(_, value) E.db.tooltip.useCustomFactionColors = value; end)

for i = 1, 8 do
	General.factionColors.args[''..i] = ACH:Color(L["FACTION_STANDING_LABEL"..i], nil, i, true, nil, nil, nil, function() return not E.Tooltip.Initialized or not E.db.tooltip.useCustomFactionColors end)
end

General.fontGroup = ACH:Group(L["Font"], nil, 70, nil, function(info) return E.db.tooltip[info[#info]] end, function(info, value) E.db.tooltip[info[#info]] = value; TT:SetTooltipFonts() end)
General.fontGroup.args.smallTextFontSize = ACH:Range(L["Comparison Font Size"], L["This setting controls the size of text in item comparison tooltips."], 1, C.Values.FontSize)
General.fontGroup.args.spacer = ACH:Spacer(2)

General.fontGroup.args.header = ACH:Group(L["Tooltip Header"], nil, 3)
General.fontGroup.args.header.args.headerFont = ACH:SharedMediaFont(L["Font"], nil, 1)
General.fontGroup.args.header.args.headerFontOutline = ACH:Select(L["Font Outline"], nil, 2, C.Values.FontFlags)
General.fontGroup.args.header.args.headerFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
General.fontGroup.args.header.inline = true

General.fontGroup.args.body = ACH:Group(L["Tooltip Body"], nil, 4)
General.fontGroup.args.body.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
General.fontGroup.args.body.args.fontOutline = ACH:Select(L["Font Outline"], nil, 2, C.Values.FontFlags)
General.fontGroup.args.body.args.textFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
General.fontGroup.args.body.inline = true

General.healthBar = ACH:Group(L["Health Bar"], nil, 80, nil, function(info) return E.db.tooltip.healthBar[info[#info]] end, function(info, value) E.db.tooltip.healthBar[info[#info]] = value; end)
General.healthBar.args.statusPosition = ACH:Select(L["Position"], nil, 1, { BOTTOM = L["Bottom"], TOP = L["Top"], DISABLED = L["Disabled"] })
General.healthBar.args.height = ACH:Range(L["Height"], nil, 3, { min = 2, max = 15, step = 1 }, nil, nil, function(_, value) E.db.tooltip.healthBar.height = value; if not GameTooltip:IsForbidden() then GameTooltipStatusBar:Height(value); end end, function() return E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)
General.healthBar.args.text = ACH:Toggle(L["Text"], nil, 3, nil, nil, nil, nil, function(_, value) E.db.tooltip.healthBar.text = value; if not GameTooltip:IsForbidden() then if value then GameTooltipStatusBar.text:Show(); else GameTooltipStatusBar.text:Hide() end end end, function() return E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)
General.healthBar.args.font = ACH:SharedMediaFont(L["Font"], nil, 4, nil, nil, function(_, value) E.db.tooltip.healthBar.font = value; if not GameTooltip:IsForbidden() then GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch('font', E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline) end end, function() return not E.db.tooltip.healthBar.text or E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)
General.healthBar.args.fontSize = ACH:Range(L["Font Size"], nil, 5, C.Values.FontSize, nil, nil, function(_, value) E.db.tooltip.healthBar.fontSize = value; if not GameTooltip:IsForbidden() then GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch('font', E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline) end end, function() return not E.db.tooltip.healthBar.text or E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)
General.healthBar.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 6, nil, nil, function(_, value) E.db.tooltip.healthBar.fontOutline = value; if not GameTooltip:IsForbidden() then GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch('font', E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline) end end, function() return not E.db.tooltip.healthBar.text or E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)

General.visibility = ACH:Group(L["Visibility"], nil, 90, nil, function(info) return E.db.tooltip.visibility[info[#info]] end, function(info, value) E.db.tooltip.visibility[info[#info]] = value; end)
General.visibility.args.actionbars = ACH:Select(L["ActionBars"], L["Choose when you want the tooltip to show. If a modifier is chosen, then you need to hold that down to show the tooltip."], 1, modifierValues)
General.visibility.args.bags = ACH:Select(L["Bags/Bank"], L["Choose when you want the tooltip to show. If a modifier is chosen, then you need to hold that down to show the tooltip."], 2, modifierValues)
General.visibility.args.unitFrames = ACH:Select(L["UnitFrames"], L["Choose when you want the tooltip to show. If a modifier is chosen, then you need to hold that down to show the tooltip."], 3, modifierValues)
General.visibility.args.combatOverride = ACH:Select(L["Combat Override Key"], L["Choose when you want the tooltip to show in combat. If a modifier is chosen, then you need to hold that down to show the tooltip."], 4, modifierValues)
