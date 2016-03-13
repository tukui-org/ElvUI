local parent, ns = ...
local oUF = ns.oUF

local updateFrequentUpdates
oUF.colors.power = {}
for power, color in next, PowerBarColor do
	if(type(power) == 'string') then
		oUF.colors.power[power] = {color.r, color.g, color.b}
	end
end

local GetDisplayPower = function(power, unit)
	if not unit then return; end
	local _, _, _, _, _, _, showOnRaid = UnitAlternatePowerInfo(unit)
	if(power.displayAltPower and showOnRaid) then
		return ALTERNATE_POWER_INDEX
	else
		return (UnitPowerType(unit))
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) or not unit then return end
	local power = self.Power

	if(power.PreUpdate) then power:PreUpdate(unit) end

	local displayType = GetDisplayPower(power, unit)
	local min, max = UnitPower(unit, displayType), UnitPowerMax(unit, displayType)
	local disconnected = not UnitIsConnected(unit)
	if max == 0 then
		max = 1
	end
	power:SetMinMaxValues(0, max)

	if(disconnected) then
		power:SetValue(max)
	else
		power:SetValue(min)
	end

	power.disconnected = disconnected
	if power.frequentUpdates ~= power.__frequentUpdates then
		power.__frequentUpdates = power.frequentUpdates
		updateFrequentUpdates(self)
	end

	local r, g, b, t
	if(power.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit)) then
		t = self.colors.tapped
	elseif(power.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	elseif(power.colorPower) then
		local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)

		t = self.colors.power[ptoken]
		if(not t and altR) then
			r, g, b = altR, altG, altB
		end
	elseif(power.colorClass and UnitIsPlayer(unit)) or
		(power.colorClassNPC and not UnitIsPlayer(unit)) or
		(power.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(power.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(power.colorSmooth) then
		r, g, b = self.ColorGradient(min, max, unpack(power.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		power:SetStatusBarColor(r, g, b)

		local bg = power.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(power.PostUpdate) then
		return power:PostUpdate(unit, min, max)
	end
end

local Path = function(self, ...)
	return (self.Power.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

function updateFrequentUpdates(self)
	local power = self.Power
	if power.frequentUpdates and not self:IsEventRegistered('UNIT_POWER_FREQUENT') then
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)

		if self:IsEventRegistered('UNIT_POWER') then
			self:UnregisterEvent('UNIT_POWER', Path)
		end
	elseif not self:IsEventRegistered('UNIT_POWER') then
		self:RegisterEvent('UNIT_POWER', Path)

		if self:IsEventRegistered('UNIT_POWER_FREQUENT') then
			self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		end		
	end
end

local Enable = function(self, unit)
	local power = self.Power
	if(power) then
		power.__owner = self
		power.ForceUpdate = ForceUpdate

		power.__frequentUpdates = power.frequentUpdates
		updateFrequentUpdates(self)

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Path)

		if(power:IsObjectType'StatusBar' and not power:GetStatusBarTexture()) then
			power:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local power = self.Power
	if(power) then
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Power', Path, Enable, Disable)
