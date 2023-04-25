local E, L, V, P, G, _ = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format

local UnitAffectingCombat = UnitAffectingCombat
local IsResting = IsResting

local C_PvP_IsWarModeActive = C_PvP.IsWarModeActive
local C_PvP_IsWarModeDesired = C_PvP.IsWarModeDesired
local C_PvP_ToggleWarMode = C_PvP.ToggleWarMode
local C_PvP_CanToggleWarMode = C_PvP.CanToggleWarMode
local C_PvP_CanToggleWarModeInArea = C_PvP.CanToggleWarModeInArea
local C_PvP_GetWarModeRewardBonus = C_PvP.GetWarModeRewardBonus

local FACTION_HORDE = PLAYER_FACTION_GROUP[0]
local RED_FONT_COLOR, GREEN_FONT_COLOR = RED_FONT_COLOR, GREEN_FONT_COLOR
local PVP_WAR_MODE_DESCRIPTION_FORMAT = PVP_WAR_MODE_DESCRIPTION_FORMAT
local PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA = PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA
local PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA = PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA
local PVP_WAR_MODE_NOT_NOW_ALLIANCE = PVP_WAR_MODE_NOT_NOW_ALLIANCE
local PVP_WAR_MODE_NOT_NOW_HORDE = PVP_WAR_MODE_NOT_NOW_HORDE
local PVP_WAR_MODE_ENABLED = PVP_WAR_MODE_ENABLED
local PVP_LABEL_WAR_MODE = PVP_LABEL_WAR_MODE
local NOT_APPLICABLE = NOT_APPLICABLE

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(PVP_LABEL_WAR_MODE, 1, 1, 1)
	if C_PvP_IsWarModeActive() or C_PvP_IsWarModeDesired() then
		DT.tooltip:AddLine(PVP_WAR_MODE_ENABLED, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, false)
	end

	local warModeRewardBonus = C_PvP_GetWarModeRewardBonus()
	DT.tooltip:AddLine(format(PVP_WAR_MODE_DESCRIPTION_FORMAT, warModeRewardBonus))

	local canToggleWarmode = C_PvP_CanToggleWarMode(true)
	local canToggleWarmodeOFF = C_PvP_CanToggleWarMode(false)

	local warmodeErrorText
	if not canToggleWarmode or not canToggleWarmodeOFF then

		if not C_PvP_CanToggleWarModeInArea() then
			if C_PvP_IsWarModeDesired() then
				if not canToggleWarmodeOFF and not IsResting() then
					warmodeErrorText = E.myfaction == FACTION_HORDE and PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA or PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA
				end
			elseif not canToggleWarmode then
				warmodeErrorText = E.myfaction == FACTION_HORDE and PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE
			end
		end

		DT.tooltip:AddLine(warmodeErrorText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
	end

	DT.tooltip:Show()
end

local function OnClick(_, button)
	if button == 'LeftButton' and not UnitAffectingCombat('player') and C_PvP_CanToggleWarMode(not C_PvP_IsWarModeActive()) then
		C_PvP_ToggleWarMode()
	end
end

local function OnEvent(self)
	local wm = C_PvP_IsWarModeDesired()
	local color, icon = wm and RED_FONT_COLOR or GREEN_FONT_COLOR, wm and [[|TInterface\Icons\ui_warmode:16:16|t]] or ''

	self.text:SetFormattedText(wm and '%s %s %s' or '%s%s%s', icon, E:RGBToHex(color.r, color.g, color.b, nil, PVP_LABEL_WAR_MODE or NOT_APPLICABLE), icon)
end

DT:RegisterDatatext('WarMode', nil, {'WAR_MODE_STATUS_UPDATE', 'PLAYER_FLAGS_CHANGED'}, OnEvent, nil, OnClick, OnEnter, nil, PVP_LABEL_WAR_MODE)
