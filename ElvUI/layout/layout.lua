local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

-- BUTTON SIZES
E.buttonsize = E.Scale(C["actionbar"].buttonsize)
E.buttonspacing = E.Scale(C["actionbar"].buttonspacing)
E.petbuttonsize = E.Scale(C["actionbar"].petbuttonsize)
E.buttonspacing = E.Scale(C["actionbar"].buttonspacing)
E.minimapsize = E.Scale(165)

--

--BOTTOM PANEL

local f = CreateFrame("Frame", "ElvuiBottomPanel", E.UIParent)
f:SetHeight(23)
f:SetWidth(E.UIParent:GetWidth() + (E.mult * 2))
f:SetPoint("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", -E.mult, -E.mult)
f:SetPoint("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", E.mult, -E.mult)
f:SetFrameStrata("BACKGROUND")
f:SetFrameLevel(1)

--TOP PANEL
if C["general"].upperpanel == true then
	local f = CreateFrame("Frame", "ElvuiTopPanel", E.UIParent)
	f:SetHeight(23)
	f:SetWidth(E.UIParent:GetWidth() + (E.mult * 2))
	f:SetPoint("TOPLEFT", E.UIParent, "TOPLEFT", -E.mult, E.mult)
	f:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", E.mult, E.mult)
	f:SetFrameStrata("BACKGROUND")
	f:SetFrameLevel(0)
	f:SetTemplate("Transparent")
	f:CreateShadow("Default")
	
	local f = CreateFrame("Frame", "ElvuiLoc", ElvuiTopPanel)
	f:SetHeight(23)
	f:SetWidth(E.minimapsize)
	f:SetFrameLevel(2)
	f:SetTemplate("Default", true)
	f:CreateShadow("Default")
	f:Point("CENTER", ElvuiTopPanel, "BOTTOM")
	
	local f = CreateFrame("Frame", "ElvuiLocX", ElvuiLoc)
	f:SetHeight(23)
	f:SetWidth(E.minimapsize / 6)
	f:SetFrameLevel(2)
	f:SetTemplate("Default", true)
	f:CreateShadow("Default")
	f:Point("RIGHT", ElvuiLoc, "LEFT", -2, 0)	
	
	local f = CreateFrame("Frame", "ElvuiLocY", ElvuiLoc)
	f:SetHeight(23)
	f:SetWidth(E.minimapsize / 6)
	f:SetFrameLevel(2)
	f:SetTemplate("Default", true)
	f:CreateShadow("Default")
	f:Point("LEFT", ElvuiLoc, "RIGHT", 2, 0)	

	local f = CreateFrame("Frame", "ElvuiStat9Block", ElvuiTopPanel)
	f:SetHeight(23)
	f:SetWidth(E.minimapsize / 1.3)
	f:SetFrameLevel(2)
	f:SetTemplate("Default", true)
	f:CreateShadow("Default")
	f:Point("RIGHT", ElvuiLocX, "LEFT", -6, 0)			
	
	local f = CreateFrame("Frame", "ElvuiStat10Block", ElvuiTopPanel)
	f:SetHeight(23)
	f:SetWidth(E.minimapsize / 1.3)
	f:SetFrameLevel(2)
	f:SetTemplate("Default", true)
	f:CreateShadow("Default")
	f:Point("LEFT", ElvuiLocY, "RIGHT", 6, 0)	

end

local mini = CreateFrame("Frame", "ElvuiMinimap", Minimap)
mini:CreatePanel("Default", E.minimapsize, E.minimapsize, "CENTER", Minimap, "CENTER", -0, 0)
mini:ClearAllPoints()
mini:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
mini:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
mini:SetFrameLevel(2)
ElvuiMinimap:CreateShadow("Default")
ElvuiMinimap.shadow:SetFrameLevel(0)
TukuiMinimap = ElvuiMinimap -- conversion

-- MINIMAP STAT FRAMES
if ElvuiMinimap then
	local minimapstatsleft = CreateFrame("Frame", "ElvuiMinimapStatsLeft", ElvuiMinimap)
	minimapstatsleft:CreatePanel("Default", (E.minimapsize / 2) - 1, 19, "TOPLEFT", ElvuiMinimap, "BOTTOMLEFT", 0, -1)

	local minimapstatsright = CreateFrame("Frame", "ElvuiMinimapStatsRight", ElvuiMinimap)
	minimapstatsright:CreatePanel("Default", (E.minimapsize / 2) - 1, 19, "TOPRIGHT", ElvuiMinimap, "BOTTOMRIGHT", 0, -1)
	ElvuiMinimapStatsLeft:SetTemplate("Default", true)
	ElvuiMinimapStatsRight:SetTemplate("Default", true)
	ElvuiMinimapStatsLeft:CreateShadow("Default")
	ElvuiMinimapStatsRight:CreateShadow("Default")
	ElvuiMinimapStatsRight.shadow:SetFrameLevel(0)
	ElvuiMinimapStatsLeft.shadow:SetFrameLevel(0)
	
	if C["others"].raidbuffreminder then
		local maptoggle = CreateFrame("Button", "ElvUIMapToggle", ElvuiMinimap)
		maptoggle:CreatePanel("Default", (((E.minimapsize - 9) / 6)) + 4, 19, "TOPLEFT", ElvuiMinimapStatsRight, "TOPRIGHT", 1, 0)
		maptoggle:SetTemplate("Default", true)
		maptoggle:CreateShadow("Default")
		maptoggle.shadow:SetFrameLevel(0)
		maptoggle:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
		maptoggle.text:SetText("M")
		maptoggle.text:SetTextColor(unpack(C["media"].valuecolor))
		maptoggle.text:SetPoint("CENTER")
		maptoggle:SetScript("OnClick", function() ToggleFrame(WorldMapFrame) end)
		WorldMapFrame:HookScript("OnShow", function() maptoggle.text:SetTextColor(unpack(C["media"].valuecolor)) end)
		WorldMapFrame:HookScript("OnHide", function() maptoggle.text:SetTextColor(1, 1, 1) end)
	end
	
	TukuiMinimapStatsLeft = ElvuiMinimapStatsLeft -- conversion
	TukuiMinimapStatsRight = ElvuiMinimapStatsRight -- conversion
end

-- MAIN ACTION BAR
local barbg = CreateFrame("Frame", "ElvuiActionBarBackground", E.UIParent)
if C["actionbar"].bottompetbar ~= true then
	barbg:CreatePanel("Default", 1, 1, "BOTTOM", E.UIParent, "BOTTOM", 0, E.Scale(4))
else
	barbg:CreatePanel("Default", 1, 1, "BOTTOM", E.UIParent, "BOTTOM", 0, (E.buttonsize + (E.buttonspacing * 2)) + E.Scale(8))
end
barbg:SetWidth(math.ceil((E.buttonsize * 12) + (E.buttonspacing * 13)))
barbg:SetFrameStrata("BACKGROUND")
barbg:SetHeight(E.buttonsize + (E.buttonspacing * 2))
barbg:CreateShadow("Default")
barbg:SetFrameLevel(2)

if C["actionbar"].enable ~= true then
	barbg:SetAlpha(0)
end

--SPLIT BAR PANELS
local splitleft = CreateFrame("Frame", "ElvuiSplitActionBarLeftBackground", ElvuiActionBarBackground)
splitleft:CreatePanel("Default", (E.buttonsize * 6) + (E.buttonspacing * 7), ElvuiActionBarBackground:GetHeight(), "RIGHT", ElvuiActionBarBackground, "LEFT", E.Scale(-4), 0)
splitleft:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitleft:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())

local splitright = CreateFrame("Frame", "ElvuiSplitActionBarRightBackground", ElvuiActionBarBackground)
splitright:CreatePanel("Default", (E.buttonsize * 6) + (E.buttonspacing * 7), ElvuiActionBarBackground:GetHeight(), "LEFT", ElvuiActionBarBackground, "RIGHT", E.Scale(4), 0)
splitright:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitright:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())

splitleft:CreateShadow("Default")
splitright:CreateShadow("Default")


-- RIGHT BAR
if C["actionbar"].enable == true then
	local barbgr = CreateFrame("Frame", "ElvuiActionBarBackgroundRight", ElvuiActionBarBackground)
	barbgr:CreatePanel("Default", 1, (E.buttonsize * 12) + (E.buttonspacing * 13), "RIGHT", E.UIParent, "RIGHT", E.Scale(-4), E.Scale(-8))
	barbgr:Hide()
	barbgr:SetFrameLevel(2)
	
	local petbg = CreateFrame("Frame", "ElvuiPetActionBarBackground", E.UIParent)
	if C["actionbar"].bottompetbar ~= true then
		petbg:CreatePanel("Default", E.petbuttonsize + (E.buttonspacing * 2), (E.petbuttonsize * 10) + (E.buttonspacing * 11), "RIGHT", E.UIParent, "RIGHT", E.Scale(-6), E.Scale(-13.5))
	else
		petbg:CreatePanel("Default", (E.petbuttonsize * 10) + (E.buttonspacing * 11), E.petbuttonsize + (E.buttonspacing * 2), "TOP", ElvuiActionBarBackground, "BOTTOM", 0, -5)
	end
	
	local ltpetbg = CreateFrame("Frame", "ElvuiLineToPetActionBarBackground", petbg)
	if C["actionbar"].bottompetbar ~= true then
		ltpetbg:CreatePanel("Default", 30, 265, "LEFT", petbg, "RIGHT", 0, 0)
	else
		ltpetbg:CreatePanel("Default", 265, 30, "BOTTOM", petbg, "TOP", 0, 0)
	end
	
	ltpetbg:SetScript("OnShow", function(self)
		self:SetFrameStrata("BACKGROUND")
		self:SetFrameLevel(0)
	end)

	
	barbgr:CreateShadow("Default")
	petbg:CreateShadow("Default")
end

-- VEHICLE BAR
if C["actionbar"].enable == true then
	local yoffset = 0
	if C["general"].lowerpanel == true then
		yoffset = yoffset + 30
	end

	local vbarbg = CreateFrame("Frame", "ElvuiVehicleBarBackground", E.UIParent)
	vbarbg:CreatePanel("Default", 1, 1, "BOTTOM", E.UIParent, "BOTTOM", 0, 4+yoffset)
	vbarbg:SetWidth((E.buttonsize * 12) + (E.buttonspacing * 13))
	vbarbg:SetHeight(E.buttonsize + (E.buttonspacing * 2))
	vbarbg:CreateShadow("Default")
	vbarbg:SetFrameLevel(4)
	vbarbg.shadow:SetFrameLevel(0)
end

-- CHAT PLACEHOLDER LEFT
local PADDING = 12
local xOffset = 0
local yOffset = 0

if C["chat"].style ~= "ElvUI" then
	xOffset = -8
	yOffset = -6
end

-- CHAT PLACEHOLDER LEFT
local chatlph = CreateFrame("Frame", "ChatLPlaceHolder", E.UIParent)
chatlph:SetWidth(C["chat"].chatwidth)
chatlph:SetHeight(C["chat"].chatheight+6)
chatlph:Point("BOTTOMLEFT", ElvuiBottomPanel, "TOPLEFT", PADDING + xOffset,  PADDING + yOffset)

-- CHAT PLACEHOLDER RIGHT
local chatrph = CreateFrame("Frame", "ChatRPlaceHolder", E.UIParent)
chatrph:SetWidth(C["chat"].chatwidth)
chatrph:SetHeight(C["chat"].chatheight+6)
chatrph:Point("BOTTOMRIGHT", ElvuiBottomPanel, "TOPRIGHT", -PADDING + math.abs(xOffset),  PADDING + yOffset)

-- CHAT BACKGROUND LEFT
local chatlbg = CreateFrame("Frame", "ChatLBG", E.UIParent)
chatlbg:SetWidth(C["chat"].chatwidth + 14)
chatlbg:SetHeight(C["chat"].chatheight + 68)
chatlbg:Point("CENTER", chatlph, "CENTER")
chatlbg:SetFrameStrata("BACKGROUND")

-- CHAT BACKGROUND LEFT DUMMY (WHEN WE NEED TO ANCHOR SOMETHING TO THE LEFT CHAT BACKGROUND, ANCHOR IT TO THIS, OTHERWISE IF THE ANCHOR FRAME IS PROTECTED THEN WE CANNOT TOGGLE CHAT IN COMBAT
local chatlbgdummy = CreateFrame("Frame", "ChatLBGDummy", E.UIParent)
chatlbgdummy:SetWidth(C["chat"].chatwidth + 14)
chatlbgdummy:SetHeight(C["chat"].chatheight + 68)
chatlbgdummy:Point("CENTER", chatlph, "CENTER")

-- CHAT BACKGROUND RIGHT
local chatrbg = CreateFrame("Frame", "ChatRBG", E.UIParent)
chatrbg:SetWidth(C["chat"].chatwidth + 14)
chatrbg:SetHeight(C["chat"].chatheight + 68)
chatrbg:Point("CENTER", chatrph, "CENTER")
chatrbg:SetFrameStrata("BACKGROUND")

-- CHAT BACKGROUND RIGHT DUMMY (WHEN WE NEED TO ANCHOR SOMETHING TO THE RIGHT CHAT BACKGROUND, ANCHOR IT TO THIS, OTHERWISE IF THE ANCHOR FRAME IS PROTECTED THEN WE CANNOT TOGGLE CHAT IN COMBAT
local chatrbgdummy = CreateFrame("Frame", "ChatRBGDummy", E.UIParent)
chatrbgdummy:SetWidth(C["chat"].chatwidth + 14)
chatrbgdummy:SetHeight(C["chat"].chatheight + 68)
chatrbgdummy:Point("CENTER", chatrph, "CENTER")

E.ChatRightShown = true

--INFO LEFT
local infoleft = CreateFrame("Frame", "ElvuiInfoLeft", E.UIParent)
infoleft:SetFrameLevel(2)
infoleft:SetTemplate("Default", true)
infoleft:SetPoint("TOPLEFT", chatlph, "BOTTOMLEFT", E.Scale(17), E.Scale(-3))
infoleft:SetPoint("BOTTOMRIGHT", chatlph, "BOTTOMRIGHT", E.Scale(-17), E.Scale(-25))

	--INFOLEFT L BUTTON
	local infoleftLbutton = CreateFrame("Button", "ElvuiInfoLeftLButton", ElvuiInfoLeft)
	infoleftLbutton:SetTemplate("Default", true)
	infoleftLbutton:Point("TOPRIGHT", infoleft, "TOPLEFT", -1, 0)
	infoleftLbutton:Point("BOTTOMLEFT", chatlph, "BOTTOMLEFT", 0, -25)

	--INFOLEFT R BUTTON
	local infoleftRbutton = CreateFrame("Button", "ElvuiInfoLeftRButton", ElvuiInfoLeft)
	infoleftRbutton:SetTemplate("Default", true)
	infoleftRbutton:Point("TOPLEFT", infoleft, "TOPRIGHT", 1, 0)
	infoleftRbutton:Point("BOTTOMRIGHT", chatlph, "BOTTOMRIGHT", 0, -25)

	infoleftLbutton:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	infoleftLbutton.text:SetText("<")
	infoleftLbutton.text:SetPoint("CENTER")

	infoleftRbutton:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	infoleftRbutton.text:SetText("L")
	infoleftRbutton.text:SetPoint("CENTER")
	
	infoleft:CreateShadow("Default")
	infoleft.shadow:ClearAllPoints()
	infoleft.shadow:Point("TOPLEFT", infoleftLbutton, "TOPLEFT", -3, 3)
	infoleft.shadow:Point("BOTTOMRIGHT", infoleftRbutton, "BOTTOMRIGHT", 3, -3)
	infoleft.shadow:SetBackdropBorderColor(0, 0, 0, 0)

--INFO RIGHT
local inforight = CreateFrame("Frame", "ElvuiInfoRight", E.UIParent)
inforight:SetTemplate("Default", true)
inforight:SetFrameLevel(2)
inforight:SetPoint("TOPLEFT", chatrph, "BOTTOMLEFT", E.Scale(17), E.Scale(-3))
inforight:SetPoint("BOTTOMRIGHT", chatrph, "BOTTOMRIGHT", E.Scale(-17), E.Scale(-25))

	--INFORIGHT L BUTTON
	local inforightLbutton = CreateFrame("Button", "ElvuiInfoRightLButton", ElvuiInfoRight)
	inforightLbutton:SetTemplate("Default", true)
	inforightLbutton:Point("TOPRIGHT", inforight, "TOPLEFT", -1, 0)
	inforightLbutton:Point("BOTTOMLEFT", chatrph, "BOTTOMLEFT", 0, -25)

	--INFORIGHT R BUTTON
	local inforightRbutton = CreateFrame("Button", "ElvuiInfoRightRButton", ElvuiInfoRight)
	inforightRbutton:SetTemplate("Default", true)
	inforightRbutton:Point("TOPLEFT", inforight, "TOPRIGHT", 1, 0)
	inforightRbutton:Point("BOTTOMRIGHT", chatrph, "BOTTOMRIGHT", 0, -25)
	
	inforightLbutton:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	inforightLbutton.text:SetText("C")
	inforightLbutton.text:SetPoint("CENTER")
	inforightLbutton:SetScript("OnClick", function(self)
		if not IsAddOnLoaded("ElvUI_Config") then return end
		local ElvuiConfig = LibStub("AceAddon-3.0"):GetAddon("ElvuiConfig")
		if not ElvuiConfig then return end
		ElvuiConfig:ShowConfig() 
	end)
	inforightLbutton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, E.Scale(6));
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, E.mult)	
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L.openConfigTooltip, 1, 1, 1)
		GameTooltip:Show()
	end)
	inforightLbutton:SetScript("OnLeave", function() GameTooltip:Hide() end)

	inforightRbutton:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	inforightRbutton.text:SetText(">")
	inforightRbutton.text:SetPoint("CENTER")
	
	inforight:CreateShadow("Default")
	inforight.shadow:ClearAllPoints()
	inforight.shadow:Point("TOPLEFT", inforightLbutton, "TOPLEFT", -3, 3)
	inforight.shadow:Point("BOTTOMRIGHT", inforightRbutton, "BOTTOMRIGHT", 3, -3)
	inforight.shadow:SetBackdropBorderColor(0, 0, 0, 0)		
	
TukuiInfoLeft = ElvuiInfoLeft -- conversion
TukuiInfoRight = ElvuiInfoRight -- conversion	

if C["chat"].showbackdrop == true then
	local chatltbg = CreateFrame("Frame", "ChatLBGTab", chatlbg)
	chatltbg:SetTemplate("Default", true)
	chatltbg:SetPoint("BOTTOMLEFT", chatlph, "TOPLEFT", 0, E.Scale(3))
	chatltbg:SetPoint("BOTTOMRIGHT", chatlph, "TOPRIGHT", 0, E.Scale(3))
	chatltbg:SetHeight(E.Scale(22))
	
	if C["chat"].style == "ElvUI" then
		chatlbg:SetTemplate("Transparent")
	else
		local classicbg = CreateFrame('Frame', nil, ChatLBG) 
		classicbg:SetTemplate("Transparent")
		classicbg:SetPoint('CENTER', chatlph, 'CENTER')
		classicbg:Size(chatlph:GetSize())
		classicbg:CreateShadow("Default")
		chatltbg:CreateShadow("Default")
		infoleft.shadow:SetBackdropBorderColor(0, 0, 0, 0.9)
		
		ChatLBG:Width(chatlph:GetWidth())
		ChatLBG:Height(chatlph:GetHeight() + 47)
		ChatLBGDummy:Width(chatlph:GetWidth())
		ChatLBGDummy:Height(chatlph:GetHeight() + 47)
	end	

	local chatrtbg = CreateFrame("Frame","ChatRBGTab", chatrbg)
	chatrtbg:SetTemplate("Default", true)
	chatrtbg:SetPoint("BOTTOMLEFT", chatrph, "TOPLEFT", 0, E.Scale(3))
	chatrtbg:SetPoint("BOTTOMRIGHT", chatrph, "TOPRIGHT", 0, E.Scale(3))
	chatrtbg:SetHeight(E.Scale(22))
	
	if C["chat"].style == "ElvUI" then
		chatrbg:SetTemplate("Transparent")
	else
		local classicbg = CreateFrame('Frame', nil, ChatRBG) 
		classicbg:SetTemplate("Transparent")
		classicbg:SetPoint('CENTER', chatrph, 'CENTER')
		classicbg:Size(chatrph:GetSize())
		classicbg:CreateShadow("Default")
		chatrtbg:CreateShadow("Default")
		inforight.shadow:SetBackdropBorderColor(0, 0, 0, 0.9)
		
		ChatRBG:Width(chatrph:GetWidth())
		ChatRBG:Height(chatrph:GetHeight() + 47)
		ChatRBGDummy:Width(chatrph:GetWidth())
		ChatRBGDummy:Height(chatrph:GetHeight() + 47)		
	end		
end

if C["general"].lowerpanel == true then	
	ElvuiBottomPanel:SetTemplate("Transparent")
	ElvuiBottomPanel:CreateShadow("Default")

	local yoffset = 0
	if C["actionbar"].bottompetbar == true then yoffset = yoffset + 42 end		
	local f = CreateFrame("Frame", "ElvUILowerStatPanel", E.UIParent)
	f:SetHeight(23)
	f:Point("TOPRIGHT", ElvuiActionBarBackground, "BOTTOMRIGHT", 0, -(4 + yoffset))
	f:Point("TOPLEFT", ElvuiActionBarBackground, "BOTTOMLEFT", 0, -(4 + yoffset))		
	f:SetTemplate("Default", true)
	f:SetFrameStrata("BACKGROUND")
	f:SetFrameLevel(3)
	f:CreateShadow("Default")
	f.shadow:SetFrameLevel(0)
	
	local f = CreateFrame("Frame", "ElvUILowerStatPanelLeft", ElvuiSplitActionBarLeftBackground)
	f:SetHeight(23)
	f:Point("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "BOTTOMRIGHT", 0, -(4 + yoffset))
	f:Point("TOPLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", 0, -(4 + yoffset))		
	f:SetTemplate("Default", true)
	f:SetFrameStrata("BACKGROUND")
	f:SetFrameLevel(3)
	f:CreateShadow("Default")
	f.shadow:SetFrameLevel(0)	
	
	local f = CreateFrame("Frame", "ElvUILowerStatPanelRight", ElvuiSplitActionBarRightBackground)
	f:SetHeight(23)
	f:Point("TOPRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", 0, -(4 + yoffset))
	f:Point("TOPLEFT", ElvuiSplitActionBarRightBackground, "BOTTOMLEFT", 0, -(4 + yoffset))		
	f:SetTemplate("Default", true)
	f:SetFrameStrata("BACKGROUND")
	f:SetFrameLevel(3)
	f:CreateShadow("Default")
	f.shadow:SetFrameLevel(0)	
end