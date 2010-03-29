-- these 4 local var value are taken from buttonstyler.lua
local buttonsize = TukuiDB:Scale(27)
local buttonspacing = TukuiDB:Scale(4)
local petbuttonsize = TukuiDB:Scale(29)
local petbuttonspacing = TukuiDB:Scale(4)

-- ACTION BAR PANEL
local barbg = CreateFrame("Frame", "ActionBarBackground", UIParent)
TukuiDB:CreatePanel(barbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, TukuiDB:Scale(14))
if TukuiDB.lowversion == true then
	barbg:SetWidth((buttonsize * 12) + (buttonspacing * 13))
	if TukuiDB["actionbar"].bottomrows == 2 then
		barbg:SetHeight((buttonsize * 2) + (buttonspacing * 3))
	else
		barbg:SetHeight(buttonsize + (buttonspacing * 2))
	end
else
	barbg:SetWidth((buttonsize * 22) + (buttonspacing * 23))
	if TukuiDB["actionbar"].bottomrows == 2 then
		barbg:SetHeight((buttonsize * 2) + (buttonspacing * 3))
	else
		barbg:SetHeight(buttonsize + (buttonspacing * 2))
	end
end

-- LEFT VERTICAL LINE
local ileftlv = CreateFrame("Frame", "InfoLeftLineVertical", barbg)
TukuiDB:CreatePanel(ileftlv, 2, 130, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", TukuiDB:Scale(22), TukuiDB:Scale(30))

-- RIGHT VERTICAL LINE
local irightlv = CreateFrame("Frame", "InfoRightLineVertical", barbg)
TukuiDB:CreatePanel(irightlv, 2, 130, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", TukuiDB:Scale(-22), TukuiDB:Scale(30))

-- CUBE AT LEFT, WILL ACT AS A BUTTON
local cubeleft = CreateFrame("Frame", "CubeLeft", barbg)
TukuiDB:CreatePanel(cubeleft, 10, 10, "BOTTOM", ileftlv, "TOP", 0, 0)

-- CUBE AT RIGHT, WILL ACT AS A BUTTON
local cuberight = CreateFrame("Frame", "CubeRight", barbg)
TukuiDB:CreatePanel(cuberight, 10, 10, "BOTTOM", irightlv, "TOP", 0, 0)

-- HORIZONTAL LINE LEFT
local ltoabl = CreateFrame("Frame", "LineToABLeft", barbg)
TukuiDB:CreatePanel(ltoabl, 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ltoabl:ClearAllPoints()
ltoabl:SetPoint("BOTTOMLEFT", ileftlv, "BOTTOMLEFT", 0, 0)
ltoabl:SetPoint("RIGHT", barbg, "BOTTOMLEFT", TukuiDB:Scale(-1), TukuiDB:Scale(17))

-- HORIZONTAL LINE RIGHT
local ltoabr = CreateFrame("Frame", "LineToABRight", barbg)
TukuiDB:CreatePanel(ltoabr, 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ltoabr:ClearAllPoints()
ltoabr:SetPoint("LEFT", barbg, "BOTTOMRIGHT", TukuiDB:Scale(1), TukuiDB:Scale(17))
ltoabr:SetPoint("BOTTOMRIGHT", irightlv, "BOTTOMRIGHT", 0, 0)

-- INFO LEFT (FOR STATS)
local ileft = CreateFrame("Frame", "InfoLeft", barbg)
TukuiDB:CreatePanel(ileft, TukuiDB["panels"].tinfowidth, 23, "LEFT", ltoabl, "LEFT", TukuiDB:Scale(14), 0)
ileft:SetFrameLevel(2)

-- INFO RIGHT (FOR STATS)
local iright = CreateFrame("Frame", "InfoRight", barbg)
TukuiDB:CreatePanel(iright, TukuiDB["panels"].tinfowidth, 23, "RIGHT", ltoabr, "RIGHT", TukuiDB:Scale(-14), 0)
iright:SetFrameLevel(2)

-- CHAT EDIT BOX
local edit = CreateFrame("Frame", "ChatFrameEditBoxBackground", ChatFrameEditBox)
TukuiDB:CreatePanel(edit, 1, 1, "LEFT", "ChatFrameEditBox", "LEFT", 0, 0)
edit:ClearAllPoints()
edit:SetAllPoints(ileft)
edit:SetFrameStrata("HIGH")
edit:SetFrameLevel(2)
local function colorize(r,g,b)
	edit:SetBackdropBorderColor(r, g, b)
end

hooksecurefunc("ChatEdit_UpdateHeader", function()
local type = DEFAULT_CHAT_FRAME.editBox:GetAttribute("chatType")
	if ( type == "CHANNEL" ) then
	local id = GetChannelName(DEFAULT_CHAT_FRAME.editBox:GetAttribute("channelTarget"))
		if id == 0 then
			colorize(0.6,0.6,0.6)
		else
			colorize(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
		end
	else
		colorize(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
	end
end)

local minimapstatsleft = CreateFrame("Frame", "MinimapStatsLeft", MapBorder)
TukuiDB:CreatePanel(minimapstatsleft, ((MapBorder:GetWidth() + 4) / 2) - 1, 19, "TOPLEFT", MapBorder, "BOTTOMLEFT", 0, TukuiDB:Scale(-2))

local minimapstatsright = CreateFrame("Frame", "MinimapStatsRight", MapBorder)
TukuiDB:CreatePanel(minimapstatsright, ((MapBorder:GetWidth() + 4) / 2) -1, 19, "TOPRIGHT", MapBorder, "BOTTOMRIGHT", 0, TukuiDB:Scale(-2))

--RIGHT BAR BACKGROUND
if TukuiDB["actionbar"].enable == true or not (IsAddOnLoaded("Dominos") or IsAddOnLoaded("Bartender4") or IsAddOnLoaded("Macaroon")) then
	local barbgr = CreateFrame("Frame", "ActionBarBackgroundRight", MultiBarRight)
	TukuiDB:CreatePanel(barbgr, 1, (buttonsize * 12) + (buttonspacing * 13), "RIGHT", UIParent, "RIGHT", TukuiDB:Scale(-23), TukuiDB:Scale(-13.5))
	if TukuiDB["actionbar"].rightbars == 1 then
		barbgr:SetWidth(buttonsize + (buttonspacing * 2))
	elseif TukuiDB["actionbar"].rightbars == 2 then
		barbgr:SetWidth((buttonsize * 2) + (buttonspacing * 3))
	elseif TukuiDB["actionbar"].rightbars == 3 then
		barbgr:SetWidth((buttonsize * 3) + (buttonspacing * 4))
	else
		barbgr:Hide()
	end
	if TukuiDB["actionbar"].rightbars > 0 then
		local rbl = CreateFrame("Frame", "RightBarLine", barbgr)
		local crblu = CreateFrame("Frame", "CubeRightBarUP", barbgr)
		local crbld = CreateFrame("Frame", "CubeRightBarDown", barbgr)
		TukuiDB:CreatePanel(rbl, 2, (buttonsize / 2 * 27) + (buttonspacing * 6), "RIGHT", barbgr, "RIGHT", TukuiDB:Scale(1), 0)
		rbl:SetWidth(TukuiDB:Scale(2))
		TukuiDB:CreatePanel(crblu, 10, 10, "BOTTOM", rbl, "TOP", 0, 0)
		TukuiDB:CreatePanel(crbld, 10, 10, "TOP", rbl, "BOTTOM", 0, 0)
	end

	local petbg = CreateFrame("Frame", "PetActionBarBackground", PetActionButton1)
	if TukuiDB["actionbar"].rightbars > 0 then
		TukuiDB:CreatePanel(petbg, petbuttonsize + (petbuttonspacing * 2), (petbuttonsize * 10) + (petbuttonspacing * 11), "RIGHT", barbgr, "LEFT", TukuiDB:Scale(-6), 0)
	else
		TukuiDB:CreatePanel(petbg, petbuttonsize + (petbuttonspacing * 2), (petbuttonsize * 10) + (petbuttonspacing * 11), "RIGHT", UIParent, "RIGHT", TukuiDB:Scale(-6), TukuiDB:Scale(-13.5))
	end

	local ltpetbg1 = CreateFrame("Frame", "LineToPetActionBarBackground", petbg)
	TukuiDB:CreatePanel(ltpetbg1, 30, 265, "TOPLEFT", petbg, "TOPRIGHT", 0, TukuiDB:Scale(-33))
	ltpetbg1:SetFrameLevel(0)
	ltpetbg1:SetAlpha(.8)
end

--BATTLEGROUND STATS FRAME
if TukuiDB["datatext"].battleground == true then
	local bgframe = CreateFrame("Frame", "InfoLeftBattleGround", UIParent)
	TukuiDB:CreatePanel(bgframe, 1, 1, "TOPLEFT", Minimap, "BOTTOMLEFT", 0, 0)
	bgframe:SetAllPoints(ileft)
	bgframe:SetFrameStrata("MEDIUM")
	bgframe:EnableMouse(true)
	local function OnEvent(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			inInstance, instanceType = IsInInstance()
			if inInstance and (instanceType == "pvp") then
				bgframe:Show()
			else
				bgframe:Hide()
			end
		end
	end
	bgframe:SetScript("OnEnter", function(self)
	local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			name, killingBlows, honorKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone  = GetBattlefieldScore(i);
			if ( name ) then
				if ( name == UnitName("player") ) then
					GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, TukuiDB:Scale(4));
					GameTooltip:ClearLines()
					GameTooltip:AddLine(tukuilocal.datatext_ttstatsfor.."[|cffCC0033"..name.."|r]")
					GameTooltip:AddLine' '
					GameTooltip:AddDoubleLine(tukuilocal.datatext_ttkillingblows, killingBlows,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_tthonorkills, honorKills,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_ttdeaths, deaths,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_tthonorgain, honorGained,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_ttdmgdone, damageDone,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_tthealdone, healingDone,1,1,1)                  
					GameTooltip:Show()
				end
			end
		end
	end) 
	bgframe:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	bgframe:RegisterEvent("PLAYER_ENTERING_WORLD")
	bgframe:SetScript("OnEvent", OnEvent)
end
