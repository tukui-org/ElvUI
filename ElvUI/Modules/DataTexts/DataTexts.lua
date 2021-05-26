local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')
local TT = E:GetModule('Tooltip')
local LDB = E.Libs.LDB
local LSM = E.Libs.LSM

local _G = _G
local tostring, format, type, pcall = tostring, format, type, pcall
local tinsert, ipairs, pairs, wipe, sort = tinsert, ipairs, pairs, wipe, sort
local next, strfind, strlen, strsplit = next, strfind, strlen, strsplit
local hooksecurefunc = hooksecurefunc
local CloseDropDownMenus = CloseDropDownMenus
local CreateFrame = CreateFrame
local EasyMenu = EasyMenu
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local MouseIsOver = MouseIsOver
local RegisterStateDriver = RegisterStateDriver
local UIDropDownMenu_SetAnchor = UIDropDownMenu_SetAnchor
local UnregisterStateDriver = UnregisterStateDriver
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_CurrencyInfo_GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize
local C_CurrencyInfo_GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo
local C_CurrencyInfo_GetCurrencyListLink = C_CurrencyInfo.GetCurrencyListLink
local C_CurrencyInfo_GetCurrencyIDFromLink = C_CurrencyInfo.GetCurrencyIDFromLink
local C_CurrencyInfo_ExpandCurrencyList = C_CurrencyInfo.ExpandCurrencyList
local GetNumSpecializations = GetNumSpecializations
local GetSpecializationInfo = GetSpecializationInfo
local MISCELLANEOUS = MISCELLANEOUS

local LFG_TYPE_DUNGEON = LFG_TYPE_DUNGEON
local expansion = _G['EXPANSION_NAME'..GetExpansionLevel()]
local ActivateHyperMode
local HyperList = {}

DT.tooltip = CreateFrame('GameTooltip', 'DataTextTooltip', E.UIParent, 'GameTooltipTemplate')
DT.EasyMenu = CreateFrame('Frame', 'DataTextEasyMenu', E.UIParent, 'UIDropDownMenuTemplate')

DT.SelectedDatatext = nil
DT.HyperList = HyperList
DT.RegisteredPanels = {}
DT.RegisteredDataTexts = {}
DT.DataTextList = {}
DT.LoadedInfo = {}
DT.PanelPool = {
	InUse = {},
	Free = {},
	Count = 0
}

DT.FontStrings = {}
DT.AssignedDatatexts = {}
DT.UnitEvents = {
	UNIT_AURA = true,
	UNIT_RESISTANCES = true,
	UNIT_STATS = true,
	UNIT_ATTACK_POWER = true,
	UNIT_RANGED_ATTACK_POWER = true,
	UNIT_TARGET = true,
	UNIT_SPELL_HASTE = true
}

DT.SPECIALIZATION_CACHE = {}

function DT:SetEasyMenuAnchor(menu, dt)
	local point = E:GetScreenQuadrant(dt)
	local bottom = point and strfind(point, 'BOTTOM')
	local left = point and strfind(point, 'LEFT')

	local anchor1 = (bottom and left and 'BOTTOMLEFT') or (bottom and 'BOTTOMRIGHT') or (left and 'TOPLEFT') or 'TOPRIGHT'
	local anchor2 = (bottom and left and 'TOPLEFT') or (bottom and 'TOPRIGHT') or (left and 'BOTTOMLEFT') or 'BOTTOMRIGHT'

	UIDropDownMenu_SetAnchor(menu, 0, 0, anchor1, dt, anchor2)
end

--> [HyperDT Credits] <--
--> Original Work: Nihilistzsche
--> Modified by Azilroka! :)

function DT:SingleHyperMode(_, key, active)
	if DT.SelectedDatatext and (key == 'LALT' or key == 'RALT') then
		if active == 1 and MouseIsOver(DT.SelectedDatatext) then
			DT:OnLeave()
			DT:SetEasyMenuAnchor(DT.EasyMenu, DT.SelectedDatatext)
			EasyMenu(HyperList, DT.EasyMenu, nil, nil, nil, 'MENU')
		elseif _G.DropDownList1:IsShown() and not _G.DropDownList1:IsMouseOver() then
			CloseDropDownMenus()
		end
	end
end

function DT:HyperClick()
	DT.SelectedDatatext = self
	DT:SetEasyMenuAnchor(DT.EasyMenu, DT.SelectedDatatext)
	EasyMenu(HyperList, DT.EasyMenu, nil, nil, nil, 'MENU')
end

function DT:EnableHyperMode(Panel)
	DT:OnLeave()

	if Panel then
		for _, dt in pairs(Panel.dataPanels) do
			dt.overlay:Show()
			dt:SetScript('OnEnter', nil)
			dt:SetScript('OnLeave', nil)
			dt:SetScript('OnClick', DT.HyperClick)
		end
	else
		for _, panel in pairs(DT.RegisteredPanels) do
			for _, dt in pairs(panel.dataPanels) do
				dt.overlay:Show()
				dt:SetScript('OnEnter', nil)
				dt:SetScript('OnLeave', nil)
				dt:SetScript('OnClick', DT.HyperClick)
			end
		end
	end
end

function DT:OnEnter()
	if E.db.datatexts.noCombatHover and InCombatLockdown() then return end

	if self.parent then
		DT.SelectedDatatext = self
		DT:SetupTooltip(self)
	end

	if self.MouseEnters then
		for _, func in ipairs(self.MouseEnters) do
			func(self)
		end
	end

	DT.MouseEnter(self)
end

function DT:OnLeave()
	if self.MouseLeaves then
		for _, func in ipairs(self.MouseLeaves) do
			func(self)
		end
	end

	DT.MouseLeave(self)
	DT.tooltip:Hide()
end

function DT:MouseEnter()
	local frame = self.parent or self
	if frame.db and frame.db.mouseover then
		E:UIFrameFadeIn(frame, 0.2, frame:GetAlpha(), 1)
	end
end

function DT:MouseLeave()
	local frame = self.parent or self
	if frame.db and frame.db.mouseover then
		E:UIFrameFadeOut(frame, 0.2, frame:GetAlpha(), 0)
	end
end

function DT:FetchFrame(givenName)
	local panelExists = DT.PanelPool.InUse[givenName]
	if panelExists then return panelExists end

	local count = DT.PanelPool.Count
	local name = 'ElvUI_DTPanel' .. count
	local frame

	local poolName, poolFrame = next(DT.PanelPool.Free)
	if poolName then
		frame = poolFrame
		DT.PanelPool.Free[poolName] = nil
	else
		frame = CreateFrame('Frame', name, E.UIParent)
		DT.PanelPool.Count = DT.PanelPool.Count + 1
	end

	DT.PanelPool.InUse[givenName] = frame

	return frame
end

function DT:EmptyPanel(panel)
	panel:Hide()

	for _, dt in ipairs(panel.dataPanels) do
		dt:UnregisterAllEvents()
		dt:SetScript('OnUpdate', nil)
		dt:SetScript('OnEvent', nil)
		dt:SetScript('OnEnter', nil)
		dt:SetScript('OnLeave', nil)
		dt:SetScript('OnClick', nil)
	end

	UnregisterStateDriver(panel, 'visibility')
	E:DisableMover(panel.moverName)
end

function DT:ReleasePanel(givenName)
	local panel = DT.PanelPool.InUse[givenName]
	if panel then
		DT:EmptyPanel(panel)
		DT.PanelPool.Free[givenName] = panel
		DT.PanelPool.InUse[givenName] = nil
		DT.RegisteredPanels[givenName] = nil
		E.db.movers[panel.moverName] = nil
	end
end

function DT:BuildPanelFrame(name, fromInit)
	local db = DT:GetPanelSettings(name)

	local Panel = DT:FetchFrame(name)
	Panel:ClearAllPoints()
	Panel:SetPoint('CENTER')
	Panel:SetSize(db.width, db.height)

	local MoverName = 'DTPanel'..name..'Mover'
	Panel.moverName = MoverName
	Panel.givenName = name

	local holder = E:GetMoverHolder(MoverName)
	if holder then
		E:SetMoverPoints(MoverName, Panel)
	else
		E:CreateMover(Panel, MoverName, name, nil, nil, nil, nil, nil, 'datatexts,panels')
	end

	DT:RegisterPanel(Panel, db.numPoints, db.tooltipAnchor, db.tooltipXOffset, db.tooltipYOffset, db.growth == 'VERTICAL')

	if not fromInit then
		DT:UpdatePanelAttributes(name, db)
	end
end

local LDBhex, LDBna = '|cffFFFFFF', {['N/A'] = true, ['n/a'] = true, ['N/a'] = true}
function DT:BuildPanelFunctions(name, obj)
	local panel

	local function OnEnter(dt)
		DT.tooltip:ClearLines()
		if obj.OnTooltipShow then obj.OnTooltipShow(DT.tooltip) end
		if obj.OnEnter then obj.OnEnter(dt) end
		DT.tooltip:Show()
	end

	local function OnLeave(dt)
		if obj.OnLeave then obj.OnLeave(dt) end
	end

	local function OnClick(dt, button)
		if obj.OnClick then
			obj.OnClick(dt, button)
		end
	end

	local function UpdateText(_, Name, _, Value)
		if not Value or (strlen(Value) >= 3) or (Value == Name or LDBna[Value]) then
			panel.text:SetText((not LDBna[Value] and Value) or Name)
		else
			panel.text:SetFormattedText('%s: %s%s|r', Name, LDBhex, Value)
		end
	end

	local function OnCallback(Hex)
		if name and obj then
			LDBhex = Hex
			LDB.callbacks:Fire('LibDataBroker_AttributeChanged_'..name..'_text', name, nil, obj.text, obj)
		end
	end

	local function OnEvent(dt)
		panel = dt
		LDB:RegisterCallback('LibDataBroker_AttributeChanged_'..name..'_text', UpdateText)
		LDB:RegisterCallback('LibDataBroker_AttributeChanged_'..name..'_value', UpdateText)
		OnCallback(LDBhex)
	end

	return OnEnter, OnLeave, OnClick, OnCallback, OnEvent, UpdateText
end

function DT:SetupObjectLDB(name, obj)
	local onEnter, onLeave, onClick, onCallback, onEvent = DT:BuildPanelFunctions(name, obj)
	local data = DT:RegisterDatatext(name, 'Data Broker', nil, onEvent, nil, onClick, onEnter, onLeave)
	E.valueColorUpdateFuncs[onCallback] = true
	data.isLibDataBroker = true
end

function DT:RegisterLDB()
	for name, obj in LDB:DataObjectIterator() do
		DT:SetupObjectLDB(name, obj)
	end
end

function DT:GetDataPanelPoint(panel, i, numPoints, vertical)
	if numPoints == 1 then
		return 'CENTER', panel, 'CENTER'
	else
		local point, relativePoint, xOffset, yOffset = 'LEFT', i == 1 and 'LEFT' or 'RIGHT', 4, 0
		if vertical then
			point, relativePoint, xOffset, yOffset = 'TOP', i == 1 and 'TOP' or 'BOTTOM', 0, -4
		end

		local lastPanel = (i == 1 and panel) or panel.dataPanels[i - 1]
		return point, lastPanel, relativePoint, xOffset, yOffset
	end
end

function DT:SetupTooltip(panel)
	local parent = panel:GetParent()
	DT.tooltip:SetOwner(panel, parent.anchor, parent.xOff, parent.yOff)

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide() -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
	end
end

function DT:RegisterPanel(panel, numPoints, anchor, xOff, yOff, vertical)
	local realName = panel:GetName()
	local name = panel.givenName or realName

	if not name then
		E:Print('DataTexts: Requires a panel name.')
		return
	end

	DT.RegisteredPanels[name] = panel

	panel:SetScript('OnEnter', DT.OnEnter)
	panel:SetScript('OnLeave', DT.OnLeave)
	panel:SetScript('OnSizeChanged', DT.PanelSizeChanged)

	panel.dataPanels = panel.dataPanels or {}
	panel.numPoints = numPoints
	panel.xOff = xOff
	panel.yOff = yOff
	panel.anchor = anchor
	panel.vertical = vertical
end

function DT:GetPanelSettings(name)
	local db = E:CopyTable({}, G.datatexts.newPanelInfo)

	local customPanels = E.global.datatexts.customPanels
	local customPanel = customPanels[name]
	if customPanel then
		db = E:CopyTable(db, customPanel)
	end

	customPanels[name] = db

	return db
end

function DT:AssignPanelToDataText(dt, data, event, ...)
	dt.name = data.name or '' -- This is needed for Custom Currencies

	if data.events then
		for _, ev in pairs(data.events) do
			if data.eventFunc then
				if data.objectEvent then
					if not dt.objectEventFunc then
						dt.objectEvent = data.objectEvent
						dt.objectEventFunc = function(_, ...)
							if data.eventFunc then
								data.eventFunc(dt, ...)
							end
						end
					end
					if not E:HasFunctionForObject(ev, data.objectEvent, dt.objectEventFunc) then
						E:RegisterEventForObject(ev, data.objectEvent, dt.objectEventFunc)
					end
				elseif DT.UnitEvents[ev] then
					pcall(dt.RegisterUnitEvent, dt, ev, 'player')
				else
					pcall(dt.RegisterEvent, dt, ev)
				end
			end
		end
	end

	local ev = event or 'ELVUI_FORCE_UPDATE'
	if data.eventFunc then
		if not data.objectEvent then
			dt:SetScript('OnEvent', data.eventFunc)
		end
		data.eventFunc(dt, ev, ...)
	end

	if data.onUpdate then
		dt:SetScript('OnUpdate', data.onUpdate)
		data.onUpdate(dt, 20000)
	end

	if data.onClick then
		dt:SetScript('OnClick', function(p, button)
			if E.db.datatexts.noCombatClick and InCombatLockdown() then return end
			data.onClick(p, button)
			DT.tooltip:Hide()
		end)
	end

	if data.onEnter then
		tinsert(dt.MouseEnters, data.onEnter)
	end
	if data.onLeave then
		tinsert(dt.MouseLeaves, data.onLeave)
	end
end

function DT:ForceUpdate_DataText(name)
	for dtSlot, dtName in pairs(DT.AssignedDatatexts) do
		if dtName.name == name then
			if dtName.colorUpdate then
				dtName.colorUpdate(E.media.hexvaluecolor)
			end
			if dtName.eventFunc then
				dtName.eventFunc(dtSlot, 'ELVUI_FORCE_UPDATE')
			end
		end
	end
end

function DT:GetTextAttributes(panel, db)
	local panelWidth, panelHeight = panel:GetSize()
	local numPoints = db and db.numPoints or panel.numPoints or 1
	local vertical = db and db.vertical or panel.vertical

	local width, height = (panelWidth / numPoints) - 4, panelHeight - 4
	if vertical then width, height = panelWidth - 4, (panelHeight / numPoints) - 4 end

	return width, height, vertical, numPoints
end

function DT:UpdatePanelInfo(panelName, panel, ...)
	if not panel then panel = DT.RegisteredPanels[panelName] end
	local db = panel.db or P.datatexts.panels[panelName] and DT.db.panels[panelName]
	if not db then return end

	local info = DT.LoadedInfo
	local font, fontSize, fontOutline = info.font, info.fontSize, info.fontOutline
	if db and db.fonts and db.fonts.enable then
		font, fontSize, fontOutline = LSM:Fetch('font', db.fonts.font), db.fonts.fontSize, db.fonts.fontOutline
	end

	local chatPanel = panelName == 'LeftChatDataPanel' or panelName == 'RightChatDataPanel'
	local battlePanel = info.isInBattle and chatPanel and (not DT.ForceHideBGStats and E.db.datatexts.battleground)
	if battlePanel then
		DT:RegisterEvent('UPDATE_BATTLEFIELD_SCORE')
		DT.ShowingBattleStats = info.instanceType
	elseif chatPanel and DT.ShowingBattleStats then
		DT:UnregisterEvent('UPDATE_BATTLEFIELD_SCORE')
		DT.ShowingBattleStats = nil
	end

	local width, height, vertical, numPoints = DT:GetTextAttributes(panel, db)

	for i = 1, numPoints do
		local dt = panel.dataPanels[i]
		if not dt then
			dt = CreateFrame('Button', panelName..'_DataText'..i, panel)
			dt.MouseEnters = {}
			dt.MouseLeaves = {}
			dt:RegisterForClicks('AnyUp')

			local text = dt:CreateFontString(nil, 'ARTWORK')
			text:SetAllPoints()
			text:SetJustifyV('MIDDLE')
			dt.text = text
			DT.FontStrings[text] = true

			local overlay = dt:CreateTexture(nil, 'OVERLAY')
			overlay:SetTexture(E.media.blankTex)
			overlay:SetVertexColor(0.3, 0.9, 0.3, .3)
			overlay:SetAllPoints()
			dt.overlay = overlay

			panel.dataPanels[i] = dt
		end
	end

	--Note: some plugins dont have db.border, we need the nil checks
	panel.forcedBorderColors = (db.border == false and {0,0,0,0}) or nil
	panel:SetTemplate(db.backdrop and (db.panelTransparency and 'Transparent' or 'Default') or 'NoBackdrop', true)

	--Show Border option
	if db.border ~= nil then
		if panel.iborder then panel.iborder:SetShown(db.border) end
		if panel.oborder then panel.oborder:SetShown(db.border) end
	end

	--Restore Panels
	for i, dt in ipairs(panel.dataPanels) do
		dt:SetShown(i <= numPoints)
		dt:SetSize(width, height)
		dt:ClearAllPoints()
		dt:SetPoint(DT:GetDataPanelPoint(panel, i, numPoints, vertical))
		dt:UnregisterAllEvents()
		dt:EnableMouseWheel(false)
		dt:SetScript('OnUpdate', nil)
		dt:SetScript('OnEvent', nil)
		dt:SetScript('OnClick', nil)
		dt:SetScript('OnEnter', DT.OnEnter)
		dt:SetScript('OnLeave', DT.OnLeave)
		wipe(dt.MouseEnters)
		wipe(dt.MouseLeaves)

		dt.overlay:Hide()
		dt.pointIndex = i
		dt.parent = panel
		dt.parentName = panelName
		dt.battleStats = battlePanel
		dt.db = db

		E:StopFlash(dt)

		if dt.objectEvent and dt.objectEventFunc then
			E:UnregisterAllEventsForObject(dt.objectEvent, dt.objectEventFunc)
			dt.objectEvent, dt.objectEventFunc = nil, nil
		end

		dt.text:FontTemplate(font, fontSize, fontOutline)
		dt.text:SetJustifyH(db.textJustify or 'CENTER')
		dt.text:SetWordWrap(DT.db.wordWrap)
		dt.text:SetText()

		if battlePanel then
			dt:SetScript('OnClick', DT.ToggleBattleStats)
			tinsert(dt.MouseEnters, DT.HoverBattleStats)
		else
			local assigned = DT.RegisteredDataTexts[ DT.db.panels[panelName][i] ]
			DT.AssignedDatatexts[dt] = assigned
			if assigned then DT:AssignPanelToDataText(dt, assigned, ...) end
		end
	end
end

function DT:LoadDataTexts(...)
	local data = DT.LoadedInfo
	data.font, data.fontSize, data.fontOutline = LSM:Fetch('font', DT.db.font), DT.db.fontSize, DT.db.fontOutline
	data.inInstance, data.instanceType = IsInInstance()
	data.isInBattle = data.inInstance and data.instanceType == 'pvp'

	for panel, db in pairs(E.global.datatexts.customPanels) do
		DT:UpdatePanelAttributes(panel, db, true)
	end

	for panelName, panel in pairs(DT.RegisteredPanels) do
		local db = DT.db.panels[panelName]
		if db and db.enable then
			DT:UpdatePanelInfo(panelName, panel, ...)
		end
	end

	if DT.ShowingBattleStats then
		DT:UPDATE_BATTLEFIELD_SCORE()
	end
end

function DT:PanelSizeChanged()
	if not self.dataPanels then return end
	local db = self.db or P.datatexts.panels[self.name] and DT.db.panels[self.name]
	local width, height, vertical, numPoints = DT:GetTextAttributes(self, db)

	for i, dt in ipairs(self.dataPanels) do
		dt:SetSize(width, height)
		dt:ClearAllPoints()
		dt:SetPoint(DT:GetDataPanelPoint(self, i, numPoints, vertical))
	end
end

function DT:UpdatePanelAttributes(name, db, fromLoad)
	local Panel = DT.PanelPool.InUse[name]
	DT.OnLeave(Panel)

	Panel.db = db
	Panel.name = name
	Panel.numPoints = db.numPoints
	Panel.xOff = db.tooltipXOffset
	Panel.yOff = db.tooltipYOffset
	Panel.anchor = db.tooltipAnchor
	Panel.vertical = db.growth == 'VERTICAL'
	Panel:SetSize(db.width, db.height)
	Panel:SetFrameStrata(db.frameStrata)
	Panel:SetFrameLevel(db.frameLevel)

	E:UIFrameFadeIn(Panel, 0.2, Panel:GetAlpha(), db.mouseover and 0 or 1)

	if not DT.db.panels[name] or type(DT.db.panels[name]) ~= 'table' then
		DT.db.panels[name] = { enable = false }
	end

	for i = 1, (E.global.datatexts.customPanels[name].numPoints or 1) do
		if not DT.db.panels[name][i] then
			DT.db.panels[name][i] = ''
		end
	end

	if DT.db.panels[name].enable then
		E:EnableMover(Panel.moverName)
		RegisterStateDriver(Panel, 'visibility', db.visibility)

		if not fromLoad then
			DT:UpdatePanelInfo(name, Panel)
		end
	else
		DT:EmptyPanel(Panel)
	end
end

function DT:GetMenuListCategory(category)
	for i, info in ipairs(HyperList) do
		if info.text == category then
			return i
		end
	end
end

do
	local function menuSort(a, b)
		if a.order and b.order then
			return a.order < b.order
		end

		return a.text < b.text
	end

	function DT:SortMenuList(list)
		for _, menu in pairs(list) do
			if menu.menuList then
				DT:SortMenuList(menu.menuList)
			end
		end

		sort(list, menuSort)
	end
end

function DT:HyperDT()
	if ActivateHyperMode then
		ActivateHyperMode = nil
		DT:LoadDataTexts()
	else
		ActivateHyperMode = true
		DT:EnableHyperMode()
	end
end

function DT:RegisterHyperDT()
	for name, info in pairs(DT.RegisteredDataTexts) do
		local category = DT:GetMenuListCategory(info.category or MISCELLANEOUS)
		if not category then
			category = #HyperList + 1
			tinsert(HyperList, { order = 0, text = info.category or MISCELLANEOUS, notCheckable = true, hasArrow = true, menuList = {} } )
		end

		tinsert(HyperList[category].menuList, {
			text = info.localizedName or name,
			checked = function() return DT.EasyMenu.MenuGetItem(DT.SelectedDatatext, name) end,
			func = function() DT.EasyMenu.MenuSetItem(DT.SelectedDatatext, name) end
		})
	end

	tinsert(HyperList, {
		order = 100, text = L["NONE"],
		checked = function() return DT.EasyMenu.MenuGetItem(DT.SelectedDatatext, '') end,
		func = function() DT.EasyMenu.MenuSetItem(DT.SelectedDatatext, '') end
	})

	DT:SortMenuList(HyperList)
	DT:RegisterEvent('MODIFIER_STATE_CHANGED', 'SingleHyperMode')
end

function DT:PopulateData(currencyOnly)
	local Collapsed = {}
	local listSize, i = C_CurrencyInfo_GetCurrencyListSize(), 1

	local headerIndex
	while listSize >= i do
		local info = C_CurrencyInfo_GetCurrencyListInfo(i)
		if info.isHeader and not info.isHeaderExpanded then
			C_CurrencyInfo_ExpandCurrencyList(i, true)
			listSize = C_CurrencyInfo_GetCurrencyListSize()
			Collapsed[info.name] = true
		end
		if info.isHeader then
			G.datatexts.settings.Currencies.tooltipData[i] = { info.name, nil, nil, (info.name == expansion or info.name == MISCELLANEOUS) or strfind(info.name, LFG_TYPE_DUNGEON) }
			E.global.datatexts.settings.Currencies.tooltipData[i] = { info.name, nil, nil, E.global.datatexts.settings.Currencies.headers }

			headerIndex = i
		end
		if not info.isHeader then
			local currencyLink = C_CurrencyInfo_GetCurrencyListLink(i)
			local currencyID = currencyLink and C_CurrencyInfo_GetCurrencyIDFromLink(currencyLink)
			if currencyID then
				DT.CurrencyList[tostring(currencyID)] = info.name
				G.datatexts.settings.Currencies.tooltipData[i] = { info.name, currencyID, headerIndex, G.datatexts.settings.Currencies.tooltipData[headerIndex][4] }
				G.datatexts.settings.Currencies.idEnable[currencyID] = G.datatexts.settings.Currencies.tooltipData[headerIndex][4]
				E.global.datatexts.settings.Currencies.idEnable[currencyID] = E.global.datatexts.settings.Currencies.idEnable[currencyID] == nil and G.datatexts.settings.Currencies.idEnable[currencyID] or E.global.datatexts.settings.Currencies.idEnable[currencyID]
				E.global.datatexts.settings.Currencies.tooltipData[i] = { info.name, currencyID, headerIndex, E.global.datatexts.settings.Currencies.idEnable[currencyID] }
			end
		end
		i = i + 1
	end

	for k = 1, listSize do
		local info = C_CurrencyInfo_GetCurrencyListInfo(k)
		if not info then
			break
		elseif info.isHeader and info.isHeaderExpanded and Collapsed[info.name] then
			C_CurrencyInfo_ExpandCurrencyList(k, false)
		end
	end

	wipe(Collapsed)

	if not currencyOnly then
		for index = 1, GetNumSpecializations() do
			local id, name, _, icon, _, statID = GetSpecializationInfo(index)

			if id then
				DT.SPECIALIZATION_CACHE[index] = { id = id, name = name, icon = icon, statID = statID }
				DT.SPECIALIZATION_CACHE[id] = { name = name, icon = icon }
			end
		end
	end
end

function DT:CURRENCY_DISPLAY_UPDATE(_, currencyID)
	if currencyID and not DT.CurrencyList[tostring(currencyID)] then
		local info = C_CurrencyInfo_GetCurrencyInfo(currencyID)
		if info then
			DT:PopulateData(true)
		end
	end
end

function DT:PLAYER_ENTERING_WORLD()
	DT:LoadDataTexts()
end

function DT:Initialize()
	DT.Initialized = true
	DT.db = E.db.datatexts

	DT.EasyMenu:SetClampedToScreen(true)
	DT.EasyMenu:EnableMouse(true)
	DT.EasyMenu.MenuSetItem = function(dt, value)
		DT.db.panels[dt.parentName][dt.pointIndex] = value
		DT:UpdatePanelInfo(dt.parentName, dt.parent)

		if ActivateHyperMode then
			DT:EnableHyperMode(dt.parent)
		end

		DT.SelectedDatatext = nil
		CloseDropDownMenus()
	end
	DT.EasyMenu.MenuGetItem = function(dt, value)
		return dt and (DT.db.panels[dt.parentName] and DT.db.panels[dt.parentName][dt.pointIndex] == value)
	end

	if E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip then
		TT:SetStyle(DT.tooltip)
	end

	-- Ignore header font size on DatatextTooltip
	local font = LSM:Fetch('font', E.db.tooltip.font)
	local fontOutline = E.db.tooltip.fontOutline
	local textSize = E.db.tooltip.textFontSize
	_G.DataTextTooltipTextLeft1:FontTemplate(font, textSize, fontOutline)
	_G.DataTextTooltipTextRight1:FontTemplate(font, textSize, fontOutline)

	LDB.RegisterCallback(E, 'LibDataBroker_DataObjectCreated', DT.SetupObjectLDB)
	DT:RegisterLDB() -- LibDataBroker
	DT:RegisterCustomCurrencyDT() -- Register all the user created currency datatexts from the 'CustomCurrency' DT.

	for name in pairs(E.global.datatexts.customPanels) do
		DT:BuildPanelFrame(name, true)
	end

	do -- we need to register the panels to access them for the text
		DT.BattleStats.LEFT.panel = _G.LeftChatDataPanel.dataPanels
		DT.BattleStats.RIGHT.panel = _G.RightChatDataPanel.dataPanels
	end

	hooksecurefunc(_G.C_CurrencyInfo, 'SetCurrencyBackpack', function() DT:ForceUpdate_DataText('Currencies') end)

	DT:PopulateData()
	DT:RegisterHyperDT()
	DT:RegisterEvent('PLAYER_ENTERING_WORLD')
	DT:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
end

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc, localizedName)

	name - name of the datatext (required)
	category - name of the category the datatext belongs to.
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
	localizedName - localized name of the datetext
	objectEvent - register events on an object, using E.RegisterEventForObject instead of panel.RegisterEvent
	colorUpdate - function that fires when called from the config when you change the dt options.
]]
function DT:RegisterDatatext(name, category, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc, localizedName, objectEvent, colorUpdate)
	if not name then return end
	if type(category) ~= 'string' and category ~= nil then return E:Print(format('%s is an invalid DataText.', name)) end

	local data = { name = name, category = category }

	if type(events) == 'function' then
		return E:Print(format('%s is an invalid DataText. Events must be registered as a table or a string.', name))
	else
		data.events = type(events) == 'string' and { strsplit('[, ]', events) } or events
		data.eventFunc = eventFunc
		data.objectEvent = objectEvent
	end

	if updateFunc and type(updateFunc) == 'function' then
		data.onUpdate = updateFunc
	end

	if clickFunc and type(clickFunc) == 'function' then
		data.onClick = clickFunc
	end

	if onEnterFunc and type(onEnterFunc) == 'function' then
		data.onEnter = onEnterFunc
	end

	if onLeaveFunc and type(onLeaveFunc) == 'function' then
		data.onLeave = onLeaveFunc
	end

	if localizedName and type(localizedName) == 'string' then
		data.localizedName = localizedName
	end

	if colorUpdate and type(colorUpdate) == 'function' then
		data.colorUpdate = colorUpdate
	end

	DT.RegisteredDataTexts[name] = data
	DT.DataTextList[name] = localizedName or name

	return data
end

E:RegisterModule(DT:GetName())
