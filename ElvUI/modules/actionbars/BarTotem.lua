-- we just use default totem bar for shaman
-- we parent it to our shapeshift bar.
-- This is approx the same script as it was in WOTLK Elvui version.
local ElvDB = ElvDB
local ElvCF = ElvCF

if ElvCF["actionbar"].enable ~= true then return end
if ElvDB.myclass ~= "SHAMAN" then return end

if MultiCastActionBarFrame then
	MultiCastActionBarFrame:SetScript("OnUpdate", nil)
	MultiCastActionBarFrame:SetScript("OnShow", nil)
	MultiCastActionBarFrame:SetScript("OnHide", nil)
	MultiCastActionBarFrame:SetParent(ElvuiShiftBar)
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", ElvuiShiftBar, 0, ElvDB.Scale(23))

	hooksecurefunc("MultiCastActionButton_Update",function(actionbutton) if not InCombatLockdown() then actionbutton:SetAllPoints(actionbutton.slotButton) end end)

	MultiCastActionBarFrame.SetParent = ElvDB.dummy
	MultiCastActionBarFrame.SetPoint = ElvDB.dummy
	MultiCastRecallSpellButton.SetPoint = ElvDB.dummy -- bug fix, see http://www.Elvui.org/v2/forums/topic.php?id=2405
	
	if ElvCF["actionbar"].shapeshiftmouseover == true then
		MultiCastActionBarFrame:SetAlpha(0)
		MultiCastActionBarFrame:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		MultiCastActionBarFrame:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	end
end
