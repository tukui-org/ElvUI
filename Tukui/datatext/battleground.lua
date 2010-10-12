--------------------------------------------------------------------
-- BGScore (original feature by elv22, edited by Tukz)
--------------------------------------------------------------------

if TukuiCF["datatext"].battleground == true then
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

	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
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
			end
		end
	end
	
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end