local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales



-- BUTTON SIZES
DB.buttonsize = DB.Scale(C["actionbar"].buttonsize)
DB.buttonspacing = DB.Scale(C["actionbar"].buttonspacing)
DB.petbuttonsize = DB.Scale(C["actionbar"].petbuttonsize)
DB.petbuttonspacing = DB.Scale(C["actionbar"].petbuttonspacing)

--BOTTOM DUMMY FRAME DOES NOTHING BUT HOLDS FRAME POSITIONS
local bottompanel = CreateFrame("Frame", "ElvuiBottomPanel", UIParent)
bottompanel:SetHeight(23)
bottompanel:SetWidth(UIParent:GetWidth() + (DB.mult * 2))
bottompanel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -DB.mult, -DB.mult)
bottompanel:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", DB.mult, -DB.mult)


local mini = CreateFrame("Frame", "ElvuiMinimap", Minimap)
DB.CreatePanel(mini, DB.Scale(144 + 4), DB.Scale(144 + 4), "CENTER", Minimap, "CENTER", -0, 0)
mini:ClearAllPoints()
mini:SetPoint("TOPLEFT", DB.Scale(-2), DB.Scale(2))
mini:SetPoint("BOTTOMRIGHT", DB.Scale(2), DB.Scale(-2))
DB.CreateShadow(ElvuiMinimap)
TukuiMinimap = ElvuiMinimap -- conversion

-- MINIMAP STAT FRAMES
if ElvuiMinimap then
	local minimapstatsleft = CreateFrame("Frame", "ElvuiMinimapStatsLeft", ElvuiMinimap)
	DB.CreatePanel(minimapstatsleft, (ElvuiMinimap:GetWidth() / 2) - 2, 19, "TOPLEFT", ElvuiMinimap, "BOTTOMLEFT", 0, DB.Scale(-3))

	local minimapstatsright = CreateFrame("Frame", "ElvuiMinimapStatsRight", ElvuiMinimap)
	DB.CreatePanel(minimapstatsright, (ElvuiMinimap:GetWidth() / 2) -2, 19, "TOPRIGHT", ElvuiMinimap, "BOTTOMRIGHT", 0, DB.Scale(-3))
	DB.SetNormTexTemplate(ElvuiMinimapStatsLeft)
	DB.SetNormTexTemplate(ElvuiMinimapStatsRight)
	DB.CreateShadow(ElvuiMinimapStatsLeft)
	DB.CreateShadow(ElvuiMinimapStatsRight)
	
	TukuiMinimapStatsLeft = ElvuiMinimapStatsLeft -- conversion
	TukuiMinimapStatsRight = ElvuiMinimapStatsRight -- conversion
end

-- MAIN ACTION BAR
local barbg = CreateFrame("Frame", "ElvuiActionBarBackground", UIParent)
if C["actionbar"].bottompetbar ~= true then
	DB.CreatePanel(barbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, DB.Scale(4))
else
	DB.CreatePanel(barbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, (DB.buttonsize + (DB.buttonspacing * 2)) + DB.Scale(8))
end
barbg:SetWidth(((DB.buttonsize * 12) + (DB.buttonspacing * 13)))
barbg:SetFrameStrata("LOW")
if C["actionbar"].bottomrows == 3 then
	barbg:SetHeight((DB.buttonsize * 3) + (DB.buttonspacing * 4))
elseif C["actionbar"].bottomrows == 2 then
	barbg:SetHeight((DB.buttonsize * 2) + (DB.buttonspacing * 3))
else
	barbg:SetHeight(DB.buttonsize + (DB.buttonspacing * 2))
end
DB.CreateShadow(barbg)

if C["actionbar"].enable ~= true then
	barbg:SetAlpha(0)
end

--SPLIT BAR PANELS
local splitleft = CreateFrame("Frame", "ElvuiSplitActionBarLeftBackground", ElvuiActionBarBackground)
DB.CreatePanel(splitleft, (DB.buttonsize * 3) + (DB.buttonspacing * 4), ElvuiActionBarBackground:GetHeight(), "RIGHT", ElvuiActionBarBackground, "LEFT", DB.Scale(-4), 0)
splitleft:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitleft:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())

local splitright = CreateFrame("Frame", "ElvuiSplitActionBarRightBackground", ElvuiActionBarBackground)
DB.CreatePanel(splitright, (DB.buttonsize * 3) + (DB.buttonspacing * 4), ElvuiActionBarBackground:GetHeight(), "LEFT", ElvuiActionBarBackground, "RIGHT", DB.Scale(4), 0)
splitright:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitright:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())

if C["actionbar"].bottomrows == 3 then
	splitleft:SetWidth((DB.buttonsize * 4) + (DB.buttonspacing * 5))
	splitright:SetWidth((DB.buttonsize * 4) + (DB.buttonspacing * 5))
end

DB.CreateShadow(splitleft)
DB.CreateShadow(splitright)


if C["actionbar"].splitbar ~= true then
	ElvuiSplitActionBarLeftBackground:Hide()
	ElvuiSplitActionBarRightBackground:Hide()
end

-- RIGHT BAR
if C["actionbar"].enable == true then
	local barbgr = CreateFrame("Frame", "ElvuiActionBarBackgroundRight", ElvuiActionBarBackground)
	DB.CreatePanel(barbgr, 1, (DB.buttonsize * 12) + (DB.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", DB.Scale(-4), DB.Scale(-8))
	if C["actionbar"].rightbars == 1 then
		barbgr:SetWidth(DB.buttonsize + (DB.buttonspacing * 2))
	elseif C["actionbar"].rightbars == 2 then
		barbgr:SetWidth((DB.buttonsize * 2) + (DB.buttonspacing * 3))
	elseif C["actionbar"].rightbars == 3 then
		barbgr:SetWidth((DB.buttonsize * 3) + (DB.buttonspacing * 4))
	else
		barbgr:Hide()
	end
	DB.AnimGroup(ElvuiActionBarBackgroundRight, DB.Scale(350), 0, 0.4)

	local petbg = CreateFrame("Frame", "ElvuiPetActionBarBackground", UIParent)
	if C["actionbar"].bottompetbar ~= true then
		if C["actionbar"].rightbars > 0 then
			DB.CreatePanel(petbg, DB.petbuttonsize + (DB.petbuttonspacing * 2), (DB.petbuttonsize * 10) + (DB.petbuttonspacing * 11), "RIGHT", barbgr, "LEFT", DB.Scale(-6), 0)
		else
			DB.CreatePanel(petbg, DB.petbuttonsize + (DB.petbuttonspacing * 2), (DB.petbuttonsize * 10) + (DB.petbuttonspacing * 11), "RIGHT", UIParent, "RIGHT", DB.Scale(-6), DB.Scale(-13.5))
		end
	else
		DB.CreatePanel(petbg, (DB.petbuttonsize * 10) + (DB.petbuttonspacing * 11), DB.petbuttonsize + (DB.petbuttonspacing * 2), "BOTTOM", UIParent, "BOTTOM", 0, DB.Scale(4))
	end
	
	local ltpetbg = CreateFrame("Frame", "ElvuiLineToPetActionBarBackground", petbg)
	if C["actionbar"].bottompetbar ~= true then
		DB.CreatePanel(ltpetbg, 30, 265, "LEFT", petbg, "RIGHT", 0, 0)
	else
		DB.CreatePanel(ltpetbg, 265, 30, "BOTTOM", petbg, "TOP", 0, 0)
	end
	
	ltpetbg:SetScript("OnShow", function(self)
		self:SetFrameStrata("BACKGROUND")
		self:SetFrameLevel(0)
	end)

	
	DB.CreateShadow(barbgr)
	DB.CreateShadow(petbg)
end

-- VEHICLE BAR
if C["actionbar"].enable == true then
	local vbarbg = CreateFrame("Frame", "ElvuiVehicleBarBackground", UIParent)
	DB.CreatePanel(vbarbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, DB.Scale(4))
	vbarbg:SetWidth(((DB.buttonsize * 11) + (DB.buttonspacing * 12))*1.2)
	vbarbg:SetHeight((DB.buttonsize + (DB.buttonspacing * 2))*1.2)
	DB.CreateShadow(vbarbg)
end

-- CHAT BACKGROUND LEFT (MOVES)
local chatlbgdummy = CreateFrame("Frame", "ChatLBackground", UIParent)
chatlbgdummy:SetWidth(C["chat"].chatwidth)
chatlbgdummy:SetHeight(C["chat"].chatheight+6)
chatlbgdummy:SetPoint("BOTTOMLEFT", ElvuiBottomPanel, "TOPLEFT", DB.Scale(4),  DB.Scale(7))

-- CHAT BACKGROUND LEFT (DOESN'T MOVE THIS IS WHAT WE ATTACH FRAMES TO)
local chatlbgdummy2 = CreateFrame("Frame", "ChatLBackground2", UIParent)
chatlbgdummy2:SetWidth(C["chat"].chatwidth)
chatlbgdummy2:SetHeight(C["chat"].chatheight+6)
chatlbgdummy2:SetPoint("BOTTOMLEFT", ElvuiBottomPanel, "TOPLEFT", DB.Scale(4),  DB.Scale(7))

-- CHAT BACKGROUND RIGHT (MOVES)
local chatrbgdummy = CreateFrame("Frame", "ChatRBackground", UIParent)
chatrbgdummy:SetWidth(C["chat"].chatwidth)
chatrbgdummy:SetHeight(C["chat"].chatheight+6)
chatrbgdummy:SetPoint("BOTTOMRIGHT", ElvuiBottomPanel, "TOPRIGHT", DB.Scale(-4),  DB.Scale(7))

-- CHAT BACKGROUND RIGHT (DOESN'T MOVE THIS IS WHAT WE ATTACH FRAMES TO)
local chatrbgdummy2 = CreateFrame("Frame", "ChatRBackground2", UIParent)
chatrbgdummy2:SetWidth(C["chat"].chatwidth)
chatrbgdummy2:SetHeight(C["chat"].chatheight+6)
chatrbgdummy2:SetPoint("BOTTOMRIGHT", ElvuiBottomPanel, "TOPRIGHT", DB.Scale(-4),  DB.Scale(7))

DB.AnimGroup(ChatLBackground, DB.Scale(-375), 0, 0.4)
DB.AnimGroup(ChatRBackground, DB.Scale(375), 0, 0.4)

DB.ChatRightShown = false
if C["chat"].showbackdrop == true then
	local chatlbg = CreateFrame("Frame", nil, ChatLBackground)
	DB.SetTransparentTemplate(chatlbg)
	chatlbg:SetAllPoints(chatlbgdummy)
	chatlbg:SetFrameStrata("BACKGROUND")
	
	local chatltbg = CreateFrame("Frame", nil, chatlbg)
	DB.SetNormTexTemplate(chatltbg)
	chatltbg:SetPoint("BOTTOMLEFT", chatlbg, "TOPLEFT", 0, DB.Scale(3))
	chatltbg:SetPoint("BOTTOMRIGHT", chatlbg, "TOPRIGHT", DB.Scale(-24), DB.Scale(3))
	chatltbg:SetHeight(DB.Scale(22))
	chatltbg:SetFrameStrata("BACKGROUND")
	
	DB.CreateShadow(chatlbg)
	DB.CreateShadow(chatltbg)
end

if C["chat"].showbackdrop == true then
	local chatrbg = CreateFrame("Frame", "ChatRBG", ChatRBackground)
	chatrbg:SetAllPoints(chatrbgdummy)
	DB.SetTransparentTemplate(chatrbg)
	chatrbg:SetFrameStrata("BACKGROUND")
	chatrbg:SetBackdropColor(unpack(C["media"].backdropfadecolor))
	chatrbg:SetAlpha(0)

	local chatrtbg = CreateFrame("Frame", nil, chatrbg)
	DB.SetNormTexTemplate(chatrtbg)
	chatrtbg:SetPoint("BOTTOMLEFT", chatrbg, "TOPLEFT", 0, DB.Scale(3))
	chatrtbg:SetPoint("BOTTOMRIGHT", chatrbg, "TOPRIGHT", DB.Scale(-24), DB.Scale(3))
	chatrtbg:SetHeight(DB.Scale(22))
	chatrtbg:SetFrameStrata("BACKGROUND")
	DB.CreateShadow(chatrbg)
	DB.CreateShadow(chatrtbg)
end

--INFO LEFT
local infoleft = CreateFrame("Frame", "ElvuiInfoLeft", UIParent)
infoleft:SetFrameLevel(2)
DB.SetNormTexTemplate(infoleft)
DB.CreateShadow(infoleft)
infoleft:SetPoint("TOPLEFT", chatlbgdummy2, "BOTTOMLEFT", DB.Scale(17), DB.Scale(-4))
infoleft:SetPoint("BOTTOMRIGHT", chatlbgdummy2, "BOTTOMRIGHT", DB.Scale(-17), DB.Scale(-26))

	--INFOLEFT L BUTTON
	local infoleftLbutton = CreateFrame("Button", "ElvuiInfoLeftLButton", ElvuiInfoLeft)
	DB.SetNormTexTemplate(infoleftLbutton)
	infoleftLbutton:SetPoint("TOPRIGHT", infoleft, "TOPLEFT", DB.Scale(-2), 0)
	infoleftLbutton:SetPoint("BOTTOMLEFT", chatlbgdummy2, "BOTTOMLEFT", 0, DB.Scale(-26))

	--INFOLEFT R BUTTON
	local infoleftRbutton = CreateFrame("Button", "ElvuiInfoLeftRButton", ElvuiInfoLeft)
	DB.SetNormTexTemplate(infoleftRbutton)
	infoleftRbutton:SetPoint("TOPLEFT", infoleft, "TOPRIGHT", DB.Scale(2), 0)
	infoleftRbutton:SetPoint("BOTTOMRIGHT", chatlbgdummy2, "BOTTOMRIGHT", 0, DB.Scale(-26))
	
	infoleft.shadow:ClearAllPoints()
	infoleft.shadow:SetPoint("TOPLEFT", infoleftLbutton, "TOPLEFT", DB.Scale(-4), DB.Scale(4))
	infoleft.shadow:SetPoint("BOTTOMRIGHT", infoleftRbutton, "BOTTOMRIGHT", DB.Scale(4), DB.Scale(-4))

	infoleftLbutton.Text = DB.SetFontString(ElvuiInfoLeftLButton, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	infoleftLbutton.Text:SetText("<")
	infoleftLbutton.Text:SetPoint("CENTER")

	infoleftRbutton.Text = DB.SetFontString(ElvuiInfoLeftRButton, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	infoleftRbutton.Text:SetText("L")
	infoleftRbutton.Text:SetPoint("CENTER")

--INFO RIGHT
local inforight = CreateFrame("Frame", "ElvuiInfoRight", UIParent)
DB.SetNormTexTemplate(inforight)
infoleft:SetFrameLevel(2)
DB.CreateShadow(inforight)
inforight:SetPoint("TOPLEFT", chatrbgdummy2, "BOTTOMLEFT", DB.Scale(17), DB.Scale(-4))
inforight:SetPoint("BOTTOMRIGHT", chatrbgdummy2, "BOTTOMRIGHT", DB.Scale(-17), DB.Scale(-26))

	--INFORIGHT L BUTTON
	local inforightLbutton = CreateFrame("Button", "ElvuiInfoRightLButton", ElvuiInfoRight)
	DB.SetNormTexTemplate(inforightLbutton)
	inforightLbutton:SetPoint("TOPRIGHT", inforight, "TOPLEFT", DB.Scale(-2), 0)
	inforightLbutton:SetPoint("BOTTOMLEFT", chatrbgdummy2, "BOTTOMLEFT", 0, DB.Scale(-26))

	--INFORIGHT R BUTTON
	local inforightRbutton = CreateFrame("Button", "ElvuiInfoRightRButton", ElvuiInfoRight)
	DB.SetNormTexTemplate(inforightRbutton)
	inforightRbutton:SetPoint("TOPLEFT", inforight, "TOPRIGHT", DB.Scale(2), 0)
	inforightRbutton:SetPoint("BOTTOMRIGHT", chatrbgdummy2, "BOTTOMRIGHT", 0, DB.Scale(-26))
	
	inforight.shadow:ClearAllPoints()
	inforight.shadow:SetPoint("TOPLEFT", inforightLbutton, "TOPLEFT", DB.Scale(-4), DB.Scale(4))
	inforight.shadow:SetPoint("BOTTOMRIGHT", inforightRbutton, "BOTTOMRIGHT", DB.Scale(4), DB.Scale(-4))

	inforightLbutton.Text = DB.SetFontString(ElvuiInfoRightLButton, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	inforightLbutton.Text:SetText("R")
	inforightLbutton.Text:SetPoint("CENTER")

	inforightRbutton.Text = DB.SetFontString(ElvuiInfoRightRButton, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	inforightRbutton.Text:SetText(">")
	inforightRbutton.Text:SetPoint("CENTER")
	
TukuiInfoLeft = ElvuiInfoLeft -- conversion
TukuiInfoRight = ElvuiInfoRight -- conversion	

-- BATTLEGROUND STATS FRAME
local shownbg = true
if C["datatext"].battleground == true then
	infoleft:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			DB.SlideOut(ElvuiInfoBattleGroundL) 
			DB.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			DB.SlideIn(ElvuiInfoBattleGroundL) 
			DB.SlideIn(ElvuiInfoBattleGroundR) 
			shownbg = true 
		end 
	end)
	infoleft:RegisterEvent("PLAYER_ENTERING_WORLD")
	infoleft:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	infoleft:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			if not InCombatLockdown() then
				infoleft:EnableMouse(true)
				ElvuiInfoBattleGroundL:Show()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			if not InCombatLockdown() then
				infoleft:EnableMouse(false)
				ElvuiInfoBattleGroundL:Hide()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
		shownbg = true
	end)

	inforight:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			DB.SlideOut(ElvuiInfoBattleGroundL) 
			DB.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			DB.SlideIn(ElvuiInfoBattleGroundL) 
			DB.SlideIn(ElvuiInfoBattleGroundR) 
			shownbg = true 
		end 
	end)
	inforight:RegisterEvent("PLAYER_ENTERING_WORLD")
	inforight:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	inforight:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			if not InCombatLockdown() then
				inforight:EnableMouse(true)
				ElvuiInfoBattleGroundR:Show()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			if not InCombatLockdown() then
				inforight:EnableMouse(false)
				ElvuiInfoBattleGroundR:Hide()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
		shownbg = true
	end)


	local bgframeL = CreateFrame("Frame", "ElvuiInfoBattleGroundL", UIParent)
	DB.CreatePanel(bgframeL, 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframeL:SetAllPoints(ElvuiInfoLeft)
	bgframeL:SetFrameLevel(ElvuiInfoLeft:GetFrameLevel() + 1)
	DB.SetNormTexTemplate(bgframeL)
	bgframeL:SetFrameStrata("HIGH")
	bgframeL:SetScript("OnEnter", function(self)
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if name then
				if name == DB.myname then
					local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
					local classcolor = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:AddDoubleLine(L.datatext_ttstatsfor, classcolor..name.."|r")
					GameTooltip:AddLine' '
					--Add extra statistics to watch based on what BG you are in.
					if GetRealZoneText() == "Arathi Basin" then --
						GameTooltip:AddDoubleLine(L.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Warsong Gulch" then --
						GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_flagsreturned,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Eye of the Storm" then --
						GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
					elseif GetRealZoneText() == "Alterac Valley" then
						GameTooltip:AddDoubleLine(L.datatext_graveyardsassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_graveyardsdefended,GetBattlefieldStatData(i, 2),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_towersassaulted,GetBattlefieldStatData(i, 3),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_towersdefended,GetBattlefieldStatData(i, 4),1,1,1)
					elseif GetRealZoneText() == "Strand of the Ancients" then
						GameTooltip:AddDoubleLine(L.datatext_demolishersdestroyed,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_gatesdestroyed,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Isle of Conquest" then
						GameTooltip:AddDoubleLine(L.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					end			
					GameTooltip:Show()
				end
			end
		end
	end) 
	
	local bgframeR = CreateFrame("Frame", "ElvuiInfoBattleGroundR", UIParent)
	DB.CreatePanel(bgframeR, 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	DB.SetNormTexTemplate(bgframeR)
	bgframeR:SetAllPoints(ElvuiInfoRight)
	bgframeR:SetFrameLevel(ElvuiInfoRight:GetFrameLevel() + 1)
	bgframeR:SetFrameStrata("HIGH")
	bgframeR:SetScript("OnEnter", function(self)
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if name then
				if name == DB.myname then
					local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
					local classcolor = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:AddDoubleLine(L.datatext_ttstatsfor, classcolor..name.."|r")
					GameTooltip:AddLine' '
					--Add extra statistics to watch based on what BG you are in.
					if GetRealZoneText() == "Arathi Basin" then --
						GameTooltip:AddDoubleLine(L.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Warsong Gulch" then --
						GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_flagsreturned,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Eye of the Storm" then --
						GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
					elseif GetRealZoneText() == "Alterac Valley" then
						GameTooltip:AddDoubleLine(L.datatext_graveyardsassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_graveyardsdefended,GetBattlefieldStatData(i, 2),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_towersassaulted,GetBattlefieldStatData(i, 3),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_towersdefended,GetBattlefieldStatData(i, 4),1,1,1)
					elseif GetRealZoneText() == "Strand of the Ancients" then
						GameTooltip:AddDoubleLine(L.datatext_demolishersdestroyed,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_gatesdestroyed,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Isle of Conquest" then
						GameTooltip:AddDoubleLine(L.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					end			
					GameTooltip:Show()
				end
			end
		end
	end)
	
	DB.AnimGroup(ElvuiInfoBattleGroundL, 0, DB.Scale(-150), 0.4)
	DB.AnimGroup(ElvuiInfoBattleGroundR, 0, DB.Scale(-150), 0.4)

	bgframeL:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			DB.SlideOut(ElvuiInfoBattleGroundL) 
			DB.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			DB.SlideIn(ElvuiInfoBattleGroundL) 
			DB.SlideIn(ElvuiInfoBattleGroundR) 
			shownbg = true 
		end 
	end)
	bgframeL:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	bgframeL:RegisterEvent("PLAYER_ENTERING_WORLD")
	bgframeL:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	bgframeL:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			if not InCombatLockdown() then
				ElvuiInfoBattleGroundL:Show()
				ElvuiInfoLeft:EnableMouse(true)
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			if not InCombatLockdown() then
				ElvuiInfoBattleGroundL:Hide()
				ElvuiInfoLeft:EnableMouse(false)
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
		shownbg = true
	end)
	
	bgframeR:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			DB.SlideOut(ElvuiInfoBattleGroundL) 
			DB.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			DB.SlideIn(ElvuiInfoBattleGroundL) 
			DB.SlideIn(ElvuiInfoBattleGroundR) 
			shownbg = true 
		end 
	end)
	bgframeR:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	bgframeR:RegisterEvent("PLAYER_ENTERING_WORLD")
	bgframeR:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	bgframeR:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			if not InCombatLockdown() then
				ElvuiInfoBattleGroundR:Show()
				ElvuiInfoRight:EnableMouse(true)
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			if not InCombatLockdown() then
				ElvuiInfoBattleGroundR:Hide()
				ElvuiInfoRight:EnableMouse(false)
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
		shownbg = true
	end)
end

--Mover buttons uses this
function PositionAllPanels()
	ElvuiActionBarBackground:ClearAllPoints()
	ElvuiPetActionBarBackground:ClearAllPoints()
	ElvuiLineToPetActionBarBackground:ClearAllPoints()
	
	if C["actionbar"].bottompetbar ~= true then
		ElvuiActionBarBackground:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, DB.Scale(4))
		if C["actionbar"].rightbars > 0 then
			ElvuiPetActionBarBackground:SetPoint("RIGHT", ElvuiActionBarBackgroundRight, "LEFT", DB.Scale(-6), 0)
		else
			ElvuiPetActionBarBackground:SetPoint("RIGHT", UIParent, "RIGHT", DB.Scale(-6), DB.Scale(-13.5))
		end
		ElvuiPetActionBarBackground:SetSize(DB.petbuttonsize + (DB.petbuttonspacing * 2), (DB.petbuttonsize * 10) + (DB.petbuttonspacing * 11))
		ElvuiLineToPetActionBarBackground:SetSize(30, 265)
		ElvuiLineToPetActionBarBackground:SetPoint("LEFT", ElvuiPetActionBarBackground, "RIGHT", 0, 0)
	else
		ElvuiActionBarBackground:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, (DB.buttonsize + (DB.buttonspacing * 2)) + DB.Scale(8))	
		ElvuiPetActionBarBackground:SetSize((DB.petbuttonsize * 10) + (DB.petbuttonspacing * 11), DB.petbuttonsize + (DB.petbuttonspacing * 2))
		ElvuiPetActionBarBackground:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, DB.Scale(4))
		ElvuiLineToPetActionBarBackground:SetSize(265, 30)
		ElvuiLineToPetActionBarBackground:SetPoint("BOTTOM", ElvuiPetActionBarBackground, "TOP", 0, 0)
	end
	
	if C["actionbar"].bottomrows == 3 then
		ElvuiActionBarBackground:SetHeight((DB.buttonsize * 3) + (DB.buttonspacing * 4))
	elseif C["actionbar"].bottomrows == 2 then
		ElvuiActionBarBackground:SetHeight((DB.buttonsize * 2) + (DB.buttonspacing * 3))
	else
		ElvuiActionBarBackground:SetHeight(DB.buttonsize + (DB.buttonspacing * 2))
	end
	
	--SplitBar
	if C["actionbar"].splitbar == true then
		if C["actionbar"].bottomrows == 3 then
			ElvuiSplitActionBarLeftBackground:SetWidth((DB.buttonsize * 4) + (DB.buttonspacing * 5))
			ElvuiSplitActionBarRightBackground:SetWidth((DB.buttonsize * 4) + (DB.buttonspacing * 5))
		else
			ElvuiSplitActionBarLeftBackground:SetWidth((DB.buttonsize * 3) + (DB.buttonspacing * 4))
			ElvuiSplitActionBarRightBackground:SetWidth((DB.buttonsize * 3) + (DB.buttonspacing * 4))	
		end
		ElvuiSplitActionBarLeftBackground:Show()
		ElvuiSplitActionBarRightBackground:Show()
		ElvuiSplitActionBarLeftBackground:SetHeight(ElvuiActionBarBackground:GetHeight())
		ElvuiSplitActionBarRightBackground:SetHeight(ElvuiActionBarBackground:GetHeight())
	else
		ElvuiSplitActionBarLeftBackground:Hide()
		ElvuiSplitActionBarRightBackground:Hide()	
	end
	
	--RightBar
	ElvuiActionBarBackgroundRight:Show()
	if C["actionbar"].rightbars == 1 then
		ElvuiActionBarBackgroundRight:SetWidth(DB.buttonsize + (DB.buttonspacing * 2))
	elseif C["actionbar"].rightbars == 2 then
		ElvuiActionBarBackgroundRight:SetWidth((DB.buttonsize * 2) + (DB.buttonspacing * 3))
	elseif C["actionbar"].rightbars == 3 then
		ElvuiActionBarBackgroundRight:SetWidth((DB.buttonsize * 3) + (DB.buttonspacing * 4))
	else
		ElvuiActionBarBackgroundRight:Hide()
	end	
end

--Fixes chat windows not displaying
ChatLBackground.anim_o:HookScript("OnFinished", function()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local point = GetChatWindowSavedPosition(id)
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		chat:SetParent(tab)
	end
end)

ChatLBackground.anim_o:HookScript("OnPlay", function()
	if DB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end		
	end
end)

ChatLBackground.anim:HookScript("OnFinished", function()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local id = chat:GetID()
		local point = GetChatWindowSavedPosition(id)
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		chat:SetParent(UIParent)
		
		if C["chat"].rightchat == true then
			ChatFrame3:SetParent(ChatFrame3Tab)
		end
	end
	ElvuiInfoLeft.shadow:SetBackdropBorderColor(0,0,0,1)
	ElvuiInfoLeft:SetScript("OnUpdate", function() end)
	DB.StopFlash(ElvuiInfoLeft.shadow)
end)

if C["chat"].rightchat == true then
	ChatRBackground.anim_o:HookScript("OnPlay", function()
		ChatFrame3:SetParent(ChatFrame3Tab)
		ChatFrame3:SetFrameStrata("LOW")
	end)

	ChatRBackground.anim:HookScript("OnFinished", function()
		ChatFrame3:SetParent(UIParent)
		ChatFrame3:SetFrameStrata("LOW")
		ElvuiInfoRight.shadow:SetBackdropBorderColor(0,0,0,1)
		ElvuiInfoRight:SetScript("OnUpdate", function() end)
		DB.StopFlash(ElvuiInfoRight.shadow)
	end)
end

--Setup Button Scripts
infoleftLbutton:SetScript("OnMouseDown", function(self, btn)
	if btn == "RightButton" then
		if DB.ChatLIn == true then
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local tab = _G[format("ChatFrame%sTab", i)]
				chat:SetParent(tab)
			end
			DB.ToggleSlideChatR()
			DB.ToggleSlideChatL()
		else
			DB.ToggleSlideChatR()
			DB.ToggleSlideChatL()
		end	
	else
		if DB.ChatLIn == true then
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local tab = _G[format("ChatFrame%sTab", i)]
				chat:SetParent(tab)
			end
			DB.ToggleSlideChatL()
		else
			DB.ToggleSlideChatL()
		end		
	end
end)

inforightRbutton:SetScript("OnMouseDown", function(self, btn)
	if C["chat"].rightchat ~= true then self:EnableMouse(false) return end
	if btn == "RightButton" then
		DB.ToggleSlideChatR()
		DB.ToggleSlideChatL()
	else
		DB.ToggleSlideChatR()
	end
end)

--Toggle UI lock button
ElvuiInfoLeftRButton:SetScript("OnMouseDown", function(self)
	if InCombatLockdown() then return end
		
	DB.ToggleMovers()
	
	if C["actionbar"].enable == true then
		DB.ToggleABLock()
	end
	
	if ElvuiInfoLeftRButton.hovered == true then
		local locked = false
		GameTooltip:ClearLines()
		for name, _ in pairs(DB.CreatedMovers) do
			if _G[name]:IsShown() then
				locked = true
			else
				locked = false
			end
		end	
		
		if locked ~= true then
			GameTooltip:AddLine(LOCKED,1,1,1)
		else
			GameTooltip:AddLine(UNLOCK,unpack(C["media"].valuecolor))
		end
	end
end)

ElvuiInfoLeftRButton:SetScript("OnEnter", function(self)
	ElvuiInfoLeftRButton.hovered = true
	if InCombatLockdown() then return end
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, DB.Scale(6));
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, DB.mult)
	GameTooltip:ClearLines()
	
	local locked = false
	for name, _ in pairs(DB.CreatedMovers) do
		if _G[name]:IsShown() then
			locked = true
			break
		else
			locked = false
		end
	end	
	
	if locked ~= true then
		GameTooltip:AddLine(LOCKED,1,1,1)
	else
		GameTooltip:AddLine(UNLOCK,unpack(C["media"].valuecolor))
	end
	GameTooltip:Show()
end)

ElvuiInfoLeftRButton:SetScript("OnLeave", function(self)
	ElvuiInfoLeftRButton.hovered = false
	GameTooltip:Hide()
end)