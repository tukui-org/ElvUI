local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local pairs = pairs
local find, join = string.find, string.join
--WoW API / Variables
local GetNumAddOns = GetNumAddOns
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMetadata = GetAddOnMetadata
local IsShiftKeyDown = IsShiftKeyDown
local ReloadUI = ReloadUI

local displayString = ""
local configText = "ElvUI Config"
local reloadText = RELOADUI
local plugins
local lastPanel

local function OnEvent(self, event, ...)
	lastPanel = self
	
	if event == "PLAYER_ENTERING_WORLD" then
		for i = 1, GetNumAddOns() do
			local name, _, _, enabled = GetAddOnInfo(i)
			if enabled and find(name, "ElvUI") and not (name == "ElvUI") then
				plugins = plugins or {}
				local version = GetAddOnMetadata(i, "version")
				plugins[name] = version
			end
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

local function Click(self, button)
	if button == "LeftButton" or (button == "RightButton" and not IsShiftKeyDown()) then
		E:ToggleConfig()
	elseif button == "RightButton" and IsShiftKeyDown() then
		ReloadUI()
	end
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]
DT:RegisterDatatext('ElvUI Config', {'PLAYER_ENTERING_WORLD'}, OnEvent, nil, Click, OnEnter)
