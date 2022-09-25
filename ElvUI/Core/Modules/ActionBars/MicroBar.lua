local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

local _G = _G
local next = next
local wipe = wipe
local gsub = gsub
local pairs = pairs
local assert = assert
local unpack = unpack
local tinsert = tinsert
local CreateFrame = CreateFrame
local UpdateMicroButtonsParent = UpdateMicroButtonsParent
local RegisterStateDriver = RegisterStateDriver
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc

local microBar = CreateFrame('Frame', 'ElvUI_MicroBar', E.UIParent)
microBar:SetSize(100, 100)

local function onLeaveBar()
	return AB.db.microbar.mouseover and E:UIFrameFadeOut(microBar, 0.2, microBar:GetAlpha(), 0)
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

	local l, r, t, b = 0.22, 0.81, 0.26, 0.82
	if not E.Retail then
		l, r, t, b = 0.17, 0.87, 0.5, 0.908
	end

	pushed:SetTexCoord(l, r, t, b)
	pushed:SetInside(button.backdrop)

	normal:SetTexCoord(l, r, t, b)
	normal:SetInside(button.backdrop)

	if disabled then
		disabled:SetTexCoord(l, r, t, b)
		disabled:SetInside(button.backdrop)
	end
end

function AB:UpdateMicroButtonsParent()
	for _, x in pairs(_G.MICRO_BUTTONS) do
		_G[x]:SetParent(microBar)
	end
end

function AB:UpdateMicroBarVisibility()
	if InCombatLockdown() then
		AB.NeedsUpdateMicroBarVisibility = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local visibility = gsub(AB.db.microbar.visibility, '[\n\r]', '')
	RegisterStateDriver(microBar.visibility, 'visibility', (AB.db.microbar.enabled and visibility) or 'hide')
end

local commandKeys = {
	CharacterMicroButton = 'TOGGLECHARACTER0',
	SpellbookMicroButton = 'TOGGLESPELLBOOK',
	TalentMicroButton = 'TOGGLETALENTS',
	AchievementMicroButton = 'TOGGLEACHIEVEMENT',
	QuestLogMicroButton = 'TOGGLEQUESTLOG',
	GuildMicroButton = 'TOGGLEGUILDTAB',
	LFDMicroButton = 'TOGGLEGROUPFINDER',
	CollectionsMicroButton = 'TOGGLECOLLECTIONS',
	EJMicroButton = 'TOGGLEENCOUNTERJOURNAL',
	MainMenuMicroButton = 'TOGGLEGAMEMENU',
	StoreMicroButton = nil, -- special

	-- tbc specific
	SocialsMicroButton = 'TOGGLESOCIAL',
	WorldMapMicroButton = 'TOGGLEWORLDMAP',
	HelpMicroButton = nil, -- special
}

do
	local buttons = {}
	function AB:ShownMicroButtons()
		wipe(buttons)

		for _, name in next, _G.MICRO_BUTTONS do
			local button = _G[name]
			if button and button:IsShown() then
				tinsert(buttons, name)
			end
		end

		return buttons
	end
end

function AB:UpdateMicroButtons()
	local db = AB.db.microbar
	microBar.db = db

	microBar.backdrop:SetShown(db.backdrop)
	microBar.backdrop:ClearAllPoints()

	AB:MoverMagic(microBar)

	local btns = AB:ShownMicroButtons()
	db.buttons = #btns

	local buttonsPerRow = db.buttonsPerRow
	local backdropSpacing = db.backdropSpacing

	local _, horizontal, anchorUp, anchorLeft = AB:GetGrowth(db.point)
	local lastButton, anchorRowButton = microBar
	for i, name in next, btns do
		local button = _G[name]

		local columnIndex = i - buttonsPerRow
		local columnName = btns[columnIndex]
		local columnButton = _G[columnName]

		if not E.Retail then
			button.commandName = commandKeys[name] -- to support KB like retail
		end

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
			E:EnableMover(microBar.mover.name)
		else
			E:DisableMover(microBar.mover.name)
		end
	end

	if E.Retail then
		AB:UpdateGuildMicroButton()
	end

	AB:UpdateMicroBarVisibility()
end

function AB:UpdateGuildMicroButton()
	local btn = _G.GuildMicroButton
	local tabard = _G.GuildMicroButtonTabard
	tabard:SetInside(btn)
	tabard.background:SetInside(btn)
	tabard.background:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	tabard.emblem:ClearAllPoints()
	tabard.emblem:Point('TOPLEFT', btn, 4, -4)
	tabard.emblem:Point('BOTTOMRIGHT', btn, -4, 8)
end

function AB:SetupMicroBar()
	microBar:CreateBackdrop(AB.db.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, nil, 0)
	microBar:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 4, -48)
	microBar:EnableMouse(false)

	microBar.visibility = CreateFrame('Frame', nil, E.UIParent, 'SecureHandlerStateTemplate')
	microBar.visibility:SetScript('OnShow', function() microBar:Show() end)
	microBar.visibility:SetScript('OnHide', function() microBar:Hide() end)

	for _, x in pairs(_G.MICRO_BUTTONS) do
		AB:HandleMicroButton(_G[x])
	end

	_G.MicroButtonPortrait:SetInside(_G.CharacterMicroButton)

	AB:SecureHook('UpdateMicroButtons')
	AB:SecureHook('UpdateMicroButtonsParent')
	UpdateMicroButtonsParent(microBar)

	if not E.Retail then
		hooksecurefunc('SetLookingForGroupUIAvailable', AB.UpdateMicroButtons)
	end

	-- With this method we might don't taint anything. Instead of using :Kill()
	_G.MainMenuBarPerformanceBar:SetAlpha(0)
	_G.MainMenuBarPerformanceBar:SetScale(0.00001)

	if E.Wrath then
		_G.PVPMicroButtonTexture:ClearAllPoints()
		_G.PVPMicroButtonTexture:Point('TOP', _G.PVPMicroButton, 'TOP', 6, -1)
	end

	E:CreateMover(microBar, 'MicrobarMover', L["Micro Bar"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,microbar')
end
