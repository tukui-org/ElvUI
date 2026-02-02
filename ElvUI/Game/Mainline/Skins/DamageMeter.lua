local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local hooksecurefunc = hooksecurefunc
local unpack = unpack
local pi = math.pi

local CreateFrame = CreateFrame

local DROPDOWN_WIDTH_OFFSET = 8

local function ButtonOnEnter(button)
	local normalTex = button:GetNormalTexture()
	if not normalTex then return end

	local r, g, b = unpack(E.media.rgbvaluecolor)
	normalTex:SetVertexColor(r, g, b)
end

local function ButtonOnLeave(button)
	local normalTex = button:GetNormalTexture()
	if not normalTex then return end

	normalTex:SetVertexColor(1, 1, 1)
end

local function HandleResizeButton(button)
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

	button:HookScript('OnEnter', ButtonOnEnter)
	button:HookScript('OnLeave', ButtonOnLeave)

	button.IsSkinned = true
end

local function BackdropSetAlpha(background, alpha)
	local parent = background:GetParent()
	if parent and parent.backdrop then
		parent.backdrop:SetAlpha(alpha)
	end
end

local function SkinBackground(window)
	if not window or not window.Background or window.backdrop then return end

	window.Background:Hide()

	window:CreateBackdrop('Transparent')
	window.backdrop:NudgePoint(13, nil, nil, 'TOPLEFT')
	window.backdrop:NudgePoint(-18, nil, nil, 'BOTTOMRIGHT')

	-- Set initial alpha
	window.backdrop:SetAlpha(window.backgroundAlpha or 0.5)

	-- Inherit background alpha changes from Blizzard Edit Mode
	hooksecurefunc(window.Background, 'SetAlpha', BackdropSetAlpha)
end

local function SessionDropdownSetWidth(dropdown, width, overrideFlag)
	if overrideFlag then return end

	dropdown:SetWidth(width + DROPDOWN_WIDTH_OFFSET, true)
end

local function SkinHeader(window)
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
		hooksecurefunc(SessionDropdown, 'SetWidth', SessionDropdownSetWidth)

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

local function SkinMeter(content)
	local StatusBar = content.StatusBar
	if StatusBar then
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
end

local function HandleMeterScrollBox(scrollBox)
	if not scrollBox or not scrollBox.ForEachFrame then return end

	scrollBox:ForEachFrame(SkinMeter)
end

local function SkinMeters(window)
	local ScrollBar = window.GetScrollBar and window:GetScrollBar()
	if ScrollBar then
		S:HandleTrimScrollBar(ScrollBar)
	end

	local ScrollBox = window.GetScrollBox and window:GetScrollBox()
	if ScrollBox and not ScrollBox.IsSkinned then
		hooksecurefunc(ScrollBox, 'Update', HandleMeterScrollBox)

		HandleMeterScrollBox(ScrollBox)

		ScrollBox.IsSkinned = true
	end
end

local function RepositionResizeButton(window)
	if not window or not window.backdrop then return end

	local ResizeButton = window.GetResizeButton and window:GetResizeButton()
	if not ResizeButton then return end

	HandleResizeButton(ResizeButton)

	ResizeButton:Size(14)
	ResizeButton:ClearAllPoints()

	local isRightSide = window.IsRightSide and window:IsRightSide()
	local rotation = pi * (isRightSide and 1.25 or 0.75)
	local point = isRightSide and 'BOTTOMRIGHT' or 'BOTTOMLEFT'
	local xOffset = isRightSide and -4 or 4

	ResizeButton:GetNormalTexture():SetRotation(rotation)
	ResizeButton:GetPushedTexture():SetRotation(rotation)
	ResizeButton:Point(point, window.backdrop, point, xOffset, 4)
end

local function SkinSourceWindow(window)
	if not window or window.IsSkinned then return end

	SkinBackground(window)
	SkinMeters(window)

	if window.AnchorToSessionWindow then
		hooksecurefunc(window, 'AnchorToSessionWindow', RepositionResizeButton)
	end

	window.IsSkinned = true
end

local function HandleSessionWindow(window)
	if not window or window.IsSkinned then return end

	SkinBackground(window)
	SkinHeader(window)
	SkinMeters(window)
	SkinSourceWindow(window.SourceWindow)

	window.IsSkinned = true
end

local function ReskinAllSessionWindows()
	_G.DamageMeter:ForEachSessionWindow(HandleSessionWindow)
end

function S:Blizzard_DamageMeter()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.damageMeter) then return end

	hooksecurefunc(_G.DamageMeter, 'SetupSessionWindow', ReskinAllSessionWindows)
	ReskinAllSessionWindows()
end

S:AddCallbackForAddon('Blizzard_DamageMeter')
