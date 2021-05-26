local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local strjoin = strjoin
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetLFGRoleShortageRewards = GetLFGRoleShortageRewards
local GetNumRandomDungeons = GetNumRandomDungeons
local GetNumRFDungeons = GetNumRFDungeons
local GetRFDungeonInfo = GetRFDungeonInfo
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local LFG_ROLE_NUM_SHORTAGE_TYPES = LFG_ROLE_NUM_SHORTAGE_TYPES
local BATTLEGROUND_HOLIDAY = BATTLEGROUND_HOLIDAY
local DUNGEONS = DUNGEONS
local RAID_FINDER = RAID_FINDER

local TANK_ICON = E:TextureString(E.Media.Textures.Tank, ':14:14')
local HEALER_ICON = E:TextureString(E.Media.Textures.Healer, ':14:14')
local DPS_ICON = E:TextureString(E.Media.Textures.DPS, ':14:14')
local enteredFrame, lastPanel = false
local displayString = ''

local function MakeIconString(tank, healer, damage)
	local str = ''
	if tank then
		str = str..TANK_ICON
	end
	if healer then
		str = str..HEALER_ICON
	end
	if damage then
		str = str..DPS_ICON
	end

	return str
end

local function OnEvent(self)
	local tankReward = false
	local healerReward = false
	local dpsReward = false
	local unavailable = true

	--Dungeons
	for i = 1, GetNumRandomDungeons() do
		local id = GetLFGRandomDungeonInfo(i)
		for x = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible and forTank and itemCount > 0 then tankReward = true; unavailable = false end
			if eligible and forHealer and itemCount > 0 then healerReward = true; unavailable = false end
			if eligible and forDamage and itemCount > 0 then dpsReward = true; unavailable = false end
		end
	end

	--LFR
	for i = 1, GetNumRFDungeons() do
		local id = GetRFDungeonInfo(i)
		for x = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible and forTank and itemCount > 0 then tankReward = true; unavailable = false end
			if eligible and forHealer and itemCount > 0 then healerReward = true; unavailable = false end
			if eligible and forDamage and itemCount > 0 then dpsReward = true; unavailable = false end
		end
	end

	if E.global.datatexts.settings.CallToArms.NoLabel then
		self.text:SetFormattedText(displayString, unavailable and 'N/A' or MakeIconString(tankReward, healerReward, dpsReward))
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.CallToArms.Label ~= '' and E.global.datatexts.settings.CallToArms.Label or BATTLEGROUND_HOLIDAY..": ", unavailable and 'N/A' or MakeIconString(tankReward, healerReward, dpsReward))
	end
	lastPanel = self
end

local function OnClick()
	PVEFrame_ToggleFrame('GroupFinderFrame', _G.LFDParentFrame)
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.CallToArms.NoLabel and '' or '%s', hex, '%s|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

local function OnEnter()
	DT.tooltip:ClearLines()
	enteredFrame = true

	local numCTA = 0
	local addTooltipHeader, addTooltipSeparator = true
	for i = 1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		local tankReward = false
		local healerReward = false
		local dpsReward = false
		local unavailable = true
		for x = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible then unavailable = false end
			if eligible and forTank and itemCount > 0 then tankReward = true end
			if eligible and forHealer and itemCount > 0 then healerReward = true end
			if eligible and forDamage and itemCount > 0 then dpsReward = true end
		end

		if not unavailable then
			local rolesString = MakeIconString(tankReward, healerReward, dpsReward)
			if rolesString ~= '' then
				if addTooltipHeader then
					DT.tooltip:AddLine(DUNGEONS)
					addTooltipHeader = false
					addTooltipSeparator = true
				end
				DT.tooltip:AddDoubleLine(name..':', rolesString, 1, 1, 1)
			end
			if tankReward or healerReward or dpsReward then numCTA = numCTA + 1 end
		end
	end

	addTooltipHeader = true
	for i = 1, GetNumRFDungeons() do
		local id, name = GetRFDungeonInfo(i)
		local tankReward = false
		local healerReward = false
		local dpsReward = false
		local unavailable = true

		for x = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible then unavailable = false end
			if eligible and forTank and itemCount > 0 then tankReward = true end
			if eligible and forHealer and itemCount > 0 then healerReward = true end
			if eligible and forDamage and itemCount > 0 then dpsReward = true end
		end

		if not unavailable then
			local rolesString = MakeIconString(tankReward, healerReward, dpsReward)
			if rolesString ~= '' then
				if addTooltipHeader then
					if addTooltipSeparator then DT.tooltip:AddLine(' ') end
					DT.tooltip:AddLine(RAID_FINDER)
					addTooltipHeader = false
				end
				DT.tooltip:AddDoubleLine(name..':', rolesString, 1, 1, 1)
			end
			if tankReward or healerReward or dpsReward then numCTA = numCTA + 1 end
		end
	end

	DT.tooltip:Show()
end

local updateInterval = 10
local function Update(self, elapsed)
	if self.timeSinceUpdate and self.timeSinceUpdate > updateInterval then
		OnEvent(self)

		if enteredFrame then
			OnEnter(self)
		end

		self.timeSinceUpdate = 0
	else
		self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed
	end
end

local function OnLeave()
	enteredFrame = false
end

DT:RegisterDatatext('CallToArms', nil, {"LFG_UPDATE_RANDOM_INFO"}, OnEvent, Update, OnClick, OnEnter, OnLeave, BATTLEGROUND_HOLIDAY, nil, ValueColorUpdate)
