local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs, wipe = ipairs, wipe
local format, next, strjoin = format, next, strjoin
local HideUIPanel = HideUIPanel
local IsShiftKeyDown = IsShiftKeyDown
local ShowUIPanel = ShowUIPanel

local TALENTS = TALENTS
local LEVEL_UP_DUALSPEC = LEVEL_UP_DUALSPEC
local MAX_TALENT_TABS = MAX_TALENT_TABS
local PRIMARY = PRIMARY
local SECONDARY = SECONDARY

local GetActiveTalentGroup = GetActiveTalentGroup
local GetNumTalentGroups = GetNumTalentGroups
local SetActiveTalentGroup = SetActiveTalentGroup
local GetTalentTabInfo = GetTalentTabInfo


local function BuildTalentString(talentGroup)
	local str = ''

	for i = 1, MAX_TALENT_TABS do
		local pointsSpent = select(3, GetTalentTabInfo(i, false, false, talentGroup));
		if (str == '') then
			str = pointsSpent
		else
			str = strjoin('/', str, pointsSpent)
		end
	end

	return str
end

local displayString, lastPanel = ''
local function OnEvent(self, event)
	lastPanel = self

	local activeGroup = GetActiveTalentGroup()
	local str = BuildTalentString(activeGroup)

	if E.global.datatexts.settings.DualSpec.NoLabel then
		self.text:SetFormattedText('%s', str)
	else
		self.text:SetFormattedText('%s: %s', activeGroup == 1 and PRIMARY or SECONDARY, str)
	end
end

local function OnEnter()
	local activeGroup = GetActiveTalentGroup()

	if activeGroup == 1 then
		DT.tooltip:AddLine(SPECIALIZATION_PRIMARY_ACTIVE)
		DT.tooltip:AddLine(SPECIALIZATION_SECONDARY)
	else
		DT.tooltip:AddLine(SPECIALIZATION_PRIMARY)
		DT.tooltip:AddLine(SPECIALIZATION_SECONDARY_ACTIVE)
	end
	-- thinking something like (active highlighted in green)
	--[[
		Primary: 56/3/12
		Secondary: 18/0/53
	]]



	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
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
			if GetNumTalentGroups() == 2 then
				SetActiveTalentGroup(GetActiveTalentGroup() == 1 and 2 or 1)
			end
		end
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.DualSpec.NoLabel and '' or '%s', hex, '%d|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Dual Specialization', nil, { 'CHARACTER_POINTS_CHANGED', 'ACTIVE_TALENT_GROUP_CHANGED' }, OnEvent, nil, OnClick, OnEnter, nil, LEVEL_UP_DUALSPEC)
