local E, C, L = unpack(select(2, ...)) -- Import: E - functions, constants, variables; C - config; L - locales

-------------------------------------------------------------
-- DAMAGE / HEAL DISPLAY REPLACEMENT FOR EYEFINITY
-- BECAUSE REGULAR 3D WORLD DAMAGE ISN'T COMPATIBLE
-------------------------------------------------------------

if not E.eyefinity then return end

local gflags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_GUARDIAN)
	
local function OnEvent(self, event, ...)
	local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = select(1,...)

	if sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet") or sourceFlags == gflags then
		-- dmg
		if eventType == "SWING_DAMAGE" then
			local amount, _, _, _, _, _, critical = select(9, ...)
			self:AddMessage(amount, 1, 1, 1)
		elseif eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
			local spellId, _, spellSchool, amount, _, _, _, _, _, critical = select(9, ...)
			if eventType == "SPELL_PERIODIC_DAMAGE" then
				self:AddMessage(amount, 151/255, 70/255, 194/255)
			else
				self:AddMessage(amount, 1, 1, 0)
			end
		elseif eventType == "RANGE_DAMAGE" then
			local spellId, _, _, amount, _, _, _, _, _, critical = select(9, ...)
			self:AddMessage(amount, 1, 1, 1)
		elseif eventType == "SWING_MISSED" then
			local missType, _ = select(9, ...)
			self:AddMessage(missType, 1, 1, 1)
		elseif eventType == "SPELL_MISSED" or eventType == "RANGE_MISSED" then
			local spellId, _, _, missType, _ = select(9,...)
			self:AddMessage(missType, 1, 1, 1)
		end
		
		-- heal
		if eventType == "SPELL_HEAL" or eventType== "SPELL_PERIODIC_HEAL" then
			local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(9,...)
			self:AddMessage(amount, 0, 1, 0)			
		end
	end
end

local f = CreateFrame("ScrollingMessageFrame", "TukuiEyefinityDamage", UIParent)
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent",OnEvent)
f:SetSize(200, 200)
f:SetPoint("TOP", 0, -50)
f:SetFont(C.media.dmgfont,36,"OUTLINE")
f:SetShadowColor(0,0,0,0)
f:SetFading(true)
f:SetFadeDuration(0.5)
f:SetTimeVisible(1)
f:SetMaxLines(64)
f:SetSpacing(2)