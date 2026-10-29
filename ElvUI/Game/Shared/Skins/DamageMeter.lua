local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pi = math.pi
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local DROPDOWN_WIDTH_OFFSET = 8

local data = S:AddCallbackForAddon('Blizzard_DamageMeter', nil, nil, nil, nil, nil, 'damageMeter')

function data:ButtonOnEnter()
	local r, g, b = unpack(E.media.rgbvaluecolor)
	self:GetNormalTexture():SetVertexColor(r, g, b)
end

function data:ButtonOnLeave()
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
end

function data:HandleResizeButton(button)
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

	button:HookScript('OnEnter', data.ButtonOnEnter)
	button:HookScript('OnLeave', data.ButtonOnLeave)

	button.IsSkinned = true
end

function data:BackdropSetAlpha(alpha)
	if self.backdrop then
		self.backdrop:SetAlpha(alpha)
	end
end

function data:HandleBackground(window, background, x1, y1, x2, y2)
	if not window or background.backdrop then return end

	background:SetTexture()
	background:CreateBackdrop('Transparent')
	background.backdrop:NudgePoint(x1, y1, nil, 'TOPLEFT')
	background.backdrop:NudgePoint(x2, y2, nil, 'BOTTOMRIGHT')
	background.backdrop:SetAlpha(background:GetAlpha())

	-- Inherit background alpha changes from Blizzard Edit Mode
	hooksecurefunc(background, 'SetAlpha', data.BackdropSetAlpha)
end

function data:DropdownSetWidth(width, overrideFlag)
	if overrideFlag then return end

	self:SetWidth(width + DROPDOWN_WIDTH_OFFSET, true)
end

function data:HandleTypeDropdown(window, dropdown)
	if dropdown.IsSkinned then return end

	dropdown:Size(20)
	dropdown:StripTextures(nil, true)
	dropdown:ClearAllPoints() -- point is a secret
	dropdown:Point('TOPLEFT', window.SessionTimer, 'TOPRIGHT', 0, 4)
	dropdown.Arrow:SetAlpha(0)

	if not dropdown.customArrow then
		local customArrow = dropdown:CreateTexture(nil, 'BACKGROUND')
		customArrow:Point('CENTER')
		customArrow:Size(14)
		customArrow:SetTexture(E.Media.Textures.ArrowUp)
		customArrow:SetRotation(S.ArrowRotation.down)
		dropdown.customArrow = customArrow
	end

	local typeName = dropdown.TypeName
	typeName:ClearAllPoints() -- point is a secret
	typeName:Point('LEFT', dropdown, 'RIGHT', 3, 0)
	typeName:Point('RIGHT', window.SessionDropdown, 'LEFT', -3, 0)

	dropdown.IsSkinned = true
end

function data:HandleSessionDropdown(window, dropdown)
	if not window or dropdown.IsSkinned then return end

	local newWidth = dropdown:GetWidth() + DROPDOWN_WIDTH_OFFSET
	dropdown:StripTextures(nil, true)
	dropdown:Width(newWidth, true)
	dropdown:NudgePoint(8, -2)
	dropdown:Height(20)
	dropdown.Arrow:SetAlpha(0)

	-- Blizzard's dynamic width is actually bugged now, but add some horizontal padding for styling anyway
	hooksecurefunc(dropdown, 'SetWidth', data.DropdownSetWidth)

	S:HandleCloseButton(dropdown.ResetButton)

	dropdown.IsSkinned = true
end

function data:HandleSettingsDropdown(window, dropdown)
	if not window or dropdown.IsSkinned then return end

	dropdown:Size(20)
	dropdown:NudgePoint(2, 1)
	dropdown.Icon:SetAlpha(0)

	if not dropdown.customIcon then
		local customIcon = dropdown:CreateTexture(nil, 'BACKGROUND')
		customIcon:SetAtlas('GM-icon-settings')
		customIcon:Point('CENTER')
		customIcon:Size(26)
		dropdown.customIcon = customIcon
	end

	dropdown.IsSkinned = true
end

function data:HandleHeader(window, header)
	local r, g, b, a = unpack(E.media.backdropfadecolor)
	header:SetTexture(E.media.blankTex)
	header:SetVertexColor(r, g, b, a)
	header:ClearAllPoints()
	header:Point('TOPLEFT', window, 6, -2)
	header:Point('BOTTOMRIGHT', window, 'TOPRIGHT', -12, -32)
end

function data:HandleStatusBar()
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

function data:ScrollBoxUpdate()
	self:ForEachFrame(data.HandleStatusBar)
end

do
	local updating = false
	function data:ScrollBoxSetPoint(point)
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

function data:ScrollBarArrowButtonOnDisable()
	self.customArrow:SetVertexColor(0.5, 0.5, 0.5)
end

function data:ScrollBarArrowButtonOnEnable()
	self.customArrow:SetVertexColor(1, 1, 1)
end

function data:ReskinScrollBarArrow(btn, arrowDir)
	if btn.IsSkinned then return end

	if not btn.customArrow then
		local customArrow = btn:CreateTexture(nil, 'ARTWORK')
		customArrow:SetTexture(E.Media.Textures.ArrowUp)
		customArrow:SetRotation(S.ArrowRotation[arrowDir])
		customArrow:Point('CENTER')
		customArrow:Size(15)

		btn.customArrow = customArrow
	end

	btn:HookScript('OnDisable', data.ScrollBarArrowButtonOnDisable)
	btn:HookScript('OnEnable', data.ScrollBarArrowButtonOnEnable)

	btn.IsSkinned = true
end

function data:HandleScrollBoxes(window)
	-- To avoid tainting the scroll bar, we apply minimal styling and leave the rest to HandleTrimScrollBar
	local ScrollBar = window:GetScrollBar()
	data:ReskinScrollBarArrow(ScrollBar.Back, 'up')
	data:ReskinScrollBarArrow(ScrollBar.Forward, 'down')
	S:HandleTrimScrollBar(ScrollBar)

	local ScrollBox = window:GetScrollBox()
	if not ScrollBox.IsSkinned then
		hooksecurefunc(ScrollBox, 'Update', data.ScrollBoxUpdate)
		hooksecurefunc(ScrollBox, 'SetPoint', data.ScrollBoxSetPoint)

		data.ScrollBoxUpdate(ScrollBox)
		data.ScrollBoxSetPoint(ScrollBox, 'TOPLEFT')
		data.ScrollBoxSetPoint(ScrollBox, 'BOTTOMRIGHT')

		ScrollBox.IsSkinned = true
	end
end

function data:RepositionResizeButton(container, x, y)
	local ResizeButton = container.ResizeButton
	data:HandleResizeButton(ResizeButton)

	local rotation = pi * 1.25
	ResizeButton:GetNormalTexture():SetRotation(rotation)
	ResizeButton:GetPushedTexture():SetRotation(rotation)

	ResizeButton:ClearAllPoints()
	ResizeButton:Point('BOTTOMRIGHT', container.Background, x, y)
	ResizeButton:Size(14)
end

function data:AnchorToSessionWindow() -- we could also handle source position here
	data:RepositionResizeButton(self, -24, 11)
end

function data:HandleMinimizeContainer(window, container)
	if not window or container.IsSkinned then return end

	data:HandleBackground(window, container.Background, 4, nil, -10)
	data:RepositionResizeButton(container, -6, -4)

	local sourceWindow = container.SourceWindow
	data:HandleBackground(window, sourceWindow.Background, 16, -13, -28, 15)
	data:HandleScrollBoxes(sourceWindow)
	hooksecurefunc(sourceWindow, 'AnchorToSessionWindow', data.AnchorToSessionWindow)

	container.IsSkinned = true
end

function data:HandleLocalPlayerEntry()
	local entry = self.MinimizeContainer.LocalPlayerEntry
	data.HandleStatusBar(entry)
	entry.StatusBar.Background:SetAlpha(1) -- Local player entry is floating above the other entries
end

function data:HandleMinimizeButton(window, button)
	if not window or button.IsSkinned then return end

	button:Size(16)
	button:SetHighlightAtlas('UI-QuestTrackerButton-Yellow-Highlight', 'ADD')

	data.SetMinimized(window, window.isMinimized)
	hooksecurefunc(window, 'SetMinimized', data.SetMinimized)

	button.IsSkinned = true
end

function data:SetMinimized(collapsed)
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

function data:HandleSessionWindow()
	if self.IsSkinned then return end

	data:HandleHeader(self, self.Header)
	data:HandleMinimizeButton(self, self.MinimizeButton)
	data:HandleMinimizeContainer(self, self.MinimizeContainer)
	data:HandleTypeDropdown(self, self.DamageMeterTypeDropdown)
	data:HandleSessionDropdown(self, self.SessionDropdown)
	data:HandleSettingsDropdown(self, self.SettingsDropdown)
	data:HandleScrollBoxes(self)

	self.SessionTimer:ClearAllPoints() -- point is a secret
	self.SessionTimer:Point('TOPLEFT', self.Header, 3, -9)

	hooksecurefunc(self, 'ShowLocalPlayerEntry', data.HandleLocalPlayerEntry)

	self.IsSkinned = true
end

function data:SetupSessionWindow()
	_G.DamageMeter:ForEachSessionWindow(data.HandleSessionWindow)
end

function S:Blizzard_DamageMeter()
	hooksecurefunc(_G.DamageMeter, 'SetupSessionWindow', data.SetupSessionWindow)
	data.SetupSessionWindow()
end
