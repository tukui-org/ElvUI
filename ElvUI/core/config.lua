local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

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

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: LibStub, UIParent, GameTooltip, EditBox_ClearFocus
-- GLOBALS: ElvUIMoverPopupWindow, ElvUIMoverNudgeWindow, ElvUIMoverPopupWindowDropDown
-- GLOBALS: UIDropDownMenu_SetSelectedValue, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton
-- GLOBALS: UIDropDownMenu_Initialize, SquareButton_SetIcon

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
			GameTooltip:Hide()
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
			tx:SetTexture(1, 0, 0)
		else
			tx:SetTexture(0, 0, 0)
		end
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0)
		tx:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0)
	end
	height = GetScreenHeight()

	do
		local tx = grid:CreateTexture(nil, 'BACKGROUND')
		tx:SetTexture(1, 0, 0)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2 + size/2))
	end

	for i = 1, floor((height/2)/hStep) do
		local tx = grid:CreateTexture(nil, 'BACKGROUND')
		tx:SetTexture(0, 0, 0)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))

		tx = grid:CreateTexture(nil, 'BACKGROUND')
		tx:SetTexture(0, 0, 0)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))
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

function E:NudgeFrame()
	local mover = ElvUIMoverNudgeWindow.child

	local screenWidth, screenHeight, screenCenter = E.UIParent:GetRight(), E.UIParent:GetTop(), E.UIParent:GetCenter()
	local x, y = mover:GetCenter()
	local point
	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2

	if y >= TOP then
		point = "TOP"
	else
		point = "BOTTOM"
	end

	if x >= RIGHT then
		point = point..'RIGHT'
	elseif x <= LEFT then
		point = point..'LEFT'
	end

	x = tonumber(ElvUIMoverNudgeWindow.xOffset.currentValue)
	y = tonumber(ElvUIMoverNudgeWindow.yOffset.currentValue)

	mover:ClearAllPoints()
	mover:Point(mover.positionOverride or point, E.UIParent, mover.positionOverride and "BOTTOMLEFT" or point, x, y)
	E:SaveMoverPosition(mover.name)
end

function E:UpdateNudgeFrame(mover)
	local screenWidth, screenHeight, screenCenter = E.UIParent:GetRight(), E.UIParent:GetTop(), E.UIParent:GetCenter()
	local x, y = mover:GetCenter()

	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2

	if y >= TOP then
		y = -(screenHeight - mover:GetTop())
	else
		y = mover:GetBottom()
	end

	if x >= RIGHT then
		x = mover:GetRight() - screenWidth
	elseif x <= LEFT then
		x = mover:GetLeft()
	else
		x = x - screenCenter
	end

	if(mover.positionOverride == "TOPLEFT") then
		x = mover:GetLeft()
		y = mover:GetTop()
	elseif(self.positionOverride == "TOPRIGHT") then
		x = mover:GetRight()
		y = mover:GetTop()
	elseif(mover.positionOverride == "BOTTOMLEFT") then
		x = mover:GetLeft()
		y = mover:GetBottom()
	elseif(mover.positionOverride == "BOTTOMRIGHT") then
		x = mover:GetRight()
		y = mover:GetBottom()
	end

	x = E:Round(x, 0)
	y = E:Round(y, 0)

	ElvUIMoverNudgeWindow.xOffset:SetText(x)
	ElvUIMoverNudgeWindow.yOffset:SetText(y)
	ElvUIMoverNudgeWindow.xOffset.currentValue = x
	ElvUIMoverNudgeWindow.yOffset.currentValue = y
	ElvUIMoverNudgeWindow.title:SetText(mover.textSting)
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
	f:SetWidth(360)
	f:SetHeight(130)
	f:SetTemplate('Transparent')
	f:SetPoint("BOTTOM", UIParent, 'CENTER', 0, 100)
	f:SetScript('OnHide', function()
		if ElvUIMoverPopupWindowDropDown then
			UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, 'ALL');
		end
	end)
	f:Hide()

	local S = E:GetModule('Skins')

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate('Default', true)
	header:SetWidth(100); header:SetHeight(25)
	header:SetPoint("CENTER", f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks('AnyUp', 'AnyDown')
	header:SetScript('OnMouseDown', function() f:StartMoving() end)
	header:SetScript('OnMouseUp', function() f:StopMovingOrSizing() end)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText('ElvUI')

	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["Movers unlocked. Move them now and click Lock when you are done."])

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

	lock:SetScript("OnClick", function(self)
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
	align.text:SetPoint('RIGHT', align, 'LEFT', -4, 0)
	align.text:SetText(L["Grid Size:"])

	--position buttons
	snapping:SetPoint("BOTTOMLEFT", 14, 10)
	lock:SetPoint("BOTTOMRIGHT", -14, 14)
	align:SetPoint('TOPRIGHT', lock, 'TOPLEFT', -4, -2)

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
	configMode.text:SetPoint('RIGHT', configMode.backdrop, 'LEFT', -2, 0)
	configMode.text:SetText(L["Config Mode:"])

	UIDropDownMenu_Initialize(configMode, ConfigMode_Initialize);

	local nudgeFrame = CreateFrame('Frame', 'ElvUIMoverNudgeWindow', E.UIParent)
	nudgeFrame:SetFrameStrata("DIALOG")
	nudgeFrame:SetWidth(200)
	nudgeFrame:SetHeight(110)
	nudgeFrame:SetTemplate('Transparent')
	nudgeFrame:Point('TOP', ElvUIMoverPopupWindow, 'BOTTOM', 0, -15)
	nudgeFrame:SetFrameLevel(100)
	nudgeFrame:Hide()
	nudgeFrame:EnableMouse(true)
	nudgeFrame:SetClampedToScreen(true)
	ElvUIMoverPopupWindow:HookScript('OnHide', function() ElvUIMoverNudgeWindow:Hide() end)

	local desc = nudgeFrame:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -15)
	desc:SetPoint("BOTTOMRIGHT", -18, 28)
	desc:SetJustifyH('CENTER')
	nudgeFrame.title = desc

	local header = CreateFrame('Button', nil, nudgeFrame)
	header:SetTemplate('Default', true)
	header:SetWidth(100); header:SetHeight(25)
	header:SetPoint("CENTER", nudgeFrame, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
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
			xOffset.currentValue = num
			E:NudgeFrame()
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
	xOffset.text:SetPoint('RIGHT', xOffset, 'LEFT', -4, 0)
	xOffset.text:SetText('X:')
	xOffset:SetPoint('BOTTOMRIGHT', nudgeFrame, 'CENTER', -6, 8)
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
			yOffset.currentValue = num
			E:NudgeFrame()
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
	yOffset.text:SetPoint('RIGHT', yOffset, 'LEFT', -4, 0)
	yOffset.text:SetText('Y:')
	yOffset:SetPoint('BOTTOMLEFT', nudgeFrame, 'CENTER', 16, 8)
	nudgeFrame.yOffset = yOffset
	S:HandleEditBox(yOffset)

	local resetButton = CreateFrame("Button", nudgeFrame:GetName()..'ResetButton', nudgeFrame, "UIPanelButtonTemplate")
	resetButton:SetText(RESET)
	resetButton:SetPoint("TOP", nudgeFrame, "CENTER", 0, 2)
	resetButton:Size(100, 25)
	resetButton:SetScript("OnClick", function()
		if ElvUIMoverNudgeWindow.child.textString then
			E:ResetMovers(ElvUIMoverNudgeWindow.child.textString)
		end
	end)
	S:HandleButton(resetButton)

	local upButton = CreateFrame('Button', nudgeFrame:GetName()..'UpButton', nudgeFrame, 'UIPanelSquareButton')
	upButton:SetPoint('BOTTOMRIGHT', nudgeFrame, 'BOTTOM', -6, 4)
	upButton:SetScript('OnClick', function()
		yOffset:SetText(yOffset.currentValue + 1)
		yOffset:GetScript('OnEnterPressed')(yOffset)
	end)
	SquareButton_SetIcon(upButton, "UP");
	S:HandleButton(upButton)

	local downButton = CreateFrame('Button', nudgeFrame:GetName()..'DownButton', nudgeFrame, 'UIPanelSquareButton')
	downButton:SetPoint('BOTTOMLEFT', nudgeFrame, 'BOTTOM', 6, 4)
	downButton:SetScript('OnClick', function()
		yOffset:SetText(yOffset.currentValue - 1)
		yOffset:GetScript('OnEnterPressed')(yOffset)
	end)
	SquareButton_SetIcon(downButton, "DOWN");
	S:HandleButton(downButton)

	local leftButton = CreateFrame('Button', nudgeFrame:GetName()..'LeftButton', nudgeFrame, 'UIPanelSquareButton')
	leftButton:SetPoint('RIGHT', upButton, 'LEFT', -6, 0)
	leftButton:SetScript('OnClick', function()
		xOffset:SetText(xOffset.currentValue - 1)
		xOffset:GetScript('OnEnterPressed')(xOffset)
	end)
	SquareButton_SetIcon(leftButton, "LEFT");
	S:HandleButton(leftButton)

	local rightButton = CreateFrame('Button', nudgeFrame:GetName()..'RightButton', nudgeFrame, 'UIPanelSquareButton')
	rightButton:SetPoint('LEFT', downButton, 'RIGHT', 6, 0)
	rightButton:SetScript('OnClick', function()
		xOffset:SetText(xOffset.currentValue + 1)
		xOffset:GetScript('OnEnterPressed')(xOffset)
	end)
	SquareButton_SetIcon(rightButton, "RIGHT");
	S:HandleButton(rightButton)
end