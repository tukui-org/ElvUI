--------------------------------------------------------------------
-- BGScore
--------------------------------------------------------------------
if TukuiCF["datatext"].battleground == true then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local Text1  = TukuiInfoBattleGround:CreateFontString(nil, "OVERLAY")
	Text1:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	TukuiDB.PP(1, Text1)

	local Text2  = TukuiInfoBattleGround:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	TukuiDB.PP(2, Text2)

	local Text3  = TukuiInfoBattleGround:CreateFontString(nil, "OVERLAY")
	Text3:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	TukuiDB.PP(3, Text3)
	
	local Text4  = TukuiInfoBattleGround:CreateFontString(nil, "OVERLAY")
	Text4:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	TukuiDB.PP(4, Text4)

	local Text5  = TukuiInfoBattleGround:CreateFontString(nil, "OVERLAY")
	Text5:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	TukuiDB.PP(5, Text5)

	local Text6  = TukuiInfoBattleGround:CreateFontString(nil, "OVERLAY")
	Text6:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	TukuiDB.PP(6, Text6)

	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
			RequestBattlefieldScoreData()
			local numScores = GetNumBattlefieldScores()
			for i=1, numScores do
				local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
				if ( name ) then
					if ( name == TukuiDB.myname) then
						Text1:SetText(tukuilocal.datatext_damage..valuecolor..damageDone)
						Text2:SetText(tukuilocal.datatext_honor..valuecolor..format('%d', honorGained))
						Text3:SetText(tukuilocal.datatext_killingblows..valuecolor..killingBlows)
						Text4:SetText(tukuilocal.datatext_ttdeaths..valuecolor..deaths)
						Text5:SetText(tukuilocal.datatext_tthonorkills..valuecolor..honorableKills)
						Text6:SetText(tukuilocal.datatext_healing..valuecolor..healingDone)
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