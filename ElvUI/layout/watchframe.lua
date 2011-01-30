local ElvuiWatchFrame = CreateFrame("Frame", "ElvuiWatchFrame", UIParent)

local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local wideFrame = GetCVar("watchFrameWidth")

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", UIParent)
WatchFrameHolder:SetWidth(130)
WatchFrameHolder:SetHeight(22)


local function init()
	ElvuiWatchFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	ElvuiWatchFrame:RegisterEvent("CVAR_UPDATE")
	ElvuiWatchFrame:SetScript("OnEvent", function(_,_,cvar,value)
		SetCVar("watchFrameWidth", 0)
		ElvuiWatchFrame:SetWidth(250)
		InterfaceOptionsObjectivesPanelWatchFrameWidth:Hide()
	end)
	
	ElvuiWatchFrame:ClearAllPoints()
	ElvuiWatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP", 0, 0)
end

function DB.PostWatchMove()
	if DB.Movers["WatchFrameMover"]["moved"] == false then
		PositionWatchFrame()
	end
end

function PositionWatchFrame()
	if fired == true and DB.Movers["WatchFrameMover"]["moved"] == true then return end
	
	if WatchFrameMover then
		if DB.Movers["WatchFrameMover"]["moved"] == true then return end

		WatchFrameMover:ClearAllPoints()
		if C.actionbar.rightbars == 3 then
			if C["actionbar"].bottompetbar ~= true then
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-210), DB.Scale(-300))
			else
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-165), DB.Scale(-300))
			end
		elseif C.actionbar.rightbars == 2 then
			if C["actionbar"].bottompetbar ~= true then
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-190), DB.Scale(-300))
			else
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-140), DB.Scale(-300))
			end
		elseif C.actionbar.rightbars == 1 then
			if C["actionbar"].bottompetbar ~= true then
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-160), DB.Scale(-300))
			else
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-110), DB.Scale(-300))
			end
		else
			if C["actionbar"].bottompetbar ~= true then
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-120), DB.Scale(-300))
			else
				WatchFrameMover:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-70), DB.Scale(-300))
			end
		end		
	else
		WatchFrameHolder:ClearAllPoints()
		if C.actionbar.rightbars == 3 then
			if C["actionbar"].bottompetbar ~= true then
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-210), DB.Scale(-300))
			else
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-165), DB.Scale(-300))
			end
		elseif C.actionbar.rightbars == 2 then
			if C["actionbar"].bottompetbar ~= true then
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-190), DB.Scale(-300))
			else
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-140), DB.Scale(-300))
			end
		elseif C.actionbar.rightbars == 1 then
			if C["actionbar"].bottompetbar ~= true then
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-160), DB.Scale(-300))
			else
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-110), DB.Scale(-300))
			end
		else
			if C["actionbar"].bottompetbar ~= true then
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-120), DB.Scale(-300))
			else
				WatchFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", DB.Scale(-70), DB.Scale(-300))
			end
		end
		
		DB.CreateMover(WatchFrameHolder, "WatchFrameMover", "Watch Frame", true, DB.PostWatchMove)
	end
end

local function setup()
	PositionWatchFrame()
	
	local screenheight = GetScreenHeight()
	ElvuiWatchFrame:SetSize(1,screenheight / 2)
	
	-- template was just to help positioning watch frame.
	--DB.SetTemplate(ElvuiWatchFrame)
	
	ElvuiWatchFrame:SetWidth(250)
	
	WatchFrame:SetParent(ElvuiWatchFrame)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:ClearAllPoints()
	WatchFrame.ClearAllPoints = function() end
	WatchFrame:SetPoint("TOPLEFT", 32,-2.5)
	WatchFrame:SetPoint("BOTTOMRIGHT", 4,0)
	WatchFrame.SetPoint = DB.dummy

	WatchFrameTitle:SetParent(ElvuiWatchFrame)
	WatchFrameCollapseExpandButton:SetParent(ElvuiWatchFrame)
	WatchFrameTitle:Hide()
	WatchFrameTitle.Show = DB.dummy
	WatchFrameCollapseExpandButton.Disable = DB.dummy
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
