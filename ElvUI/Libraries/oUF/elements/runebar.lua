--[[ Element: Runes Bar

 Handle updating and visibility of the Death Knight's Rune indicators.

 Widget

 Runes - An array holding StatusBar's.

 Sub-Widgets

 .bg - A Texture which functions as a background. It will inherit the color of
       the main StatusBar.

 Notes

 The default StatusBar texture will be applied if the UI widget doesn't have a
             status bar texture or color defined.

 Sub-Widgets Options

 .multiplier - Defines a multiplier, which is used to tint the background based
               on the main widgets R, G and B values. Defaults to 1 if not
               present.

 Examples

   local Runes = {}
   for index = 1, 6 do
      -- Position and size of the rune bar indicators
      local Rune = CreateFrame('StatusBar', nil, self)
      Rune:SetSize(120 / 6, 20)
      Rune:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * 120 / 6, 0)

      Runes[index] = Rune
   end

   -- Register with oUF
   self.Runes = Runes

 Hooks

 Override(self)           - Used to completely override the internal update
                            function. Removing the table key entry will make the
                            element fall-back to its internal function again.

]]

if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local parent, ns = ...
local oUF = ns.oUF

local OnUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
end

local Update = function(self, event, rid, energized)
	local runes = self.Runes
	local rune = runes[rid]
	if(not rune) then return end

	local start, duration, runeReady
	if(UnitHasVehicleUI'player') then
		rune:Hide()
	else
		start, duration, runeReady = GetRuneCooldown(rid)
		if(not start) then return end

		if(energized or runeReady) then
			rune:SetMinMaxValues(0, 1)
			rune:SetValue(1)
			rune:SetScript("OnUpdate", nil)
		else
			rune.duration = GetTime() - start
			rune.max = duration
			rune:SetMinMaxValues(1, duration)
			rune:SetScript("OnUpdate", OnUpdate)
		end

		rune:Show()
	end

	if(runes.PostUpdate) then
		return runes:PostUpdate(rune, rid, energized and 0 or start, duration, energized or runeReady)
	end
end

local Path = function(self, event, ...)
	local runes = self.Runes
	local UpdateMethod = runes.Override or Update
	if(event == 'RUNE_POWER_UPDATE') then
		return UpdateMethod(self, event, ...)
	else
		for index = 1, #runes do
			UpdateMethod(self, event, index)
		end
	end
end

local function RunesEnable(self)
	self:RegisterEvent('UNIT_ENTERED_VEHICLE', VisibilityPath)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", VisibilityPath)

	self.Runes:Show()

	if self.Runes.PostUpdateVisibility then
		self.Runes:PostUpdateVisibility(true, not self.Runes.isEnabled)
	end

	self.Runes.isEnabled = true

	Path(self, 'RunesEnable')
end

local function RunesDisable(self)
	self:UnregisterEvent('UNIT_ENTERED_VEHICLE', VisibilityPath)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", VisibilityPath)

	self.Runes:Hide()

	if self.Runes.PostUpdateVisibility then
		self.Runes:PostUpdateVisibility(false, self.Runes.isEnabled)
	end

	self.Runes.isEnabled = false

	Path(self, 'RunesDisable')
end

local function Visibility(self, event, ...)
	local element = self.Runes
	local shouldEnable

	if not (UnitHasVehicleUI('player')) then
		shouldEnable = true
	end

	local isEnabled = element.isEnabled
	if(shouldEnable and not isEnabled) then
		RunesEnable(self)
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		RunesDisable(self)
	elseif(shouldEnable and isEnabled) then
		Path(self, event, ...)
	end
end

local VisibilityPath = function(self, ...)
	return (self.Runes.OverrideVisibility or Visibility) (self, ...)
end

local ForceUpdate = function(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local runes = self.Runes
	if(runes and unit == 'player') then
		runes.__owner = self
		runes.ForceUpdate = ForceUpdate

		for i = 1, #runes do
			local rune = runes[i]

			local r, g, b = unpack(self.colors.power.RUNES)
			if(rune:IsObjectType'StatusBar' and not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
				rune:SetStatusBarColor(r, g, b)
			end

			if(rune.bg) then
				local mu = rune.bg.multiplier or 1
				rune.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end

		self:RegisterEvent("RUNE_POWER_UPDATE", Path, true)

		return true
	end
end

local Disable = function(self)
	self:UnregisterEvent("RUNE_POWER_UPDATE", Path)

	RunesDisable(self)
end

oUF:AddElement("Runes", VisibilityPath, Enable, Disable)
