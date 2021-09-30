local E, L, V, P, G = unpack(ElvUI)
local oUF = E.oUF

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit

local function MouseOnUnit(frame)
	if frame and frame:IsVisible() and UnitExists('mouseover') then
		return frame.unit and UnitIsUnit('mouseover', frame.unit)
	end

	return false
end

local function OnUpdate(self, elapsed)
	if self.elapsed and self.elapsed > 0.1 then
		if not MouseOnUnit(self) then
			self:Hide()
			self:ForceUpdate()
		end

		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end

local function Update(self)
	local element = self.Highlight

	if element.PreUpdate then
		element:PreUpdate()
	end

	if MouseOnUnit(self) then
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		return element:PostUpdate(element:IsShown())
	end
end

local function Path(self, ...)
	return (self.Highlight.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.Highlight
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element:SetScript('OnUpdate', OnUpdate)

		self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.Highlight
	if element then
		element:Hide()
		element:SetScript('OnUpdate', nil)

		self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', Path)
	end
end

oUF:AddElement('Highlight', Path, Enable, Disable)
