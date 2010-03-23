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
		barbg:SetHeight(buttonsize+buttonsize+buttonspacing+buttonspacing+buttonspacing)
	else
		barbg:SetHeight(buttonsize+buttonspacing+buttonspacing)
	end
else
	barbg:SetWidth((buttonsize * 22) + (buttonspacing * 23))
	if TukuiDB["actionbar"].bottomrows == 2 then
		barbg:SetHeight(buttonsize+buttonsize+buttonspacing+buttonspacing+buttonspacing)
	else
		barbg:SetHeight(buttonsize+buttonspacing+buttonspacing)
	end
end

-- LEFT VERTICAL LINE
local ileftlv = CreateFrame("Frame", "InfoLeftLineVertical", barbg)
TukuiDB:CreatePanel(ileftlv, 2, 130, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 22, 30)

-- RIGHT VERTICAL LINE
local irightlv = CreateFrame("Frame", "InfoRightLineVertical", barbg)
TukuiDB:CreatePanel(irightlv, 2, 130, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -22, 30)
irightlv:SetWidth(TukuiDB:Scale(2))

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
ltoabl:SetPoint("RIGHT", barbg, "BOTTOMLEFT", TukuiDB:Scale(-1), 17)

-- HORIZONTAL LINE RIGHT
local ltoabr = CreateFrame("Frame", "LineToABRight", barbg)
TukuiDB:CreatePanel(ltoabr, 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ltoabr:ClearAllPoints()
ltoabr:SetPoint("LEFT", barbg, "BOTTOMRIGHT", TukuiDB:Scale(1), 17)
ltoabr:SetPoint("BOTTOMRIGHT", irightlv, "BOTTOMRIGHT", 0, 0)

-- INFO LEFT (FOR STATS)
local ileft = CreateFrame("Frame", "InfoLeft", barbg)
TukuiDB:CreatePanel(ileft, TukuiDB["panels"].tinfowidth, TukuiDB:Scale(23), "LEFT", ltoabl, "LEFT", 14, 0)
ileft:SetFrameLevel(2)

-- INFO RIGHT (FOR STATS)
local iright = CreateFrame("Frame", "InfoRight", barbg)
TukuiDB:CreatePanel(iright, TukuiDB["panels"].tinfowidth, TukuiDB:Scale(23), "RIGHT", ltoabr, "RIGHT", -14, 0)
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

local minimapstatsleft = CreateFrame("Frame", "MinimapStatsLeft", Minimap)
TukuiDB:CreatePanel(minimapstatsleft, 1, 1, "TOPLEFT", Minimap, "BOTTOMLEFT", TukuiDB:Scale(-2), TukuiDB:Scale(-4))
minimapstatsleft:SetWidth(TukuiDB:Scale(73))
minimapstatsleft:SetHeight(TukuiDB:Scale(19))

local minimapstatsright = CreateFrame("Frame", "MinimapStatsRight", Minimap)
TukuiDB:CreatePanel(minimapstatsright, 1, 1, "TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB:Scale(2), TukuiDB:Scale(-4))
minimapstatsright:SetWidth(TukuiDB:Scale(73))
minimapstatsright:SetHeight(TukuiDB:Scale(19))

--RIGHT BAR BACKGROUND
local barbgr = CreateFrame("Frame", "ActionBarBackgroundRight", UIParent)
TukuiDB:CreatePanel(barbgr, 1, 1, "RIGHT", UIParent, "RIGHT", -23, -13.5)
barbgr:SetHeight((buttonsize * 12) + (buttonspacing * 13))
if TukuiDB["actionbar"].rightbars == 1 then
	barbgr:SetWidth(buttonsize+buttonspacing+buttonspacing)
elseif TukuiDB["actionbar"].rightbars == 2 then
	barbgr:SetWidth(buttonspacing+buttonsize+buttonspacing+buttonsize+buttonspacing)
elseif TukuiDB["actionbar"].rightbars == 3 then
	barbgr:SetWidth(buttonspacing+buttonsize+buttonspacing+buttonsize+buttonspacing+buttonsize+buttonspacing)
else
	barbgr:Hide()
end
if TukuiDB["actionbar"].rightbars > 0 then
	local rbl = CreateFrame("Frame", "RightBarLine", barbg)
	local crblu = CreateFrame("Frame", "CubeRightBarUP", barbg)
	local crbld = CreateFrame("Frame", "CubeRightBarDown", barbg)
	TukuiDB:CreatePanel(rbl, 2, TukuiDB:Scale((buttonsize/2 * 27) + (buttonspacing * 6)), "RIGHT", barbgr, "RIGHT", 1, 0)
	rbl:SetWidth(TukuiDB:Scale(2))
	TukuiDB:CreatePanel(crblu, 10, 10, "BOTTOM", rbl, "TOP", 0, 0)
	TukuiDB:CreatePanel(crbld, 10, 10, "TOP", rbl, "BOTTOM", 0, 0)
end

local petbg = CreateFrame("Frame", "PetActionBarBackground", PetActionButton1)
if TukuiDB["actionbar"].rightbars > 0 then
	TukuiDB:CreatePanel(petbg, 1, 1, "RIGHT", barbgr, "LEFT", TukuiDB:Scale(-6), 0)
else
	TukuiDB:CreatePanel(petbg, 1, 1, "RIGHT", UIParent, "RIGHT", TukuiDB:Scale(-6), TukuiDB:Scale(-13.5))
end
petbg:SetWidth(petbuttonspacing+petbuttonsize+petbuttonspacing)
petbg:SetHeight((petbuttonsize * 10) + (petbuttonspacing * 11))

local ltpetbg1 = CreateFrame("Frame", "LineToPetActionBarBackground", petbg)
TukuiDB:CreatePanel(ltpetbg1, 30, 265, "TOPLEFT", petbg, "TOPRIGHT", 0, -33)
ltpetbg1:SetFrameLevel(0)
ltpetbg1:SetAlpha(.8)