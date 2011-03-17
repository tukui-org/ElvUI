-- we just use default totem bar for shaman
-- we parent it to our shapeshift bar.
-- This is approx the same script as it was in WOTLK Elvui version.
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if C["actionbar"].enable ~= true then return end
if E.myclass ~= "SHAMAN" then return end

if MultiCastActionBarFrame then
	MultiCastActionBarFrame:SetScript("OnUpdate", nil)
	MultiCastActionBarFrame:SetScript("OnShow", nil)
	MultiCastActionBarFrame:SetScript("OnHide", nil)
	MultiCastActionBarFrame:SetParent(ElvuiShiftBar)
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", ElvuiShiftBar, "BOTTOMLEFT", -2, -2)

	hooksecurefunc("MultiCastActionButton_Update",function(actionbutton) if not InCombatLockdown() then actionbutton:SetAllPoints(actionbutton.slotButton) end end)
	
	MultiCastActionBarFrame.SetParent = E.dummy
	MultiCastActionBarFrame.SetPoint = E.dummy
	MultiCastRecallSpellButton.SetPoint = E.dummy -- bug fix, see http://www.tukui.org/v2/forums/topic.php?id=2405

	if C["actionbar"].shapeshiftmouseover == true then
		MultiCastActionBarFrame:SetAlpha(0)
		MultiCastActionBarFrame:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		MultiCastActionBarFrame:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	end
end
