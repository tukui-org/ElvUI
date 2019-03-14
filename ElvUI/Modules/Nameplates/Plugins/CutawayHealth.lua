local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local UnitIsTapDenied = UnitIsTapDenied
local CreateFrame = CreateFrame
local C_Timer_After = C_Timer.After

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

function NP:RegisterHealthBarCallbacks(frame, valueChangeCB, colorChangeCB, maxHealthChangeCB)
	if (valueChangeCB) then
		frame.HealthValueChangeCallbacks = frame.HealthValueChangeCallbacks or {};
		tinsert(frame.HealthValueChangeCallbacks, valueChangeCB);
	end

	if (colorChangeCB) then
		frame.HealthColorChangeCallbacks = frame.HealthColorChangeCallbacks or {};
		tinsert(frame.HealthColorChangeCallbacks, colorChangeCB);
	end

	if (maxHealthChangeCB) then
		frame.MaxHealthChangeCallbacks = frame.MaxHealthChangeCallbacks or {};
		tinsert(frame.MaxHealthChangeCallbacks, maxHealthChangeCB)
	end
end

function NP:UpdateElement_CutawayHealthFadeOut(frame)
	local cutawayHealth = frame.CutawayHealth;
	cutawayHealth.fading = true;
	E:UIFrameFadeOut(cutawayHealth, self.db.cutawayHealthFadeOutTime, cutawayHealth:GetAlpha(), 0);
	cutawayHealth.isPlaying = nil;
end

local function CutawayHealthClosure(frame)
	return function() NP:UpdateElement_CutawayHealthFadeOut(frame) end;
end

function NP:CutawayHealthValueChangeCallback(frame, health)
	if NP.db.cutawayHealth and not UnitIsTapDenied(frame.displayedUnit) then
		local oldValue = frame.Health:GetValue();
		local change = oldValue - health;
		if (change > 0 and not frame.CutawayHealth.isPlaying) then
			local cutawayHealth = frame.CutawayHealth;
			if (cutawayHealth.fading) then
				E:UIFrameFadeRemoveFrame(cutawayHealth);
			end
			cutawayHealth.fading = false;
			cutawayHealth:SetValue(oldValue);
			cutawayHealth:SetAlpha(1);
			if (not cutawayHealth.closure) then
				cutawayHealth.closure = CutawayHealthClosure(frame);
			end
			C_Timer_After(NP.db.cutawayHealthLength, cutawayHealth.closure);
			cutawayHealth.isPlaying = true;
			cutawayHealth:Show();
		end
	else
		if frame.CutawayHealth.isPlaying then
			frame.CutawayHealth.isPlaying = nil;
			frame.CutawayHealth:SetScript('OnUpdate', nil);
		end
		frame.CutawayHealth:Hide();
	end
end

function NP:CutawayHealthColorChangeCallback(frame, r, g, b)
	frame.CutawayHealth:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, 1);
end

function NP:CutawayHealthMaxHealthChangeCallback(frame, maxHealth)
	frame.CutawayHealth:SetMinMaxValues(0, maxHealth);
end

function NP:ConfigureElement_CutawayHealth(frame)
	local cutawayHealth = frame.CutawayHealth
	local healthBar = frame.Health

	cutawayHealth:SetAllPoints(healthBar)
	cutawayHealth:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function NP:ConstructElement_CutawayHealth(parent)
	local healthBar = parent.Health

	local cutawayHealth = CreateFrame("StatusBar", "$parentCutawayHealth", healthBar)
	cutawayHealth:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
	cutawayHealth:SetFrameLevel(healthBar:GetFrameLevel() - 1)

	local statusBarTexture = cutawayHealth:GetStatusBarTexture()
	statusBarTexture:SetSnapToPixelGrid(false)
	statusBarTexture:SetTexelSnappingBias(0)

	NP:RegisterHealthBarCallbacks(parent, NP.CutawayHealthValueChangeCallback, NP.CutawayHealthColorChangeCallback, NP.CutawayHealthMaxHealthChangeCallback);

	return cutawayHealth
end
