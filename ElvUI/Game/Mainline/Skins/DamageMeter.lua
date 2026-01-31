local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local unpack = unpack
local pi, floor = math.pi, math.floor

local CreateFrame = CreateFrame

local function HandleResizeButton(button)
	if not button or button.IsSkinned then return end

	button:SetNormalTexture(E.Media.Textures.ArrowUp)
	button:GetHighlightTexture():SetTexture('')
	button:SetPushedTexture(E.Media.Textures.ArrowUp)

	local normalTex = button:GetNormalTexture()
	local pushedTex = button:GetPushedTexture()

	if not normalTex or not pushedTex then return end

	normalTex:SetVertexColor(1, 1, 1)
	normalTex:SetTexCoord(0, 1, 0, 1)
	normalTex:SetAllPoints()

	pushedTex:SetVertexColor(unpack(E.media.rgbvaluecolor))
	pushedTex:SetTexCoord(0, 1, 0, 1)
	pushedTex:SetAllPoints()

	button:HookScript('OnEnter', function()
		normalTex:SetVertexColor(unpack(E.media.rgbvaluecolor))
	end)

	button:HookScript('OnLeave', function()
		normalTex:SetVertexColor(1, 1, 1)
	end)

	button.IsSkinned = true
end

local function SkinBackground(window)
	if not window or not window.Background or window.backdrop then return end

	window.Background:Hide()

	window:CreateBackdrop('Transparent')
	window.backdrop:NudgePoint(13, nil, nil, 'TOPLEFT')
	window.backdrop:NudgePoint(-18, nil, nil, 'BOTTOMRIGHT')

	-- Inherit background alpha changes from Blizzard Edit Mode
	hooksecurefunc(window.Background, 'SetAlpha', function(_, alpha)
		window.backdrop:SetAlpha(alpha)
	end)
end

local function SkinHeader(window)
	if not window then return end

	local Header = window.Header
	if Header and not window.headerBackdrop then
		Header:Hide()
		window.headerBackdrop = CreateFrame('Frame', nil, window)
		window.headerBackdrop:SetTemplate('Transparent')
		window.headerBackdrop:Point('TOPLEFT', 17, -2)
		window.headerBackdrop:Point('BOTTOMRIGHT', window, 'TOPRIGHT', -22, -28)
		window.headerBackdrop:SetFrameLevel(window.backdrop:GetFrameLevel())
	end

	local DamageMeterTypeDropdown = window.DamageMeterTypeDropdown
	if DamageMeterTypeDropdown and not DamageMeterTypeDropdown.IsSkinned then
		S:HandleButton(DamageMeterTypeDropdown, nil, nil, nil, true, 'Default')
		DamageMeterTypeDropdown:Size(20)
		DamageMeterTypeDropdown:NudgePoint(nil, -2)

		if not DamageMeterTypeDropdown.customArrow then
			local customArrow = DamageMeterTypeDropdown:CreateTexture(nil, 'BACKGROUND')
			customArrow:Point('CENTER')
			customArrow:Size(14)
			customArrow:SetTexture(E.Media.Textures.ArrowUp)
			customArrow:SetRotation(S.ArrowRotation.down)

			DamageMeterTypeDropdown.customArrow = customArrow
		end

		if DamageMeterTypeDropdown.Arrow then DamageMeterTypeDropdown.Arrow:SetAlpha(0) end
		if DamageMeterTypeDropdown.TypeName then DamageMeterTypeDropdown.TypeName:NudgePoint(-4, -1) end

		DamageMeterTypeDropdown.IsSkinned = true
	end

	local SessionDropdown = window.SessionDropdown
	if SessionDropdown and not SessionDropdown.IsSkinned then
		S:HandleButton(SessionDropdown, nil, nil, nil, true, 'Default')

		SessionDropdown:NudgePoint(nil, -3)
		SessionDropdown:Height(20)

		-- Blizzard's dynamic width is actually bugged now, but add some horizontal padding for styling anyway
		hooksecurefunc(SessionDropdown, 'SetWidth', function(self, width, overrideFlag)
			if not overrideFlag then self:SetWidth(width + 8, true) end
		end)
		SessionDropdown:Width(SessionDropdown:GetWidth() + 8, true)

		if SessionDropdown.Arrow then SessionDropdown.Arrow:SetAlpha(0) end
		if SessionDropdown.ResetButton then S:HandleCloseButton(SessionDropdown.ResetButton) end

		SessionDropdown.IsSkinned = true
	end

	local SettingsDropdown = window.SettingsDropdown
	if SettingsDropdown and not SettingsDropdown.IsSkinned then
		S:HandleButton(SettingsDropdown, nil, nil, nil, true, 'Default')
		SettingsDropdown:Size(20)
		SettingsDropdown:NudgePoint(-6, -2)

		if SettingsDropdown.Icon then SettingsDropdown.Icon:SetAlpha(0) end

		if not SettingsDropdown.customIcon then
			local customIcon = SettingsDropdown:CreateTexture(nil, 'BACKGROUND')
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
		if StatusBar.Background then StatusBar.Background:Hide() end
		if StatusBar.BackgroundEdge then StatusBar.BackgroundEdge:Hide() end
		if not StatusBar.backdrop then StatusBar:CreateBackdrop('Transparent') end
		StatusBar:GetStatusBarTexture():SetTexture(E.media.normTex)
	end
end

local function HandleMeterScrollBox(scrollBox)
	if not scrollBox or not scrollBox.ForEachFrame then return end
	scrollBox:ForEachFrame(SkinMeter)
end

local function SkinMeters(window)
	local ScrollBar = window.GetScrollBar and window:GetScrollBar()
	if ScrollBar then S:HandleTrimScrollBar(ScrollBar) end

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

	if window.AnchorToSessionWindow then hooksecurefunc(window, 'AnchorToSessionWindow', RepositionResizeButton) end

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
