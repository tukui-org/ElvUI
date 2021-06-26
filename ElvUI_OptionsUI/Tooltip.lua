local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local TT = E:GetModule('Tooltip')
local Skins = E:GetModule('Skins')
local ACH = E.Libs.ACH

local _G = _G
local tonumber = tonumber
local GameTooltip = _G.GameTooltip
local GameTooltipStatusBar = _G.GameTooltipStatusBar

local modifierValues = { SHOW = L["Show"], HIDE = L["Hide"], SHIFT = L["SHIFT_KEY_TEXT"], CTRL = L["CTRL_KEY_TEXT"], ALT = L["ALT_KEY_TEXT"] }

E.Options.args.tooltip = ACH:Group(L["Tooltip"], nil, 2, 'tree', function(info) return E.db.tooltip[info[#info]] end, function(info, value) E.db.tooltip[info[#info]] = value; end)
E.Options.args.tooltip.args.intro = ACH:Description(L["TOOLTIP_DESC"], 1)
E.Options.args.tooltip.args.enable = ACH:Toggle(L["Enable"], nil, 2, nil, nil, nil, function(info) return E.private.tooltip[info[#info]] end, function(info, value) E.private.tooltip[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.tooltip.args.modifierID = ACH:Select(L["Modifier for IDs"], nil, 3, modifierValues)
E.Options.args.tooltip.args.itemCount = ACH:Select(L["Item Count"], L["Display how many of a certain item you have in your possession."], 4, { BAGS_ONLY = L["Bags Only"], BANK_ONLY = L["Bank Only"], BOTH = L["Both"], NONE = L["NONE"] })
E.Options.args.tooltip.args.colorAlpha = ACH:Range(L["OPACITY"], nil, 5, { isPercent = true, min = 0, max = 1, step = 0.01 }, nil, nil, function(info, value) E.db.tooltip[info[#info]] = value; Skins:StyleTooltips() end)

E.Options.args.tooltip.args.general = ACH:Group(L["General"], nil, 6)
E.Options.args.tooltip.args.general.inline = true
E.Options.args.tooltip.args.general.args.targetInfo = ACH:Toggle(L["Target Info"], L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."], 1)
E.Options.args.tooltip.args.general.args.playerTitles = ACH:Toggle(L["Player Titles"], L["Display player titles."], 2)
E.Options.args.tooltip.args.general.args.guildRanks = ACH:Toggle(L["Guild Ranks"], L["Display guild ranks if a unit is guilded."], 3)
E.Options.args.tooltip.args.general.args.alwaysShowRealm = ACH:Toggle(L["Always Show Realm"], nil, 4)
E.Options.args.tooltip.args.general.args.role = ACH:Toggle(L["ROLE"], L["Display the unit role in the tooltip."], 5).args
E.Options.args.tooltip.args.general.args.showMount = ACH:Toggle(L["Current Mount"], L["Display current mount the unit is riding."], 6)
E.Options.args.tooltip.args.general.args.gender = ACH:Toggle(L["Gender"], L["Displays the gender of players."], 7)
E.Options.args.tooltip.args.general.args.showElvUIUsers = ACH:Toggle(L["Show ElvUI Users"], L["Show ElvUI users and their version of ElvUI."], 8)
E.Options.args.tooltip.args.general.args.cursorAnchor = ACH:Toggle(L["Cursor Anchor"], L["Should tooltip be anchored to mouse cursor"], 9)
E.Options.args.tooltip.args.general.args.cursorAnchorType = ACH:Select(L["Cursor Anchor Type"], nil, 10, { ANCHOR_CURSOR = L["CURSOR"], ANCHOR_CURSOR_LEFT = L["CURSOR_LEFT"], ANCHOR_CURSOR_RIGHT = L["CURSOR_RIGHT"] }, nil, nil, nil, nil, nil, function() return (not E.db.tooltip.cursorAnchor) end)
E.Options.args.tooltip.args.general.args.cursorAnchorX = ACH:Range(L["Cursor Anchor Offset X"], nil, 11, { min = -128, max = 128, step = 1 }, nil, nil, nil, nil, function() return (not E.db.tooltip.cursorAnchor) or (E.db.tooltip.cursorAnchorType == 'ANCHOR_CURSOR') end)
E.Options.args.tooltip.args.general.args.cursorAnchorY = ACH:Range(L["Cursor Anchor Offset Y"], nil, 12, { min = -128, max = 128, step = 1 }, nil, nil, nil, nil, function() return (not E.db.tooltip.cursorAnchor) or (E.db.tooltip.cursorAnchorType == 'ANCHOR_CURSOR') end)

E.Options.args.tooltip.args.mythicPlus = ACH:Group(L["Mythic+ Data"], nil, 7)
E.Options.args.tooltip.args.mythicPlus.inline = true
E.Options.args.tooltip.args.mythicPlus.args.mythicDataEnable = ACH:Toggle(L["Enable"], nil, 1)
E.Options.args.tooltip.args.mythicPlus.args.dungeonScore = ACH:Toggle(L["Mythic+ Score"], L["Display the current Mythic+ Dungeon Score."], 2, nil, nil, nil, nil, nil, nil, function() return not E.db.tooltip.mythicDataEnable end)
E.Options.args.tooltip.args.mythicPlus.args.dungeonScoreColor = ACH:Toggle(L["Color Score"], L["Color score based on Blizzards API."], 3, nil, nil, nil, nil, nil, function() return not E.db.tooltip.dungeonScore end)

E.Options.args.tooltip.args.factionColors = ACH:Group(L["Custom Faction Colors"], nil, 8, nil, function(info) local v = tonumber(info[#info]) local t = E.db.tooltip.factionColors[v] local d = P.tooltip.factionColors[v] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local v = tonumber(info[#info]); local t = E.db.tooltip.factionColors[v]; t.r, t.g, t.b = r, g, b end)
E.Options.args.tooltip.args.factionColors.args.useCustomFactionColors = ACH:Toggle(L["Custom Faction Colors"], nil, 0, nil, nil, nil, function() return E.db.tooltip.useCustomFactionColors end, function(_, value) E.db.tooltip.useCustomFactionColors = value; end)

for i = 1, 8 do
	E.Options.args.tooltip.args.factionColors.args[''..i] = ACH:Color(L["FACTION_STANDING_LABEL"..i], nil, i, true, nil, nil, nil, function() return not E.Tooltip.Initialized or not E.db.tooltip.useCustomFactionColors end)
end

E.Options.args.tooltip.args.fontGroup = ACH:Group(L["Font"], nil, 9, nil, function(info) return E.db.tooltip[info[#info]] end, function(info, value) E.db.tooltip[info[#info]] = value; TT:SetTooltipFonts() end)
E.Options.args.tooltip.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
E.Options.args.tooltip.args.fontGroup.args.fontOutline = ACH:Select(L["Font Outline"], nil, 2, C.Values.FontFlags)
E.Options.args.tooltip.args.fontGroup.args.spacer = ACH:Spacer(3)
E.Options.args.tooltip.args.fontGroup.args.headerFontSize = ACH:Range(L["Header Font Size"], nil, 4, C.Values.FontSize)
E.Options.args.tooltip.args.fontGroup.args.textFontSize = ACH:Range(L["Text Font Size"], nil, 5, C.Values.FontSize)
E.Options.args.tooltip.args.fontGroup.args.smallTextFontSize = ACH:Range(L["Comparison Font Size"], L["This setting controls the size of text in item comparison tooltips."], 6, C.Values.FontSize)

E.Options.args.tooltip.args.healthBar = ACH:Group(L["Health Bar"], nil, 10, nil, function(info) return E.db.tooltip.healthBar[info[#info]] end, function(info, value) E.db.tooltip.healthBar[info[#info]] = value; end)
E.Options.args.tooltip.args.healthBar.args.statusPosition = ACH:Select(L["Position"], nil, 1, { BOTTOM = L["Bottom"], TOP = L["Top"], DISABLED = L['Disabled'] })
E.Options.args.tooltip.args.healthBar.args.text = ACH:Toggle(L["Text"], nil, 2, nil, nil, nil, nil, function(_, value) E.db.tooltip.healthBar.text = value; if not GameTooltip:IsForbidden() then if value then GameTooltipStatusBar.text:Show(); else GameTooltipStatusBar.text:Hide() end end end, function() return E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)
E.Options.args.tooltip.args.healthBar.args.height = ACH:Range(L["Height"], nil, 3, { min = 1, max = 15, step = 1 }, nil, nil, function(_, value) E.db.tooltip.healthBar.height = value; if not GameTooltip:IsForbidden() then GameTooltipStatusBar:Height(value); end end, function() return E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)
E.Options.args.tooltip.args.healthBar.args.font = ACH:SharedMediaFont(L["Font"], nil, 4, nil, nil, function(_, value) E.db.tooltip.healthBar.font = value; if not GameTooltip:IsForbidden() then GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch('font', E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline) end end, function() return not E.db.tooltip.healthBar.text or E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)
E.Options.args.tooltip.args.healthBar.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 5, C.Values.FontSize, nil, nil, function(_, value) E.db.tooltip.healthBar.fontSize = value; if not GameTooltip:IsForbidden() then GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch('font', E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline) end end, function() return not E.db.tooltip.healthBar.text or E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)
E.Options.args.tooltip.args.healthBar.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 6, nil, nil, function(_, value) E.db.tooltip.healthBar.fontOutline = value; if not GameTooltip:IsForbidden() then GameTooltipStatusBar.text:FontTemplate(E.Libs.LSM:Fetch('font', E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline) end end, function() return not E.db.tooltip.healthBar.text or E.db.tooltip.healthBar.statusPosition == 'DISABLED' end)

E.Options.args.tooltip.args.visibility = ACH:Group(L["Visibility"], nil, 11, nil, function(info) return E.db.tooltip.visibility[info[#info]] end, function(info, value) E.db.tooltip.visibility[info[#info]] = value; end)
E.Options.args.tooltip.args.visibility.args.actionbars = ACH:Select(L["ActionBars"], L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."], 1, modifierValues)
E.Options.args.tooltip.args.visibility.args.bags = ACH:Select(L["Bags/Bank"], L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."], 2, modifierValues)
E.Options.args.tooltip.args.visibility.args.unitFrames = ACH:Select(L["UnitFrames"], L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."], 3, modifierValues)
E.Options.args.tooltip.args.visibility.args.combatOverride = ACH:Select(L["Combat Override Key"], L["Choose when you want the tooltip to show in combat. If a modifer is chosen, then you need to hold that down to show the tooltip."], 4, modifierValues)
