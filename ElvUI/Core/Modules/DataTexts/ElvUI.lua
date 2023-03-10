local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local pairs, strjoin = pairs, strjoin
local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local ReloadUI = ReloadUI

local displayString, db = ''
local configText = 'ElvUI'
local reloadText = RELOADUI

local function OnEvent(self)
	self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or configText)
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddDoubleLine(L["Left Click:"], L["Toggle Configuration"], 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Hold Shift + Right Click:"], reloadText, 1, 1, 1)

	if E.Libs.EP.registeredPrefix then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine('Plugins:', 'Version:')

		for _, plugin in pairs(E.Libs.EP.plugins) do
			if not plugin.isLib then
				local r, g, b = plugin.old and 1 or .2, plugin.old and .2 or 1, .2
				DT.tooltip:AddDoubleLine(plugin.title, plugin.version, 1, 1, 1, r, g, b)
			end
		end
	end

	DT.tooltip:Show()
end

local function OnClick(_, button)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if button == 'LeftButton' then
		E:ToggleOptions()
	elseif button == 'RightButton' and IsShiftKeyDown() then
		ReloadUI()
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', hex, '%s|r')
end

DT:RegisterDatatext('ElvUI', nil, nil, OnEvent, nil, OnClick, OnEnter, nil, configText, nil, ApplySettings)
