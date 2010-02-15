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

if not TukuiUF == true then return end
if not showthreat == true then return end

local aggroColors = {
	[1] = {0, 1, 0},
	[2] = {1, 1, 0},
	[3] = {1, 0, 0},
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
		
		local numParty = GetNumPartyMembers()
		local numRaid = GetNumRaidMembers() 

		-- this part is an addition by tukz because he is tired
		-- to see this fucking bar appear when pvp'ing or in solo		
		if (threatval > 0) and (numParty > 0 or numRaid > 0) then
			self:SetAlpha(1)
		else
			self:SetAlpha(0)
		end
		-- end of hack
		
	end
end

local function enable(self)
	local bar = self.ThreatBar
	if( bar ) then
		bar:Hide()
		bar:SetMinMaxValues(0, bar.maxThreatVal or 100)

		self:RegisterEvent("PLAYER_REGEN_ENABLED", function(self) self.ThreatBar:Hide() end)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", function(self) self.ThreatBar:Show() end)
		
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
		bar:UnregisterEvent("PLAYER_REGEN_ENABLED")
		bar:UnregisterEvent("PLAYER_REGEN_DISABLED")
		bar:Hide()
		bar:SetScript("OnEvent", nil)
	end
end

oUF:AddElement("ThreatBar", function() return end, enable, disable)