local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local ElvuiWatchFrame = CreateFrame("Frame", "ElvuiWatchFrame", E.UIParent)
local wideFrame = GetCVar("watchFrameWidth")

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
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

function E.PostWatchMove()
	if E.Movers and not E.Movers["WatchFrameMover"] or not E.Movers then
		E.PositionWatchFrame()
	end
end

function E.PositionWatchFrame()
	if fired == true and E.Movers and E.Movers["WatchFrameMover"] then return end
	
	if WatchFrameMover then
		if E.Movers and E.Movers["WatchFrameMover"] then return end
		
		WatchFrameMover:ClearAllPoints()
		if E.actionbar then	
			if E.actionbar.rightbars == 3 then
				if C["actionbar"].bottompetbar ~= true then
					WatchFrameMover:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-210), E.Scale(-300))
				else
					WatchFrameMover:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-165), E.Scale(-300))
				end
			elseif E.actionbar.rightbars == 2 then
				if C["actionbar"].bottompetbar ~= true then
					WatchFrameMover:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-190), E.Scale(-300))
				else
					WatchFrameMover:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-140), E.Scale(-300))
				end
			elseif E.actionbar.rightbars == 1 then
				if C["actionbar"].bottompetbar ~= true then
					WatchFrameMover:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-160), E.Scale(-300))
				else
					WatchFrameMover:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-110), E.Scale(-300))
				end
			else
				if C["actionbar"].bottompetbar ~= true then
					WatchFrameMover:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-120), E.Scale(-300))
				else
					WatchFrameMover:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-70), E.Scale(-300))
				end
			end
		end
	else
		
		WatchFrameHolder:ClearAllPoints()
		if E.actionbar then
			if C["actionbar"].enable and E.actionbar.rightbars == 3 then
				if C["actionbar"].bottompetbar ~= true then
					WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-210), E.Scale(-300))
				else
					WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-165), E.Scale(-300))
				end
			elseif C["actionbar"].enable and E.actionbar.rightbars == 2 then
				if C["actionbar"].bottompetbar ~= true then
					WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-190), E.Scale(-300))
				else
					WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-140), E.Scale(-300))
				end
			elseif C["actionbar"].enable and E.actionbar.rightbars == 1 then
				if C["actionbar"].bottompetbar ~= true then
					WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-160), E.Scale(-300))
				else
					WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-110), E.Scale(-300))
				end
			else
				if C["actionbar"].bottompetbar ~= true then
					WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-120), E.Scale(-300))
				else
					WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-70), E.Scale(-300))
				end
			end
		else
			WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.Scale(-120), E.Scale(-300))			
		end
		
		E.CreateMover(WatchFrameHolder, "WatchFrameMover", "Watch Frame", true, E.PostWatchMove)
	end
end

local function setup()
	E.PositionWatchFrame()
	
	local screenheight = GetScreenHeight()
	ElvuiWatchFrame:SetSize(1,screenheight / 2)
	
	-- template was just to help positioning watch frame.
	--ElvuiWatchFrame:SetTemplate("Default")
	
	ElvuiWatchFrame:SetWidth(250)
	
	WatchFrame:SetParent(ElvuiWatchFrame)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:ClearAllPoints()
	WatchFrame.ClearAllPoints = function() end
	WatchFrame:SetPoint("TOPLEFT", 32,-2.5)
	WatchFrame:SetPoint("BOTTOMRIGHT", 4,0)
	WatchFrame.SetPoint = E.dummy

	WatchFrameTitle:SetParent(ElvuiWatchFrame)
	WatchFrameCollapseExpandButton:SetParent(ElvuiWatchFrame)
	WatchFrameTitle:Hide()
	WatchFrameTitle.Show = E.dummy
	WatchFrameCollapseExpandButton.Disable = E.dummy
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
