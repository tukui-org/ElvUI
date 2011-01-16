local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

--------------------------------------------------------------------
-- BGScore
--------------------------------------------------------------------
if ElvCF["datatext"].battleground == true then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local Text1  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text1:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	ElvDB.PP(1, Text1)

	local Text2  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	ElvDB.PP(2, Text2)

	local Text3  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text3:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	ElvDB.PP(3, Text3)
	
	local Text4  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text4:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	ElvDB.PP(5, Text4)

	local Text5  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text5:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	ElvDB.PP(4, Text5)

	local Text6  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text6:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	ElvDB.PP(6, Text6)

	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
			RequestBattlefieldScoreData()
			local numScores = GetNumBattlefieldScores()
			for i=1, numScores do
				local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
				if ( name ) then
					if ( name == ElvDB.myname) then
						Text1:SetText(ElvL.datatext_damage..ElvDB.ValColor..damageDone)
						Text2:SetText(ElvL.datatext_honor..ElvDB.ValColor..format('%d', honorGained))
						Text3:SetText(ElvL.datatext_killingblows..ElvDB.ValColor..killingBlows)
						Text4:SetText(ElvL.datatext_ttdeaths..ElvDB.ValColor..deaths)
						Text5:SetText(ElvL.datatext_tthonorkills..ElvDB.ValColor..honorableKills)
						Text6:SetText(ElvL.datatext_healing..ElvDB.ValColor..healingDone)
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