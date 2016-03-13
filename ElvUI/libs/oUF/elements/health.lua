--[[ Element: Health Bar

 Handles updating of `self.Health` based on the units health.

 Widget

 Health - A StatusBar used to represent current unit health.

 Sub-Widgets

 .bg - A Texture which functions as a background. It will inherit the color of
       the main StatusBar.

 Notes

 The default StatusBar texture will be applied if the UI widget doesn't have a
 status bar texture or color defined.

 Options

 The following options are listed by priority. The first check that returns
 true decides the color of the bar.

 .colorTapping      - Use `self.colors.tapping` to color the bar if the unit
                      isn't tapped by the player.
 .colorDisconnected - Use `self.colors.disconnected` to color the bar if the
                      unit is offline.
 .colorClass        - Use `self.colors.class[class]` to color the bar based on
                      unit class. `class` is defined by the second return of
                      [UnitClass](http://wowprogramming.com/docs/api/UnitClass).
 .colorClassNPC     - Use `self.colors.class[class]` to color the bar if the
                      unit is a NPC.
 .colorClassPet     - Use `self.colors.class[class]` to color the bar if the
                      unit is player controlled, but not a player.
 .colorReaction     - Use `self.colors.reaction[reaction]` to color the bar
                      based on the player's reaction towards the unit.
                      `reaction` is defined by the return value of
                      [UnitReaction](http://wowprogramming.com/docs/api/UnitReaction).
 .colorSmooth       - Use `self.colors.smooth` to color the bar with a smooth
                      gradient based on the player's current health percentage.
 .colorHealth       - Use `self.colors.health` to color the bar. This flag is
                      used to reset the bar color back to default if none of the
                      above conditions are met.

 Sub-Widgets Options

 .multiplier - Defines a multiplier, which is used to tint the background based
               on the main widgets R, G and B values. Defaults to 1 if not
               present.

 Examples

   -- Position and size
   local Health = CreateFrame("StatusBar", nil, self)
   Health:Height(20)
   Health:SetPoint('TOP')
   Health:SetPoint('LEFT')
   Health:SetPoint('RIGHT')
   
   -- Add a background
   local Background = Health:CreateTexture(nil, 'BACKGROUND')
   Background:SetAllPoints(Health)
   Background:SetTexture(1, 1, 1, .5)
   
   -- Options
   Health.frequentUpdates = true
   Health.colorTapping = true
   Health.colorDisconnected = true
   Health.colorClass = true
   Health.colorReaction = true
   Health.colorHealth = true
   
   -- Make the background darker.
   Background.multiplier = .5
   
   -- Register it with oUF
   self.Health = Health
   self.Health.bg = Background

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]
local parent, ns = ...
local oUF = ns.oUF
local updateFrequentUpdates
oUF.colors.health = {49/255, 207/255, 37/255}


local Update = function(self, event, unit)
	if(self.unit ~= unit) or not unit then return end
	local health = self.Health

	if(health.PreUpdate) then health:PreUpdate(unit) end

	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local disconnected = not UnitIsConnected(unit)
	health:SetMinMaxValues(0, max)

	if(disconnected) then
		health:SetValue(max)
	else
		health:SetValue(min)
	end

	health.disconnected = disconnected

	if health.frequentUpdates ~= health.__frequentUpdates then
		health.__frequentUpdates = health.frequentUpdates
		updateFrequentUpdates(self)
	end

	local r, g, b, t
	if(health.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit)) then
		t = self.colors.tapped
	elseif(health.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	elseif(health.colorClass and UnitIsPlayer(unit)) or
		(health.colorClassNPC and not UnitIsPlayer(unit)) or
		(health.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(health.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(health.colorSmooth) then
		r, g, b = self.ColorGradient(min, max, unpack(health.smoothGradient or self.colors.smooth))
	elseif(health.colorHealth) then
		t = self.colors.health
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		health:SetStatusBarColor(r, g, b)
		local bg = health.bg
		if(bg) then local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(health.PostUpdate) then
		return health:PostUpdate(unit, min, max)
	end
end

local Path = function(self, ...)
	return (self.Health.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

function updateFrequentUpdates(self)
	local health = self.Health
	if health.frequentUpdates and not self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
		if GetCVarBool("predictedHealth") ~= true then
			SetCVar("predictedHealth", "1")
		end

		self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)

		if self:IsEventRegistered("UNIT_HEALTH") then
			self:UnregisterEvent("UNIT_HEALTH", Path)
		end
	elseif not self:IsEventRegistered("UNIT_HEALTH") then
		self:RegisterEvent('UNIT_HEALTH', Path)

		if self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
			self:UnregisterEvent("UNIT_HEALTH_FREQUENT", Path)
		end	
	end
end

local Enable = function(self, unit)
	local health = self.Health
	if(health) then
		health.__owner = self
		health.ForceUpdate = ForceUpdate
		health.__frequentUpdates = health.frequentUpdates
		updateFrequentUpdates(self)

		self:RegisterEvent("UNIT_MAXHEALTH", Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)

		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Path)

		if(health:IsObjectType'StatusBar' and not health:GetStatusBarTexture()) then
			health:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local health = self.Health
	if(health) then
		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)

		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Health', Path, Enable, Disable)
