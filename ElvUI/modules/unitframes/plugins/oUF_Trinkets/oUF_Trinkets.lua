local E, C, L, DB = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
if C.unitframes.enable ~= true or C.unitframes.arena ~= true then return end

local _, ns = ...
local oUF = ns.oUF
assert(oUF, 'oUF not loaded')

local arenaFrame = {}
local arenaGUID  = {}
local usedTrinkets = {}
local trinketFrame = {}
 
local TrinketUpdate = function(self, elapsed)
	if self.endTime < GetTime() then
		usedTrinkets[self.guid] = false
		local unit = arenaGUID[self.guid]
		if unit and arenaFrame[unit] then
			if arenaFrame[unit].Trinket.trinketUpAnnounce then
				SendChatMessage("Trinket ready: "..UnitName(unit).." "..UnitClass(unit), "PARTY")
			end
		end
		self:SetScript("OnUpdate", nil)
	end
end

local GetTrinketIcon = function(unit)
	if UnitFactionGroup(unit) == "Horde" then
		return UnitLevel(unit) == 80 and "Interface\\Icons\\INV_Jewelry_Necklace_38" or "Interface\\Icons\\INV_Jewelry_TrinketPVP_02"
	else
		return UnitLevel(unit) == 80 and "Interface\\Icons\\INV_Jewelry_Necklace_37" or "Interface\\Icons\\INV_Jewelry_TrinketPVP_01"
	end
end

local TrinketUsed = function(guid, time)
	local message
	local unit = arenaGUID[guid]
	if unit and arenaFrame[unit] then
		CooldownFrame_SetTimer(arenaFrame[unit].Trinket.cooldownFrame, GetTime(), time, 1)
		if arenaFrame[unit].Trinket.trinketUseAnnounce then
			message = time == 120 and "Trinket used: " or "WotF used: "
			SendChatMessage(message..UnitName(unit).." "..UnitClass(unit), "PARTY")
		end
	end
	usedTrinkets[guid] = true
	if not trinketFrame[guid] then 
		trinketFrame[guid] = CreateFrame("Frame")
	end
	trinketFrame[guid].endTime = GetTime() + time
	trinketFrame[guid].guid = guid
	trinketFrame[guid]:SetScript("OnUpdate", TrinketUpdate)
end

local Update = function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, _, sourceGUID, _, _, _, _, _, _, _, spellID = ...
		if eventType == "SPELL_CAST_SUCCESS" then
			-- enemy trinket usage
			if spellID == 59752 or spellID == 42292 then
				TrinketUsed(sourceGUID, 120)
			end
			-- WotF
			if spellID == 7744 then
				TrinketUsed(sourceGUID, 45)
			end
		end
	elseif event == "ARENA_OPPONENT_UPDATE" then
		local unit, type = ...
		if type == "seen" then
			if UnitExists(unit) and UnitIsPlayer(unit) and arenaFrame[unit] then
				arenaGUID[UnitGUID(unit)] = unit
				arenaFrame[unit].Trinket.Icon:SetTexture(GetTrinketIcon(unit))
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		for k, v in pairs(trinketFrame) do
			v:SetScript("OnUpdate", nil)
		end
		for k, v in pairs(arenaFrame) do
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
	if usedTrinkets[UnitGUID(unit)] or not UnitIsPlayer(unit) then return end
	return string.format("|T%s:20:20:0:0|t", GetTrinketIcon(unit))
end

local Enable = function(self)
	if self.Trinket then
		self.Trinket.cooldownFrame = CreateFrame("Cooldown", nil, self.Trinket)
		self.Trinket.cooldownFrame:SetAllPoints(self.Trinket)
		self.Trinket.Icon = self.Trinket:CreateTexture(nil, "BORDER")
		self.Trinket.Icon:SetAllPoints(self.Trinket)
		self.Trinket.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		arenaFrame[self.unit] = self
	end
end
 
local Disable = function(self)
	if self.Trinket then
		arenaFrame[self.unit] = nil
	end
end
 
oUF:AddElement('Trinket', function() return end, Enable, Disable)