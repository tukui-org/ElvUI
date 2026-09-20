local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
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
		local _, g, b = button.background:GetVertexColor()
		if g == 0 and b == 0 then
			name:SetTextColor(0.9, 0.3, 0.3)
		else
			name:SetTextColor(0.9, 0.9, 0.9)
		end
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
	if button.selected then
		button.backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		button.backdrop:SetBackdropBorderColor(r, g, b)
	end

	button.hovered = nil
end

local function HandleJournalButton(bu, dragButton)
	local icon = bu.icon
	local savedIconTexture = icon:GetTexture()
	icon:Size(40)
	icon:Point('LEFT', -43, 0)
	S:HandleIcon(icon, true)
	S:HandleIconBorder(bu.iconBorder, icon.backdrop)

	bu:StripTextures()
	bu:CreateBackdrop('Transparent', nil, nil, true)
	bu.backdrop:ClearAllPoints()
	bu.backdrop:Point('TOPLEFT', bu, 0, -2)
	bu.backdrop:Point('BOTTOMRIGHT', bu, 0, 2)
	icon:SetTexture(savedIconTexture) -- restore the texture

	bu:HookScript('OnEnter', ButtonOnEnter)
	bu:HookScript('OnLeave', ButtonOnLeave)

	bu.selectedTexture:SetTexture()
	hooksecurefunc(bu.selectedTexture, 'Show', SelectedTextureShow)
	hooksecurefunc(bu.selectedTexture, 'Hide', SelectedTextureHide)

	local hl = dragButton:GetHighlightTexture()
	hl:SetTexture(E.media.blankTex)
	hl:SetVertexColor(1, 1, 1, .25)
	hl:SetAllPoints(icon)

	dragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
	dragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)
end

local function SkinPetScrollButton(bu)
	if bu.IsSkinned then return end

	local petTypeIcon = bu.petTypeIcon
	local savedPetTypeTexture = petTypeIcon:GetTexture()
	HandleJournalButton(bu, bu.dragButton)

	bu.petList = true
	petTypeIcon:SetTexture(savedPetTypeTexture)
	petTypeIcon:Point('TOPRIGHT', -1, -1)
	petTypeIcon:Point('BOTTOMRIGHT', -1, 1)

	bu.IsSkinned = true
end

local function SkinMountScrollButton(bu)
	if bu.IsSkinned then return end

	local factionIcon = bu.factionIcon
	local savedFactionAtlas = factionIcon:GetAtlas()
	HandleJournalButton(bu, bu.DragButton)

	bu.mountList = true
	factionIcon:SetAtlas(savedFactionAtlas)
	factionIcon:SetDrawLayer('OVERLAY')
	factionIcon:Point('TOPRIGHT', -1, -1)
	factionIcon:Point('BOTTOMRIGHT', -1, 1)

	bu.icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

	bu.favorite:SetTexture([[Interface\COMMON\FavoritesIcon]])
	bu.favorite:Point('TOPLEFT', bu.DragButton, 'TOPLEFT' , -8, 8)
	bu.favorite:Size(32)

	hooksecurefunc(bu.name, 'SetFontObject', MountNameColor)
	hooksecurefunc(bu.background, 'SetVertexColor', MountNameColor)

	bu.IsSkinned = true
end

local function PetScrollButtons(frame)
	frame:ForEachFrame(SkinPetScrollButton)
end

local function MountScrollButtons(frame)
	frame:ForEachFrame(SkinMountScrollButton)
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

		E:RegisterCooldown(button.cooldown)

		button.IsSkinned = true
	end

	if C_Heirloom_PlayerHasHeirloom(button.itemID) then
		local r, g, b = E:GetItemQualityColor(ITEMQUALITY_HEIRLOOM)
		button.name:SetTextColor(0.9, 0.9, 0.9)
		button.special:SetTextColor(1, .82, 0)
		button.backdrop:SetBackdropBorderColor(r, g, b)
	else
		button.name:SetTextColor(0.4, 0.4, 0.4)
		button.special:SetTextColor(0.4, 0.4, 0.4)
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function HeirloomsJournalLayoutCurrentPage()
	for _, header in next, _G.HeirloomsJournal.heirloomHeaderFrames do
		header:StripTextures()
		header.text:FontTemplate(nil, 15, 'SHADOW')
		header.text:SetTextColor(0.9, 0.9, 0.9)
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
	local MountJournal = _G.MountJournal
	MountJournal:StripTextures()
	MountJournal.MountCount:StripTextures()

	local FilterDropdown = MountJournal.FilterDropdown
	S:HandleButton(FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	FilterDropdown:ClearAllPoints()
	FilterDropdown:Point('LEFT', _G.MountJournalSearchBox, 'RIGHT', 5, 0)
	S:HandleCloseButton(FilterDropdown.ResetButton)
	FilterDropdown.ResetButton:ClearAllPoints()
	FilterDropdown.ResetButton:Point('CENTER', FilterDropdown, 'TOPRIGHT', 0, 0)

	local MountDisplay = MountJournal.MountDisplay
	MountDisplay:StripTextures()
	MountDisplay.ShadowOverlay:StripTextures()
	S:HandleRotateButton(MountDisplay.ModelScene.RotateLeftButton)
	S:HandleRotateButton(MountDisplay.ModelScene.RotateRightButton)
	S:HandleIcon(MountDisplay.InfoButton.Icon, true)

	S:HandleButton(_G.MountJournalMountButton)
	_G.MountJournalMountButton:NudgePoint(0, -3)
	S:HandleEditBox(_G.MountJournalSearchBox)
	S:HandleTrimScrollBar(MountJournal.ScrollBar)

	hooksecurefunc(MountJournal.ScrollBox, 'Update', MountScrollButtons)
end

local function SkinPetFrame()
	_G.PetJournalSummonButton:StripTextures()
	S:HandleButton(_G.PetJournalSummonButton)
	_G.PetJournalRightInset:StripTextures()
	_G.PetJournalLeftInset:StripTextures()

	local PetJournal = _G.PetJournal
	PetJournal.PetCount:StripTextures()
	S:HandleEditBox(_G.PetJournalSearchBox)
	_G.PetJournalSearchBox:ClearAllPoints()
	_G.PetJournalSearchBox:Point('TOPLEFT', _G.PetJournalLeftInset, 'TOPLEFT', (E.PixelMode and 13 or 10), -9)

	local FilterDropdown = PetJournal.FilterDropdown
	S:HandleButton(FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	FilterDropdown:Height(E.PixelMode and 22 or 24)
	FilterDropdown:ClearAllPoints()
	FilterDropdown:Point('TOPRIGHT', _G.PetJournalLeftInset, 'TOPRIGHT', -5, -(E.PixelMode and 8 or 7))
	S:HandleCloseButton(FilterDropdown.ResetButton)
	FilterDropdown.ResetButton:ClearAllPoints()
	FilterDropdown.ResetButton:Point('CENTER', FilterDropdown, 'TOPRIGHT', 0, 0)

	S:HandleTrimScrollBar(PetJournal.ScrollBar)
	hooksecurefunc(PetJournal.ScrollBox, 'Update', PetScrollButtons)

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

	local FilterDropdown = ToyBox.FilterDropdown
	S:HandleButton(FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	FilterDropdown:Point('LEFT', ToyBox.searchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(FilterDropdown.ResetButton)
	FilterDropdown.ResetButton:ClearAllPoints()
	FilterDropdown.ResetButton:Point('CENTER', FilterDropdown, 'TOPRIGHT', 0, 0)

	ToyBox.iconsFrame:StripTextures()
	S:HandleNextPrevButton(ToyBox.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(ToyBox.PagingFrame.PrevPageButton, nil, nil, true)

	ToyBox.progressBar.border:Hide()
	ToyBox.progressBar:DisableDrawLayer('BACKGROUND')
	ToyBox.progressBar:SetStatusBarTexture(E.media.normTex)
	ToyBox.progressBar:CreateBackdrop()
	E:RegisterStatusBar(ToyBox.progressBar)

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

		hooksecurefunc(button.name, 'SetTextColor', ToyTextColor)
		hooksecurefunc(button.new, 'SetTextColor', ToyTextColor)
	end

	hooksecurefunc('ToySpellButton_UpdateButton', ToySpellButtonUpdateButton)
end

local function SkinHeirloomFrame()
	local HeirloomsJournal = _G.HeirloomsJournal
	S:HandleEditBox(HeirloomsJournal.SearchBox)
	HeirloomsJournal.iconsFrame:StripTextures()

	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.PrevPageButton, nil, nil, true)
	S:HandleDropDownBox(HeirloomsJournal.ClassDropdown)

	local FilterDropdown = HeirloomsJournal.FilterDropdown
	S:HandleButton(FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	S:HandleCloseButton(FilterDropdown.ResetButton)
	FilterDropdown.ResetButton:ClearAllPoints()
	FilterDropdown.ResetButton:Point('CENTER', FilterDropdown, 'TOPRIGHT', 0, 0)

	HeirloomsJournal.progressBar.border:Hide()
	HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
	HeirloomsJournal.progressBar:SetStatusBarTexture(E.media.normTex)
	HeirloomsJournal.progressBar:CreateBackdrop()
	E:RegisterStatusBar(HeirloomsJournal.progressBar)

	hooksecurefunc(HeirloomsJournal, 'UpdateButton', HeirloomsJournalUpdateButton)
	hooksecurefunc(HeirloomsJournal, 'LayoutCurrentPage', HeirloomsJournalLayoutCurrentPage)
end

local function SkinTransmogFrames()
	local WardrobeCollectionFrame = _G.WardrobeCollectionFrame
	S:HandleTab(WardrobeCollectionFrame.ItemsTab)
	S:HandleTab(WardrobeCollectionFrame.SetsTab)

	local WardrobeProgressBar = WardrobeCollectionFrame.progressBar
	WardrobeProgressBar:StripTextures()
	WardrobeProgressBar:CreateBackdrop()
	WardrobeProgressBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(WardrobeProgressBar)

	local SearchBox = WardrobeCollectionFrame.SearchBox
	S:HandleEditBox(SearchBox)
	SearchBox:SetFrameLevel(5)

	local FilterButton = WardrobeCollectionFrame.FilterButton
	S:HandleButton(FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	FilterButton:Point('LEFT', SearchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(FilterButton.ResetButton)
	FilterButton.ResetButton:ClearAllPoints()
	FilterButton.ResetButton:Point('CENTER', FilterButton, 'TOPRIGHT', 0, 0)

	local ItemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame
	S:HandleDropDownBox(ItemsCollectionFrame.WeaponDropdown)
	ItemsCollectionFrame:StripTextures()
	ItemsCollectionFrame:SetTemplate('Transparent')
	S:HandleNextPrevButton(ItemsCollectionFrame.PagingFrame.PrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(ItemsCollectionFrame.PagingFrame.NextPageButton, nil, nil, true)

	for _, Model in next, ItemsCollectionFrame.Models do
		Model.Border:SetAlpha(0)
		Model.TransmogStateTexture:SetAlpha(0)

		local border = CreateFrame('Frame', nil, Model)
		border:SetTemplate()
		border:ClearAllPoints()
		border:Point('TOPLEFT', Model, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
		border:Point('BOTTOMRIGHT', Model, 'BOTTOMRIGHT', 1, -1)
		border:SetBackdropColor(0, 0, 0, 0)
		border.callbackBackdropColor = ClearBackdrop

		Model.NewGlow:SetParent(border)
		Model.NewString:SetParent(border)

		for _, region in next, { Model:GetRegions() } do
			if region:IsObjectType('Texture') and region:GetTexture() == 1116940 then -- transmogrify.blp, the hover glow atlas
				region:SetColorTexture(1, 1, 1, .25)
				region:SetBlendMode('ADD')
				region:SetAllPoints(Model)
			end
		end

		hooksecurefunc(Model.Border, 'SetAtlas', function(_, texture)
			if texture == 'transmog-wardrobe-border-uncollected' then
				border:SetBackdropBorderColor(0.9, 0.9, 0.3)
			elseif texture == 'transmog-wardrobe-border-unusable' then
				border:SetBackdropBorderColor(0.9, 0.3, 0.3)
			elseif Model.TransmogStateTexture:IsShown() then
				border:SetBackdropBorderColor(1, 0.7, 1)
			else
				border:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end)
	end

	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame:SetTemplate('Transparent')
	SetsCollectionFrame.RightInset:StripTextures()
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

local function HandleTabs()
	local tab = _G.CollectionsJournalTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.CollectionsJournal, 'BOTTOMLEFT', -10, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['CollectionsJournalTab'..index]
	end
end

local function SkinCollectionsFrames()
	S:HandlePortraitFrame(_G.CollectionsJournal, true)

	HandleTabs()

	SkinMountFrame()
	SkinPetFrame()
	SkinToyFrame()
	SkinHeirloomFrame()
end

function S:Blizzard_Collections()
	if not E.private.skins.blizzard.enable then return end
	if E.private.skins.blizzard.collections then SkinCollectionsFrames() end
	if E.private.skins.blizzard.transmogrify then SkinTransmogFrames() end
end

S:AddCallbackForAddon('Blizzard_Collections')
