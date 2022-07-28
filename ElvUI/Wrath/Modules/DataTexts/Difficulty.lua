local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

-- TODO: Wrath

local _G = _G
local pairs, format = pairs, format
local StaticPopup_Show = StaticPopup_Show
local GetDungeonDifficultyID, GetRaidDifficultyID = GetDungeonDifficultyID, GetRaidDifficultyID
local SetDungeonDifficultyID, SetRaidDifficultyID = SetDungeonDifficultyID, SetRaidDifficultyID
local GetInstanceInfo, GetDifficultyInfo = GetInstanceInfo, GetDifficultyInfo

local DungeonTexture, RaidTexture = CreateAtlasMarkup('Dungeon', 20, 20), CreateAtlasMarkup('Raid', 20, 20)
local DungeonDifficultyID, RaidDifficultyID = GetDungeonDifficultyID(), GetRaidDifficultyID()
local displayString = '%s %s %s %s'

local RightClickMenu, DiffLabel = {
	{ text = _G.DUNGEON_DIFFICULTY, isTitle = true, notCheckable = true },
	{ text = _G.PLAYER_DIFFICULTY1, checked = function() return GetDungeonDifficultyID() == 1 end, func = function() SetDungeonDifficultyID(1) end },
	{ text = _G.PLAYER_DIFFICULTY2, checked = function() return GetDungeonDifficultyID() == 2 end, func = function() SetDungeonDifficultyID(2) end },
	{ text = '', isTitle = true, notCheckable = true },
	{ text = _G.RAID_DIFFICULTY, isTitle = true, notCheckable = true},
	{ text = _G.RAID_DIFFICULTY1, checked = function() return GetRaidDifficultyID() == 3 end, func = function() SetRaidDifficultyID(3) end },
	{ text = _G.RAID_DIFFICULTY2, checked = function() return GetRaidDifficultyID() == 4 end, func = function() SetRaidDifficultyID(4) end },
	{ text = '', isTitle = true, notCheckable = true },
	{ text = _G.RESET_INSTANCES, notCheckable = true, func = function() StaticPopup_Show('CONFIRM_RESET_INSTANCES') end},
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
	['10'] = { 3 },
	['25'] = { 4 },
	['PvP'] = { 25, 29, 32, 34, 45 },
}

local IDTexture = {
	RAID = { 14, 15, 16 },
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
	for _, Info in pairs(IDTexture) do
		for _, Num in pairs(Info) do
			if Num == ID then
				return RaidTexture
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
	local name, instanceType, difficultyID = GetInstanceInfo()

	if instanceType ~= 'none' and difficultyID then
		self.text:SetFormattedText('%s %s %s', GetLabelTexture(difficultyID), name, GetDiffIDLabel(difficultyID))
	else
		DungeonDifficultyID, RaidDifficultyID = GetDungeonDifficultyID(), GetRaidDifficultyID()

		self.text:SetFormattedText(displayString, DungeonTexture, GetDiffIDLabel(DungeonDifficultyID), RaidTexture, GetDiffIDLabel(RaidDifficultyID))
	end
end

local function OnEnter()
	if not (DungeonDifficultyID or RaidDifficultyID) then return end

	DT.tooltip:ClearLines()
	DT.tooltip:SetText(L["Current Difficulties:"])
	DT.tooltip:AddLine(' ')

	if DungeonDifficultyID then
		DT.tooltip:AddLine(format('%s %s', DungeonTexture, GetDiffIDLabel(DungeonDifficultyID)), 1, 1, 1)
	end
	if RaidDifficultyID then
		DT.tooltip:AddLine(format('%s %s', RaidTexture, GetDiffIDLabel(RaidDifficultyID)), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Difficulty', nil, {'CHAT_MSG_SYSTEM', 'LOADING_SCREEN_DISABLED', 'UPDATE_INSTANCE_INFO'}, OnEvent, nil, OnClick, OnEnter, nil, 'Difficulty')
