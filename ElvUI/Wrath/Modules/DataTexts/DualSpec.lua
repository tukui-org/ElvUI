local E, L, V, P, G = unpack(ElvUI)
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

local primaryStr, secondaryStr, activeGroup, hasDualSpec

local function BuildTalentString(talentGroup)
	local str = ''

	for i = 1, MAX_TALENT_TABS do
		local _, _, pointsSpent = GetTalentTabInfo(i, false, false, talentGroup)
		if (str == '') then
			str = pointsSpent
		else
			str = strjoin('/', str, pointsSpent)
		end
	end

	return str
end

local function ColorText(str, hex)
	return format('|cff%s%s|r',hex,str)
end

local displayString, lastPanel = ''
local function OnEvent(self, event)
	lastPanel = self

	primaryStr, secondaryStr = BuildTalentString(1), BuildTalentString(2)

	activeGroup = GetActiveTalentGroup()
	local str = activeGroup == 1 and primaryStr or secondaryStr

	if not hasDualSpec then
		hasDualSpec = GetNumTalentGroups() == 2
	end

	self.text:SetFormattedText(displayString, E.global.datatexts.settings.DualSpecialization.NoLabel and str or activeGroup == 1 and PRIMARY or SECONDARY, str)
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddDoubleLine(format('%s: %s', ColorText(PRIMARY, activeGroup == 1 and '0CD809' or 'FFFFFF'), primaryStr))

	if hasDualSpec then
		DT.tooltip:AddDoubleLine(format('%s: %s', ColorText(SECONDARY, activeGroup == 2 and '0CD809' or 'FFFFFF'), secondaryStr))
	end

	DT.tooltip:AddLine(' ')

	if hasDualSpec then
		DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
	end

	DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"])
	DT.tooltip:Show()
end

local function OnClick(self, button)
	if button == 'LeftButton' then
		if not _G.PlayerTalentFrame then
			_G.LoadAddOn('Blizzard_TalentUI')
		end
		if IsShiftKeyDown() then
			if not _G.PlayerTalentFrame:IsShown() then
				ShowUIPanel(_G.PlayerTalentFrame)
			else
				HideUIPanel(_G.PlayerTalentFrame)
			end
		else
			if hasDualSpec then
				SetActiveTalentGroup(activeGroup == 1 and 2 or 1)
			end
		end
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.DualSpecialization.NoLabel and '' or '%s: ', hex, '%s|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('DualSpecialization', nil, { 'CHARACTER_POINTS_CHANGED', 'ACTIVE_TALENT_GROUP_CHANGED' }, OnEvent, nil, OnClick, OnEnter, nil, LEVEL_UP_DUALSPEC, nil, ValueColorUpdate)
