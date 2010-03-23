--[[
	Elements handled: .Health

	Shared:
	 The following settings are listed by priority:
	 - colorTapping
	 - colorDisconnected
	 - colorHappiness
	 - colorClass (Colors player units based on class)
	 - colorClassPet (Colors pet units based on class)
	 - colorClassNPC (Colors non-player units based on class)
	 - colorReaction
	 - colorSmooth - will use smoothGradient instead of the internal gradient if set.
	 - colorHealth

	Background:
	 - multiplier - number used to manipulate the power background. (default: 1)

	WotLK only:
	 - frequentUpdates - do OnUpdate polling of health data.

	Functions that can be overridden from within a layout:
	 - :PreUpdateHealth(event, unit)
	 - :OverrideUpdateHealth(event, unit, bar, min, max) - Setting this function
	 will disable the above color settings.
	 - :PostUpdateHealth(event, unit, bar, min, max)
--]]
local parent, ns = ...
local oUF = ns.oUF

oUF.colors.health = {49/255, 207/255, 37/255}

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end
	if(self.PreUpdateHealth) then self:PreUpdateHealth(event, unit) end

	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local disconnected = not UnitIsConnected(unit)
	local bar = self.Health
	bar:SetMinMaxValues(0, max)

	if(disconnected) then
		bar:SetValue(max)
	else
		bar:SetValue(min)
	end

	bar.disconnected = disconnected
	bar.unit = unit

	if(not self.OverrideUpdateHealth) then
		local r, g, b, t
		if(bar.colorTapping and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
			t = self.colors.tapped
		elseif(bar.colorDisconnected and not UnitIsConnected(unit)) then
			t = self.colors.disconnected
		elseif(bar.colorHappiness and unit == "pet" and GetPetHappiness()) then
			t = self.colors.happiness[GetPetHappiness()]
		elseif(bar.colorReaction and UnitReaction(unit, 'player') and UnitIsEnemy(unit, "player") and not (unit and unit:find("arena%d"))) then
			t = self.colors.reaction[UnitReaction(unit, "player")]
		elseif(bar.colorClass and UnitIsPlayer(unit)) or
			(bar.colorClassNPC and not UnitIsPlayer(unit)) or
			(bar.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = self.colors.class[class]
		elseif(bar.colorReaction and UnitReaction(unit, 'player')) then
			t = self.colors.reaction[UnitReaction(unit, "player")]
		elseif(bar.colorSmooth) then
			r, g, b = self.ColorGradient(min / max, unpack(bar.smoothGradient or self.colors.smooth))
		elseif(bar.colorHealth) then
			t = self.colors.health
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
		self:OverrideUpdateHealth(event, unit, bar, min, max)
	end

	if(self.PostUpdateHealth) then
		return self:PostUpdateHealth(event, unit, bar, min, max)
	end
end

local OnHealthUpdate
do
	local UnitHealth = UnitHealth
	OnHealthUpdate = function(self)
		if(self.disconnected) then return end
		local health = UnitHealth(self.unit)

		if(health ~= self.min) then
			self.min = health

			return Update(self:GetParent(), "OnHealthUpdate", self.unit)
		end
	end
end

local Enable = function(self, unit)
	local health = self.Health
	if(health) then
		if(health.frequentUpdates and (unit and not unit:match'%w+target$') or not unit) then
			health:SetScript('OnUpdate', OnHealthUpdate)

			-- The party frames need this to handle disconnect states correctly.
			if(not unit) then
				self:RegisterEvent("UNIT_HEALTH", Update)
			end
		else
			self:RegisterEvent("UNIT_HEALTH", Update)
		end

		self:RegisterEvent("UNIT_MAXHEALTH", Update)
		self:RegisterEvent('UNIT_HAPPINESS', Update)
		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Update)

		if(not health:GetStatusBarTexture()) then
			health:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local health = self.Health
	if(health) then
		if(health:GetScript'OnUpdate') then
			health:SetScript('OnUpdate', nil)
		else
			self:UnregisterEvent('UNIT_HEALTH', Update)
		end

		self:UnregisterEvent('UNIT_MAXHEALTH', Update)
		self:UnregisterEvent('UNIT_HAPPINESS', Update)
		self:UnregisterEvent('UNIT_FACTION', Update)
	end
end

oUF:AddElement('Health', Update, Enable, Disable)
