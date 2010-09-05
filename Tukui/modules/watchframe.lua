if TukuiCF["watchframe"].movable ~= true then return end

local TukuiWatchFrame = CreateFrame("Frame", nil, UIParent)

TukuiWatchFrame:RegisterEvent("ADDON_LOADED")
TukuiWatchFrame:SetScript("OnEvent", function(self, event, addon)
	if (addon == "Tukui") and (not IsAddOnLoaded("Who Framed Watcher Wabbit") or not IsAddOnLoaded("Fux")) then	
		self:UnregisterEvent("ADDON_LOADED")
		
		local wfbutton = CreateFrame("Button", "WatchFrameButton", WatchFrame)
		TukuiDB.CreatePanel(wfbutton, 40, 10, "BOTTOM", WatchFrame, "TOP", 0, -8)
		wfbutton:Hide()

		local wf = WatchFrame
		local wfmove = false 

		wf:SetMovable(true)
		wf:SetClampedToScreen(false)
		wf:ClearAllPoints()
		wf:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", TukuiDB.Scale(-8), TukuiDB.Scale(-230))
		wf:SetHeight(600)
		wf:SetUserPlaced(true)
		wf.SetPoint = TukuiDB.dummy
		wf.ClearAllPoints = TukuiDB.dummy

		local function WATCHFRAMELOCK()
			if wfmove == false then
				wfmove = true
				print(tukuilocal.core_wf_unlock)
				wf:EnableMouse(true);
				wf:RegisterForDrag("LeftButton");
				wf:SetScript("OnDragStart", wf.StartMoving);
				wf:SetScript("OnDragStop", wf.StopMovingOrSizing);
				wfbutton:Show()
			elseif wfmove == true then
				wf:EnableMouse(false);
				wfmove = false
				wfbutton:Hide()
				print(tukuilocal.core_wf_lock)
			end
		end

		SLASH_WATCHFRAMELOCK1 = "/wf"
		SlashCmdList["WATCHFRAMELOCK"] = WATCHFRAMELOCK
	end
end)
