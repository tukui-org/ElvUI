local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF

local attributeBlacklist = {["showplayer"] = true, ["showraid"] = true, ["showparty"] = true, ["showsolo"] = true}


function UF:ForceShow(frame)
	if not frame.isForced then		
		frame.oldUnit = frame.unit
		frame.unit = 'player'
		frame.isForced = true;
	end
	frame.forceShowAuras = true
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame, true)	
	
	frame:Show()
	if frame:IsVisible() and frame.Update then
		frame:Update()
	end		
end

function UF:UnforceShow(frame)
	if not frame.isForced then
		return
	end
	frame.forceShowAuras = nil
	frame.isForced = nil
	
	-- Ask the SecureStateDriver to show/hide the frame for us
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame)
	
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
		self:ForceShow(frame)
	end
end

function UF:UnshowChildUnits(header, ...)
	header.isForced = nil
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		self:UnforceShow(frame)
	end
end

local function OnAttributeChanged(self, name)
	if not self.forceShow then return; end
	
	local maxUnits = MAX_RAID_MEMBERS
	local startingIndex = -math.min(self.db.maxColumns * self.db.unitsPerColumn, maxUnits) + 1
	if self:GetAttribute("startingIndex") ~= startingIndex then
		self:SetAttribute("startingIndex", startingIndex)
		UF:ShowChildUnits(self, self:GetChildren())	
	end
end

function UF:HeaderConfig(header, configMode)
	local db = header.db
	header.forceShow = configMode
	header:HookScript('OnAttributeChanged', OnAttributeChanged)
	if configMode then		
		header.forceShowAuras = true

		for key in pairs(attributeBlacklist) do
			header:SetAttribute(key, nil)
		end
		
		RegisterAttributeDriver(header, 'state-visibility', 'show')		
		
		local maxUnits = MAX_RAID_MEMBERS
		OnAttributeChanged(header)
		UF:ShowChildUnits(header, header:GetChildren())
		
		header:Update()	
	else
		header.forceShowAuras = nil
		header:SetAttribute("showParty", db.showParty)
		header:SetAttribute("showRaid", db.showRaid)
		header:SetAttribute("showSolo", db.showSolo)
		header:SetAttribute("showPlayer", db.showPlayer)
		
		UF:ChangeVisibility(header, 'custom '..db.visibility)
		
		header:SetAttribute("startingIndex", 1)
		UF:UnshowChildUnits(header, header:GetChildren())
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