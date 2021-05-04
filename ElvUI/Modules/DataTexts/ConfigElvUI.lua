local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local pairs, strjoin = pairs, strjoin
local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local ReloadUI = ReloadUI

local displayString = ''
local configText = 'ElvUI'
local reloadText = RELOADUI
local lastPanel

local function OnEvent(self)
	lastPanel = self
	self.text:SetFormattedText(displayString, E.global.datatexts.settings.ElvUI.Label ~= '' and E.global.datatexts.settings.ElvUI.Label or configText)
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
				local r, g, b = E:HexToRGB(plugin.old and 'ff3333' or '33ff33')
				DT.tooltip:AddDoubleLine(plugin.title, plugin.version, 1, 1, 1, r/255, g/255, b/255)
			end
		end
	end

	DT.tooltip:Show()
end

local function OnClick(_, button)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if button == 'LeftButton' then
		E:ToggleOptionsUI()
	elseif button == 'RightButton' and IsShiftKeyDown() then
		ReloadUI()
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', hex, '%s|r')

	if lastPanel then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('ElvUI', nil, nil, OnEvent, nil, OnClick, OnEnter, nil, L['ElvUI Config'], nil, ValueColorUpdate)
