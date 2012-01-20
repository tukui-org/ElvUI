local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:NewModule('DataTexts', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')

function DT:Initialize()
	--if E.db["datatexts"].enable ~= true then return end
	E.DataTexts = DT
	self:LoadDataTexts()
	self:PanelLayoutOptions()	
end

DT.RegisteredPanels = {}
DT.RegisteredDataTexts = {}

DT.PointLocation = {
	[1] = 'middle',
	[2] = 'left',
	[3] = 'right',
}

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
			panel.dataPanels[pointIndex]:Point(DT:GetDataPanelPoint(panel, i, numPoints))		
		end
	end
end

function DT:Data_OnLeave()
	GameTooltip:Hide()
end

function DT:SetupTooltip(panel)
	local parent = panel:GetParent()
	GameTooltip:Hide()
	GameTooltip:SetOwner(parent, parent.anchor, parent.xOff, parent.yOff)
	GameTooltip:ClearLines()
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
			panel.dataPanels[pointIndex] = CreateFrame('Button', nil, panel)
			panel.dataPanels[pointIndex]:RegisterForClicks("AnyUp")
			--panel.dataPanels[pointIndex]:SetTemplate('Default')
			panel.dataPanels[pointIndex]:SetScript('OnLeave', DT.Data_OnLeave)
			panel.dataPanels[pointIndex].text = panel.dataPanels[pointIndex]:CreateFontString(nil, 'OVERLAY')
			panel.dataPanels[pointIndex].text:SetAllPoints()
			panel.dataPanels[pointIndex].text:FontTemplate()
			panel.dataPanels[pointIndex].text:SetJustifyH("CENTER")
			panel.dataPanels[pointIndex].text:SetJustifyV("middle")	
			--panel.dataPanels[pointIndex].text:SetText(pointIndex..' DATATEXT')
		end
		
		panel.dataPanels[pointIndex]:Point(DT:GetDataPanelPoint(panel, i, numPoints))
	end
	
	panel:SetScript('OnSizeChanged', DT.UpdateAllDimensions)
end

function DT:AssignPanelToDataText(panel, data)	
	if data['events'] then
		for _, event in pairs(data['events']) do
			panel:RegisterEvent(event)
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
		panel:SetScript('OnClick', data['onClick'])
	end
	
	if data['onEnter'] then
		panel:SetScript('OnEnter', data['onEnter'])
	end
end

function DT:LoadDataTexts()
	local spec = 'spec1'
	if not self.db then self.db = E.db.datatexts end
	if self.db.specswap and GetActiveTalentGroup() == 2 then
		spec = 'spec2'
	end

	for panelName, panel in pairs(DT.RegisteredPanels) do
		--Restore Panels
		for i=1, panel.numPoints do
			local pointIndex = DT.PointLocation[i]
			panel.dataPanels[pointIndex]:UnregisterAllEvents()
			panel.dataPanels[pointIndex]:SetScript('OnUpdate', nil)
			panel.dataPanels[pointIndex]:SetScript('OnEnter', nil)
			panel.dataPanels[pointIndex]:SetScript('OnClick', nil)
			panel.dataPanels[pointIndex].text:SetText(nil)
			
			--Register Panel to Datatext
			for name, data in pairs(DT.RegisteredDataTexts) do
				for option, value in pairs(self.db.panels[spec]) do
					if value and type(value) == 'table' then
						if option == panelName and self.db.panels[spec][option][pointIndex] and self.db.panels[spec][option][pointIndex] == name then
							DT:AssignPanelToDataText(panel.dataPanels[pointIndex], data)
						end
					elseif value and type(value) == 'string' and value == name then
						if self.db.panels[spec][option] == name and option == panelName then
							DT:AssignPanelToDataText(panel.dataPanels[pointIndex], data)
						end
					end
				end
			end					
		end
	end
end
DT:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', 'LoadDataTexts')

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
function DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)
	if name then
		DT.RegisteredDataTexts[name] = {}
	else
		error('Cannot register datatext no name was provided.')
	end
	
	if type(events) ~= 'table' and events ~= nil then
		error('Events must be registered as a table.')
	else
		DT.RegisteredDataTexts[name]['events'] = events
		DT.RegisteredDataTexts[name]['eventFunc'] = eventFunc
	end
	
	if events == nil and updateFunc and type(updateFunc) == 'function' then
		DT.RegisteredDataTexts[name]['onUpdate'] = updateFunc
	end
	
	if clickFunc and type(clickFunc) == 'function' then
		DT.RegisteredDataTexts[name]['onClick'] = clickFunc
	end
	
	if onEnterFunc and type(onEnterFunc) == 'function' then
		DT.RegisteredDataTexts[name]['onEnter'] = onEnterFunc
	end
end

E:RegisterModule(DT:GetName())