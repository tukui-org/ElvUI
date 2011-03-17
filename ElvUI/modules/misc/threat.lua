local E, C, L, DB = unpack(select(2, ...)) -- Import: E - functions, constants, variables; C - config; L - locales
-- Very simple threat bar for ElvUI.

-- cannot work without Info Right DataText Panel.
if not ElvuiInfoRight or C["others"].showthreat ~= true then return end

local aggroColors = {
	[1] = {0, 1, 0},
	[2] = {1, 1, 0},
	[3] = {0, 1, 0},
}

-- create the bar
local ElvuiThreatBar = CreateFrame("StatusBar", "ElvuiThreatBar", TukuiInfoRight)
ElvuiThreatBar:Point("TOPLEFT", 2, -2)
ElvuiThreatBar:Point("BOTTOMRIGHT", -2, 2)

ElvuiThreatBar:SetStatusBarTexture(C["media"].normTex)
ElvuiThreatBar:GetStatusBarTexture():SetHorizTile(false)
ElvuiThreatBar:SetTemplate('Default', true)
ElvuiThreatBar:SetBackdropBorderColor(0, 0, 0, 0)
ElvuiThreatBar:SetMinMaxValues(0, 100)

ElvuiThreatBar:FontString(nil, C["media"].font, C.general.fontscale, 'THINOUTLINE')
ElvuiThreatBar.text:SetPoint("CENTER")
ElvuiThreatBar.text:SetShadowOffset(E.mult, -E.mult)
ElvuiThreatBar.text:SetShadowColor(0, 0, 0, 0.4)

ElvuiThreatBar.bg = ElvuiThreatBar:CreateTexture(nil, 'BORDER')
ElvuiThreatBar.bg:SetAllPoints(ElvuiThreatBar)

-- event func
local function OnEvent(self, event, ...)
	local party = GetNumPartyMembers()
	local raid = GetNumRaidMembers()
	local pet = select(1, HasPetUI())
	
	if event == "PLAYER_ENTERING_WORLD" then
		self:Hide()
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:Hide()
	elseif event == "PLAYER_REGEN_DISABLED" then
		-- look if we have a pet, party or raid active
		-- having threat bar solo is totally useless
		if party > 0 or raid > 0 or pet == 1 then
			self:Show()
		else
			self:Hide()
		end
	else
		-- update when pet, party or raid change.
		if (InCombatLockdown()) and (party > 0 or raid > 0 or pet == 1) then
			self:Show()
		else
			self:Hide()
		end
	end
end

-- update status bar func
local function OnUpdate(self, event, unit)
	if UnitAffectingCombat(self.unit) then
		local _, _, threatpct, rawthreatpct, _ = UnitDetailedThreatSituation(self.unit, self.tar)
		local threatval = threatpct or 0
		
		self:SetValue(threatval)
		self.text:SetFormattedText("%s "..E.ValColor.."%3.1f%%|r", L.unitframes_ouf_threattext, threatval)
		
		if E.Role ~= "Tank" then
			if( threatval < 30 ) then
				self:SetStatusBarColor(unpack(self.Colors[1]))
			elseif( threatval >= 30 and threatval < 70 ) then
				self:SetStatusBarColor(unpack(self.Colors[2]))
			else
				self:SetStatusBarColor(unpack(self.Colors[3]))
			end
		else
			if( threatval < 30 ) then
				self:SetStatusBarColor(unpack(self.Colors[3]))
			elseif( threatval >= 30 and threatval < 70 ) then
				self:SetStatusBarColor(unpack(self.Colors[2]))
			else
				self:SetStatusBarColor(unpack(self.Colors[1]))
			end		
		end
				
		if threatval > 0 then
			self:SetAlpha(1)
		else
			self:SetAlpha(0)
		end		
	end
end

-- event handling
ElvuiThreatBar:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiThreatBar:RegisterEvent("PLAYER_REGEN_ENABLED")
ElvuiThreatBar:RegisterEvent("PLAYER_REGEN_DISABLED")
ElvuiThreatBar:SetScript("OnEvent", OnEvent)
ElvuiThreatBar:SetScript("OnUpdate", OnUpdate)
ElvuiThreatBar.unit = "player"
ElvuiThreatBar.tar = ElvuiThreatBar.unit.."target"
ElvuiThreatBar.Colors = aggroColors
ElvuiThreatBar:SetAlpha(0)