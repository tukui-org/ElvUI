if TukuiDB["watchframe"].movable == true then
	local wf = WatchFrame
	local wfmove = false 

	wf:SetMovable(true)
	wf:SetClampedToScreen(false) 
	wf:ClearAllPoints()
	wf:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB:Scale(17), TukuiDB:Scale(-80))
	wf:SetWidth(TukuiDB:Scale(250))
	wf:SetHeight(TukuiDB:Scale(600))
	wf:SetUserPlaced(true)
	wf.SetPoint = function() end
	wf.ClearAllPoints = function() end

	local function WATCHFRAMELOCK()
		if wfmove == false then
			wfmove = true
			print(tukuilocal.core_wf_unlock)
			wf:EnableMouse(true);
			wf:RegisterForDrag("LeftButton"); 
			wf:SetScript("OnDragStart", wf.StartMoving); 
			wf:SetScript("OnDragStop", wf.StopMovingOrSizing);
		elseif wfmove == true then
			wf:EnableMouse(false);
			wfmove = false
			print(tukuilocal.core_wf_lock)
		end
	end

	SLASH_WATCHFRAMELOCK1 = "/wf"
	SlashCmdList["WATCHFRAMELOCK"] = WATCHFRAMELOCK
end