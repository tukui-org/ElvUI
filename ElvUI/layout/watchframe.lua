local ElvuiWatchFrame = CreateFrame("Frame", "ElvuiWatchFrame", UIParent)
local ElvCF = ElvCF
local ElvDB = ElvDB
local wideFrame = GetCVar("watchFrameWidth")

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", UIParent)
WatchFrameHolder:SetWidth(130)
WatchFrameHolder:SetHeight(22)


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
	
	ElvuiWatchFrame:ClearAllPoints()
	ElvuiWatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP", 0, 0)
end

function ElvDB.PostWatchMove()
	if ElvDB.Movers["WatchFrameMover"]["moved"] == false then
		PositionWatchFrame()
	end
end

function PositionWatchFrame()
	if fired == true and ElvDB.Movers["WatchFrameMover"]["moved"] == true then return end
	
	if WatchFrameMover then
		if ElvDB.Movers["WatchFrameMover"]["moved"] == true then return end

		WatchFrameMover:ClearAllPoints()
		if ElvCF.actionbar.rightbars == 3 then
			if ElvCF["actionbar"].bottompetbar ~= true then
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-210), ElvDB.Scale(-300))
			else
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-165), ElvDB.Scale(-300))
			end
		elseif ElvCF.actionbar.rightbars == 2 then
			if ElvCF["actionbar"].bottompetbar ~= true then
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-190), ElvDB.Scale(-300))
			else
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-140), ElvDB.Scale(-300))
			end
		elseif ElvCF.actionbar.rightbars == 1 then
			if ElvCF["actionbar"].bottompetbar ~= true then
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-160), ElvDB.Scale(-300))
			else
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-110), ElvDB.Scale(-300))
			end
		else
			if ElvCF["actionbar"].bottompetbar ~= true then
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-120), ElvDB.Scale(-300))
			else
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-70), ElvDB.Scale(-300))
			end
		end		
	else
		WatchFrameHolder:ClearAllPoints()
		if ElvCF.actionbar.rightbars == 3 then
			if ElvCF["actionbar"].bottompetbar ~= true then
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-210), ElvDB.Scale(-300))
			else
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-165), ElvDB.Scale(-300))
			end
		elseif ElvCF.actionbar.rightbars == 2 then
			if ElvCF["actionbar"].bottompetbar ~= true then
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-190), ElvDB.Scale(-300))
			else
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-140), ElvDB.Scale(-300))
			end
		elseif ElvCF.actionbar.rightbars == 1 then
			if ElvCF["actionbar"].bottompetbar ~= true then
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-160), ElvDB.Scale(-300))
			else
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-110), ElvDB.Scale(-300))
			end
		else
			if ElvCF["actionbar"].bottompetbar ~= true then
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-120), ElvDB.Scale(-300))
			else
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-70), ElvDB.Scale(-300))
			end
		end
		
		ElvDB.CreateMover(WatchFrameHolder, "WatchFrameMover", "Watch Frame", true, ElvDB.PostWatchMove)
	end
end

local function setup()
	PositionWatchFrame()
	
	local screenheight = GetScreenHeight()
	ElvuiWatchFrame:SetSize(1,screenheight / 2)
	
	-- template was just to help positioning watch frame.
	--ElvDB.SetTemplate(ElvuiWatchFrame)
	
	ElvuiWatchFrame:SetWidth(250)
	
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
