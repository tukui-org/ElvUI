
local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


--------------------------------------------------------------------
-- BGScore
--------------------------------------------------------------------
if C["datatext"].battleground == true then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local Text1  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text1:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	DB.PP(1, Text1)

	local Text2  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	DB.PP(2, Text2)

	local Text3  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
	Text3:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	DB.PP(3, Text3)
	
	local Text4  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text4:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	DB.PP(5, Text4)

	local Text5  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text5:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	DB.PP(4, Text5)

	local Text6  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
	Text6:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	DB.PP(6, Text6)

	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
			RequestBattlefieldScoreData()
			local numScores = GetNumBattlefieldScores()
			for i=1, numScores do
				local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
				if ( name ) then
					if ( name == DB.myname) then
						Text1:SetText(L.datatext_damage..DB.ValColor..damageDone)
						Text2:SetText(L.datatext_honor..DB.ValColor..format('%d', honorGained))
						Text3:SetText(L.datatext_killingblows..DB.ValColor..killingBlows)
						Text4:SetText(L.datatext_ttdeaths..DB.ValColor..deaths)
						Text5:SetText(L.datatext_tthonorkills..DB.ValColor..honorableKills)
						Text6:SetText(L.datatext_healing..DB.ValColor..healingDone)
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