
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


--------------------------------------------------------------------
-- BGScore
--------------------------------------------------------------------
if C["datatext"].battleground == true then
	local shownbg = true

	--Map IDs
	local WSG = 443
	local TP = 626
	local AV = 401
	local SOTA = 512
	local IOC = 540
	local EOTS = 482
	local TBFG = 736
	local AB = 461

	ElvuiInfoLeft:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			E.SlideOut(ElvuiInfoBattleGroundL) 
			E.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			E.SlideIn(ElvuiInfoBattleGroundL) 
			E.SlideIn(ElvuiInfoBattleGroundR) 
			shownbg = true 
		end 
	end)
	ElvuiInfoLeft:RegisterEvent("PLAYER_ENTERING_WORLD")
	ElvuiInfoLeft:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	ElvuiInfoLeft:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			if not InCombatLockdown() then
				ElvuiInfoLeft:EnableMouse(true)
				ElvuiInfoBattleGroundL:Show()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			if not InCombatLockdown() then
				ElvuiInfoLeft:EnableMouse(false)
				ElvuiInfoBattleGroundL:Hide()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
		shownbg = true
	end)

	ElvuiInfoRight:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			E.SlideOut(ElvuiInfoBattleGroundL) 
			E.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			E.SlideIn(ElvuiInfoBattleGroundL) 
			E.SlideIn(ElvuiInfoBattleGroundR) 
			shownbg = true 
		end 
	end)
	ElvuiInfoRight:RegisterEvent("PLAYER_ENTERING_WORLD")
	ElvuiInfoRight:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	ElvuiInfoRight:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			if not InCombatLockdown() then
				ElvuiInfoRight:EnableMouse(true)
				ElvuiInfoBattleGroundR:Show()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			if not InCombatLockdown() then
				ElvuiInfoRight:EnableMouse(false)
				ElvuiInfoBattleGroundR:Hide()
			else
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
		shownbg = true
	end)


	local bgframeL = CreateFrame("Frame", "ElvuiInfoBattleGroundL", UIParent)
	bgframeL:CreatePanel("Default", 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframeL:SetAllPoints(ElvuiInfoLeft)
	bgframeL:SetFrameLevel(ElvuiInfoLeft:GetFrameLevel() + 1)
	bgframeL:SetTemplate("Default", true)
	bgframeL:SetFrameStrata("HIGH")
	bgframeL:SetScript("OnEnter", function(self)
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if name then
				if name == E.myname then
					local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
					local classcolor = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
					local curmapid = GetCurrentMapAreaID()
					SetMapToCurrentZone()
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:AddDoubleLine(L.datatext_ttstatsfor, classcolor..name.."|r")
					GameTooltip:AddLine' '
					--Add extra statistics to watch based on what BG you are in.
					if curmapid == WSG or curmapid == TP then 
						GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_flagsreturned,GetBattlefieldStatData(i, 2),1,1,1)
					elseif curmapid == EOTS then
						GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
					elseif curmapid == AV then
						GameTooltip:AddDoubleLine(L.datatext_graveyardsassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_graveyardsdefended,GetBattlefieldStatData(i, 2),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_towersassaulted,GetBattlefieldStatData(i, 3),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_towersdefended,GetBattlefieldStatData(i, 4),1,1,1)
					elseif curmapid == SOTA then
						GameTooltip:AddDoubleLine(L.datatext_demolishersdestroyed,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_gatesdestroyed,GetBattlefieldStatData(i, 2),1,1,1)
					elseif curmapid == IOC or curmapid == TBFG or curmapid == AB then
						GameTooltip:AddDoubleLine(L.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					end			
					GameTooltip:Show()
				end
			end
		end
	end) 
	
	local bgframeR = CreateFrame("Frame", "ElvuiInfoBattleGroundR", UIParent)
	bgframeR:CreatePanel("Default", 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframeR:SetTemplate("Default", true)
	bgframeR:SetAllPoints(ElvuiInfoRight)
	bgframeR:SetFrameLevel(ElvuiInfoRight:GetFrameLevel() + 1)
	bgframeR:SetFrameStrata("HIGH")
	bgframeR:SetScript("OnEnter", function(self)
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if name then
				if name == E.myname then
					local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
					local classcolor = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
					local curmapid = GetCurrentMapAreaID()
					SetMapToCurrentZone()
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:AddDoubleLine(L.datatext_ttstatsfor, classcolor..name.."|r")
					GameTooltip:AddLine' '
					--Add extra statistics to watch based on what BG you are in.
					if curmapid == WSG or curmapid == TP then 
						GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_flagsreturned,GetBattlefieldStatData(i, 2),1,1,1)
					elseif curmapid == EOTS then
						GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
					elseif curmapid == AV then
						GameTooltip:AddDoubleLine(L.datatext_graveyardsassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_graveyardsdefended,GetBattlefieldStatData(i, 2),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_towersassaulted,GetBattlefieldStatData(i, 3),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_towersdefended,GetBattlefieldStatData(i, 4),1,1,1)
					elseif curmapid == SOTA then
						GameTooltip:AddDoubleLine(L.datatext_demolishersdestroyed,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_gatesdestroyed,GetBattlefieldStatData(i, 2),1,1,1)
					elseif curmapid == IOC or curmapid == TBFG or curmapid == AB then
						GameTooltip:AddDoubleLine(L.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
						GameTooltip:AddDoubleLine(L.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
					end			
					GameTooltip:Show()
				end
			end
		end
	end)
	
	E.AnimGroup(ElvuiInfoBattleGroundL, 0, E.Scale(-150), 0.4)
	E.AnimGroup(ElvuiInfoBattleGroundR, 0, E.Scale(-150), 0.4)

	bgframeL:SetScript("OnMouseDown", function(self) 
		if shownbg == true then 
			E.SlideOut(ElvuiInfoBattleGroundL) 
			E.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			E.SlideIn(ElvuiInfoBattleGroundL) 
			E.SlideIn(ElvuiInfoBattleGroundR) 
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
			E.SlideOut(ElvuiInfoBattleGroundL) 
			E.SlideOut(ElvuiInfoBattleGroundR) 
			shownbg = false 
		else 
			E.SlideIn(ElvuiInfoBattleGroundL) 
			E.SlideIn(ElvuiInfoBattleGroundR) 
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
	
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local Text1  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text1:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text1:SetShadowColor(0, 0, 0, 0.4)
	Text1:SetShadowOffset(E.mult, -E.mult)
	E.PP(1, Text1)
	Text1:SetParent(ElvuiInfoBattleGroundL)
	
	local Text2  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text2:SetShadowColor(0, 0, 0, 0.4)
	Text2:SetShadowOffset(E.mult, -E.mult)
	E.PP(2, Text2)
	Text2:SetParent(ElvuiInfoBattleGroundL)
	
	local Text3  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text3:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text3:SetShadowColor(0, 0, 0, 0.4)
	Text3:SetShadowOffset(E.mult, -E.mult)
	E.PP(3, Text3)
	Text3:SetParent(ElvuiInfoBattleGroundL)
	
	local Text4  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text4:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text4:SetShadowColor(0, 0, 0, 0.4)
	Text4:SetShadowOffset(E.mult, -E.mult)
	E.PP(5, Text4)
	Text4:SetParent(ElvuiInfoBattleGroundR)
	
	local Text5  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text5:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text5:SetShadowColor(0, 0, 0, 0.4)
	Text5:SetShadowOffset(E.mult, -E.mult)
	E.PP(4, Text5)
	Text5:SetParent(ElvuiInfoBattleGroundR)
	
	local Text6  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text6:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text6:SetShadowColor(0, 0, 0, 0.4)
	Text6:SetShadowOffset(E.mult, -E.mult)
	E.PP(6, Text6)
	Text6:SetParent(ElvuiInfoBattleGroundR)


	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
			RequestBattlefieldScoreData()
			local numScores = GetNumBattlefieldScores()
			for i=1, numScores do
				local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
				if ( name ) then
					if ( name == E.myname) then
						
						Text1:SetText(L.datatext_damage..E.ValColor..damageDone)
						Text2:SetText(L.datatext_honor..E.ValColor..format('%d', honorGained))
						Text3:SetText(L.datatext_killingblows..E.ValColor..killingBlows)
						Text4:SetText(L.datatext_ttdeaths..E.ValColor..deaths)
						Text5:SetText(L.datatext_tthonorkills..E.ValColor..honorableKills)
						Text6:SetText(L.datatext_healing..E.ValColor..healingDone)
					end   
				end
			end 
			int  = 1
		end
	end
	
	--hide text when not in an bg
	local function OnEvent(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			inInstance, instanceType = IsInInstance()
			if (not inInstance) or (instanceType == "none") then
				Text1:SetText("")
				Text2:SetText("")
				Text3:SetText("")
				Text4:SetText("")
				Text5:SetText("")
				Text6:SetText("")
			end
		end
	end
	
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
	
end