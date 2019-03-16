local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Fader was unable to locate oUF install')

local frameFadeManager = CreateFrame("FRAME");
local FADEFRAMES = {};

local tDeleteItem, GetMouseFocus = tDeleteItem, GetMouseFocus
local UnitPowerType, UnitPower, UnitPowerMax, UnitCastingInfo, UnitChannelInfo, UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax = UnitPowerType, UnitPower, UnitPowerMax, UnitCastingInfo, UnitChannelInfo, UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax

local function UIFrameFadeRemoveFrame(frame)
	tDeleteItem(FADEFRAMES, frame);
end

local function UIFrameFade_OnUpdate(self, elapsed)
	local index = 1;
	local frame, fadeInfo;
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index];
		fadeInfo = FADEFRAMES[index].fadeInfo;
		fadeInfo.fadeTimer = (fadeInfo.fadeTimer or 0) + elapsed;
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed;
		if ( fadeInfo.fadeTimer < fadeInfo.timeToFade ) then
			if ( fadeInfo.mode == "IN" ) then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha);
			elseif ( fadeInfo.mode == "OUT" ) then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha);
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha);
			if ( fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0  ) then
				fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed;
			else
				UIFrameFadeRemoveFrame(frame);
				if ( fadeInfo.finishedFunc ) then
					fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4);
					fadeInfo.finishedFunc = nil;
				end
			end
		end
		index = index + 1;
	end
	if ( #FADEFRAMES == 0 ) then
		frameFadeManager:SetScript("OnUpdate", nil);
	end
end

-- Generic fade function
local function UIFrameFade(frame, fadeInfo)
	if (not frame) then
		return;
	end
	if ( not fadeInfo.mode ) then
		fadeInfo.mode = "IN";
	end
	if ( fadeInfo.mode == "IN" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 1.0;
		end
	elseif ( fadeInfo.mode == "OUT" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 1.0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 0;
		end
	end
	frame:SetAlpha(fadeInfo.startAlpha);

	frame.fadeInfo = fadeInfo;

	local index = 1;
	while FADEFRAMES[index] do
		-- If frame is already set to fade then return
		if ( FADEFRAMES[index] == frame ) then
			return;
		end
		index = index + 1;
	end
	FADEFRAMES[#FADEFRAMES + 1] = frame
	frameFadeManager:SetScript("OnUpdate", UIFrameFade_OnUpdate);
end

-- Convenience function to do a simple fade in
local function UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	UIFrameFade(frame, fadeInfo);
end

-- Convenience function to do a simple fade out
local function UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {};
	fadeInfo.mode = "OUT";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	UIFrameFade(frame, fadeInfo);
end

local function Update(self)
	local unit = self.unit

	local _, powerType = UnitPowerType(unit)
	local power = UnitPower(unit)

	if
		(self.FadeCasting and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) or
		(self.FadeCombat and UnitAffectingCombat(unit)) or
		(self.FadeTarget and (unit:find('target') and UnitExists(unit))) or
		(self.FadeTarget and UnitExists(unit .. 'target')) or
		(self.FadeHealth and UnitHealth(unit) < UnitHealthMax(unit)) or
		(self.FadePower and ((powerType == 'RAGE' or powerType == 'RUNIC_POWER') and power > 0)) or
		(self.FadePower and ((powerType ~= 'RAGE' and powerType ~= 'RUNIC_POWER') and power < UnitPowerMax(unit))) or
		(self.FadeHover and GetMouseFocus() == self)
	then
		if (self.FadeSmooth) then
			UIFrameFadeIn(self, self.FadeSmooth, self:GetAlpha(), self.FadeMaxAlpha or 1)
		else
			self:SetAlpha(self.FadeMaxAlpha or 1)
		end
	else
		if(self.FadeSmooth) then
			UIFrameFadeOut(self, self.FadeSmooth, self:GetAlpha(), self.FadeMinAlpha or 0.3)
		else
			self:SetAlpha(self.FadeMinAlpha or 0.3)
		end
	end
end

local function Enable(self, unit)
	if self.Fader then
		if(self.FadeHover) then
			self:HookScript('OnEnter', Update)
			self:HookScript('OnLeave', Update)
		end

		if(self.FadeCombat) then
			self:RegisterEvent('PLAYER_REGEN_ENABLED', Update, true)
			self:RegisterEvent('PLAYER_REGEN_DISABLED', Update, true)
		end

		if(self.FadeTarget) then
			self:HookScript('OnShow', Update)
			self:RegisterEvent('UNIT_TARGET', Update)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', Update, true)
		end

		if(self.FadeHealth) then
			self:RegisterEvent('UNIT_HEALTH', Update)
			self:RegisterEvent('UNIT_MAXHEALTH', Update)
		end

		if(self.FadePower) then
			self:RegisterEvent('UNIT_POWER_UPDATE', Update)
			self:RegisterEvent('UNIT_MAXPOWER', Update)
		end

		if(self.FadeCasting) then
			self:RegisterEvent('UNIT_SPELLCAST_START', Update)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', Update)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', Update)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)
		end

		Update(self)

		return true
	end
end

local function Disable(self, unit)
	self:UnregisterEvent('PLAYER_REGEN_ENABLED', Update)
	self:UnregisterEvent('PLAYER_REGEN_DISABLED', Update)
	self:UnregisterEvent('UNIT_TARGET', Update)
	self:UnregisterEvent('PLAYER_TARGET_CHANGED', Update)
	self:UnregisterEvent('UNIT_HEALTH', Update)
	self:UnregisterEvent('UNIT_MAXHEALTH', Update)
	self:UnregisterEvent('UNIT_POWER_UPDATE', Update)
	self:UnregisterEvent('UNIT_MAXPOWER', Update)
	self:UnregisterEvent('UNIT_SPELLCAST_START', Update)
	self:UnregisterEvent('UNIT_SPELLCAST_FAILED', Update)
	self:UnregisterEvent('UNIT_SPELLCAST_STOP', Update)
	self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
	self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
	self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)
end

oUF:AddElement('Fader', nil, Enable, Disable)
