local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

-- Cache global variables
-- Lua functions
-- WoW API / Variables
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local C_Timer_After = C_Timer.After

local function MouseOnUnit(frame)
	if frame and frame:IsVisible() and UnitExists('mouseover') then
		return frame.unit and UnitIsUnit('mouseover', frame.unit)
	end

	return false
end

local function Update(self, event)
	local element = self.Highlight

	if (element.PreUpdate) then
		element:PreUpdate()
	end

	if MouseOnUnit(self) or UnitIsUnit("mouseover", self.unit) then
		element:Show()
		C_Timer_After(.1, function() element:ForceUpdate() end)
	else
		element:Hide()
	end

	if (element.PostUpdate) then
		return element:PostUpdate(element:IsShown())
	end
end

local function Path(self, ...)
	return (self.Highlight.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.Highlight
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.Highlight
	if (element) then
		element:Hide()

		self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT", Path)
	end
end

oUF:AddElement('Highlight', Path, Enable, Disable)
