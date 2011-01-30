
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


--------------------------------------------------------------------
-- BGScore
--------------------------------------------------------------------
if C["datatext"].battleground == true then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local Text1  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text1:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	E.PP(1, Text1)
	Text1:SetParent(ElvuiInfoBattleGroundL)
	
	local Text2  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	E.PP(2, Text2)
	Text2:SetParent(ElvuiInfoBattleGroundL)
	
	local Text3  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text3:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	E.PP(3, Text3)
	Text3:SetParent(ElvuiInfoBattleGroundL)
	
	local Text4  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text4:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	E.PP(5, Text4)
	Text4:SetParent(ElvuiInfoBattleGroundR)
	
	local Text5  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text5:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	E.PP(4, Text5)
	Text5:SetParent(ElvuiInfoBattleGroundR)
	
	local Text6  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text6:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
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