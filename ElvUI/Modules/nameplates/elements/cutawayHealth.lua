local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

local UnitIsTapDenied = UnitIsTapDenied
local C_Timer_After = C_Timer.After

function mod:UpdateElement_CutawayHealthFadeOut(frame)
	local cutawayHealth = frame.CutawayHealth;
	cutawayHealth.fading = true;
	E:UIFrameFadeOut(cutawayHealth, self.db.cutawayHealthFadeOutTime, cutawayHealth:GetAlpha(), 0);
	cutawayHealth.isPlaying = nil;
end

local function CutawayHealthClosure(frame)
	return function() mod:UpdateElement_CutawayHealthFadeOut(frame) end;
end

function mod:CutawayHealthValueChangeCallback(frame, health)
	if self.db.cutawayHealth and not UnitIsTapDenied(frame.displayedUnit) then
		local oldValue = frame.HealthBar:GetValue();
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
			C_Timer_After(self.db.cutawayHealthLength, cutawayHealth.closure);
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

function mod:CutawayHealthColorChangeCallback(frame, r, g, b)
	frame.CutawayHealth:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, 1);
end

function mod:CutawayHealthMaxHealthChangeCallback(frame, maxHealth)
	frame.CutawayHealth:SetMinMaxValues(0, maxHealth);
end

function mod:ConfigureElement_CutawayHealth(frame)
	local cutawayHealth = frame.CutawayHealth
	local healthBar = frame.HealthBar

	cutawayHealth:SetAllPoints(healthBar)
	cutawayHealth:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function mod:ConstructElement_CutawayHealth(parent)
	local healthBar = parent.HealthBar

	local cutawayHealth = CreateFrame("StatusBar", "$parentCutawayHealth", healthBar)
	cutawayHealth:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
	cutawayHealth:SetFrameLevel(healthBar:GetFrameLevel() - 1);

	mod:RegisterHealthBarCallbacks(parent, mod.CutawayHealthValueChangeCallback, mod.CutawayHealthColorChangeCallback, mod.CutawayHealthMaxHealthChangeCallback);

	return cutawayHealth
end