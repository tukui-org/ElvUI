COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"] = {r = 0.1, g = 1, b = 0.1, show = TukuiCF["combattext"].showhots}
	
if TukuiCF["combattext"].showoverheal == false then
	if UnitHealth("player") ~= UnitHealthMax("player") then
		COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"] = {r = 0.1, g = 1, b = 0.1, show = TukuiCF["combattext"].showhots}
		COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"] = {r = 0.1, g = 1, b = 0.1, show = true}
		COMBAT_TEXT_TYPE_INFO["HEAL"] = {r = 0.1, g = 1, b = 0.1, show = true}
	else
		COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"] = {r = 0.1, g = 1, b = 0.1, show = false}
		COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"] = {r = 0.1, g = 1, b = 0.1, show = false}
		COMBAT_TEXT_TYPE_INFO["HEAL"] = {r = 0.1, g = 1, b = 0.1, show = false}
	end	
	
	local CombatTextHideOverHeal = CreateFrame("Frame")
	CombatTextHideOverHeal:RegisterEvent("UNIT_HEALTH")
	CombatTextHideOverHeal:SetScript("OnEvent", function(self, event, unit)
		if unit ~= "player" then return end
		
		if UnitHealth("player") ~= UnitHealthMax("player") then
			COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"] = {r = 0.1, g = 1, b = 0.1, show = true}
			COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"] = {r = 0.1, g = 1, b = 0.1, show = true}
			COMBAT_TEXT_TYPE_INFO["HEAL"] = {r = 0.1, g = 1, b = 0.1, show = true}
		else
			COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"] = {r = 0.1, g = 1, b = 0.1, show = false}
			COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"] = {r = 0.1, g = 1, b = 0.1, show = false}
			COMBAT_TEXT_TYPE_INFO["HEAL"] = {r = 0.1, g = 1, b = 0.1, show = false}
		end
	end)
end
