-- BUTTON SIZES
TukuiDB.buttonsize = TukuiDB.Scale(TukuiCF["actionbar"].buttonsize)
TukuiDB.buttonspacing = TukuiDB.Scale(TukuiCF["actionbar"].buttonspacing)
TukuiDB.petbuttonsize = TukuiDB.Scale(TukuiCF["actionbar"].petbuttonsize)
TukuiDB.petbuttonspacing = TukuiDB.Scale(TukuiCF["actionbar"].petbuttonspacing)

--BOTTOM FRAME (For Stats)
local bottompanel = CreateFrame("Frame", "TukuiBottomPanel", UIParent)
TukuiDB.CreatePanel(bottompanel, UIParent:GetWidth() + (TukuiDB.mult * 2), 23, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", -TukuiDB.mult, -TukuiDB.mult)
bottompanel:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", TukuiDB.mult, -TukuiDB.mult)
bottompanel:SetFrameLevel(1)
TukuiDB.CreateShadow(bottompanel)

--Battleground Support for Bottom Frame
if TukuiCF["datatext"].battleground == true then
	bottompanel:SetScript("OnMouseDown", function(self) ToggleFrame(TukuiInfoBattleGround) end)
	bottompanel:RegisterEvent("PLAYER_ENTERING_WORLD")
	bottompanel:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	bottompanel:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			if not InCombatLockdown() then
				TukuiBottomPanel:EnableMouse(true)
				TukuiInfoBattleGround:Show()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			if not InCombatLockdown() then
				TukuiBottomPanel:EnableMouse(false)
				TukuiInfoBattleGround:Hide()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
	end)
end

-- MINIMAP STAT FRAMES
if TukuiMinimap then
	local minimapstatsleft = CreateFrame("Frame", "TukuiMinimapStatsLeft", TukuiMinimap)
	TukuiDB.CreatePanel(minimapstatsleft, (TukuiMinimap:GetWidth() / 2) - 2, 19, "TOPLEFT", TukuiMinimap, "BOTTOMLEFT", 0, TukuiDB.Scale(-3))

	local minimapstatsright = CreateFrame("Frame", "TukuiMinimapStatsRight", TukuiMinimap)
	TukuiDB.CreatePanel(minimapstatsright, (TukuiMinimap:GetWidth() / 2) -2, 19, "TOPRIGHT", TukuiMinimap, "BOTTOMRIGHT", 0, TukuiDB.Scale(-3))
end

-- MAIN ACTION BAR
local barbg = CreateFrame("Frame", "TukuiActionBarBackground", UIParent)
if TukuiCF["actionbar"].bottompetbar ~= true then
	TukuiDB.CreatePanel(barbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(4))
else
	TukuiDB.CreatePanel(barbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, (TukuiDB.buttonsize + (TukuiDB.buttonspacing * 2)) + TukuiDB.Scale(8))
end
barbg:SetWidth(((TukuiDB.buttonsize * 12) + (TukuiDB.buttonspacing * 13)))
barbg:SetFrameLevel(bottompanel:GetFrameLevel() + 2)
barbg:SetFrameStrata("LOW")
if TukuiCF["actionbar"].bottomrows == 3 then
	barbg:SetHeight((TukuiDB.buttonsize * 3) + (TukuiDB.buttonspacing * 4))
elseif TukuiCF["actionbar"].bottomrows == 2 then
	barbg:SetHeight((TukuiDB.buttonsize * 2) + (TukuiDB.buttonspacing * 3))
else
	barbg:SetHeight(TukuiDB.buttonsize + (TukuiDB.buttonspacing * 2))
end
TukuiDB.CreateShadow(barbg)
barbg.shadow:SetFrameStrata("BACKGROUND")
barbg.shadow:SetFrameLevel(bottompanel:GetFrameLevel()-1)

-- VEHICLE BAR
local vbarbg = CreateFrame("Frame", "TukuiVehicleBarBackground", UIParent)
TukuiDB.CreatePanel(vbarbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(4))
vbarbg:SetWidth(((TukuiDB.buttonsize * 11) + (TukuiDB.buttonspacing * 12))*1.2)
vbarbg:SetHeight((TukuiDB.buttonsize + (TukuiDB.buttonspacing * 2))*1.2)
vbarbg:SetFrameLevel(bottompanel:GetFrameLevel() + 2)
vbarbg:SetFrameStrata("LOW")
TukuiDB.CreateShadow(vbarbg)
vbarbg.shadow:SetFrameStrata("BACKGROUND")
vbarbg.shadow:SetFrameLevel(bottompanel:GetFrameLevel()-1)


--SPLIT BAR PANELS
if TukuiCF["actionbar"].splitbar == true then
	local splitleft = CreateFrame("Frame", "TukuiSplitActionBarLeftBackground", TukuiActionBarBackground)
	TukuiDB.CreatePanel(splitleft, (TukuiDB.buttonsize * 3) + (TukuiDB.buttonspacing * 4), TukuiActionBarBackground:GetHeight(), "RIGHT", TukuiActionBarBackground, "LEFT", TukuiDB.Scale(-4), 0)
	splitleft:SetFrameLevel(TukuiActionBarBackground:GetFrameLevel())
	splitleft:SetFrameStrata(TukuiActionBarBackground:GetFrameStrata())
	
	local splitright = CreateFrame("Frame", "TukuiSplitActionBarRightBackground", TukuiActionBarBackground)
	TukuiDB.CreatePanel(splitright, (TukuiDB.buttonsize * 3) + (TukuiDB.buttonspacing * 4), TukuiActionBarBackground:GetHeight(), "LEFT", TukuiActionBarBackground, "RIGHT", TukuiDB.Scale(4), 0)
	splitright:SetFrameLevel(TukuiActionBarBackground:GetFrameLevel())
	splitright:SetFrameStrata(TukuiActionBarBackground:GetFrameStrata())
	
	TukuiDB.CreateShadow(splitleft)
	splitleft.shadow:SetFrameStrata("BACKGROUND")
	splitleft.shadow:SetFrameLevel(bottompanel:GetFrameLevel()-1)
	
	TukuiDB.CreateShadow(splitright)
	splitright.shadow:SetFrameStrata("BACKGROUND")
	splitright.shadow:SetFrameLevel(bottompanel:GetFrameLevel()-1)
end

-- RIGHT BAR
if TukuiCF["actionbar"].enable == true then
	local barbgr = CreateFrame("Frame", "TukuiActionBarBackgroundRight", TukuiActionBarBackground)
	TukuiDB.CreatePanel(barbgr, 1, (TukuiDB.buttonsize * 12) + (TukuiDB.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(-8))
	if TukuiCF["actionbar"].rightbars == 1 then
		barbgr:SetWidth(TukuiDB.buttonsize + (TukuiDB.buttonspacing * 2))
	elseif TukuiCF["actionbar"].rightbars == 2 then
		barbgr:SetWidth((TukuiDB.buttonsize * 2) + (TukuiDB.buttonspacing * 3))
	elseif TukuiCF["actionbar"].rightbars == 3 then
		barbgr:SetWidth((TukuiDB.buttonsize * 3) + (TukuiDB.buttonspacing * 4))
	else
		barbgr:Hide()
	end

	local petbg = CreateFrame("Frame", "TukuiPetActionBarBackground", UIParent)
	if TukuiCF["actionbar"].bottompetbar ~= true then
		if TukuiCF["actionbar"].rightbars > 0 then
			TukuiDB.CreatePanel(petbg, TukuiDB.petbuttonsize + (TukuiDB.petbuttonspacing * 2), (TukuiDB.petbuttonsize * 10) + (TukuiDB.petbuttonspacing * 11), "RIGHT", barbgr, "LEFT", TukuiDB.Scale(-6), 0)
		else
			TukuiDB.CreatePanel(petbg, TukuiDB.petbuttonsize + (TukuiDB.petbuttonspacing * 2), (TukuiDB.petbuttonsize * 10) + (TukuiDB.petbuttonspacing * 11), "RIGHT", UIParent, "RIGHT", TukuiDB.Scale(-6), TukuiDB.Scale(-13.5))
		end
	else
		TukuiDB.CreatePanel(petbg, (TukuiDB.petbuttonsize * 10) + (TukuiDB.petbuttonspacing * 11), TukuiDB.petbuttonsize + (TukuiDB.petbuttonspacing * 2), "BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(4))
		petbg:SetFrameLevel(bottompanel:GetFrameLevel() + 2)
		petbg:SetFrameStrata("LOW")
	end
	
	local ltpetbg1 = CreateFrame("Frame", "TukuiLineToPetActionBarBackground", petbg)
	if TukuiCF["actionbar"].bottompetbar ~= true then
		TukuiDB.CreatePanel(ltpetbg1, 30, 265, "LEFT", petbg, "RIGHT", 0, 0)
	else
		TukuiDB.CreatePanel(ltpetbg1, 265, 30, "BOTTOM", petbg, "TOP", 0, 0)
	end
	ltpetbg1:SetFrameLevel(0)
	ltpetbg1:SetAlpha(.8)
	
	TukuiDB.CreateShadow(barbgr)
	barbgr.shadow:SetFrameStrata("BACKGROUND")
	barbgr.shadow:SetFrameLevel(bottompanel:GetFrameLevel()-1)
	
	TukuiDB.CreateShadow(petbg)
	petbg.shadow:SetFrameStrata("BACKGROUND")
	petbg.shadow:SetFrameLevel(bottompanel:GetFrameLevel()-1)
end

-- CHAT BACKGROUND LEFT
local chatlbgdummy = CreateFrame("Frame", "ChatLBackground", UIParent)
chatlbgdummy:SetWidth(TukuiCF["chat"].chatwidth)
chatlbgdummy:SetHeight(TukuiCF["chat"].chatheight+6)
chatlbgdummy:SetPoint("BOTTOMLEFT", TukuiBottomPanel, "TOPLEFT", TukuiDB.Scale(4),  TukuiDB.Scale(4))

--Create Template frame for addon embedding
local rdummyframe = CreateFrame("Frame", "RDummyFrame", UIParent)
rdummyframe:SetWidth(TukuiCF["chat"].chatwidth)
rdummyframe:SetHeight(TukuiCF["chat"].chatheight+6)
rdummyframe:SetPoint("BOTTOMRIGHT", TukuiBottomPanel, "TOPRIGHT", TukuiDB.Scale(-4),  TukuiDB.Scale(4))

TukuiDB.ChatRightShown = false
if TukuiCF["chat"].showbackdrop == true then
	local chatlbg = CreateFrame("Frame", nil, GeneralDockManager)
	TukuiDB.SetTransparentTemplate(chatlbg)
	chatlbg:SetAllPoints(chatlbgdummy)
	chatlbg:SetFrameStrata("BACKGROUND")
	
	local chatltbg = CreateFrame("Frame", nil, chatlbg)
	TukuiDB.SetTransparentTemplate(chatltbg)
	chatltbg:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	chatltbg:SetPoint("BOTTOMLEFT", chatlbg, "TOPLEFT", 0, TukuiDB.Scale(3))
	chatltbg:SetPoint("BOTTOMRIGHT", chatlbg, "TOPRIGHT", TukuiDB.Scale(-24), TukuiDB.Scale(3))
	chatltbg:SetHeight(TukuiDB.Scale(22))
	chatltbg:SetFrameStrata("BACKGROUND")
	
	TukuiDB.CreateShadow(chatlbg)
	TukuiDB.CreateShadow(chatltbg)
end

--This was requested a lot.. and probably is a better way to do this but whatever this will work.
local chatrbg = CreateFrame("Frame", "ChatRBG", GeneralDockManager)
chatrbg:SetAllPoints(rdummyframe)
TukuiDB.SetTransparentTemplate(chatrbg)
chatrbg:SetFrameStrata("BACKGROUND")
chatrbg:SetBackdropColor(unpack(TukuiCF["media"].backdropfadecolor))
chatrbg:SetAlpha(0)

local chatrtbg = CreateFrame("Frame", nil, chatrbg)
TukuiDB.SetTransparentTemplate(chatrtbg)
chatrtbg:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
chatrtbg:SetPoint("BOTTOMLEFT", chatrbg, "TOPLEFT", 0, TukuiDB.Scale(3))
chatrtbg:SetPoint("BOTTOMRIGHT", chatrbg, "TOPRIGHT", TukuiDB.Scale(-24), TukuiDB.Scale(3))
chatrtbg:SetHeight(TukuiDB.Scale(22))
chatrtbg:SetFrameStrata("BACKGROUND")

TukuiDB.CreateShadow(chatrbg)
TukuiDB.CreateShadow(chatrtbg)

-- BATTLEGROUND STATS FRAME
if TukuiCF["datatext"].battleground == true then
	local bgframe = CreateFrame("Frame", "TukuiInfoBattleGround", UIParent)
	TukuiDB.CreatePanel(bgframe, 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframe:SetAllPoints(TukuiBottomPanel)
	bgframe:SetFrameLevel(TukuiBottomPanel:GetFrameLevel() + 1)
	bgframe:SetFrameStrata("LOW")
	bgframe:SetScript("OnEnter", function(self)
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if name then
				if name == TukuiDB.myname then
					local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
					local classcolor = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:AddDoubleLine(tukuilocal.datatext_ttstatsfor, classcolor..name.."|r")
					GameTooltip:AddLine' '
					--Add extra statistics to watch based on what BG you are in.
					if GetRealZoneText() == "Arathi Basin" then --
						GameTooltip:AddDoubleLine(tukuilocal.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(tukuilocal.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Warsong Gulch" then --
						GameTooltip:AddDoubleLine(tukuilocal.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(tukuilocal.datatext_flagsreturned,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Eye of the Storm" then --
						GameTooltip:AddDoubleLine(tukuilocal.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
					elseif GetRealZoneText() == "Alterac Valley" then
						GameTooltip:AddDoubleLine(tukuilocal.datatext_graveyardsassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(tukuilocal.datatext_graveyardsdefended,GetBattlefieldStatData(i, 2),1,1,1)
						GameTooltip:AddDoubleLine(tukuilocal.datatext_towersassaulted,GetBattlefieldStatData(i, 3),1,1,1)
						GameTooltip:AddDoubleLine(tukuilocal.datatext_towersdefended,GetBattlefieldStatData(i, 4),1,1,1)
					elseif GetRealZoneText() == "Strand of the Ancients" then
						GameTooltip:AddDoubleLine(tukuilocal.datatext_demolishersdestroyed,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(tukuilocal.datatext_gatesdestroyed,GetBattlefieldStatData(i, 2),1,1,1)
					elseif GetRealZoneText() == "Isle of Conquest" then
						GameTooltip:AddDoubleLine(tukuilocal.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(tukuilocal.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					end			
					GameTooltip:Show()
				end
			end
		end
	end) 

	bgframe:SetScript("OnMouseDown", function(self) ToggleFrame(TukuiInfoBattleGround) end)
	bgframe:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	bgframe:RegisterEvent("PLAYER_ENTERING_WORLD")
	bgframe:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	bgframe:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			if not InCombatLockdown() then
				TukuiInfoBattleGround:Show()
				TukuiBottomPanel:EnableMouse(true)
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			if not InCombatLockdown() then
				TukuiInfoBattleGround:Hide()
				TukuiBottomPanel:EnableMouse(false)
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
	end)
end


