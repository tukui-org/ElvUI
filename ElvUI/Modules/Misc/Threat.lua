local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local THREAT = E:GetModule('Threat')
local DT = E:GetModule('DataTexts')

--Lua functions
local _G = _G
local pairs, select, wipe = pairs, select, wipe
--WoW API / Variables
local CreateFrame = CreateFrame
local GetThreatStatusColor = GetThreatStatusColor
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local UnitClass = UnitClass
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitReaction = UnitReaction
local UNKNOWN = UNKNOWN
-- GLOBALS: ElvUF

THREAT.list = {}

function THREAT:UpdatePosition()
	if self.db.position == 'RIGHTCHAT' then
		self.bar:SetInside(_G.RightChatDataPanel)
		self.bar:SetParent(_G.RightChatDataPanel)
	else
		self.bar:SetInside(_G.LeftChatDataPanel)
		self.bar:SetParent(_G.LeftChatDataPanel)
	end

	self.bar.text:FontTemplate(nil, self.db.textSize)
	self.bar:SetFrameStrata('MEDIUM')
end

function THREAT:GetLargestThreatOnList(percent)
	local largestValue, largestUnit = 0, nil
	for unit, threatPercent in pairs(self.list) do
		if threatPercent > largestValue then
			largestValue = threatPercent
			largestUnit = unit
		end
	end

	return (percent - largestValue), largestUnit
end

function THREAT:GetColor(unit)
	local unitReaction = UnitReaction(unit, 'player')
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[unitClass] or _G.RAID_CLASS_COLORS[unitClass]
		if not class then return 194, 194, 194 end
		return class.r*255, class.g*255, class.b*255
	elseif (unitReaction) then
		local reaction = ElvUF.colors.reaction[unitReaction]
		return reaction[1]*255, reaction[2]*255, reaction[3]*255
	else
		return 194, 194, 194
	end
end

function THREAT:Update()
	if DT and DT.ShowingBGStats then
		if self.bar:IsShown() then
			self.bar:Hide()
		end

		return
	end

	local isInGroup, isInRaid, petExists = IsInGroup(), IsInRaid(), UnitExists('pet')
	local _, status, percent = UnitDetailedThreatSituation('player', 'target')
	if percent and percent > 0 and (isInGroup or petExists) then
		local name = UnitName('target')
		self.bar:Show()
		if percent == 100 then
			--Build threat list
			if petExists then
				self.list.pet = select(3, UnitDetailedThreatSituation('pet', 'target'))
			end

			if isInRaid then
				for i=1, 40 do
					if UnitExists('raid'..i) and not UnitIsUnit('raid'..i, 'player') then
						self.list['raid'..i] = select(3, UnitDetailedThreatSituation('raid'..i, 'target'))
					end
				end
			else
				for i=1, 4 do
					if UnitExists('party'..i) then
						self.list['party'..i] = select(3, UnitDetailedThreatSituation('party'..i, 'target'))
					end
				end
			end

			local leadPercent, largestUnit = self:GetLargestThreatOnList(percent)
			if leadPercent > 0 and largestUnit ~= nil then
				local r, g, b = self:GetColor(largestUnit)
				self.bar.text:SetFormattedText(L["ABOVE_THREAT_FORMAT"], name, percent, leadPercent, r, g, b, UnitName(largestUnit) or UNKNOWN)

				if E.myrole == 'TANK' then
					self.bar:SetStatusBarColor(0, 0.839, 0)
					self.bar:SetValue(leadPercent)
				else
					self.bar:SetStatusBarColor(GetThreatStatusColor(status))
					self.bar:SetValue(percent)
				end
			else
				self.bar:SetStatusBarColor(GetThreatStatusColor(status))
				self.bar.text:SetFormattedText('%s: %.0f%%', name, percent)
				self.bar:SetValue(percent)
			end
		else
			self.bar:SetStatusBarColor(GetThreatStatusColor(status))
			self.bar.text:SetFormattedText('%s: %.0f%%', name, percent)
			self.bar:SetValue(percent)
		end
	else
		self.bar:Hide()
	end

	wipe(self.list)
end

function THREAT:ToggleEnable()
	if self.db.enable then
		self:RegisterEvent('PLAYER_TARGET_CHANGED', 'Update')
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', 'Update')
		self:RegisterEvent('GROUP_ROSTER_UPDATE', 'Update')
		self:RegisterEvent('UNIT_PET', 'Update')
		self:Update()
	else
		self.bar:Hide()
		self:UnregisterEvent('PLAYER_TARGET_CHANGED')
		self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE')
		self:UnregisterEvent('GROUP_ROSTER_UPDATE')
		self:UnregisterEvent('UNIT_PET')
	end
end

function THREAT:Initialize()
	self.Initialized = true
	self.db = E.db.general.threat

	self.bar = CreateFrame('StatusBar', 'ElvUI_ThreatBar', E.UIParent)
	self.bar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(self.bar)
	self.bar:SetMinMaxValues(0, 100)
	self.bar:CreateBackdrop()

	self.bar.text = self.bar:CreateFontString(nil, 'OVERLAY')
	self.bar.text:FontTemplate(nil, self.db.textSize, self.db.textOutline)
	self.bar.text:Point('CENTER', self.bar, 'CENTER')

	self:UpdatePosition()
	self:ToggleEnable()
end

E:RegisterModule(THREAT:GetName())
