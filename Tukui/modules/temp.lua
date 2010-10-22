-- temporary stuff

--Temp fix for tooltips crashing people inside instances
local TooltipHider = CreateFrame("Frame")
TooltipHider:RegisterEvent("PLAYER_ENTERING_WORLD")
TooltipHider:SetScript("OnEvent", function()
	if not TukuiCF["tooltip"].enable then return end
	local inInstance, instanceType = IsInInstance()
	if inInstance and (instanceType == "party" or instanceType == "pvp") then
		print("|cffC495DDElvUI|r: One-Lined tooltips temporarily disabled while inside instance to prevent client crashes")
		GameTooltip:SetScript("OnShow", function()
			if GameTooltip:NumLines() == 1 then
				GameTooltip:Hide()
			end
		end)
		GameTooltip:HookScript("OnShow", TukuiDB.SetStyle)
	else
		GameTooltip:SetScript("OnShow", GameTooltip.Show)
		GameTooltip:HookScript("OnShow", TukuiDB.SetStyle)
	end
end)