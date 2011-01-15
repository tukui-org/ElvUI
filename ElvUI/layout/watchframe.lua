local ElvuiWatchFrame = CreateFrame("Frame", "ElvuiWatchFrame", UIParent)
local ElvCF = ElvCF
local ElvDB = ElvDB
local wideFrame = GetCVar("watchFrameWidth")

local function init()
	ElvuiWatchFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	ElvuiWatchFrame:RegisterEvent("CVAR_UPDATE")
	ElvuiWatchFrame:SetScript("OnEvent", function(_,_,cvar,value)
		if cvar == "WATCH_FRAME_WIDTH_TEXT" then
			if not WatchFrame.userCollapsed then
				if value == "1" then
					ElvuiWatchFrame:SetWidth(350)
				else
					ElvuiWatchFrame:SetWidth(250)
				end
			end
			wideFrame = value
		end
	end)
end

function PositionWatchFrame()
	ElvuiWatchFrame:ClearAllPoints()
	if ElvCF.actionbar.rightbars == 3 then
		if ElvCF["actionbar"].bottompetbar ~= true then
			ElvuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", ElvDB.Scale(-180), ElvDB.Scale(-115))
		else
			ElvuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", ElvDB.Scale(-115), ElvDB.Scale(-115))
		end
	elseif ElvCF.actionbar.rightbars == 2 then
		if ElvCF["actionbar"].bottompetbar ~= true then
			ElvuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", ElvDB.Scale(-140), ElvDB.Scale(-115))
		else
			ElvuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", ElvDB.Scale(-75), ElvDB.Scale(-115))
		end
	elseif ElvCF.actionbar.rightbars == 1 then
		if ElvCF["actionbar"].bottompetbar ~= true then
			ElvuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", ElvDB.Scale(-100), ElvDB.Scale(-115))
		else
			ElvuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", ElvDB.Scale(-45), ElvDB.Scale(-115))
		end
	else
		if ElvCF["actionbar"].bottompetbar ~= true then
			ElvuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", ElvDB.Scale(-30), ElvDB.Scale(-115))
		else
			ElvuiWatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, ElvDB.Scale(-115))
		end
	end
end

local function setup()
	PositionWatchFrame()
	
	local screenheight = GetScreenHeight()
	ElvuiWatchFrame:SetSize(1,screenheight / 2)
	
	-- template was just to help positioning watch frame.
	-- ElvDB.SetTemplate(ElvuiWatchFrame)
	
	if wideFrame == "1" then
		ElvuiWatchFrame:SetWidth(350)
	else
		ElvuiWatchFrame:SetWidth(250)
	end
	
	WatchFrame:SetParent(ElvuiWatchFrame)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:ClearAllPoints()
	WatchFrame.ClearAllPoints = function() end
	WatchFrame:SetPoint("TOPLEFT", 32,-2.5)
	WatchFrame:SetPoint("BOTTOMRIGHT", 4,0)
	WatchFrame.SetPoint = ElvDB.dummy

	WatchFrameTitle:SetParent(ElvuiWatchFrame)
	WatchFrameCollapseExpandButton:SetParent(ElvuiWatchFrame)
	WatchFrameTitle:Hide()
	WatchFrameTitle.Show = ElvDB.dummy
	WatchFrameCollapseExpandButton.Disable = ElvDB.dummy
end

ElvuiWatchFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

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
ElvuiWatchFrame:SetScript("OnEvent", function() if not IsAddOnLoaded("Who Framed Watcher Wabbit") or not IsAddOnLoaded("Fux") then init() f:Show() end end)
