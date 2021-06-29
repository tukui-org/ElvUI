local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local DB = E:GetModule('DataBars')
local ACH = E.Libs.ACH

local ceil = ceil
local tonumber = tonumber
local CopyTable = CopyTable
local GetScreenWidth = GetScreenWidth

local SharedOptions = {
	enable = ACH:Toggle(L["Enable"], nil, 1),
	textFormat = ACH:Select(L["Text Format"], nil, 2, { NONE = L["NONE"], CUR = L["Current"], REM = L["Remaining"], PERCENT = L["Percent"], CURMAX = L["Current - Max"], CURPERC = L["Current - Percent"], CURREM = L["Current - Remaining"], CURPERCREM = L["Current - Percent (Remaining)"] }),
	mouseover = ACH:Toggle(L["Mouseover"], nil, 3),
	clickThrough = ACH:Toggle(L["Click Through"], nil, 4),
	showBubbles = ACH:Toggle(L["Show Bubbles"], nil, 5),
	sizeGroup = ACH:Group(L["Size"], nil, -4),
	conditionGroup = ACH:MultiSelect(L["Conditions"], nil, -3),
	strataAndLevel = ACH:Group(L["Strata and Level"], nil, -2),
	fontGroup = ACH:Group(L["Fonts"], nil, -1)
}

SharedOptions.strataAndLevel.inline = true
SharedOptions.strataAndLevel.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 1, C.Values.Strata)
SharedOptions.strataAndLevel.args.frameLevel = ACH:Range(L["Frame Level"], nil, 2, {min = 1, max = 128, step = 1})

SharedOptions.sizeGroup.inline = true
SharedOptions.sizeGroup.args.width = ACH:Range(L["Width"], nil, 1, { min = 5, max = ceil(GetScreenWidth() or 800), step = 1 })
SharedOptions.sizeGroup.args.height = ACH:Range(L["Height"], nil, 2, { min = 5, max = ceil(GetScreenWidth() or 800), step = 1 })
SharedOptions.sizeGroup.args.orientation = ACH:Select(L["Statusbar Fill Orientation"], L["Direction the bar moves on gains/losses"], 3, { AUTOMATIC = L["Automatic"], HORIZONTAL = L["Horizontal"], VERTICAL = L["Vertical"] })
SharedOptions.sizeGroup.args.reverseFill = ACH:Toggle(L["Reverse Fill Direction"], nil, 4)

SharedOptions.fontGroup.inline = true
SharedOptions.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
SharedOptions.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
SharedOptions.fontGroup.args.fontOutline = ACH:Select(L["Font Outline"], nil, 3, C.Values.FontFlags)

local DataBars = ACH:Group(L["DataBars"], nil, 2, 'tab', function(info) return E.db.databars[info[#info]] end, function(info, value) E.db.databars[info[#info]] = value DB:UpdateAll() end)
E.Options.args.databars = DataBars

DataBars.args.intro = ACH:Description(L["Setup on-screen display of information bars."], 1)
DataBars.args.spacer = ACH:Spacer(2)

DataBars.args.general = ACH:Group(L["General"], nil, 3, nil, function(info) return E.db.databars[info[#info]] end, function(info, value) E.db.databars[info[#info]] = value DB:UpdateAll() end)
DataBars.args.general.inline = true
DataBars.args.general.args.transparent = ACH:Toggle(L["Transparent"], nil, 1)
DataBars.args.general.args.customTexture = ACH:Toggle(L["Custom StatusBar"], nil, 2)
DataBars.args.general.args.statusbar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], nil, 3, nil, nil, nil, function() return not E.db.databars.customTexture end)

DataBars.args.colorGroup = ACH:Group(L["COLORS"], nil, 4, nil, function(info) local t = E.db.databars.colors[info[#info]] local d = P.databars.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end)
DataBars.args.colorGroup.inline = true
DataBars.args.colorGroup.args.experience = ACH:Color(L["Experience"], nil, 1, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_Update() end)
DataBars.args.colorGroup.args.rested = ACH:Color(L["Rested Experience"], nil, 2, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_Update() end)
DataBars.args.colorGroup.args.quest = ACH:Color(L["Quest Experience"], nil, 3, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_QuestXP() end)
DataBars.args.colorGroup.args.honor = ACH:Color(L["Honor"], nil, 4, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:HonorBar_Update() end)
DataBars.args.colorGroup.args.azerite = ACH:Color(L["Azerite"], nil, 5, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:AzeriteBar_Update() end)
DataBars.args.colorGroup.args.useCustomFactionColors = ACH:Toggle(L["Custom Faction Colors"], L["Reputation"], 6, nil, nil, nil, function() return E.db.databars.colors.useCustomFactionColors end, function(_, value) E.db.databars.colors.useCustomFactionColors = value end)

DataBars.args.colorGroup.args.factionColors = ACH:Group(' ', nil, nil, nil, function(info) local v = tonumber(info[#info]) local t = E.db.databars.colors.factionColors[v] local d = P.databars.colors.factionColors[v] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local v = tonumber(info[#info]); local t = E.db.databars.colors.factionColors[v]; t.r, t.g, t.b, t.a = r, g, b, a end, nil, function() return not E.db.databars.colors.useCustomFactionColors end)
DataBars.args.colorGroup.args.factionColors.inline = true

for i = 1, 8 do
	DataBars.args.colorGroup.args.factionColors.args[""..i] = ACH:Color(L["FACTION_STANDING_LABEL"..i], nil, i, true)
end
DataBars.args.colorGroup.args.factionColors.args["9"] = ACH:Color(L["Paragon"], nil, 9, true)

DataBars.args.experience = ACH:Group(L["Experience"], nil, 1, nil, function(info) return DB.db.experience[info[#info]] end, function(info, value) DB.db.experience[info[#info]] = value DB:ExperienceBar_Update() DB:UpdateAll() end)
DataBars.args.experience.args = CopyTable(SharedOptions)
DataBars.args.experience.args.showLevel = ACH:Toggle(L["Level"], nil, 6)
DataBars.args.experience.args.enable.set = function(info, value) DB.db.experience[info[#info]] = value DB:ExperienceBar_Toggle() DB:UpdateAll() end
DataBars.args.experience.args.textFormat.set = function(info, value) DB.db.experience[info[#info]] = value DB:ExperienceBar_Update() end
DataBars.args.experience.args.conditionGroup.get = function(_, key) return DB.db.experience[key] end
DataBars.args.experience.args.conditionGroup.set = function(_, key, value) DB.db.experience[key] = value DB:ExperienceBar_Update() DB:UpdateAll() end
DataBars.args.experience.args.conditionGroup.values = {
	hideAtMaxLevel = L["Hide At Max Level"],
	hideInCombat = L["Hide In Combat"],
}

DataBars.args.experience.args.questGroup = ACH:Group(L["Quests"], nil, -3, nil, function(info) return DB.db.experience[info[#info]] end, function(info, value) DB.db.experience[info[#info]] = value DB:ExperienceBar_QuestXP() DB:UpdateAll() end)
DataBars.args.experience.args.questGroup.inline = true
DataBars.args.experience.args.questGroup.args.showQuestXP = ACH:Toggle(L["Show QuestXP"], nil, 1)
DataBars.args.experience.args.questGroup.args.questCompletedOnly = ACH:Toggle(L["Completed Quests Only"], nil, 2, nil, nil, nil, nil, nil, function() return not DB.db.experience.showQuestXP end)
DataBars.args.experience.args.questGroup.args.questsCurrentZoneOnly = ACH:Toggle(L["Quests in Current Zone Only"], nil, 3, nil, nil, nil, nil, nil, function() return not DB.db.experience.showQuestXP end)

DataBars.args.reputation = ACH:Group(L["Reputation"], nil, 2, nil, function(info) return DB.db.reputation[info[#info]] end, function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() DB:UpdateAll() end)
DataBars.args.reputation.args = CopyTable(SharedOptions)
DataBars.args.reputation.args.enable.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Toggle() DB:UpdateAll() end
DataBars.args.reputation.args.textFormat.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() end
DataBars.args.reputation.args.showReward = ACH:Toggle(L["Reward Icon"], nil, 6)
DataBars.args.reputation.args.showReward.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() end
DataBars.args.reputation.args.rewardPosition = ACH:Select(L["Reward Position"], nil, 7, { TOP = 'Top', BOTTOM = 'Bottom', LEFT = 'LEFT', RIGHT = 'RIGHT' })
DataBars.args.reputation.args.rewardPosition.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() end
DataBars.args.reputation.args.conditionGroup.get = function(_, key) return DB.db.reputation[key] end
DataBars.args.reputation.args.conditionGroup.set = function(_, key, value) DB.db.reputation[key] = value DB:ReputationBar_Update() DB:UpdateAll() end
DataBars.args.reputation.args.conditionGroup.values = {
	hideInVehicle = L["Hide In Vehicle"],
	hideInCombat = L["Hide In Combat"],
}

DataBars.args.honor = ACH:Group(L["Honor"], nil, 3, nil, function(info) return DB.db.honor[info[#info]] end, function(info, value) DB.db.honor[info[#info]] = value DB:HonorBar_Update() DB:UpdateAll() end)
DataBars.args.honor.args = CopyTable(SharedOptions)
DataBars.args.honor.args.enable.set = function(info, value) DB.db.honor[info[#info]] = value DB:HonorBar_Toggle() DB:UpdateAll() end
DataBars.args.honor.args.textFormat.set = function(info, value) DB.db.honor[info[#info]] = value DB:HonorBar_Update() end
DataBars.args.honor.args.conditionGroup.get = function(_, key) return DB.db.honor[key] end
DataBars.args.honor.args.conditionGroup.set = function(_, key, value) DB.db.honor[key] = value DB:HonorBar_Update() DB:UpdateAll() end
DataBars.args.honor.args.conditionGroup.values = {
	hideInVehicle = L["Hide In Vehicle"],
	hideInCombat = L["Hide In Combat"],
	hideOutsidePvP = L["Hide Outside PvP"],
	hideBelowMaxLevel = L["Hide Below Max Level"],
}

DataBars.args.threat = ACH:Group(L["Threat"], nil, 4, nil, function(info) return DB.db.threat[info[#info]] end, function(info, value) DB.db.threat[info[#info]] = value DB:ThreatBar_Update() DB:UpdateAll() end)
DataBars.args.threat.args = CopyTable(SharedOptions)
DataBars.args.threat.args.enable.set = function(info, value) DB.db.threat[info[#info]] = value DB:ThreatBar_Toggle() DB:UpdateAll() end
DataBars.args.threat.args.textFormat = nil
DataBars.args.threat.args.conditionGroup = nil
DataBars.args.threat.args.showBubbles = nil

DataBars.args.azerite = ACH:Group(L["Azerite"], nil, 5, nil, function(info) return DB.db.azerite[info[#info]] end, function(info, value) DB.db.azerite[info[#info]] = value DB:AzeriteBar_Update() DB:UpdateAll() end)
DataBars.args.azerite.args = CopyTable(SharedOptions)
DataBars.args.azerite.args.enable.set = function(info, value) DB.db.azerite[info[#info]] = value DB:AzeriteBar_Toggle() DB:UpdateAll() end
DataBars.args.azerite.args.textFormat.set = function(info, value) DB.db.azerite[info[#info]] = value DB:AzeriteBar_Update() end
DataBars.args.azerite.args.conditionGroup.get = function(_, key) return DB.db.azerite[key] end
DataBars.args.azerite.args.conditionGroup.set = function(_, key, value) DB.db.azerite[key] = value DB:AzeriteBar_Update() DB:UpdateAll() end
DataBars.args.azerite.args.conditionGroup.values = {
	hideInVehicle = L["Hide In Vehicle"],
	hideInCombat = L["Hide In Combat"],
	hideAtMaxLevel = L["Hide At Max Level"],
}
