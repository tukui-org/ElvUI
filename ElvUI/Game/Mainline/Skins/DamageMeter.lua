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
	local parent = self:GetParent()
	if parent and parent.backdrop then
		parent.backdrop:SetAlpha(alpha)
	end
end

function S:DamageMeter_HandleBackground(window, background, x1, y1, x2, y2)
	if not window or not background or window.backdrop then return end

	background:Hide()

	window:CreateBackdrop('Transparent')
	window.backdrop:NudgePoint(x1, y1, nil, 'TOPLEFT')
	window.backdrop:NudgePoint(x2, y2, nil, 'BOTTOMRIGHT')

	-- Set initial alpha; 100% will not set backgroundAlpha so default to 1
	-- this copies the functionality of GetBackgroundAlpha
	window.backdrop:SetAlpha(window.backgroundAlpha or 1)

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

	S:HandleButton(dropdown, nil, nil, nil, true, 'Default')

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

	S:HandleButton(dropdown, nil, nil, nil, true, 'Default')

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

	S:HandleButton(dropdown, nil, nil, nil, true, 'Default')

	dropdown:Size(20)
	dropdown:NudgePoint(15, -2)

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
		if not updating and point == 'TOPLEFT' then
			updating = true
			self:NudgePoint(-15)
			updating = false
		end
	end
end

function S:DamageMeter_HandleScrollBoxes(window)
	local ScrollBar = window.GetScrollBar and window:GetScrollBar()
	if ScrollBar then
		S:HandleTrimScrollBar(ScrollBar)
	end

	local ScrollBox = window.GetScrollBox and window:GetScrollBox()
	if ScrollBox and not ScrollBox.IsSkinned then
		hooksecurefunc(ScrollBox, 'Update', S.DamageMeter_ScrollBoxUpdate)
		hooksecurefunc(ScrollBox, 'SetPoint', S.DamageMeter_ScrollBoxSetPoint)

		S.DamageMeter_ScrollBoxUpdate(ScrollBox)
		S.DamageMeter_ScrollBoxSetPoint(ScrollBox, 'TOPLEFT')

		ScrollBox.IsSkinned = true
	end
end

function S:DamageMeter_RepositionResizeButton()
	local ResizeButton = self.backdrop and self.GetResizeButton and self:GetResizeButton()
	if not ResizeButton then return end

	S:DamageMeter_HandleResizeButton(ResizeButton)

	ResizeButton:Size(14)
	ResizeButton:ClearAllPoints()

	local isRightSide = not self.IsRightSide or self:IsRightSide()
	local rotation = pi * (isRightSide and 1.25 or 0.75)
	local point = isRightSide and 'BOTTOMRIGHT' or 'BOTTOMLEFT'
	local xOffset = isRightSide and -4 or 4

	ResizeButton:GetNormalTexture():SetRotation(rotation)
	ResizeButton:GetPushedTexture():SetRotation(rotation)
	ResizeButton:Point(point, self.backdrop, point, xOffset, 4)
end

function S:DamageMeter_HandleSourceWindow(window, sourceWindow)
	if not sourceWindow or sourceWindow.IsSkinned then return end

	S:DamageMeter_HandleBackground(sourceWindow, sourceWindow.Background, -4, nil, -18)
	S:DamageMeter_HandleScrollBoxes(sourceWindow)

	if sourceWindow.AnchorToSessionWindow then
		hooksecurefunc(sourceWindow, 'AnchorToSessionWindow', S.DamageMeter_RepositionResizeButton)
	end

	sourceWindow.IsSkinned = true
end

function S:DamageMeter_HandleSessionWindow()
	if self.IsSkinned then return end

	S:DamageMeter_HandleBackground(self, self.Background, 13, nil, -18)
	S:DamageMeter_HandleHeader(self, self.Header)
	S:DamageMeter_HandleTypeDropdown(self, self.DamageMeterTypeDropdown)
	S:DamageMeter_HandleSessionDropdown(self, self.SessionDropdown)
	S:DamageMeter_HandleSettingsDropdown(self, self.SettingsDropdown)
	S:DamageMeter_HandleSourceWindow(self, self.SourceWindow)
	S:DamageMeter_HandleSessionTimer(self, self.SessionTimer)
	S:DamageMeter_HandleScrollBoxes(self)
	S.DamageMeter_RepositionResizeButton(self)

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
