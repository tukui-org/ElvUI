--[[
	Elements handled: .Power

	Shared:
	 The following settings are listed by priority:
	 - colorTapping
	 - colorDisconnected
	 - colorHappiness
	 - colorPower
	 - colorClass (Colors player units based on class)
	 - colorClassPet (Colors pet units based on class)
	 - colorClassNPC (Colors non-player units based on class)
	 - colorReaction
	 - colorSmooth - will use smoothGradient instead of the internal gradient if set.

	Background:
	 - multiplier - number used to manipulate the power background. (default: 1)
	 This option will only enable for player and pet.
	 - frequentUpdates - do OnUpdate polling of power data.

	Functions that can be overridden from within a layout:
	 - :PreUpdatePower(event, unit)
	 - :OverrideUpdatePower(event, unit, bar, min, max) - Setting this function
	 will disable the above color settings.
	 - :PostUpdatePower(event, unit, bar, min, max)
--]]
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
	if(self.PreUpdatePower) then self:PreUpdatePower(event, unit) end

	local min, max = UnitPower(unit), UnitPowerMax(unit)
	local disconnected = not UnitIsConnected(unit)
	local bar = self.Power
	bar:SetMinMaxValues(0, max)

	if(disconnected) then
		bar:SetValue(max)
	else
		bar:SetValue(min)
	end

	bar.disconnected = disconnected
	bar.unit = unit

	if(not self.OverrideUpdatePower) then
		local r, g, b, t
		if(bar.colorTapping and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
			t = self.colors.tapped
		elseif(bar.colorDisconnected and not UnitIsConnected(unit)) then
			t = self.colors.disconnected
		elseif(bar.colorHappiness and unit == "pet" and GetPetHappiness()) then
			t = self.colors.happiness[GetPetHappiness()]
		elseif(bar.colorPower) then
			local ptype, ptoken, altR, altG, altB  = UnitPowerType(unit)

			t = self.colors.power[ptoken]
			if(not t and altR) then
				r, g, b = altR, altG, altB
			end
		elseif(bar.colorClass and UnitIsPlayer(unit)) or
			(bar.colorClassNPC and not UnitIsPlayer(unit)) or
			(bar.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = self.colors.class[class]
		elseif(bar.colorReaction and UnitReaction(unit, 'player')) then
			t = self.colors.reaction[UnitReaction(unit, "player")]
		elseif(bar.colorSmooth) then
			r, g, b = self.ColorGradient(min / max, unpack(bar.smoothGradient or self.colors.smooth))
		end

		if(t) then
			r, g, b = t[1], t[2], t[3]
		end

		if(b) then
			bar:SetStatusBarColor(r, g, b)

			local bg = bar.bg
			if(bg) then
				local mu = bg.multiplier or 1
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	else
		self:OverrideUpdatePower(event, unit, bar, min, max)
	end

	if(self.PostUpdatePower) then
		return self:PostUpdatePower(event, unit, bar, min, max)
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

			return Update(self:GetParent(), 'OnPowerUpdate', self.unit)
		end
	end
end

local Enable = function(self, unit)
	local power = self.Power
	if(power) then
		if(power.frequentUpdates and (unit == 'player' or unit == 'pet')) then
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
