local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack = unpack
local type, ipairs, tonumber = type, ipairs, tonumber
local floor, select = floor, select
--WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown
local EditBox_ClearFocus = EditBox_ClearFocus
local RESET = RESET
-- GLOBALS: ElvUIMoverPopupWindow, ElvUIMoverNudgeWindow, ElvUIMoverPopupWindowDropDown

local selectedValue, grid = 'ALL'

E.ConfigModeLayouts = {
	'ALL',
	'GENERAL',
	'SOLO',
	'PARTY',
	'ARENA',
	'RAID',
	'ACTIONBARS'
}

E.ConfigModeLocalizedStrings = {
	ALL = _G.ALL,
	GENERAL = _G.GENERAL,
	SOLO = _G.SOLO,
	PARTY = _G.PARTY,
	ARENA = _G.ARENA,
	RAID = _G.RAID,
	ACTIONBARS = _G.ACTIONBARS_LABEL
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

function E:ToggleMoveMode(override, configType)
	if InCombatLockdown() then return; end
	if override ~= nil and override ~= '' then E.ConfigurationMode = override end

	if E.ConfigurationMode ~= true then
		E:Grid_Show()

		if not ElvUIMoverPopupWindow then
			E:CreateMoverPopup()
		end

		ElvUIMoverPopupWindow:Show()

		if IsAddOnLoaded('ElvUI_OptionsUI') then
			if E.Libs.AceConfigDialog then
				E.Libs.AceConfigDialog:Close('ElvUI')
			end

			if not _G.GameTooltip:IsForbidden() then
				_G.GameTooltip:Hide()
			end
		end

		E.ConfigurationMode = true
	else
		E:Grid_Hide()

		if ElvUIMoverPopupWindow then
			ElvUIMoverPopupWindow:Hide()
		end

		E.ConfigurationMode = false
	end

	if type(configType) ~= 'string' then
		configType = nil
	end

	self:ToggleMovers(E.ConfigurationMode, configType or 'ALL')
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

	local size = E.mult
	local width, height = E.UIParent:GetSize()

	local ratio = width / height
	local hStepheight = height * ratio
	local wStep = width / E.db.gridSize
	local hStep = hStepheight / E.db.gridSize

	grid.boxSize = E.db.gridSize
	grid:SetPoint('CENTER', E.UIParent)
	grid:SetSize(width, height)
	grid:Show()

	for i = 0, E.db.gridSize do
		local tx = E:Grid_GetRegion()
		if i == E.db.gridSize / 2 then
			tx:SetColorTexture(1, 0, 0)
			tx:SetDrawLayer('BACKGROUND', 1)
		else
			tx:SetColorTexture(0, 0, 0)
			tx:SetDrawLayer('BACKGROUND', 0)
		end
		tx:ClearAllPoints()
		tx:Point('TOPLEFT', grid, 'TOPLEFT', i*wStep - (size/2), 0)
		tx:Point('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0)
	end

	do
		local tx = E:Grid_GetRegion()
		tx:SetColorTexture(1, 0, 0)
		tx:SetDrawLayer('BACKGROUND', 1)
		tx:ClearAllPoints()
		tx:Point('TOPLEFT', grid, 'TOPLEFT', 0, -(height/2) + (size/2))
		tx:Point('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2 + size/2))
	end

	for i = 1, floor((height/2)/hStep) do
		local tx = E:Grid_GetRegion()
		tx:SetColorTexture(0, 0, 0)
		tx:SetDrawLayer('BACKGROUND', 0)
		tx:ClearAllPoints()
		tx:Point('TOPLEFT', grid, 'TOPLEFT', 0, -(height/2+i*hStep) + (size/2))
		tx:Point('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))

		tx = E:Grid_GetRegion()
		tx:SetColorTexture(0, 0, 0)
		tx:SetDrawLayer('BACKGROUND', 0)
		tx:ClearAllPoints()
		tx:Point('TOPLEFT', grid, 'TOPLEFT', 0, -(height/2-i*hStep) + (size/2))
		tx:Point('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))
	end
end

local function ConfigMode_OnClick(self)
	selectedValue = self.value
	E:ToggleMoveMode(false, self.value)
	_G.UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, self.value)
end

local function ConfigMode_Initialize()
	local info = _G.UIDropDownMenu_CreateInfo()
	info.func = ConfigMode_OnClick

	for _, configMode in ipairs(E.ConfigModeLayouts) do
		info.text = E.ConfigModeLocalizedStrings[configMode]
		info.value = configMode
		_G.UIDropDownMenu_AddButton(info)
	end

	_G.UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, selectedValue)
end

function E:NudgeMover(nudgeX, nudgeY)
	local mover = ElvUIMoverNudgeWindow.child
	local x, y, point = E:CalculateMoverPoints(mover, nudgeX, nudgeY)

	mover:ClearAllPoints()
	mover:Point(mover.positionOverride or point, E.UIParent, mover.positionOverride and 'BOTTOMLEFT' or point, x, y)
	E:SaveMoverPosition(mover.name)

	--Update coordinates in Nudge Window
	E:UpdateNudgeFrame(mover, x, y)
end

function E:UpdateNudgeFrame(mover, x, y)
	if not (x and y) then
		x, y = E:CalculateMoverPoints(mover)
	end

	x = E:Round(x, 0)
	y = E:Round(y, 0)

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
	local f = CreateFrame('Frame', 'ElvUIMoverPopupWindow', _G.UIParent)
	f:SetFrameStrata('DIALOG')
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetFrameLevel(99)
	f:SetClampedToScreen(true)
	f:Width(370)
	f:Height(190)
	f:SetTemplate('Transparent')
	f:Point('BOTTOM', _G.UIParent, 'CENTER', 0, 100)
	f:SetScript('OnHide', function()
		if ElvUIMoverPopupWindowDropDown then
			_G.UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, 'ALL')
		end
	end)
	f:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	f:CreateShadow(5)
	f:Hide()

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate(nil, true)
	header:Width(100); header:Height(25)
	header:Point('CENTER', f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks('AnyUp', 'AnyDown')
	header:SetScript('OnMouseDown', function() f:StartMoving() end)
	header:SetScript('OnMouseUp', function() f:StopMovingOrSizing() end)
	header:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))

	local title = header:CreateFontString('OVERLAY')
	title:FontTemplate()
	title:Point('CENTER', header, 'CENTER')
	title:SetText('ElvUI')

	local desc = f:CreateFontString('ARTWORK')
	desc:SetFontObject('GameFontHighlight')
	desc:SetJustifyV('TOP')
	desc:SetJustifyH('LEFT')
	desc:Point('TOPLEFT', 18, -20)
	desc:Point('BOTTOMRIGHT', -18, 48)
	desc:SetText(L["DESC_MOVERCONFIG"])

	local snapping = CreateFrame('CheckButton', f:GetName()..'CheckButton', f, 'OptionsCheckButtonTemplate')
	_G[snapping:GetName() .. 'Text']:SetText(L["Sticky Frames"])

	snapping:SetScript('OnShow', function(cb)
		cb:SetChecked(E.db.general.stickyFrames)
	end)

	snapping:SetScript('OnClick', function(cb)
		E.db.general.stickyFrames = cb:GetChecked()
	end)

	local lock = CreateFrame('Button', f:GetName()..'CloseButton', f, 'OptionsButtonTemplate')
	_G[lock:GetName() .. 'Text']:SetText(L["Lock"])

	lock:SetScript('OnClick', function()
		E:ToggleMoveMode(true)

		if IsAddOnLoaded('ElvUI_OptionsUI') and E.Libs.AceConfigDialog then
			E.Libs.AceConfigDialog:Open('ElvUI')
		end

		selectedValue = 'ALL'
		_G.UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, selectedValue)
	end)

	local align = CreateFrame('EditBox', f:GetName()..'EditBox', f, 'InputBoxTemplate')
	align:Width(24)
	align:Height(17)
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
			E:ToggleMoveMode(true)
		end
	end)

	local configMode = CreateFrame('Frame', f:GetName()..'DropDown', f, 'UIDropDownMenuTemplate')
	configMode:Point('BOTTOMRIGHT', lock, 'TOPRIGHT', 8, -5)
	S:HandleDropDownBox(configMode, 165)
	configMode.text = configMode:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	configMode.text:Point('RIGHT', configMode.backdrop, 'LEFT', -2, 0)
	configMode.text:SetText(L["Config Mode:"])

	_G.UIDropDownMenu_Initialize(configMode, ConfigMode_Initialize)

	local nudgeFrame = CreateFrame('Frame', 'ElvUIMoverNudgeWindow', E.UIParent)
	nudgeFrame:SetFrameStrata('DIALOG')
	nudgeFrame:Width(200)
	nudgeFrame:Height(110)
	nudgeFrame:SetTemplate('Transparent')
	nudgeFrame:CreateShadow(5)
	nudgeFrame:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	nudgeFrame:SetFrameLevel(500)
	nudgeFrame:Hide()
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

	desc = nudgeFrame:CreateFontString('ARTWORK')
	desc:SetFontObject('GameFontHighlight')
	desc:SetJustifyV('TOP')
	desc:SetJustifyH('LEFT')
	desc:Point('TOPLEFT', 18, -15)
	desc:Point('BOTTOMRIGHT', -18, 28)
	desc:SetJustifyH('CENTER')
	nudgeFrame.title = desc

	header = CreateFrame('Button', nil, nudgeFrame)
	header:SetTemplate(nil, true)
	header:Width(100); header:Height(25)
	header:Point('CENTER', nudgeFrame, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))

	title = header:CreateFontString('OVERLAY')
	title:FontTemplate()
	title:Point('CENTER', header, 'CENTER')
	title:SetText(L["Nudge"])

	local xOffset = CreateFrame('EditBox', nudgeFrame:GetName()..'XEditBox', nudgeFrame, 'InputBoxTemplate')
	xOffset:Width(50)
	xOffset:Height(17)
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
	nudgeFrame.xOffset = xOffset
	S:HandleEditBox(xOffset)

	local yOffset = CreateFrame('EditBox', nudgeFrame:GetName()..'YEditBox', nudgeFrame, 'InputBoxTemplate')
	yOffset:Width(50)
	yOffset:Height(17)
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
	nudgeFrame.yOffset = yOffset
	S:HandleEditBox(yOffset)

	local resetButton = CreateFrame('Button', nudgeFrame:GetName()..'ResetButton', nudgeFrame, 'UIPanelButtonTemplate')
	resetButton:SetText(RESET)
	resetButton:Point('TOP', nudgeFrame, 'CENTER', 0, 2)
	resetButton:Size(100, 25)
	resetButton:SetScript('OnClick', function()
		if ElvUIMoverNudgeWindow.child.textString then
			E:ResetMovers(ElvUIMoverNudgeWindow.child.textString)
		end
	end)
	S:HandleButton(resetButton)

	local upButton = CreateFrame('Button', nudgeFrame:GetName()..'UpButton', nudgeFrame)
	upButton:Point('BOTTOMRIGHT', nudgeFrame, 'BOTTOM', -6, 4)
	upButton:SetScript('OnClick', function()
		E:NudgeMover(nil, 1)
	end)
	S:HandleNextPrevButton(upButton)
	S:HandleButton(upButton)
	upButton:SetSize(22, 22)

	local downButton = CreateFrame('Button', nudgeFrame:GetName()..'DownButton', nudgeFrame)
	downButton:Point('BOTTOMLEFT', nudgeFrame, 'BOTTOM', 6, 4)
	downButton:SetScript('OnClick', function()
		E:NudgeMover(nil, -1)
	end)
	S:HandleNextPrevButton(downButton)
	S:HandleButton(downButton)
	downButton:SetSize(22, 22)

	local leftButton = CreateFrame('Button', nudgeFrame:GetName()..'LeftButton', nudgeFrame)
	leftButton:Point('RIGHT', upButton, 'LEFT', -6, 0)
	leftButton:SetScript('OnClick', function()
		E:NudgeMover(-1)
	end)
	S:HandleNextPrevButton(leftButton)
	S:HandleButton(leftButton)
	leftButton:SetSize(22, 22)

	local rightButton = CreateFrame('Button', nudgeFrame:GetName()..'RightButton', nudgeFrame)
	rightButton:Point('LEFT', downButton, 'RIGHT', 6, 0)
	rightButton:SetScript('OnClick', function()
		E:NudgeMover(1)
	end)
	S:HandleNextPrevButton(rightButton)
	S:HandleButton(rightButton)
	rightButton:SetSize(22, 22)
end
