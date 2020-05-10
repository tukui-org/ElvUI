local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local _G = _G
local pairs, strfind, strjoin = pairs, strfind, strjoin
--WoW API / Variables
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMetadata = GetAddOnMetadata
local GetNumAddOns = GetNumAddOns
local IsShiftKeyDown = IsShiftKeyDown
local ReloadUI = ReloadUI
local InCombatLockdown = InCombatLockdown

local displayString = ""
local configText = "ElvUI"
local reloadText = RELOADUI
local plugins, lastPanel

local function OnEvent(self)
	lastPanel = self

	for i = 1, GetNumAddOns() do
		local name, _, _, enabled = GetAddOnInfo(i)
		if enabled and strfind(name, "ElvUI") and not (name == "ElvUI") then
			plugins = plugins or {}
			local version = GetAddOnMetadata(i, "version")
			plugins[name] = version
		end
	end

	self.text:SetFormattedText(displayString, configText)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Left Click:"], L["Toggle Configuration"], 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Hold Shift + Right Click:"], reloadText, 1, 1, 1)
	if plugins then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddDoubleLine("Plugins:", "Version:")
		for plugin, version in pairs(plugins) do
			DT.tooltip:AddDoubleLine(plugin, version, 1, 1, 1, 1, 1, 1)
		end
	end

	DT.tooltip:Show()
end

local function Click(_, button)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
	if button == "LeftButton" or (button == "RightButton" and not IsShiftKeyDown()) then
		E:ToggleOptionsUI()
	elseif button == "RightButton" and IsShiftKeyDown() then
		ReloadUI()
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('ElvUI Config', nil, nil, OnEvent, nil, Click, OnEnter)
