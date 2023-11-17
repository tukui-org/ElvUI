local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local _G = _G
local setmetatable, getfenv, setfenv = setmetatable, getfenv, setfenv
local type, pairs, min, random, strfind, next = type, pairs, min, random, strfind, next

local UnitName = UnitName
local UnitPower = UnitPower
local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitPowerMax = UnitPowerMax
local UnitHealthMax = UnitHealthMax
local UnitPowerType = UnitPowerType
local InCombatLockdown = InCombatLockdown
local UnregisterUnitWatch = UnregisterUnitWatch
local RegisterUnitWatch = RegisterUnitWatch
local RegisterStateDriver = RegisterStateDriver
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local CLASS_SORT_ORDER = CLASS_SORT_ORDER
local NUM_CLASS_ORDER = #CLASS_SORT_ORDER
local MAX_RAID_MEMBERS = MAX_RAID_MEMBERS
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS

local configEnv
local originalEnvs = {}
local overrideFuncs = {}

local forceShown = {}
local attributeBlacklist = {
	showRaid = true,
	showParty = true,
	showSolo = true
}

local colorTags = {
	healthcolor = true,
	powercolor = true,
	classcolor = true,
	namecolor = true
}

local PowerType = Enum.PowerType
local classPowers = {
	[0] = PowerType.Mana,
	[1] = PowerType.Rage,
	[2] = PowerType.Focus,
	[3] = PowerType.Energy
}

if E.Wrath then -- also handled in Elements/Power
	classPowers[4] = PowerType.RunicPower
elseif E.Retail then
	classPowers[4] = PowerType.RunicPower
	classPowers[5] = PowerType.PAIN
	classPowers[6] = PowerType.FURY
	classPowers[7] = PowerType.LunarPower
	classPowers[8] = PowerType.Insanity
	classPowers[9] = PowerType.Maelstrom
	classPowers[10] = PowerType.Alternate or 10
end

local function envUnit(arg1)
	local frame = configEnv._FRAME -- yoink
	if not frame then return arg1, true end

	local cool = frame.oldUnit
	local unit = frame.unit or arg1
	if cool then -- everyone who is cool <3
		return cool or unit
	else -- someone that's okay, i guess
		return unit, true
	end
end

local function createConfigEnv()
	if configEnv then return end

	configEnv = setmetatable({
		UnitPower = function(arg1, displayType)
			local unit, real = envUnit(arg1)
			if real then
				return UnitPower(unit, displayType)
			end

			local maxPower = UnitPowerMax(unit, displayType) or 0
			return random(1, (maxPower > 0 and maxPower) or 100)
		end,
		UnitPowerType = function(arg1)
			local unit, real = envUnit(arg1)
			if real then
				return UnitPowerType(unit)
			end

			return classPowers[random(0, #classPowers)]
		end,
		UnitHealth = function(arg1)
			local unit, real = envUnit(arg1)
			if real then
				return UnitHealth(unit)
			end

			local maxHealth = UnitHealthMax(unit) or 0
			return random(1, (maxHealth > 0 and maxHealth) or 100)
		end,
		UnitName = function(arg1)
			local unit, real = envUnit(arg1)
			if real then
				return UnitName(unit)
			end

			local cool = E.CreditsList
			local people = cool and #cool
			if people > 0 then
				return cool[random(1, people)]
			else
				return UnitName(unit)
			end
		end,
		UnitClass = function(arg1)
			local unit, real = envUnit(arg1)
			if real then
				return UnitClass(unit)
			end

			local classToken = CLASS_SORT_ORDER[random(1, NUM_CLASS_ORDER)]
			return LOCALIZED_CLASS_NAMES_MALE[classToken], classToken
		end,
		Env = ElvUF.Tags.Env,
		_VARS = ElvUF.Tags.Vars,
		_COLORS = ElvUF.colors,
		ColorGradient = ElvUF.ColorGradient,
	}, {
		__index = function(obj, key)
			local envValue = ElvUF.Tags.Env[key]
			if envValue ~= nil then
				return envValue
			end

			return obj[key]
		end,
		__newindex = function(_, key, value)
			_G[key] = value
		end,
	})

	for tag, func in next, ElvUF.Tags.Methods do
		if colorTags[tag] or (strfind(tag, '^name:') or strfind(tag, '^health:') or strfind(tag, '^power:')) then
			overrideFuncs[tag] = func
		end
	end
end

local function WhoIsAwesome(awesome)
	if not configEnv then
		createConfigEnv()
	end

	if awesome then
		for _, func in pairs(overrideFuncs) do
			if type(func) == 'function' then
				if not originalEnvs[func] then
					originalEnvs[func] = getfenv(func)
					setfenv(func, configEnv)
				end
			end
		end
	else
		for func, env in pairs(originalEnvs) do
			setfenv(func, env)
			originalEnvs[func] = nil
		end
	end
end

function UF:ForceShow(frame)
	if InCombatLockdown() then return end
	if not frame.isForced then
		frame.isForced = true
		frame.forceShowAuras = true

		frame.unit = 'player'
		frame.oldUnit = frame.unit
	end

	if not next(forceShown) then
		WhoIsAwesome(true)
	end
	forceShown[frame] = true

	frame:EnableMouse(false)
	frame:Show()

	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame, true)

	if frame.Update then
		frame:Update()
	end

	if _G[frame:GetName()..'Target'] then
		self:ForceShow(_G[frame:GetName()..'Target'])
	end

	if _G[frame:GetName()..'Pet'] then
		self:ForceShow(_G[frame:GetName()..'Pet'])
	end
end

function UF:UnforceShow(frame)
	if InCombatLockdown() then return end
	if not frame.isForced then return end

	forceShown[frame] = nil
	if not next(forceShown) then
		WhoIsAwesome(false)
	end

	frame.isForced = nil
	frame.forceShowAuras = nil

	if frame.oldUnit ~= nil then
		frame.unit = frame.oldUnit
		frame.oldUnit = nil
	end

	frame:EnableMouse(true)

	-- Ask the SecureStateDriver to show/hide the frame for us
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame)

	if _G[frame:GetName()..'Target'] then
		self:UnforceShow(_G[frame:GetName()..'Target'])
	end

	if _G[frame:GetName()..'Pet'] then
		self:UnforceShow(_G[frame:GetName()..'Pet'])
	end

	if frame.Update then
		frame:Update()
	end
end

do
	local allowHidePlayer = {
		party = true,
		raid1 = true,
		raid2 = true,
		raid3 = true
	}

	local function ForceShow(frame, index, length)
		frame:SetID(index)

		if not length or (index % length) > 0 then
			UF:ForceShow(frame)
		end
	end

	function UF:ShowChildUnits(header)
		header.isForced = true

		local length -- Limit number of players shown, if Display Player option is disabled
		if not UF.isForcedHidePlayer and not header.db.showPlayer and allowHidePlayer[header.groupName] then
			UF.isForcedHidePlayer = true
			length = MAX_PARTY_MEMBERS + 1
		end

		header:ExecuteForChildren(nil, ForceShow, length)
	end

	local function UnforceShow(frame)
		UF:UnforceShow(frame)
	end

	function UF:UnshowChildUnits(header)
		header.isForced = nil
		UF.isForcedHidePlayer = nil

		header:ExecuteForChildren(nil, UnforceShow)
	end
end

local function OnAttributeChanged(self, attr)
	if not self:IsShown() or (not self:GetParent().forceShow and not self.forceShow) then return end

	local db = self.db or self:GetParent().db
	local tankAssist = self.groupName == 'tank' or self.groupName == 'assist'
	local index = tankAssist and -1 or not db.raidWideSorting and -4 or -(min((db.numGroups or 1) * ((db.groupsPerRowCol or 1) * 5), MAX_RAID_MEMBERS) + 1)
	if self:GetAttribute('startingIndex') ~= index then
		self:SetAttribute('startingIndex', index)
		UF:ShowChildUnits(self)
	elseif tankAssist then -- for showing target frames
		if attr == 'startingindex' then
			self.waitForTarget = db.targetsGroup.enable or nil
		elseif self.waitForTarget and attr == 'statehidden' then
			UF:ShowChildUnits(self)
			self.waitForTarget = nil
		end
	end
end

function UF:HeaderForceShow(header, group, configMode)
	if group:IsShown() then
		group.forceShow = header.forceShow
		group.forceShowAuras = header.forceShowAuras

		if not group.hasOnAttributeChanged then
			group:HookScript('OnAttributeChanged', OnAttributeChanged)
			group.hasOnAttributeChanged = true
		end

		if configMode then
			for key in pairs(attributeBlacklist) do
				group:SetAttribute(key, nil)
			end

			OnAttributeChanged(group)

			group:Update()
		else
			for key in pairs(attributeBlacklist) do
				group:SetAttribute(key, true)
			end

			UF:UnshowChildUnits(group)
			group:SetAttribute('startingIndex', 1)

			group:Update()
		end
	end
end

function UF:HeaderConfig(header, configMode)
	if InCombatLockdown() then return end

	header.forceShow = configMode
	header.forceShowAuras = configMode
	header.isForced = configMode

	if configMode then
		RegisterStateDriver(header, 'visibility', 'show')
	else
		RegisterStateDriver(header, 'visibility', header.db.visibility)

		local onEvent = header:GetScript('OnEvent')
		if onEvent then
			onEvent(header, 'PLAYER_ENTERING_WORLD')
		end
	end

	if header.groups then
		for i = 1, #header.groups do
			UF:HeaderForceShow(header, header.groups[i], configMode)
		end

		UF.headerFunctions[header.groupName]:AdjustVisibility(header)
	else -- used to show tank/assist
		UF:HeaderForceShow(header, header, configMode)
	end
end

function UF:PLAYER_REGEN_DISABLED()
	for _, header in pairs(UF.headers) do
		if header.forceShow then
			self:HeaderConfig(header)
		end
	end

	for _, frame in pairs(UF.units) do
		if frame.forceShow then
			self:UnforceShow(frame)
		end
	end

	for i = 1, 8 do
		if i < 6 then
			local arena = self['arena'..i]
			if arena and arena.isForced then
				self:UnforceShow(arena)
			end
		end

		local boss = self['boss'..i]
		if boss and boss.isForced then
			self:UnforceShow(boss)
		end
	end
end

UF:RegisterEvent('PLAYER_REGEN_DISABLED')
