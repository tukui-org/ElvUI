local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

local _G = _G
local gsub = gsub
local pairs = pairs
local assert = assert
local unpack = unpack
local CreateFrame = CreateFrame
local C_StorePublic_IsEnabled = C_StorePublic.IsEnabled
local UpdateMicroButtonsParent = UpdateMicroButtonsParent
local GetCurrentRegionName = GetCurrentRegionName
local RegisterStateDriver = RegisterStateDriver
local InCombatLockdown = InCombatLockdown

local microBar = CreateFrame('Frame', 'ElvUI_MicroBar', E.UIParent)
microBar:SetSize(100, 100)

local function onLeaveBar()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(microBar, 0.2, microBar:GetAlpha(), 0)
	end
end

local watcher = 0
local function onUpdate(self, elapsed)
	if watcher > 0.1 then
		if not self:IsMouseOver() then
			self.IsMouseOvered = nil
			self:SetScript('OnUpdate', nil)
			onLeaveBar()
		end
		watcher = 0
	else
		watcher = watcher + elapsed
	end
end

local function onEnter(button)
	if AB.db.microbar.mouseover and not microBar.IsMouseOvered then
		microBar.IsMouseOvered = true
		microBar:SetScript('OnUpdate', onUpdate)
		E:UIFrameFadeIn(microBar, 0.2, microBar:GetAlpha(), AB.db.microbar.alpha)
	end

	if button:IsEnabled() then
		button:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end

	-- bag keybind support from actionbar module
	if E.private.actionbar.enable then
		AB:BindUpdate(button, 'MICRO')
	end
end

local function onLeave(button)
	if button:IsEnabled() then
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

function AB:HandleMicroButton(button)
	assert(button, 'Invalid micro button name.')

	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	button:SetTemplate()
	button:SetParent(microBar)
	button:GetHighlightTexture():Kill()
	button:HookScript('OnEnter', onEnter)
	button:HookScript('OnLeave', onLeave)
	button:SetHitRectInsets(0, 0, 0, 0)

	if button.Flash then
		button.Flash:SetInside()
		button.Flash:SetTexture()
	end

	pushed:SetTexCoord(0.22, 0.81, 0.26, 0.82)
	pushed:SetInside(button)

	normal:SetTexCoord(0.22, 0.81, 0.21, 0.82)
	normal:SetInside(button)

	if disabled then
		disabled:SetTexCoord(0.22, 0.81, 0.21, 0.82)
		disabled:SetInside(button)
	end
end

function AB:MainMenuMicroButton_SetNormal()
	_G.MainMenuBarPerformanceBar:ClearAllPoints()
	_G.MainMenuBarPerformanceBar:Point('TOPLEFT', _G.MainMenuMicroButton, 'TOPLEFT', 9, -36)
end

function AB:MainMenuMicroButton_SetPushed()
	_G.MainMenuBarPerformanceBar:ClearAllPoints()
	_G.MainMenuBarPerformanceBar:Point('TOPLEFT', _G.MainMenuMicroButton, 'TOPLEFT', 8, -37)
end

function AB:UpdateMicroButtonsParent()
	for _, x in pairs(_G.MICRO_BUTTONS) do
		_G[x]:SetParent(microBar)
	end
end

-- we use this table to sort the micro buttons on our bar to match Blizzard's button placements.
local __buttonIndex = {
	[8] = 'CollectionsMicroButton',
	[9] = 'EJMicroButton',
	[10] = (not C_StorePublic_IsEnabled() and GetCurrentRegionName() == 'CN') and 'HelpMicroButton' or 'StoreMicroButton',
	[11] = 'MainMenuMicroButton'
}

function AB:UpdateMicroBarVisibility()
	if InCombatLockdown() then
		AB.NeedsUpdateMicroBarVisibility = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local visibility = AB.db.microbar.visibility
	visibility = gsub(visibility, '[\n\r]','')

	RegisterStateDriver(microBar.visibility, 'visibility', (AB.db.microbar.enabled and visibility) or 'hide')
end

function AB:UpdateMicroPositionDimensions()
	local db = AB.db.microbar
	microBar.db = db

	microBar.backdrop:SetShown(db.backdrop)
	microBar.backdrop:ClearAllPoints()

	AB:MoverMagic(microBar)

	local btns = _G.MICRO_BUTTONS
	local numBtns = #btns-1
	db.buttons = numBtns

	local buttonsPerRow = db.buttonsPerRow
	local backdropSpacing = db.backdropSpacing

	local _, horizontal, anchorUp, anchorLeft = AB:GetGrowth(db.point)
	local lastButton, anchorRowButton = microBar
	for i = 1, numBtns do
		local name = __buttonIndex[i] or btns[i]
		local button = _G[name]

		local columnIndex = i - buttonsPerRow
		local columnName = __buttonIndex[columnIndex] or btns[columnIndex]
		local columnButton = _G[columnName]

		button.db = db

		if i == 1 or i == buttonsPerRow then
			anchorRowButton = button
		end

		button.handleBackdrop = true -- keep over HandleButton
		AB:HandleButton(microBar, button, i, lastButton, columnButton)

		lastButton = button
	end

	microBar:SetAlpha((db.mouseover and not microBar.IsMouseOvered and 0) or db.alpha)

	AB:HandleBackdropMultiplier(microBar, backdropSpacing, db.buttonSpacing, db.widthMult, db.heightMult, anchorUp, anchorLeft, horizontal, lastButton, anchorRowButton)
	AB:HandleBackdropMover(microBar, backdropSpacing)

	if microBar.mover then
		if AB.db.microbar.enabled then
			E:EnableMover(microBar.mover:GetName())
		else
			E:DisableMover(microBar.mover:GetName())
		end
	end

	AB:UpdateMicroBarVisibility()
end

function AB:UpdateMicroButtons()
	local GuildMicroButton = _G.GuildMicroButton
	local GuildMicroButtonTabard = _G.GuildMicroButtonTabard
	GuildMicroButtonTabard:SetInside(GuildMicroButton)
	GuildMicroButtonTabard.background:SetInside(GuildMicroButton)
	GuildMicroButtonTabard.background:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	GuildMicroButtonTabard.emblem:ClearAllPoints()
	GuildMicroButtonTabard.emblem:Point('TOPLEFT', GuildMicroButton, 'TOPLEFT', 4, -4)
	GuildMicroButtonTabard.emblem:Point('BOTTOMRIGHT', GuildMicroButton, 'BOTTOMRIGHT', -4, 8)

	AB:UpdateMicroPositionDimensions()
end

function AB:SetupMicroBar()
	microBar:CreateBackdrop(AB.db.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, 0)
	microBar:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 4, -48)
	microBar:EnableMouse(false)

	microBar.visibility = CreateFrame('Frame', nil, E.UIParent, 'SecureHandlerStateTemplate')
	microBar.visibility:SetScript('OnShow', function() microBar:Show() end)
	microBar.visibility:SetScript('OnHide', function() microBar:Hide() end)

	for _, x in pairs(_G.MICRO_BUTTONS) do
		AB:HandleMicroButton(_G[x])
	end

	_G.MicroButtonPortrait:SetInside(_G.CharacterMicroButton)

	AB:SecureHook('UpdateMicroButtonsParent')
	AB:SecureHook('MoveMicroButtons', 'UpdateMicroPositionDimensions')
	AB:SecureHook('UpdateMicroButtons')
	UpdateMicroButtonsParent(microBar)
	AB:MainMenuMicroButton_SetNormal()
	AB:UpdateMicroPositionDimensions()

	-- With this method we might don't taint anything. Instead of using :Kill()
	_G.MainMenuBarPerformanceBar:SetAlpha(0)
	_G.MainMenuBarPerformanceBar:SetScale(0.00001)

	E:CreateMover(microBar, 'MicrobarMover', L["Micro Bar"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,microbar')
end
