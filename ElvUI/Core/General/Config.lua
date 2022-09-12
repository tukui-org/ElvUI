local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, sort, gsub, wipe = unpack, sort, gsub, wipe
local strupper, ipairs, tonumber = strupper, ipairs, tonumber
local floor, select, type, min = floor, select, type, min
local pairs, tinsert, tContains = pairs, tinsert, tContains
local strsplit = strsplit

local hooksecurefunc = hooksecurefunc
local EnableAddOn = EnableAddOn
local LoadAddOn = LoadAddOn
local GetAddOnMetadata = GetAddOnMetadata
local GetAddOnInfo = GetAddOnInfo
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown
local EditBox_ClearFocus = EditBox_ClearFocus
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local RESET = RESET
-- GLOBALS: ElvUIMoverPopupWindow, ElvUIMoverNudgeWindow, ElvUIMoverPopupWindowDropDown

local ConfigTooltip = CreateFrame('GameTooltip', 'ElvUIConfigTooltip', E.UIParent, 'SharedTooltipTemplate')

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

	self:ToggleMovers(mode, which)

	if mode then
		E:Grid_Show()
		_G.ElvUIGrid:SetAlpha(0.4)

		if not ElvUIMoverPopupWindow then
			E:CreateMoverPopup()
		end

		ElvUIMoverPopupWindow:Show()
		_G.UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, strupper(which))

		if IsAddOnLoaded('ElvUI_OptionsUI') then
			E:Config_CloseWindow()
		end
	else
		E:Grid_Hide()
		_G.ElvUIGrid:SetAlpha(1)

		if ElvUIMoverPopupWindow then
			ElvUIMoverPopupWindow:Hide()
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
		local numRegions = grid:GetNumRegions()
		for i = 1, numRegions do
			local region = select(i, grid:GetRegions())
			if region and region.IsObjectType and region:IsObjectType('Texture') then
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

local function ConfigMode_OnClick(self)
	E:ToggleMoveMode(self.value)
end

local function ConfigMode_Initialize()
	local info = _G.UIDropDownMenu_CreateInfo()
	info.func = ConfigMode_OnClick

	for _, configMode in ipairs(E.ConfigModeLayouts) do
		info.text = E.ConfigModeLocalizedStrings[configMode]
		info.value = configMode
		_G.UIDropDownMenu_AddButton(info)
	end

	local dd = ElvUIMoverPopupWindowDropDown
	_G.UIDropDownMenu_SetSelectedValue(dd, dd.selectedValue or 'ALL')
end

function E:NudgeMover(nudgeX, nudgeY)
	local mover = ElvUIMoverNudgeWindow.child
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

	local ElvUIMoverNudgeWindow = ElvUIMoverNudgeWindow
	ElvUIMoverNudgeWindow.xOffset:SetText(x)
	ElvUIMoverNudgeWindow.yOffset:SetText(y)
	ElvUIMoverNudgeWindow.xOffset.currentValue = x
	ElvUIMoverNudgeWindow.yOffset.currentValue = y
	ElvUIMoverNudgeWindow.title:SetText(mover.textString)
end

function E:AssignFrameToNudge()
	ElvUIMoverNudgeWindow.child = self
	E:UpdateNudgeFrame(self)
end

function E:CreateMoverPopup()
	local r, g, b = unpack(E.media.rgbvaluecolor)

	local f = CreateFrame('Frame', 'ElvUIMoverPopupWindow', _G.UIParent)
	f:SetFrameStrata('FULLSCREEN_DIALOG')
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetFrameLevel(200)
	f:SetClampedToScreen(true)
	f:Size(370, 190)
	f:SetTemplate('Transparent')
	f:Point('BOTTOM', _G.UIParent, 'CENTER', 0, 100)
	f:Hide()

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate(nil, true)
	header:Size(100, 25)
	header:SetPoint('CENTER', f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)
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
	local snapping = CreateFrame('CheckButton', snapName, f, 'OptionsCheckButtonTemplate')
	snapping:SetScript('OnShow', function(cb) cb:SetChecked(E.db.general.stickyFrames) end)
	snapping:SetScript('OnClick', function(cb) E.db.general.stickyFrames = cb:GetChecked() end)
	snapping.text = _G[snapName..'Text']
	snapping.text:SetText(L["Sticky Frames"])
	f.snapping = snapping

	local lock = CreateFrame('Button', f:GetName()..'CloseButton', f, 'OptionsButtonTemplate')
	lock.Text:SetText(L["Lock"])
	lock:SetScript('OnClick', function()
		E:ToggleMoveMode()

		if E.ConfigurationToggled then
			E.ConfigurationToggled = nil

			if IsAddOnLoaded('ElvUI_OptionsUI') then
				E:Config_OpenWindow()
			end
		end
	end)
	f.lock = lock

	local align = CreateFrame('EditBox', f:GetName()..'EditBox', f, 'InputBoxTemplate')
	align:Size(24, 17)
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
	align:SetScript('OnEditFocusGained', align.HighlightText)
	align:SetScript('OnShow', function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E.db.gridSize)
	end)

	align.text = align:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	align.text:Point('RIGHT', align, 'LEFT', -4, 0)
	align.text:SetText(L["Grid Size:"])
	f.align = align

	--position buttons
	snapping:Point('BOTTOMLEFT', 14, 10)
	lock:Point('BOTTOMRIGHT', -14, 14)
	align:Point('TOPRIGHT', lock, 'TOPLEFT', -4, -2)

	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	S:HandleEditBox(align)

	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:SetScript('OnEvent', function(mover)
		if mover:IsShown() then
			mover:Hide()
			E:Grid_Hide()
			E:ToggleMoveMode()
		end
	end)

	local dropDown = CreateFrame('Frame', f:GetName()..'DropDown', f, 'UIDropDownMenuTemplate')
	dropDown:Point('BOTTOMRIGHT', lock, 'TOPRIGHT', 8, -5)
	S:HandleDropDownBox(dropDown, 165)
	dropDown.text = dropDown:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	dropDown.text:Point('RIGHT', dropDown.backdrop, 'LEFT', -2, 0)
	dropDown.text:SetText(L["Config Mode:"])
	f.dropDown = dropDown

	_G.UIDropDownMenu_Initialize(dropDown, ConfigMode_Initialize)

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

	ElvUIMoverPopupWindow:HookScript('OnHide', function() ElvUIMoverNudgeWindow:Hide() end)

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
	header:SetFrameLevel(header:GetFrameLevel() + 2)
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
	xOffset:SetScript('OnEditFocusGained', xOffset.HighlightText)
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
	yOffset:SetScript('OnEditFocusGained', yOffset.HighlightText)
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
	resetButton:SetText(RESET)
	resetButton:Point('TOP', nudgeFrame, 'CENTER', 0, 2)
	resetButton:Size(100, 25)
	resetButton:SetScript('OnClick', function()
		if ElvUIMoverNudgeWindow.child and ElvUIMoverNudgeWindow.child.textString then
			E:ResetMovers(ElvUIMoverNudgeWindow.child.textString)
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

function E:Config_UpdateSize(reset)
	local frame = E:Config_GetWindow()
	if not frame then return end

	local maxWidth, maxHeight = self.UIParent:GetSize()
	frame:SetMinResize(800, 600)
	frame:SetMaxResize(maxWidth-50, maxHeight-50)

	self.Libs.AceConfigDialog:SetDefaultSize(E.name, E:Config_GetDefaultSize())

	local status = frame.obj and frame.obj.status
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
	if frame and frame.obj and frame.obj.status then
		E.configSavedPositionTop, E.configSavedPositionLeft = E:Round(frame:GetTop(), 2), E:Round(frame:GetLeft(), 2)
		E.global.general.AceGUI.width, E.global.general.AceGUI.height = E:Round(frame:GetWidth(), 2), E:Round(frame:GetHeight(), 2)
		E:Config_UpdateLeftScroller(frame)
	end
end

local function Config_ButtonOnEnter(self)
	if ConfigTooltip:IsForbidden() or not self.desc then return end

	ConfigTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT', 0, 2)
	ConfigTooltip:AddLine(self.desc, 1, 1, 1, true)
	ConfigTooltip:Show()
end

local function Config_ButtonOnLeave()
	if ConfigTooltip:IsForbidden() then return end

	ConfigTooltip:Hide()
end

local function Config_StripNameColor(name)
	if type(name) == 'function' then name = name() end
	return E:StripString(name)
end

local function Config_SortButtons(a,b)
	local A1, B1 = a[1], b[1]
	if A1 and B1 then
		if A1 == B1 then
			local A3, B3 = a[3], b[3]
			if A3 and B3 and (A3.name and B3.name) then
				return Config_StripNameColor(A3.name) < Config_StripNameColor(B3.name)
			end
		end
		return A1 < B1
	end
end

local function ConfigSliderOnMouseWheel(self, offset)
	local _, maxValue = self:GetMinMaxValues()
	if maxValue == 0 then return end

	local newValue = self:GetValue() - offset
	if newValue < 0 then newValue = 0 end
	if newValue > maxValue then return end

	self:SetValue(newValue)
	self.buttons:Point('TOPLEFT', 0, newValue * 36)
end

local function ConfigSliderOnValueChanged(self, value)
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
	if disabled then
		btn:Disable()
		btn.Text:SetTextColor(1, 1, 1)
		E:Config_SetButtonText(btn, true)

		if btn.SetBackdropColor then
			btn:SetBackdropColor(1, .82, 0, 0.4)
			btn:SetBackdropBorderColor(1, .82, 0, 1)
		end
	else
		btn:Enable()
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
		ConfigSliderOnValueChanged(left.slider, btn.sliderValue or 0)
	end
end

function E:Config_CreateButton(info, frame, unskinned, ...)
	local btn = CreateFrame(...)
	btn.frame = frame
	btn.desc = info.desc
	btn.info = info

	if not unskinned then
		E.Skins:HandleButton(btn)
	end

	E:Config_SetButtonText(btn)
	E:Config_SetButtonColor(btn, btn.info.key == 'general')
	btn:HookScript('OnEnter', Config_ButtonOnEnter)
	btn:HookScript('OnLeave', Config_ButtonOnLeave)
	btn:SetScript('OnClick', info.func)
	btn:Width(btn:GetTextWidth() + 40)

	return btn
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

	local status = frame.obj.status
	local selected = status and status.groups.selected
	for _, btn in ipairs(frame.leftHolder.buttons) do
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
	for _, btn in ipairs(btns) do
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
		slider.thumb:Hide()
	else
		slider.thumb:Show()
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
		info.func = function()
			local ACD = E.Libs.AceConfigDialog
			if ACD then ACD:SelectGroup('ElvUI', key) end
		end

		local btn = E:Config_CreateButton(info, frame, unskinned, 'Button', nil, buttons, 'UIPanelButtonTemplate')
		btn:Width(177)

		if not last then
			btn:Point('TOP', buttons, 'TOP', 0, 0)
		else
			btn:Point('TOP', last, 'BOTTOM', 0, (last.separator and -6) or -4)
		end

		buttons[index] = btn
		last = btn
	end
end

function E:Config_CloseClicked()
	if self.originalClose then
		self.originalClose:Click()
	end
end

function E:Config_CloseWindow()
	local ACD = E.Libs.AceConfigDialog
	if ACD then
		ACD:Close('ElvUI')
	end

	if not ConfigTooltip:IsForbidden() then
		ConfigTooltip:Hide()
	end
end

function E:Config_OpenWindow()
	local ACD = E.Libs.AceConfigDialog
	if ACD then ACD:Open('ElvUI') end

	if not ConfigTooltip:IsForbidden() then
		ConfigTooltip:Hide()
	end
end

function E:Config_GetWindow()
	local ACD = E.Libs.AceConfigDialog
	local ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[E.name]
	return ConfigOpen and ConfigOpen.frame
end

local ConfigLogoTop
E.valueColorUpdateFuncs[function(_, r, g, b)
	if ConfigLogoTop then
		ConfigLogoTop:SetVertexColor(r, g, b)
	end

	if ElvUIMoverNudgeWindow and ElvUIMoverNudgeWindow.shadow then
		ElvUIMoverNudgeWindow.shadow:SetBackdropBorderColor(r, g, b, 0.9)
	end
end] = true

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

		if E.ShowPopup then
			E:StaticPopup_Show('CONFIG_RL')
			E.ShowPopup = nil
		end
	end
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
		local offset = unskinned and 14 or 8
		local version = frame.topHolder.version
		E:Config_SaveOldPosition(version)
		version:ClearAllPoints()
		version:Point('LEFT', frame.topHolder, 'LEFT', unskinned and 8 or 6, unskinned and -4 or 0)

		local holderHeight = frame.bottomHolder:GetHeight()
		local content = frame.obj.content
		E:Config_SaveOldPosition(content)
		content:ClearAllPoints()
		content:Point('TOPLEFT', frame, 'TOPLEFT', offset, -(unskinned and 50 or 40))
		content:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -offset, holderHeight + 3)

		local titlebg = frame.obj.titlebg
		E:Config_SaveOldPosition(titlebg)
		titlebg:ClearAllPoints()
		titlebg:SetPoint('TOPLEFT', frame)
		titlebg:SetPoint('TOPRIGHT', frame)
	end
end

function E:Config_CreateBottomButtons(frame, unskinned)
	local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')

	local last
	for _, info in ipairs({
		{
			var = 'ToggleAnchors',
			name = L["Toggle Anchors"],
			desc = L["Unlock various elements of the UI to be repositioned."],
			func = function()
				E:ToggleMoveMode()
				E.ConfigurationToggled = true
			end
		},
		{
			var = 'ResetAnchors',
			name = L["Reset Anchors"],
			desc = L["Reset all frames to their original positions."],
			func = function() E:ResetUI() end
		},
		{
			var = 'RepositionWindow',
			name = L["Reposition Window"],
			desc = L["Reset the size and position of this frame."],
			func = function() E:Config_UpdateSize(true) end
		},
		{
			var = 'Install',
			name = L["Install"],
			desc = L["Run the installation process."],
			func = function()
				E:Install()
				E:ToggleOptionsUI()
			end
		},
		{
			var = 'ToggleTutorials',
			name = L["Toggle Tutorials"],
			func = function()
				E:Tutorials(true)
				E:ToggleOptionsUI()
			end
		},
		{
			var = 'ShowStatusReport',
			name = L["ElvUI Status"],
			desc = L["Shows a frame with needed info for support."],
			func = function()
				E:ShowStatusReport()
				E:ToggleOptionsUI()
				E.StatusReportToggled = true
			end
		}
	}) do
		local btn = E:Config_CreateButton(info, frame, unskinned, 'Button', nil, frame.bottomHolder, 'UIPanelButtonTemplate')
		local offset = unskinned and 14 or 8

		if not last then
			btn:Point('BOTTOMLEFT', frame.bottomHolder, 'BOTTOMLEFT', unskinned and 24 or offset, offset)
			last = btn
		else
			btn:Point('LEFT', last, 'RIGHT', 4, 0)
			last = btn
		end

		frame.bottomHolder[info.var] = btn
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
			local ACD = E.Libs.AceConfigDialog
			local pageCount, index, mainSel = #pages
			if pageCount > 1 then
				wipe(pageNodes)
				index = 0

				local main, mainNode, mainSelStr, sub, subNode, subSel
				for i = 1, pageCount do
					if i == 1 then
						main = pages[i] and ACD and ACD.Status and ACD.Status.ElvUI
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
				local main = pages[1] and ACD and ACD.Status and ACD.Status.ElvUI
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

function E:ToggleOptionsUI(msg)
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self.ShowOptionsUI = true
		return
	end

	if not IsAddOnLoaded('ElvUI_OptionsUI') then
		local noConfig
		local _, _, _, _, reason = GetAddOnInfo('ElvUI_OptionsUI')

		if reason ~= 'MISSING' then
			EnableAddOn('ElvUI_OptionsUI')
			LoadAddOn('ElvUI_OptionsUI')

			-- version check elvui options if it's actually enabled
			if GetAddOnMetadata('ElvUI_OptionsUI', 'Version') ~= '1.08' then
				self:StaticPopup_Show('CLIENT_UPDATE_REQUEST')
			end
		else
			noConfig = true
		end

		if noConfig then
			self:Print('|cffff0000Error -- Addon "ElvUI_OptionsUI" not found.|r')
			return
		end
	end

	local frame = E:Config_GetWindow()
	local mode, pages = E:Config_GetToggleMode(frame, msg)

	local ACD = E.Libs.AceConfigDialog
	if ACD then
		if not ACD.OpenHookedElvUI then
			hooksecurefunc(E.Libs.AceConfigDialog, 'Open', E.Config_DialogOpened)
			ACD.OpenHookedElvUI = true
		end

		ACD[mode](ACD, E.name)
	end

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

		if not frame.bottomHolder then -- window was released or never opened
			frame:HookScript('OnHide', E.Config_WindowClosed)

			for i=1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child:IsObjectType('Button') and child:GetText() == _G.CLOSE then
					frame.originalClose = child
					child:Hide()
				elseif child:IsObjectType('Frame') or child:IsObjectType('Button') then
					if child:HasScript('OnMouseUp') then
						child:HookScript('OnMouseUp', E.Config_StopMoving)
					end
				end
			end

			local unskinned = not E.private.skins.ace3Enable
			if unskinned then
				for i = 1, frame:GetNumRegions() do
					local region = select(i, frame:GetRegions())
					if region:IsObjectType('Texture') and region:GetTexture() == 131080 then
						region:SetAlpha(0)
					end
				end
			end

			local bottom = CreateFrame('Frame', nil, frame)
			bottom:Point('BOTTOMLEFT', 2, 2)
			bottom:Point('BOTTOMRIGHT', -2, 2)
			bottom:Height(37)
			frame.bottomHolder = bottom

			local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
			close:SetScript('OnClick', E.Config_CloseClicked)
			close:SetFrameLevel(1000)
			close:Point('TOPRIGHT', unskinned and -8 or 1, unskinned and -8 or 2)
			close:Size(32, 32)
			close.originalClose = frame.originalClose
			frame.closeButton = close

			local left = CreateFrame('Frame', nil, frame)
			left:Point('BOTTOMRIGHT', bottom, 'BOTTOMLEFT', 181, 0)
			left:Point('BOTTOMLEFT', bottom, 'TOPLEFT', 0, 1)
			left:Point('TOPLEFT', unskinned and 10 or 2, unskinned and -6 or -2)
			frame.leftHolder = left

			local top = CreateFrame('Frame', nil, frame)
			top.version = frame.obj.titletext
			top:Point('TOPRIGHT', frame, -2, 0)
			top:Point('TOPLEFT', left, 'TOPRIGHT', 1, 0)
			top:Height(24)
			frame.topHolder = top

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
			buttonsHolder:Point('BOTTOMLEFT', bottom, 'TOPLEFT', 0, 1)
			buttonsHolder:Point('TOPLEFT', left, 'TOPLEFT', 0, -70)
			buttonsHolder:Point('BOTTOMRIGHT')
			buttonsHolder:SetClipsChildren(true)
			left.buttonsHolder = buttonsHolder

			local buttons = CreateFrame('Frame', nil, buttonsHolder)
			buttons:Point('BOTTOMLEFT', bottom, 'TOPLEFT', 0, 1)
			buttons:Point('BOTTOMRIGHT')
			buttons:Point('TOPLEFT', 0, 0)
			left.buttons = buttons

			local slider = CreateFrame('Slider', nil, frame)
			slider:SetThumbTexture(E.Media.Textures.White8x8)
			slider:SetScript('OnMouseWheel', ConfigSliderOnMouseWheel)
			slider:SetScript('OnValueChanged', ConfigSliderOnValueChanged)
			slider:SetOrientation('VERTICAL')
			slider:SetObeyStepOnDrag(true)
			slider:SetValueStep(1)
			slider:SetValue(0)
			slider:Width(192)
			slider:Point('BOTTOMLEFT', bottom, 'TOPLEFT', 0, 1)
			slider:Point('TOPLEFT', buttons, 'TOPLEFT', 0, 0)
			slider.buttons = buttons
			left.slider = slider

			local thumb = slider:GetThumbTexture()
			thumb:Point('LEFT', left, 'RIGHT', 2, 0)
			thumb:SetVertexColor(1, 1, 1, 0.5)
			thumb:Size(8, 12)
			left.slider.thumb = thumb

			if not unskinned then
				bottom:SetTemplate('Transparent')
				left:SetTemplate('Transparent')
				top:SetTemplate('Transparent')
				E.Skins:HandleCloseButton(close)
			end

			E:Config_CreateLeftButtons(frame, unskinned, E.Options.args)
			E:Config_CreateBottomButtons(frame, unskinned)
			E:Config_UpdateLeftScroller(frame)
			E:Config_WindowOpened(frame)
		end

		if ACD and pages then
			ACD:SelectGroup(E.name, unpack(pages))
		end
	end
end
