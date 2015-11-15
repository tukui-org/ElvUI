local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc');

--Cache global variables
--Lua functions
local _G = _G
local min, max = math.min, math.max
local format = string.format
--WoW API / Variables
local CreateFrame = CreateFrame
local GetPetExperience = GetPetExperience
local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local UnitLevel = UnitLevel
local IsXPUserDisabled = IsXPUserDisabled
local GetXPExhaustion = GetXPExhaustion
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetNumFactions = GetNumFactions
local GetFactionInfo = GetFactionInfo
local GetFriendshipReputation = GetFriendshipReputation
local GetExpansionLevel = GetExpansionLevel
local STANDING = STANDING
local REPUTATION = REPUTATION
local FACTION_BAR_COLORS = FACTION_BAR_COLORS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: MAX_PLAYER_LEVEL, GameTooltip, ElvUI_ExperienceBar, ElvUI_ReputationBar
-- GLOBALS: MAX_PLAYER_LEVEL_TABLE, LeftChatPanel, RightChatPanel

function M:GetXP(unit)
	if(unit == 'pet') then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

function M:UpdateExperience(event)
	local bar = self.expBar

	if(UnitLevel('player') == MAX_PLAYER_LEVEL) or IsXPUserDisabled() then
		bar:Hide()
	else
		bar:Show()

		local cur, max = self:GetXP('player')
		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		bar.statusBar:SetValue(cur)

		local rested = GetXPExhaustion()
		local text = ''
		local textFormat = E.db.general.experience.textFormat

		if rested and rested > 0 then
			bar.rested:SetMinMaxValues(0, max)
			bar.rested:SetValue(min(cur + rested, max))

			if textFormat == 'PERCENT' then
				text = format('%d%% R:%d%%', cur / max * 100, rested / max * 100)
			elseif textFormat == 'CURMAX' then
				text = format('%s - %s R:%s', E:ShortValue(cur), E:ShortValue(max), E:ShortValue(rested))
			elseif textFormat == 'CURPERC' then
				text = format('%s - %d%% R:%s [%d%%]', E:ShortValue(cur), cur / max * 100, E:ShortValue(rested), rested / max * 100)
			end
		else
			bar.rested:SetMinMaxValues(0, 1)
			bar.rested:SetValue(0)

			if textFormat == 'PERCENT' then
				text = format('%d%%', cur / max * 100)
			elseif textFormat == 'CURMAX' then
				text = format('%s - %s', E:ShortValue(cur), E:ShortValue(max))
			elseif textFormat == 'CURPERC' then
				text = format('%s - %d%%', E:ShortValue(cur), cur / max * 100)
			end
		end

		bar.text:SetText(text)
	end
end

local backupColor = FACTION_BAR_COLORS[1]
local FactionStandingLabelUnknown = UNKNOWN
function M:UpdateReputation(event)
	local bar = self.repBar

	local ID
	local isFriend, friendText, standingLabel
	local name, reaction, min, max, value = GetWatchedFactionInfo()
	local numFactions = GetNumFactions();

	if not name then
		bar:Hide()
	else
		bar:Show()

		local text = ''
		local textFormat = E.db.general.reputation.textFormat
		local color = FACTION_BAR_COLORS[reaction] or backupColor
		bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

		bar.statusBar:SetMinMaxValues(min, max)
		bar.statusBar:SetValue(value)

		for i=1, numFactions do
			local factionName, _, standingID,_,_,_,_,_,_,_,_,_,_, factionID = GetFactionInfo(i);
			local friendID, friendRep, friendMaxRep, _, _, _, friendTextLevel = GetFriendshipReputation(factionID);
			if factionName == name then
				if friendID ~= nil then
					isFriend = true
					friendText = friendTextLevel
				else
					ID = standingID
				end
			end
		end
		
		if ID then
			standingLabel = _G['FACTION_STANDING_LABEL'..ID]
		else
			standingLabel = FactionStandingLabelUnknown
		end

		if textFormat == 'PERCENT' then
			text = format('%s: %d%% [%s]', name, ((value - min) / (max - min) * 100), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURMAX' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue(max - min), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURPERC' then
			text = format('%s: %s - %d%% [%s]', name, E:ShortValue(value - min), ((value - min) / (max - min) * 100), isFriend and friendText or standingLabel)
		end

		bar.text:SetText(text)
	end
end

local function ExperienceBar_OnEnter(self)
	if E.db.general.experience.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local cur, max = M:GetXP('player')
	local rested = GetXPExhaustion()
	GameTooltip:AddLine(L["Experience"])
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%d%%)', cur, max, cur/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	if rested then
		GameTooltip:AddDoubleLine(L["Rested:"], format('+%d (%d%%)', rested, rested / max * 100), 1, 1, 1)
	end

	GameTooltip:Show()
end

local function ReputationBar_OnEnter(self)
	if E.db.general.reputation.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
	local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID);
	if name then
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(' ')

		GameTooltip:AddDoubleLine(STANDING..':', friendID and friendTextLevel or _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		GameTooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
	end
	GameTooltip:Show()
end

local function OnLeave(self)
	if (self == ElvUI_ExperienceBar and E.db.general.experience.mouseover) or (self == ElvUI_ReputationBar and E.db.general.reputation.mouseover) then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end
	GameTooltip:Hide()
end

function M:CreateBar(name, onEnter, ...)
	local bar = CreateFrame('Button', name, E.UIParent)
	bar:Point(...)
	bar:SetScript('OnEnter', onEnter)
	bar:SetScript('OnLeave', OnLeave)
	bar:SetFrameStrata('LOW')
	bar:SetTemplate('Transparent')
	bar:Hide()

	bar.statusBar = CreateFrame('StatusBar', nil, bar)
	bar.statusBar:SetInside()
	bar.statusBar:SetStatusBarTexture(E.media.normTex)

	bar.text = bar.statusBar:CreateFontString(nil, 'OVERLAY')
	bar.text:FontTemplate()
	bar.text:SetPoint('CENTER')

	E.FrameLocks[name] = true

	return bar
end

function M:UpdateExpRepDimensions()
	self.expBar:Width(E.db.general.experience.width)
	self.expBar:Height(E.db.general.experience.height)

	self.repBar:Width(E.db.general.reputation.width)
	self.repBar:Height(E.db.general.reputation.height)

	self.repBar.text:FontTemplate(nil, E.db.general.reputation.textSize)
	self.expBar.text:FontTemplate(nil, E.db.general.experience.textSize)

	self.expBar.statusBar:SetOrientation(E.db.general.experience.orientation)
	self.repBar.statusBar:SetOrientation(E.db.general.reputation.orientation)
	self.expBar.rested:SetOrientation(E.db.general.experience.orientation)
	self.expBar.statusBar:SetReverseFill(E.db.general.experience.reverseFill)
	self.repBar.statusBar:SetReverseFill(E.db.general.reputation.reverseFill)
	self.expBar.rested:SetReverseFill(E.db.general.experience.reverseFill)

	if E.db.general.experience.mouseover then
		self.expBar:SetAlpha(0)
	else
		self.expBar:SetAlpha(1)
	end

	if E.db.general.reputation.mouseover then
		self.repBar:SetAlpha(0)
	else
		self.repBar:SetAlpha(1)
	end
end

function M:EnableDisable_ExperienceBar()
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()];
	if UnitLevel('player') ~= maxLevel and E.db.general.experience.enable then
		self:RegisterEvent('PLAYER_XP_UPDATE', 'UpdateExperience')
		self:RegisterEvent('PLAYER_LEVEL_UP', 'UpdateExperience')
		self:RegisterEvent("DISABLE_XP_GAIN", 'UpdateExperience')
		self:RegisterEvent("ENABLE_XP_GAIN", 'UpdateExperience')
		self:RegisterEvent('UPDATE_EXHAUSTION', 'UpdateExperience')
		self:UnregisterEvent("UPDATE_EXPANSION_LEVEL")
		self:UpdateExperience()
	else
		self:UnregisterEvent('PLAYER_XP_UPDATE')
		self:UnregisterEvent('PLAYER_LEVEL_UP')
		self:UnregisterEvent("DISABLE_XP_GAIN")
		self:UnregisterEvent("ENABLE_XP_GAIN")
		self:UnregisterEvent('UPDATE_EXHAUSTION')
		self:RegisterEvent("UPDATE_EXPANSION_LEVEL", "EnableDisable_ExperienceBar")
		self.expBar:Hide()
	end
end

function M:EnableDisable_ReputationBar()
	if E.db.general.reputation.enable then
		self:RegisterEvent('UPDATE_FACTION', 'UpdateReputation')
		self:UpdateReputation()
	else
		self:UnregisterEvent('UPDATE_FACTION')
		self.repBar:Hide()
	end
end

function M:LoadExpRepBar()
	self.expBar = self:CreateBar('ElvUI_ExperienceBar', ExperienceBar_OnEnter, 'LEFT', LeftChatPanel, 'RIGHT', E.PixelMode and -1 or 1, 0)
	self.expBar.statusBar:SetStatusBarColor(0, 0.4, 1, .8)
	self.expBar.rested = CreateFrame('StatusBar', nil, self.expBar)
	self.expBar.rested:SetInside()
	self.expBar.rested:SetStatusBarTexture(E.media.normTex)
	self.expBar.rested:SetStatusBarColor(1, 0, 1, 0.2)

	self.repBar = self:CreateBar('ElvUI_ReputationBar', ReputationBar_OnEnter, 'RIGHT', RightChatPanel, 'LEFT', E.PixelMode and 1 or -1, 0)

	self:UpdateExpRepDimensions()

	self:EnableDisable_ExperienceBar()
	self:EnableDisable_ReputationBar()

	E:CreateMover(self.expBar, "ExperienceBarMover", L["Experience Bar"])
	E:CreateMover(self.repBar, "ReputationBarMover", L["Reputation Bar"])
end