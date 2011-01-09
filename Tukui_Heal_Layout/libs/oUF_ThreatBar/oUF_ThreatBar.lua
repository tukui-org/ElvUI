if TukuiCF.unitframes.enable ~= true or TukuiCF.unitframes.showthreat ~= true then return end
--[[
	Elements handled:
	.ThreatBar - StatusBar
	.Text - Text value of threat percentage
	
	Options:
	.Colors - Table of colors to use for threat coloring
	.useRawThreat - Use raw threat percentage instead of normalized
	.usePlayerTarget - Always use the player target to determine threat for non-player units.
					- otherwise will always use the unit's target.
	.maxThreatVal - For use with .useRawThreat.  Allows threat percentage greater than 100.
]]--

if not oUF then return end

local ThreatNumParty = 0
local ThreatNumRaid = 0
local ThreatPet = 0

local aggroColors = {
	[1] = {12/255, 151/255,  15/255},
	[2] = {166/255, 171/255,  26/255},
	[3] = {163/255,  24/255,  24/255},
}

local function update(self, event, unit)
	if( UnitAffectingCombat(self.unit) ) then
		local _, _, threatpct, rawthreatpct, _ = UnitDetailedThreatSituation(self.unit, self.tar)
		
		if( self.useRawThreat ) then
			threatval = rawthreatpct or 0
		else
			threatval = threatpct or 0
		end
		
		self:SetValue(threatval)
		if( self.Text ) then
			self.Text:SetFormattedText("%3.1f", threatval)
		end
		
		if( threatval < 30 ) then
			self:SetStatusBarColor(unpack(self.Colors[1]))
		elseif( threatval >= 30 and threatval < 70 ) then
			self:SetStatusBarColor(unpack(self.Colors[2]))
		else
			self:SetStatusBarColor(unpack(self.Colors[3]))
		end
				
		if (threatval > 0) and (ThreatNumRaid > 0 or ThreatNumParty > 0 or ThreatPet == 1) then
			self:SetAlpha(1)
		else
			self:SetAlpha(0)
		end		
	end
end

local function UpdateGroup()
	ThreatNumParty = GetNumPartyMembers()
	ThreatNumRaid = GetNumRaidMembers()
	ThreatPet = select(1, HasPetUI())
end

local function enable(self)
	local bar = self.ThreatBar
	if( bar ) then
		bar:Hide()
		bar:SetMinMaxValues(0, bar.maxThreatVal or 100)
		
		self:RegisterEvent("PLAYER_ENTERING_WORLD", function() UpdateGroup() end)
		self:RegisterEvent("PLAYER_LOGIN", function() UpdateGroup() end)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", function(self) self.ThreatBar:Hide() end)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", function(self) self.ThreatBar:Show() end)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", function() UpdateGroup() end)
		self:RegisterEvent("RAID_ROSTER_UPDATE", function() UpdateGroup() end)
		self:RegisterEvent("UNIT_PET", function() UpdateGroup() end)
		
		bar:SetScript("OnUpdate", update)
		
		bar.Colors = (self.ThreatBar.Colors or aggroColors)
		bar.unit = self.unit
		
		if( self.usePlayerTarget ) then
			bar.tar = "playertarget"
		else
			bar.tar = bar.unit.."target"
		end

		return true
	end
end

local function disable(self)
	local bar = self.ThreatBar
	if( bar ) then
		bar:UnregisterEvent("PLAYER_ENTERING_WORLD")
		bar:UnregisterEvent("PLAYER_LOGIN")
		bar:UnregisterEvent("PLAYER_REGEN_ENABLED")
		bar:UnregisterEvent("PLAYER_REGEN_DISABLED")
		bar:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		bar:UnregisterEvent("RAID_ROSTER_UPDATE")
		bar:UnregisterEvent("UNIT_PET")
		bar:Hide()
		bar:SetScript("OnEvent", nil)
	end
end

oUF:AddElement("ThreatBar", function() return end, enable, disable)