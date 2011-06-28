--------------------------------------------------------------------
-- BGScore
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].battleground or C["datatext"].battleground ~= true then return end

local join = string.join

local shownbg = true
local classColor = RAID_CLASS_COLORS[E.myclass]
local damageDoneString = join("", L.datatext_damage, E.ValColor, "%s")
local honorGainedString = join("", L.datatext_honor, E.ValColor, "%s")
local killingBlowsString = join("", L.datatext_killingblows, E.ValColor, "%d")
local deathsString = join("", L.datatext_ttdeaths, E.ValColor, "%d")
local honorableKillsString = join("", L.datatext_tthonorkills, E.ValColor, "%d")
local healingDoneString = join("", L.datatext_healing, E.ValColor, "%s")

--Map IDs
local WSG = 443
local TP = 626
local AV = 401
local SOTA = 512
local IOC = 540
local EOTS = 482
local TBFG = 736
local AB = 461

local function ShowBattleGroundStatTooltip(self, name, index)
	local curmapid = GetCurrentMapAreaID()

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(L.datatext_ttstatsfor, name, 1,1,1, classColor.r, classColor.g, classColor.b)
	GameTooltip:AddLine(" ")

	--Add extra statistics to watch based on what BG you are in.
	if curmapid == WSG or curmapid == TP then 
		GameTooltip:AddDoubleLine(L.datatext_flagscaptured, GetBattlefieldStatData(index, 1),1,1,1)
		GameTooltip:AddDoubleLine(L.datatext_flagsreturned, GetBattlefieldStatData(index, 2),1,1,1)
	elseif curmapid == EOTS then
		GameTooltip:AddDoubleLine(L.datatext_flagscaptured, GetBattlefieldStatData(index, 1),1,1,1)
	elseif curmapid == AV then
		GameTooltip:AddDoubleLine(L.datatext_graveyardsassaulted, GetBattlefieldStatData(index, 1),1,1,1)
		GameTooltip:AddDoubleLine(L.datatext_graveyardsdefended, GetBattlefieldStatData(index, 2),1,1,1)
		GameTooltip:AddDoubleLine(L.datatext_towersassaulted, GetBattlefieldStatData(index, 3),1,1,1)
		GameTooltip:AddDoubleLine(L.datatext_towersdefended, GetBattlefieldStatData(index, 4),1,1,1)
	elseif curmapid == SOTA then
		GameTooltip:AddDoubleLine(L.datatext_demolishersdestroyed, GetBattlefieldStatData(index, 1),1,1,1)
		GameTooltip:AddDoubleLine(L.datatext_gatesdestroyed, GetBattlefieldStatData(index, 2),1,1,1)
	elseif curmapid == IOC or curmapid == TBFG or curmapid == AB then
		GameTooltip:AddDoubleLine(L.datatext_basesassaulted, GetBattlefieldStatData(index, 1),1,1,1)
		GameTooltip:AddDoubleLine(L.datatext_basesdefended, GetBattlefieldStatData(index, 2),1,1,1)
	end			
	GameTooltip:Show()
end


ElvuiInfoLeft:SetScript("OnMouseDown", function(self) 
	if shownbg == true then 
		ElvuiInfoBattleGroundL:Hide()
		ElvuiInfoBattleGroundR:Hide()
		shownbg = false 
	else 
		ElvuiInfoBattleGroundL:Show()
		ElvuiInfoBattleGroundR:Show()
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
		ElvuiInfoBattleGroundL:Hide()
		ElvuiInfoBattleGroundR:Hide()
		shownbg = false 
	else 
		ElvuiInfoBattleGroundL:Show()
		ElvuiInfoBattleGroundR:Show()
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

local bgframeL = CreateFrame("Frame", "ElvuiInfoBattleGroundL", E.UIParent)
bgframeL:CreatePanel("Default", 1, 1, "TOPLEFT", E.UIParent, "BOTTOMLEFT", 0, 0)
bgframeL:SetAllPoints(ElvuiInfoLeft)
bgframeL:SetFrameLevel(ElvuiInfoLeft:GetFrameLevel() + 1)
bgframeL:SetTemplate("Default", true)
bgframeL:SetFrameStrata("HIGH")
bgframeL:SetScript("OnEnter", function(self)
	for i=1, GetNumBattlefieldScores() do
		local name = GetBattlefieldScore(i)
		if name and name == E.myname then ShowBattleGroundStatTooltip(self, name, i) end
	end
end) 

local bgframeR = CreateFrame("Frame", "ElvuiInfoBattleGroundR", E.UIParent)
bgframeR:CreatePanel("Default", 1, 1, "TOPLEFT", E.UIParent, "BOTTOMLEFT", 0, 0)
bgframeR:SetTemplate("Default", true)
bgframeR:SetAllPoints(ElvuiInfoRight)
bgframeR:SetFrameLevel(ElvuiInfoRight:GetFrameLevel() + 1)
bgframeR:SetFrameStrata("HIGH")
bgframeR:SetScript("OnEnter", function(self)
	for i=1, GetNumBattlefieldScores() do
		local name = GetBattlefieldScore(i)
		if name and name == E.myname then ShowBattleGroundStatTooltip(self, name, i) end
	end
end)

bgframeL:SetScript("OnMouseDown", function(self) 
	if shownbg == true then 
		ElvuiInfoBattleGroundL:Hide()
		ElvuiInfoBattleGroundR:Hide()
		shownbg = false 
	else 
		ElvuiInfoBattleGroundL:Show()
		ElvuiInfoBattleGroundR:Show()
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
		ElvuiInfoBattleGroundL:Hide()
		ElvuiInfoBattleGroundR:Hide()
		shownbg = false 
	else 
		ElvuiInfoBattleGroundL:Show()
		ElvuiInfoBattleGroundR:Show()
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
Text1:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text1:SetShadowColor(0, 0, 0, 0.4)
Text1:SetShadowOffset(E.mult, -E.mult)
E.PP(1, Text1)
Text1:SetParent(ElvuiInfoBattleGroundL)

local Text2  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
Text2:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text2:SetShadowColor(0, 0, 0, 0.4)
Text2:SetShadowOffset(E.mult, -E.mult)
E.PP(2, Text2)
Text2:SetParent(ElvuiInfoBattleGroundL)

local Text3  = ElvuiInfoBattleGroundL:CreateFontString(nil, "OVERLAY")
Text3:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text3:SetShadowColor(0, 0, 0, 0.4)
Text3:SetShadowOffset(E.mult, -E.mult)
E.PP(3, Text3)
Text3:SetParent(ElvuiInfoBattleGroundL)

local Text4  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
Text4:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text4:SetShadowColor(0, 0, 0, 0.4)
Text4:SetShadowOffset(E.mult, -E.mult)
E.PP(5, Text4)
Text4:SetParent(ElvuiInfoBattleGroundR)

local Text5  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
Text5:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text5:SetShadowColor(0, 0, 0, 0.4)
Text5:SetShadowOffset(E.mult, -E.mult)
E.PP(4, Text5)
Text5:SetParent(ElvuiInfoBattleGroundR)

local Text6  = ElvuiInfoBattleGroundR:CreateFontString(nil, "OVERLAY")
Text6:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text6:SetShadowColor(0, 0, 0, 0.4)
Text6:SetShadowOffset(E.mult, -E.mult)
E.PP(6, Text6)
Text6:SetParent(ElvuiInfoBattleGroundR)


local int = 1
local function Update(self, t)
	int = int - t
	if int < 0 then
		-- request new battlefield scores from server
		RequestBattlefieldScoreData()
		int  = 1
	end
end

local function OnEvent(self, event)
	--hide text when not in an bg
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
	-- scores have been updated, put them in our datatext
	if event == "UPDATE_BATTLEFIELD_SCORE" then
		local name, killingBlows, honorableKills, deaths, honorGained, damageDone, healingDone
		for i=1, GetNumBattlefieldScores() do
			name, killingBlows, honorableKills, deaths, honorGained, _, _, _, _, damageDone, healingDone = GetBattlefieldScore(i)
			if name and name == E.myname then
				Text1:SetFormattedText(damageDoneString, E.ShortValue(damageDone) )
				Text2:SetFormattedText(honorGainedString, E.ShortValue(honorGained))
				Text3:SetFormattedText(killingBlowsString, killingBlows)
				Text4:SetFormattedText(deathsString, deaths)
				Text5:SetFormattedText(honorableKillsString, honorableKills)
				Text6:SetFormattedText(healingDoneString, E.ShortValue(healingDone) )
			end
		end 
	end
end

Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnUpdate", Update)