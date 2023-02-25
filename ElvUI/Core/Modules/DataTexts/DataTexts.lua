local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local TT = E:GetModule('Tooltip')
local LDB = E.Libs.LDB
local LSM = E.Libs.LSM
-- GLOBALS: ElvDB

local _G = _G
local min, max = min, max
local next, format, type, pcall, unpack = next, format, type, pcall, unpack
local tinsert, ipairs, pairs, wipe, sort, gsub = tinsert, ipairs, pairs, wipe, sort, gsub
local tostring, strfind, strsplit = tostring, strfind, strsplit
local hooksecurefunc = hooksecurefunc

local CloseDropDownMenus = CloseDropDownMenus
local CreateFrame = CreateFrame
local EasyMenu = EasyMenu
local GetCurrencyInfo = GetCurrencyInfo
local GetCurrencyListInfo = GetCurrencyListInfo
local GetNumSpecializations = GetNumSpecializations
local GetSpecializationInfo = GetSpecializationInfo
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local MouseIsOver = MouseIsOver
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

local C_ClassTalents_GetActiveConfigID = C_ClassTalents and C_ClassTalents.GetActiveConfigID
local C_CurrencyInfo_ExpandCurrencyList = C_CurrencyInfo.ExpandCurrencyList
local C_CurrencyInfo_GetCurrencyIDFromLink = C_CurrencyInfo.GetCurrencyIDFromLink
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_CurrencyInfo_GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo
local C_CurrencyInfo_GetCurrencyListLink = C_CurrencyInfo.GetCurrencyListLink
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo or C_CurrencyInfo.GetBackpackCurrencyInfo
local GetCurrencyListSize = GetCurrencyListSize or C_CurrencyInfo.GetCurrencyListSize

local MISCELLANEOUS = MISCELLANEOUS
local LFG_TYPE_DUNGEON = LFG_TYPE_DUNGEON
local expansion = _G['EXPANSION_NAME'..GetExpansionLevel()]
local QuickList = {}

local iconString = '|T%s:16:16:0:0:64:64:4:60:4:60|t'

DT.tooltip = CreateFrame('GameTooltip', 'DataTextTooltip', E.UIParent, 'GameTooltipTemplate')

DT.SelectedDatatext = nil
DT.QuickList = QuickList
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

function DT:QuickDTMode(_, key, active)
	if DT.SelectedDatatext and (key == 'LALT' or key == 'RALT') then
		if active == 1 and MouseIsOver(DT.SelectedDatatext) then
			DT.OnLeave(DT.SelectedDatatext)
			E:SetEasyMenuAnchor(E.EasyMenu, DT.SelectedDatatext)
			EasyMenu(QuickList, E.EasyMenu, nil, nil, nil, 'MENU')
		elseif _G.DropDownList1:IsShown() and not _G.DropDownList1:IsMouseOver() then
			CloseDropDownMenus()
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

	if self.watchModKey then
		self:RegisterEvent('MODIFIER_STATE_CHANGED')
	end

	DT.MouseEnter(self)
end

function DT:OnLeave()
	if self.MouseLeaves then
		for _, func in ipairs(self.MouseLeaves) do
			func(self)
		end
	end

	if self.watchModKey then
		self:UnregisterEvent('MODIFIER_STATE_CHANGED')
	end

	DT.MouseLeave(self)
	DT.tooltip:Hide()
end

function DT:MouseEnter()
	local frame = self.parent or self
	return frame.db and frame.db.mouseover and E:UIFrameFadeIn(frame, 0.2, frame:GetAlpha(), 1)
end

function DT:MouseLeave()
	local frame = self.parent or self
	return frame.db and frame.db.mouseover and E:UIFrameFadeOut(frame, 0.2, frame:GetAlpha(), 0)
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

		if E.db.movers then
			E.db.movers[panel.moverName] = nil
		end
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

function DT:BuildPanelFunctions(name, obj)
	local panel, hex

	local function OnEnter(dt)
		if obj.tooltip then
			obj.tooltip:ClearAllPoints()
			obj.tooltip:SetOwner(DT:SetupTooltip(self))
			obj.tooltip:Show()
		else
			DT.tooltip:ClearLines()

			if obj.OnEnter then
				obj.OnEnter(dt)
			elseif obj.OnTooltipShow then
				obj.OnTooltipShow(DT.tooltip)
			end

			DT.tooltip:Show()
		end
	end

	local function OnLeave(dt)
		if obj.tooltip then
			obj.tooltip:Hide()
		elseif obj.OnLeave then
			obj.OnLeave(dt)
		end
	end

	local function OnClick(dt, button)
		if obj.OnClick then
			obj.OnClick(dt, button)
		end
	end

	local function UpdateText(_, _, _, _, data)
		local db = E.global.datatexts.settings['LDB_'..name]
		local icon = db.icon and data.icon
		local label = db.label and data.label
		local value = db.text and data.text

		local str = ''

		if label then
			str = (db.customLabel ~= '' and db.customLabel) or label
		end

		if value then
			local color = (db.useValueColor and hex) or '|cFFFFFFFF'
			str = str .. (label and ': ' or '') .. (color .. value .. '|r')
		end

		panel.text:SetText(str)
		panel.icon:SetShown(icon)
		panel.icon:SetTexture(icon)
		panel.icon:SetTexCoord(unpack(data.iconCoords or E.TexCoords))
	end

	local function UpdateColor(_, Hex)
		hex = Hex
		LDB.callbacks:Fire('LibDataBroker_AttributeChanged_'..name, name, nil, obj.text, obj)
	end

	local function OnEvent(dt, event)
		if event == 'ELVUI_REMOVE' then
			LDB.UnregisterCallback(dt, 'LibDataBroker_AttributeChanged_'..name)
		else
			panel = dt
			LDB.RegisterCallback(dt, 'LibDataBroker_AttributeChanged_'..name, UpdateText)
			UpdateColor(dt, hex)
		end
	end

	return OnEvent, OnClick, OnEnter, OnLeave, UpdateColor, UpdateText
end

function DT:SetupObjectLDB(name, obj)
	if obj.type == 'data source' or obj.type == 'launcher' then
		local ldbName = 'LDB_'..name
		if DT.RegisteredDataTexts[ldbName] then return end

		local onEvent, onClick, onEnter, onLeave, updateColor = DT:BuildPanelFunctions(name, obj)
		local data = DT:RegisterDatatext(ldbName, 'Data Broker', nil, onEvent, nil, onClick, onEnter, onLeave, 'LDB: '..name, nil, updateColor)
		data.isLDB = true

		if not obj.label then obj.label = name end

		local defaults = { customLabel = '', label = obj.type == 'launcher', text = obj.type == 'data source', icon = false, useValueColor = false }

		G.datatexts.settings[ldbName] = defaults
		E.global.datatexts.settings[ldbName] = E:CopyTable(E.global.datatexts.settings[ldbName], defaults, true)

		if self ~= DT then -- This checks to see if we are calling it or the callback.
			DT:UpdateQuickDT()
		end
	end
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

		local previous = (i == 1 and panel) or panel.dataPanels[i - 1]
		return point, previous, relativePoint, xOffset, yOffset
	end
end

function DT:SetupTooltip(panel)
	local parent = panel:GetParent()
	DT.tooltip:SetOwner(panel, parent.anchor, parent.xOff, parent.yOff)

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide() -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
	end

	return panel, parent.anchor, parent.xOff, parent.yOff
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

do
	local defaults = { enable = false, battleground = false }
	function DT:GetPanelSettings(name)
		-- battleground dt
		if not P.datatexts.battlePanel[name] then
			P.datatexts.battlePanel[name] = {}
		end

		DT.db.battlePanel[name] = E:CopyTable(DT.db.battlePanel[name], P.datatexts.battlePanel[name], true)

		-- enable / battleground - enable / profile dt
		if not DT.db.panels[name] then DT.db.panels[name] = {} end
		local panelDB = E:CopyTable(DT.db.panels[name], defaults, true)

		-- global frame settings and to keep profile tidy
		G.datatexts.customPanels[name] = E:CopyTable(G.datatexts.customPanels[name], G.datatexts.newPanelInfo, true)
		E.global.datatexts.customPanels[name] = E:CopyTable(E.global.datatexts.customPanels[name], G.datatexts.customPanels[name], true)

		-- global number of datatext slots for the profile
		for i = 1, (E.global.datatexts.customPanels[name].numPoints or 1) do
			if not panelDB[i] then panelDB[i] = '' end
			if not DT.db.battlePanel[name][i] then DT.db.battlePanel[name][i] = '' end
		end

		-- pass the table back
		return E.global.datatexts.customPanels[name]
	end
end

function DT:AssignPanelToDataText(dt, data, event, ...)
	dt.name = data.name

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
					if ev == 'MODIFIER_STATE_CHANGED' then
						dt.watchModKey = true
					else
						pcall(dt.RegisterEvent, dt, ev)
					end
				end
			end
		end
	end

	if data.applySettings then -- has to be before event function
		data.applySettings(dt, E.media.hexvaluecolor)
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

function DT:ForceUpdate_DataText(name) -- This is suppose to fire separately.
	local hex, r, g, b = E.media.hexvaluecolor, unpack(E.media.rgbvaluecolor)
	for dtSlot, dtInfo in pairs(DT.AssignedDatatexts) do
		if dtInfo.name == name then
			if dtInfo.applySettings then
				dtInfo.applySettings(dtSlot, hex, r, g, b)
			end
			if dtInfo.eventFunc then
				dtInfo.eventFunc(dtSlot, 'ELVUI_FORCE_UPDATE')
			end
		end
	end
end

function DT:UpdateHexColors(hex, r, g, b) -- This will fire both together.
	for dtSlot, dtInfo in pairs(DT.AssignedDatatexts) do
		if dtInfo.applySettings then
			dtInfo.applySettings(dtSlot, hex, r, g, b)
			if dtInfo.eventFunc then
				dtInfo.eventFunc(dtSlot, 'ELVUI_FORCE_UPDATE')
			end
		end
	end
end
E.valueColorUpdateFuncs.DataTexts = DT.UpdateHexColors

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

	local battlePanel = info.isInBattle and (not DT.ForceHideBGStats and E.db.datatexts.panels[panelName].battleground)
	if battlePanel then
		DT.ShowingBattleStats = info.instanceType
	elseif DT.ShowingBattleStats then
		DT.ShowingBattleStats = nil
	end

	local width, height, vertical, numPoints = DT:GetTextAttributes(panel, db)
	local iconSize = min(max(height - 2, fontSize), fontSize)

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

			local icon = dt:CreateTexture(nil, 'ARTWORK')
			icon:Hide()
			icon:Point('RIGHT', text, 'LEFT', -4, 0)
			icon:SetTexCoord(unpack(E.TexCoords))

			dt.icon = icon

			DT.FontStrings[text] = true

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
		local assigned = DT.AssignedDatatexts[dt]

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

		dt.pointIndex = i
		dt.parent = panel
		dt.parentName = panelName
		dt.battlePanel = battlePanel
		dt.db = db
		dt.watchModKey = nil
		dt.name = nil

		E:StopFlash(dt)

		dt.text:FontTemplate(font, fontSize, fontOutline)
		dt.text:SetJustifyH(db.textJustify or 'CENTER')
		dt.text:SetWordWrap(DT.db.wordWrap)
		dt.text:SetText()

		dt.icon:Size(iconSize)
		dt.icon:SetTexture(E.ClearTexture)

		if dt.objectEvent and dt.objectEventFunc then
			E:UnregisterAllEventsForObject(dt.objectEvent, dt.objectEventFunc)
			dt.objectEvent, dt.objectEventFunc = nil, nil
		end

		if assigned and assigned.isLDB and assigned.eventFunc then
			assigned.eventFunc(dt, 'ELVUI_REMOVE')
		end

		local data = DT.RegisteredDataTexts[ (battlePanel and DT.db.battlePanel or DT.db.panels)[panelName][i] ]
		DT.AssignedDatatexts[dt] = data
		if data then DT:AssignPanelToDataText(dt, data, ...) end

		if dt.icon:IsShown() then
			dt.text:ClearAllPoints()

			if db.textJustify == 'LEFT' then
				dt.text:Point('LEFT', dt, 'LEFT', iconSize + 4, 0)
				dt.text:Point('RIGHT')
			else
				dt.text:Point(db.textJustify or 'CENTER')
			end
		else
			dt.text:SetAllPoints()
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

	local panelDB = DT.db.panels[name]
	if panelDB and panelDB.enable then
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
	for i, info in ipairs(QuickList) do
		if info.text == category then
			return i
		end
	end
end

do
	local function menuSort(a, b)
		if a.order and b.order and not (a.order == b.order) then
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

do
	local function hasName(tbl, name)
		for _, data in pairs(tbl) do
			if data.text == name then
				return true
			end
		end
	end

	function DT:UpdateQuickDT()
		wipe(QuickList)

		for name, info in pairs(DT.RegisteredDataTexts) do
			local category = DT:GetMenuListCategory(info.category or MISCELLANEOUS)
			if not category then
				category = #QuickList + 1
				tinsert(QuickList, { order = 0, text = info.category or MISCELLANEOUS, notCheckable = true, hasArrow = true, menuList = {} })
			end

			if not hasName(QuickList[category].menuList, info.localizedName or name) then
				tinsert(QuickList[category].menuList, {
					text = gsub(info.localizedName or name, '^LDB: ', ''),
					checked = function() return E.EasyMenu.MenuGetItem(DT.SelectedDatatext, name) end,
					func = function() E.EasyMenu.MenuSetItem(DT.SelectedDatatext, name) end
				})
			end
		end

		tinsert(QuickList, { order = 99, text = ' ', notCheckable = true, isTitle = true })
		tinsert(QuickList, {
			order = 100, text = L["None"],
			checked = function() return E.EasyMenu.MenuGetItem(DT.SelectedDatatext, '') end,
			func = function() E.EasyMenu.MenuSetItem(DT.SelectedDatatext, '') end
		})

		DT:SortMenuList(QuickList)
	end
end

function DT:PopulateData(currencyOnly)
	local Collapsed = {}
	local listSize, i = GetCurrencyListSize(), 1

	local headerIndex
	while listSize >= i do
		local info = DT:CurrencyListInfo(i)
		if E.Retail and info.isHeader and not info.isHeaderExpanded then
			C_CurrencyInfo_ExpandCurrencyList(i, true)
			Collapsed[info.name] = true
		end
		if info.isHeader then
			G.datatexts.settings.Currencies.tooltipData[i] = { info.name, nil, nil, (info.name == expansion or info.name == MISCELLANEOUS) or strfind(info.name, LFG_TYPE_DUNGEON) }
			E.global.datatexts.settings.Currencies.tooltipData[i] = { info.name, nil, nil, E.global.datatexts.settings.Currencies.headers }

			headerIndex = i
		end
		if info.name and not info.isHeader then
			local currencyLink = E.Retail and C_CurrencyInfo_GetCurrencyListLink(i)
			local currencyID = currencyLink and C_CurrencyInfo_GetCurrencyIDFromLink(currencyLink)
			if currencyID then
				if DT.CurrencyList then
					DT.CurrencyList[tostring(currencyID)] = info.name
				end

				G.datatexts.settings.Currencies.tooltipData[i] = { info.name, currencyID, headerIndex, G.datatexts.settings.Currencies.tooltipData[headerIndex][4] }
				G.datatexts.settings.Currencies.idEnable[currencyID] = G.datatexts.settings.Currencies.tooltipData[headerIndex][4]
				E.global.datatexts.settings.Currencies.idEnable[currencyID] = E.global.datatexts.settings.Currencies.idEnable[currencyID] == nil and G.datatexts.settings.Currencies.idEnable[currencyID] or E.global.datatexts.settings.Currencies.idEnable[currencyID]
				E.global.datatexts.settings.Currencies.tooltipData[i] = { info.name, currencyID, headerIndex, E.global.datatexts.settings.Currencies.idEnable[currencyID] }
			end
		end

		i = i + 1
	end

	if E.Retail then
		for k = 1, listSize do
			local info = DT:CurrencyListInfo(k)
			if not info.name then
				break
			elseif info.isHeader and info.isHeaderExpanded and Collapsed[info.name] then
				C_CurrencyInfo_ExpandCurrencyList(k, false)
			end
		end
	end

	wipe(Collapsed)

	if E.Retail and not currencyOnly then
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
		local name = DT:CurrencyInfo(currencyID)
		if name then
			DT:PopulateData(true)
		end
	end
end

function DT:CurrencyListInfo(index)
	local info = E.Retail and C_CurrencyInfo_GetCurrencyListInfo(index) or {}

	if E.Wrath then
		info.name, info.isHeader, info.isHeaderExpanded, info.isUnused, info.isWatched, info.quantity, info.iconFileID, info.maxQuantity, info.weeklyMax, info.earnedThisWeek, info.isTradeable, info.itemID = GetCurrencyListInfo(index)
	end

	return info
end

function DT:CurrencyInfo(id)
	local info = E.Retail and C_CurrencyInfo_GetCurrencyInfo(id) or {}

	if E.Wrath then
		info.name, info.quantity, info.iconFileID, info.earnedThisWeek, info.weeklyMax, info.maxQuantity, info.isDiscovered = GetCurrencyInfo(id)
	end

	return info, info and info.name, format(iconString, info and info.iconFileID or '136012')
end

function DT:BackpackCurrencyInfo(index)
	local info = E.Retail and GetBackpackCurrencyInfo(index) or {}

	if E.Wrath then
		info.name, info.quantity, info.iconFileID, info.currencyTypesID = GetBackpackCurrencyInfo(index)
	end

	return info, info and info.name
end

function DT:PLAYER_ENTERING_WORLD()
	DT:LoadDataTexts()
end

function DT:BuildTables()
	local db = ElvDB
	if not db then db = {} ElvDB = db end

	if not db.gold then db.gold = {} end
	db.gold[E.myrealm] = db.gold[E.myrealm] or {}

	if not db.class then db.class = {} end
	db.class[E.myrealm] = db.class[E.myrealm] or {}
	db.class[E.myrealm][E.myname] = E.myclass

	if not db.faction then db.faction = {} end
	db.faction[E.myrealm] = db.faction[E.myrealm] or {}
	db.faction[E.myrealm][E.myname] = E.myfaction

	if not db.serverID then db.serverID = {} end
	db.serverID[E.serverID] = db.serverID[E.serverID] or {}
	db.serverID[E.serverID][E.myrealm] = true
end

function DT:Initialize()
	DT.Initialized = true
	DT.db = E.db.datatexts

	DT:BuildTables()

	E.EasyMenu:SetClampedToScreen(true)
	E.EasyMenu:EnableMouse(true)
	E.EasyMenu.MenuSetItem = function(dt, value)
		local panel = (dt.battlePanel and DT.db.battlePanel or DT.db.panels)

		panel[dt.parentName][dt.pointIndex] = value
		DT:UpdatePanelInfo(dt.parentName, dt.parent)

		DT.SelectedDatatext = nil
		CloseDropDownMenus()
	end
	E.EasyMenu.MenuGetItem = function(dt, value)
		local panel = (dt.battlePanel and DT.db.battlePanel or DT.db.panels)
		return dt and (panel[dt.parentName] and panel[dt.parentName][dt.pointIndex] == value)
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

	if E.Retail or E.Wrath then
		DT:RegisterCustomCurrencyDT() -- Register all the user created currency datatexts from the 'CustomCurrency' DT.

		if E.Retail then
			hooksecurefunc(_G.C_CurrencyInfo, 'SetCurrencyBackpack', function() DT:ForceUpdate_DataText('Currencies') end)

			hooksecurefunc(_G.C_ClassTalents, 'UpdateLastSelectedSavedConfigID', function(_, newConfigID)
				if not newConfigID then return end
				if DT.ClassTalentsID and newConfigID == C_ClassTalents_GetActiveConfigID() then return end
				DT.ClassTalentsID = newConfigID

				DT:ForceUpdate_DataText('Talent/Loot Specialization')
			end)
		else
			hooksecurefunc('SetCurrencyBackpack', function() DT:ForceUpdate_DataText('Currencies') end)
		end

		DT:PopulateData()
		DT:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	end

	for name in pairs(E.global.datatexts.customPanels) do
		DT:BuildPanelFrame(name, true)
	end

	LDB.RegisterCallback(E, 'LibDataBroker_DataObjectCreated', DT.SetupObjectLDB)

	DT:RegisterLDB() -- LibDataBroker
	DT:UpdateQuickDT()

	DT:RegisterEvent('UPDATE_BATTLEFIELD_SCORE')
	DT:RegisterEvent('MODIFIER_STATE_CHANGED', 'QuickDTMode')
	DT:RegisterEvent('PLAYER_ENTERING_WORLD')
end

--[[
	DT:RegisterDatatext(name, category, events, onEvent, onUpdate, onClick, onEnter, onLeave, localizedName, objectEvent, applySettings)

	name - name of the datatext (required) [string]
	category - name of the category the datatext belongs to. [string]
	events - must be a table with string values of event names to register [string or table]
	onEvent - function that gets fired when an event gets triggered [function]
	onUpdate - onUpdate script target function [function]
	onClick - function to fire when clicking the datatext [function]
	onEnter - function to fire OnEnter [function]
	onLeave - function to fire OnLeave, if not provided one will be set for you that hides the tooltip. [function]
	localizedName - localized name of the datetext [string]
	objectEvent - register events on an object, using E.RegisterEventForObject instead of panel.RegisterEvent [function]
	applySettings - function that fires when you change the dt settings or update the value color. [function]
]]

function DT:RegisterDatatext(name, category, events, onEvent, onUpdate, onClick, onEnter, onLeave, localizedName, objectEvent, applySettings)
	if not name then return end
	if type(category) ~= 'string' and category ~= nil then return E:Print(format('%s is an invalid DataText.', name)) end

	local data = { name = name, category = category }

	if type(events) == 'function' then
		return E:Print(format('%s is an invalid DataText. Events must be registered as a table or a string.', name))
	else
		data.events = type(events) == 'string' and { strsplit('[, ]', events) } or events
		data.eventFunc = onEvent
		data.objectEvent = objectEvent
	end

	if onUpdate and type(onUpdate) == 'function' then
		data.onUpdate = onUpdate
	end

	if onClick and type(onClick) == 'function' then
		data.onClick = onClick
	end

	if onEnter and type(onEnter) == 'function' then
		data.onEnter = onEnter
	end

	if onLeave and type(onLeave) == 'function' then
		data.onLeave = onLeave
	end

	if localizedName and type(localizedName) == 'string' then
		data.localizedName = localizedName
	end

	if applySettings and type(applySettings) == 'function' then
		data.applySettings = applySettings
	end

	DT.RegisteredDataTexts[name] = data
	DT.DataTextList[name] = localizedName or name

	if not G.datatexts.settings[name] then
		G.datatexts.settings[name] = {}
	end

	return data
end

E:RegisterModule(DT:GetName())
