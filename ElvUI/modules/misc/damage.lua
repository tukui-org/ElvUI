-------------------------------------------------------------
-- DAMAGE / HEAL DISPLAY REPLACEMENT FOR EYEFINITY
-- BECAUSE REGULAR 3D WORLD DAMAGE ISN'T COMPATIBLE
-------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import: E - functions, constants, variables; C - config; L - locales

if not E.eyefinity then return end

local displaydamage = GetCVar("CombatDamage")
local displayheal = GetCVar("CombatHealing")
local displaydot = GetCVar("CombatLogPeriodicSpells")

local gflags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_GUARDIAN)

local function OnEvent(self, event, ...)
	local eventType, sourceGUID, sourceFlags
	
	if E.IsPTRVersion() then
		_, eventType, _, sourceGUID, _, sourceFlags = ...
	else
		_, eventType, _, sourceGUID, _, sourceFlags = ...
	end

	if sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet") or sourceFlags == gflags then
		-- dmg
		if displaydamage then
			if eventType == "SWING_DAMAGE" then
				local amount, critical
				if E.IsPTRVersion() then
					_, _, _, amount, _, _, _, _, critical = select(9, ...)
				else
					_, amount, _, _, _, _, critical = select(9, ...)
				end
				self:AddMessage(amount, 1, 1, 1)
			elseif eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
				local spellId, spellSchool, amount, critical
				if E.IsPTRVersion() then
					_, _, _, spellId, _, spellSchool, amount, _, _, _, _, _, critical = select(9, ...)
				else
					_, spellId, _, spellSchool, amount, _, _, _, _, _, critical = select(9, ...)
				end
				if eventType == "SPELL_PERIODIC_DAMAGE" then
					if displaydot then self:AddMessage(amount, 151/255, 70/255, 194/255) end
				else
					self:AddMessage(amount, 1, 1, 0)
				end
			elseif eventType == "RANGE_DAMAGE" then
				local spellId, amount, critical
				if E.IsPTRVersion() then
					_, _, _, spellId, _, _, amount, _, _, _, _, _, critical = select(9, ...)
				else
					_, spellId, _, _, amount, _, _, _, _, _, critical = select(9, ...)	
				end
				self:AddMessage(amount, 1, 1, 1)
			elseif eventType == "SWING_MISSED" then
				local missType
				if E.IsPTRVersion() then
					_, _, _, missType, _ = select(9, ...)
				else
					_, missType, _ = select(9, ...)
				end
				self:AddMessage(missType, 1, 1, 1)
			elseif eventType == "SPELL_MISSED" or eventType == "RANGE_MISSED" then
				local spellId, missType
				if E.IsPTRVersion() then
					_, _, _, spellId, _, _, missType, _ = select(9,...)
				else
					_, spellId, _, _, missType, _ = select(9,...)
				end
				self:AddMessage(missType, 1, 1, 1)
			end
		end
		
		-- heal
		if displayheal then
			if eventType == "SPELL_HEAL" or eventType== "SPELL_PERIODIC_HEAL" then
				local amount
				if E.IsPTRVersion() then
					_, _, _, _, _, _, amount, _, _, _ = select(9,...)
				else
					_, _, _, _, amount, _, _, _ = select(9,...)
				end
				self:AddMessage(amount, 0, 1, 0)			
			end
		end
	end
end

local f = CreateFrame("ScrollingMessageFrame", "TukuiEyefinityDamage", UIParent)
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent",OnEvent)
f:SetSize(200, 200)
f:SetPoint("TOP", 0, -50)
f:SetFont(C["media"].dmgfont,36,"OUTLINE")
f:SetShadowColor(0,0,0,0)
f:SetFading(true)
f:SetFadeDuration(0.5)
f:SetTimeVisible(1)
f:SetMaxLines(64)
f:SetSpacing(2)

local o = CreateFrame("Frame")
o:RegisterEvent("CVAR_UPDATE")
o:SetScript("OnEvent", function(self, event, cvar, value)
	if cvar == "SHOW_DAMAGE_TEXT" then
		if value == 1 then
			displaydamage = true
		else
			displaydamage = false
		end
	end

	if cvar == "LOG_PERIODIC_EFFECTS" then
		if value == 1 then
			displaydot = true
		else
			displaydot = false
		end
	end

	if cvar == "SHOW_COMBAT_HEALING" then
		if value == 1 then
			displayheal = true
		else
			displayheal = false
		end
	end
end)

-- kill
InterfaceOptionsCombatTextPanelPetDamage:Kill()