local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local DB = E:GetModule('DataBars')
local ACH = E.Libs.ACH

local tonumber = tonumber

local SharedOptions = {
	enable = ACH:Toggle(L["Enable"], nil, 1),
	textFormat = ACH:Select(L["Text Format"], nil, 2, { NONE = L["NONE"], CUR = L["Current"], REM = L["Remaining"], PERCENT = L["Percent"], CURMAX = L["Current - Max"], CURPERC = L["Current - Percent"], CURREM = L["Current - Remaining"], CURPERCREM = L["Current - Percent (Remaining)"] }),
	mouseover = ACH:Toggle(L["Mouseover"], nil, 3),
	clickThrough = ACH:Toggle(L["Click Through"], nil, 4),
	showBubbles = ACH:Toggle(L["Show Bubbles"], nil, 5),
	sizeGroup = ACH:Group(L["Size"], nil, -3),
	conditionGroup = ACH:MultiSelect(L["Conditions"], nil, -2),
	fontGroup = ACH:Group(L["Fonts"], nil, -1),
}

SharedOptions.sizeGroup.inline = true
SharedOptions.sizeGroup.args.width = ACH:Range(L["Width"], nil, 1, { min = 5, max = ceil(GetScreenWidth() or 800), step = 1 })
SharedOptions.sizeGroup.args.height = ACH:Range(L["Height"], nil, 2, { min = 5, max = ceil(GetScreenWidth() or 800), step = 1 })
SharedOptions.sizeGroup.args.orientation = ACH:Select(L["Statusbar Fill Orientation"], L["Direction the bar moves on gains/losses"], 3, { AUTOMATIC = L["Automatic"], HORIZONTAL = L["Horizontal"], VERTICAL = L["Vertical"] })
SharedOptions.sizeGroup.args.reverseFill = ACH:Toggle(L["Reverse Fill Direction"], nil, 4)

SharedOptions.fontGroup.inline = true
SharedOptions.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
SharedOptions.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
SharedOptions.fontGroup.args.fontOutline = ACH:Select(L["Font Outline"], nil, 3, C.Values.FontFlags)

E.Options.args.databars = ACH:Group(L["DataBars"], nil, 2, 'tab', function(info) return E.db.databars[info[#info]] end, function(info, value) E.db.databars[info[#info]] = value DB:UpdateAll() end)
E.Options.args.databars.args.intro = ACH:Description(L["Setup on-screen display of information bars."], 1)
E.Options.args.databars.args.spacer = ACH:Spacer(2)

E.Options.args.databars.args.general = ACH:Group(L["General"], nil, 3, nil, function(info) return E.db.databars[info[#info]] end, function(info, value) E.db.databars[info[#info]] = value DB:UpdateAll() end)
E.Options.args.databars.args.general.inline = true
E.Options.args.databars.args.general.args.transparent = ACH:Toggle(L["Transparent"], nil, 1)
E.Options.args.databars.args.general.args.customTexture = ACH:Toggle(L["Custom StatusBar"], nil, 2)
E.Options.args.databars.args.general.args.statusbar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], nil, 3, nil, nil, nil, function() return not E.db.databars.customTexture end)

E.Options.args.databars.args.colorGroup = ACH:Group(L["COLORS"], nil, 4, nil, function(info) local t = E.db.databars.colors[info[#info]] local d = P.databars.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end)
E.Options.args.databars.args.colorGroup.inline = true
E.Options.args.databars.args.colorGroup.args.experience = ACH:Color(L["Experience"], nil, 1, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_Update() end)
E.Options.args.databars.args.colorGroup.args.rested = ACH:Color(L["Rested Experience"], nil, 2, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_Update() end)
E.Options.args.databars.args.colorGroup.args.quest = ACH:Color(L["Quest Experience"], nil, 3, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_QuestXP() end)
E.Options.args.databars.args.colorGroup.args.honor = ACH:Color(L["Honor"], nil, 4, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:HonorBar_Update() end)
E.Options.args.databars.args.colorGroup.args.azerite = ACH:Color(L["Azerite"], nil, 5, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:AzeriteBar_Update() end)
E.Options.args.databars.args.colorGroup.args.useCustomFactionColors = ACH:Toggle(L["Custom Faction Colors"], L["Reputation"], 6, nil, nil, nil, function() return E.db.databars.colors.useCustomFactionColors end, function(_, value) E.db.databars.colors.useCustomFactionColors = value end)

E.Options.args.databars.args.colorGroup.args.factionColors = ACH:Group(' ', nil, nil, nil, function(info) local v = tonumber(info[#info]) local t = E.db.databars.colors.factionColors[v] local d = P.databars.colors.factionColors[v] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local v = tonumber(info[#info]); local t = E.db.databars.colors.factionColors[v]; t.r, t.g, t.b = r, g, b end, nil, function() return not E.db.databars.colors.useCustomFactionColors end)
E.Options.args.databars.args.colorGroup.args.factionColors.inline = true

for i = 1, 8 do
	E.Options.args.databars.args.colorGroup.args.factionColors.args[""..i] = ACH:Color(L["FACTION_STANDING_LABEL"..i], nil, i, true)
end

E.Options.args.databars.args.experience = ACH:Group(L["Experience"], nil, 1, nil, function(info) return DB.db.experience[info[#info]] end, function(info, value) DB.db.experience[info[#info]] = value DB:ExperienceBar_Update() DB:ExperienceBar_QuestXP() DB:UpdateAll() end)
E.Options.args.databars.args.experience.args = CopyTable(SharedOptions)
E.Options.args.databars.args.experience.args.showLevel = ACH:Toggle(L["Level"], nil, 6)
E.Options.args.databars.args.experience.args.enable.set = function(info, value) DB.db.experience[info[#info]] = value DB:ExperienceBar_Toggle() DB:UpdateAll() end
E.Options.args.databars.args.experience.args.textFormat.set = function(info, value) DB.db.experience[info[#info]] = value DB:ExperienceBar_Update() end
E.Options.args.databars.args.experience.args.conditionGroup.get = function(_, key) return DB.db.experience[key] end
E.Options.args.databars.args.experience.args.conditionGroup.set = function(_, key, value) DB.db.experience[key] = value DB:ExperienceBar_Update() DB:ExperienceBar_QuestXP() DB:UpdateAll() end
E.Options.args.databars.args.experience.args.conditionGroup.values = {
	questCurrentZoneOnly = L["Quests in Current Zone Only"],
	questCompletedOnly = L["Completed Quests Only"],
	hideAtMaxLevel = L["Hide At Max Level"],
	hideInVehicle = L["Hide In Vehicle"],
	hideInCombat = L["Hide In Combat"],
}

E.Options.args.databars.args.reputation = ACH:Group(L["Reputation"], nil, 2, nil, function(info) return DB.db.reputation[info[#info]] end, function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() DB:UpdateAll() end)
E.Options.args.databars.args.reputation.args = CopyTable(SharedOptions)
E.Options.args.databars.args.reputation.args.enable.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Toggle() DB:UpdateAll() end
E.Options.args.databars.args.reputation.args.textFormat.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() end
E.Options.args.databars.args.reputation.args.conditionGroup.get = function(_, key) return DB.db.reputation[key] end
E.Options.args.databars.args.reputation.args.conditionGroup.set = function(_, key, value) DB.db.reputation[key] = value DB:ReputationBar_Update() DB:UpdateAll() end
E.Options.args.databars.args.reputation.args.conditionGroup.values = {
	hideInVehicle = L["Hide In Vehicle"],
	hideInCombat = L["Hide In Combat"],
}

E.Options.args.databars.args.honor = ACH:Group(L["Honor"], nil, 3, nil, function(info) return DB.db.honor[info[#info]] end, function(info, value) DB.db.honor[info[#info]] = value DB:HonorBar_Update() DB:UpdateAll() end)
E.Options.args.databars.args.honor.args = CopyTable(SharedOptions)
E.Options.args.databars.args.honor.args.enable.set = function(info, value) DB.db.honor[info[#info]] = value DB:HonorBar_Toggle() DB:UpdateAll() end
E.Options.args.databars.args.honor.args.textFormat.set = function(info, value) DB.db.honor[info[#info]] = value DB:HonorBar_Update() end
E.Options.args.databars.args.honor.args.conditionGroup.get = function(_, key) return DB.db.honor[key] end
E.Options.args.databars.args.honor.args.conditionGroup.set = function(_, key, value) DB.db.honor[key] = value DB:HonorBar_Update() DB:UpdateAll() end
E.Options.args.databars.args.honor.args.conditionGroup.values = {
	hideInVehicle = L["Hide In Vehicle"],
	hideInCombat = L["Hide In Combat"],
	hideOutsidePvP = L["Hide Outside PvP"],
	hideBelowMaxLevel = L["Hide Below Max Level"],
}

E.Options.args.databars.args.threat = ACH:Group(L["Threat"], nil, 4, nil, function(info) return DB.db.threat[info[#info]] end, function(info, value) DB.db.threat[info[#info]] = value DB:ThreatBar_Update() DB:UpdateAll() end)
E.Options.args.databars.args.threat.args = CopyTable(SharedOptions)
E.Options.args.databars.args.threat.args.enable.set = function(info, value) DB.db.threat[info[#info]] = value DB:ThreatBar_Toggle() DB:UpdateAll() end
E.Options.args.databars.args.threat.args.textFormat = nil
E.Options.args.databars.args.threat.args.conditionGroup = nil
E.Options.args.databars.args.threat.args.showBubbles = nil

E.Options.args.databars.args.azerite = ACH:Group(L["Azerite"], nil, 5, nil, function(info) return DB.db.azerite[info[#info]] end, function(info, value) DB.db.azerite[info[#info]] = value DB:AzeriteBar_Update() DB:UpdateAll() end)
E.Options.args.databars.args.azerite.args = CopyTable(SharedOptions)
E.Options.args.databars.args.azerite.args.enable.set = function(info, value) DB.db.azerite[info[#info]] = value DB:AzeriteBar_Toggle() DB:UpdateAll() end
E.Options.args.databars.args.azerite.args.textFormat.set = function(info, value) DB.db.azerite[info[#info]] = value DB:AzeriteBar_Update() end
E.Options.args.databars.args.azerite.args.conditionGroup.get = function(_, key) return DB.db.azerite[key] end
E.Options.args.databars.args.azerite.args.conditionGroup.set = function(_, key, value) DB.db.azerite[key] = value DB:AzeriteBar_Update() DB:UpdateAll() end
E.Options.args.databars.args.azerite.args.conditionGroup.values = {
	hideInVehicle = L["Hide In Vehicle"],
	hideInCombat = L["Hide In Combat"],
	hideAtMaxLevel = L["Hide At Max Level"],
}
