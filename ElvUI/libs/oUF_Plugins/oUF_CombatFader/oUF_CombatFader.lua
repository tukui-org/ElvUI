--By Elv, for E.
local parent, ns = ...
local oUF = ns.oUF
local frames, allFrames = {}, {}
local showStatus

local CheckForReset = function()
	for frame, unit in pairs(allFrames) do
		if frame.fadeInfo and frame.fadeInfo.reset then
			frame:SetAlpha(1)
			frame.fadeInfo.reset = nil
		end
	end
end

local FadeFramesInOut = function(fade, unit)
	local E = unpack(ElvUI)
	for frame, unit in pairs(frames) do
		if not UnitExists(unit) then return end
		if fade then
			if frame:GetAlpha() ~= 1 or (frame.fadeInfo and frame.fadeInfo.endAlpha == 0) then
				E:UIFrameFadeIn(frame, 0.15)
			end
		else	
			if frame:GetAlpha() ~= 0 then
				E:UIFrameFadeOut(frame, 0.15)
				frame.fadeInfo.finishedFunc = CheckForReset
			else
				showStatus = false;
				return
			end
		end
	end
	
	if unit == 'player' then
		showStatus = fade
	end
end

local Update = function(self, arg1, arg2)
	if arg1 == "UNIT_HEALTH" and self and self.unit ~= arg2 then return end
	if type(arg1) == 'boolean' and not frames[self] then
		return
	end
	
	local E = unpack(ElvUI)
	
	if not frames[self] then
		E:UIFrameFadeIn(self, 0.15)
		self.fadeInfo.reset = true
		return
	end		
		
	local combat = InCombatLockdown()
	local cur, max = UnitHealth("player"), UnitHealthMax("player")
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player")
	local target, focus = UnitExists("target"), UnitExists("focus")

	if (cast or channel) and showStatus ~= true then
		FadeFramesInOut(true, frames[self])
	elseif cur ~= max and showStatus ~= true then
		FadeFramesInOut(true, frames[self])
	elseif (target or focus) and showStatus ~= true then
		FadeFramesInOut(true, frames[self])
	elseif arg1 == true and showStatus ~= true then
		FadeFramesInOut(true, frames[self])
	else
		if combat and showStatus ~= true then
			FadeFramesInOut(true, frames[self])
		elseif not target and not combat and not focus and (cur == max) and not (cast or channel) then
			FadeFramesInOut(false, frames[self])
		end
	end	
end

local Enable = function(self, unit)
	if self.CombatFade then
		frames[self] = self.unit
		allFrames[self] = self.unit
		
		if unit == 'player' then
			showStatus = false;
		end
		
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Update)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", Update)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update)
		self:RegisterEvent("PLAYER_FOCUS_CHANGED", Update)
		self:RegisterEvent("UNIT_HEALTH", Update)
		self:RegisterEvent("UNIT_SPELLCAST_START", Update)
		self:RegisterEvent("UNIT_SPELLCAST_STOP", Update)
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", Update)
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Update)
		self:RegisterEvent("UNIT_PORTRAIT_UPDATE", Update)
		self:RegisterEvent("UNIT_MODEL_CHANGED", Update)
		
		if not self.CombatFadeHooked then
			self:HookScript("OnEnter", function(self) Update(self, true) end)
			self:HookScript("OnLeave", function(self) Update(self, false) end)	
			self.CombatFadeHooked = true
		end		
		return true
	end
end

local Disable = function(self)
	if(self.CombatFade) then
		frames[self] = nil
		Update(self)

		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Update)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", Update)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update)
		self:UnregisterEvent("PLAYER_FOCUS_CHANGED", Update)
		self:UnregisterEvent("UNIT_HEALTH", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_START", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_STOP", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Update)
		self:UnregisterEvent("UNIT_PORTRAIT_UPDATE", Update)
		self:UnregisterEvent("UNIT_MODEL_CHANGED", Update)
	end
end

oUF:AddElement('CombatFade', Update, Enable, Disable)