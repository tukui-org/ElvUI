local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pi = math.pi
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local DROPDOWN_WIDTH_OFFSET = 8

function S:DamageMeter_ButtonOnEnter()
	local r, g, b = unpack(E.media.rgbvaluecolor)
	self:GetNormalTexture():SetVertexColor(r, g, b)
end

function S:DamageMeter_ButtonOnLeave()
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
end

function S:DamageMeter_HandleResizeButton(button)
	if button.IsSkinned then return end

	button:SetNormalTexture(E.Media.Textures.ArrowUp)
	button:SetPushedTexture(E.Media.Textures.ArrowUp)
	button:GetHighlightTexture():SetTexture('')

	local normalTex = button:GetNormalTexture()
	normalTex:SetVertexColor(1, 1, 1)
	normalTex:SetTexCoord(0, 1, 0, 1)
	normalTex:SetAllPoints()

	local r, g, b = unpack(E.media.rgbvaluecolor)
	local pushedTex = button:GetPushedTexture()
	pushedTex:SetVertexColor(r, g, b)
	pushedTex:SetTexCoord(0, 1, 0, 1)
	pushedTex:SetAllPoints()

	button:HookScript('OnEnter', S.DamageMeter_ButtonOnEnter)
	button:HookScript('OnLeave', S.DamageMeter_ButtonOnLeave)

	button.IsSkinned = true
end

function S:DamageMeter_BackdropSetAlpha(alpha)
	if self.backdrop then
		self.backdrop:SetAlpha(alpha)
	end
end

function S:DamageMeter_HandleBackground(background, x1, y1, x2, y2)
	if background.backdrop then return end

	background:SetTexture()
	background:CreateBackdrop('Transparent')
	background.backdrop:NudgePoint(x1, y1, nil, 'TOPLEFT')
	background.backdrop:NudgePoint(x2, y2, nil, 'BOTTOMRIGHT')
	background.backdrop:SetAlpha(background:GetAlpha())

	-- Inherit background alpha changes from Blizzard Edit Mode
	hooksecurefunc(background, 'SetAlpha', S.DamageMeter_BackdropSetAlpha)
end

function S:DamageMeter_DropdownSetWidth(width, overrideFlag)
	if overrideFlag then return end

	self:SetWidth(width + DROPDOWN_WIDTH_OFFSET, true)
end

function S:DamageMeter_HandleTypeDropdown(window, dropdown)
	if dropdown.IsSkinned then return end

	dropdown:Size(20)
	dropdown:StripTextures(nil, true)
	dropdown:ClearAllPoints() -- point is a secret
	dropdown:Point('TOPLEFT', window.SessionTimer, 'TOPRIGHT', 0, 4)
	dropdown.Arrow:SetAlpha(0)

	local customArrow = dropdown:CreateTexture(nil, 'BACKGROUND')
	customArrow:Point('CENTER')
	customArrow:Size(14)
	customArrow:SetTexture(E.Media.Textures.ArrowUp)
	customArrow:SetRotation(S.ArrowRotation.down)
	dropdown.customArrow = customArrow

	local typeName = dropdown.TypeName
	typeName:ClearAllPoints() -- point is a secret
	typeName:Point('LEFT', dropdown, 'RIGHT', 3, 0)
	typeName:Point('RIGHT', window.SessionDropdown, 'LEFT', -3, 0)

	dropdown.IsSkinned = true
end

function S:DamageMeter_HandleSessionDropdown(dropdown)
	if dropdown.IsSkinned then return end

	local newWidth = dropdown:GetWidth() + DROPDOWN_WIDTH_OFFSET
	dropdown:StripTextures(nil, true)
	dropdown:Width(newWidth, true)
	dropdown:NudgePoint(8, -2)
	dropdown:Height(20)
	dropdown.Arrow:SetAlpha(0)

	-- Blizzard's dynamic width is actually bugged now, but add some horizontal padding for styling anyway
	hooksecurefunc(dropdown, 'SetWidth', S.DamageMeter_DropdownSetWidth)

	S:HandleCloseButton(dropdown.ResetButton)

	dropdown.IsSkinned = true
end

function S:DamageMeter_HandleSettingsDropdown(dropdown)
	if dropdown.IsSkinned then return end

	dropdown:Size(20)
	dropdown:NudgePoint(2, 1)
	dropdown.Icon:SetAlpha(0)

	local customIcon = dropdown:CreateTexture(nil, 'BACKGROUND')
	customIcon:SetAtlas('GM-icon-settings')
	customIcon:Point('CENTER')
	customIcon:Size(26)
	dropdown.customIcon = customIcon

	dropdown.IsSkinned = true
end

function S:DamageMeter_HandleHeader(window, header)
	local r, g, b, a = unpack(E.media.backdropfadecolor)
	header:SetTexture(E.media.blankTex)
	header:SetVertexColor(r, g, b, a)
	header:ClearAllPoints()
	header:Point('TOPLEFT', window, 6, -2)
	header:Point('BOTTOMRIGHT', window, 'TOPRIGHT', -12, -32)
end

function S:DamageMeter_HandleStatusBar()
	local Icon = self.Icon
	Icon:Size(18)
	Icon:ClearAllPoints()
	Icon:Point('LEFT', 1, 0)

	local StatusBar = self.StatusBar
	local r, g, b, a = unpack(E.media.backdropfadecolor)
	local bg = StatusBar.Background
	bg:SetTexture(E.media.blankTex)
	bg:SetVertexColor(r, g, b, a)
	bg:ClearAllPoints()
	bg:Point('TOPLEFT', -19, 1)
	bg:Point('BOTTOMRIGHT', 1, -1)

	StatusBar.BackgroundEdge:Hide()
	StatusBar:GetStatusBarTexture():SetTexture(E.media.normTex)
end

function S:DamageMeter_ScrollBoxUpdate()
	self:ForEachFrame(S.DamageMeter_HandleStatusBar)
end

do
	local updating = false
	function S:DamageMeter_ScrollBoxSetPoint(point)
		if updating then return end

		updating = true

		if point == 'TOPLEFT' then
			self:NudgePoint(-5, 0, nil, point)
		elseif point == 'BOTTOMRIGHT' then
			self:NudgePoint(-8, 0, nil, point)
		end

		updating = false
	end
end

function S:DamageMeter_ScrollBarArrowButtonOnDisable()
	self.customArrow:SetVertexColor(0.5, 0.5, 0.5)
end

function S:DamageMeter_ScrollBarArrowButtonOnEnable()
	self.customArrow:SetVertexColor(1, 1, 1)
end

function S:DamageMeter_ReskinScrollBarArrow(btn, arrowDir)
	if btn.IsSkinned then return end

	btn.customArrow = btn:CreateTexture(nil, 'ARTWORK')
	btn.customArrow:SetTexture(E.Media.Textures.ArrowUp)
	btn.customArrow:SetRotation(S.ArrowRotation[arrowDir])
	btn.customArrow:Point('CENTER')
	btn.customArrow:Size(15)

	btn:HookScript('OnDisable', S.DamageMeter_ScrollBarArrowButtonOnDisable)
	btn:HookScript('OnEnable', S.DamageMeter_ScrollBarArrowButtonOnEnable)

	btn.IsSkinned = true
end

function S:DamageMeter_HandleScrollBoxes(window)
	-- To avoid tainting the scroll bar, we apply minimal styling and leave the rest to HandleTrimScrollBar
	local ScrollBar = window:GetScrollBar()
	S:DamageMeter_ReskinScrollBarArrow(ScrollBar.Back, 'up')
	S:DamageMeter_ReskinScrollBarArrow(ScrollBar.Forward, 'down')
	S:HandleTrimScrollBar(ScrollBar)

	local ScrollBox = window:GetScrollBox()
	if not ScrollBox.IsSkinned then
		hooksecurefunc(ScrollBox, 'Update', S.DamageMeter_ScrollBoxUpdate)
		hooksecurefunc(ScrollBox, 'SetPoint', S.DamageMeter_ScrollBoxSetPoint)

		S.DamageMeter_ScrollBoxUpdate(ScrollBox)
		S.DamageMeter_ScrollBoxSetPoint(ScrollBox, 'TOPLEFT')
		S.DamageMeter_ScrollBoxSetPoint(ScrollBox, 'BOTTOMRIGHT')

		ScrollBox.IsSkinned = true
	end
end

function S:DamageMeter_RepositionResizeButton(container, x, y)
	local ResizeButton = container.ResizeButton
	S:DamageMeter_HandleResizeButton(ResizeButton)

	local rotation = pi * 1.25
	ResizeButton:GetNormalTexture():SetRotation(rotation)
	ResizeButton:GetPushedTexture():SetRotation(rotation)

	ResizeButton:ClearAllPoints()
	ResizeButton:Point('BOTTOMRIGHT', container.Background, x, y)
	ResizeButton:Size(14)
end

function S:DamageMeter_AnchorToSessionWindow() -- we could also handle source position here
	S:DamageMeter_RepositionResizeButton(self, -24, 11)
end

function S:DamageMeter_HandleMinimizeContainer(container)
	if container.IsSkinned then return end

	S:DamageMeter_HandleBackground(container.Background, 4, nil, -10)
	S:DamageMeter_RepositionResizeButton(container, -6, -4)

	local sourceWindow = container.SourceWindow
	S:DamageMeter_HandleBackground(sourceWindow.Background, 16, -13, -28, 15)
	S:DamageMeter_HandleScrollBoxes(sourceWindow)
	hooksecurefunc(sourceWindow, 'AnchorToSessionWindow', S.DamageMeter_AnchorToSessionWindow)

	container.IsSkinned = true
end

function S:DamageMeter_HandleLocalPlayerEntry()
	local entry = self.MinimizeContainer.LocalPlayerEntry
	S.DamageMeter_HandleStatusBar(entry)
	entry.StatusBar.Background:SetAlpha(1) -- Local player entry is floating above the other entries
end

function S:DamageMeter_HandleMinimizeButton(window, button)
	if button.IsSkinned then return end

	button:Size(16)
	button:SetHighlightAtlas('UI-QuestTrackerButton-Yellow-Highlight', 'ADD')

	S.DamageMeter_SetMinimized(window, window.isMinimized)
	hooksecurefunc(window, 'SetMinimized', S.DamageMeter_SetMinimized)

	button.IsSkinned = true
end

function S:DamageMeter_SetMinimized(collapsed)
	local normalTexture = self.MinimizeButton:GetNormalTexture()
	local pushedTexture = self.MinimizeButton:GetPushedTexture()

	if collapsed then
		normalTexture:SetAtlas('UI-QuestTrackerButton-Secondary-Expand', true)
		pushedTexture:SetAtlas('UI-QuestTrackerButton-Secondary-Expand-Pressed', true)
	else
		normalTexture:SetAtlas('UI-QuestTrackerButton-Secondary-Collapse', true)
		pushedTexture:SetAtlas('UI-QuestTrackerButton-Secondary-Collapse-Pressed', true)
	end
end

function S:DamageMeter_HandleSessionWindow()
	if self.IsSkinned then return end

	S:DamageMeter_HandleHeader(self, self.Header)
	S:DamageMeter_HandleMinimizeButton(self, self.MinimizeButton)
	S:DamageMeter_HandleMinimizeContainer(self.MinimizeContainer)
	S:DamageMeter_HandleTypeDropdown(self, self.DamageMeterTypeDropdown)
	S:DamageMeter_HandleSessionDropdown(self.SessionDropdown)
	S:DamageMeter_HandleSettingsDropdown(self.SettingsDropdown)
	S:DamageMeter_HandleScrollBoxes(self)

	self.SessionTimer:ClearAllPoints() -- point is a secret
	self.SessionTimer:Point('TOPLEFT', self.Header, 3, -9)

	hooksecurefunc(self, 'ShowLocalPlayerEntry', S.DamageMeter_HandleLocalPlayerEntry)

	self.IsSkinned = true
end

function S:DamageMeter_SetupSessionWindow()
	_G.DamageMeter:ForEachSessionWindow(S.DamageMeter_HandleSessionWindow)
end

function S:Blizzard_DamageMeter()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.damageMeter) then return end

	hooksecurefunc(_G.DamageMeter, 'SetupSessionWindow', S.DamageMeter_SetupSessionWindow)
	S.DamageMeter_SetupSessionWindow()
end

S:AddCallbackForAddon('Blizzard_DamageMeter')
