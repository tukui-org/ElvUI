local parent, ns = ...
local oUF = ns.oUF

oUF.colors.power = {}
for power, color in next, PowerBarColor do
	if(type(power) == 'string') then
		oUF.colors.power[power] = {color.r, color.g, color.b}
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end
	local power = self.Power

	if(power.PreUpdate) then power:PreUpdate(unit) end

	local min, max = UnitPower(unit), UnitPowerMax(unit)
	local disconnected = not UnitIsConnected(unit)
	power:SetMinMaxValues(0, max)

	if(disconnected) then
		power:SetValue(max)
	else
		power:SetValue(min)
	end

	power.disconnected = disconnected

	local r, g, b, t
	if(power.colorTapping and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		t = self.colors.tapped
	elseif(power.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	elseif(power.colorHappiness and UnitIsUnit(unit, "pet") and GetPetHappiness()) then
		t = self.colors.happiness[GetPetHappiness()]
	elseif(power.colorPower) then
		local ptype, ptoken, altR, altG, altB  = UnitPowerType(unit)

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
		r, g, b = self.ColorGradient(min / max, unpack(power.smoothGradient or self.colors.smooth))
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

local OnPowerUpdate
do
	local UnitPower = UnitPower
	OnPowerUpdate = function(self)
		if(self.disconnected) then return end
		local unit = self.__owner.unit
		local power = UnitPower(unit)

		if(power ~= self.min) then
			self.min = power

			return Path(self.__owner, 'OnPowerUpdate', unit)
		end
	end
end

local Enable = function(self, unit)
	local power = self.Power
	if(power) then
		power.__owner = self
		power.ForceUpdate = ForceUpdate

		if(power.frequentUpdates and (unit == 'player' or unit == 'pet')) then
			power:SetScript("OnUpdate", OnPowerUpdate)
		else
			self:RegisterEvent('UNIT_POWER', Path)
		end

		self:RegisterEvent('UNIT_CONNECTION', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Path)

		if(not power:GetStatusBarTexture()) then
			power:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local power = self.Power
	if(power) then
		if(power:GetScript'OnUpdate') then
			power:SetScript("OnUpdate", nil)
		else
			self:UnregisterEvent('UNIT_POWER', Path)
		end

		self:UnregisterEvent('UNIT_CONNECTION', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Power', Path, Enable, Disable)
