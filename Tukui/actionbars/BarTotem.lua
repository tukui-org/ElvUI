if TukuiCF["actionbar"].enable ~= true then return end

-- we just use default totem bar for shaman
-- we parent it to our shapeshift bar.
-- This is approx the same script as it was in WOTLK Tukui version.

if TukuiDB.myclass == "SHAMAN" then
	if MultiCastActionBarFrame then
		MultiCastActionBarFrame:SetScript("OnUpdate", nil)
		MultiCastActionBarFrame:SetScript("OnShow", nil)
		MultiCastActionBarFrame:SetScript("OnHide", nil)
		MultiCastActionBarFrame:SetParent(TukuiShiftBar)
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", TukuiShiftBar, 0, TukuiDB.Scale(23))
 
		hooksecurefunc("MultiCastActionButton_Update",function(actionbutton) if not InCombatLockdown() then actionbutton:SetAllPoints(actionbutton.slotButton) end end)
 
		MultiCastActionBarFrame.SetParent = TukuiDB.dummy
		MultiCastActionBarFrame.SetPoint = TukuiDB.dummy
		MultiCastRecallSpellButton.SetPoint = TukuiDB.dummy -- bug fix, see http://www.tukui.org/v2/forums/topic.php?id=2405
	end
end