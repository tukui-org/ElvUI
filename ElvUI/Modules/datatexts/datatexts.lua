local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:NewModule('DataTexts', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')
local LDB = LibStub:GetLibrary("LibDataBroker-1.1");
local LSM = LibStub("LibSharedMedia-3.0")
local TT = E:GetModule("Tooltip")

--Cache global variables
--Lua functions
local pairs, type, error = pairs, type, error
local len = string.len
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitGUID = UnitGUID
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, ElvConfigToggle

function DT:Initialize()
	--if E.db["datatexts"].enable ~= true then return end
	E.DataTexts = DT

	self.tooltip = CreateFrame("GameTooltip", "DatatextTooltip", E.UIParent, "GameTooltipTemplate")
	TT:HookScript(self.tooltip, 'OnShow', 'SetStyle')

	self:RegisterLDB()
	self:LoadDataTexts()

	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'LoadDataTexts')
	--self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'LoadDataTexts') -- is this needed??
end

DT.RegisteredPanels = {}
DT.RegisteredDataTexts = {}

DT.PointLocation = {
	[1] = 'middle',
	[2] = 'left',
	[3] = 'right',
}

local hex = '|cffFFFFFF'
function DT:RegisterLDB()
	for name, obj in LDB:DataObjectIterator() do
		local OnEnter = nil;
		local OnLeave = nil;
		local curFrame = nil;
		if obj.OnTooltipShow then
			function OnEnter(self)
				DT:SetupTooltip(self)
				obj.OnTooltipShow(DT.tooltip)
				DT.tooltip:Show()
			end
		end

		if obj.OnEnter then
			function OnEnter(self)
				DT:SetupTooltip(self)
				obj.OnEnter(self)
				DT.tooltip:Show()
			end
		end

		if obj.OnLeave then
			function OnLeave(self)
				obj.OnLeave(self)
				DT.tooltip:Hide()
			end
		end

		local function OnClick(self, button)
			obj.OnClick(self, button)
		end

		local function textUpdate(event, name, key, value, dataobj)
			if value == nil or (len(value) >= 3) or value == 'n/a' or name == value then
				curFrame.text:SetText(value ~= 'n/a' and value or name)
			else
				curFrame.text:SetFormattedText("%s: %s%s|r", name, hex, value)
			end
		end

		local function OnEvent(self)
			curFrame = self
			LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..name.."_text", textUpdate)
			LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..name.."_value", textUpdate)
			LDB.callbacks:Fire("LibDataBroker_AttributeChanged_"..name.."_text", name, nil, obj.text, obj)
		end

		self:RegisterDatatext(name, {'PLAYER_ENTER_WORLD'}, OnEvent, nil, OnClick, OnEnter, OnLeave)
	end
end

local function ValueColorUpdate(newHex)
	hex = newHex
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

function DT:GetDataPanelPoint(panel, i, numPoints)
	if numPoints == 1 then
		return 'CENTER', panel, 'CENTER'
	else
		if i == 1 then
			return 'CENTER', panel, 'CENTER'
		elseif i == 2 then
			return 'RIGHT', panel.dataPanels['middle'], 'LEFT', -4, 0
		elseif i == 3 then
			return 'LEFT', panel.dataPanels['middle'], 'RIGHT', 4, 0
		end
	end
end

function DT:UpdateAllDimensions()
	for panelName, panel in pairs(DT.RegisteredPanels) do
		local width = (panel:GetWidth() / panel.numPoints) - 4
		local height = panel:GetHeight() - 4
		for i=1, panel.numPoints do
			local pointIndex = DT.PointLocation[i]
			panel.dataPanels[pointIndex]:Width(width)
			panel.dataPanels[pointIndex]:Height(height)
			panel.dataPanels[pointIndex]:Point(DT:GetDataPanelPoint(panel, i, panel.numPoints))
		end
	end
end

function DT:Data_OnLeave()
	DT.tooltip:Hide()
end

function DT:SetupTooltip(panel)
	local parent = panel:GetParent()
	self.tooltip:Hide()
	self.tooltip:SetOwner(parent, parent.anchor, parent.xOff, parent.yOff)
	self.tooltip:ClearLines()
	GameTooltip:Hide() -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
end

function DT:RegisterPanel(panel, numPoints, anchor, xOff, yOff)
	DT.RegisteredPanels[panel:GetName()] = panel
	panel.dataPanels = {}
	panel.numPoints = numPoints

	panel.xOff = xOff
	panel.yOff = yOff
	panel.anchor = anchor
	for i=1, numPoints do
		local pointIndex = DT.PointLocation[i]
		if not panel.dataPanels[pointIndex] then
			panel.dataPanels[pointIndex] = CreateFrame('Button', 'DataText'..i, panel)
			panel.dataPanels[pointIndex]:RegisterForClicks("AnyUp")
			panel.dataPanels[pointIndex].text = panel.dataPanels[pointIndex]:CreateFontString(nil, 'OVERLAY')
			panel.dataPanels[pointIndex].text:SetAllPoints()
			panel.dataPanels[pointIndex].text:FontTemplate()
			panel.dataPanels[pointIndex].text:SetJustifyH("CENTER")
			panel.dataPanels[pointIndex].text:SetJustifyV("MIDDLE")
		end

		panel.dataPanels[pointIndex]:Point(DT:GetDataPanelPoint(panel, i, numPoints))
	end

	panel:SetScript('OnSizeChanged', DT.UpdateAllDimensions)
	DT.UpdateAllDimensions(panel)
end

function DT:AssignPanelToDataText(panel, data)
	panel.name = ""
	if data['name'] then
		panel.name = data['name']
	end

	if data['events'] then
		for _, event in pairs(data['events']) do
			-- use new filtered event registration for appropriate events
			if event == "UNIT_AURA" or event == "UNIT_RESISTANCES"  or event == "UNIT_STATS" or event == "UNIT_ATTACK_POWER"
				or event == "UNIT_RANGED_ATTACK_POWER" or event == "UNIT_TARGET" or event == "UNIT_SPELL_HASTE" then
				panel:RegisterUnitEvent(event, 'player')
			elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
				panel:RegisterUnitEvent(event, UnitGUID("player"), UnitGUID("pet"))
			else
				panel:RegisterEvent(event)
			end
		end
	end

	if data['eventFunc'] then
		panel:SetScript('OnEvent', data['eventFunc'])
		data['eventFunc'](panel, 'ELVUI_FORCE_RUN')
	end

	if data['onUpdate'] then
		panel:SetScript('OnUpdate', data['onUpdate'])
		data['onUpdate'](panel, 20000)
	end

	if data['onClick'] then
		panel:SetScript('OnClick', function(self, button)
			if E.db.datatexts.noCombatClick and InCombatLockdown() then return; end
			data['onClick'](self, button)
		end)
	end

	if data['onEnter'] then
		panel:SetScript('OnEnter', function(self)
			if E.db.datatexts.noCombatHover and InCombatLockdown() then return; end
			data['onEnter'](self)
		end)
	end

	if data['onLeave'] then
		panel:SetScript('OnLeave', data['onLeave'])
	else
		panel:SetScript('OnLeave', DT.Data_OnLeave)
	end
end

function DT:LoadDataTexts()
	self.db = E.db.datatexts
	for name, obj in LDB:DataObjectIterator() do
		LDB:UnregisterAllCallbacks(self)
	end

	local inInstance, instanceType = IsInInstance()
	local fontTemplate = LSM:Fetch("font", self.db.font)
	if ElvConfigToggle then
		ElvConfigToggle.text:FontTemplate(fontTemplate, self.db.fontSize, self.db.fontOutline)
	end
	
	for panelName, panel in pairs(DT.RegisteredPanels) do
		--Restore Panels
		for i=1, panel.numPoints do
			local pointIndex = DT.PointLocation[i]
			panel.dataPanels[pointIndex]:UnregisterAllEvents()
			panel.dataPanels[pointIndex]:SetScript('OnUpdate', nil)
			panel.dataPanels[pointIndex]:SetScript('OnEnter', nil)
			panel.dataPanels[pointIndex]:SetScript('OnLeave', nil)
			panel.dataPanels[pointIndex]:SetScript('OnClick', nil)
			panel.dataPanels[pointIndex].text:FontTemplate(fontTemplate, self.db.fontSize, self.db.fontOutline)
			panel.dataPanels[pointIndex].text:SetWordWrap(self.db.wordWrap)
			panel.dataPanels[pointIndex].text:SetText(nil)
			panel.dataPanels[pointIndex].pointIndex = pointIndex

			if (panelName == 'LeftChatDataPanel' or panelName == 'RightChatDataPanel') and (inInstance and (instanceType == "pvp")) and not DT.ForceHideBGStats and E.db.datatexts.battleground then
				panel.dataPanels[pointIndex]:RegisterEvent('UPDATE_BATTLEFIELD_SCORE')
				panel.dataPanels[pointIndex]:SetScript('OnEvent', DT.UPDATE_BATTLEFIELD_SCORE)
				panel.dataPanels[pointIndex]:SetScript('OnEnter', DT.BattlegroundStats)
				panel.dataPanels[pointIndex]:SetScript('OnLeave', DT.Data_OnLeave)
				panel.dataPanels[pointIndex]:SetScript('OnClick', DT.HideBattlegroundTexts)
				DT.UPDATE_BATTLEFIELD_SCORE(panel.dataPanels[pointIndex])
			else
				--Register Panel to Datatext
				for name, data in pairs(DT.RegisteredDataTexts) do
					for option, value in pairs(self.db.panels) do
						if value and type(value) == 'table' then
							if option == panelName and self.db.panels[option][pointIndex] and self.db.panels[option][pointIndex] == name then
								DT:AssignPanelToDataText(panel.dataPanels[pointIndex], data)
							end
						elseif value and type(value) == 'string' and value == name then
							if self.db.panels[option] == name and option == panelName then
								DT:AssignPanelToDataText(panel.dataPanels[pointIndex], data)
							end
						end
					end
				end
			end
		end
	end

	if DT.ForceHideBGStats then
		DT.ForceHideBGStats = nil;
	end
end

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
function DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	if name then
		DT.RegisteredDataTexts[name] = {}
	else
		error('Cannot register datatext no name was provided.')
	end

	DT.RegisteredDataTexts[name]['name'] = name

	if type(events) ~= 'table' and events ~= nil then
		error('Events must be registered as a table.')
	else
		DT.RegisteredDataTexts[name]['events'] = events
		DT.RegisteredDataTexts[name]['eventFunc'] = eventFunc
	end

	if updateFunc and type(updateFunc) == 'function' then
		DT.RegisteredDataTexts[name]['onUpdate'] = updateFunc
	end

	if clickFunc and type(clickFunc) == 'function' then
		DT.RegisteredDataTexts[name]['onClick'] = clickFunc
	end

	if onEnterFunc and type(onEnterFunc) == 'function' then
		DT.RegisteredDataTexts[name]['onEnter'] = onEnterFunc
	end

	if onLeaveFunc and type(onLeaveFunc) == 'function' then
		DT.RegisteredDataTexts[name]['onLeave'] = onLeaveFunc
	end
end

E:RegisterModule(DT:GetName())