--local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
--local NP = E:GetModule('NamePlates')
--local LSM = E.Libs.LSM

--local tinsert = tinsert
--local UnitIsTapDenied = UnitIsTapDenied
--local CreateFrame = CreateFrame
--local C_Timer_After = C_Timer.After

--[[
	if ( r ~= frame.HealthBar.r or g ~= frame.HealthBar.g or b ~= frame.HealthBar.b ) then
		if not frame.HealthColorChanged then
			frame.HealthBar:SetStatusBarColor(r, g, b);
			if frame.HealthColorChangeCallbacks then
				for _, cb in ipairs(frame.HealthColorChangeCallbacks) do
					cb(self, frame, r, g, b);
				end
			end
		end
		frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = r, g, b;
	end

	if frame.MaxHealthChangeCallbacks then
		for _, cb in ipairs(frame.MaxHealthChangeCallbacks) do
			cb(self, frame, maxHealth);
		end
	end

	if frame.HealthValueChangeCallbacks then
		for _, cb in ipairs(frame.HealthValueChangeCallbacks) do
			cb(self, frame, health);
		end
	end

	frame.scale = CreateAnimationGroup(frame)
	frame.scale.width = frame.scale:CreateAnimation("Width")
	frame.scale.width:SetDuration(0.2)
	frame.scale.height = frame.scale:CreateAnimation("Height")
	frame.scale.height:SetDuration(0.2)
]]

--function NP:RegisterHealthBarCallbacks(frame, valueChangeCB, colorChangeCB, maxHealthChangeCB)
--	if (valueChangeCB) then
--		frame.HealthValueChangeCallbacks = frame.HealthValueChangeCallbacks or {};
--		tinsert(frame.HealthValueChangeCallbacks, valueChangeCB);
--	end

--	if (colorChangeCB) then
--		frame.HealthColorChangeCallbacks = frame.HealthColorChangeCallbacks or {};
--		tinsert(frame.HealthColorChangeCallbacks, colorChangeCB);
--	end

--	if (maxHealthChangeCB) then
--		frame.MaxHealthChangeCallbacks = frame.MaxHealthChangeCallbacks or {};
--		tinsert(frame.MaxHealthChangeCallbacks, maxHealthChangeCB)
--	end
--end

--function NP:UpdateElement_CutawayHealthFadeOut(frame)
--	local cutawayHealth = frame.CutawayHealth;
--	cutawayHealth.fading = true;
--	cutawayHealth.isPlaying = nil;
--end

--local function CutawayHealthClosure(frame)
--	return function() NP:UpdateElement_CutawayHealthFadeOut(frame) end;
--end

--function NP:CutawayHealthValueChangeCallback(frame, health)
--	if NP.db.cutawayHealth and not UnitIsTapDenied(frame.displayedUnit) then
--		local oldValue = frame.Health:GetValue();
--		local change = oldValue - health;
--		if (change > 0 and not frame.CutawayHealth.isPlaying) then
--			local cutawayHealth = frame.CutawayHealth;
--			if (cutawayHealth.fading) then
--				E:UIFrameFadeRemoveFrame(cutawayHealth);
--			end
--			cutawayHealth.fading = false;
--			cutawayHealth:SetValue(oldValue);
--			cutawayHealth:SetAlpha(1);
--			if (not cutawayHealth.closure) then
--				cutawayHealth.closure = CutawayHealthClosure(frame);
--			end
--			C_Timer_After(NP.db.cutawayHealthLength, cutawayHealth.closure);
--			cutawayHealth.isPlaying = true;
--			cutawayHealth:Show();
--		end
--	else
--		if frame.CutawayHealth.isPlaying then
--			frame.CutawayHealth.isPlaying = nil;
--			frame.CutawayHealth:SetScript('OnUpdate', nil);
--		end
--		frame.CutawayHealth:Hide();
--	end
--end

--function NP:CutawayHealthColorChangeCallback(frame, r, g, b)
--	frame.CutawayHealth:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, 1);
--end

--function NP:CutawayHealthMaxHealthChangeCallback(frame, maxHealth)
--	frame.CutawayHealth:SetMinMaxValues(0, maxHealth);
--end

--function NP:ConfigureElement_CutawayHealth(frame)
--	local cutawayHealth = frame.CutawayHealth
--	local healthBar = frame.Health

--	cutawayHealth:SetAllPoints(healthBar)
--	cutawayHealth:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
--end

--function NP:ConstructElement_CutawayHealth(parent)
--	local healthBar = parent.Health

--	local cutawayHealth = CreateFrame("StatusBar", "$parentCutawayHealth", healthBar)
--	cutawayHealth:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
--	cutawayHealth:SetFrameLevel(healthBar:GetFrameLevel() - 1)

--	local statusBarTexture = cutawayHealth:GetStatusBarTexture()
--	statusBarTexture:SetSnapToPixelGrid(false)
--	statusBarTexture:SetTexelSnappingBias(0)

--	NP:RegisterHealthBarCallbacks(parent, NP.CutawayHealthValueChangeCallback, NP.CutawayHealthColorChangeCallback, NP.CutawayHealthMaxHealthChangeCallback);

--	return cutawayHealth
--end

local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local HealthIsDone, PowerIsDone
local function CloseHealth()
	HealthIsDone = false
end

local function ClosePower()
	PowerIsDone = false
end

local function Health_PreUpdate(self, unit)
	if HealthIsDone then return end
	self.__owner.Cutaway.Health.cur = UnitHealth(unit)
	self.__owner.Cutaway.Health:SetValue(UnitHealth(unit))
	self.__owner.Cutaway.Health:SetMinMaxValues(0, UnitHealthMax(unit))
	HealthIsDone = true
end

local function Health_PostUpdate(self, unit, cur, max)
	if not HealthIsDone then return end
	if (self.__owner.Cutaway.Health.cur or 1) > (cur) then
		E:UIFrameFadeOut(self.__owner.Cutaway.Health, 2, 1, 0);
		C_Timer.After(2, CloseHealth)
	end
end

local function Power_PreUpdate(self, unit)
	if PowerIsDone then return end
	self.__owner.Cutaway.Power.cur = UnitPower(unit)
	self.__owner.Cutaway.Power:SetValue(UnitPower(unit))
	self.__owner.Cutaway.Power:SetMinMaxValues(0, UnitPowerMax(unit))
	PowerIsDone = true
end

local function Power_PostUpdate(self, unit, cur, max)
	if not PowerIsDone then return end
	if (self.__owner.Cutaway.Power.cur or 1) > (cur) then
		E:UIFrameFadeOut(self.__owner.Cutaway.Power, 2, 1, 0);
		C_Timer.After(2, ClosePower)
	end
end

local function Enable(self)
	local element = self.Cutaway
	if (element) then
		if (element.Health and element.Health:IsObjectType('StatusBar') and not element.Health:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if (element.Power and element.Power:IsObjectType('StatusBar') and not element.Power:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if element.Health then
			element.Health.__owner = self

			if self.Health and not element.Health.isHooked then

				if self.Health.PreUpdate then
					hooksecurefunc(self.Health, 'PreUpdate', Health_PreUpdate)
				else
					self.Health.PreUpdate = Health_PreUpdate
				end

				if self.Health.PostUpdate then
					hooksecurefunc(self.Health, 'PostUpdate', Health_PostUpdate)
				else
					self.Health.PostUpdate = Health_PostUpdate
				end

				element.Health.isHooked = true
			end
		end

		if element.Power then
			element.Power.__owner = self

			if self.Power and not element.Power.isHooked then

				if self.Power.PreUpdate then
					hooksecurefunc(self.Power, 'PreUpdate', Power_PreUpdate)
				else
					self.Power.PreUpdate = Power_PreUpdate
				end

				if self.Power.PostUpdate then
					hooksecurefunc(self.Power, 'PostUpdate', Power_PostUpdate)
				else
					self.Power.PostUpdate = Power_PostUpdate
				end

				element.Power.isHooked = true
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.Cutaway
	if (element) then
		element:Hide()
	end
end

oUF:AddElement('Cutaway', nil, Enable, Disable)
