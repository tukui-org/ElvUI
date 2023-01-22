local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local M = E:GetModule('Minimap')

local _G = _G
local strjoin = strjoin
local EasyMenu = EasyMenu
local ToggleFrame = ToggleFrame
local displayString = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, L["Micro Bar"])
end

local function OnClick(self, button)
	if button == 'LeftButton' then
		ToggleFrame(_G.GameMenuFrame)
	else
		E:SetEasyMenuAnchor(E.EasyMenu, self)
		EasyMenu(M.RightClickMenuList, E.EasyMenu, nil, nil, nil, 'MENU')
	end
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', hex, '%s|r')

	OnEvent(self)
end

DT:RegisterDatatext("Micro Bar", nil, nil, OnEvent, nil, OnClick, nil, nil, L["Micro Bar"], nil, ValueColorUpdate)
