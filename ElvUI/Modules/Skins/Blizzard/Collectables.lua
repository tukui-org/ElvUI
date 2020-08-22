local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select = select
local ipairs, pairs, unpack = ipairs, pairs, unpack

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local PlayerHasToy = PlayerHasToy
local hooksecurefunc = hooksecurefunc
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS
local GetItemQualityColor = GetItemQualityColor
local C_Heirloom_PlayerHasHeirloom = C_Heirloom.PlayerHasHeirloom
local C_TransmogCollection_GetSourceInfo = C_TransmogCollection.GetSourceInfo

local function TextColorModified(self, r, g, b)
	if r == 0.33 and g == 0.27 and b == 0.2 then
		self:SetTextColor(0.6, 0.6, 0.6)
	elseif r == 1 and g == 0.82 and b == 0 then
		self:SetTextColor(1, 1, 1)
	end
end

function S:Blizzard_Collections()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.collections) then return end

	-- global
	local CollectionsJournal = _G.CollectionsJournal
	S:HandlePortraitFrame(CollectionsJournal, true)

	for i=1, 5 do
		S:HandleTab(_G['CollectionsJournalTab'..i])
	end

	S:HandleItemButton(_G.MountJournalSummonRandomFavoriteButton)
	S:HandleButton(_G.MountJournalFilterButton)

	_G.MountJournalFilterButton:ClearAllPoints()
	_G.MountJournalFilterButton:SetPoint('LEFT', _G.MountJournalSearchBox, 'RIGHT', 5, 0)

	-------------------------------
	--[[ mount journal (tab 1) ]]--
	-------------------------------
	local MountJournal = _G.MountJournal
	MountJournal:StripTextures()
	MountJournal.MountDisplay:StripTextures()
	MountJournal.MountDisplay.ShadowOverlay:StripTextures()
	MountJournal.MountCount:StripTextures()

	S:HandleIcon(MountJournal.MountDisplay.InfoButton.Icon)
	S:HandleCheckBox(MountJournal.MountDisplay.ModelScene.TogglePlayer)
	MountJournal.MountDisplay.ModelScene.TogglePlayer:SetSize(22, 22)

	S:HandleButton(_G.MountJournalMountButton)
	S:HandleEditBox(_G.MountJournalSearchBox)
	S:HandleScrollBar(_G.MountJournalListScrollFrameScrollBar)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateLeftButton)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateRightButton)

	-- New Mount Equip. 8.2
	MountJournal.BottomLeftInset:StripTextures()
	MountJournal.BottomLeftInset:CreateBackdrop('Transparent')
	MountJournal.BottomLeftInset.SlotButton:StripTextures()
	S:HandleIcon(MountJournal.BottomLeftInset.SlotButton.ItemIcon)
	S:HandleButton(MountJournal.BottomLeftInset.SlotButton)

	for _, bu in pairs(MountJournal.ListScrollFrame.buttons) do
		bu:CreateBackdrop('Transparent')
		bu.backdrop:SetFrameLevel(bu:GetFrameLevel())
		bu.backdrop:SetInside(bu, 3, 3)

		bu.icon:SetPoint('LEFT', bu, -40, 0)
		bu.icon:SetTexCoord(unpack(E.TexCoords))
		bu.icon:CreateBackdrop()
		bu.icon.backdrop:SetOutside(bu.icon, 1, 1)

		bu:HookScript('OnEnter', function(s)
			s.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
			s.icon.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		end)

		bu:HookScript('OnLeave', function(s)
			if s.selected then
				s.backdrop:SetBackdropBorderColor(1, .8, .1)
				s.icon.backdrop:SetBackdropBorderColor(1, .8, .1)
			else
				s.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				s.icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end)

		hooksecurefunc(bu.selectedTexture, 'Show', function()
			bu.name:SetTextColor(1, .8, .1)
			bu.backdrop:SetBackdropBorderColor(1, .8, .1)
			bu.icon.backdrop:SetBackdropBorderColor(1, .8, .1)
		end)

		hooksecurefunc(bu.selectedTexture, 'Hide', function()
			bu.name:SetTextColor(1, 1, 1)
			bu.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			bu.icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

		bu:SetHighlightTexture(nil)
		bu.iconBorder:SetTexture()
		bu.background:SetTexture()
		bu.selectedTexture:SetTexture()

		bu.factionIcon:SetDrawLayer('OVERLAY')
		bu.factionIcon:SetPoint('TOPRIGHT', -1, -4)
		bu.factionIcon:SetPoint('BOTTOMRIGHT', -1, 4)

		bu.favorite:SetTexture([[Interface\COMMON\FavoritesIcon]])
		bu.favorite:SetPoint('TOPLEFT', bu.DragButton, 'TOPLEFT' , -8, 8)
		bu.favorite:SetSize(32, 32)
	end

	-----------------------------
	--[[ pet journal (tab 2) ]]--
	-----------------------------
	_G.PetJournalSummonButton:StripTextures()
	_G.PetJournalFindBattle:StripTextures()
	S:HandleButton(_G.PetJournalSummonButton)
	S:HandleButton(_G.PetJournalFindBattle)
	_G.PetJournalRightInset:StripTextures()
	_G.PetJournalLeftInset:StripTextures()
	S:HandleItemButton(_G.PetJournalSummonRandomFavoritePetButton, true)

	for i = 1, 3 do
		local f = _G['PetJournalLoadoutPet'..i..'HelpFrame']
		f:StripTextures()
	end

	if E.global.general.disableTutorialButtons then
		_G.PetJournalTutorialButton:Kill()
	end

	local PetJournal = _G.PetJournal
	PetJournal.PetCount:StripTextures()
	S:HandleEditBox(_G.PetJournalSearchBox)
	_G.PetJournalSearchBox:ClearAllPoints()
	_G.PetJournalSearchBox:SetPoint('TOPLEFT', _G.PetJournalLeftInset, 'TOPLEFT', (E.PixelMode and 13 or 10), -9)
	S:HandleButton(_G.PetJournalFilterButton)
	_G.PetJournalFilterButton:SetHeight(E.PixelMode and 22 or 24)
	_G.PetJournalFilterButton:ClearAllPoints()
	_G.PetJournalFilterButton:SetPoint('TOPRIGHT', _G.PetJournalLeftInset, 'TOPRIGHT', -5, -(E.PixelMode and 8 or 7))
	_G.PetJournalListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.PetJournalListScrollFrameScrollBar)

	for _, bu in pairs(PetJournal.listScroll.buttons) do
		bu:StripTextures()
		bu:CreateBackdrop('Transparent')
		bu.backdrop:SetFrameLevel(bu:GetFrameLevel())
		bu.backdrop:SetInside(bu, 3, 3)

		bu.icon:SetPoint('LEFT', -40, 0)
		bu.icon:SetTexCoord(unpack(E.TexCoords))
		bu.icon:CreateBackdrop()
		bu.icon.backdrop:SetOutside(bu.icon, 1, 1)

		bu:HookScript('OnEnter', function(s)
			s.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		end)

		bu:HookScript('OnLeave', function(s)
			if s.selected then
				s.backdrop:SetBackdropBorderColor(1, .8, .1)
			else
				s.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end)

		hooksecurefunc(bu.selectedTexture, 'Show', function()
			bu.name:SetTextColor(1, .8, .1)
			bu.backdrop:SetBackdropBorderColor(1, .8, .1)
		end)

		hooksecurefunc(bu.selectedTexture, 'Hide', function()
			bu.name:SetTextColor(1, 1, 1)
			bu.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

		bu.dragButton.ActiveTexture:SetAlpha(0)
		bu.dragButton.levelBG:SetTexture()

		bu.iconBorder:SetTexture()
		bu.selectedTexture:SetTexture()

		hooksecurefunc(bu.iconBorder, 'SetVertexColor', function(_, r, g, b)
			bu.icon.backdrop:SetBackdropBorderColor(r, g, b)
		end)

		hooksecurefunc(bu.iconBorder, 'Hide', function()
			bu.icon.backdrop:SetBackdropColor(unpack(E.media.bordercolor))
		end)
	end

	_G.PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')

	S:HandleItemButton(_G.PetJournalHealPetButton, true)
	E:RegisterCooldown(_G.PetJournalHealPetButtonCooldown)
	_G.PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	_G.PetJournalLoadoutBorder:StripTextures()

	for i = 1, 3 do
		local petButton = _G['PetJournalLoadoutPet'..i]
		local petButtonHealthFrame = _G['PetJournalLoadoutPet'..i..'HealthFrame']
		local petButtonXPBar = _G['PetJournalLoadoutPet'..i..'XPBar']
		petButton:StripTextures()
		petButton:CreateBackdrop()
		petButton.backdrop:SetAllPoints()
		petButton.petTypeIcon:SetPoint('BOTTOMLEFT', 2, 2)

		petButton.dragButton:SetOutside(_G['PetJournalLoadoutPet'..i..'Icon'])
		petButton.dragButton:SetFrameLevel(_G['PetJournalLoadoutPet'..i].dragButton:GetFrameLevel() + 1)

		petButton.hover = true;
		petButton.pushed = true;
		petButton.checked = true;
		S:HandleItemButton(petButton)
		petButton.levelBG:SetAtlas('PetJournal-LevelBubble', true)

		petButton.backdrop:SetFrameLevel(_G['PetJournalLoadoutPet'..i].backdrop:GetFrameLevel() + 1)

		petButton.setButton:StripTextures()
		petButtonHealthFrame.healthBar:StripTextures()
		petButtonHealthFrame.healthBar:CreateBackdrop()
		petButtonHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(petButtonHealthFrame.healthBar)
		petButtonXPBar:StripTextures()
		petButtonXPBar:CreateBackdrop()
		petButtonXPBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(petButtonXPBar)
		petButtonXPBar:SetFrameLevel(petButtonXPBar:GetFrameLevel() + 2)

		for index = 1, 3 do
			local f = _G['PetJournalLoadoutPet'..i..'Spell'..index]
			S:HandleItemButton(f)
			f.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
			_G['PetJournalLoadoutPet'..i..'Spell'..index..'Icon']:SetInside(f)
		end
	end

	_G.PetJournalSpellSelect:StripTextures()
	for i=1, 2 do
		local btn = _G['PetJournalSpellSelectSpell'..i]
		S:HandleItemButton(btn)
		_G['PetJournalSpellSelectSpell'..i..'Icon']:SetInside(btn)
		_G['PetJournalSpellSelectSpell'..i..'Icon']:SetDrawLayer('BORDER')
	end

	_G.PetJournalPetCard:StripTextures()
	_G.PetJournalPetCard:SetTemplate()
	_G.PetJournalPetCardInset:StripTextures()
	_G.PetJournalPetCardPetInfoQualityBorder:SetAlpha(0)

	_G.PetJournalPetCardPetInfoIcon:SetTexCoord(unpack(E.TexCoords))
	_G.PetJournalPetCardPetInfo:CreateBackdrop()
	_G.PetJournalPetCardPetInfo.favorite:SetParent(_G.PetJournalPetCardPetInfo.backdrop)
	_G.PetJournalPetCardPetInfo.backdrop:SetOutside(_G.PetJournalPetCardPetInfoIcon)
	_G.PetJournalPetCardPetInfoIcon:SetParent(_G.PetJournalPetCardPetInfo.backdrop)

	if E.private.skins.blizzard.tooltip then
		local tt = _G.PetJournalPrimaryAbilityTooltip
		tt.Background:SetTexture()
		if tt.Delimiter1 then
			tt.Delimiter1:SetTexture()
			tt.Delimiter2:SetTexture()
		end
		tt.BorderTop:SetTexture()
		tt.BorderTopLeft:SetTexture()
		tt.BorderTopRight:SetTexture()
		tt.BorderLeft:SetTexture()
		tt.BorderRight:SetTexture()
		tt.BorderBottom:SetTexture()
		tt.BorderBottomRight:SetTexture()
		tt.BorderBottomLeft:SetTexture()
		tt:SetTemplate('Transparent')
	end

	for i=1, 6 do
		local frame = _G['PetJournalPetCardSpell'..i]
		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame:DisableDrawLayer('BACKGROUND')
		frame:CreateBackdrop()
		frame.backdrop:SetAllPoints()
		frame.icon:SetTexCoord(unpack(E.TexCoords))
		frame.icon:SetInside(frame.backdrop)
	end

	_G.PetJournalPetCardHealthFrame.healthBar:StripTextures()
	_G.PetJournalPetCardHealthFrame.healthBar:CreateBackdrop()
	_G.PetJournalPetCardHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.PetJournalPetCardHealthFrame.healthBar)
	_G.PetJournalPetCardXPBar:StripTextures()
	_G.PetJournalPetCardXPBar:CreateBackdrop()
	_G.PetJournalPetCardXPBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.PetJournalPetCardXPBar)

	--Toy Box
	local ToyBox = _G.ToyBox
	S:HandleButton(_G.ToyBoxFilterButton)
	_G.ToyBoxFilterButton:SetPoint('TOPRIGHT', ToyBox, 'TOPRIGHT', -15, -34)
	S:HandleEditBox(ToyBox.searchBox)
	ToyBox.iconsFrame:StripTextures()
	S:HandleNextPrevButton(ToyBox.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(ToyBox.PagingFrame.PrevPageButton, nil, nil, true)

	local progressBar = ToyBox.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer('BACKGROUND')
	progressBar:SetStatusBarTexture(E.media.normTex)
	progressBar:CreateBackdrop()
	E:RegisterStatusBar(progressBar)

	for i = 1, 18 do
		local button = ToyBox.iconsFrame['spellButton'..i]
		S:HandleItemButton(button, true)
		button.iconTextureUncollected:SetTexCoord(unpack(E.TexCoords))
		button.iconTextureUncollected:SetInside(button)
		button.hover:SetAllPoints(button.iconTexture)
		button.checked:SetAllPoints(button.iconTexture)
		button.pushed:SetAllPoints(button.iconTexture)
		button.cooldown:SetAllPoints(button.iconTexture)

		hooksecurefunc(button.name, 'SetTextColor', TextColorModified)
		hooksecurefunc(button.new, 'SetTextColor', TextColorModified)
		E:RegisterCooldown(button.cooldown)
	end

	hooksecurefunc('ToySpellButton_UpdateButton', function(s)
		if PlayerHasToy(s.itemID) then
			local quality = select(3, GetItemInfo(s.itemID))
			local r, g, b = 1, 1, 1
			if quality then
				r, g, b = GetItemQualityColor(quality)
			end
			s.backdrop:SetBackdropBorderColor(r, g, b)
		else
			s.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	--Heirlooms
	local HeirloomsJournal = _G.HeirloomsJournal
	S:HandleButton(_G.HeirloomsJournalFilterButton)
	_G.HeirloomsJournalFilterButton:SetPoint('TOPRIGHT', HeirloomsJournal, 'TOPRIGHT', -15, -34)
	S:HandleEditBox(HeirloomsJournal.SearchBox)
	HeirloomsJournal.iconsFrame:StripTextures()
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.PrevPageButton, nil, nil, true)
	S:HandleDropDownBox(_G.HeirloomsJournalClassDropDown)

	progressBar = HeirloomsJournal.progressBar -- swap local variable
	progressBar.border:Hide()
	progressBar:DisableDrawLayer('BACKGROUND')
	progressBar:SetStatusBarTexture(E.media.normTex)
	progressBar:CreateBackdrop()
	E:RegisterStatusBar(progressBar)

	hooksecurefunc(HeirloomsJournal, 'UpdateButton', function(_, button)
		if not button.styled then
			S:HandleItemButton(button, true)

			button.iconTexture:SetDrawLayer('ARTWORK')
			button.hover:SetAllPoints(button.iconTexture)
			button.slotFrameCollected:SetAlpha(0)
			button.slotFrameUncollected:SetAlpha(0)
			button.special:SetJustifyH('RIGHT')
			button.special:ClearAllPoints()
			button.styled = true
		end

		button.levelBackground:SetTexture()

		button.name:SetPoint('LEFT', button, 'RIGHT', 4, 8)
		button.level:SetPoint('TOPLEFT', button.levelBackground,'TOPLEFT', 25, 2)

		button.SetTextColor = nil
		if C_Heirloom_PlayerHasHeirloom(button.itemID) then
			button.name:SetTextColor(1, 1, 1)
			button.level:SetTextColor(1, 1, 1)
			button.special:SetTextColor(1, .82, 0)
			button.backdrop:SetBackdropBorderColor(GetItemQualityColor(7))
		else
			button.name:SetTextColor(0.4, 0.4, 0.4)
			button.level:SetTextColor(0.4, 0.4, 0.4)
			button.special:SetTextColor(0.4, 0.4, 0.4)
			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
		button.SetTextColor = E.noop
	end)

	hooksecurefunc(HeirloomsJournal, 'LayoutCurrentPage', function()
		for i=1, #HeirloomsJournal.heirloomHeaderFrames do
			local header = HeirloomsJournal.heirloomHeaderFrames[i]
			header:StripTextures()
			header.text:FontTemplate(nil, 15, '')
			header.text:SetTextColor(1, 1, 1)
		end
	end)

	-- Appearances Tab
	local WardrobeCollectionFrame = _G.WardrobeCollectionFrame
	S:HandleTab(WardrobeCollectionFrame.ItemsTab)
	S:HandleTab(WardrobeCollectionFrame.SetsTab)

	--Items
	WardrobeCollectionFrame.progressBar:StripTextures()
	WardrobeCollectionFrame.progressBar:CreateBackdrop()
	WardrobeCollectionFrame.progressBar:SetStatusBarTexture(E.media.normTex)

	E:RegisterStatusBar(WardrobeCollectionFrame.progressBar)

	S:HandleEditBox(_G.WardrobeCollectionFrameSearchBox)
	_G.WardrobeCollectionFrameSearchBox:SetFrameLevel(5)

	WardrobeCollectionFrame.FilterButton:SetPoint('LEFT', WardrobeCollectionFrame.searchBox, 'RIGHT', 2, 0)
	S:HandleButton(WardrobeCollectionFrame.FilterButton)
	S:HandleDropDownBox(_G.WardrobeCollectionFrameWeaponDropDown)

	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()

	for _, Frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
		if Frame.Models then
			for _, Model in pairs(Frame.Models) do
				Model:SetFrameLevel(Model:GetFrameLevel() + 1)
				Model.Border:SetAlpha(0)
				Model.TransmogStateTexture:SetAlpha(0)

				local bg = CreateFrame('Frame', nil, Model)
				bg:SetAllPoints()
				bg:CreateBackdrop()
				bg.backdrop:SetOutside(Model, 2, 2)

				hooksecurefunc(Model.Border, 'SetAtlas', function(_, texture)
					local r, g, b
					if texture == 'transmog-wardrobe-border-uncollected' then
						r, g, b = 1, 1, 0
					elseif texture == 'transmog-wardrobe-border-unusable' then
						r, g, b =  1, 0, 0
					else
						r, g, b = unpack(E.media.bordercolor)
					end
					bg.backdrop:SetBackdropBorderColor(r, g, b)
				end)
			end
		end

		if Frame.PendingTransmogFrame then
			Frame.PendingTransmogFrame.Glowframe:SetAtlas(nil)
			Frame.PendingTransmogFrame.Glowframe:CreateBackdrop()
			Frame.PendingTransmogFrame.Glowframe.backdrop:SetOutside()
			Frame.PendingTransmogFrame.Glowframe.backdrop:SetBackdropColor(0, 0, 0, 0)
			Frame.PendingTransmogFrame.Glowframe.backdrop:SetBackdropBorderColor(1, .77, 1, 1)
			Frame.PendingTransmogFrame.Glowframe = Frame.PendingTransmogFrame.Glowframe.backdrop

			for i = 1, 12 do
				Frame.PendingTransmogFrame['Wisp'..i]:Hide()
			end
		end

		if Frame.PagingFrame then
			S:HandleNextPrevButton(Frame.PagingFrame.PrevPageButton, nil, nil, true)
			S:HandleNextPrevButton(Frame.PagingFrame.NextPageButton, nil, nil, true)
		end
	end

	--Sets
	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame.RightInset:StripTextures()
	SetsCollectionFrame:SetTemplate('Transparent')
	SetsCollectionFrame.LeftInset:StripTextures()

	local ScrollFrame = SetsCollectionFrame.ScrollFrame
	S:HandleScrollBar(ScrollFrame.scrollBar)
	for i = 1, #ScrollFrame.buttons do
		local bu = ScrollFrame.buttons[i]
		S:HandleItemButton(bu)
		bu.Favorite:SetAtlas('PetJournal-FavoritesIcon', true)
		bu.Favorite:SetPoint('TOPLEFT', bu.Icon, 'TOPLEFT', -8, 8)
		bu.SelectedTexture:SetColorTexture(1, 1, 1, 0.1)
	end

	-- DetailsFrame
	local DetailsFrame = SetsCollectionFrame.DetailsFrame
	DetailsFrame.Name:FontTemplate(nil, 16)
	DetailsFrame.LongName:FontTemplate(nil, 16)
	S:HandleButton(DetailsFrame.VariantSetsButton)

	hooksecurefunc(SetsCollectionFrame, 'SetItemFrameQuality', function(_, itemFrame)
		local icon = itemFrame.Icon
		if not icon.backdrop then
			icon:CreateBackdrop()
			icon:SetTexCoord(unpack(E.TexCoords))
			itemFrame.IconBorder:Hide()
		end

		if itemFrame.collected then
			local quality = C_TransmogCollection_GetSourceInfo(itemFrame.sourceID).quality
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	_G.WardrobeSetsCollectionVariantSetsButton.Icon:SetTexture(E.Media.Textures.ArrowUp)
	_G.WardrobeSetsCollectionVariantSetsButton.Icon:SetRotation(S.ArrowRotation.down)

	-- Transmogrify NPC
	local WardrobeFrame = _G.WardrobeFrame
	S:HandlePortraitFrame(WardrobeFrame, true)

	local WardrobeOutfitFrame = _G.WardrobeOutfitFrame
	WardrobeOutfitFrame:StripTextures()
	WardrobeOutfitFrame:SetTemplate('Transparent')
	S:HandleButton(_G.WardrobeOutfitDropDown.SaveButton)
	S:HandleDropDownBox(_G.WardrobeOutfitDropDown, 221)
	_G.WardrobeOutfitDropDown:SetHeight(34)
	_G.WardrobeOutfitDropDown.SaveButton:ClearAllPoints()
	_G.WardrobeOutfitDropDown.SaveButton:SetPoint('TOPLEFT', _G.WardrobeOutfitDropDown, 'TOPRIGHT', -2, -2)

	local WardrobeTransmogFrame = _G.WardrobeTransmogFrame
	WardrobeTransmogFrame:StripTextures()

	for i = 1, #WardrobeTransmogFrame.ModelScene.SlotButtons do
		WardrobeTransmogFrame.ModelScene.SlotButtons[i]:StripTextures()
		WardrobeTransmogFrame.ModelScene.SlotButtons[i]:SetFrameLevel(WardrobeTransmogFrame.ModelScene.SlotButtons[i]:GetFrameLevel() + 2)
		WardrobeTransmogFrame.ModelScene.SlotButtons[i]:CreateBackdrop()
		WardrobeTransmogFrame.ModelScene.SlotButtons[i].backdrop:SetAllPoints()
		WardrobeTransmogFrame.ModelScene.SlotButtons[i].Border:Kill()
		WardrobeTransmogFrame.ModelScene.SlotButtons[i].Icon:SetTexCoord(unpack(E.TexCoords))
	end

	WardrobeTransmogFrame.SpecButton:ClearAllPoints()
	WardrobeTransmogFrame.SpecButton:SetPoint('RIGHT', WardrobeTransmogFrame.ApplyButton, 'LEFT', -2, 0)
	S:HandleButton(WardrobeTransmogFrame.SpecButton)
	S:HandleButton(WardrobeTransmogFrame.ApplyButton)
	S:HandleButton(WardrobeTransmogFrame.ModelScene.ClearAllPendingButton)

	--Transmogrify NPC Sets tab
	WardrobeCollectionFrame.SetsTransmogFrame:StripTextures()
	WardrobeCollectionFrame.SetsTransmogFrame:SetTemplate('Transparent')
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.NextPageButton)
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.PrevPageButton)

	-- Outfit Edit Frame
	local WardrobeOutfitEditFrame = _G.WardrobeOutfitEditFrame
	WardrobeOutfitEditFrame:StripTextures()
	WardrobeOutfitEditFrame:CreateBackdrop('Transparent')
	WardrobeOutfitEditFrame.EditBox:StripTextures()
	S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
	S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
	S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)
end

S:AddCallbackForAddon('Blizzard_Collections')
