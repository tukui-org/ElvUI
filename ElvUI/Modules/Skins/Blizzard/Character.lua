local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack, select = unpack, select
local pairs, ipairs, type = pairs, ipairs, type

local hooksecurefunc = hooksecurefunc
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local EquipmentManager_GetItemInfoByLocation = EquipmentManager_GetItemInfoByLocation

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

local function UpdateAzeriteItem(self)
	if not self.styled then
		self.styled = true

		self.AzeriteTexture:SetAlpha(0)
		self.RankFrame.Texture:SetTexture()
		self.RankFrame.Label:FontTemplate(nil, nil, 'OUTLINE')
	end
end

local function UpdateAzeriteEmpoweredItem(self)
	self.AzeriteTexture:SetAtlas('AzeriteIconFrame')
	self.AzeriteTexture:SetInside()
	self.AzeriteTexture:SetTexCoord(unpack(E.TexCoords))
	self.AzeriteTexture:SetDrawLayer('BORDER', 1)
end

local function ColorizeStatPane(frame)
	if frame.leftGrad then return end

	local r, g, b = 0.8, 0.8, 0.8
	frame.leftGrad = frame:CreateTexture(nil, 'BORDER')
	frame.leftGrad:Size(80, frame:GetHeight())
	frame.leftGrad:Point('LEFT', frame, 'CENTER')
	frame.leftGrad:SetTexture(E.Media.Textures.White8x8)
	frame.leftGrad:SetGradientAlpha('Horizontal', r, g, b, 0.25, r, g, b, 0)

	frame.rightGrad = frame:CreateTexture(nil, 'BORDER')
	frame.rightGrad:Size(80, frame:GetHeight())
	frame.rightGrad:Point('RIGHT', frame, 'CENTER')
	frame.rightGrad:SetTexture(E.Media.Textures.White8x8)
	frame.rightGrad:SetGradientAlpha('Horizontal', r, g, b, 0, r, g, b, 0.25)
end

local function StatsPane(which)
	local CharacterStatsPane = _G.CharacterStatsPane
	CharacterStatsPane[which]:StripTextures()
	CharacterStatsPane[which]:CreateBackdrop('Transparent')
	CharacterStatsPane[which].backdrop:ClearAllPoints()
	CharacterStatsPane[which].backdrop:Point('CENTER')
	CharacterStatsPane[which].backdrop:Size(150, 18)
end

local function EquipmentUpdateItems()
	local anchor = _G.EquipmentFlyoutFrame.buttonFrame
	if not anchor.template then
		anchor:StripTextures()
		anchor:SetTemplate('Transparent')
	end

	local width, height = anchor:GetSize()
	anchor:Size(width+3, height)
end

local function EquipmentDisplayButton(button)
	local location, border = button.location, button.IconBorder
	if not location or not border then return end

	local id = button.id or button:GetID()
	if not id then return end

	if not button.isHooked then
		local oldTex = button.icon:GetTexture()
		button:StripTextures()
		button:SetTemplate()
		button:StyleButton(false)
		button:GetNormalTexture():SetTexture()

		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:SetTexture(oldTex)

		S:HandleIconBorder(button.IconBorder)

		button.isHooked = true
	end

	local r, g, b, a = unpack(E.media.bordercolor)
	if FLYOUT_LOCATIONS[location] then -- special slots
		button:SetBackdropBorderColor(r, g, b, a)
	else
		local quality = select(13, EquipmentManager_GetItemInfoByLocation(location))
		if not quality or quality == 0 then
			button:SetBackdropBorderColor(r, g, b, a)
		else
			local color = ITEM_QUALITY_COLORS[quality]
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		end
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
				for x=1, tab:GetNumRegions() do
					local region = select(x, tab:GetRegions())
					region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
					hooksecurefunc(region, 'SetTexCoord', function(self, x1)
						if x1 ~= 0.16001 then
							self:SetTexCoord(0.16001, 0.86, 0.16, 0.86)
						end
					end)
				end
			end
		end
	end
end

local function UpdateFactionSkins()
	_G.ReputationListScrollFrame:StripTextures()
	_G.ReputationFrame:StripTextures(true)

	for i = 1, _G.NUM_FACTIONS_DISPLAYED, 1 do
		local statusbar = _G['ReputationBar'..i..'ReputationBar']
		if statusbar then
			statusbar:SetStatusBarTexture(E.media.normTex)

			if not statusbar.backdrop then
				statusbar:CreateBackdrop()
				E:RegisterStatusBar(statusbar)
			end

			_G['ReputationBar'..i..'Background']:SetTexture()
			_G['ReputationBar'..i..'ReputationBarHighlight1']:SetTexture()
			_G['ReputationBar'..i..'ReputationBarHighlight2']:SetTexture()
			_G['ReputationBar'..i..'ReputationBarAtWarHighlight1']:SetTexture()
			_G['ReputationBar'..i..'ReputationBarAtWarHighlight2']:SetTexture()
			_G['ReputationBar'..i..'ReputationBarLeftTexture']:SetTexture()
			_G['ReputationBar'..i..'ReputationBarRightTexture']:SetTexture()
		end
	end

	local ReputationDetailFrame = _G.ReputationDetailFrame
	ReputationDetailFrame:ClearAllPoints()
	ReputationDetailFrame:Point('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', 4, -28)
	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:SetTemplate('Transparent')
end

local function UpdateCurrencySkins()
	local TokenFramePopup = _G.TokenFramePopup

	if TokenFramePopup then
		TokenFramePopup:ClearAllPoints()
		TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 4, -28)
		TokenFramePopup:StripTextures()
		TokenFramePopup:SetTemplate('Transparent')
	end

	local TokenFrameContainer = _G.TokenFrameContainer
	if not TokenFrameContainer.buttons then return end

	local buttons = TokenFrameContainer.buttons
	local numButtons = #buttons

	for i=1, numButtons do
		local button = buttons[i]

		if button then
			if button.highlight then button.highlight:Kill() end
			if button.categoryLeft then button.categoryLeft:Kill() end
			if button.categoryRight then button.categoryRight:Kill() end
			if button.categoryMiddle then button.categoryMiddle:Kill() end

			if not button.backdrop then
				button:CreateBackdrop(nil, nil, nil, true)
			end

			if button.icon then
				button.icon:SetTexCoord(unpack(E.TexCoords))
				button.icon:Size(17, 17)

				button.backdrop:SetOutside(button.icon, 1, 1)
				button.backdrop:Show()
			else
				button.backdrop:Hide()
			end

			if button.expandIcon then
				if not button.highlightTexture then
					button.highlightTexture = button:CreateTexture(button:GetName()..'HighlightTexture', 'HIGHLIGHT')
					button.highlightTexture:SetTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
					button.highlightTexture:SetBlendMode('ADD')
					button.highlightTexture:SetInside(button.expandIcon)

					-- these two only need to be called once
					-- adding them here will prevent additional calls
					button.expandIcon:Point('LEFT', 4, 0)
					button.expandIcon:Size(15, 15)
				end

				if button.isHeader then
					button.backdrop:Hide()

					if button.isExpanded then
						button.expandIcon:SetTexture(E.Media.Textures.MinusButton)
						button.expandIcon:SetTexCoord(0,1,0,1)
					else
						button.expandIcon:SetTexture(E.Media.Textures.PlusButton)
						button.expandIcon:SetTexCoord(0,1,0,1)
					end

					button.highlightTexture:Show()
				else
					button.highlightTexture:Hide()
				end
			end
		end
	end
end

function S:CharacterFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- General
	local CharacterFrame = _G.CharacterFrame
	S:HandlePortraitFrame(CharacterFrame)
	S:HandleScrollBar(_G.ReputationListScrollFrameScrollBar)
	S:HandleScrollBar(_G.TokenFrameContainerScrollBar)
	S:HandleScrollBar(_G.GearManagerDialogPopupScrollFrameScrollBar)

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
			hooksecurefunc(bg, 'SetDesaturated', function(bckgnd, value)
				if value and bckgnd.ignoreDesaturated then
					bckgnd:SetDesaturated(false)
				end
			end)
		end
	end

	_G.CharacterLevelText:FontTemplate()
	_G.CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)
	_G.CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
	ColorizeStatPane(_G.CharacterStatsPane.ItemLevelFrame)

	hooksecurefunc('PaperDollFrame_UpdateStats', function()
		if E:IsAddOnEnabled('DejaCharacterStats') then return end

		for _, Table in ipairs({_G.CharacterStatsPane.statsFramePool:EnumerateActive()}) do
			if type(Table) == 'table' then
				for statFrame in pairs(Table) do
					ColorizeStatPane(statFrame)
					if statFrame.Background:IsShown() then
						statFrame.leftGrad:Show()
						statFrame.rightGrad:Show()
					else
						statFrame.leftGrad:Hide()
						statFrame.rightGrad:Hide()
					end
				end
			end
		end
	end)

	if not E:IsAddOnEnabled('DejaCharacterStats') then
		StatsPane('EnhancementsCategory')
		StatsPane('ItemLevelCategory')
		StatsPane('AttributesCategory')
	end

	--Strip Textures
	local charframe = {
		'CharacterModelFrame',
		'CharacterStatsPane',
		'CharacterFrameInset',
		'CharacterFrameInsetRight',
		'PaperDollSidebarTabs',
		'PaperDollEquipmentManagerPane',
	}

	S:HandleCloseButton(_G.ReputationDetailCloseButton)
	S:HandleCloseButton(_G.TokenFramePopupCloseButton)

	S:HandleCheckBox(_G.ReputationDetailAtWarCheckBox)
	S:HandleCheckBox(_G.ReputationDetailMainScreenCheckBox)
	S:HandleCheckBox(_G.ReputationDetailInactiveCheckBox)
	--S:HandleCheckBox(_G.ReputationDetailLFGBonusReputationCheckBox)
	S:HandleCheckBox(_G.TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(_G.TokenFramePopupBackpackCheckBox)

	_G.EquipmentFlyoutFrameHighlight:StripTextures()
	_G.EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
	_G.EquipmentFlyoutFrameButtons:DisableDrawLayer('ARTWORK')
	_G.EquipmentFlyoutFrame.NavigationFrame:StripTextures()
	_G.EquipmentFlyoutFrame.NavigationFrame:SetTemplate('Transparent')
	_G.EquipmentFlyoutFrame.NavigationFrame:Point('TOPLEFT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMLEFT', 0, -E.Border - E.Spacing)
	_G.EquipmentFlyoutFrame.NavigationFrame:Point('TOPRIGHT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMRIGHT', 0, -E.Border - E.Spacing)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.NextButton)

	--Swap item flyout frame (shown when holding alt over a slot)
	hooksecurefunc('EquipmentFlyout_UpdateItems', EquipmentUpdateItems)
	hooksecurefunc('EquipmentFlyout_DisplayButton', EquipmentDisplayButton)

	--Icon in upper right corner of character frame
	_G.CharacterFramePortrait:Kill()

	local scrollbars = {
		'PaperDollTitlesPaneScrollBar',
		'PaperDollEquipmentManagerPaneScrollBar',
	}

	for _, scrollbar in pairs(scrollbars) do
		S:HandleScrollBar(_G[scrollbar], 5)
	end

	for _, object in pairs(charframe) do
		_G[object]:StripTextures()
	end

	--Re-add the overlay texture which was removed right above via StripTextures
	_G.CharacterModelFrameBackgroundOverlay:SetColorTexture(0, 0, 0)
	_G.CharacterModelFrame:CreateBackdrop()
	_G.CharacterModelFrame.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	_G.CharacterModelFrame.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	local controlButtons = {
		'CharacterModelFrameControlFrameZoomInButton',
		'CharacterModelFrameControlFrameZoomOutButton',
		'CharacterModelFrameControlFrameRotateLeftButton',
		'CharacterModelFrameControlFrameRotateRightButton',
		'CharacterModelFrameControlFrameRotateResetButton',
	}

	_G.CharacterModelFrameControlFrame:StripTextures()
	_G.CharacterFrameInset:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, true)

	for _, button in pairs(controlButtons) do
		S:HandleButton(_G[button])
	end

	--Titles
	_G.PaperDollTitlesPane:HookScript('OnShow', function()
		for _, object in pairs(_G.PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture()
			object.BgBottom:SetTexture()
			object.BgMiddle:SetTexture()
			object.text:FontTemplate()

			if not object.text.hooked then
				object.text.hooked = true

				hooksecurefunc(object.text, 'SetFont', function(txt, font)
					if font ~= E.media.normFont then
						txt:FontTemplate()
					end
				end)
			end
		end
	end)

	--Equipement Manager
	S:HandleButton(_G.PaperDollEquipmentManagerPaneEquipSet)
	S:HandleButton(_G.PaperDollEquipmentManagerPaneSaveSet)
	_G.PaperDollEquipmentManagerPaneEquipSet:Width(_G.PaperDollEquipmentManagerPaneEquipSet:GetWidth() - 8)
	_G.PaperDollEquipmentManagerPaneSaveSet:Width(_G.PaperDollEquipmentManagerPaneSaveSet:GetWidth() - 8)
	_G.PaperDollEquipmentManagerPaneEquipSet:Point('TOPLEFT', _G.PaperDollEquipmentManagerPane, 'TOPLEFT', 8, 0)
	_G.PaperDollEquipmentManagerPaneSaveSet:Point('LEFT', _G.PaperDollEquipmentManagerPaneEquipSet, 'RIGHT', 4, 0)

	--Itemset buttons
	for _, object in pairs(_G.PaperDollEquipmentManagerPane.buttons) do
		object.BgTop:SetTexture()
		object.BgBottom:SetTexture()
		object.BgMiddle:SetTexture()
		object.HighlightBar:Kill()
		object.Stripe:Kill()

		object.SelectedBar:SetTexture(E.media.normTex)
		object.SelectedBar:SetVertexColor(1, 1, 1, 0.20)
		object.SelectedBar:SetInside(object, 4, 3)

		S:HandleButton(object, nil, nil, nil, nil, 'Transparent')

		object.icon:Point('LEFT', object, 6, 0)
		object.icon:SetTexCoord(unpack(E.TexCoords))
		object.icon:CreateBackdrop(nil, nil, nil, true)

		hooksecurefunc(object.icon, 'SetPoint', function(icn, _, _, _, _, _, forced)
			if forced ~= true then
				icn:Point('LEFT', object, 'LEFT', 6, 0, true)
			end
		end)

		hooksecurefunc(object.icon, 'SetSize', function(icn, width, height)
			if width == 36 or height == 36 then -- items
				icn:Size(32, 32)
			elseif width == 30 or height == 30 then -- new set
				icn:Size(32, 32)
			end
		end)
	end

	--Icon selection frame
	S:HandleIconSelectionFrame(_G.GearManagerDialogPopup, _G.NUM_GEARSET_ICONS_SHOWN, 'GearManagerDialogPopupButton')
	S:HandleButton(_G.GearManagerDialogPopupOkay)
	S:HandleButton(_G.GearManagerDialogPopupCancel)
	S:HandleEditBox(_G.GearManagerDialogPopupEditBox)

	for i = 1, _G.NUM_FACTIONS_DISPLAYED do
		local bu = _G['ReputationBar'..i..'ExpandOrCollapseButton']
		if bu then S:HandleCollapseTexture(bu) end
	end

	do --Handle Tabs at bottom of character frame
		local i = 1
		local tab = _G['CharacterFrameTab'..i]
		while tab do
			S:HandleTab(tab)

			i = i + 1
			tab = _G['CharacterFrameTab'..i]
		end
	end

	hooksecurefunc('ExpandFactionHeader', UpdateFactionSkins)
	hooksecurefunc('CollapseFactionHeader', UpdateFactionSkins)
	hooksecurefunc('ReputationFrame_Update', UpdateFactionSkins)

	--Buttons used to toggle between equipment manager, titles, and character stats
	hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', FixSidebarTabCoords)

	--Currency
	hooksecurefunc('TokenFrame_Update', UpdateCurrencySkins)
	hooksecurefunc(_G.TokenFrameContainer, 'update', UpdateCurrencySkins)

	hooksecurefunc('CharacterFrame_ShowSubFrame', UpdateCharacterInset)
end

S:AddCallback('CharacterFrame')
