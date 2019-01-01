local _, ns = ...
local oUF = ns.oUF

local UnitAura = UnitAura

--Cache detection buff names
local DETECTION_BUFFS = {
	[203761] = true, --Detector
	[213486] = true, --Demonic Vision
}

local function Update(self, event)
	local element = self.DetectionIndicator

	if (element.PreUpdate) then
		element:PreUpdate()
	end

	local unit = self.displayedUnit
	local canDetect
	for i = 1, BUFF_MAX_DISPLAY do
		local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, i, 'HELPFUL')
		if (not name) then
			break
		elseif (spellId and DETECTION_BUFFS[spellId]) then
			canDetect = true
			break
		end
	end

	if canDetect then
		self.DetectionIndicator:Show()
	else
		self.DetectionIndicator:Hide()
	end

	if (element.PostUpdate) then
		return element:PostUpdate(canDetect)
	end
end

local function Path(self, ...)
	return (self.DetectionIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.DetectionIndicator
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(element:IsObjectType('PlayerModel') and not element:GetTexture()) then
			element:SetModel([[Spells\Blackfuse_LaserTurret_GroundBurn_State_Base]])
			element:SetPosition(3, 0, 1.25)
		end

		return true
	end
end

local function Disable(self)
	local element = self.DetectionIndicator
	if (element) then
		element:Hide()
	end
end

oUF:AddElement('DetectionIndicator', Path, Enable, Disable)