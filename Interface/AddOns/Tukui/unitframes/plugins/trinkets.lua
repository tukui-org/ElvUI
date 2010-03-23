if not TukuiDB["unitframes"].enable == true then return end

local arenaUnits = {}
local arenaGUID  = {}
local usedTrinkets = {}
local trinketFrame = {}
 
local UpdateTag = function(self, elapsed)
	if ( self.endTime < GetTime() ) then
		usedTrinkets[self.guid] = false
		self:SetScript("OnUpdate", nil)
	end
end

local TrinketUsed = function(guid, time)
	local message
	local unit = arenaGUID[guid]
	if (unit and arenaUnits[unit].Trinket) then
		arenaUnits[unit].Trinket.endTime = GetTime() + time
		CooldownFrame_SetTimer(arenaUnits[unit].Trinket.cooldownFrame, GetTime(), time, 1)
		if ( arenaUnits[unit].Trinket.trinketUseAnnounce ) then
			if ( time == 120 ) then 
				message = "Trinket used: "..UnitName(unit).." "..UnitClass(unit)
			else 
				message = "WotF used: "..UnitName(unit).." "..UnitClass(unit) 
			end
			SendChatMessage(message, "PARTY")
		end
	end
	usedTrinkets[guid] = true
	trinketFrame[guid] = CreateFrame("Frame")
	trinketFrame[guid].endTime = GetTime() + time
	trinketFrame[guid].guid = guid
	trinketFrame[guid]:SetScript("OnUpdate", UpdateTag)
end

local Update = function(self, event, ...)
	if ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
		local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName = ...
		if ( eventType == "SPELL_CAST_SUCCESS" ) then
			-- enemy trinket usage
			if ( spellID == 59752 or spellID == 42292 ) then
				TrinketUsed(sourceGUID, 120)
			end
			-- WotF
			if ( spellID == 7744 ) then
				TrinketUsed(sourceGUID, 45)
			end
		end
	elseif ( event == "ARENA_OPPONENT_UPDATE" ) then
		local unit, type = ...
		if ( type == "seen" ) then
			if ( UnitExists(unit) and UnitIsPlayer(unit) and arenaUnits[unit].Trinket ) then
				arenaGUID[UnitGUID(unit)] = unit
				if ( UnitFactionGroup(unit) == "Horde" ) then
					arenaUnits[unit].Trinket.Icon:SetTexture(UnitLevel(unit) == 80 and "Interface\\Addons\\Tukui\\media\\INV_Jewelry_Necklace_38" or "Interface\\Addons\\Tukui\\media\\INV_Jewelry_TrinketPVP_02")
				else
					arenaUnits[unit].Trinket.Icon:SetTexture(UnitLevel(unit) == 80 and "Interface\\Addons\\Tukui\\media\\INV_Jewelry_Necklace_37" or "Interface\\Addons\\Tukui\\media\\INV_Jewelry_TrinketPVP_01")
				end
			end
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		for k, v in pairs(trinketFrame) do
			v:SetScript("OnUpdate", nil)
		end
		for k, v in pairs(arenaUnits) do
			v.Trinket:SetScript("OnUpdate", nil)
			CooldownFrame_SetTimer(v.Trinket.cooldownFrame, 1, 1, 1)
		end
		arenaGUID  = {}
		usedTrinkets = {}
		trinketFrame = {}
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ARENA_OPPONENT_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", Update)

oUF.Tags['[trinket]'] = function(unit)
	if( usedTrinkets[UnitGUID(unit)] or not UnitIsPlayer(unit) ) then return end
	local trinketIcon
	if( UnitFactionGroup(unit) == "Horde" ) then
		trinketIcon = UnitLevel(unit) == 80 and "Interface\\Icons\\INV_Jewelry_Necklace_38" or "Interface\\Icons\\INV_Jewelry_TrinketPVP_02"
	else
		trinketIcon = UnitLevel(unit) == 80 and "Interface\\Icons\\INV_Jewelry_Necklace_37" or "Interface\\Icons\\INV_Jewelry_TrinketPVP_01"
	end
	return string.format("|T%s:20:20:0:0|t", trinketIcon)
end

local Enable = function(self)
	if ( self.Trinket ) then
		self.Trinket.cooldownFrame = CreateFrame("Cooldown", nil, self.Trinket)
		self.Trinket.cooldownFrame:SetAllPoints(self.Trinket)
		self.Trinket.Icon = self.Trinket:CreateTexture(nil, "BORDER")
		self.Trinket.Icon:SetAllPoints(self.Trinket)
		self.Trinket.Icon:SetTexCoord(0, 1, 0, 1)
		arenaUnits[self.unit] = self
	end
end
 
local Disable = function(self)
	if ( self.Trinket ) then
		arenaUnits[self.unit] = nil
	end
end
 
oUF:AddElement('Trinket', function() return end, Enable, Disable)
