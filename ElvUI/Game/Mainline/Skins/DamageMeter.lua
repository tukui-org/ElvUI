local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local pi = math.pi
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local DROPDOWN_WIDTH_OFFSET = 8

function S:DamageMeter_ButtonOnEnter()
	local normalTex = self:GetNormalTexture()
	if not normalTex then return end

	local r, g, b = unpack(E.media.rgbvaluecolor)
	normalTex:SetVertexColor(r, g, b)
end

function S:DamageMeter_ButtonOnLeave()
	local normalTex = self:GetNormalTexture()
	if not normalTex then return end

	normalTex:SetVertexColor(1, 1, 1)
end

function S:DamageMeter_HandleResizeButton(button)
	if not button or button.IsSkinned then return end

	button:SetNormalTexture(E.Media.Textures.ArrowUp)
	button:SetPushedTexture(E.Media.Textures.ArrowUp)
	button:GetHighlightTexture():SetTexture('')

	local normalTex = button:GetNormalTexture()
	local pushedTex = button:GetPushedTexture()

	if not normalTex or not pushedTex then return end

	normalTex:SetVertexColor(1, 1, 1)
	normalTex:SetTexCoord(0, 1, 0, 1)
	normalTex:SetAllPoints()

	local r, g, b = unpack(E.media.rgbvaluecolor)
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

function S:DamageMeter_HandleBackground(window, background, x1, y1, x2, y2)
	if not window or not background or background.backdrop then return end

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

function S:DamageMeter_HandleSessionTimer(window, sessionTimer)
	if not sessionTimer then return end

	sessionTimer:NudgePoint(-15)
end

function S:DamageMeter_HandleTypeDropdown(window, dropdown)
	if not dropdown or dropdown.IsSkinned then return end

	S:HandleButton(dropdown, nil, nil, nil, true)

	dropdown:Size(20)
	dropdown:NudgePoint(nil, -2)

	local customArrow = not dropdown.customArrow and dropdown:CreateTexture(nil, 'BACKGROUND')
	if customArrow then
		customArrow:Point('CENTER')
		customArrow:Size(14)
		customArrow:SetTexture(E.Media.Textures.ArrowUp)
		customArrow:SetRotation(S.ArrowRotation.down)

		dropdown.customArrow = customArrow
	end

	if dropdown.Arrow then
		dropdown.Arrow:SetAlpha(0)
	end

	if dropdown.TypeName then
		dropdown.TypeName:NudgePoint(-4, -1)
	end

	dropdown.IsSkinned = true
end

function S:DamageMeter_HandleSessionDropdown(window, dropdown)
	if not dropdown or dropdown.IsSkinned then return end

	S:HandleButton(dropdown, nil, nil, nil, true)

	dropdown:NudgePoint(nil, -3)
	dropdown:Height(20)

	local newWidth = dropdown:GetWidth() + DROPDOWN_WIDTH_OFFSET
	dropdown:Width(newWidth, true)

	-- Blizzard's dynamic width is actually bugged now, but add some horizontal padding for styling anyway
	hooksecurefunc(dropdown, 'SetWidth', S.DamageMeter_DropdownSetWidth)

	if dropdown.Arrow then
		dropdown.Arrow:SetAlpha(0)
	end

	if dropdown.ResetButton then
		S:HandleCloseButton(dropdown.ResetButton)
	end

	dropdown.IsSkinned = true
end

function S:DamageMeter_HandleSettingsDropdown(window, dropdown)
	if not dropdown or dropdown.IsSkinned then return end

	S:HandleButton(dropdown, nil, nil, nil, true)

	dropdown:Size(20)
	dropdown:NudgePoint(2, 0)

	if dropdown.Icon then
		dropdown.Icon:SetAlpha(0)
	end

	local customIcon = not dropdown.customIcon and dropdown:CreateTexture(nil, 'BACKGROUND')
	if customIcon then
		customIcon:Point('CENTER')
		customIcon:Size(26)
		customIcon:SetAtlas('GM-icon-settings')

		dropdown.customIcon = customIcon
	end

	dropdown.IsSkinned = true
end

function S:DamageMeter_HandleHeader(window, header)
	if not window or not header then return end

	local r, g, b, a = unpack(E.media.backdropfadecolor)
	header:SetTexture(E.media.blankTex)
	header:SetVertexColor(r, g, b, a)
	header:ClearAllPoints()
	header:Point('TOPLEFT', 16, -2)
	header:Point('BOTTOMRIGHT', window, 'TOPRIGHT', -22, -32)
end

function S:DamageMeter_HandleStatusBar()
	local StatusBar = self.StatusBar
	if not StatusBar then return end

	if StatusBar.Background then
		local r, g, b, a = unpack(E.media.backdropfadecolor)
		StatusBar.Background:SetTexture(E.media.blankTex)
		StatusBar.Background:SetVertexColor(r, g, b, a)
	end

	if StatusBar.BackgroundEdge then
		StatusBar.BackgroundEdge:Hide()
	end

	StatusBar:GetStatusBarTexture():SetTexture(E.media.normTex)
end

function S:DamageMeter_ScrollBoxUpdate()
	if not self.ForEachFrame then return end

	self:ForEachFrame(S.DamageMeter_HandleStatusBar)
end

do
	local updating = false
	function S:DamageMeter_ScrollBoxSetPoint(point)
		if updating then return end

		updating = true

		if point == 'TOPLEFT' then
			self:NudgePoint(-16, 0, nil, point)
		elseif point == 'BOTTOMRIGHT' then
			self:NudgePoint(-5, 0, nil, point)
		end

		updating = false
	end
end

function S:DamageMeter_ScrollBarArrowButtonOnDisable()
	if not self.customArrow then return end

	self.customArrow:SetVertexColor(0.5, 0.5, 0.5)
end

function S:DamageMeter_ScrollBarArrowButtonOnEnable()
	if not self.customArrow then return end

	self.customArrow:SetVertexColor(1, 1, 1)
end

function S:DamageMeter_ReskinScrollBarArrow(btn, arrowDir)
	if not btn or btn.IsSkinned then return end

	if not btn.customArrow then
		btn.customArrow = btn:CreateTexture(nil, 'ARTWORK')
		btn.customArrow:SetTexture(E.Media.Textures.ArrowUp)
		btn.customArrow:SetRotation(S.ArrowRotation[arrowDir])
		btn.customArrow:Point('CENTER')
		btn.customArrow:Size(15)
	end

	btn:HookScript('OnDisable', S.DamageMeter_ScrollBarArrowButtonOnDisable)
	btn:HookScript('OnEnable', S.DamageMeter_ScrollBarArrowButtonOnEnable)

	btn.IsSkinned = true
end

function S:DamageMeter_HandleScrollBoxes(window)
	local ScrollBar = window.GetScrollBar and window:GetScrollBar()
	if ScrollBar then -- To avoid tainting the scroll bar, we apply minimal styling and leave the rest to HandleTrimScrollBar
		S:DamageMeter_ReskinScrollBarArrow(ScrollBar.Back, 'up')
		S:DamageMeter_ReskinScrollBarArrow(ScrollBar.Forward, 'down')

		S:HandleTrimScrollBar(ScrollBar)
	end

	local ScrollBox = window.GetScrollBox and window:GetScrollBox()
	if ScrollBox and not ScrollBox.IsSkinned then
		hooksecurefunc(ScrollBox, 'Update', S.DamageMeter_ScrollBoxUpdate)
		hooksecurefunc(ScrollBox, 'SetPoint', S.DamageMeter_ScrollBoxSetPoint)

		S.DamageMeter_ScrollBoxUpdate(ScrollBox)
		S.DamageMeter_ScrollBoxSetPoint(ScrollBox, 'TOPLEFT')
		S.DamageMeter_ScrollBoxSetPoint(ScrollBox, 'BOTTOMRIGHT')

		ScrollBox.IsSkinned = true
	end
end

function S:DamageMeter_RepositionResizeButton(container)
	local ResizeButton = container.ResizeButton
	if not ResizeButton then return end

	S:DamageMeter_HandleResizeButton(ResizeButton)

	ResizeButton:Size(14)
	ResizeButton:ClearAllPoints()

	local rotation = pi * 1.25
	ResizeButton:GetNormalTexture():SetRotation(rotation)
	ResizeButton:GetPushedTexture():SetRotation(rotation)
	ResizeButton:Point('BOTTOMRIGHT', container.Background, -12, 2)
end

function S:DamageMeter_HandleSourceWindow(window, sourceWindow)
	if not sourceWindow or sourceWindow.IsSkinned then return end

	S:DamageMeter_HandleScrollBoxes(sourceWindow)

	sourceWindow.IsSkinned = true
end

function S:DamageMeter_HandleMinimizeContainer(window, container)
	if not container or container.IsSkinned then return end

	S:DamageMeter_HandleBackground(window, container.Background, 4, nil, -10)
	S:DamageMeter_RepositionResizeButton(container)

	container.IsSkinned = true
end

function S:DamageMeter_HandleLocalPlayerEntry()
	local entry = self.LocalPlayerEntry
	if not entry then return end

	S.DamageMeter_HandleStatusBar(entry)

	local StatusBarBackground = entry.StatusBar and entry.StatusBar.Background
	if StatusBarBackground then -- Local player entry is floating above the other entries
		StatusBarBackground:SetAlpha(1)
	end
end

function S:DamageMeter_HandleMinimizeButton(window, button)
	if not button or button.IsSkinned then return end

	button:Size(16)
	button:NudgePoint(13)
	button:SetHighlightAtlas('UI-QuestTrackerButton-Yellow-Highlight', 'ADD')

	S.DamageMeter_SetMinimized(window, window.isMinimized)
	hooksecurefunc(window, 'SetMinimized', S.DamageMeter_SetMinimized)

	button.IsSkinned = true
end

function S:DamageMeter_SetMinimized(collapsed)
	local MinimizeButton = self.MinimizeButton
	if not MinimizeButton then return end

	local normalTexture = MinimizeButton:GetNormalTexture()
	local pushedTexture = MinimizeButton:GetPushedTexture()

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
	S:DamageMeter_HandleMinimizeContainer(self, self.MinimizeContainer)
	S:DamageMeter_HandleTypeDropdown(self, self.DamageMeterTypeDropdown)
	S:DamageMeter_HandleSessionDropdown(self, self.SessionDropdown)
	S:DamageMeter_HandleSettingsDropdown(self, self.SettingsDropdown)
	S:DamageMeter_HandleSourceWindow(self, self.SourceWindow)
	S:DamageMeter_HandleSessionTimer(self, self.SessionTimer)
	S:DamageMeter_HandleScrollBoxes(self)

	if self.ShowLocalPlayerEntry then
		hooksecurefunc(self, 'ShowLocalPlayerEntry', S.DamageMeter_HandleLocalPlayerEntry)
	end

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
