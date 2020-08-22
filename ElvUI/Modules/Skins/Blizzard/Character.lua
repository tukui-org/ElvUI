local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack, select = unpack, select
local pairs, ipairs, type = pairs, ipairs, type

local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetContainerItemLink = GetContainerItemLink
local GetInventoryItemLink = GetInventoryItemLink
local GetFactionInfo = GetFactionInfo
local GetNumFactions = GetNumFactions
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local IsCorruptedItem = IsCorruptedItem

local PLACEINBAGS_LOCATION = 0xFFFFFFFF
local IGNORESLOT_LOCATION = 0xFFFFFFFE
local UNIGNORESLOT_LOCATION = 0xFFFFFFFD

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
	frame.leftGrad:SetWidth(80)
	frame.leftGrad:SetHeight(frame:GetHeight())
	frame.leftGrad:SetPoint('LEFT', frame, 'CENTER')
	frame.leftGrad:SetTexture(E.Media.Textures.White8x8)
	frame.leftGrad:SetGradientAlpha('Horizontal', r, g, b, 0.25, r, g, b, 0)

	frame.rightGrad = frame:CreateTexture(nil, 'BORDER')
	frame.rightGrad:SetWidth(80)
	frame.rightGrad:SetHeight(frame:GetHeight())
	frame.rightGrad:SetPoint('RIGHT', frame, 'CENTER')
	frame.rightGrad:SetTexture(E.Media.Textures.White8x8)
	frame.rightGrad:SetGradientAlpha('Horizontal', r, g, b, 0, r, g, b, 0.25)
end

local function StatsPane(which)
	local CharacterStatsPane = _G.CharacterStatsPane
	CharacterStatsPane[which]:StripTextures()
	CharacterStatsPane[which]:CreateBackdrop('Transparent')
	CharacterStatsPane[which].backdrop:ClearAllPoints()
	CharacterStatsPane[which].backdrop:SetPoint('CENTER')
	CharacterStatsPane[which].backdrop:SetWidth(150)
	CharacterStatsPane[which].backdrop:SetHeight(18)
end

local function SkinItemFlyouts()
	local flyout = _G.EquipmentFlyoutFrame
	local buttons = flyout.buttons
	local buttonAnchor = flyout.buttonFrame

	if not buttonAnchor.template then
		buttonAnchor:StripTextures()
		buttonAnchor:SetTemplate('Transparent')
	end

	for i, button in ipairs(buttons) do
		if buttonAnchor['bg'..i] and buttonAnchor['bg'..i]:GetTexture() ~= nil then
			buttonAnchor['bg'..i]:SetTexture()
		end

		if not button.isHooked then
			button.isHooked = true
			button:StyleButton(false)
			button:GetNormalTexture():SetTexture()

			button.icon:SetInside()
			button.icon:SetTexCoord(unpack(E.TexCoords))

			if not button.backdrop then
				button:SetFrameLevel(buttonAnchor:GetFrameLevel()+2)
				button:CreateBackdrop()
				button.backdrop:SetAllPoints()

				if i ~= 1 then -- dont call this intially on placeInBags button
					button.backdrop:SetBackdropBorderColor(button.IconBorder:GetVertexColor())
				end

				if i == 1 or i == 2 then
					hooksecurefunc(button.icon, 'SetTexture', function(self)
						local loc = self:GetParent().location
						if (loc == PLACEINBAGS_LOCATION) or (loc == IGNORESLOT_LOCATION) or (loc == UNIGNORESLOT_LOCATION) then
							self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end)
				end

				button.IconBorder:SetTexture()
				hooksecurefunc(button.IconBorder, 'SetVertexColor', function(self, r, g, b)
					self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
					self:SetTexture()
				end)
				hooksecurefunc(button.IconBorder, 'Hide', function(self)
					self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end)
			end
		end
	end

	local width, height = buttonAnchor:GetSize()
	buttonAnchor:SetSize(width+3, height)
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
			if IsAddOnLoaded('DejaCharacterStats') then
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

	local factionOffset = FauxScrollFrame_GetOffset(_G.ReputationListScrollFrame)
	local numFactions = GetNumFactions()

	for i = 1, _G.NUM_FACTIONS_DISPLAYED, 1 do
		local statusbar = _G['ReputationBar'..i..'ReputationBar']
		local button = _G['ReputationBar'..i..'ExpandOrCollapseButton']
		local factionIndex = factionOffset + i
		local _, _, _, _, _, _, _, _, _, isCollapsed = GetFactionInfo(factionIndex)
		if factionIndex <= numFactions then
			if button then
				if isCollapsed then
					button:SetNormalTexture(E.Media.Textures.PlusButton)
				else
					button:SetNormalTexture(E.Media.Textures.MinusButton)
				end
			end
		end

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
	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:ClearAllPoints()
	ReputationDetailFrame:SetPoint('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', 4, -28)
	if not ReputationDetailFrame.backdrop then
		ReputationDetailFrame:CreateBackdrop('Transparent')
	end
end

local function UpdateCurrencySkins()
	local TokenFramePopup = _G.TokenFramePopup

	if TokenFramePopup then
		TokenFramePopup:StripTextures()
		TokenFramePopup:ClearAllPoints()
		TokenFramePopup:SetPoint('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 4, -28)
		if not TokenFramePopup.backdrop then
			TokenFramePopup:CreateBackdrop('Transparent')
		end
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

			if button.icon then
				button.icon:SetTexCoord(unpack(E.TexCoords))
			end

			if button.expandIcon then
				if not button.highlightTexture then
					button.highlightTexture = button:CreateTexture(button:GetName()..'HighlightTexture', 'HIGHLIGHT')
					button.highlightTexture:SetTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
					button.highlightTexture:SetBlendMode('ADD')
					button.highlightTexture:SetInside(button.expandIcon)

					-- these two only need to be called once
					-- adding them here will prevent additional calls
					button.expandIcon:SetPoint('LEFT', 4, 0)
					button.expandIcon:SetSize(15, 15)
				end

				if button.isHeader then
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

local function CorruptionIcon(self)
	local itemLink = GetInventoryItemLink('player', self:GetID())
	self.IconOverlay:SetShown(itemLink and IsCorruptedItem(itemLink))
end

local function UpdateCorruption(button, location)
	local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
	if voidStorage then
		button.Eye:Hide()
		return
	end

	local itemLink
	if bags then
		itemLink = GetContainerItemLink(bag, slot)
	else
		itemLink = GetInventoryItemLink('player', slot)
	end
	button.Eye:SetShown(itemLink and IsCorruptedItem(itemLink))
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
			Slot.CorruptedHighlightTexture:SetAtlas('Nzoth-charactersheet-item-glow')
			Slot.IconOverlay:SetAtlas('Nzoth-inventory-icon')
			Slot.IconOverlay:SetInside()
			Slot.IconBorder:SetAlpha(0)

			if Slot.popoutButton:GetPoint() == 'TOP' then
				Slot.popoutButton:SetPoint('TOP', Slot, 'BOTTOM', 0, 2)
			else
				Slot.popoutButton:SetPoint('LEFT', Slot, 'RIGHT', -2, 0)
			end

			E:RegisterCooldown(_G[Slot:GetName()..'Cooldown'])
			hooksecurefunc(Slot, 'DisplayAsAzeriteItem', UpdateAzeriteItem)
			hooksecurefunc(Slot, 'DisplayAsAzeriteEmpoweredItem', UpdateAzeriteEmpoweredItem)
			hooksecurefunc(Slot.IconBorder, 'SetVertexColor', function(_, r, g, b) Slot:SetBackdropBorderColor(r, g, b) end)
			hooksecurefunc(Slot.IconBorder, 'Hide', function() Slot:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)

			Slot:HookScript('OnShow', CorruptionIcon)
			Slot:HookScript('OnEvent', CorruptionIcon)
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
		local bg = _G['CharacterModelFrameBackground'..corner];
		if bg then
			bg:SetDesaturated(false);
			bg.ignoreDesaturated = true; -- so plugins can prevent this if they want.
			hooksecurefunc(bg, 'SetDesaturated', function(bckgnd, value)
				if value and bckgnd.ignoreDesaturated then
					bckgnd:SetDesaturated(false);
				end
			end)
		end
	end

	_G.CharacterLevelText:FontTemplate()
	_G.CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)
	_G.CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
	ColorizeStatPane(_G.CharacterStatsPane.ItemLevelFrame)

	--Corruption 8.3
	_G.CharacterStatsPane.ItemLevelFrame.Corruption:ClearAllPoints()
	_G.CharacterStatsPane.ItemLevelFrame.Corruption:SetPoint('RIGHT', _G.CharacterStatsPane.ItemLevelFrame, 'RIGHT', 22, -8)

	hooksecurefunc('PaperDollFrame_UpdateStats', function()
		if IsAddOnLoaded('DejaCharacterStats') then return end

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

	if not IsAddOnLoaded('DejaCharacterStats') then
		StatsPane('EnhancementsCategory')
		StatsPane('ItemLevelCategory')
		StatsPane('AttributesCategory')
	end

	--Strip Textures
	local charframe = {
		'CharacterModelFrame',
		'CharacterFrameInset',
		'CharacterStatsPane',
		'CharacterFrameInsetRight',
		'PaperDollSidebarTabs',
		'PaperDollEquipmentManagerPane',
	}

	S:HandleCloseButton(_G.ReputationDetailCloseButton)
	S:HandleCloseButton(_G.TokenFramePopupCloseButton)

	S:HandleCheckBox(_G.ReputationDetailAtWarCheckBox)
	S:HandleCheckBox(_G.ReputationDetailMainScreenCheckBox)
	S:HandleCheckBox(_G.ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(_G.ReputationDetailLFGBonusReputationCheckBox)
	S:HandleCheckBox(_G.TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(_G.TokenFramePopupBackpackCheckBox)

	_G.EquipmentFlyoutFrameHighlight:Kill()
	_G.EquipmentFlyoutFrame.NavigationFrame:StripTextures()
	_G.EquipmentFlyoutFrame.NavigationFrame:SetTemplate('Transparent')
	_G.EquipmentFlyoutFrame.NavigationFrame:SetPoint('TOPLEFT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMLEFT', 0, -E.Border - E.Spacing)
	_G.EquipmentFlyoutFrame.NavigationFrame:SetPoint('TOPRIGHT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMRIGHT', 0, -E.Border - E.Spacing)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.NextButton)

	--Swap item flyout frame (shown when holding alt over a slot)
	hooksecurefunc('EquipmentFlyout_UpdateItems', SkinItemFlyouts)
	hooksecurefunc('EquipmentFlyout_CreateButton', function()
		local button = _G.EquipmentFlyoutFrame.buttons[#_G.EquipmentFlyoutFrame.buttons]

		if not button.Eye then
			button.Eye = button:CreateTexture()
			button.Eye:SetAtlas('Nzoth-inventory-icon')
			button.Eye:SetInside()
		end
	end)

	hooksecurefunc('EquipmentFlyout_DisplayButton', function(button)
		local location = button.location
		local border = button.IconBorder
		if not location or not border then return end

		if location >= _G.EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
			border:Hide()
		else
			border:Show()
		end

		UpdateCorruption(button, location)
	end)

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
	_G.CharacterModelFrameBackgroundOverlay:SetColorTexture(0,0,0)
	_G.CharacterModelFrame:CreateBackdrop()
	_G.CharacterModelFrame.backdrop:SetPoint('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	_G.CharacterModelFrame.backdrop:SetPoint('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

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
	_G.PaperDollEquipmentManagerPaneEquipSet:SetWidth(_G.PaperDollEquipmentManagerPaneEquipSet:GetWidth() - 8)
	_G.PaperDollEquipmentManagerPaneSaveSet:SetWidth(_G.PaperDollEquipmentManagerPaneSaveSet:GetWidth() - 8)
	_G.PaperDollEquipmentManagerPaneEquipSet:SetPoint('TOPLEFT', _G.PaperDollEquipmentManagerPane, 'TOPLEFT', 8, 0)
	_G.PaperDollEquipmentManagerPaneSaveSet:SetPoint('LEFT', _G.PaperDollEquipmentManagerPaneEquipSet, 'RIGHT', 4, 0)

	--Itemset buttons
	for _, object in pairs(_G.PaperDollEquipmentManagerPane.buttons) do
		object.BgTop:SetTexture()
		object.BgBottom:SetTexture()
		object.BgMiddle:SetTexture()
		object.icon:SetSize(36, 36)
		object.icon:SetTexCoord(unpack(E.TexCoords))

		--Making all icons the same size and position because otherwise BlizzardUI tries to attach itself to itself when it refreshes
		object.icon:SetPoint('LEFT', object, 'LEFT', 4, 0)
		hooksecurefunc(object.icon, 'SetPoint', function(icn, _, _, _, _, _, forced)
			if forced ~= true then
				icn:SetPoint('LEFT', object, 'LEFT', 4, 0, true)
			end
		end)
		hooksecurefunc(object.icon, 'SetSize', function(icn, width, height)
			if width == 30 or height == 30 then
				icn:SetSize(36, 36)
			end
		end)
	end

	--Icon selection frame
	S:HandleIconSelectionFrame(_G.GearManagerDialogPopup, _G.NUM_GEARSET_ICONS_SHOWN, 'GearManagerDialogPopupButton')
	S:HandleButton(_G.GearManagerDialogPopupOkay)
	S:HandleButton(_G.GearManagerDialogPopupCancel)
	S:HandleEditBox(_G.GearManagerDialogPopupEditBox)

	--Handle Tabs at bottom of character frame
	for i=1, 4 do
		S:HandleTab(_G['CharacterFrameTab'..i])
	end

	hooksecurefunc('ExpandFactionHeader', UpdateFactionSkins)
	hooksecurefunc('CollapseFactionHeader', UpdateFactionSkins)
	hooksecurefunc('ReputationFrame_Update', UpdateFactionSkins)

	--Buttons used to toggle between equipment manager, titles, and character stats
	hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', FixSidebarTabCoords)

	--Currency
	hooksecurefunc('TokenFrame_Update', UpdateCurrencySkins)
	hooksecurefunc(_G.TokenFrameContainer, 'update', UpdateCurrencySkins)

	-- Tutorials have a look for the new name on PTR 8.2.5
	-- S:HandleCloseButton(_G.PaperDollItemsFrame.HelpTipBox.CloseButton)
end

S:AddCallback('CharacterFrame')
