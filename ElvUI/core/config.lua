local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local _G = _G
local type, ipairs, tonumber = type, ipairs, tonumber
local floor = math.floor
--WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight
local InCombatLockdown = InCombatLockdown
local RESET = RESET

local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: LibStub, UIParent, GameTooltip, EditBox_ClearFocus, SquareButton_SetIcon
-- GLOBALS: ElvUIMoverPopupWindow, ElvUIMoverNudgeWindow, ElvUIMoverPopupWindowDropDown

local grid
local selectedValue = 'ALL'

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
	ALL = ALL,
	GENERAL = GENERAL,
	SOLO = SOLO,
	PARTY = PARTY,
	ARENA = ARENA,
	RAID = RAID,
	ACTIONBARS = ACTIONBARS_LABEL
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

function E:ToggleConfigMode(override, configType)
	if InCombatLockdown() then return; end
	if override ~= nil and override ~= '' then E.ConfigurationMode = override end

	if E.ConfigurationMode ~= true then
		if not grid then
			E:Grid_Create()
		elseif grid.boxSize ~= E.db.gridSize then
			grid:Hide()
			E:Grid_Create()
		else
			grid:Show()
		end

		if not ElvUIMoverPopupWindow then
			E:CreateMoverPopup()
		end

		ElvUIMoverPopupWindow:Show()
		if IsAddOnLoaded("ElvUI_Config") then
			LibStub("AceConfigDialog-3.0-ElvUI"):Close("ElvUI")
			if not GameTooltip:IsForbidden() then
				GameTooltip:Hide()
			end
		end
		E.ConfigurationMode = true
	else
		if ElvUIMoverPopupWindow then
			ElvUIMoverPopupWindow:Hide()
		end

		if grid then
			grid:Hide()
		end

		E.ConfigurationMode = false
	end

	if type(configType) ~= 'string' then
		configType = nil
	end

	self:ToggleMovers(E.ConfigurationMode, configType or 'ALL')
end

function E:Grid_Create()
	grid = CreateFrame('Frame', 'EGrid', UIParent)
	grid.boxSize = E.db.gridSize
	grid:SetAllPoints(E.UIParent)
	grid:Show()

	local size = 1
	local width = E.eyefinity or GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / E.db.gridSize
	local hStep = height / E.db.gridSize

	for i = 0, E.db.gridSize do
		local tx = grid:CreateTexture(nil, 'BACKGROUND')
		if i == E.db.gridSize / 2 then
			tx:SetColorTexture(1, 0, 0)
		else
			tx:SetColorTexture(0, 0, 0)
		end
		tx:Point("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0)
		tx:Point('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0)
	end
	height = GetScreenHeight()

	do
		local tx = grid:CreateTexture(nil, 'BACKGROUND')
		tx:SetColorTexture(1, 0, 0)
		tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
		tx:Point('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2 + size/2))
	end

	for i = 1, floor((height/2)/hStep) do
		local tx = grid:CreateTexture(nil, 'BACKGROUND')
		tx:SetColorTexture(0, 0, 0)

		tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
		tx:Point('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))

		tx = grid:CreateTexture(nil, 'BACKGROUND')
		tx:SetColorTexture(0, 0, 0)

		tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
		tx:Point('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))
	end
end

local function ConfigMode_OnClick(self)
	selectedValue = self.value
	E:ToggleConfigMode(false, self.value)
	UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, self.value);
end

local function ConfigMode_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func = ConfigMode_OnClick;

	for _, configMode in ipairs(E.ConfigModeLayouts) do
		info.text = E.ConfigModeLocalizedStrings[configMode];
		info.value = configMode;
		UIDropDownMenu_AddButton(info);
	end

	UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, selectedValue);
end

function E:NudgeMover(nudgeX, nudgeY)
	local mover = ElvUIMoverNudgeWindow.child
	local x, y, point = E:CalculateMoverPoints(mover, nudgeX, nudgeY)

	mover:ClearAllPoints()
	mover:Point(mover.positionOverride or point, E.UIParent, mover.positionOverride and "BOTTOMLEFT" or point, x, y)
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

	ElvUIMoverNudgeWindow.xOffset:SetText(x)
	ElvUIMoverNudgeWindow.yOffset:SetText(y)
	ElvUIMoverNudgeWindow.xOffset.currentValue = x
	ElvUIMoverNudgeWindow.yOffset.currentValue = y
	ElvUIMoverNudgeWindow.title:SetText(mover.textString)
end

function E:AssignFrameToNudge()
	ElvUIMoverNudgeWindow.child = self;
	E:UpdateNudgeFrame(self)
end

function E:CreateMoverPopup()
	local f = CreateFrame("Frame", "ElvUIMoverPopupWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetFrameLevel(99)
	f:SetClampedToScreen(true)
	f:Width(360)
	f:Height(170)
	f:SetTemplate('Transparent')
	f:Point("BOTTOM", UIParent, 'CENTER', 0, 100)
	f:SetScript('OnHide', function()
		if ElvUIMoverPopupWindowDropDown then
			UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, 'ALL');
		end
	end)
	f:Hide()

	local S = E:GetModule('Skins')

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate('Default', true)
	header:Width(100); header:Height(25)
	header:Point("CENTER", f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks('AnyUp', 'AnyDown')
	header:SetScript('OnMouseDown', function() f:StartMoving() end)
	header:SetScript('OnMouseUp', function() f:StopMovingOrSizing() end)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:Point("CENTER", header, "CENTER")
	title:SetText('ElvUI')

	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:Point("TOPLEFT", 18, -20)
	desc:Point("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["DESC_MOVERCONFIG"])

	local snapping = CreateFrame("CheckButton", f:GetName()..'CheckButton', f, "OptionsCheckButtonTemplate")
	_G[snapping:GetName() .. "Text"]:SetText(L["Sticky Frames"])

	snapping:SetScript("OnShow", function(self)
		self:SetChecked(E.db.general.stickyFrames)
	end)

	snapping:SetScript("OnClick", function(self)
		E.db.general.stickyFrames = self:GetChecked()
	end)

	local lock = CreateFrame("Button", f:GetName()..'CloseButton', f, "OptionsButtonTemplate")
	_G[lock:GetName() .. "Text"]:SetText(L["Lock"])

	lock:SetScript("OnClick", function()
		E:ToggleConfigMode(true)
		if IsAddOnLoaded("ElvUI_Config") then LibStub("AceConfigDialog-3.0-ElvUI"):Open('ElvUI') end
		selectedValue = 'ALL'
		UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, selectedValue);
	end)

	local align = CreateFrame('EditBox', f:GetName()..'EditBox', f, 'InputBoxTemplate')
	align:Width(24)
	align:Height(17)
	align:SetAutoFocus(false)
	align:SetScript("OnEscapePressed", function(self)
		self:SetText(E.db.gridSize)
		EditBox_ClearFocus(self)
	end)
	align:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if tonumber(text) then
			if tonumber(text) <= 256 and tonumber(text) >= 4 then
				E.db.gridSize = tonumber(text)
			else
				self:SetText(E.db.gridSize)
			end
		else
			self:SetText(E.db.gridSize)
		end
		E:Grid_Show()
		EditBox_ClearFocus(self)
	end)
	align:SetScript("OnEditFocusLost", function(self)
		self:SetText(E.db.gridSize)
	end)
	align:SetScript("OnEditFocusGained", align.HighlightText)
	align:SetScript('OnShow', function(self)
		EditBox_ClearFocus(self)
		self:SetText(E.db.gridSize)
	end)

	align.text = align:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	align.text:Point('RIGHT', align, 'LEFT', -4, 0)
	align.text:SetText(L["Grid Size:"])

	--position buttons
	snapping:Point("BOTTOMLEFT", 14, 10)
	lock:Point("BOTTOMRIGHT", -14, 14)
	align:Point('TOPRIGHT', lock, 'TOPLEFT', -4, -2)

	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	S:HandleEditBox(align)

	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:SetScript('OnEvent', function(self)
		if self:IsShown() then
			self:Hide()
			E:Grid_Hide()
			E:ToggleConfigMode(true)
		end
	end)

	local configMode = CreateFrame('Frame', f:GetName()..'DropDown', f, 'UIDropDownMenuTemplate')
	configMode:Point('BOTTOMRIGHT', lock, 'TOPRIGHT', 8, -5)
	S:HandleDropDownBox(configMode, 148)
	configMode.text = configMode:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	configMode.text:Point('RIGHT', configMode.backdrop, 'LEFT', -2, 0)
	configMode.text:SetText(L["Config Mode:"])

	UIDropDownMenu_Initialize(configMode, ConfigMode_Initialize);

	local nudgeFrame = CreateFrame('Frame', 'ElvUIMoverNudgeWindow', E.UIParent)
	nudgeFrame:SetFrameStrata("DIALOG")
	nudgeFrame:Width(200)
	nudgeFrame:Height(110)
	nudgeFrame:SetTemplate('Transparent')
	nudgeFrame:Point('TOP', ElvUIMoverPopupWindow, 'BOTTOM', 0, -15)
	nudgeFrame:SetFrameLevel(500)
	nudgeFrame:Hide()
	nudgeFrame:EnableMouse(true)
	nudgeFrame:SetClampedToScreen(true)
	ElvUIMoverPopupWindow:HookScript('OnHide', function() ElvUIMoverNudgeWindow:Hide() end)

	desc = nudgeFrame:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:Point("TOPLEFT", 18, -15)
	desc:Point("BOTTOMRIGHT", -18, 28)
	desc:SetJustifyH('CENTER')
	nudgeFrame.title = desc

	header = CreateFrame('Button', nil, nudgeFrame)
	header:SetTemplate('Default', true)
	header:Width(100); header:Height(25)
	header:Point("CENTER", nudgeFrame, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:Point("CENTER", header, "CENTER")
	title:SetText(L["Nudge"])

	local xOffset = CreateFrame('EditBox', nudgeFrame:GetName()..'XEditBox', nudgeFrame, 'InputBoxTemplate')
	xOffset:Width(50)
	xOffset:Height(17)
	xOffset:SetAutoFocus(false)
	xOffset.currentValue = 0
	xOffset:SetScript("OnEscapePressed", function(self)
		self:SetText(E:Round(xOffset.currentValue))
		EditBox_ClearFocus(self)
	end)
	xOffset:SetScript("OnEnterPressed", function(self)
		local num = self:GetText()
		if tonumber(num) then
			local diff = num - xOffset.currentValue
			xOffset.currentValue = num
			E:NudgeMover(diff)
		end
		self:SetText(E:Round(xOffset.currentValue))
		EditBox_ClearFocus(self)
	end)
	xOffset:SetScript("OnEditFocusLost", function(self)
		self:SetText(E:Round(xOffset.currentValue))
	end)
	xOffset:SetScript("OnEditFocusGained", xOffset.HighlightText)
	xOffset:SetScript('OnShow', function(self)
		EditBox_ClearFocus(self)
		self:SetText(E:Round(xOffset.currentValue))
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
	yOffset:SetScript("OnEscapePressed", function(self)
		self:SetText(E:Round(yOffset.currentValue))
		EditBox_ClearFocus(self)
	end)
	yOffset:SetScript("OnEnterPressed", function(self)
		local num = self:GetText()
		if tonumber(num) then
			local diff = num - yOffset.currentValue
			yOffset.currentValue = num
			E:NudgeMover(nil, diff)
		end
		self:SetText(E:Round(yOffset.currentValue))
		EditBox_ClearFocus(self)
	end)
	yOffset:SetScript("OnEditFocusLost", function(self)
		self:SetText(E:Round(yOffset.currentValue))
	end)
	yOffset:SetScript("OnEditFocusGained", yOffset.HighlightText)
	yOffset:SetScript('OnShow', function(self)
		EditBox_ClearFocus(self)
		self:SetText(E:Round(yOffset.currentValue))
	end)

	yOffset.text = yOffset:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	yOffset.text:Point('RIGHT', yOffset, 'LEFT', -4, 0)
	yOffset.text:SetText('Y:')
	yOffset:Point('BOTTOMLEFT', nudgeFrame, 'CENTER', 16, 8)
	nudgeFrame.yOffset = yOffset
	S:HandleEditBox(yOffset)

	local resetButton = CreateFrame("Button", nudgeFrame:GetName()..'ResetButton', nudgeFrame, "UIPanelButtonTemplate")
	resetButton:SetText(RESET)
	resetButton:Point("TOP", nudgeFrame, "CENTER", 0, 2)
	resetButton:Size(100, 25)
	resetButton:SetScript("OnClick", function()
		if ElvUIMoverNudgeWindow.child.textString then
			E:ResetMovers(ElvUIMoverNudgeWindow.child.textString)
		end
	end)
	S:HandleButton(resetButton)

	local upButton = CreateFrame('Button', nudgeFrame:GetName()..'UpButton', nudgeFrame, 'UIPanelSquareButton')
	upButton:Point('BOTTOMRIGHT', nudgeFrame, 'BOTTOM', -6, 4)
	upButton:SetScript('OnClick', function()
		E:NudgeMover(nil, 1)
	end)
	SquareButton_SetIcon(upButton, "UP");
	S:HandleButton(upButton)

	local downButton = CreateFrame('Button', nudgeFrame:GetName()..'DownButton', nudgeFrame, 'UIPanelSquareButton')
	downButton:Point('BOTTOMLEFT', nudgeFrame, 'BOTTOM', 6, 4)
	downButton:SetScript('OnClick', function()
		E:NudgeMover(nil, -1)
	end)
	SquareButton_SetIcon(downButton, "DOWN");
	S:HandleButton(downButton)

	local leftButton = CreateFrame('Button', nudgeFrame:GetName()..'LeftButton', nudgeFrame, 'UIPanelSquareButton')
	leftButton:Point('RIGHT', upButton, 'LEFT', -6, 0)
	leftButton:SetScript('OnClick', function()
		E:NudgeMover(-1)
	end)
	SquareButton_SetIcon(leftButton, "LEFT");
	S:HandleButton(leftButton)

	local rightButton = CreateFrame('Button', nudgeFrame:GetName()..'RightButton', nudgeFrame, 'UIPanelSquareButton')
	rightButton:Point('LEFT', downButton, 'RIGHT', 6, 0)
	rightButton:SetScript('OnClick', function()
		E:NudgeMover(1)
	end)
	SquareButton_SetIcon(rightButton, "RIGHT");
	S:HandleButton(rightButton)
end
