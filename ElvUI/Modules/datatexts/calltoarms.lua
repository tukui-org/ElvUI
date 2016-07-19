local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--WoW API / Variables
local GetNumRandomDungeons = GetNumRandomDungeons
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetNumRFDungeons = GetNumRFDungeons
local GetRFDungeonInfo = GetRFDungeonInfo
local GetLFGRoleShortageRewards = GetLFGRoleShortageRewards
local ToggleFrame = ToggleFrame
local LFG_ROLE_NUM_SHORTAGE_TYPES = LFG_ROLE_NUM_SHORTAGE_TYPES
local BATTLEGROUND_HOLIDAY = BATTLEGROUND_HOLIDAY
local DUNGEONS = DUNGEONS
local RAID_FINDER = RAID_FINDER

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LFDParentFrame

local TANK_ICON = "|TInterface\\AddOns\\ElvUI\\media\\textures\\tank.tga:14:14|t"
local HEALER_ICON = "|TInterface\\AddOns\\ElvUI\\media\\textures\\healer.tga:14:14|t"
local DPS_ICON = "|TInterface\\AddOns\\ElvUI\\media\\textures\\dps.tga:14:14|t"
local NOBONUSREWARDS = BATTLEGROUND_HOLIDAY..": N/A"
local lastPanel
local enteredFrame = false

local function MakeIconString(tank, healer, damage)
	local str = ""
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

local function OnEvent(self, event, ...)
	local tankReward = false
	local healerReward = false
	local dpsReward = false
	local unavailable = true

	--Dungeons
	for i=1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		for x = 1,LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible and forTank and itemCount > 0 then tankReward = true; unavailable = false; end
			if eligible and forHealer and itemCount > 0 then healerReward = true; unavailable = false; end
			if eligible and forDamage and itemCount > 0 then dpsReward = true; unavailable = false; end
		end
	end

	--LFR
	for i = 1, GetNumRFDungeons() do
		local id, name = GetRFDungeonInfo(i)
		for x = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible and forTank and itemCount > 0 then tankReward = true; unavailable = false; end
			if eligible and forHealer and itemCount > 0 then healerReward = true; unavailable = false; end
			if eligible and forDamage and itemCount > 0 then dpsReward = true; unavailable = false; end
		end
	end

	if unavailable then
		self.text:SetText(NOBONUSREWARDS)
	else
		self.text:SetText(BATTLEGROUND_HOLIDAY..": "..MakeIconString(tankReward, healerReward, dpsReward))
	end
	lastPanel = self
end

local function OnClick()
	ToggleFrame(LFDParentFrame)
end

local function ValueColorUpdate(hex, r, g, b)
	NOBONUSREWARDS = BATTLEGROUND_HOLIDAY..": "..hex.."N/A|r"

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

local function OnEnter(self)
	if not enteredFrame then
		enteredFrame = true
	end

	DT:SetupTooltip(self)
	local allUnavailable = true
	local numCTA = 0
	local addTooltipHeader = true
	for i=1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		local tankReward = false
		local healerReward = false
		local dpsReward = false
		local unavailable = true
		for x=1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible then unavailable = false end
			if eligible and forTank and itemCount > 0 then tankReward = true end
			if eligible and forHealer and itemCount > 0 then healerReward = true end
			if eligible and forDamage and itemCount > 0 then dpsReward = true end
		end

		if not unavailable then
			allUnavailable = false
			local rolesString = MakeIconString(tankReward, healerReward, dpsReward)
			if rolesString ~= ""  then
				if addTooltipHeader then
					DT.tooltip:AddLine(DUNGEONS)
					addTooltipHeader = false
				end
				DT.tooltip:AddDoubleLine(name..":", rolesString, 1, 1, 1)
			end
			if tankReward or healerReward or dpsReward then numCTA = numCTA + 1 end
		end
	end

	addTooltipHeader = true
	for i = 1, GetNumRFDungeons() do
		local id, name, typeID, subtype, minLevel, maxLevel = GetRFDungeonInfo(i);
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
			allUnavailable = false
			local rolesString = MakeIconString(tankReward, healerReward, dpsReward)
			if rolesString ~= ""  then
				if addTooltipHeader then
					DT.tooltip:AddLine(" ")
					DT.tooltip:AddLine(RAID_FINDER)
					addTooltipHeader = false
				end
				DT.tooltip:AddDoubleLine(name..":", rolesString, 1, 1, 1)
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

local function OnLeave(self)
	DT.tooltip:Hide();
	enteredFrame = false;
end

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]
DT:RegisterDatatext('Call to Arms', {"PLAYER_ENTERING_WORLD", "LFG_UPDATE_RANDOM_INFO"}, OnEvent, Update, OnClick, OnEnter, OnLeave)
