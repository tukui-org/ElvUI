local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local CreateFrame = CreateFrame

local function MouseOnUnit(frame)
	if frame and frame:IsVisible() and UnitExists('mouseover') then
		return frame.unit and UnitIsUnit('mouseover', frame.unit)
	end

	return false
end

local function OnUpdate(self, elapsed)
	if self.elapsed and self.elapsed > 0.1 then
		local element = self:GetParent()
		if element and not MouseOnUnit(element) then
			self:Hide()
			element:ForceUpdate()
		elseif not element then
			self:Hide()
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
		element.watcher:Show()
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

		if not element.watcher then
			element.watcher = CreateFrame('Frame', nil, element)
			element.watcher:SetScript('OnUpdate', OnUpdate)
			element.watcher:Hide()
		end

		self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.Highlight
	if element then
		element:Hide()

		self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', Path)
	end
end

oUF:AddElement('Highlight', Path, Enable, Disable)
