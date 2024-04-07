local E, L, V, P, G = unpack(ElvUI)
if not (E.Wrath or E.ClassicSOD) then return end
local DT = E:GetModule('DataTexts')

local _G = _G
local format, strjoin = format, strjoin
local HideUIPanel = HideUIPanel
local IsShiftKeyDown = IsShiftKeyDown
local ShowUIPanel = ShowUIPanel

local LEVEL_UP_DUALSPEC = LEVEL_UP_DUALSPEC
local MAX_TALENT_TABS = MAX_TALENT_TABS
local PRIMARY = PRIMARY
local SECONDARY = SECONDARY

local GetActiveTalentGroup = GetActiveTalentGroup
local GetNumTalentGroups = GetNumTalentGroups
local SetActiveTalentGroup = SetActiveTalentGroup
local GetTalentTabInfo = GetTalentTabInfo

local LoadAddOn = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn

local displayString, db = ''
local primaryStr, secondaryStr, activeGroup, hasDualSpec = '', ''

local function BuildTalentString(talentGroup)
	local str = ''

	for i = 1, MAX_TALENT_TABS do
		local _, _, pointsSpent = GetTalentTabInfo(i, false, false, talentGroup)
		str = (str == '' and pointsSpent) or strjoin('/', str, pointsSpent)
	end

	return str
end

local function OnEvent(self)
	primaryStr, secondaryStr = BuildTalentString(1), BuildTalentString(2)

	activeGroup = GetActiveTalentGroup()
	local str = activeGroup == 1 and primaryStr or secondaryStr

	if not hasDualSpec then
		hasDualSpec = GetNumTalentGroups() == 2
	end

	self.text:SetFormattedText(displayString, db.NoLabel and str or activeGroup == 1 and PRIMARY or SECONDARY, str)
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(format('|cff%s%s:|r %s', activeGroup == 1 and '0CD809' or 'FFFFFF', PRIMARY, primaryStr), 1, 1, 1)

	if hasDualSpec then
		DT.tooltip:AddLine(format('|cff%s%s:|r %s', activeGroup == 2 and '0CD809' or 'FFFFFF', SECONDARY, secondaryStr), 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')

	if hasDualSpec then
		DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
	end

	DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"])
	DT.tooltip:Show()
end

local function OnClick(_, button)
	if button == 'LeftButton' then
		if not _G.PlayerTalentFrame then
			LoadAddOn('Blizzard_TalentUI')
		end

		if IsShiftKeyDown() then
			if not _G.PlayerTalentFrame:IsShown() then
				ShowUIPanel(_G.PlayerTalentFrame)
			else
				HideUIPanel(_G.PlayerTalentFrame)
			end
		elseif hasDualSpec then
			SetActiveTalentGroup(activeGroup == 1 and 2 or 1)
		end
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s: ', hex, '%s|r')
end

DT:RegisterDatatext('DualSpecialization', nil, { 'CHARACTER_POINTS_CHANGED', 'ACTIVE_TALENT_GROUP_CHANGED' }, OnEvent, nil, OnClick, OnEnter, nil, LEVEL_UP_DUALSPEC, nil, ApplySettings)
