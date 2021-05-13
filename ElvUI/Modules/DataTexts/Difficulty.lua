local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local pairs, format = pairs, format
local GetDungeonDifficultyID, GetRaidDifficultyID, GetLegacyRaidDifficultyID = GetDungeonDifficultyID, GetRaidDifficultyID, GetLegacyRaidDifficultyID
local SetDungeonDifficultyID, SetRaidDifficultyID, SetLegacyRaidDifficultyID = SetDungeonDifficultyID, SetRaidDifficultyID, SetLegacyRaidDifficultyID
local GetInstanceInfo, GetDifficultyInfo, ResetInstances = GetInstanceInfo, GetDifficultyInfo, ResetInstances
local C_ChallengeMode_GetActiveChallengeMapID = C_ChallengeMode.GetActiveChallengeMapID
local C_ChallengeMode_GetActiveKeystoneInfo = C_ChallengeMode.GetActiveKeystoneInfo
local C_ChallengeMode_IsChallengeModeActive = C_ChallengeMode.IsChallengeModeActive
local C_MythicPlus_IsMythicPlusActive = C_MythicPlus.IsMythicPlusActive

local DungeonTexture, RaidTexture, LegacyTexture = CreateAtlasMarkup('Dungeon', 20, 20), CreateAtlasMarkup('Raid', 20, 20), CreateAtlasMarkup('worldquest-icon-raid', 20, 20)
local DungeonDifficultyID, RaidDifficultyID, LegacyRaidDifficultyID = GetDungeonDifficultyID(), GetRaidDifficultyID(), GetLegacyRaidDifficultyID()

local RightClickMenu, DiffLabel = {
	{ text = _G.DUNGEON_DIFFICULTY, isTitle = true, notCheckable = true },
	{ text = _G.PLAYER_DIFFICULTY1, checked = function() return GetDungeonDifficultyID() == 1 end, func = function() SetDungeonDifficultyID(1) end },
	{ text = _G.PLAYER_DIFFICULTY2, checked = function() return GetDungeonDifficultyID() == 2 end, func = function() SetDungeonDifficultyID(2) end },
	{ text = _G.PLAYER_DIFFICULTY6, checked = function() return GetDungeonDifficultyID() == 23 end, func = function() SetDungeonDifficultyID(23) end },
	{ text = '', isTitle = true, notCheckable = true },
	{ text = _G.RAID_DIFFICULTY, isTitle = true, notCheckable = true},
	{ text = _G.PLAYER_DIFFICULTY1, checked = function() return GetRaidDifficultyID() == 14 end, func = function() SetRaidDifficultyID(14) end },
	{ text = _G.PLAYER_DIFFICULTY2, checked = function() return GetRaidDifficultyID() == 15 end, func = function() SetRaidDifficultyID(15) end },
	{ text = _G.PLAYER_DIFFICULTY6, checked = function() return GetRaidDifficultyID() == 16 end, func = function() SetRaidDifficultyID(16) end },
	{ text = '', isTitle = true, notCheckable = true },
	{ text = _G.UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LEGACY_RAID, isTitle = true, notCheckable = true },
	{ text = _G.RAID_DIFFICULTY1, checked = function() return GetLegacyRaidDifficultyID() == 3 end, func = function() SetLegacyRaidDifficultyID(3) end },
	{ text = _G.RAID_DIFFICULTY1..' '.._G.PLAYER_DIFFICULTY2, checked = function() return GetLegacyRaidDifficultyID() == 5 end, func = function() SetLegacyRaidDifficultyID(5) end },
	{ text = _G.RAID_DIFFICULTY2, checked = function() return GetLegacyRaidDifficultyID() == 4 end, func = function() SetLegacyRaidDifficultyID(4) end },
	{ text = _G.RAID_DIFFICULTY2..' '.._G.PLAYER_DIFFICULTY2, checked = function() return GetLegacyRaidDifficultyID() == 6 end, func = function() SetLegacyRaidDifficultyID(6) end },
	{ text = '', isTitle = true, notCheckable = true },
	{ text = _G.RESET_INSTANCES, notCheckable = true, func = function() ResetInstances() end},
}, {}


for i = 1, 200 do
	local Name = GetDifficultyInfo(i)
	if Name and not DiffLabel[i] then
		DiffLabel[i] = Name
	end
end

local DiffIDLabel = {
	['N'] = { 1, 14, 38 },
	['H'] = { 2, 15, 39 },
	['M'] = { 16, 23, 40 },
	['10N'] = { 3 },
	['25N'] = { 4 },
	['10H'] = { 5 },
	['25H'] = { 6 },
	['LFR'] = { 7, 17 },
	['CM'] = { 8 },
	['40'] = { 9 },
	['TW'] = { 24, 33, 151 },
	['S'] = { 11, 12, 20, 152, 153 },
	['E'] = { 18, 19, 30 },
	['PvP'] = { 25, 29, 32, 34, 45 },
	['WF'] = { 147 },
	['WFH'] = { 149 },
}

local IDTexture = {
	LEGACY = { 3, 4, 5, 6, 9 },
	RAID = { 14, 15, 16 },
}

local Garrison = {
	[1152] = true,
	[1330] = true,
	[1153] = true,
	[1154] = true,
	[1158] = true,
	[1331] = true,
	[1159] = true,
	[1160] = true,
}

local function GetDiffIDLabel(ID)
	for Name, Info in pairs(DiffIDLabel) do
		for _, Num in pairs(Info) do
			if Num == ID then
				return Name
			end
		end
	end
	return ID
end

local function GetLabelTexture(ID)
	for Name, Info in pairs(IDTexture) do
		for _, Num in pairs(Info) do
			if Num == ID then
				return (Name == 'LEGACY' and LegacyTexture) or RaidTexture
			end
		end
	end
	return DungeonTexture
end

local function OnClick(self)
	DT:SetEasyMenuAnchor(DT.EasyMenu, self)
	_G.EasyMenu(RightClickMenu, DT.EasyMenu, nil, nil, nil, 'MENU')
end

local function OnEvent(self)
	local name, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
	local keyStoneLevel = C_MythicPlus_IsMythicPlusActive() and C_ChallengeMode_GetActiveChallengeMapID() and C_ChallengeMode_IsChallengeModeActive() and C_ChallengeMode_GetActiveKeystoneInfo()

	if keyStoneLevel then
		self.text:SetFormattedText('%s %s +%s', GetLabelTexture(difficultyID), name, keyStoneLevel)
	elseif instanceType ~= 'none' and difficultyID and not Garrison[instanceID] then
		self.text:SetFormattedText('%s %s %s', GetLabelTexture(difficultyID), name, GetDiffIDLabel(difficultyID))
	else
		DungeonDifficultyID, RaidDifficultyID, LegacyRaidDifficultyID = GetDungeonDifficultyID(), GetRaidDifficultyID(), GetLegacyRaidDifficultyID()
		self.text:SetFormattedText('%s %s %s %s %s %s', DungeonTexture, GetDiffIDLabel(DungeonDifficultyID), RaidTexture, GetDiffIDLabel(RaidDifficultyID), LegacyTexture, GetDiffIDLabel(LegacyRaidDifficultyID))
	end
end

local function OnEnter()
	if not (DungeonDifficultyID or RaidDifficultyID or LegacyRaidDifficultyID) then return end

	DT.tooltip:ClearLines()
	DT.tooltip:SetText(L["Current Difficulties:"])
	DT.tooltip:AddLine(' ')

	if DungeonDifficultyID then
		DT.tooltip:AddLine(format('%s %s', DungeonTexture, GetDiffIDLabel(DungeonDifficultyID)), 1, 1, 1)
	end
	if RaidDifficultyID then
		DT.tooltip:AddLine(format('%s %s', RaidTexture, GetDiffIDLabel(RaidDifficultyID)), 1, 1, 1)
	end
	if LegacyRaidDifficultyID then
		DT.tooltip:AddLine(format('%s %s', LegacyTexture, GetDiffIDLabel(LegacyRaidDifficultyID)), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Difficulty', nil, {'CHAT_MSG_SYSTEM', 'LOADING_SCREEN_DISABLED'}, OnEvent, nil, OnClick, OnEnter, nil, 'Difficulty')
