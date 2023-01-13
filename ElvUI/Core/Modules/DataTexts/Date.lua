local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local date = date
local InCombatLockdown = InCombatLockdown
local FormatShortDate = FormatShortDate

local displayString, lastPanel

local function OnClick()
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
	_G.GameTimeFrame:Click()
end

local function OnEvent(self)
	local dateTable = date('*t')

	self.text:SetText(FormatShortDate(dateTable.day, dateTable.month, dateTable.year):gsub('([/.])', displayString))
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = hex..'%1|r'

	if lastPanel ~= nil then OnEvent(lastPanel) end
end

DT:RegisterDatatext('Date', nil, {'UPDATE_INSTANCE_INFO'}, OnEvent, nil, OnClick, nil, nil, nil, nil, ValueColorUpdate)
