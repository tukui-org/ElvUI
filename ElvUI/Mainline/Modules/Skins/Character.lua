local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, ipairs = pairs, ipairs
local unpack, next = unpack, next
local hooksecurefunc = hooksecurefunc
local CreateColor = CreateColor

local FLYOUT_LOCATIONS = {
	[0xFFFFFFFF] = 'PLACEINBAGS',
	[0xFFFFFFFE] = 'IGNORESLOT',
	[0xFFFFFFFD] = 'UNIGNORESLOT'
}

local showInsetBackdrop = {
	ReputationFrame = true,
	TokenFrame = true
}

local function UpdateCharacterInset(name)
	_G.CharacterFrameInset.backdrop:SetShown(showInsetBackdrop[name])
end

local function UpdateAzeriteItem(item)
	if not item.IsSkinned then
		item.IsSkinned = true

		item.AzeriteTexture:SetAlpha(0)
		item.RankFrame.Texture:SetTexture()
		item.RankFrame.Label:FontTemplate(nil, nil, 'OUTLINE')
	end
end

local function UpdateAzeriteEmpoweredItem(item)
	item.AzeriteTexture:SetAtlas('AzeriteIconFrame')
	item.AzeriteTexture:SetInside()
	item.AzeriteTexture:SetTexCoord(unpack(E.TexCoords))
	item.AzeriteTexture:SetDrawLayer('BORDER', 1)
end

local function ColorizeStatPane(frame)
	frame.Background:SetAlpha(0)

	local r, g, b = 0.8, 0.8, 0.8
	local gradientFrom, gradientTo = CreateColor(r, g, b, 0.25), CreateColor(r, g, b, 0)

	frame.leftGrad = frame:CreateTexture(nil, 'BORDER')
	frame.leftGrad:Size(80, frame:GetHeight())
	frame.leftGrad:Point('LEFT', frame, 'CENTER')
	frame.leftGrad:SetTexture(E.Media.Textures.White8x8)
	frame.leftGrad:SetGradient('Horizontal', gradientFrom, gradientTo)

	frame.rightGrad = frame:CreateTexture(nil, 'BORDER')
	frame.rightGrad:Size(80, frame:GetHeight())
	frame.rightGrad:Point('RIGHT', frame, 'CENTER')
	frame.rightGrad:SetTexture(E.Media.Textures.White8x8)
	frame.rightGrad:SetGradient('Horizontal', gradientTo, gradientFrom)
end

local function StatsPane(which)
	local CharacterStatsPane = _G.CharacterStatsPane
	CharacterStatsPane[which]:StripTextures()
	CharacterStatsPane[which]:CreateBackdrop('Transparent')
	CharacterStatsPane[which].backdrop:ClearAllPoints()
	CharacterStatsPane[which].backdrop:Point('CENTER')
	CharacterStatsPane[which].backdrop:Size(150, 18)
end

local function EquipmentDisplayButton(button)
	if not button.isHooked then
		button:SetNormalTexture(E.ClearTexture)
		button:SetPushedTexture(E.ClearTexture)
		button:SetTemplate()
		button:StyleButton()

		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(E.TexCoords))

		S:HandleIconBorder(button.IconBorder)

		button.isHooked = true
	end

	if FLYOUT_LOCATIONS[button.location] then -- special slots
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function EquipmentUpdateItems()
	local frame = _G.EquipmentFlyoutFrame.buttonFrame
	if not frame.template then
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	local width, height = frame:GetSize()
	frame:Size(width+3, height)

	for _, button in ipairs(_G.EquipmentFlyoutFrame.buttons) do
		EquipmentDisplayButton(button)
	end
end

local function EquipmentUpdateNavigation()
	local navi = _G.EquipmentFlyoutFrame.NavigationFrame
	if not navi then return end

	navi:ClearAllPoints()
	navi:Point('TOPLEFT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMLEFT', 0, -E.Border - E.Spacing)
	navi:Point('TOPRIGHT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMRIGHT', 0, -E.Border - E.Spacing)

	navi:StripTextures()
	navi:SetTemplate('Transparent')
end

local function TabTextureCoords(tex, x1)
	if x1 ~= 0.16001 then
		tex:SetTexCoord(0.16001, 0.86, 0.16, 0.86)
	end
end

local function FixSidebarTabCoords()
	for i=1, #_G.PAPERDOLL_SIDEBARS do
		local tab = _G['PaperDollSidebarTab'..i]

		if tab and not tab.backdrop then
			tab:CreateBackdrop()
			tab.Icon:SetAllPoints()
			tab.Highlight:SetColorTexture(1, 1, 1, 0.3)
			tab.Highlight:SetAllPoints()

			-- Check for DejaCharacterStats. Lets hide the Texture if the AddOn is loaded.
			if E:IsAddOnEnabled('DejaCharacterStats') then
				tab.Hider:SetTexture()
			else
				tab.Hider:SetColorTexture(0, 0, 0, 0.8)
			end

			tab.Hider:SetAllPoints(tab.backdrop)
			tab.TabBg:Kill()

			if i == 1 then
				for _, region in next, { tab:GetRegions() } do
					region:SetTexCoord(0.16, 0.86, 0.16, 0.86)

					hooksecurefunc(region, 'SetTexCoord', TabTextureCoords)
				end
			end
		end
	end
end

local function UpdateFactionSkins(frame)
	for _, child in next, { frame.ScrollTarget:GetChildren() } do
		local container = child.Container
		if container and not container.IsSkinned then
			container.IsSkinned = true

			container:StripTextures()

			if container.ExpandOrCollapseButton then
				S:HandleCollapseTexture(container.ExpandOrCollapseButton)
			end

			if container.ReputationBar then
				container.ReputationBar:StripTextures()
				container.ReputationBar:SetStatusBarTexture(E.media.normTex)

				if not container.ReputationBar.backdrop then
					container.ReputationBar:CreateBackdrop()
					E:RegisterStatusBar(container.ReputationBar)
				end
			end
		end
	end
end

local function PaperDollUpdateStats()
	local _, stats = _G.CharacterStatsPane.statsFramePool:EnumerateActive()
	if not stats then return end

	for frame in pairs(stats) do
		if not frame.leftGrad then
			ColorizeStatPane(frame)
		end

		local shown = frame.Background:IsShown()
		frame.leftGrad:SetShown(shown)
		frame.rightGrad:SetShown(shown)
	end
end

local function BackdropDesaturated(background, value)
	if value and background.ignoreDesaturated then
		background:SetDesaturated(false)
	end
end

function S:CharacterFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- General
	local CharacterFrame = _G.CharacterFrame
	S:HandlePortraitFrame(CharacterFrame)

	S:HandleTrimScrollBar(_G.ReputationFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.TokenFrame.ScrollBar)

	for _, Slot in pairs({_G.PaperDollItemsFrame:GetChildren()}) do
		if Slot:IsObjectType('Button') or Slot:IsObjectType('ItemButton') then
			S:HandleIcon(Slot.icon)
			Slot:StripTextures()
			Slot:SetTemplate()
			Slot:StyleButton(Slot)
			Slot.icon:SetInside()
			Slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])

			S:HandleIconBorder(Slot.IconBorder)

			if Slot.popoutButton:GetPoint() == 'TOP' then
				Slot.popoutButton:Point('TOP', Slot, 'BOTTOM', 0, 2)
			else
				Slot.popoutButton:Point('LEFT', Slot, 'RIGHT', -2, 0)
			end

			E:RegisterCooldown(_G[Slot:GetName()..'Cooldown'])
			hooksecurefunc(Slot, 'DisplayAsAzeriteItem', UpdateAzeriteItem)
			hooksecurefunc(Slot, 'DisplayAsAzeriteEmpoweredItem', UpdateAzeriteEmpoweredItem)
		end
	end

	hooksecurefunc('PaperDollItemSlotButton_Update', function(slot)
		local highlight = slot:GetHighlightTexture()
		highlight:SetTexture(E.Media.Textures.White8x8)
		highlight:SetVertexColor(1, 1, 1, .25)
		highlight:SetInside()
	end)

	--Give character frame model backdrop it's color back
	for _, corner in pairs({'TopLeft','TopRight','BotLeft','BotRight'}) do
		local bg = _G['CharacterModelFrameBackground'..corner]
		if bg then
			bg:SetDesaturated(false)
			bg.ignoreDesaturated = true -- so plugins can prevent this if they want.

			hooksecurefunc(bg, 'SetDesaturated', BackdropDesaturated)
		end
	end

	_G.CharacterLevelText:FontTemplate()
	_G.CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)
	ColorizeStatPane(_G.CharacterStatsPane.ItemLevelFrame)

	if not E:IsAddOnEnabled('DejaCharacterStats') then
		hooksecurefunc('PaperDollFrame_UpdateStats', PaperDollUpdateStats)

		StatsPane('EnhancementsCategory')
		StatsPane('ItemLevelCategory')
		StatsPane('AttributesCategory')
	end

	--Strip Textures
	local charframe = {
		'CharacterModelScene',
		'CharacterStatsPane',
		'CharacterFrameInset',
		'CharacterFrameInsetRight',
		'PaperDollSidebarTabs',
	}

	_G.EquipmentFlyoutFrameHighlight:StripTextures()
	_G.EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
	_G.EquipmentFlyoutFrameButtons:DisableDrawLayer('ARTWORK')

	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.NextButton)

	hooksecurefunc('EquipmentFlyout_SetBackgroundTexture', EquipmentUpdateNavigation)
	hooksecurefunc('EquipmentFlyout_UpdateItems', EquipmentUpdateItems) -- Swap item flyout frame (shown when holding alt over a slot)

	-- Icon in upper right corner of character frame
	_G.CharacterFramePortrait:Kill()

	for _, scrollbar in pairs({ _G.PaperDollFrame.EquipmentManagerPane.ScrollBar, _G.PaperDollFrame.TitleManagerPane.ScrollBar }) do
		S:HandleTrimScrollBar(scrollbar)
	end

	for _, object in pairs(charframe) do
		_G[object]:StripTextures()
	end

	--Re-add the overlay texture which was removed right above via StripTextures
	_G.CharacterModelFrameBackgroundOverlay:SetColorTexture(0, 0, 0)
	_G.CharacterModelScene:CreateBackdrop()
	_G.CharacterModelScene.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	_G.CharacterModelScene.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	_G.CharacterFrameInset:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, true)

	for _, button in pairs({
		'CharacterModelSceneZoomInButton',
		'CharacterModelSceneZoomOutButton',
		'CharacterModelSceneRotateLeftButton',
		'CharacterModelSceneRotateRightButton',
		'CharacterModelSceneRotateResetButton',
	}) do
		S:HandleButton(_G[button])
	end

	--Titles
	hooksecurefunc(_G.PaperDollFrame.TitleManagerPane.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				child:DisableDrawLayer('BACKGROUND')
				child.isSkinned = true
			end
		end
	end)

	--Equipement Manager
	S:HandleButton(_G.PaperDollFrameEquipSet)
	S:HandleButton(_G.PaperDollFrameSaveSet)

	hooksecurefunc(_G.PaperDollFrame.EquipmentManagerPane.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if child.icon and not child.isSkinned then
				child.BgTop:SetTexture('')
				child.BgMiddle:SetTexture('')
				child.BgBottom:SetTexture('')
				S:HandleIcon(child.icon)
				child.HighlightBar:SetColorTexture(1, 1, 1, .25)
				child.HighlightBar:SetDrawLayer('BACKGROUND')
				child.SelectedBar:SetColorTexture(0.8, 0.8, 0.8, .25)
				child.SelectedBar:SetDrawLayer('BACKGROUND')

				child.isSkinned = true
			end
		end
	end)

	-- Icon selection frame
	_G.GearManagerPopupFrame:HookScript('OnShow', function(frame)
		if frame.isSkinned then return end
		S:HandleIconSelectionFrame(frame)
	end)

	-- Reposition Tabs
	_G.CharacterFrameTab1:ClearAllPoints()
	_G.CharacterFrameTab2:ClearAllPoints()
	_G.CharacterFrameTab3:ClearAllPoints()
	_G.CharacterFrameTab1:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', -3, 0)
	_G.CharacterFrameTab2:Point('TOPLEFT', _G.CharacterFrameTab1, 'TOPRIGHT', -5, 0)
	_G.CharacterFrameTab3:Point('TOPLEFT', _G.CharacterFrameTab2, 'TOPRIGHT', -5, 0)

	do --Handle Tabs at bottom of character frame
		local i = 1
		local tab = _G['CharacterFrameTab'..i]
		while tab do
			S:HandleTab(tab)

			i = i + 1
			tab = _G['CharacterFrameTab'..i]
		end
	end

	-- Reputation Frame
	_G.ReputationDetailFrame:StripTextures()
	_G.ReputationDetailFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.ReputationDetailCloseButton)
	S:HandleCheckBox(_G.ReputationDetailAtWarCheckBox)
	S:HandleCheckBox(_G.ReputationDetailMainScreenCheckBox)
	S:HandleCheckBox(_G.ReputationDetailInactiveCheckBox)
	S:HandleButton(_G.ReputationDetailViewRenownButton)

	hooksecurefunc(_G.ReputationFrame.ScrollBox, 'Update', UpdateFactionSkins)

	-- Currency Frame
	_G.TokenFramePopup:StripTextures()
	_G.TokenFramePopup:SetTemplate('Transparent')
	if _G.TokenFramePopup.CloseButton then  -- Probably Blizzard Typo
		S:HandleCloseButton(_G.TokenFramePopup.CloseButton)
	end
	_G.TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 3, -28)
	S:HandleCheckBox(_G.TokenFramePopup.InactiveCheckBox)
	S:HandleCheckBox(_G.TokenFramePopup.BackpackCheckBox)

	hooksecurefunc(_G.TokenFrame.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if child.Highlight and not child.IsSkinned then
				child.CategoryLeft:SetAlpha(0)
				child.CategoryRight:SetAlpha(0)
				child.CategoryMiddle:SetAlpha(0)

				child.Highlight:SetInside()
				child.Highlight.SetPoint = E.noop
				child.Highlight:SetColorTexture(1, 1, 1, .25)
				child.Highlight.SetTexture = E.noop

				S:HandleIcon(child.Icon)

				if child.ExpandIcon then
					child.ExpandIcon:CreateBackdrop('Transparent')
					child.ExpandIcon.backdrop:SetInside(3, 3)
				end

				child.IsSkinned = true
			end

			if child.isHeader then
				child.ExpandIcon.backdrop:Show()
			else
				child.ExpandIcon.backdrop:Hide()
			end
		end
	end)

	--Buttons used to toggle between equipment manager, titles, and character stats
	hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', FixSidebarTabCoords)

	hooksecurefunc('CharacterFrame_ShowSubFrame', UpdateCharacterInset)
end

S:AddCallback('CharacterFrame')
