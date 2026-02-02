local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local hooksecurefunc = hooksecurefunc
local unpack = unpack
local pi = math.pi

local CreateFrame = CreateFrame

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

	pushedTex:SetVertexColor(unpack(E.media.rgbvaluecolor))
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

function S:DamageMeter_HandleBackground(window)
	if not window or not window.Background or window.backdrop then return end

	window.Background:Hide()

	window:CreateBackdrop('Transparent')
	window.backdrop:NudgePoint(13, nil, nil, 'TOPLEFT')
	window.backdrop:NudgePoint(-18, nil, nil, 'BOTTOMRIGHT')

	-- Set initial alpha
	window.backdrop:SetAlpha(window.backgroundAlpha or 0.5)

	-- Inherit background alpha changes from Blizzard Edit Mode
	hooksecurefunc(window.Background, 'SetAlpha', S.DamageMeter_BackdropSetAlpha)
end

function S:DamageMeter_DropdownSetWidth(width, overrideFlag)
	if overrideFlag then return end

	self:SetWidth(width + DROPDOWN_WIDTH_OFFSET, true)
end

function S:DamageMeter_HandleHeader(window)
	if not window then return end

	local Header = not window.headerBackdrop and window.Header
	if Header then
		Header:Hide()

		local headerBackdrop = CreateFrame('Frame', nil, window)
		headerBackdrop:SetTemplate('Transparent')
		headerBackdrop:Point('TOPLEFT', 16, -2)
		headerBackdrop:Point('BOTTOMRIGHT', window, 'TOPRIGHT', -22, -28)
		headerBackdrop:OffsetFrameLevel(nil, window.backdrop)

		window.headerBackdrop = headerBackdrop
	end

	local DamageMeterTypeDropdown = window.DamageMeterTypeDropdown
	if DamageMeterTypeDropdown and not DamageMeterTypeDropdown.IsSkinned then
		S:HandleButton(DamageMeterTypeDropdown, nil, nil, nil, true, 'Default')

		DamageMeterTypeDropdown:Size(20)
		DamageMeterTypeDropdown:NudgePoint(nil, -2)

		local customArrow = not DamageMeterTypeDropdown.customArrow and DamageMeterTypeDropdown:CreateTexture(nil, 'BACKGROUND')
		if customArrow then
			customArrow:Point('CENTER')
			customArrow:Size(14)
			customArrow:SetTexture(E.Media.Textures.ArrowUp)
			customArrow:SetRotation(S.ArrowRotation.down)

			DamageMeterTypeDropdown.customArrow = customArrow
		end

		if DamageMeterTypeDropdown.Arrow then
			DamageMeterTypeDropdown.Arrow:SetAlpha(0)
		end

		if DamageMeterTypeDropdown.TypeName then
			DamageMeterTypeDropdown.TypeName:NudgePoint(-4, -1)
		end

		DamageMeterTypeDropdown.IsSkinned = true
	end

	local SessionDropdown = window.SessionDropdown
	if SessionDropdown and not SessionDropdown.IsSkinned then
		S:HandleButton(SessionDropdown, nil, nil, nil, true, 'Default')

		SessionDropdown:NudgePoint(nil, -3)
		SessionDropdown:Height(20)

		local newWidth = SessionDropdown:GetWidth() + DROPDOWN_WIDTH_OFFSET
		SessionDropdown:Width(newWidth, true)

		-- Blizzard's dynamic width is actually bugged now, but add some horizontal padding for styling anyway
		hooksecurefunc(SessionDropdown, 'SetWidth', S.DamageMeter_DropdownSetWidth)

		if SessionDropdown.Arrow then
			SessionDropdown.Arrow:SetAlpha(0)
		end

		if SessionDropdown.ResetButton then
			S:HandleCloseButton(SessionDropdown.ResetButton)
		end

		SessionDropdown.IsSkinned = true
	end

	local SettingsDropdown = window.SettingsDropdown
	if SettingsDropdown and not SettingsDropdown.IsSkinned then
		S:HandleButton(SettingsDropdown, nil, nil, nil, true, 'Default')

		SettingsDropdown:Size(20)
		SettingsDropdown:NudgePoint(-6, -2)

		if SettingsDropdown.Icon then
			SettingsDropdown.Icon:SetAlpha(0)
		end

		local customIcon = not SettingsDropdown.customIcon and SettingsDropdown:CreateTexture(nil, 'BACKGROUND')
		if customIcon then
			customIcon:Point('CENTER')
			customIcon:Size(26)
			customIcon:SetAtlas('GM-icon-settings')

			SettingsDropdown.customIcon = customIcon
		end

		SettingsDropdown.IsSkinned = true
	end
end

function S:DamageMeter_HandleStatusBar()
	local StatusBar = self.StatusBar
	if not StatusBar then return end

	if StatusBar.Background then
		StatusBar.Background:Hide()
	end

	if StatusBar.BackgroundEdge then
		StatusBar.BackgroundEdge:Hide()
	end

	if not StatusBar.backdrop then
		StatusBar:CreateBackdrop('Transparent')
	end

	StatusBar:GetStatusBarTexture():SetTexture(E.media.normTex)
end

function S:DamageMeter_HandleScrollBox()
	if not self.ForEachFrame then return end

	self:ForEachFrame(S.DamageMeter_HandleStatusBar)
end

function S:DamageMeter_HandleWindow(window)
	local ScrollBar = window.GetScrollBar and window:GetScrollBar()
	if ScrollBar then
		S:HandleTrimScrollBar(ScrollBar)
	end

	local ScrollBox = window.GetScrollBox and window:GetScrollBox()
	if ScrollBox and not ScrollBox.IsSkinned then
		hooksecurefunc(ScrollBox, 'Update', S.DamageMeter_HandleScrollBox)

		S.DamageMeter_HandleScrollBox(ScrollBox)

		ScrollBox.IsSkinned = true
	end
end

function S:DamageMeter_RepositionResizeButton()
	if not self or not self.backdrop then return end

	local ResizeButton = self.GetResizeButton and self:GetResizeButton()
	if not ResizeButton then return end

	S:DamageMeter_HandleResizeButton(ResizeButton)

	ResizeButton:Size(14)
	ResizeButton:ClearAllPoints()

	local isRightSide = self.IsRightSide and self:IsRightSide()
	local rotation = pi * (isRightSide and 1.25 or 0.75)
	local point = isRightSide and 'BOTTOMRIGHT' or 'BOTTOMLEFT'
	local xOffset = isRightSide and -4 or 4

	ResizeButton:GetNormalTexture():SetRotation(rotation)
	ResizeButton:GetPushedTexture():SetRotation(rotation)
	ResizeButton:Point(point, self.backdrop, point, xOffset, 4)
end

function S:DamageMeter_HandleSourceWindow(window)
	if not window or window.IsSkinned then return end

	S:DamageMeter_HandleBackground(window)
	S:DamageMeter_HandleWindow(window)

	if window.AnchorToSessionWindow then
		hooksecurefunc(window, 'AnchorToSessionWindow', S.DamageMeter_RepositionResizeButton)
	end

	window.IsSkinned = true
end

function S:DamageMeter_HandleSessionWindow(window)
	if not window or window.IsSkinned then return end

	S:DamageMeter_HandleBackground(window)
	S:DamageMeter_HandleHeader(window)
	S:DamageMeter_HandleWindow(window)
	S:DamageMeter_HandleSourceWindow(window.SourceWindow)

	window.IsSkinned = true
end

function S:DamageMeter_HandleSessionWindows()
	_G.DamageMeter:ForEachSessionWindow(S.DamageMeter_HandleSessionWindow)
end

function S:Blizzard_DamageMeter()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.damageMeter) then return end

	hooksecurefunc(_G.DamageMeter, 'SetupSessionWindow', S.DamageMeter_HandleSessionWindows)
	S.DamageMeter_HandleSessionWindows()
end

S:AddCallbackForAddon('Blizzard_DamageMeter')
