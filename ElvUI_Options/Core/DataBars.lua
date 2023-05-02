local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local DB = E:GetModule('DataBars')
local ACH = E.Libs.ACH

local ceil = ceil
local tonumber = tonumber
local CopyTable = CopyTable

local SharedOptions = {
	enable = ACH:Toggle(L["Enable"], nil, 1),
	mouseover = ACH:Toggle(L["Mouseover"], nil, 2),
	clickThrough = ACH:Toggle(L["Click Through"], nil, 3),
	showBubbles = ACH:Toggle(L["Show Bubbles"], nil, 5),
	textFormat = ACH:Select(L["Text Format"], nil, 10, { NONE = L["None"], CUR = L["Current"], REM = L["Remaining"], PERCENT = L["Percent"], CURMAX = L["Current - Max"], CURPERC = L["Current - Percent"], CURREM = L["Current - Remaining"], CURPERCREM = L["Current - Percent (Remaining)"] }),
	sizeGroup = ACH:Group(L["Size"], nil, -4),
	conditionGroup = ACH:MultiSelect(L["Conditions"], nil, -3),
	strataAndLevel = ACH:Group(L["Strata and Level"], nil, -2),
	fontGroup = ACH:Group(L["Fonts"], nil, -1)
}

SharedOptions.strataAndLevel.inline = true
SharedOptions.strataAndLevel.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 1, C.Values.Strata)
SharedOptions.strataAndLevel.args.frameLevel = ACH:Range(L["Frame Level"], nil, 2, {min = 1, max = 128, step = 1})

SharedOptions.sizeGroup.inline = true
SharedOptions.sizeGroup.args.width = ACH:Range(L["Width"], nil, 1, { min = 5, max = ceil(E.screenWidth), step = 1 })
SharedOptions.sizeGroup.args.height = ACH:Range(L["Height"], nil, 2, { min = 5, max = ceil(E.screenWidth), step = 1 })
SharedOptions.sizeGroup.args.orientation = ACH:Select(L["Statusbar Fill Orientation"], L["Direction the bar moves on gains/losses"], 3, { AUTOMATIC = L["Automatic"], HORIZONTAL = L["Horizontal"], VERTICAL = L["Vertical"] })
SharedOptions.sizeGroup.args.reverseFill = ACH:Toggle(L["Reverse Fill Direction"], nil, 4)

SharedOptions.fontGroup.inline = true
SharedOptions.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
SharedOptions.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
SharedOptions.fontGroup.args.fontOutline = ACH:Select(L["Font Outline"], nil, 3, C.Values.FontFlags)
SharedOptions.fontGroup.args.spacer = ACH:Spacer(4, 'full')
SharedOptions.fontGroup.args.anchorPoint = ACH:Select(L["Anchor Point"], nil, 5, C.Values.AllPoints)
SharedOptions.fontGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
SharedOptions.fontGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

local DataBars = ACH:Group(L["DataBars"], nil, 2, 'tab', function(info) return E.db.databars[info[#info]] end, function(info, value) E.db.databars[info[#info]] = value DB:UpdateAll() end)
E.Options.args.databars = DataBars

DataBars.args.intro = ACH:Description(L["Setup on-screen display of information bars."], 1)
DataBars.args.transparent = ACH:Toggle(L["Transparent"], nil, 3)
DataBars.args.customTexture = ACH:Toggle(L["Custom StatusBar"], nil, 4)
DataBars.args.statusbar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], nil, 5, nil, nil, nil, function() return not E.db.databars.customTexture end)

DataBars.args.colorGroup = ACH:Group(L["Colors"], nil, -1, nil, function(info) local t = E.db.databars.colors[info[#info]] local d = P.databars.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end)
DataBars.args.colorGroup.args.experience = ACH:Color(L["Experience"], nil, 1, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_Update() end)
DataBars.args.colorGroup.args.petExperience = ACH:Color(L["Pet Experience"], nil, 3, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:PetExperienceBar_Update() end, nil, function() return E.Retail or E.myclass ~= 'HUNTER' end)
DataBars.args.colorGroup.args.rested = ACH:Color(L["Rested Experience"], nil, 2, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_Update() end)
DataBars.args.colorGroup.args.quest = ACH:Color(L["Quest Experience"], nil, 3, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:ExperienceBar_QuestXP() end)
DataBars.args.colorGroup.args.honor = ACH:Color(L["Honor"], nil, 4, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:HonorBar_Update() end)
DataBars.args.colorGroup.args.azerite = ACH:Color(L["Azerite"], nil, 5, true, nil, nil, function(info, r, g, b, a) local t = E.db.databars.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a DB:AzeriteBar_Update() end, nil, not E.Retail)
DataBars.args.colorGroup.args.useCustomFactionColors = ACH:Toggle(L["Custom Faction Colors"], L["Reputation"], 6, nil, nil, nil, function() return E.db.databars.colors.useCustomFactionColors end, function(_, value) E.db.databars.colors.useCustomFactionColors = value; DB:ReputationBar_Update() end)
DataBars.args.colorGroup.args.reputationAlpha = ACH:Range(L["Reputation Alpha"], nil, 7, {min = 0, max = 1, step = 0.05, isPercent = true}, nil, function() return E.db.databars.colors.reputationAlpha end, function(_, value) E.db.databars.colors.reputationAlpha = value; DB:ReputationBar_Update() end, nil, function() return E.db.databars.colors.useCustomFactionColors end)

DataBars.args.colorGroup.args.factionColors = ACH:Group(' ', nil, nil, nil, function(info) local v = tonumber(info[#info]) local t = E.db.databars.colors.factionColors[v] local d = P.databars.colors.factionColors[v] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local v = tonumber(info[#info]); local t = E.db.databars.colors.factionColors[v]; t.r, t.g, t.b, t.a = r, g, b, a; DB:ReputationBar_Update() end, nil, function() return not E.db.databars.colors.useCustomFactionColors end)
DataBars.args.colorGroup.args.factionColors.inline = true

for i = 1, 8 do
	DataBars.args.colorGroup.args.factionColors.args[""..i] = ACH:Color(L["FACTION_STANDING_LABEL"..i], nil, i, true)
end
DataBars.args.colorGroup.args.factionColors.args["9"] = ACH:Color(L["Paragon"], nil, 9, true)
DataBars.args.colorGroup.args.factionColors.args["10"] = ACH:Color(L["Renown"], nil, 10, true)

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
DataBars.args.experience.args.questGroup.args.questCurrentZoneOnly = ACH:Toggle(L["Quests in Current Zone Only"], nil, 3, nil, nil, nil, nil, nil, function() return not DB.db.experience.showQuestXP end)
DataBars.args.experience.args.questGroup.args.questTrackedOnly = ACH:Toggle(L["Tracked Quests Only"], nil, 3, nil, nil, nil, nil, nil, function() return not DB.db.experience.showQuestXP end, not E.Retail)

E.Options.args.databars.args.petExperience = ACH:Group(L["Pet Experience"], nil, 2, nil, function(info) return DB.db.petExperience[info[#info]] end, function(info, value) DB.db.petExperience[info[#info]] = value DB:PetExperienceBar_Update() DB:UpdateAll() end, nil, function() return E.Retail or E.myclass ~= 'HUNTER' end)
E.Options.args.databars.args.petExperience.args = CopyTable(SharedOptions)
E.Options.args.databars.args.petExperience.args.enable.set = function(info, value) DB.db.petExperience[info[#info]] = value DB:PetExperienceBar_Toggle() DB:UpdateAll() end
E.Options.args.databars.args.petExperience.args.textFormat.set = function(info, value) DB.db.petExperience[info[#info]] = value DB:PetExperienceBar_Update() end
E.Options.args.databars.args.petExperience.args.conditionGroup.get = function(_, key) return DB.db.petExperience[key] end
E.Options.args.databars.args.petExperience.args.conditionGroup.set = function(_, key, value) DB.db.petExperience[key] = value DB:PetExperienceBar_Update() DB:UpdateAll() end
E.Options.args.databars.args.petExperience.args.conditionGroup.values = {
	hideAtMaxLevel = L["Hide At Max Level"],
	hideInCombat = L["Hide In Combat"],
}

DataBars.args.reputation = ACH:Group(L["Reputation"], nil, 2, nil, function(info) return DB.db.reputation[info[#info]] end, function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() DB:UpdateAll() end)
DataBars.args.reputation.args = CopyTable(SharedOptions)
DataBars.args.reputation.args.enable.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Toggle() DB:UpdateAll() end
DataBars.args.reputation.args.textFormat.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() end
DataBars.args.reputation.args.showReward = ACH:Toggle(L["Reward Icon"], nil, 15)
DataBars.args.reputation.args.showReward.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() end
DataBars.args.reputation.args.rewardPosition = ACH:Select(L["Reward Position"], nil, 16, C.Values.SidePositions)
DataBars.args.reputation.args.rewardPosition.set = function(info, value) DB.db.reputation[info[#info]] = value DB:ReputationBar_Update() end
DataBars.args.reputation.args.conditionGroup.get = function(_, key) return DB.db.reputation[key] end
DataBars.args.reputation.args.conditionGroup.set = function(_, key, value) DB.db.reputation[key] = value DB:ReputationBar_Update() DB:UpdateAll() end
DataBars.args.reputation.args.conditionGroup.values = {
	hideInVehicle = L["Hide In Vehicle"],
	hideInCombat = L["Hide In Combat"],
}

DataBars.args.honor = ACH:Group(L["Honor"], nil, 3, nil, function(info) return DB.db.honor[info[#info]] end, function(info, value) DB.db.honor[info[#info]] = value DB:HonorBar_Update() DB:UpdateAll() end, nil, not E.Retail)
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
DataBars.args.threat.args.displayText = ACH:Toggle(L["Display Text"], nil, 5)
DataBars.args.threat.args.tankStatus = ACH:Toggle(L["Tank Colors"], nil, 6)
DataBars.args.threat.args.textFormat = nil
DataBars.args.threat.args.conditionGroup = nil
DataBars.args.threat.args.showBubbles = nil

DataBars.args.azerite = ACH:Group(L["Azerite"], nil, 5, nil, function(info) return DB.db.azerite[info[#info]] end, function(info, value) DB.db.azerite[info[#info]] = value DB:AzeriteBar_Update() DB:UpdateAll() end, nil, not E.Retail)
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
