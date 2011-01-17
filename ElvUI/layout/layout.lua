local ElvDB = ElvDB
local ElvCF = ElvCF
local ElvL = ElvL

-- BUTTON SIZES
ElvDB.buttonsize = ElvDB.Scale(ElvCF["actionbar"].buttonsize)
ElvDB.buttonspacing = ElvDB.Scale(ElvCF["actionbar"].buttonspacing)
ElvDB.petbuttonsize = ElvDB.Scale(ElvCF["actionbar"].petbuttonsize)
ElvDB.petbuttonspacing = ElvDB.Scale(ElvCF["actionbar"].petbuttonspacing)

--BOTTOM DUMMY FRAME DOES NOTHING BUT HOLDS FRAME POSITIONS
local bottompanel = CreateFrame("Frame", "ElvuiBottomPanel", UIParent)
bottompanel:SetHeight(23)
bottompanel:SetWidth(UIParent:GetWidth() + (ElvDB.mult * 2))
bottompanel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -ElvDB.mult, -ElvDB.mult)
bottompanel:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", ElvDB.mult, -ElvDB.mult)


local mini = CreateFrame("Frame", "ElvuiMinimap", Minimap)
ElvDB.CreatePanel(mini, ElvDB.Scale(144 + 4), ElvDB.Scale(144 + 4), "CENTER", Minimap, "CENTER", -0, 0)
mini:ClearAllPoints()
mini:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
mini:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
ElvDB.CreateShadow(ElvuiMinimap)
TukuiMinimap = ElvuiMinimap -- conversion

-- MINIMAP STAT FRAMES
if ElvuiMinimap then
	local minimapstatsleft = CreateFrame("Frame", "ElvuiMinimapStatsLeft", ElvuiMinimap)
	ElvDB.CreatePanel(minimapstatsleft, (ElvuiMinimap:GetWidth() / 2) - 2, 19, "TOPLEFT", ElvuiMinimap, "BOTTOMLEFT", 0, ElvDB.Scale(-3))

	local minimapstatsright = CreateFrame("Frame", "ElvuiMinimapStatsRight", ElvuiMinimap)
	ElvDB.CreatePanel(minimapstatsright, (ElvuiMinimap:GetWidth() / 2) -2, 19, "TOPRIGHT", ElvuiMinimap, "BOTTOMRIGHT", 0, ElvDB.Scale(-3))
	ElvDB.SetNormTexTemplate(ElvuiMinimapStatsLeft)
	ElvDB.SetNormTexTemplate(ElvuiMinimapStatsRight)
	ElvDB.CreateShadow(ElvuiMinimapStatsLeft)
	ElvDB.CreateShadow(ElvuiMinimapStatsRight)
	
	TukuiMinimapStatsLeft = ElvuiMinimapStatsLeft -- conversion
	TukuiMinimapStatsRight = ElvuiMinimapStatsRight -- conversion
end

-- MAIN ACTION BAR
local barbg = CreateFrame("Frame", "ElvuiActionBarBackground", UIParent)
if ElvCF["actionbar"].bottompetbar ~= true then
	ElvDB.CreatePanel(barbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, ElvDB.Scale(4))
else
	ElvDB.CreatePanel(barbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, (ElvDB.buttonsize + (ElvDB.buttonspacing * 2)) + ElvDB.Scale(8))
end
barbg:SetWidth(((ElvDB.buttonsize * 12) + (ElvDB.buttonspacing * 13)))
barbg:SetFrameStrata("LOW")
if ElvCF["actionbar"].bottomrows == 3 then
	barbg:SetHeight((ElvDB.buttonsize * 3) + (ElvDB.buttonspacing * 4))
elseif ElvCF["actionbar"].bottomrows == 2 then
	barbg:SetHeight((ElvDB.buttonsize * 2) + (ElvDB.buttonspacing * 3))
else
	barbg:SetHeight(ElvDB.buttonsize + (ElvDB.buttonspacing * 2))
end
ElvDB.CreateShadow(barbg)

if ElvCF["actionbar"].enable ~= true then
	barbg:SetAlpha(0)
end

--SPLIT BAR PANELS
local splitleft = CreateFrame("Frame", "ElvuiSplitActionBarLeftBackground", ElvuiActionBarBackground)
ElvDB.CreatePanel(splitleft, (ElvDB.buttonsize * 3) + (ElvDB.buttonspacing * 4), ElvuiActionBarBackground:GetHeight(), "RIGHT", ElvuiActionBarBackground, "LEFT", ElvDB.Scale(-4), 0)
splitleft:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitleft:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())

local splitright = CreateFrame("Frame", "ElvuiSplitActionBarRightBackground", ElvuiActionBarBackground)
ElvDB.CreatePanel(splitright, (ElvDB.buttonsize * 3) + (ElvDB.buttonspacing * 4), ElvuiActionBarBackground:GetHeight(), "LEFT", ElvuiActionBarBackground, "RIGHT", ElvDB.Scale(4), 0)
splitright:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitright:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())

if ElvCF["actionbar"].bottomrows == 3 then
	splitleft:SetWidth((ElvDB.buttonsize * 4) + (ElvDB.buttonspacing * 5))
	splitright:SetWidth((ElvDB.buttonsize * 4) + (ElvDB.buttonspacing * 5))
end

ElvDB.CreateShadow(splitleft)
ElvDB.CreateShadow(splitright)


if ElvCF["actionbar"].splitbar ~= true then
	ElvuiSplitActionBarLeftBackground:Hide()
	ElvuiSplitActionBarRightBackground:Hide()
end

-- RIGHT BAR
if ElvCF["actionbar"].enable == true then
	local barbgr = CreateFrame("Frame", "ElvuiActionBarBackgroundRight", ElvuiActionBarBackground)
	ElvDB.CreatePanel(barbgr, 1, (ElvDB.buttonsize * 12) + (ElvDB.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", ElvDB.Scale(-4), ElvDB.Scale(-8))
	if ElvCF["actionbar"].rightbars == 1 then
		barbgr:SetWidth(ElvDB.buttonsize + (ElvDB.buttonspacing * 2))
	elseif ElvCF["actionbar"].rightbars == 2 then
		barbgr:SetWidth((ElvDB.buttonsize * 2) + (ElvDB.buttonspacing * 3))
	elseif ElvCF["actionbar"].rightbars == 3 then
		barbgr:SetWidth((ElvDB.buttonsize * 3) + (ElvDB.buttonspacing * 4))
	else
		barbgr:Hide()
	end
	ElvDB.AnimGroup(ElvuiActionBarBackgroundRight, ElvDB.Scale(350), 0, 0.4)

	local petbg = CreateFrame("Frame", "ElvuiPetActionBarBackground", UIParent)
	if ElvCF["actionbar"].bottompetbar ~= true then
		if ElvCF["actionbar"].rightbars > 0 then
			ElvDB.CreatePanel(petbg, ElvDB.petbuttonsize + (ElvDB.petbuttonspacing * 2), (ElvDB.petbuttonsize * 10) + (ElvDB.petbuttonspacing * 11), "RIGHT", barbgr, "LEFT", ElvDB.Scale(-6), 0)
		else
			ElvDB.CreatePanel(petbg, ElvDB.petbuttonsize + (ElvDB.petbuttonspacing * 2), (ElvDB.petbuttonsize * 10) + (ElvDB.petbuttonspacing * 11), "RIGHT", UIParent, "RIGHT", ElvDB.Scale(-6), ElvDB.Scale(-13.5))
		end
	else
		ElvDB.CreatePanel(petbg, (ElvDB.petbuttonsize * 10) + (ElvDB.petbuttonspacing * 11), ElvDB.petbuttonsize + (ElvDB.petbuttonspacing * 2), "BOTTOM", UIParent, "BOTTOM", 0, ElvDB.Scale(4))
	end
	
	local ltpetbg = CreateFrame("Frame", "ElvuiLineToPetActionBarBackground", petbg)
	if ElvCF["actionbar"].bottompetbar ~= true then
		ElvDB.CreatePanel(ltpetbg, 30, 265, "LEFT", petbg, "RIGHT", 0, 0)
	else
		ElvDB.CreatePanel(ltpetbg, 265, 30, "BOTTOM", petbg, "TOP", 0, 0)
	end
	
	ltpetbg:SetScript("OnShow", function(self)
		self:SetFrameStrata("BACKGROUND")
		self:SetFrameLevel(0)
	end)

	
	ElvDB.CreateShadow(barbgr)
	ElvDB.CreateShadow(petbg)
end

-- VEHICLE BAR
if ElvCF["actionbar"].enable == true then
	local vbarbg = CreateFrame("Frame", "ElvuiVehicleBarBackground", UIParent)
	ElvDB.CreatePanel(vbarbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, ElvDB.Scale(4))
	vbarbg:SetWidth(((ElvDB.buttonsize * 11) + (ElvDB.buttonspacing * 12))*1.2)
	vbarbg:SetHeight((ElvDB.buttonsize + (ElvDB.buttonspacing * 2))*1.2)
	ElvDB.CreateShadow(vbarbg)
end

-- CHAT BACKGROUND LEFT (MOVES)
local chatlbgdummy = CreateFrame("Frame", "ChatLBackground", UIParent)
chatlbgdummy:SetWidth(ElvCF["chat"].chatwidth)
chatlbgdummy:SetHeight(ElvCF["chat"].chatheight+6)
chatlbgdummy:SetPoint("BOTTOMLEFT", ElvuiBottomPanel, "TOPLEFT", ElvDB.Scale(4),  ElvDB.Scale(7))

-- CHAT BACKGROUND LEFT (DOESN'T MOVE THIS IS WHAT WE ATTACH FRAMES TO)
local chatlbgdummy2 = CreateFrame("Frame", "ChatLBackground2", UIParent)
chatlbgdummy2:SetWidth(ElvCF["chat"].chatwidth)
chatlbgdummy2:SetHeight(ElvCF["chat"].chatheight+6)
chatlbgdummy2:SetPoint("BOTTOMLEFT", ElvuiBottomPanel, "TOPLEFT", ElvDB.Scale(4),  ElvDB.Scale(7))

-- CHAT BACKGROUND RIGHT (MOVES)
local chatrbgdummy = CreateFrame("Frame", "ChatRBackground", UIParent)
chatrbgdummy:SetWidth(ElvCF["chat"].chatwidth)
chatrbgdummy:SetHeight(ElvCF["chat"].chatheight+6)
chatrbgdummy:SetPoint("BOTTOMRIGHT", ElvuiBottomPanel, "TOPRIGHT", ElvDB.Scale(-4),  ElvDB.Scale(7))

-- CHAT BACKGROUND RIGHT (DOESN'T MOVE THIS IS WHAT WE ATTACH FRAMES TO)
local chatrbgdummy2 = CreateFrame("Frame", "ChatRBackground2", UIParent)
chatrbgdummy2:SetWidth(ElvCF["chat"].chatwidth)
chatrbgdummy2:SetHeight(ElvCF["chat"].chatheight+6)
chatrbgdummy2:SetPoint("BOTTOMRIGHT", ElvuiBottomPanel, "TOPRIGHT", ElvDB.Scale(-4),  ElvDB.Scale(7))

ElvDB.AnimGroup(ChatLBackground, ElvDB.Scale(-375), 0, 0.4)
ElvDB.AnimGroup(ChatRBackground, ElvDB.Scale(375), 0, 0.4)

ElvDB.ChatRightShown = false
if ElvCF["chat"].showbackdrop == true then
	local chatlbg = CreateFrame("Frame", nil, ChatLBackground)
	ElvDB.SetTransparentTemplate(chatlbg)
	chatlbg:SetAllPoints(chatlbgdummy)
	chatlbg:SetFrameStrata("BACKGROUND")
	
	local chatltbg = CreateFrame("Frame", nil, chatlbg)
	ElvDB.SetNormTexTemplate(chatltbg)
	chatltbg:SetPoint("BOTTOMLEFT", chatlbg, "TOPLEFT", 0, ElvDB.Scale(3))
	chatltbg:SetPoint("BOTTOMRIGHT", chatlbg, "TOPRIGHT", ElvDB.Scale(-24), ElvDB.Scale(3))
	chatltbg:SetHeight(ElvDB.Scale(22))
	chatltbg:SetFrameStrata("BACKGROUND")
	
	ElvDB.CreateShadow(chatlbg)
	ElvDB.CreateShadow(chatltbg)
end

if ElvCF["chat"].showbackdrop == true then
	local chatrbg = CreateFrame("Frame", "ChatRBG", ChatRBackground)
	chatrbg:SetAllPoints(chatrbgdummy)
	ElvDB.SetTransparentTemplate(chatrbg)
	chatrbg:SetFrameStrata("BACKGROUND")
	chatrbg:SetBackdropColor(unpack(ElvCF["media"].backdropfadecolor))
	chatrbg:SetAlpha(0)

	local chatrtbg = CreateFrame("Frame", nil, chatrbg)
	ElvDB.SetNormTexTemplate(chatrtbg)
	chatrtbg:SetPoint("BOTTOMLEFT", chatrbg, "TOPLEFT", 0, ElvDB.Scale(3))
	chatrtbg:SetPoint("BOTTOMRIGHT", chatrbg, "TOPRIGHT", ElvDB.Scale(-24), ElvDB.Scale(3))
	chatrtbg:SetHeight(ElvDB.Scale(22))
	chatrtbg:SetFrameStrata("BACKGROUND")
	ElvDB.CreateShadow(chatrbg)
	ElvDB.CreateShadow(chatrtbg)
end

--INFO LEFT
local infoleft = CreateFrame("Frame", "ElvuiInfoLeft", UIParent)
infoleft:SetFrameLevel(2)
ElvDB.SetNormTexTemplate(infoleft)
ElvDB.CreateShadow(infoleft)
infoleft:SetPoint("TOPLEFT", chatlbgdummy2, "BOTTOMLEFT", ElvDB.Scale(17), ElvDB.Scale(-4))
infoleft:SetPoint("BOTTOMRIGHT", chatlbgdummy2, "BOTTOMRIGHT", ElvDB.Scale(-17), ElvDB.Scale(-26))

	--INFOLEFT L BUTTON
	local infoleftLbutton = CreateFrame("Button", "ElvuiInfoLeftLButton", ElvuiInfoLeft)
	ElvDB.SetNormTexTemplate(infoleftLbutton)
	infoleftLbutton:SetPoint("TOPRIGHT", infoleft, "TOPLEFT", ElvDB.Scale(-2), 0)
	infoleftLbutton:SetPoint("BOTTOMLEFT", chatlbgdummy2, "BOTTOMLEFT", 0, ElvDB.Scale(-26))

	--INFOLEFT R BUTTON
	local infoleftRbutton = CreateFrame("Button", "ElvuiInfoLeftRButton", ElvuiInfoLeft)
	ElvDB.SetNormTexTemplate(infoleftRbutton)
	infoleftRbutton:SetPoint("TOPLEFT", infoleft, "TOPRIGHT", ElvDB.Scale(2), 0)
	infoleftRbutton:SetPoint("BOTTOMRIGHT", chatlbgdummy2, "BOTTOMRIGHT", 0, ElvDB.Scale(-26))
	
	infoleft.shadow:ClearAllPoints()
	infoleft.shadow:SetPoint("TOPLEFT", infoleftLbutton, "TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(4))
	infoleft.shadow:SetPoint("BOTTOMRIGHT", infoleftRbutton, "BOTTOMRIGHT", ElvDB.Scale(4), ElvDB.Scale(-4))

	infoleftLbutton.Text = ElvDB.SetFontString(ElvuiInfoLeftLButton, ElvCF["media"].font, ElvCF["general"].fontscale, "THINOUTLINE")
	infoleftLbutton.Text:SetText("<")
	infoleftLbutton.Text:SetPoint("CENTER")

	infoleftRbutton.Text = ElvDB.SetFontString(ElvuiInfoLeftRButton, ElvCF["media"].font, ElvCF["general"].fontscale, "THINOUTLINE")
	infoleftRbutton.Text:SetText("L")
	infoleftRbutton.Text:SetPoint("CENTER")

--INFO RIGHT
local inforight = CreateFrame("Frame", "ElvuiInfoRight", UIParent)
ElvDB.SetNormTexTemplate(inforight)
infoleft:SetFrameLevel(2)
ElvDB.CreateShadow(inforight)
inforight:SetPoint("TOPLEFT", chatrbgdummy2, "BOTTOMLEFT", ElvDB.Scale(17), ElvDB.Scale(-4))
inforight:SetPoint("BOTTOMRIGHT", chatrbgdummy2, "BOTTOMRIGHT", ElvDB.Scale(-17), ElvDB.Scale(-26))

	--INFORIGHT L BUTTON
	local inforightLbutton = CreateFrame("Button", "ElvuiInfoRightLButton", ElvuiInfoRight)
	ElvDB.SetNormTexTemplate(inforightLbutton)
	inforightLbutton:SetPoint("TOPRIGHT", inforight, "TOPLEFT", ElvDB.Scale(-2), 0)
	inforightLbutton:SetPoint("BOTTOMLEFT", chatrbgdummy2, "BOTTOMLEFT", 0, ElvDB.Scale(-26))

	--INFORIGHT R BUTTON
	local inforightRbutton = CreateFrame("Button", "ElvuiInfoRightRButton", ElvuiInfoRight)
	ElvDB.SetNormTexTemplate(inforightRbutton)
	inforightRbutton:SetPoint("TOPLEFT", inforight, "TOPRIGHT", ElvDB.Scale(2), 0)
	inforightRbutton:SetPoint("BOTTOMRIGHT", chatrbgdummy2, "BOTTOMRIGHT", 0, ElvDB.Scale(-26))
	
	inforight.shadow:ClearAllPoints()
	inforight.shadow:SetPoint("TOPLEFT", inforightLbutton, "TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(4))
	inforight.shadow:SetPoint("BOTTOMRIGHT", inforightRbutton, "BOTTOMRIGHT", ElvDB.Scale(4), ElvDB.Scale(-4))

	inforightLbutton.Text = ElvDB.SetFontString(ElvuiInfoRightLButton, ElvCF["media"].font, ElvCF["general"].fontscale, "THINOUTLINE")
	inforightLbutton.Text:SetText("R")
	inforightLbutton.Text:SetPoint("CENTER")

	inforightRbutton.Text = ElvDB.SetFontString(ElvuiInfoRightRButton, ElvCF["media"].font, ElvCF["general"].fontscale, "THINOUTLINE")
	inforightRbutton.Text:SetText(">")
	inforightRbutton.Text:SetPoint("CENTER")
	
TukuiInfoLeft = ElvuiInfoLeft -- conversion
TukuiInfoRight = ElvuiInfoRight -- conversion	

-- BATTLEGROUND STATS FRAME
local shownbg = true
if ElvCF["datatext"].battleground == true then
	infoleft:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			ElvDB.SlideOut(ElvuiInfoBattleGroundL) 
			ElvDB.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			ElvDB.SlideIn(ElvuiInfoBattleGroundL) 
			ElvDB.SlideIn(ElvuiInfoBattleGroundR) 
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
			ElvDB.SlideOut(ElvuiInfoBattleGroundL) 
			ElvDB.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			ElvDB.SlideIn(ElvuiInfoBattleGroundL) 
			ElvDB.SlideIn(ElvuiInfoBattleGroundR) 
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
	ElvDB.CreatePanel(bgframeL, 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframeL:SetAllPoints(ElvuiInfoLeft)
	bgframeL:SetFrameLevel(ElvuiInfoLeft:GetFrameLevel() + 1)
	ElvDB.SetNormTexTemplate(bgframeL)
	bgframeL:SetFrameStrata("HIGH")
	bgframeL:SetScript("OnEnter", function(self)
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if name then
				if name == ElvDB.myname then
					local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
					local classcolor = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:AddDoubleLine(ElvL.datatext_ttstatsfor, classcolor..name.."|r")
					GameTooltip:AddLine' '
					--Add extra statistics to watch based on what BG you are in.
					if GetRealZoneText() == "Arathi Basin" then --
						GameTooltip:AddDoubleLine(ElvL.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Warsong Gulch" then --
						GameTooltip:AddDoubleLine(ElvL.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_flagsreturned,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Eye of the Storm" then --
						GameTooltip:AddDoubleLine(ElvL.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
					elseif GetRealZoneText() == "Alterac Valley" then
						GameTooltip:AddDoubleLine(ElvL.datatext_graveyardsassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_graveyardsdefended,GetBattlefieldStatData(i, 2),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_towersassaulted,GetBattlefieldStatData(i, 3),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_towersdefended,GetBattlefieldStatData(i, 4),1,1,1)
					elseif GetRealZoneText() == "Strand of the Ancients" then
						GameTooltip:AddDoubleLine(ElvL.datatext_demolishersdestroyed,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_gatesdestroyed,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Isle of Conquest" then
						GameTooltip:AddDoubleLine(ElvL.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					end			
					GameTooltip:Show()
				end
			end
		end
	end) 
	
	local bgframeR = CreateFrame("Frame", "ElvuiInfoBattleGroundR", UIParent)
	ElvDB.CreatePanel(bgframeR, 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	ElvDB.SetNormTexTemplate(bgframeR)
	bgframeR:SetAllPoints(ElvuiInfoRight)
	bgframeR:SetFrameLevel(ElvuiInfoRight:GetFrameLevel() + 1)
	bgframeR:SetFrameStrata("HIGH")
	bgframeR:SetScript("OnEnter", function(self)
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if name then
				if name == ElvDB.myname then
					local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
					local classcolor = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:AddDoubleLine(ElvL.datatext_ttstatsfor, classcolor..name.."|r")
					GameTooltip:AddLine' '
					--Add extra statistics to watch based on what BG you are in.
					if GetRealZoneText() == "Arathi Basin" then --
						GameTooltip:AddDoubleLine(ElvL.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Warsong Gulch" then --
						GameTooltip:AddDoubleLine(ElvL.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_flagsreturned,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Eye of the Storm" then --
						GameTooltip:AddDoubleLine(ElvL.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
					elseif GetRealZoneText() == "Alterac Valley" then
						GameTooltip:AddDoubleLine(ElvL.datatext_graveyardsassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_graveyardsdefended,GetBattlefieldStatData(i, 2),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_towersassaulted,GetBattlefieldStatData(i, 3),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_towersdefended,GetBattlefieldStatData(i, 4),1,1,1)
					elseif GetRealZoneText() == "Strand of the Ancients" then
						GameTooltip:AddDoubleLine(ElvL.datatext_demolishersdestroyed,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_gatesdestroyed,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Isle of Conquest" then
						GameTooltip:AddDoubleLine(ElvL.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(ElvL.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					end			
					GameTooltip:Show()
				end
			end
		end
	end)
	
	ElvDB.AnimGroup(ElvuiInfoBattleGroundL, 0, ElvDB.Scale(-150), 0.4)
	ElvDB.AnimGroup(ElvuiInfoBattleGroundR, 0, ElvDB.Scale(-150), 0.4)

	bgframeL:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			ElvDB.SlideOut(ElvuiInfoBattleGroundL) 
			ElvDB.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			ElvDB.SlideIn(ElvuiInfoBattleGroundL) 
			ElvDB.SlideIn(ElvuiInfoBattleGroundR) 
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
			ElvDB.SlideOut(ElvuiInfoBattleGroundL) 
			ElvDB.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			ElvDB.SlideIn(ElvuiInfoBattleGroundL) 
			ElvDB.SlideIn(ElvuiInfoBattleGroundR) 
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
	
	if ElvCF["actionbar"].bottompetbar ~= true then
		ElvuiActionBarBackground:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, ElvDB.Scale(4))
		if ElvCF["actionbar"].rightbars > 0 then
			ElvuiPetActionBarBackground:SetPoint("RIGHT", ElvuiActionBarBackgroundRight, "LEFT", ElvDB.Scale(-6), 0)
		else
			ElvuiPetActionBarBackground:SetPoint("RIGHT", UIParent, "RIGHT", ElvDB.Scale(-6), ElvDB.Scale(-13.5))
		end
		ElvuiPetActionBarBackground:SetSize(ElvDB.petbuttonsize + (ElvDB.petbuttonspacing * 2), (ElvDB.petbuttonsize * 10) + (ElvDB.petbuttonspacing * 11))
		ElvuiLineToPetActionBarBackground:SetSize(30, 265)
		ElvuiLineToPetActionBarBackground:SetPoint("LEFT", ElvuiPetActionBarBackground, "RIGHT", 0, 0)
	else
		ElvuiActionBarBackground:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, (ElvDB.buttonsize + (ElvDB.buttonspacing * 2)) + ElvDB.Scale(8))	
		ElvuiPetActionBarBackground:SetSize((ElvDB.petbuttonsize * 10) + (ElvDB.petbuttonspacing * 11), ElvDB.petbuttonsize + (ElvDB.petbuttonspacing * 2))
		ElvuiPetActionBarBackground:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, ElvDB.Scale(4))
		ElvuiLineToPetActionBarBackground:SetSize(265, 30)
		ElvuiLineToPetActionBarBackground:SetPoint("BOTTOM", ElvuiPetActionBarBackground, "TOP", 0, 0)
	end
	
	if ElvCF["actionbar"].bottomrows == 3 then
		ElvuiActionBarBackground:SetHeight((ElvDB.buttonsize * 3) + (ElvDB.buttonspacing * 4))
	elseif ElvCF["actionbar"].bottomrows == 2 then
		ElvuiActionBarBackground:SetHeight((ElvDB.buttonsize * 2) + (ElvDB.buttonspacing * 3))
	else
		ElvuiActionBarBackground:SetHeight(ElvDB.buttonsize + (ElvDB.buttonspacing * 2))
	end
	
	--SplitBar
	if ElvCF["actionbar"].splitbar == true then
		if ElvCF["actionbar"].bottomrows == 3 then
			ElvuiSplitActionBarLeftBackground:SetWidth((ElvDB.buttonsize * 4) + (ElvDB.buttonspacing * 5))
			ElvuiSplitActionBarRightBackground:SetWidth((ElvDB.buttonsize * 4) + (ElvDB.buttonspacing * 5))
		else
			ElvuiSplitActionBarLeftBackground:SetWidth((ElvDB.buttonsize * 3) + (ElvDB.buttonspacing * 4))
			ElvuiSplitActionBarRightBackground:SetWidth((ElvDB.buttonsize * 3) + (ElvDB.buttonspacing * 4))	
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
	if ElvCF["actionbar"].rightbars == 1 then
		ElvuiActionBarBackgroundRight:SetWidth(ElvDB.buttonsize + (ElvDB.buttonspacing * 2))
	elseif ElvCF["actionbar"].rightbars == 2 then
		ElvuiActionBarBackgroundRight:SetWidth((ElvDB.buttonsize * 2) + (ElvDB.buttonspacing * 3))
	elseif ElvCF["actionbar"].rightbars == 3 then
		ElvuiActionBarBackgroundRight:SetWidth((ElvDB.buttonsize * 3) + (ElvDB.buttonspacing * 4))
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
	if ElvDB.ChatLIn == true then
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
		
		if ElvCF["chat"].rightchat == true then
			ChatFrame3:SetParent(ChatFrame3Tab)
		end
	end
	ElvuiInfoLeft.shadow:SetBackdropBorderColor(0,0,0,1)
	ElvuiInfoLeft:SetScript("OnUpdate", function() end)
	ElvDB.StopFlash(ElvuiInfoLeft.shadow)
end)

if ElvCF["chat"].rightchat == true then
	ChatRBackground.anim_o:HookScript("OnPlay", function()
		ChatFrame3:SetParent(ChatFrame3Tab)
		ChatFrame3:SetFrameStrata("LOW")
	end)

	ChatRBackground.anim:HookScript("OnFinished", function()
		ChatFrame3:SetParent(UIParent)
		ChatFrame3:SetFrameStrata("LOW")
		ElvuiInfoRight.shadow:SetBackdropBorderColor(0,0,0,1)
		ElvuiInfoRight:SetScript("OnUpdate", function() end)
		ElvDB.StopFlash(ElvuiInfoRight.shadow)
	end)
end

--Setup Button Scripts
infoleftLbutton:SetScript("OnMouseDown", function(self, btn)
	if btn == "RightButton" then
		if ElvDB.ChatLIn == true then
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local tab = _G[format("ChatFrame%sTab", i)]
				chat:SetParent(tab)
			end
			ElvDB.ToggleSlideChatR()
			ElvDB.ToggleSlideChatL()
		else
			ElvDB.ToggleSlideChatR()
			ElvDB.ToggleSlideChatL()
		end	
	else
		if ElvDB.ChatLIn == true then
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local tab = _G[format("ChatFrame%sTab", i)]
				chat:SetParent(tab)
			end
			ElvDB.ToggleSlideChatL()
		else
			ElvDB.ToggleSlideChatL()
		end		
	end
end)

inforightRbutton:SetScript("OnMouseDown", function(self, btn)
	if ElvCF["chat"].rightchat ~= true then self:EnableMouse(false) return end
	if btn == "RightButton" then
		ElvDB.ToggleSlideChatR()
		ElvDB.ToggleSlideChatL()
	else
		ElvDB.ToggleSlideChatR()
	end
end)