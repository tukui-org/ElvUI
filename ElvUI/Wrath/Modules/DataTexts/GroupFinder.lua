local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local pairs, strjoin = pairs, strjoin
local InCombatLockdown = InCombatLockdown

local displayString = ''
local configText = 'Group Finder'
local lastPanel

local function OnEvent(self)
	lastPanel = self
	self.text:SetFormattedText(displayString, E.global.datatexts.settings.ElvUI.Label ~= '' and E.global.datatexts.settings.ElvUI.Label or configText)
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddDoubleLine(L["Left Click:"], L["Open Group Finder"], 1, 1, 1)

	DT.tooltip:Show()
end

local function OnClick(self, button)
	if button == 'LeftButton' then
		if not IsAddOnLoaded('Blizzard_LookingForGroupUI') then
			UIParentLoadAddOn('Blizzard_LookingForGroupUI')
		end
		_G.ToggleLFGParentFrame()
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin(hex, '%s|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Group Finder', nil, nil, OnEvent, nil, OnClick, OnEnter, nil, L["Group Finder"], nil, ValueColorUpdate)
