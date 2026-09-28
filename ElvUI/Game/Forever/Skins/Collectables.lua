local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack, strfind = next, unpack, strfind
local ipairs, pairs = ipairs, pairs
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local PlayerHasToy = PlayerHasToy

local C_Heirloom_PlayerHasHeirloom = C_Heirloom.PlayerHasHeirloom
local C_TransmogCollection_GetSourceInfo = C_TransmogCollection.GetSourceInfo
local GetItemQualityByID = C_Item.GetItemQualityByID

local ITEMQUALITY_HEIRLOOM = Enum.ItemQuality.Heirloom or 7

local function ClearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 0)
end

local function HandleCollectionsBackground(frame)
	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
	else
		frame.Bg:Hide()
		frame.NineSlice:StripTextures()
		frame.BackgroundTile:SetDrawLayer('BACKGROUND', 1) -- above the ElvUI backdrop
	end
end

local function ToyTextColor(text, r, g, b)
	if r == 0.33 and g == 0.27 and b == 0.2 then
		text:SetTextColor(0.4, 0.4, 0.4)
	elseif r == 1 and g == 0.82 and b == 0 then
		text:SetTextColor(0.9, 0.9, 0.9)
	end
end

local function MountNameColor(object)
	local button = object:GetParent()
	local name = button.name

	if name:GetFontObject() == _G.GameFontDisable then
		name:SetTextColor(0.4, 0.4, 0.4)
	else
		if button.background then
			local _, g, b = button.background:GetVertexColor()
			if g == 0 and b == 0 then
				name:SetTextColor(0.9, 0.3, 0.3)
				return
			end
		end

		name:SetTextColor(0.9, 0.9, 0.9)
	end
end

local function SelectedTextureSetShown(texture, shown) -- used sets list
	local parent = texture:GetParent()
	if shown then
		parent.backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		parent.backdrop:SetBackdropBorderColor(r, g, b)
	end
end

local function SelectedTextureShow(texture) -- used for pets/mounts
	local parent = texture:GetParent()
	parent.backdrop:SetBackdropBorderColor(1, .8, .1)
end

local function SelectedTextureHide(texture) -- used for pets/mounts
	local parent = texture:GetParent()
	if not parent.hovered then
		local r, g, b = unpack(E.media.bordercolor)
		parent.backdrop:SetBackdropBorderColor(r, g, b)
	end
end

local function ButtonOnEnter(button)
	local r, g, b = unpack(E.media.rgbvaluecolor)
	button.backdrop:SetBackdropBorderColor(r, g, b)

	button.hovered = true
end

local function ButtonOnLeave(button)
	if button.selected or (button.SelectedTexture and button.SelectedTexture:IsShown()) then
		button.backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		button.backdrop:SetBackdropBorderColor(r, g, b)
	end

	button.hovered = nil
end

local function SkinJournalScrollButton(bu)
	if not bu.IsSkinned then
		local icon = bu.icon or bu.Icon
		local savedIconTexture = icon:GetTexture()
		icon:Size(40)
		icon:Point('LEFT', -43, 0)
		S:HandleIcon(icon, true)
		S:HandleIconBorder(bu.iconBorder, icon.backdrop)

		local savedPetTypeTexture = bu.petTypeIcon and bu.petTypeIcon:GetTexture()
		local savedFactionAtlas = bu.factionIcon and bu.factionIcon:GetAtlas()

		bu:StripTextures()
		bu:CreateBackdrop('Transparent', nil, nil, true)
		bu.backdrop:ClearAllPoints()
		bu.backdrop:Point('TOPLEFT', bu, 0, -2)
		bu.backdrop:Point('BOTTOMRIGHT', bu, 0, 2)
		icon:SetTexture(savedIconTexture) -- restore the texture

		bu:HookScript('OnEnter', ButtonOnEnter)
		bu:HookScript('OnLeave', ButtonOnLeave)

		if bu.ProgressBar then
			bu.ProgressBar:SetTexture(E.media.normTex)
			bu.ProgressBar:SetVertexColor(0.251, 0.753, 0.251, 1) -- 0.0118, 0.247, 0.00392
		end

		local parent = bu:GetParent():GetParent():GetParent()
		if parent == _G.WardrobeCollectionFrame.SetsCollectionFrame then
			bu.Favorite:SetAtlas('PetJournal-FavoritesIcon', true)
			bu.Favorite:Point('TOPLEFT', bu.Icon, 'TOPLEFT', -8, 8)

			hooksecurefunc(bu.SelectedTexture, 'SetShown', SelectedTextureSetShown)
		else
			bu.selectedTexture:SetTexture()
			hooksecurefunc(bu.selectedTexture, 'Show', SelectedTextureShow)
			hooksecurefunc(bu.selectedTexture, 'Hide', SelectedTextureHide)

			if parent == _G.PetJournal then
				bu.petList = true
				bu.petTypeIcon:SetTexture(savedPetTypeTexture)
				bu.petTypeIcon:Point('TOPRIGHT', -1, -1)
				bu.petTypeIcon:Point('BOTTOMRIGHT', -1, 1)

				bu.dragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
				bu.dragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)

				local hl = bu.dragButton:GetHighlightTexture()
				hl:SetTexture(E.media.blankTex)
				hl:SetVertexColor(1, 1, 1, .25)
				hl:SetAllPoints(bu.icon)
			elseif parent == _G.MountJournal then
				bu.mountList = true
				bu.factionIcon:SetAtlas(savedFactionAtlas)
				bu.factionIcon:SetDrawLayer('OVERLAY')
				bu.factionIcon:Point('TOPRIGHT', -1, -1)
				bu.factionIcon:Point('BOTTOMRIGHT', -1, 1)

				icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				bu.DragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
				bu.DragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)

				local hl = bu.DragButton:GetHighlightTexture()
				hl:SetTexture(E.media.blankTex)
				hl:SetVertexColor(1, 1, 1, .25)
				hl:SetAllPoints(bu.icon)

				bu.favorite:SetTexture([[Interface\COMMON\FavoritesIcon]])
				bu.favorite:Point('TOPLEFT', bu.DragButton, 'TOPLEFT' , -8, 8)
				bu.favorite:Size(32)

				hooksecurefunc(bu.name, 'SetFontObject', MountNameColor)
				hooksecurefunc(bu.background, 'SetVertexColor', MountNameColor)
			end
		end

		bu.IsSkinned = true
	end
end

local function JournalScrollButtons(frame)
	frame:ForEachFrame(SkinJournalScrollButton)
end

local function ToySpellButtonUpdateButton(button)
	local quality = button.itemID and PlayerHasToy(button.itemID) and GetItemQualityByID(button.itemID)
	local r, g, b = E:GetItemQualityColor(quality)
	button.backdrop:SetBackdropBorderColor(r, g, b)
end

local function HeirloomsJournalUpdateButton(_, button)
	if not button.IsSkinned then
		S:HandleItemButton(button, true)

		button.iconTextureUncollected:SetTexCoords()
		button.iconTextureUncollected:SetInside(button)
		button.iconTexture:SetDrawLayer('ARTWORK')
		button.hover:SetAllPoints(button.iconTexture)
		button.slotFrameCollected:SetAlpha(0)
		button.slotFrameUncollected:SetAlpha(0)
		button.special:SetJustifyH('RIGHT')
		button.special:ClearAllPoints()

		button.cooldown:SetAllPoints(button.iconTexture)

		E:RegisterCooldown(button.cooldown)

		button.IsSkinned = true
	end

	button.levelBackground:SetTexture()

	button.name:Point('LEFT', button, 'RIGHT', 4, 8)
	button.level:Point('TOPLEFT', button.levelBackground,'TOPLEFT', 25, 2)

	local collected = C_Heirloom_PlayerHasHeirloom(button.itemID)
	if collected then
		local r, g, b = E:GetItemQualityColor(ITEMQUALITY_HEIRLOOM)
		button.backdrop:SetBackdropBorderColor(r, g, b)
	else
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end

	-- Blizzard's text colours are made for the collections tile
	if not E.private.skins.parchmentRemoverEnable then return end

	if collected then
		button.name:SetTextColor(0.9, 0.9, 0.9)
		button.level:SetTextColor(0.9, 0.9, 0.9)
		button.special:SetTextColor(1, .82, 0)
	else
		button.name:SetTextColor(0.4, 0.4, 0.4)
		button.level:SetTextColor(0.4, 0.4, 0.4)
		button.special:SetTextColor(0.4, 0.4, 0.4)
	end
end

local function HeirloomsJournalLayoutCurrentPage()
	local headers = _G.HeirloomsJournal.heirloomHeaderFrames
	if headers and next(headers) then
		for _, header in next, headers do
			header.text:FontTemplate(nil, 15, 'SHADOW')

			if E.private.skins.parchmentRemoverEnable then
				header:StripTextures()
				header.text:SetTextColor(0.9, 0.9, 0.9)
			end
		end
	end
end

local function SetsFrame_ScrollBoxUpdateChild(child)
	if not child.IsSkinned then
		child.Background:Hide()
		child.HighlightTexture:SetTexture(E.ClearTexture)
		child.IconFrame.Icon:SetSize(42, 42)
		S:HandleIcon(child.IconFrame.Icon)

		child.SelectedTexture:SetDrawLayer('BACKGROUND')
		child.SelectedTexture:SetColorTexture(1, 1, 1, .25)
		child.SelectedTexture:ClearAllPoints()
		child.SelectedTexture:Point('TOPLEFT', 4, -2)
		child.SelectedTexture:Point('BOTTOMRIGHT', -1, 2)
		child.SelectedTexture:CreateBackdrop('Transparent')

		child.IsSkinned = true
	end
end

local function SetsFrame_ScrollBoxUpdate(frame)
	frame:ForEachFrame(SetsFrame_ScrollBoxUpdateChild)
end

local function SetsFrame_SetItemFrameQuality(_, itemFrame)
	local icon = itemFrame.Icon
	if not icon.backdrop then
		icon:CreateBackdrop()
		icon:SetTexCoords()
		itemFrame.IconBorder:Hide()
	end

	local source = itemFrame.collected and itemFrame.sourceID and C_TransmogCollection_GetSourceInfo(itemFrame.sourceID)
	local r, g, b = E:GetItemQualityColor(source and source.quality)
	icon.backdrop:SetBackdropBorderColor(r, g, b)
end

local function SkinMountFrame()
	S:HandleItemButton(_G.MountJournal.SummonRandomFavoriteSpellFrame.Button)
	S:HandleButton(_G.MountJournal.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')

	_G.MountJournal.FilterDropdown:ClearAllPoints()
	_G.MountJournal.FilterDropdown:Point('LEFT', _G.MountJournalSearchBox, 'RIGHT', 5, 0)

	S:HandleCloseButton(_G.MountJournal.FilterDropdown.ResetButton)
	_G.MountJournal.FilterDropdown.ResetButton:ClearAllPoints()
	_G.MountJournal.FilterDropdown.ResetButton:Point('CENTER', _G.MountJournal.FilterDropdown, 'TOPRIGHT', 0, 0)

	local MountJournal = _G.MountJournal
	MountJournal:StripTextures()
	MountJournal.MountCount:StripTextures()

	local MountDisplay = MountJournal.MountDisplay
	MountDisplay:StripTextures()
	MountDisplay.ShadowOverlay:StripTextures()
	MountDisplay.ModelScene.TogglePlayer:Size(22)

	S:HandleIcon(MountDisplay.InfoButton.Icon, true)
	S:HandleCheckBox(MountDisplay.ModelScene.TogglePlayer)
	S:HandleModelSceneControlButtons(MountDisplay.ModelScene.ControlFrame)

	S:HandleButton(_G.MountJournalMountButton)
	_G.MountJournalMountButton:NudgePoint(0, -3)
	S:HandleEditBox(_G.MountJournalSearchBox)
	S:HandleTrimScrollBar(_G.MountJournal.ScrollBar)
	hooksecurefunc(MountJournal.ScrollBox, 'Update', JournalScrollButtons)
end

local function SkinPetFrame()
	local PetJournal = _G.PetJournal

	_G.PetJournalSummonButton:StripTextures()
	S:HandleButton(_G.PetJournalSummonButton)
	_G.PetJournalRightInset:StripTextures()
	_G.PetJournalLeftInset:StripTextures()
	S:HandleItemButton(PetJournal.SummonRandomPetSpellFrame.Button, true)
	E:RegisterCooldown(PetJournal.SummonRandomPetSpellFrame.Button.Cooldown)

	PetJournal.PetCount:StripTextures()
	S:HandleEditBox(_G.PetJournalSearchBox)
	_G.PetJournalSearchBox:ClearAllPoints()
	_G.PetJournalSearchBox:Point('TOPLEFT', _G.PetJournalLeftInset, 'TOPLEFT', (E.PixelMode and 13 or 10), -9)

	S:HandleButton(PetJournal.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	PetJournal.FilterDropdown:Height(E.PixelMode and 22 or 24)
	PetJournal.FilterDropdown:ClearAllPoints()
	PetJournal.FilterDropdown:Point('TOPRIGHT', _G.PetJournalLeftInset, 'TOPRIGHT', -5, -(E.PixelMode and 8 or 7))
	S:HandleCloseButton(PetJournal.FilterDropdown.ResetButton)
	PetJournal.FilterDropdown.ResetButton:ClearAllPoints()
	PetJournal.FilterDropdown.ResetButton:Point('CENTER', PetJournal.FilterDropdown, 'TOPRIGHT', 0, 0)

	S:HandleTrimScrollBar(PetJournal.ScrollBar)
	hooksecurefunc(PetJournal.ScrollBox, 'Update', JournalScrollButtons)

	local Card = _G.PetJournalPetCard
	Card:StripTextures()
	Card:SetTemplate('Transparent')

	Card.ShadowOverlay:Hide()
	Card.PetInfo:OffsetFrameLevel(2, Card)

	S:HandleIcon(Card.PetInfo.icon, true)
end

local function SkinToyFrame()
	local ToyBox = _G.ToyBox
	S:HandleEditBox(ToyBox.searchBox)

	S:HandleButton(_G.ToyBox.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	_G.ToyBox.FilterDropdown:Point('LEFT', ToyBox.searchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(_G.ToyBox.FilterDropdown.ResetButton)
	_G.ToyBox.FilterDropdown.ResetButton:ClearAllPoints()
	_G.ToyBox.FilterDropdown.ResetButton:Point('CENTER', _G.ToyBox.FilterDropdown, 'TOPRIGHT', 0, 0)

	HandleCollectionsBackground(ToyBox.iconsFrame)
	S:HandleNextPrevButton(ToyBox.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(ToyBox.PagingFrame.PrevPageButton, nil, nil, true)

	ToyBox.ProgressTracker:StripTextures()

	for i = 1, 18 do
		local button = ToyBox.iconsFrame['spellButton'..i]
		S:HandleItemButton(button, true)

		button.iconTextureUncollected:SetTexCoords()
		button.iconTextureUncollected:SetInside(button)
		button.hover:SetAllPoints(button.iconTexture)
		button.checked:SetAllPoints(button.iconTexture)
		button.pushed:SetAllPoints(button.iconTexture)
		button.cooldown:SetAllPoints(button.iconTexture)

		E:RegisterCooldown(button.cooldown)

		if E.private.skins.parchmentRemoverEnable then
			hooksecurefunc(button.name, 'SetTextColor', ToyTextColor)
			hooksecurefunc(button.new, 'SetTextColor', ToyTextColor)
		end
	end

	hooksecurefunc('ToySpellButton_UpdateButton', ToySpellButtonUpdateButton)
end

local function SkinHeirloomFrame()
	local HeirloomsJournal = _G.HeirloomsJournal
	S:HandleEditBox(HeirloomsJournal.SearchBox)
	HandleCollectionsBackground(HeirloomsJournal.iconsFrame)

	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.PrevPageButton, nil, nil, true)
	S:HandleDropDownBox(_G.HeirloomsJournal.ClassDropdown)

	S:HandleButton(_G.HeirloomsJournal.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	S:HandleCloseButton(_G.HeirloomsJournal.FilterDropdown.ResetButton)
	_G.HeirloomsJournal.FilterDropdown.ResetButton:ClearAllPoints()
	_G.HeirloomsJournal.FilterDropdown.ResetButton:Point('CENTER', _G.HeirloomsJournal.FilterDropdown, 'TOPRIGHT', 0, 0)

	HeirloomsJournal.progressBar.border:Hide()
	HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
	HeirloomsJournal.progressBar:SetStatusBarTexture(E.media.normTex)
	HeirloomsJournal.progressBar:CreateBackdrop()
	E:RegisterStatusBar(HeirloomsJournal.progressBar)

	hooksecurefunc(HeirloomsJournal, 'UpdateButton', HeirloomsJournalUpdateButton)
	hooksecurefunc(HeirloomsJournal, 'LayoutCurrentPage', HeirloomsJournalLayoutCurrentPage)
end

local function ModelBorderSetAtlas(frame, texture)
	local model = frame:GetParent()
	if texture == 'transmog-wardrobe-border-uncollected' then
		frame.border:SetBackdropBorderColor(0.9, 0.9, 0.3)
	elseif texture == 'transmog-wardrobe-border-unusable' then
		frame.border:SetBackdropBorderColor(0.9, 0.3, 0.3)
	elseif model.TransmogStateTexture:IsShown() then
		frame.border:SetBackdropBorderColor(1, 0.7, 1)
	else
		frame.border:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function SkinWardrobeFrame()
	local WardrobeCollectionFrame = _G.WardrobeCollectionFrame
	S:HandleTab(_G.WardrobeCollectionFrameTab1)
	S:HandleTab(_G.WardrobeCollectionFrameTab2)

	local ProgressBar = WardrobeCollectionFrame.progressBar
	ProgressBar.border:Hide()
	ProgressBar:DisableDrawLayer('BACKGROUND')
	ProgressBar:SetStatusBarTexture(E.media.normTex)
	ProgressBar:CreateBackdrop()
	E:RegisterStatusBar(ProgressBar)

	if E.global.general.disableTutorialButtons then
		WardrobeCollectionFrame.InfoButton:Kill()
	end

	S:HandleEditBox(_G.WardrobeCollectionFrameSearchBox)
	_G.WardrobeCollectionFrameSearchBox:SetFrameLevel(5)
	S:HandleDropDownBox(_G.WardrobeCollectionFrame.ClassDropdown, 145)

	S:HandleButton(WardrobeCollectionFrame.FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	WardrobeCollectionFrame.FilterButton:Point('LEFT', WardrobeCollectionFrame.searchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(WardrobeCollectionFrame.FilterButton.ResetButton)
	WardrobeCollectionFrame.FilterButton.ResetButton:ClearAllPoints()
	WardrobeCollectionFrame.FilterButton.ResetButton:Point('CENTER', WardrobeCollectionFrame.FilterButton, 'TOPRIGHT', 0, 0)

	S:HandleDropDownBox(_G.WardrobeCollectionFrame.ItemsCollectionFrame.WeaponDropdown)
	HandleCollectionsBackground(WardrobeCollectionFrame.ItemsCollectionFrame)
	WardrobeCollectionFrame.ItemsCollectionFrame:SetTemplate('Transparent')

	for _, Frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
		if Frame.Models then
			for _, Model in pairs(Frame.Models) do
				Model.Border:SetAlpha(0)
				Model.TransmogStateTexture:SetAlpha(0)

				local border = CreateFrame('Frame', nil, Model)
				border:SetTemplate()
				border:ClearAllPoints()
				border:Point('TOPLEFT', Model, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
				border:Point('BOTTOMRIGHT', Model, 'BOTTOMRIGHT', 1, -1)
				border:SetBackdropColor(0, 0, 0, 0)
				border.callbackBackdropColor = ClearBackdrop

				Model.Border.border = border -- used by ModelBorderSetAtlas

				Model.NewGlow:SetParent(border)
				Model.NewString:SetParent(border)

				for _, region in next, { Model:GetRegions() } do
					if region:IsObjectType('Texture') then -- check for hover glow
						local texture, regionName = region:GetTexture(), region:GetDebugName() -- find transmogrify.blp (sets:1569530 or items:1116940)
						if texture == 1569530 or (texture == 1116940 and not strfind(regionName, 'SlotInvalidTexture') and not strfind(regionName, 'DisabledOverlay')) then
							region:SetColorTexture(1, 1, 1, .25)
							region:SetBlendMode('ADD')
							region:SetAllPoints(Model)
						end
					end
				end

				hooksecurefunc(Model.Border, 'SetAtlas', ModelBorderSetAtlas)
			end
		end

		local paging = Frame.PagingFrame
		if paging then
			S:HandleNextPrevButton(paging.PrevPageButton, nil, nil, true)
			S:HandleNextPrevButton(paging.NextPageButton, nil, nil, true)
		end
	end

	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame:SetTemplate('Transparent')
	HandleCollectionsBackground(SetsCollectionFrame.RightInset)
	SetsCollectionFrame.LeftInset:StripTextures()
	S:HandleTrimScrollBar(SetsCollectionFrame.ListContainer.ScrollBar)
	hooksecurefunc(SetsCollectionFrame.ListContainer.ScrollBox, 'Update', SetsFrame_ScrollBoxUpdate)

	local DetailsFrame = SetsCollectionFrame.DetailsFrame
	DetailsFrame.ModelFadeTexture:Hide()
	DetailsFrame.IconRowBackground:Hide()
	DetailsFrame.Name:FontTemplate(nil, 16)
	DetailsFrame.LongName:FontTemplate(nil, 16)
	S:HandleDropDownBox(DetailsFrame.VariantSetsDropdown)
	hooksecurefunc(SetsCollectionFrame, 'SetItemFrameQuality', SetsFrame_SetItemFrameQuality)
end

local function CheckAndDisplayTabs()
	local CollectionsJournal = _G.CollectionsJournal
	S:LayoutLargeSideTabs(CollectionsJournal, CollectionsJournal.TabContainer.Tabs)
end

function S:Blizzard_Collections()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.collections) then return end

	S:HandlePortraitFrame(_G.CollectionsJournal, true)
	SkinWardrobeFrame()

	for _, tab in next, _G.CollectionsJournal.TabContainer.Tabs do
		S:HandleLargeSideTab(tab)
	end

	hooksecurefunc('CollectionsJournal_CheckAndDisplayTabs', CheckAndDisplayTabs)
	CheckAndDisplayTabs()

	SkinMountFrame()
	SkinPetFrame()
	SkinToyFrame()
	SkinHeirloomFrame()
end

S:AddCallbackForAddon('Blizzard_Collections')
