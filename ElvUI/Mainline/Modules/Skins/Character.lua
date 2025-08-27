local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
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

local oldAtlas = {
	Options_ListExpand_Right = 1,
	Options_ListExpand_Right_Expanded = 1
}

local function UpdateCollapse(texture, atlas)
	if not atlas or oldAtlas[atlas] then
		local parent = texture:GetParent()
		if parent:IsCollapsed() then
			texture:SetAtlas('Soulbinds_Collection_CategoryHeader_Expand')
		else
			texture:SetAtlas('Soulbinds_Collection_CategoryHeader_Collapse')
		end
	end
end

local function UpdateTokenSkinsChild(child)
	if not child.IsSkinned then
		if child.Right then
			child:StripTextures()
			child:CreateBackdrop('Transparent')
			child.backdrop:SetInside(child)

			UpdateCollapse(child.Right)
			UpdateCollapse(child.HighlightRight)

			hooksecurefunc(child.Right, 'SetAtlas', UpdateCollapse)
			hooksecurefunc(child.HighlightRight, 'SetAtlas', UpdateCollapse)
		end

		local icon = child.Content and child.Content.CurrencyIcon
		if icon then
			S:HandleIcon(icon)
		end

		child.IsSkinned = true
	end

end

local function UpdateTokenSkins(frame)
	frame:ForEachFrame(UpdateTokenSkinsChild)
end

local function EquipmentManagerPane_UpdateChild(child)
	if child.icon and not child.IsSkinned then
		child.BgTop:SetTexture(E.ClearTexture)
		child.BgMiddle:SetTexture(E.ClearTexture)
		child.BgBottom:SetTexture(E.ClearTexture)
		S:HandleIcon(child.icon)
		child.HighlightBar:SetColorTexture(1, 1, 1, .25)
		child.HighlightBar:SetDrawLayer('BACKGROUND')
		child.SelectedBar:SetColorTexture(0.8, 0.8, 0.8, .25)
		child.SelectedBar:SetDrawLayer('BACKGROUND')

		child.IsSkinned = true
	end
end

local function EquipmentManagerPane_Update(frame)
	frame:ForEachFrame(EquipmentManagerPane_UpdateChild)
end

local function TitleManagerPane_UpdateChild(child)
	if not child.IsSkinned then
		child:DisableDrawLayer('BACKGROUND')
		child.IsSkinned = true
	end
end

local function TitleManagerPane_Update(frame)
	frame:ForEachFrame(TitleManagerPane_UpdateChild)
end

local function PaperDollItemSlotButtonUpdate(slot)
	local highlight = slot:GetHighlightTexture()
	highlight:SetTexture(E.Media.Textures.White8x8)
	highlight:SetVertexColor(1, 1, 1, .25)
	highlight:SetInside()
end

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

	for _, button in next, _G.EquipmentFlyoutFrame.buttons do
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
	local hasDejaCharacterStats = E.OtherAddons.DejaCharacterStats

	local index = 1
	local tab = _G['PaperDollSidebarTab'..index]
	while tab do
		if not tab.backdrop then
			tab:CreateBackdrop()
			tab.Icon:SetAllPoints()

			tab.Highlight:SetColorTexture(1, 1, 1, 0.3)
			tab.Highlight:SetAllPoints()

			if hasDejaCharacterStats then
				tab.Hider:SetTexture()
			else
				tab.Hider:SetColorTexture(0, 0, 0, 0.8)
			end

			tab.Hider:SetAllPoints(tab.backdrop)
			tab.TabBg:Kill()

			if index == 1 then
				for _, region in next, { tab:GetRegions() } do
					region:SetTexCoord(0.16, 0.86, 0.16, 0.86)

					hooksecurefunc(region, 'SetTexCoord', TabTextureCoords)
				end
			end
		end

		index = index + 1
		tab = _G['PaperDollSidebarTab'..index]
	end
end

local function UpdateFactionSkinsChild(child)
	if not child.IsSkinned then
		if child.Right then
			child:StripTextures()
			child:CreateBackdrop('Transparent')
			child.backdrop:SetInside(child)

			UpdateCollapse(child.Right)
			UpdateCollapse(child.HighlightRight)

			hooksecurefunc(child.Right, 'SetAtlas', UpdateCollapse)
			hooksecurefunc(child.HighlightRight, 'SetAtlas', UpdateCollapse)
		end

		local ReputationBar = child.Content and child.Content.ReputationBar
		if ReputationBar then
			ReputationBar:StripTextures()
			ReputationBar:SetStatusBarTexture(E.media.normTex)

			if not ReputationBar.backdrop then
				ReputationBar:CreateBackdrop()
				E:RegisterStatusBar(ReputationBar)
			end
		end

		child.IsSkinned = true
	end
end

local function UpdateFactionSkins(frame)
	frame:ForEachFrame(UpdateFactionSkinsChild)
end

local function PaperDollUpdateStats()
	for frame in _G.CharacterStatsPane.statsFramePool:EnumerateActive() do
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

function S:Blizzard_UIPanels_Game()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- General
	local CharacterFrame = _G.CharacterFrame
	S:HandlePortraitFrame(CharacterFrame)

	S:HandleTrimScrollBar(_G.ReputationFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.TokenFrame.ScrollBar, true) -- updates to this can taint transferring currencies

	for _, Slot in next, { _G.PaperDollItemsFrame:GetChildren() } do
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

	--Give character frame model backdrop it's color back
	for _, corner in next, { 'TopLeft', 'TopRight', 'BotLeft', 'BotRight' } do
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

	if not E.OtherAddons.DejaCharacterStats then
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

	for _, scrollbar in next, { _G.PaperDollFrame.EquipmentManagerPane.ScrollBar, _G.PaperDollFrame.TitleManagerPane.ScrollBar } do
		S:HandleTrimScrollBar(scrollbar)
	end

	for _, object in next, charframe do
		_G[object]:StripTextures()
	end

	--Re-add the overlay texture which was removed right above via StripTextures
	_G.CharacterModelFrameBackgroundOverlay:SetColorTexture(0, 0, 0)
	_G.CharacterModelScene:CreateBackdrop()
	_G.CharacterModelScene.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	_G.CharacterModelScene.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	S:HandleModelSceneControlButtons(_G.CharacterModelScene.ControlFrame)

	--Titles
	hooksecurefunc(_G.PaperDollFrame.TitleManagerPane.ScrollBox, 'Update', TitleManagerPane_Update)

	--Equipement Manager
	hooksecurefunc(_G.PaperDollFrame.EquipmentManagerPane.ScrollBox, 'Update', EquipmentManagerPane_Update)
	S:HandleButton(_G.PaperDollFrameEquipSet)
	S:HandleButton(_G.PaperDollFrameSaveSet)

	-- Icon selection frame
	_G.GearManagerPopupFrame:HookScript('OnShow', function(frame)
		if frame.IsSkinned then return end -- set by HandleIconSelectionFrame

		S:HandleIconSelectionFrame(frame)
	end)

	do --Handle Tabs at bottom of character frame
		local i = 1
		local tab, prev = _G['CharacterFrameTab'..i]
		while tab do
			S:HandleTab(tab)

			tab:ClearAllPoints()

			if prev then -- Reposition Tabs
				tab:Point('TOPLEFT', prev, 'TOPRIGHT', -5, 0)
			else
				tab:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', -3, 0)
			end

			prev = tab

			i = i + 1
			tab = _G['CharacterFrameTab'..i]
		end
	end

	-- Reputation Frame
	local ReputationFrame = _G.ReputationFrame
	ReputationFrame:StripTextures()
	S:HandleDropDownBox(ReputationFrame.filterDropdown)

	local DetailFrame = ReputationFrame.ReputationDetailFrame
	DetailFrame:StripTextures()
	DetailFrame:SetTemplate('Transparent')
	DetailFrame.CloseButton:StripTextures()
	S:HandleCloseButton(DetailFrame.CloseButton)
	S:HandleCheckBox(DetailFrame.AtWarCheckbox)
	S:HandleCheckBox(DetailFrame.MakeInactiveCheckbox)
	S:HandleCheckBox(DetailFrame.WatchFactionCheckbox)
	S:HandleButton(DetailFrame.ViewRenownButton)

	-- Currency Frame
	_G.TokenFramePopup:StripTextures()
	_G.TokenFramePopup:SetTemplate('Transparent')
	_G.TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 3, -28)

	S:HandleDropDownBox(_G.TokenFrame.filterDropdown)
	--S:HandleButton(_G.TokenFrame.CurrencyTransferLogToggleButton) -- No no no, this taints

	_G.TokenFrame.CurrencyTransferLogToggleButton.NormalTexture:SetTexture(E.Media.Textures.Copy)
	_G.TokenFrame.CurrencyTransferLogToggleButton.PushedTexture:SetTexture(E.Media.Textures.Copy)
	_G.TokenFrame.CurrencyTransferLogToggleButton.PushedTexture:SetVertexColor(unpack(E.media.rgbvaluecolor))

	S:HandlePortraitFrame(_G.CurrencyTransferLog)
	S:HandleCheckBox(_G.TokenFramePopup.InactiveCheckbox)
	S:HandleCheckBox(_G.TokenFramePopup.BackpackCheckbox)
	S:HandleButton(_G.TokenFramePopup.CurrencyTransferToggleButton)

	local TokenPopupClose = _G.TokenFramePopup['$parent.CloseButton']
	if TokenPopupClose then
		S:HandleCloseButton(TokenPopupClose)
	end

	-- Currency Transfer (new in 11.0)
	local currencyTransfer = _G.CurrencyTransferMenu
	currencyTransfer:StripTextures()
	currencyTransfer:SetTemplate('Transparent')
	S:HandleCloseButton(currencyTransfer.CloseButton)
	S:HandleDropDownBox(currencyTransfer.Content.SourceSelector.Dropdown)
	S:HandleEditBox(currencyTransfer.Content.AmountSelector.InputBox)
	S:HandleButton(currencyTransfer.Content.AmountSelector.MaxQuantityButton)
	S:HandleButton(currencyTransfer.Content.ConfirmButton)
	S:HandleButton(currencyTransfer.Content.CancelButton)

	hooksecurefunc(_G.ReputationFrame.ScrollBox, 'Update', UpdateFactionSkins)
	hooksecurefunc(_G.TokenFrame.ScrollBox, 'Update', UpdateTokenSkins)
	hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', FixSidebarTabCoords)
	hooksecurefunc('PaperDollItemSlotButton_Update', PaperDollItemSlotButtonUpdate)
	hooksecurefunc(_G.CharacterFrameMixin, 'ShowSubFrame', UpdateCharacterInset)
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game')
