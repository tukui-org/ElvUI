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
	power.unit = unit

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

local OnPowerUpdate
do
	local UnitPower = UnitPower
	OnPowerUpdate = function(self)
		if(self.disconnected) then return end
		local power = UnitPower(self.unit)

		if(power ~= self.min) then
			self.min = power

			return (self.Update or Update) (self:GetParent(), 'OnPowerUpdate', self.unit)
		end
	end
end

local Enable = function(self, unit)
	local power = self.Power
	if(power) then
		local Update = power.Update or Update
		if(power.frequentUpdates and (unit == 'player' or unit == 'pet')) then
			-- TODO 1.5: We should do this regardless of frequentUpdates.
			if(power:GetParent() ~= self) then
				return oUF.error('Element [%s] is incorrectly parented on [%s]. Expected self, got something else.', 'Power', unit)
			end

			power:SetScript("OnUpdate", OnPowerUpdate)
		else
			self:RegisterEvent("UNIT_MANA", Update)
			self:RegisterEvent("UNIT_RAGE", Update)
			self:RegisterEvent("UNIT_FOCUS", Update)
			self:RegisterEvent("UNIT_ENERGY", Update)
			self:RegisterEvent("UNIT_RUNIC_POWER", Update)
		end
		self:RegisterEvent("UNIT_MAXMANA", Update)
		self:RegisterEvent("UNIT_MAXRAGE", Update)
		self:RegisterEvent("UNIT_MAXFOCUS", Update)
		self:RegisterEvent("UNIT_MAXENERGY", Update)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Update)
		self:RegisterEvent("UNIT_MAXRUNIC_POWER", Update)

		self:RegisterEvent('UNIT_HAPPINESS', Update)
		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Update)

		if(not power:GetStatusBarTexture()) then
			power:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local power = self.Power
	if(power) then
		local Update = power.Update or Update
		if(power:GetScript'OnUpdate') then
			power:SetScript("OnUpdate", nil)
		else
			self:UnregisterEvent("UNIT_MANA", Update)
			self:UnregisterEvent("UNIT_RAGE", Update)
			self:UnregisterEvent("UNIT_FOCUS", Update)
			self:UnregisterEvent("UNIT_ENERGY", Update)
			self:UnregisterEvent("UNIT_RUNIC_POWER", Update)
		end
		self:UnregisterEvent("UNIT_MAXMANA", Update)
		self:UnregisterEvent("UNIT_MAXRAGE", Update)
		self:UnregisterEvent("UNIT_MAXFOCUS", Update)
		self:UnregisterEvent("UNIT_MAXENERGY", Update)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
		self:UnregisterEvent("UNIT_MAXRUNIC_POWER", Update)

		self:UnregisterEvent('UNIT_HAPPINESS', Update)
		self:UnregisterEvent('UNIT_FACTION', Update)
	end
end

oUF:AddElement('Power', Update, Enable, Disable)
