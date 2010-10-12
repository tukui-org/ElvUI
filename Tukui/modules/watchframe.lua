local TukuiWatchFrame = CreateFrame("Frame", "TukuiWatchFrame", UIParent)

local function init()
	TukuiWatchFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	TukuiWatchFrame:RegisterEvent("CVAR_UPDATE")
	TukuiWatchFrame:SetScript("OnEvent", function(_,_,cvar,value)
		if cvar == "WATCH_FRAME_WIDTH_TEXT" then
			if not WatchFrame.userCollapsed then
				if value == "1" then
					TukuiWatchFrame:SetWidth(350)
				else
					TukuiWatchFrame:SetWidth(250)
				end
			end
			wideFrame = value
		end
	end)
end

local function setup()
	TukuiWatchFrame:ClearAllPoints()
	if TukuiCF.actionbar.rightbars == 3 then
		TukuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB.Scale(-180), TukuiDB.Scale(-68))
	elseif TukuiCF.actionbar.rightbars == 2 then
		TukuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB.Scale(-140), TukuiDB.Scale(-68))
	elseif TukuiCF.actionbar.rightbars == 1 then
		TukuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB.Scale(-100), TukuiDB.Scale(-68))
	else
		TukuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB.Scale(12), TukuiDB.Scale(-68))
	end
	
	local screenheight = GetScreenHeight()
	TukuiWatchFrame:SetSize(1,screenheight / 1.6)
	
	-- template was just to help positioning watch frame.
	-- TukuiDB.SetTemplate(TukuiWatchFrame)
	
	if wideFrame == "1" then
		TukuiWatchFrame:SetWidth(350)
	else
		TukuiWatchFrame:SetWidth(250)
	end
	
	WatchFrame:SetParent(TukuiWatchFrame)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:ClearAllPoints()
	WatchFrame.ClearAllPoints = function() end
	WatchFrame:SetPoint("TOPLEFT", 32,-2.5)
	WatchFrame:SetPoint("BOTTOMRIGHT", 4,0)
	WatchFrame.SetPoint = TukuiDB.dummy

	WatchFrameTitle:SetParent(TukuiWatchFrame)
	WatchFrameCollapseExpandButton:SetParent(TukuiWatchFrame)
	WatchFrameTitle:Hide()
	WatchFrameTitle.Show = TukuiDB.dummy
	WatchFrameCollapseExpandButton:Hide()
	WatchFrameCollapseExpandButton.Show = TukuiDB.dummy
end

TukuiWatchFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local f = CreateFrame("Frame")
f:Hide()
f.elapsed = 0
f:SetScript("OnUpdate", function(self, elapsed)
	f.elapsed = f.elapsed + elapsed
	if f.elapsed > .5 then
		setup()
		f:Hide()
	end
end)
TukuiWatchFrame:SetScript("OnEvent", function() if not IsAddOnLoaded("Who Framed Watcher Wabbit") or not IsAddOnLoaded("Fux") then init() f:Show() end end)
