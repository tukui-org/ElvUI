--------------------------------------------------------------------
-- BGScore (original feature by elv22, edited by Tukz)
--------------------------------------------------------------------

if TukuiCF["datatext"].battleground == true then
	local bgframe = TukuiInfoLeftBattleGround
	bgframe:SetScript("OnEnter", function(self)
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if ( name ) then
				if ( name == UnitName("player") ) then
					GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, TukuiDB.Scale(4));
					GameTooltip:ClearLines()
					GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, TukuiDB.Scale(1))
					GameTooltip:ClearLines()
					GameTooltip:AddLine(tukuilocal.datatext_ttstatsfor.."[|cffCC0033"..name.."|r]")
					GameTooltip:AddLine' '
					GameTooltip:AddDoubleLine(tukuilocal.datatext_ttkillingblows, killingBlows,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_tthonorkills, honorableKills,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_ttdeaths, deaths,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_tthonorgain, format('%d', honorGained),1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_ttdmgdone, damageDone,1,1,1)
					GameTooltip:AddDoubleLine(tukuilocal.datatext_tthealdone, healingDone,1,1,1)
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
	bgframe:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local Text1  = TukuiInfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
	Text1:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize)
	Text1:SetPoint("LEFT", TukuiInfoLeftBattleGround, 30, 0.5)
	Text1:SetHeight(TukuiInfoLeft:GetHeight())

	local Text2  = TukuiInfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize)
	Text2:SetPoint("CENTER", TukuiInfoLeftBattleGround, 0, 0.5)
	Text2:SetHeight(TukuiInfoLeft:GetHeight())

	local Text3  = TukuiInfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
	Text3:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize)
	Text3:SetPoint("RIGHT", TukuiInfoLeftBattleGround, -30, 0.5)
	Text3:SetHeight(TukuiInfoLeft:GetHeight())

	local int = 2
	local function Update(self, t)
		int = int - t
		if int < 0 then
			local dmgtxt
			RequestBattlefieldScoreData()
			local numScores = GetNumBattlefieldScores()
			for i=1, numScores do
				local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
				if healingDone > damageDone then
					dmgtxt = (tukuilocal.datatext_healing..healingDone)
				else
					dmgtxt = (tukuilocal.datatext_damage..damageDone)
				end
				if ( name ) then
					if ( name == TukuiDB.myname ) then
						Text2:SetText(tukuilocal.datatext_honor..format('%d', honorGained))
						Text1:SetText(dmgtxt)
						Text3:SetText(tukuilocal.datatext_killingblows..killingBlows)
					end   
				end
			end 
			int  = 2
		end
	end
	
	--hide text when not in an bg
	local function OnEvent(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			local inInstance, instanceType = IsInInstance()
			if inInstance and (instanceType == "pvp") then
				bgframe:Show()
			else
				Text1:SetText("")
				Text2:SetText("")
				Text3:SetText("")
				bgframe:Hide()
			end
		end
	end

	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 2)
end