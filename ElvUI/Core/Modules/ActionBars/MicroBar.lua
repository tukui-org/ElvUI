local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

local _G = _G
local next = next
local wipe = wipe
local gsub = gsub
local assert = assert
local unpack = unpack
local tinsert = tinsert
local CreateFrame = CreateFrame
local UpdateMicroButtonsParent = UpdateMicroButtonsParent
local RegisterStateDriver = RegisterStateDriver
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc

AB.MICRO_CLASSIC = {}
AB.MICRO_BUTTONS = _G.MICRO_BUTTONS or {
	'CharacterMicroButton',
	'SpellbookMicroButton',
	'TalentMicroButton',
	'AchievementMicroButton',
	'QuestLogMicroButton',
	'GuildMicroButton',
	'LFDMicroButton',
	'EJMicroButton',
	'CollectionsMicroButton',
	'MainMenuMicroButton',
	'HelpMicroButton',
	'StoreMicroButton',
}

do
	local meep = 12.125
	AB.MICRO_OFFSETS = {
		CharacterMicroButton	= 0.07 / meep,
		SpellbookMicroButton	= 1.05 / meep,
		TalentMicroButton		= 2.04 / meep,
		AchievementMicroButton	= 3.03 / meep,
		QuestLogMicroButton		= 4.02 / meep,
		GuildMicroButton		= 5.01 / meep, -- Retail
		SocialsMicroButton		= 5.01 / meep, -- Classic, use Guild button
		LFDMicroButton			= 6.00 / meep, -- Retail
		LFGMicroButton			= 6.00 / meep, -- Classic
		EJMicroButton			= 7.00 / meep,
		CollectionsMicroButton	= 8.00 / meep,
		MainMenuMicroButton		= (E.Retail and 9 or 10) / meep, -- flip these
		HelpMicroButton			= (E.Retail and 10 or 9) / meep, -- on classic
		StoreMicroButton		= 10.0 / meep
	}
end

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

function AB:HandleMicroCoords(button, name)
	local l, r, t, b = 0.17, 0.87, 0.5, 0.908
	local icons = AB.db.microbar.useIcons

	if name == 'PVPMicroButton' or (not E.Retail and name == 'CharacterMicroButton') then
		l, r, t, b = 0, 1, 0, 1
	elseif E.Retail or icons then
		local offset = AB.MICRO_OFFSETS[name]
		if offset then
			l, r = offset, offset + 0.065
			t, b = icons and 0.41 or 0.038, icons and 0.72 or 0.35
		end
	end

	button:GetNormalTexture():SetTexCoord(l, r, t, b)
	button:GetPushedTexture():SetTexCoord(l, r, t, b)

	if button.FlashBorder then
		button.FlashBorder:SetTexCoord(l, r, t, b)
	end

	local disabled = button:GetDisabledTexture()
	if disabled then
		disabled:SetTexCoord(l, r, t, b)
	end
end

function AB:HandleMicroTextures(button, name)
	local normal = button:GetNormalTexture()
	local pushed = button:GetPushedTexture()

	local icons = AB.db.microbar.useIcons
	local character = not E.Retail and name == 'CharacterMicroButton' and E.Media.Textures.Black8x8
	local faction = name == 'PVPMicroButton' and E.Media.Textures[E.myfaction == 'Horde' and 'PVPHorde' or 'PVPAlliance']
	local texture = faction or (not character and AB.MICRO_OFFSETS[name] and E.Media.Textures.MicroBar)
	local stock = not E.Retail and not icons and AB.MICRO_CLASSIC[name] -- classic default icons from the game
	if stock then
		normal:SetTexture(faction or stock.normal)
		pushed:SetTexture(character or faction or stock.pushed)
	elseif texture then
		normal:SetTexture(texture)
		pushed:SetTexture(character or texture)
	elseif character then
		normal:SetTexture()
		pushed:SetTexture(character)
	end

	if character then
		pushed:SetDrawLayer('OVERLAY', 1)
		pushed:SetBlendMode('ADD')
		pushed:SetAlpha(0.25)
	end

	normal:SetInside(button.backdrop)
	pushed:SetInside(button.backdrop)

	local color = E.media.rgbvaluecolor
	if color then
		pushed:SetVertexColor(color.r * 1.5, color.g * 1.5, color.b * 1.5)
	end

	local highlight = button:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, 0.2)

	local disabled = button:GetDisabledTexture()
	if disabled then
		disabled:SetTexture(texture)
		disabled:SetDesaturated(true)
		disabled:SetInside(button.backdrop)
	end

	if button.FlashBorder then
		button.FlashBorder:SetInside(button.backdrop)

		if icons then
			button.FlashBorder:SetTexture(stock and (faction or stock.normal) or texture or character or nil)
		else
			button.FlashBorder:SetColorTexture(1, 1, 1, 0.2)
		end
	end

	if button.FlashContent then
		button.FlashContent:SetTexture()
	end

	if button.Flash then
		button.Flash:SetTexture()
	end
end

function AB:HandleMicroButton(button, name)
	assert(button, 'Invalid micro button name.')

	button:SetTemplate()
	button:SetParent(microBar)
	button:HookScript('OnEnter', onEnter)
	button:HookScript('OnLeave', onLeave)
	button:SetHitRectInsets(0, 0, 0, 0)

	if not E.Retail then
		AB.MICRO_CLASSIC[name] = {
			pushed = button:GetPushedTexture():GetTexture(),
			normal = button:GetNormalTexture():GetTexture()
		}
	end

	AB:UpdateMicroButtonTexture(name)
end

function AB:UpdateMicroButtonsParent()
	for _, x in next, AB.MICRO_BUTTONS do
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

		for _, name in next, AB.MICRO_BUTTONS do
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
		if db.enabled then
			E:EnableMover(microBar.mover.name)
		else
			E:DisableMover(microBar.mover.name)
		end
	end

	AB:UpdateMicroBarVisibility()
end

function AB:UpdateMicroButtonTexture(name)
	local button = _G[name]
	if not button then return end

	AB:HandleMicroTextures(button, name)
	AB:HandleMicroCoords(button, name)
end

function AB:UpdateMicroBarTextures()
	for _, name in next, AB.MICRO_BUTTONS do
		AB:UpdateMicroButtonTexture(name)
	end
end

function AB:SetupMicroBar()
	microBar:CreateBackdrop(AB.db.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, nil, 0)
	microBar:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 4, -48)
	microBar:EnableMouse(false)

	microBar.visibility = CreateFrame('Frame', nil, E.UIParent, 'SecureHandlerStateTemplate')
	microBar.visibility:SetScript('OnShow', function() microBar:Show() end)
	microBar.visibility:SetScript('OnHide', function() microBar:Hide() end)

	for _, name in next, AB.MICRO_BUTTONS do
		local button = _G[name]
		AB:HandleMicroButton(button, name)

		if name == 'MainMenuMicroButton' then
			hooksecurefunc(button, (E.Retail and 'SetHighlightAtlas') or (E.Classic and 'SetPushedTexture') or 'SetHighlightTexture', function()
				AB:UpdateMicroButtonTexture(name)
			end)
		end
	end

	-- With this method we might don't taint anything. Instead of using :Kill()
	local PerformanceBar = _G.MainMenuBarPerformanceBar or _G.MainMenuMicroButton.MainMenuBarPerformanceBar
	if PerformanceBar then
		PerformanceBar:SetAlpha(0)
		PerformanceBar:SetScale(0.00001)
	end

	AB:SecureHook('UpdateMicroButtons')

	if _G.ResetMicroMenuPosition then
		_G.ResetMicroMenuPosition()
	else
		AB:SecureHook('UpdateMicroButtonsParent')
		UpdateMicroButtonsParent(microBar)
	end

	if not E.Retail then
		hooksecurefunc('SetLookingForGroupUIAvailable', AB.UpdateMicroButtons)
	end

	if _G.MicroButtonPortrait then
		_G.MicroButtonPortrait:SetInside(_G.CharacterMicroButton)
	end

	if _G.PVPMicroButtonTexture then
		_G.PVPMicroButtonTexture:SetAlpha(0)
	end

	E:CreateMover(microBar, 'MicrobarMover', L["Micro Bar"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,microbar')
end
