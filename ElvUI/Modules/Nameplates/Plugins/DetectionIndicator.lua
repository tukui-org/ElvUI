local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local UnitAura = UnitAura
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY

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

	local unit = self.displayedUnit or self.unit
	local canDetect

	for i = 1, BUFF_MAX_DISPLAY do
		local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, i, 'HELPFUL')
		if name and (spellId and DETECTION_BUFFS[spellId]) then
			canDetect = true
			break
		end
	end

	if canDetect then
		self.DetectionIndicator:Show()
		self.DetectionIndicator:SetModel("Spells\\Blackfuse_LaserTurret_GroundBurn_State_Base")
		self.DetectionIndicator:SetPosition(3, 0, 1.5)
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
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.DetectionIndicator
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_NAME_UPDATE", Path)
		self:RegisterEvent("UNIT_AURA", Path)

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
