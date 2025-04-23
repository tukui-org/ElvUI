local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local ACD = E.Libs.AceConfigDialog

local _G = _G
local hooksecurefunc = hooksecurefunc
local next, strsplit = next, strsplit
local unpack, sort, gsub, wipe = unpack, sort, gsub, wipe
local strupper, ipairs, tonumber = strupper, ipairs, tonumber
local floor, select, type, min = floor, select, type, min
local pairs, tinsert, tContains = pairs, tinsert, tContains
local strmatch, strtrim, strlower = strmatch, strtrim, strlower

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UIParent = UIParent

local EditBox_HighlightText = EditBox_HighlightText
local EditBox_ClearFocus = EditBox_ClearFocus

local EnableAddOn = C_AddOns.EnableAddOn
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

local grid
E.ConfigModeLayouts = {
	'ALL',
	'GENERAL',
	'SOLO',
	'PARTY',
	'ARENA',
	'RAID',
	'ACTIONBARS',
	'WIDGETS'
}

E.ConfigModeLocalizedStrings = {
	ALL = _G.ALL,
	GENERAL = _G.GENERAL,
	SOLO = _G.SOLO,
	PARTY = _G.PARTY,
	ARENA = _G.ARENA,
	RAID = _G.RAID,
	ACTIONBARS = _G.ACTIONBARS_LABEL,
	WIDGETS = L["Blizzard Widgets"]
}

local statusTextHooked = {}

function E:ConfigMode_AddGroup(layoutName, localizedName)
	if E.ConfigModeLocalizedStrings[layoutName] then return end

	tinsert(E.ConfigModeLayouts, layoutName)
	E.ConfigModeLocalizedStrings[layoutName] = localizedName or layoutName

	return true
end

function E:Grid_Show()
	if not grid then
		E:Grid_Create()
	elseif grid.boxSize ~= E.db.gridSize then
		grid:Hide()
		E:Grid_Create()
	else
		grid:Show()
	end
end

function E:Grid_Hide()
	if grid then
		grid:Hide()
	end
end

function E:ToggleMoveMode(which)
	if InCombatLockdown() then return end

	local mode = not E.ConfigurationMode
	if not which or which == '' then
		E.ConfigurationMode = mode
		which = 'all'
	else
		E.ConfigurationMode = true
		mode = true
	end

	E:ToggleMovers(mode, which)

	if mode then
		E:Grid_Show()
		_G.ElvUIGrid:SetAlpha(0.4)

		if not E.MoverPopupWindow then
			E:CreateMoverPopup()
		end

		E.MoverPopupWindow:Show()

		if E.Classic then
			_G.UIDropDownMenu_SetSelectedValue(E.MoverPopupDropdown, strupper(which))
		end

		if IsAddOnLoaded('ElvUI_Options') then
			E:Config_CloseWindow()
		end
	else
		E:Grid_Hide()
		_G.ElvUIGrid:SetAlpha(1)

		if E.MoverPopupWindow then
			E.MoverPopupWindow:Hide()
		end
	end
end

function E:Grid_GetRegion()
	if grid then
		if grid.regionCount and grid.regionCount > 0 then
			local line = select(grid.regionCount, grid:GetRegions())
			grid.regionCount = grid.regionCount - 1
			line:SetAlpha(1)
			return line
		else
			return grid:CreateTexture()
		end
	end
end

function E:Grid_Create()
	if not grid then
		grid = CreateFrame('Frame', 'ElvUIGrid', E.UIParent)
		grid:SetFrameStrata('BACKGROUND')
	else
		grid.regionCount = 0
		for _, region in next, { grid:GetRegions() } do
			if region.IsObjectType and region:IsObjectType('Texture') then
				grid.regionCount = grid.regionCount + 1
				region:SetAlpha(0)
			end
		end
	end

	local width, height = E.UIParent:GetSize()
	local size, half = E.mult * 0.5, height * 0.5

	local gSize = E.db.gridSize
	local gHalf = gSize * 0.5

	local ratio = width / height
	local hHeight = height * ratio
	local wStep = width / gSize
	local hStep = hHeight / gSize

	grid.boxSize = gSize
	grid:SetPoint('CENTER', E.UIParent)
	grid:Size(width, height)
	grid:Show()

	for i = 0, gSize do
		local tx = E:Grid_GetRegion()
		if i == gHalf then
			tx:SetColorTexture(1, 0, 0)
			tx:SetDrawLayer('BACKGROUND', 1)
		else
			tx:SetColorTexture(0, 0, 0)
			tx:SetDrawLayer('BACKGROUND', 0)
		end

		local iwStep = i*wStep
		tx:ClearAllPoints()
		tx:SetPoint('TOPLEFT', grid, 'TOPLEFT', iwStep - size, 0)
		tx:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', iwStep + size, 0)
	end

	do
		local tx = E:Grid_GetRegion()
		tx:SetColorTexture(1, 0, 0)
		tx:SetDrawLayer('BACKGROUND', 1)
		tx:ClearAllPoints()
		tx:SetPoint('TOPLEFT', grid, 'TOPLEFT', 0, -half + size)
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(half + size))
	end

	local hSteps = floor((height*0.5)/hStep)
	for i = 1, hSteps do
		local ihStep = i*hStep

		local tx = E:Grid_GetRegion()
		tx:SetColorTexture(0, 0, 0)
		tx:SetDrawLayer('BACKGROUND', 0)
		tx:ClearAllPoints()
		tx:SetPoint('TOPLEFT', grid, 'TOPLEFT', 0, -(half+ihStep) + size)
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(half+ihStep + size))

		tx = E:Grid_GetRegion()
		tx:SetColorTexture(0, 0, 0)
		tx:SetDrawLayer('BACKGROUND', 0)
		tx:ClearAllPoints()
		tx:SetPoint('TOPLEFT', grid, 'TOPLEFT', 0, -(half-ihStep) + size)
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(half-ihStep + size))
	end
end

function E:ConfigMode_OnClick()
	E:ToggleMoveMode(self.value)
end

do
	local selected = 'ALL'
	local function IsSelected(restrictEnum)
		return selected == restrictEnum
	end

	local function SetSelected(restrictEnum)
		E:ToggleMoveMode(restrictEnum)
		selected = restrictEnum
	end

	function E:ConfigMode_Initialize(root)
		if E.Classic then
			local info = _G.UIDropDownMenu_CreateInfo()
			info.func = E.ConfigMode_OnClick

			for _, configMode in ipairs(E.ConfigModeLayouts) do
				info.text = E.ConfigModeLocalizedStrings[configMode]
				info.value = configMode
				_G.UIDropDownMenu_AddButton(info)
			end

			_G.UIDropDownMenu_SetSelectedValue(E.MoverPopupDropdown, E.MoverPopupDropdown.selectedValue or 'ALL')
		else
			root:SetTag('ELVUI_MOVER_LAYOUT')

			for _, configMode in ipairs(E.ConfigModeLayouts) do
				root:CreateRadio(E.ConfigModeLocalizedStrings[configMode], IsSelected, SetSelected, configMode)
			end
		end
	end
end

function E:NudgeMover(nudgeX, nudgeY)
	local mover = E.MoverNudgeFrame.child
	if not mover then return end

	local x, y, point = E:CalculateMoverPoints(mover, nudgeX, nudgeY)

	mover:ClearAllPoints()
	mover:SetPoint(point, E.UIParent, point, x, y)
	E:SaveMoverPosition(mover.name)

	--Update coordinates in Nudge Window
	E:UpdateNudgeFrame(mover, x, y)
end

function E:UpdateNudgeFrame(mover, x, y)
	if not (x and y) then
		x, y = E:CalculateMoverPoints(mover)
	end

	x = E:Round(x)
	y = E:Round(y)

	E.MoverNudgeFrame.xOffset:SetText(x)
	E.MoverNudgeFrame.yOffset:SetText(y)
	E.MoverNudgeFrame.xOffset.currentValue = x
	E.MoverNudgeFrame.yOffset.currentValue = y
	E.MoverNudgeFrame.title:SetText(mover.textString)
end

function E:AssignFrameToNudge()
	E.MoverNudgeFrame.child = self
	E:UpdateNudgeFrame(self)
end

function E:CreateMoverPopup()
	local r, g, b = unpack(E.media.rgbvaluecolor)

	local f = CreateFrame('Frame', 'ElvUIMoverPopupWindow', UIParent)
	f:SetFrameStrata('DIALOG')
	f:SetFrameLevel(1000)
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:Size(370, 190)
	f:SetTemplate('Transparent')
	f:Point('BOTTOM', UIParent, 'CENTER', 0, 100)
	f:Hide()
	f:HookScript('OnHide', function()
		E.MoverNudgeFrame:Hide()
	end)

	E.MoverPopupWindow = f

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate(nil, true)
	header:Size(100, 25)
	header:SetPoint('CENTER', f, 'TOP')
	header:OffsetFrameLevel(2)
	header:EnableMouse(true)
	header:RegisterForClicks('AnyUp', 'AnyDown')
	header:SetScript('OnMouseDown', function() f:StartMoving() end)
	header:SetScript('OnMouseUp', function() f:StopMovingOrSizing() end)
	f.header = header

	local title = header:CreateFontString(nil, 'OVERLAY')
	title:FontTemplate()
	title:Point('CENTER', header, 'CENTER')
	title:SetText('ElvUI')
	f.title = title

	local desc = f:CreateFontString(nil, 'ARTWORK')
	desc:SetFontObject('GameFontHighlight')
	desc:SetJustifyV('TOP')
	desc:SetJustifyH('LEFT')
	desc:Point('TOPLEFT', 18, -20)
	desc:Point('BOTTOMRIGHT', -18, 48)
	desc:SetText(L["DESC_MOVERCONFIG"])
	f.desc = desc

	local snapName = f:GetName()..'CheckButton'
	local snapping = CreateFrame('CheckButton', snapName, f, 'UICheckButtonTemplate')
	snapping:SetScript('OnShow', function(cb) cb:SetChecked(E.db.general.stickyFrames) end)
	snapping:SetScript('OnClick', function(cb) E.db.general.stickyFrames = cb:GetChecked() end)
	snapping.text = _G[snapName..'Text']
	snapping.text:SetText(L["Sticky Frames"])
	snapping.text:FontTemplate(nil, 12, 'SHADOW')
	f.snapping = snapping

	local lock = CreateFrame('Button', f:GetName()..'CloseButton', f, 'UIPanelButtonTemplate')
	lock.Text:SetText(L["Lock"])
	lock:Width(80)
	lock:SetScript('OnClick', function()
		E:ToggleMoveMode()

		if E.ConfigurationToggled then
			E.ConfigurationToggled = nil

			if IsAddOnLoaded('ElvUI_Options') then
				E:Config_OpenWindow()
			end
		end
	end)
	f.lock = lock

	local reset = CreateFrame('Button', f:GetName()..'CloseButton', f, 'UIPanelButtonTemplate')
	reset.Text:SetText(L["Reset"])
	reset:SetScript('OnClick', function() E:ResetUI() end)
	reset:Width(100)
	f.reset = reset

	local align = CreateFrame('EditBox', f:GetName()..'EditBox', f, 'InputBoxTemplate')
	align:Size(30, 22)
	align:SetAutoFocus(false)
	align:SetScript('OnEscapePressed', function(eb)
		eb:SetText(E.db.gridSize)
		EditBox_ClearFocus(eb)
	end)
	align:SetScript('OnEnterPressed', function(eb)
		local text = eb:GetText()
		if tonumber(text) then
			if tonumber(text) <= 256 and tonumber(text) >= 4 then
				E.db.gridSize = tonumber(text)
			else
				eb:SetText(E.db.gridSize)
			end
		else
			eb:SetText(E.db.gridSize)
		end
		E:Grid_Show()
		EditBox_ClearFocus(eb)
	end)
	align:SetScript('OnEditFocusLost', function(eb)
		eb:SetText(E.db.gridSize)
	end)
	align:SetScript('OnEditFocusGained', EditBox_HighlightText)
	align:SetScript('OnShow', function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E.db.gridSize)
	end)

	align.text = align:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	align.text:Point('RIGHT', align, 'LEFT', -4, 0)
	align.text:SetText(L["Grid Size:"])
	align.text:FontTemplate(nil, 12, 'SHADOW')
	f.align = align

	--position buttons
	reset:Point('BOTTOMLEFT', 5, 5)
	snapping:Point('BOTTOMLEFT', reset, 'TOPLEFT', -4, 0)
	lock:Point('BOTTOMRIGHT', -5, 5)
	align:Point('TOPRIGHT', lock, 'TOPLEFT', -3, 0)

	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	S:HandleButton(reset)
	S:HandleEditBox(align)

	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:SetScript('OnEvent', function(mover)
		if mover:IsShown() then
			mover:Hide()
			E:Grid_Hide()
			E:ToggleMoveMode()
		end
	end)

	local dropDown = CreateFrame(E.Classic and 'Frame' or 'DropdownButton', f:GetName()..'DropDown', f, E.Classic and 'UIDropDownMenuTemplate' or 'WowStyle1DropdownTemplate')
	dropDown:Point('BOTTOMRIGHT', lock, 'TOPRIGHT', 2, 0)
	S:HandleDropDownBox(dropDown, 160)

	dropDown.text = dropDown:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	dropDown.text:Point('RIGHT', dropDown.backdrop, 'LEFT', -2, 0)
	dropDown.text:SetText(L["Config Mode:"])
	dropDown.text:FontTemplate(nil, 12, 'SHADOW')

	E.MoverPopupDropdown = dropDown

	f.dropDown = dropDown

	if E.Classic then
		_G.UIDropDownMenu_Initialize(dropDown, E.ConfigMode_Initialize)
	else
		dropDown:SetupMenu(E.ConfigMode_Initialize)
	end

	local nudgeFrame = CreateFrame('Frame', 'ElvUIMoverNudgeWindow', E.UIParent)
	nudgeFrame:SetFrameStrata('DIALOG')
	nudgeFrame:Size(200, 110)
	nudgeFrame:SetTemplate('Transparent')
	nudgeFrame:CreateShadow(5)
	nudgeFrame.shadow:SetBackdropBorderColor(r, g, b, 0.9)
	nudgeFrame:SetFrameLevel(500)
	nudgeFrame:EnableMouse(true)
	nudgeFrame:SetClampedToScreen(true)
	nudgeFrame:SetPropagateKeyboardInput(true)
	nudgeFrame:SetScript('OnKeyDown', function(_, btn)
		local Mod = IsAltKeyDown() or IsControlKeyDown()
		if btn == 'NUMPAD4' then
			E:NudgeMover(-1 * (Mod and 10 or 1))
		elseif btn == 'NUMPAD6' then
			E:NudgeMover(1 * (Mod and 10 or 1))
		elseif btn == 'NUMPAD8' then
			E:NudgeMover(nil, 1 * (Mod and 10 or 1))
		elseif btn == 'NUMPAD2' then
			E:NudgeMover(nil, -1 * (Mod and 10 or 1))
		end
	end)

	E.MoverNudgeFrame = nudgeFrame

	desc = nudgeFrame:CreateFontString(nil, 'ARTWORK')
	desc:SetFontObject('GameFontHighlight')
	desc:SetJustifyV('TOP')
	desc:SetJustifyH('LEFT')
	desc:Point('TOPLEFT', 18, -15)
	desc:Point('BOTTOMRIGHT', -18, 28)
	desc:SetJustifyH('CENTER')
	nudgeFrame.desc = desc

	header = CreateFrame('Button', nil, nudgeFrame)
	header:SetTemplate(nil, true)
	header:Size(100, 25)
	header:SetPoint('CENTER', nudgeFrame, 'TOP')
	header:OffsetFrameLevel(2)
	nudgeFrame.header = header

	title = header:CreateFontString(nil, 'OVERLAY')
	title:FontTemplate()
	title:Point('CENTER', header, 'CENTER')
	title:SetText(L["Nudge"])
	nudgeFrame.title = title

	local xOffset = CreateFrame('EditBox', nudgeFrame:GetName()..'XEditBox', nudgeFrame, 'InputBoxTemplate')
	xOffset:Size(50, 17)
	xOffset:SetAutoFocus(false)
	xOffset.currentValue = 0
	xOffset:SetScript('OnEscapePressed', function(eb)
		eb:SetText(E:Round(xOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	xOffset:SetScript('OnEnterPressed', function(eb)
		local num = eb:GetText()
		if tonumber(num) then
			local diff = num - xOffset.currentValue
			xOffset.currentValue = num
			E:NudgeMover(diff)
		end

		eb:SetText(E:Round(xOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	xOffset:SetScript('OnEditFocusLost', function(eb)
		eb:SetText(E:Round(xOffset.currentValue))
	end)
	xOffset:SetScript('OnEditFocusGained', EditBox_HighlightText)
	xOffset:SetScript('OnShow', function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E:Round(xOffset.currentValue))
	end)

	xOffset.text = xOffset:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	xOffset.text:Point('RIGHT', xOffset, 'LEFT', -4, 0)
	xOffset.text:SetText('X:')
	xOffset:Point('BOTTOMRIGHT', nudgeFrame, 'CENTER', -6, 8)
	S:HandleEditBox(xOffset)
	nudgeFrame.xOffset = xOffset

	local yOffset = CreateFrame('EditBox', nudgeFrame:GetName()..'YEditBox', nudgeFrame, 'InputBoxTemplate')
	yOffset:Size(50, 17)
	yOffset:SetAutoFocus(false)
	yOffset.currentValue = 0
	yOffset:SetScript('OnEscapePressed', function(eb)
		eb:SetText(E:Round(yOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	yOffset:SetScript('OnEnterPressed', function(eb)
		local num = eb:GetText()
		if tonumber(num) then
			local diff = num - yOffset.currentValue
			yOffset.currentValue = num
			E:NudgeMover(nil, diff)
		end

		eb:SetText(E:Round(yOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	yOffset:SetScript('OnEditFocusLost', function(eb)
		eb:SetText(E:Round(yOffset.currentValue))
	end)
	yOffset:SetScript('OnEditFocusGained', EditBox_HighlightText)
	yOffset:SetScript('OnShow', function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E:Round(yOffset.currentValue))
	end)

	yOffset.text = yOffset:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	yOffset.text:Point('RIGHT', yOffset, 'LEFT', -4, 0)
	yOffset.text:SetText('Y:')
	yOffset:Point('BOTTOMLEFT', nudgeFrame, 'CENTER', 16, 8)
	S:HandleEditBox(yOffset)
	nudgeFrame.yOffset = yOffset

	local resetButton = CreateFrame('Button', nudgeFrame:GetName()..'ResetButton', nudgeFrame, 'UIPanelButtonTemplate')
	resetButton:SetText(L["Reset"])
	resetButton:Point('TOP', nudgeFrame, 'CENTER', 0, 2)
	resetButton:Size(100, 25)
	resetButton:SetScript('OnClick', function()
		if E.MoverNudgeFrame.child and E.MoverNudgeFrame.child.textString then
			E:ResetMovers(E.MoverNudgeFrame.child.textString)
		end
	end)
	S:HandleButton(resetButton)
	nudgeFrame.resetButton = resetButton

	local upButton = CreateFrame('Button', nudgeFrame:GetName()..'UpButton', nudgeFrame)
	upButton:Point('BOTTOMRIGHT', nudgeFrame, 'BOTTOM', -6, 4)
	upButton:SetScript('OnClick', function() E:NudgeMover(nil, 1) end)
	S:HandleNextPrevButton(upButton)
	S:HandleButton(upButton)
	upButton:Size(22)
	nudgeFrame.upButton = upButton

	local downButton = CreateFrame('Button', nudgeFrame:GetName()..'DownButton', nudgeFrame)
	downButton:Point('BOTTOMLEFT', nudgeFrame, 'BOTTOM', 6, 4)
	downButton:SetScript('OnClick', function() E:NudgeMover(nil, -1) end)
	S:HandleNextPrevButton(downButton)
	S:HandleButton(downButton)
	downButton:Size(22)
	nudgeFrame.downButton = downButton

	local leftButton = CreateFrame('Button', nudgeFrame:GetName()..'LeftButton', nudgeFrame)
	leftButton:Point('RIGHT', upButton, 'LEFT', -6, 0)
	leftButton:SetScript('OnClick', function() E:NudgeMover(-1) end)
	S:HandleNextPrevButton(leftButton)
	S:HandleButton(leftButton)
	leftButton:Size(22)
	nudgeFrame.leftButton = leftButton

	local rightButton = CreateFrame('Button', nudgeFrame:GetName()..'RightButton', nudgeFrame)
	rightButton:Point('LEFT', downButton, 'RIGHT', 6, 0)
	rightButton:SetScript('OnClick', function() E:NudgeMover(1) end)
	S:HandleNextPrevButton(rightButton)
	S:HandleButton(rightButton)
	rightButton:Size(22)
	nudgeFrame.rightButton = rightButton
end

function E:Config_ResetSettings()
	E.configSavedPositionTop, E.configSavedPositionLeft = nil, nil
	E.global.general.AceGUI = E:CopyTable({}, E.DF.global.general.AceGUI)
end

function E:Config_GetPosition()
	return E.configSavedPositionTop, E.configSavedPositionLeft
end

function E:Config_GetSize()
	return E.global.general.AceGUI.width, E.global.general.AceGUI.height
end

function E:Config_GetStatus(frame)
	local status = frame and frame.obj and frame.obj.status
	local selected = status and status.groups and status.groups.selected

	return status, selected
end

function E:Config_UpdateSize(reset)
	local frame = E:Config_GetWindow()
	if not frame then return end

	local maxWidth, maxHeight = self.UIParent:GetSize()
	if frame.SetResizeBounds then
		frame:SetResizeBounds(800, 600, maxWidth-50, maxHeight-50)
	else
		frame:SetMinResize(800, 600)
		frame:SetMaxResize(maxWidth-50, maxHeight-50)
	end

	self.Libs.AceConfigDialog:SetDefaultSize('ElvUI', E:Config_GetDefaultSize())

	local status = E:Config_GetStatus(frame)
	if status then
		if reset then
			E:Config_ResetSettings()

			status.top, status.left = E:Config_GetPosition()
			status.width, status.height = E:Config_GetDefaultSize()

			frame.obj:ApplyStatus()
		else
			local top, left = E:Config_GetPosition()
			if top and left then
				status.top, status.left = top, left

				frame.obj:ApplyStatus()
			end
		end

		E:Config_UpdateLeftScroller(frame)
	end
end

function E:Config_GetDefaultSize()
	local width, height = E:Config_GetSize()
	local maxWidth, maxHeight = E.UIParent:GetSize()
	width, height = min(maxWidth-50, width), min(maxHeight-50, height)
	return width, height
end

function E:Config_StopMoving()
	local frame = self and self.GetParent and self:GetParent()
	local status = E:Config_GetStatus(frame)
	if status then
		E.configSavedPositionTop, E.configSavedPositionLeft = E:Round(frame:GetTop(), 2), E:Round(frame:GetLeft(), 2)
		E.global.general.AceGUI.width, E.global.general.AceGUI.height = E:Round(frame:GetWidth(), 2), E:Round(frame:GetHeight(), 2)
		E:Config_UpdateLeftScroller(frame)
	end
end

function E:Config_ButtonOnEnter()
	if E.ConfigTooltip:IsForbidden() or not self.desc then return end

	E.ConfigTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT', 0, 2)
	E.ConfigTooltip:AddLine(self.desc, 1, 1, 1, true)
	E.ConfigTooltip:Show()
end

function E:Config_ButtonOnLeave()
	if E.ConfigTooltip:IsForbidden() then return end

	E.ConfigTooltip:Hide()
end

function E:Config_RepositionOnEnter()
	if self.highlight then
		self.highlight:Show()
	else
		local r, g, b = unpack(E.media.rgbvaluecolor)
		self.texture:SetVertexColor(r, g, b, 1)
	end

	E.Config_ButtonOnEnter(self)
end

function E:Config_RepositionOnLeave()
	if self.highlight then
		self.highlight:Hide()
	else
		self.texture:SetVertexColor(1, 1, 1, 0.8)
	end

	E.Config_ButtonOnLeave()
end

function E:Config_PreviousLocation(editbox)
	local _, selected = E:Config_GetStatus(editbox.frame)
	if selected ~= 'search' then
		editbox.selected = selected or nil
	end
end

function E:Config_SearchUpdate(userInput)
	if not userInput then return end

	local C = E.Config[1]
	C:Search_ClearResults()

	local text = self:GetText()
	if strmatch(text, '%S+') then
		C.SearchText = strtrim(strlower(text))

		C:Search_Config()
		C:Search_AddResults()

		ACD:SelectGroup('ElvUI', 'search') -- trigger update
	else
		local _, selected = E:Config_GetStatus(self.frame)
		if selected == 'search' then
			ACD:SelectGroup('ElvUI', self.selected or 'general') -- try to stay or swap back to general if it cant
		end
	end
end

function E:Config_SearchClear()
	if not self.ClearFocus then
		self = self:GetParent()
	end

	local C = E.Config[1]
	C:Search_ClearResults()

	local _, selected = E:Config_GetStatus(self.frame)
	if selected == 'search' then
		ACD:SelectGroup('ElvUI', self.selected or 'general') -- try to stay or swap back to general if it cant
	end

	self:SetText('')
	EditBox_ClearFocus(self)
end

function E:Config_SearchFocusGained()
	EditBox_HighlightText(self)
	E:Config_PreviousLocation(self)
end

function E:Config_SearchFocusLost()
	EditBox_ClearFocus(self)
end

function E:Config_SearchOnEvent()
	local frame = self:HasFocus() and E:GetMouseFocus()
	if frame and (frame ~= self and frame ~= self.clearButton) then
		EditBox_ClearFocus(self)
	end
end

function E:Config_SliderOnMouseWheel(offset)
	local _, maxValue = self:GetMinMaxValues()
	if maxValue == 0 then return end

	local newValue = self:GetValue() - offset
	if newValue < 0 then newValue = 0 end
	if newValue > maxValue then return end

	self:SetValue(newValue)
	self.buttons:Point('TOPLEFT', 0, newValue * 36)
end

function E:Config_SliderOnValueChanged(value)
	self:SetValue(value)
	self.buttons:Point('TOPLEFT', 0, value * 36)
end

function E:Config_SetButtonText(btn, noColor)
	local name = btn.info.name
	if type(name) == 'function' then name = name() end

	if noColor then
		btn:SetText(name:gsub('|c[fF][fF]%x%x%x%x%x%x',''):gsub('|r',''))
	else
		btn:SetText(name)
	end
end

function E:Config_CreateSeparatorLine(frame, lastButton)
	local line = frame.leftHolder.buttons:CreateTexture()
	line:SetTexture(E.Media.Textures.White8x8)
	line:SetVertexColor(1, .82, 0, .4)
	line:Size(179, 2)
	line:Point('TOP', lastButton, 'BOTTOM', 0, -6)
	line.separator = true

	return line
end

function E:Config_SetButtonColor(btn, disabled)
	btn:SetEnabled(not disabled)

	if not btn.Text then return end

	if disabled then
		btn.Text:SetTextColor(1, 1, 1)
		E:Config_SetButtonText(btn, true)

		if btn.SetBackdropColor then
			btn:SetBackdropColor(1, .82, 0, 0.4)
			btn:SetBackdropBorderColor(1, .82, 0, 1)
		end
	else
		btn.Text:SetTextColor(1, .82, 0)
		E:Config_SetButtonText(btn)

		if btn.SetBackdropColor then
			local r1, g1, b1 = unpack(E.media.backdropcolor)
			btn:SetBackdropColor(r1, g1, b1, 1)

			local r2, g2, b2 = unpack(E.media.bordercolor)
			btn:SetBackdropBorderColor(r2, g2, b2, 1)
		end
	end
end

function E:Config_UpdateSliderPosition(btn)
	local left = btn and btn.frame and btn.frame.leftHolder
	if left and left.slider then
		E.Config_SliderOnValueChanged(left.slider, btn.sliderValue or 0)
	end
end

function E:Config_CreateFrame(info, frame, unskinned, frameType, ...)
	local element = CreateFrame(frameType, ...)
	element.frame = frame
	element.desc = info.desc
	element.info = info

	if frameType == 'Button' then
		if not unskinned then
			E.Skins:HandleButton(element)
		end

		element:SetScript('OnClick', info.func)

		if element.Text then
			E:Config_SetButtonText(element)
			E:Config_SetButtonColor(element, element.info.key == 'general')
			element:HookScript('OnEnter', E.Config_ButtonOnEnter)
			element:HookScript('OnLeave', E.Config_ButtonOnLeave)
			element:Width(element:GetTextWidth() + 40)
		end
	elseif frameType == 'EditBox' then
		if not unskinned then
			E.Skins:HandleEditBox(element)
		end

		element:HookScript('OnTextChanged', info.update)
		element:SetScript('OnEscapePressed', info.clear)
		element:SetScript('OnEditFocusLost', info.focusLost)
		element:SetScript('OnEditFocusGained', info.focusGained)
		element.clearButton:HookScript('OnClick', info.clear)

		element:Size(220, 22)
	end

	return element
end

function E:Config_DialogOpened(name)
	if name ~= 'ElvUI' then return end

	local frame = E:Config_GetWindow()
	if frame and frame.leftHolder then
		E:Config_WindowOpened(frame)
	end
end

function E:Config_UpdateLeftButtons()
	local frame = E:Config_GetWindow()
	if not (frame and frame.leftHolder) then return end

	local _, selected = E:Config_GetStatus(frame)
	for _, btn in next, frame.leftHolder.buttons do
		if type(btn) == 'table' and btn.IsObjectType and btn:IsObjectType('Button') then
			local enabled = btn.info.key == selected
			E:Config_SetButtonColor(btn, enabled)

			if enabled then
				E:Config_UpdateSliderPosition(btn)
			end
		end
	end
end

function E:Config_UpdateLeftScroller(frame)
	local left = frame and frame.leftHolder
	if not left then return end

	local btns = left.buttons
	local bottom = btns:GetBottom()
	if not bottom then return end
	btns:Point('TOPLEFT', 0, 0)

	local max = 0
	for _, btn in next, btns do
		local button = type(btn) == 'table' and btn.IsObjectType and btn:IsObjectType('Button')
		if button then
			btn.sliderValue = nil

			local btm = btn:GetBottom()
			if btm then
				if bottom > btm then
					max = max + 1
					btn.sliderValue = max
				end
			end
		end
	end

	local slider = left.slider
	slider:SetMinMaxValues(0, max)
	slider:SetValue(0)

	if max == 0 then
		slider.thumb.holder:Hide()
	else
		slider.thumb.holder:Show()
	end
end

function E:Config_SaveOldPosition(frame)
	if frame.GetNumPoints and not frame.oldPosition then
		frame.oldPosition = {}
		for i = 1, frame:GetNumPoints() do
			tinsert(frame.oldPosition, {frame:GetPoint(i)})
		end
	end
end

function E:Config_RestoreOldPosition(frame)
	local position = frame.oldPosition
	if position then
		frame:ClearAllPoints()
		for i = 1, #position do
			frame:Point(unpack(position[i]))
		end
	end
end

function E:Config_HandleLeftButton(info, frame, unskinned, buttons, last, index)
	local btn = E:Config_CreateFrame(info, frame, unskinned, 'Button', nil, buttons, 'UIPanelButtonTemplate')
	btn:Width(176)

	if not last then
		btn:Point('TOP', buttons, 'TOP', -1, 0)
	else
		btn:Point('TOP', last, 'BOTTOM', 0, (last.separator and -6) or -4)
	end

	buttons[index] = btn

	return btn
end

function E:Config_StripNameColor(name)
	if type(name) == 'function' then
		name = name()
	end

	return E:StripString(name)
end

local function Config_SortButtons(a, b)
	local A1, B1 = a[1], b[1]
	if A1 and B1 then
		if A1 == B1 then
			local A3, B3 = a[3], b[3]
			if A3 and B3 and (A3.name and B3.name) then
				return E:Config_StripNameColor(A3.name) < E:Config_StripNameColor(B3.name)
			end
		end

		return A1 < B1
	end
end

function E:Config_CreateLeftButtons(frame, unskinned, options)
	local opts = {}
	for key, info in pairs(options) do
		if (not info.order or info.order < 6) and not tContains(E.OriginalOptions, key) then
			info.order = 6
		end
		if key == 'profiles' then
			info.desc = nil
		end
		tinsert(opts, {info.order, key, info})
	end
	sort(opts, Config_SortButtons)

	local buttons, last, order = frame.leftHolder.buttons
	for index, opt in ipairs(opts) do
		local info = opt[3]
		local key = opt[2]

		if (order == 2 or order == 5) and order < opt[1] then
			last = E:Config_CreateSeparatorLine(frame, last)
		end

		order = opt[1]

		info.key = key
		info.func = function() ACD:SelectGroup('ElvUI', key) end

		if key ~= 'search' then
			last = E:Config_HandleLeftButton(info, frame, unskinned, buttons, last, index)
		end
	end
end

function E:Config_CloseClicked()
	if self.originalClose then
		self.originalClose:Click()
	end
end

function E:Config_CloseWindow()
	ACD:Close('ElvUI')

	if not E.ConfigTooltip:IsForbidden() then
		E.ConfigTooltip:Hide()
	end
end

function E:Config_OpenWindow()
	ACD:Open('ElvUI')

	if not E.ConfigTooltip:IsForbidden() then
		E.ConfigTooltip:Hide()
	end
end

function E:Config_GetWindow()
	local ConfigOpen = ACD.OpenFrames and ACD.OpenFrames.ElvUI
	return ConfigOpen and ConfigOpen.frame
end

local ConfigLogoTop
E.valueColorUpdateFuncs.ConfigLogo = function(_, _, r, g, b)
	if ConfigLogoTop then
		ConfigLogoTop:SetVertexColor(r, g, b)
	end

	if E.MoverNudgeFrame and E.MoverNudgeFrame.shadow then
		E.MoverNudgeFrame.shadow:SetBackdropBorderColor(r, g, b, 0.9)
	end
end

function E:Config_WindowClosed()
	if not self.bottomHolder then return end

	local frame = E:Config_GetWindow()
	if not frame or frame ~= self then
		self.bottomHolder:Hide()
		self.leftHolder:Hide()
		self.topHolder:Hide()
		self.leftHolder.slider:Hide()
		self.closeButton:Hide()
		self.originalClose:Show()

		ConfigLogoTop = nil

		E:StopElasticize(self.leftHolder.LogoTop)
		E:StopElasticize(self.leftHolder.LogoBottom)

		E:Config_RestoreOldPosition(self.topHolder.version)
		E:Config_RestoreOldPosition(self.obj.content)
		E:Config_RestoreOldPosition(self.obj.titlebg)

		local statusParent = self.statusText and self.statusText.parent
		if statusParent then
			statusParent:Show()

			E:Config_RestoreOldPosition(statusParent)
		end

		if E.ShowPopup then
			E:StaticPopup_Show('CONFIG_RL')
			E.ShowPopup = nil
		end
	end
end

function E:Config_ContentPlacement(frame, content, unskinned, statusShown)
	content:ClearAllPoints()
	content:Point('TOPLEFT', frame, 'TOPLEFT', unskinned and 13 or 7, -(frame.bottomHolder:GetHeight() + (unskinned and 46 or 41)))
	content:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -(unskinned and 18 or 8), (statusShown and (unskinned and 32 or 25)) or (unskinned and 12) or 2)
end

function E:Config_SetStatusText(text)
	if not ConfigLogoTop or not self.parent then return end

	local shown = text and text ~= ''
	self.parent:SetShown(shown)

	E:Config_ContentPlacement(self.frame, self.content, not E.private.skins.ace3Enable, shown)
end

function E:Config_WindowOpened(frame)
	if frame and frame.bottomHolder and not ConfigLogoTop then
		frame.bottomHolder:Show()
		frame.leftHolder:Show()
		frame.topHolder:Show()
		frame.leftHolder.slider:Show()
		frame.closeButton:Show()
		frame.originalClose:Hide()

		frame.leftHolder.LogoTop:SetVertexColor(unpack(E.media.rgbvaluecolor))
		ConfigLogoTop = frame.leftHolder.LogoTop

		E:Elasticize(frame.leftHolder.LogoTop, 128, 64)
		E:Elasticize(frame.leftHolder.LogoBottom, 128, 64)

		local unskinned = not E.private.skins.ace3Enable
		local version = frame.topHolder.version
		E:Config_SaveOldPosition(version)
		version:ClearAllPoints()
		version:Point('LEFT', frame.topHolder, 'LEFT', unskinned and 8 or 6, unskinned and -4 or 0)

		local content = frame.obj.content
		E:Config_SaveOldPosition(content)
		E:Config_ContentPlacement(frame, content, unskinned)

		local titlebg = frame.obj.titlebg
		E:Config_SaveOldPosition(titlebg)
		titlebg:ClearAllPoints()
		titlebg:SetPoint('TOPLEFT', frame)
		titlebg:SetPoint('TOPRIGHT', frame)

		local statusParent = frame.statusText and frame.statusText.parent
		if statusParent then
			E:Config_SaveOldPosition(statusParent)

			statusParent:ClearAllPoints()
			statusParent:Point('TOPLEFT', frame.leftHolder, 'BOTTOMRIGHT', unskinned and 11 or 1, unskinned and 38 or 22)
			statusParent:Point('BOTTOMRIGHT', frame, -2, 2)
		end
	end
end

function E:Config_CreateBottomButtons(frame, unskinned)
	local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')
	local C = E.Config[1]

	local last, search
	for index, info in ipairs({
		{
			var = 'Install',
			name = L["Install"],
			desc = L["Run the installation process."],
			func = function()
				E:Install()
				E:ToggleOptions()
			end
		},
		{
			var = 'ShowStatusReport',
			name = L["Status"],
			desc = L["Shows a frame with needed info for support."],
			func = function()
				E:ShowStatusReport()
				E:ToggleOptions()
				E.StatusReportToggled = true
			end
		},
		{
			var = 'ToggleAnchors',
			name = L["Movers"],
			desc = L["Unlock various elements of the UI to be repositioned."],
			func = function()
				E:ToggleMoveMode()
				E.ConfigurationToggled = true
			end
		},
		{
			editbox = 'SearchBoxTemplate',
			clear = E.Config_SearchClear,
			update = E.Config_SearchUpdate,
			focusLost = E.Config_SearchFocusLost,
			focusGained = E.Config_SearchFocusGained,
			event = E.Config_SearchOnEvent,
			var = 'Search',
			name = L["Search"]
		},
		{
			var = 'WhatsNew',
			name = L["Whats New"],
			hidden = function()
				return C.SearchText ~= '' or next(C.SearchCache)
			end,
			func = function()
				if search then
					E:Config_PreviousLocation(search)
				end

				C:Search_ClearResults()
				C:Search_Config(nil, nil, nil, true)
				C:Search_AddResults()

				ACD:SelectGroup('ElvUI', 'search') -- trigger update
			end
		},
		{
			texture = true,
			var = 'RepositionWindow',
			name = L["Reposition Window"],
			desc = L["Reset the size and position of this frame."],
			func = function() E:Config_UpdateSize(true) end
		}
	}) do
		local element
		if info.var == 'RepositionWindow' then
			element = E:Config_CreateFrame(info, frame, true, 'Button', nil, frame.bottomHolder)
			element:Size(unskinned and 34 or 18)

			local texture = element:CreateTexture()
			texture:SetTexture(unskinned and 386859 or E.Media.Textures.Resize2)
			texture:SetAllPoints()
			element.texture = texture

			if unskinned then
				local highlight = element:CreateTexture()
				highlight:SetTexture(130757)
				highlight:SetBlendMode('ADD')
				highlight:SetAllPoints()
				highlight:Hide()
				element.highlight = highlight
			else
				texture:SetVertexColor(1, 1, 1, 0.8)
			end

			element:HookScript('OnEnter', E.Config_RepositionOnEnter)
			element:HookScript('OnLeave', E.Config_RepositionOnLeave)
		elseif info.editbox then
			element = E:Config_CreateFrame(info, frame, unskinned, 'EditBox', nil, frame.bottomHolder, info.editbox)
		else
			element = E:Config_CreateFrame(info, frame, unskinned, 'Button', nil, frame.bottomHolder, 'UIPanelButtonTemplate')
		end

		if not search and (info.var == 'Search') then
			search = element

			if not E.Retail then
				search:RegisterEvent('GLOBAL_MOUSE_DOWN')
				search:SetScript('OnEvent', info.event)
			end
		end

		local offset = unskinned and 14 or 8

		if not last then
			element:Point('BOTTOMLEFT', frame.bottomHolder, 'BOTTOMLEFT', unskinned and 24 or offset, offset)
		elseif info.var == 'RepositionWindow' then
			element:Point('TOPRIGHT', frame.topHolder, 'TOPRIGHT', -(unskinned and 46 or 32), -(unskinned and 4 or 2))
		elseif index == 4 then -- Search
			element:Point('BOTTOMRIGHT', frame.bottomHolder, 'BOTTOMRIGHT', -(unskinned and 24 or offset), offset)
		elseif index > 4 then
			element:Point('RIGHT', last, 'LEFT', -(index == 5 and (unskinned and 8 or 6) or (unskinned and 2) or 4), 0)
		else
			element:Point('LEFT', last, 'RIGHT', unskinned and 2 or 4, 0)
		end

		last = element

		frame.bottomHolder[info.var] = element
	end
end

local pageNodes = {}
function E:Config_GetToggleMode(frame, msg)
	local pages, msgStr
	if msg and msg ~= '' then
		pages = {strsplit(',', msg)}
		msgStr = gsub(msg, ',', '\001')
	end

	local empty = pages ~= nil
	if not frame or empty then
		if empty then
			local pageCount, index, mainSel = #pages
			if pageCount > 1 then
				wipe(pageNodes)
				index = 0

				local main, mainNode, mainSelStr, sub, subNode, subSel
				for i = 1, pageCount do
					if i == 1 then
						main = pages[i] and ACD.Status and ACD.Status.ElvUI
						mainSel = main and main.status and main.status.groups and main.status.groups.selected
						mainSelStr = mainSel and ('^'..E:EscapeString(mainSel)..'\001')
						mainNode = main and main.children and main.children[pages[i]]
						pageNodes[index+1], pageNodes[index+2] = main, mainNode
					else
						sub = pages[i] and pageNodes[i] and ((i == pageCount and pageNodes[i]) or pageNodes[i].children[pages[i]])
						subSel = sub and sub.status and sub.status.groups and sub.status.groups.selected
						subNode = (mainSelStr and msgStr:match(mainSelStr..E:EscapeString(pages[i])..'$') and (subSel and subSel == pages[i])) or ((i == pageCount and not subSel) and mainSel and mainSel == msgStr)
						pageNodes[index+1], pageNodes[index+2] = sub, subNode
					end
					index = index + 2
				end
			else
				local main = pages[1] and ACD.Status and ACD.Status.ElvUI
				mainSel = main and main.status and main.status.groups and main.status.groups.selected
			end

			if frame and ((not index and mainSel and mainSel == msg) or (index and pageNodes and pageNodes[index])) then
				return 'Close'
			else
				return 'Open', pages
			end
		else
			return 'Open'
		end
	else
		return 'Close'
	end
end

function E:ToggleOptions(msg)
	if E:AlertCombat() then
		self.ShowOptions = true
		return
	end

	if not IsAddOnLoaded('ElvUI_Options') then
		local _, _, _, _, reason = GetAddOnInfo('ElvUI_Options')

		if reason == 'MISSING' then
			E:Print('|cffff0000Error|r -- Addon "ElvUI_Options" not found.')
			return
		else
			EnableAddOn('ElvUI_Options')
			LoadAddOn('ElvUI_Options')

			-- version check if it's actually enabled
			local config = E.Config and E.Config[1]
			if not config or (E.version ~= config.version) then
				E.updateRequestTriggered = true
				E:StaticPopup_Show('UPDATE_REQUEST')
				return
			end
		end
	end

	local frame = E:Config_GetWindow()
	local mode, pages = E:Config_GetToggleMode(frame, msg)

	if not ACD.OpenHookedElvUI then
		hooksecurefunc(E.Libs.AceConfigDialog, 'Open', E.Config_DialogOpened)
		ACD.OpenHookedElvUI = true
	end

	ACD[mode](ACD, 'ElvUI')

	if not frame then
		frame = E:Config_GetWindow()
	end

	if mode == 'Open' and frame then
		local ACR = E.Libs.AceConfigRegistry
		if ACR and not ACR.NotifyHookedElvUI then
			hooksecurefunc(E.Libs.AceConfigRegistry, 'NotifyChange', E.Config_UpdateLeftButtons)
			ACR.NotifyHookedElvUI = true
			E:Config_UpdateSize()
		end

		local unskinned = not E.private.skins.ace3Enable
		if not frame.bottomHolder then -- window was released or never opened
			frame:HookScript('OnHide', E.Config_WindowClosed)

			for _, child in next, { frame:GetChildren() } do
				local button = child:IsObjectType('Button')
				if button and child:GetText() == _G.CLOSE then
					frame.originalClose = child
					child:Hide()
				elseif button or child:IsObjectType('Frame') then
					if unskinned and child.GetBackdrop then
						local info = child:GetBackdrop()
						if info and info.edgeFile == [[Interface\Tooltips\UI-Tooltip-Border]] then
							child:SetBackdrop()
						end
					end

					local point = not unskinned and not frame.resizeArrow and child:GetPoint()
					if point == 'BOTTOMRIGHT' then
						for _, region in next, { child:GetRegions() } do
							local texture = region:IsObjectType('Texture') and region:GetTexture()
							if texture == 137057 then
								if not child.resizeTexture then
									region:SetTexture(E.Media.Textures.ArrowUp)
									region:SetTexCoord(0, 1, 0, 1)
									region:SetRotation(-2.35)
									region:SetAllPoints()

									child.resizeTexture = region
								elseif texture then -- this is the smaller texture, we don't need it
									region:SetAlpha(0)
								end
							end
						end

						child:Size(24)
						child:Point('BOTTOMRIGHT', 1, -1)
						child:SetFrameLevel(200)

						frame.resizeArrow = child
					end

					if child:HasScript('OnMouseUp') then
						child:HookScript('OnMouseUp', E.Config_StopMoving)
					end
				end
			end

			local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
			close:SetScript('OnClick', E.Config_CloseClicked)
			close:SetFrameLevel(1000)
			close:Point('TOPRIGHT', unskinned and -12 or 1, unskinned and -12 or 2)
			close:Size(unskinned and 30 or 32)
			close.originalClose = frame.originalClose
			frame.closeButton = close

			local statusText = frame.obj.statustext
			if statusText then
				frame.statusText = statusText

				statusText.parent = statusText:GetParent()
				statusText.content = frame.obj.content
				statusText.frame = frame

				if not statusTextHooked[statusText] then
					statusTextHooked[statusText] = true

					hooksecurefunc(statusText, 'SetText', E.Config_SetStatusText)
				end
			end

			local left = CreateFrame('Frame', nil, frame)
			left:Point('TOPLEFT', unskinned and 10 or 2, unskinned and -6 or -2)
			left:Point('BOTTOMRIGHT', frame, 'BOTTOMLEFT', 182, 2)
			frame.leftHolder = left

			local top = CreateFrame('Frame', nil, frame)
			top.version = frame.obj.titletext
			top:Point('TOPRIGHT', frame, -2, 0)
			top:Point('TOPLEFT', left, 'TOPRIGHT', 1, 0)
			top:Height(24)
			frame.topHolder = top

			local bottom = CreateFrame('Frame', nil, frame)
			bottom:Point('TOPLEFT', top, 'BOTTOMLEFT', unskinned and -15 or 0, -(unskinned and 15 or 1))
			bottom:Point('TOPRIGHT', top, 'BOTTOMRIGHT', unskinned and 10 or 0, -(unskinned and 15 or 1))
			bottom:Height(37)
			frame.bottomHolder = bottom

			local LogoBottom = left:CreateTexture()
			LogoBottom:SetTexture(E.Media.Textures.LogoBottomSmall)
			LogoBottom:Point('CENTER', left, 'TOP', unskinned and 10 or 0, unskinned and -40 or -36)
			LogoBottom:Size(128, 64)
			left.LogoBottom = LogoBottom

			local LogoTop = left:CreateTexture()
			LogoTop:SetTexture(E.Media.Textures.LogoTopSmall)
			LogoTop:Point('CENTER', left, 'TOP', unskinned and 10 or 0, unskinned and -40 or -36)
			LogoTop:Size(128, 64)
			left.LogoTop = LogoTop

			local buttonsHolder = CreateFrame('Frame', nil, left)
			buttonsHolder:Point('TOPLEFT', unskinned and 4 or 1, -70)
			buttonsHolder:Point('BOTTOMRIGHT', unskinned and 6 or 1, unskinned and 10 or 0)
			buttonsHolder:SetClipsChildren(true)
			left.buttonsHolder = buttonsHolder

			local buttons = CreateFrame('Frame', nil, buttonsHolder)
			buttons:Point('BOTTOMRIGHT')
			buttons:Point('TOPLEFT', 0, 0)
			left.buttons = buttons

			local slider = CreateFrame('Slider', nil, frame)
			slider:SetThumbTexture(E.Media.Textures.White8x8)
			slider:SetScript('OnMouseWheel', E.Config_SliderOnMouseWheel)
			slider:SetScript('OnValueChanged', E.Config_SliderOnValueChanged)
			slider:SetOrientation('VERTICAL')
			slider:SetObeyStepOnDrag(true)
			slider:SetValueStep(1)
			slider:SetValue(0)
			slider:Width(192)
			slider:Point('TOPLEFT', buttons, 'TOPLEFT', 0, 0)
			slider:Point('BOTTOMRIGHT', left, 'BOTTOMRIGHT', unskinned and 3 or 0, unskinned and 10 or 1)
			slider.buttons = buttons
			left.slider = slider

			local thumb = slider:GetThumbTexture()
			thumb:Point('LEFT', left, 'RIGHT', unskinned and 6 or 2, 0)
			thumb:Size(8, 12)
			thumb:SetAlpha(0) -- hide this one, its under the unskinned buttons
			left.slider.thumb = thumb

			local thumbHolder = CreateFrame('Frame', nil, left)
			thumbHolder:SetFrameLevel(200)
			thumbHolder:SetAllPoints(thumb)
			thumb.holder = thumbHolder

			local thumbTexture = thumbHolder:CreateTexture()
			thumbTexture:SetTexture(E.media.blankTex)
			thumbTexture:SetDrawLayer('OVERLAY')
			thumbTexture:SetVertexColor(1, 1, 1, 0.5)
			thumbTexture:SetAllPoints()
			thumbHolder.texture = thumbTexture

			if not unskinned then
				local statusParent = statusText and statusText.parent
				if statusParent then
					statusParent:Hide()
					statusParent:SetTemplate('Transparent')
				end

				bottom:SetTemplate('Transparent')
				left:SetTemplate('Transparent')
				top:SetTemplate('Transparent')

				E.Skins:HandleCloseButton(close)
			else
				for _, region in next, { frame:GetRegions() } do
					local texture = region:IsObjectType('Texture') and region:GetTexture()
					if texture == 131080 then
						region:SetAlpha(0)
					end
				end
			end

			E:Config_CreateLeftButtons(frame, unskinned, E.Options.args)
			E:Config_CreateBottomButtons(frame, unskinned)
			E:Config_UpdateLeftScroller(frame)
			E:Config_WindowOpened(frame)
		end

		if pages then
			ACD:SelectGroup('ElvUI', unpack(pages))
		end
	end
end
