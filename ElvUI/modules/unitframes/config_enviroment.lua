local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF

local attributeBlacklist = {["showRaid"] = true, ["showParty"] = true, ["showSolo"] = true}
local configEnv
local originalEnvs = {}
local overrideFuncs = {}
local format = string.format
local min, random = math.min, math.random

local function createConfigEnv()
	if( configEnv ) then return end
	configEnv = setmetatable({
		UnitPower = function (unit, displayType)
			if unit:find('target') or unit:find('focus') then
				return UnitPower(unit, displayType)
			end

			return random(1, UnitPowerMax(unit, displayType) or 1)
		end,
		UnitHealth = function(unit)
			if unit:find('target') or unit:find('focus') then
				return UnitHealth(unit)
			end

			return random(1, UnitHealthMax(unit))
		end,
		UnitName = function(unit)
			if unit:find('target') or unit:find('focus') then
				return UnitName(unit)
			end
			if E.CreditsList then
				local max = #E.CreditsList
				return E.CreditsList[random(1, max)]
			end
			return 'Test Name'
		end,
		UnitClass = function(unit)
			if unit:find('target') or unit:find('focus') then
				return UnitClass(unit)
			end		
		
			local classToken = CLASS_SORT_ORDER[random(1, #(CLASS_SORT_ORDER))]
			return LOCALIZED_CLASS_NAMES_MALE[classToken], classToken
		end,
		Hex = function(r, g, b)
			if type(r) == "table" then
				if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
			end
			return format("|cff%02x%02x%02x", r*255, g*255, b*255)
		end,
		ColorGradient = ElvUF.ColorGradient,		
	}, {
		__index = _G,
		__newindex = function(tbl, key, value) _G[key] = value end,
	})
	
	overrideFuncs['namecolor'] = ElvUF.Tags.Methods['namecolor']
	overrideFuncs['name:veryshort'] = ElvUF.Tags.Methods['name:veryshort']
	overrideFuncs['name:short'] = ElvUF.Tags.Methods['name:short']
	overrideFuncs['name:medium'] = ElvUF.Tags.Methods['name:medium']
	overrideFuncs['name:long'] = ElvUF.Tags.Methods['name:long']

	overrideFuncs['healthcolor'] = ElvUF.Tags.Methods['healthcolor']
	overrideFuncs['health:current'] = ElvUF.Tags.Methods['health:current']
	overrideFuncs['health:deficit'] = ElvUF.Tags.Methods['health:deficit']
	overrideFuncs['health:current-percent'] = ElvUF.Tags.Methods['health:current-percent']	
	overrideFuncs['health:current-max'] = ElvUF.Tags.Methods['health:current-max']	
	overrideFuncs['health:current-max-percent'] = ElvUF.Tags.Methods['health:current-max-percent']	
	overrideFuncs['health:max'] = ElvUF.Tags.Methods['health:max']	
	overrideFuncs['health:percent'] = ElvUF.Tags.Methods['health:percent']	

	overrideFuncs['powercolor'] = ElvUF.Tags.Methods['powercolor']
	overrideFuncs['power:current'] = ElvUF.Tags.Methods['power:current']
	overrideFuncs['power:deficit'] = ElvUF.Tags.Methods['power:deficit']
	overrideFuncs['power:current-percent'] = ElvUF.Tags.Methods['power:current-percent']	
	overrideFuncs['power:current-max'] = ElvUF.Tags.Methods['power:current-max']	
	overrideFuncs['power:current-max-percent'] = ElvUF.Tags.Methods['power:current-max-percent']	
	overrideFuncs['power:max'] = ElvUF.Tags.Methods['power:max']	
	overrideFuncs['power:percent'] = ElvUF.Tags.Methods['power:percent']		
end

function UF:ForceShow(frame)
	if InCombatLockdown() then return; end
	if not frame.isForced then		
		frame.oldUnit = frame.unit
		frame.unit = 'player'
		frame.isForced = true;
		frame.oldOnUpdate = frame:GetScript("OnUpdate")
	end

	frame:SetScript("OnUpdate", nil)
	frame.forceShowAuras = true
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame, true)	
	
	frame:Show()
	if frame:IsVisible() and frame.Update then
		frame:Update()
	end		
end

function UF:UnforceShow(frame)
	if InCombatLockdown() then return; end
	if not frame.isForced then
		return
	end
	frame.forceShowAuras = nil
	frame.isForced = nil
	
	-- Ask the SecureStateDriver to show/hide the frame for us
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame)

	if frame.oldOnUpdate then
		frame:SetScript("OnUpdate", frame.oldOnUpdate)
		frame.oldOnUpdate = nil
	end
	
	frame.unit = frame.oldUnit or frame.unit
	-- If we're visible force an update so everything is properly in a
	-- non-config mode state
	if frame:IsVisible() and frame.Update then
		frame:Update()
	end	
end

function UF:ShowChildUnits(header, ...)
	header.isForced = true
	
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		frame:RegisterForClicks(nil)
		frame:SetID(i)
		frame.TargetGlow:SetAlpha(0)
		self:ForceShow(frame)
	end
	
	header.dirtyWidth, header.dirtyHeight = header:GetSize()
	header.mover:Size(header.dirtyWidth, header.dirtyHeight)
end

function UF:UnshowChildUnits(header, ...)
	header.isForced = nil
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
		frame.TargetGlow:SetAlpha(1)
		self:UnforceShow(frame)
	end
end

local function GetNumChildrenShown(...)
	local num = 0
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		if frame:IsShown() then
			num = num + 1
		end
	end
	
	return num
end

local function OnAttributeChanged(self, name)
	if not self.forceShow then return; end

	local maxUnits = MAX_RAID_MEMBERS
	local startingIndex = -min(self.db.numGroups * self.db.unitsPerGroup, maxUnits) + 1
	local numChildren = self:GetNumChildren()
	if self:GetAttribute("startingIndex") ~= startingIndex then
		self:SetAttribute("startingIndex", startingIndex)
		self.lastNumChildren = numChildren
		UF:ShowChildUnits(self, self:GetChildren())
	elseif GetNumChildrenShown(self:GetChildren()) ~= (self.db.numGroups * self.db.unitsPerGroup) then
		UF:ShowChildUnits(self, self:GetChildren())
	elseif self.mover:GetWidth() ~= self:GetWidth() or self.mover:GetHeight() ~= self:GetHeight() then
		self.dirtyWidth, self.dirtyHeight = self:GetSize()
		self.mover:Size(self.dirtyWidth, self.dirtyHeight)	
	end
end

function UF:HeaderConfig(header, configMode)
	if InCombatLockdown() then return; end
	
	createConfigEnv()
	local db = header.db
	header.forceShow = configMode
	header:HookScript('OnAttributeChanged', OnAttributeChanged)
	if configMode then		
		header.forceShowAuras = true

		for key in pairs(attributeBlacklist) do
			header:SetAttribute(key, nil)
		end
		
		RegisterAttributeDriver(header, 'state-visibility', 'show')		
		
		OnAttributeChanged(header)

		for _, func in pairs(overrideFuncs) do
			if type(func) == 'function' then
				originalEnvs[func] = getfenv(func)
				setfenv(func, configEnv)		
			end
		end
		
		header:Update()	
	else
		for key in pairs(attributeBlacklist) do
			header:SetAttribute(key, true)
		end	
		header.forceShowAuras = nil		
		
		UF:UnshowChildUnits(header, header:GetChildren())
		
		for func, env in pairs(originalEnvs) do
			setfenv(func, env)
			originalEnvs[func] = nil
		end		
		
		header:Update()
	end
end

function UF:PLAYER_REGEN_DISABLED()
	for _, header in pairs(UF['headers']) do
		if header.forceShow then
			self:HeaderConfig(header)
		end
	end
	
	for _, unit in pairs(UF['units']) do
		local frame = self[unit]
		if frame and frame.forceShow then
			self:UnforceShow(frame)
		end	
	end
	
	for i=1, 5 do
		if self['arena'..i] and self['arena'..i].isForced then
			self:UnforceShow(self['arena'..i])
		end
	end
	
	for i=1, 4 do
		if self['boss'..i] and self['boss'..i].isForced then
			self:UnforceShow(self['boss'..i])
		end
	end	
end

UF:RegisterEvent('PLAYER_REGEN_DISABLED')