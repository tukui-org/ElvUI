local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next, unpack = next, unpack
local ipairs, pairs = ipairs, pairs
local select, strfind = select, strfind
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local PlayerHasToy = PlayerHasToy

local C_Heirloom_PlayerHasHeirloom = C_Heirloom.PlayerHasHeirloom
local C_TransmogCollection_GetSourceInfo = C_TransmogCollection.GetSourceInfo
local GetItemQualityByID = C_Item.GetItemQualityByID

local ITEMQUALITY_HEIRLOOM = Enum.ItemQuality.Heirloom or 7

local data = S:AddCallbackForAddon('Blizzard_Collections')
function data.check() -- every section checks its own toggle
	return E.private.skins.blizzard.enable
end

local function ClearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 0)
end

local function CheckAndDisplayHeirloomsTab()
	_G.CollectionsJournalTab5:Point('TOPLEFT', E.TimerunningID and _G.CollectionsJournalTab3 or _G.CollectionsJournalTab4, 'TOPRIGHT', -5, 0)
end

local function CheckAndDisplayTabs()
	local CollectionsJournal = _G.CollectionsJournal
	S:LayoutLargeSideTabs(CollectionsJournal, CollectionsJournal.TabContainer.Tabs)
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

local function SkinJournalScrollButton(bu)
	if not bu.IsSkinned then
		local icon = bu.icon
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

		bu.selectedTexture:SetTexture()
		hooksecurefunc(bu.selectedTexture, 'Show', SelectedTextureShow)
		hooksecurefunc(bu.selectedTexture, 'Hide', SelectedTextureHide)

		local parent = bu:GetParent():GetParent():GetParent()
		if parent == _G.PetJournal then
			bu.petList = true

			bu.petTypeIcon:SetTexture(savedPetTypeTexture)
			bu.petTypeIcon:Point('TOPRIGHT', -1, -1)
			bu.petTypeIcon:Point('BOTTOMRIGHT', -1, 1)

			bu.dragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
			bu.dragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)

			-- Forever and Wrath load the Classic pet journal
			if E.Retail or E.Mists then
				bu.dragButton.levelBG:SetTexture()
				bu.dragButton.level:FontTemplate(nil, 12)
			end

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

	if E.Modern then
		button.levelBackground:SetTexture()

		button.name:Point('LEFT', button, 'RIGHT', 4, 8)
		button.level:Point('TOPLEFT', button.levelBackground,'TOPLEFT', 25, 2)
	end

	if C_Heirloom_PlayerHasHeirloom(button.itemID) then
		local r, g, b = E:GetItemQualityColor(ITEMQUALITY_HEIRLOOM)
		button.name:SetTextColor(0.9, 0.9, 0.9)
		if E.Modern then button.level:SetTextColor(0.9, 0.9, 0.9) end
		button.special:SetTextColor(1, .82, 0)
		button.backdrop:SetBackdropBorderColor(r, g, b)
	else
		button.name:SetTextColor(0.4, 0.4, 0.4)
		if E.Modern then button.level:SetTextColor(0.4, 0.4, 0.4) end
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

local function HandleDynamicFlightButton(button, index)
	if button.BorderShadow then button.BorderShadow:SetAlpha(0) end
	if button.Border then button.Border:SetAlpha(0) end

	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	button:SetPushedTexture(0)
	button:SetNormalTexture(0)

	local region = select(index, button:GetRegions())
	S:HandleIcon(region, true) -- the icon texture has no key
end

local function SkinMountFrame()
	if E.Modern then
		S:HandleItemButton(_G.MountJournal.SummonRandomFavoriteSpellFrame.Button)
		HandleDynamicFlightButton(_G.MountJournal.ToggleDynamicFlightFlyoutButton, 3)

		local Flyout = _G.MountJournal.DynamicFlightFlyoutPopup
		Flyout.Background:Hide()
		HandleDynamicFlightButton(Flyout.DynamicFlightModeButton, 4)
		HandleDynamicFlightButton(Flyout.OpenDynamicFlightSkillTreeButton, 4)
	end

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

	if E.Modern then
		MountDisplay.ModelScene.TogglePlayer:Size(22)
		S:HandleCheckBox(MountDisplay.ModelScene.TogglePlayer)
		S:HandleModelSceneControlButtons(MountDisplay.ModelScene.ControlFrame)
	else
		S:HandleRotateButton(MountDisplay.ModelScene.RotateLeftButton)
		S:HandleRotateButton(MountDisplay.ModelScene.RotateRightButton)
	end

	S:HandleIcon(MountDisplay.InfoButton.Icon, true)

	S:HandleButton(_G.MountJournalMountButton)
	_G.MountJournalMountButton:NudgePoint(0, -3)
	S:HandleEditBox(_G.MountJournalSearchBox)
	S:HandleTrimScrollBar(_G.MountJournal.ScrollBar)

	if E.Modern then
		MountJournal.BottomLeftInset:StripTextures()
		MountJournal.BottomLeftInset:SetTemplate('Transparent')
		MountJournal.BottomLeftInset.SlotButton:StripTextures()
		S:HandleIcon(MountJournal.BottomLeftInset.SlotButton.ItemIcon)
		S:HandleButton(MountJournal.BottomLeftInset.SlotButton, nil, nil, nil, true)
		MountJournal.BottomLeftInset.SlotButton.backdrop:SetOutside(nil, -3, -3)
	end

	hooksecurefunc(MountJournal.ScrollBox, 'Update', JournalScrollButtons)
end

local function SkinPetFrame()
	local PetJournal = _G.PetJournal

	_G.PetJournalSummonButton:StripTextures()
	S:HandleButton(_G.PetJournalSummonButton)
	_G.PetJournalRightInset:StripTextures()
	_G.PetJournalLeftInset:StripTextures()

	if not E.Wrath then
		S:HandleItemButton(PetJournal.SummonRandomPetSpellFrame.Button, true)
		E:RegisterCooldown(PetJournal.SummonRandomPetSpellFrame.Button.Cooldown)
	end

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

	-- Forever and Wrath load the Classic pet journal
	if E.Retail or E.Mists then
		_G.PetJournalFindBattle:StripTextures()
		S:HandleButton(_G.PetJournalFindBattle)

		if E.global.general.disableTutorialButtons then
			_G.PetJournalTutorialButton:Kill()
		end

		_G.PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')

		S:HandleItemButton(PetJournal.HealPetSpellFrame.Button, true)
		E:RegisterCooldown(PetJournal.HealPetSpellFrame.Button.Cooldown)
		PetJournal.HealPetSpellFrame.Button.Icon:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
		_G.PetJournalLoadoutBorder:StripTextures()
		_G.PetJournalSpellSelect:StripTextures()

		for i = 1, 3 do
			local petButton = _G['PetJournalLoadoutPet'..i]
			local petButtonHighlight = _G['PetJournalLoadoutPet'..i..'Highlight']
			local petButtonHealthFrame = _G['PetJournalLoadoutPet'..i..'HealthFrame']
			local petButtonXPBar = _G['PetJournalLoadoutPet'..i..'XPBar']
			petButton:StripTextures()
			petButton:SetTemplate()
			petButton.petTypeIcon:Point('BOTTOMLEFT', 2, 2)

			petButtonHighlight:SetTexture(E.media.blankTex)
			petButtonHighlight:SetVertexColor(1, 1, 1, .25)
			petButtonHighlight:SetAllPoints(petButton.icon)

			local helpFrame = _G['PetJournalLoadoutPet'..i..'HelpFrame']
			helpFrame:StripTextures()

			petButton.dragButton:SetOutside(_G['PetJournalLoadoutPet'..i..'Icon'])
			petButton.dragButton:OffsetFrameLevel(1, _G['PetJournalLoadoutPet'..i].dragButton)

			petButton.hover = true
			petButton.pushed = true
			petButton.checked = true
			S:HandleItemButton(petButton)
			S:HandleIconBorder(petButton.qualityBorder, petButton.backdrop)

			petButton.levelBG:SetTexture()
			petButton.level:FontTemplate(nil, 12)

			petButton.setButton:StripTextures()
			petButtonHealthFrame.healthBar:StripTextures()
			petButtonHealthFrame.healthBar:CreateBackdrop()
			petButtonHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
			E:RegisterStatusBar(petButtonHealthFrame.healthBar)
			petButtonXPBar:StripTextures()
			petButtonXPBar:CreateBackdrop()
			petButtonXPBar:SetStatusBarTexture(E.media.normTex)
			E:RegisterStatusBar(petButtonXPBar)
			petButtonXPBar:OffsetFrameLevel(2)

			for index = 1, 3 do
				local f = _G['PetJournalLoadoutPet'..i..'Spell'..index]
				S:HandleItemButton(f)
				f.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
				_G['PetJournalLoadoutPet'..i..'Spell'..index..'Icon']:SetInside(f)
			end
		end

		for i = 1, 2 do
			local btn = _G['PetJournalSpellSelectSpell'..i]
			S:HandleItemButton(btn)

			local icon = _G['PetJournalSpellSelectSpell'..i..'Icon']
			icon:SetInside(btn)
			icon:SetDrawLayer('BORDER')
		end
	end

	local Card = _G.PetJournalPetCard

	Card:StripTextures()
	Card:SetTemplate('Transparent')

	Card.PetInfo:OffsetFrameLevel(2, Card)
	S:HandleIcon(Card.PetInfo.icon, true)

	if E.Retail or E.Mists then
		_G.PetJournalPetCardInset:StripTextures()

		Card.PetInfo.level:FontTemplate(nil, 12)
		Card.PetInfo.levelBG:SetTexture()
		S:HandleIconBorder(Card.PetInfo.qualityBorder, Card.PetInfo.icon.backdrop)
		Card.PetInfo.qualityBorder:SetAlpha(0)

		if E.private.skins.blizzard.tooltip then
			TT:SetStyle(_G.PetJournalPrimaryAbilityTooltip)
		end

		for i = 1, 6 do
			local frame = _G['PetJournalPetCardSpell'..i]
			frame:OffsetFrameLevel(2)
			frame:DisableDrawLayer('BACKGROUND')
			frame:SetTemplate()
			frame.icon:SetTexCoords()
		end

		Card.HealthFrame.healthBar:StripTextures()
		Card.HealthFrame.healthBar:CreateBackdrop()
		Card.HealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(Card.HealthFrame.healthBar)

		Card.xpBar:StripTextures()
		Card.xpBar:CreateBackdrop()
		Card.xpBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(Card.xpBar)
	else
		Card.ShadowOverlay:Hide()
	end
end

local function SkinToyFrame()
	local ToyBox = _G.ToyBox
	S:HandleEditBox(ToyBox.searchBox)

	S:HandleButton(_G.ToyBox.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	_G.ToyBox.FilterDropdown:Point('LEFT', ToyBox.searchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(_G.ToyBox.FilterDropdown.ResetButton)
	_G.ToyBox.FilterDropdown.ResetButton:ClearAllPoints()
	_G.ToyBox.FilterDropdown.ResetButton:Point('CENTER', _G.ToyBox.FilterDropdown, 'TOPRIGHT', 0, 0)

	ToyBox.iconsFrame:StripTextures()
	S:HandleNextPrevButton(ToyBox.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(ToyBox.PagingFrame.PrevPageButton, nil, nil, true)

	if E.Forever then -- ToDo: Forever
		ToyBox.ProgressTracker:StripTextures()
	else
		ToyBox.progressBar.border:Hide()
		ToyBox.progressBar:DisableDrawLayer('BACKGROUND')
		ToyBox.progressBar:SetStatusBarTexture(E.media.normTex)
		ToyBox.progressBar:CreateBackdrop()
		E:RegisterStatusBar(ToyBox.progressBar)
	end

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

local function HandleTabs()
	local tab = _G.CollectionsJournalTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.CollectionsJournal, 'BOTTOMLEFT', E.Modern and -3 or -10, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', E.Modern and -5 or -19, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['CollectionsJournalTab'..index]
	end

	-- Blizzard clears points on the wardrobe tab
	if E.Retail then -- ToDo: Forever
		hooksecurefunc('CollectionsJournal_CheckAndDisplayHeirloomsTab', CheckAndDisplayHeirloomsTab)
	end
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

	if E.Modern then
		if E.global.general.disableTutorialButtons then
			WardrobeCollectionFrame.InfoButton:Kill()
		end

		S:HandleDropDownBox(_G.WardrobeCollectionFrame.ClassDropdown, 145)
	end

	S:HandleEditBox(_G.WardrobeCollectionFrameSearchBox)
	_G.WardrobeCollectionFrameSearchBox:SetFrameLevel(5)

	S:HandleButton(WardrobeCollectionFrame.FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	WardrobeCollectionFrame.FilterButton:Point('LEFT', WardrobeCollectionFrame.SearchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(WardrobeCollectionFrame.FilterButton.ResetButton)
	WardrobeCollectionFrame.FilterButton.ResetButton:ClearAllPoints()
	WardrobeCollectionFrame.FilterButton.ResetButton:Point('CENTER', WardrobeCollectionFrame.FilterButton, 'TOPRIGHT', 0, 0)

	S:HandleDropDownBox(_G.WardrobeCollectionFrame.ItemsCollectionFrame.WeaponDropdown)
	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()
	WardrobeCollectionFrame.ItemsCollectionFrame:SetTemplate('Transparent')

	for _, Frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
		if Frame.Models then
			for _, Model in pairs(Frame.Models) do
				local border = CreateFrame('Frame', nil, Model)
				border:SetTemplate()
				border:ClearAllPoints()
				border:Point('TOPLEFT', Model, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
				border:Point('BOTTOMRIGHT', Model, 'BOTTOMRIGHT', 1, -1)
				border:SetBackdropColor(0, 0, 0, 0)
				border.callbackBackdropColor = ClearBackdrop

				Model.Border.border = border -- used by ModelBorderSetAtlas

				Model.Border:SetAlpha(0)
				Model.TransmogStateTexture:SetAlpha(0)

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

local function SkinCollectionsFrames()
	S:HandlePortraitFrame(_G.CollectionsJournal, true)
	SkinWardrobeFrame()

	if E.Forever then
		for _, tab in next, _G.CollectionsJournal.TabContainer.Tabs do
			S:HandleLargeSideTab(tab)
		end

		hooksecurefunc('CollectionsJournal_CheckAndDisplayTabs', CheckAndDisplayTabs)
		CheckAndDisplayTabs()
	else
		HandleTabs()
	end

	SkinMountFrame()
	SkinPetFrame()
	SkinToyFrame()
	SkinHeirloomFrame()
end

local function UpdateWarbandSceneData(frame)
	if frame.warbandSceneInfo and not frame.artBackdrop then
		frame.artBackdrop = CreateFrame('Frame', nil, frame)
		frame.artBackdrop:OffsetFrameLevel(-1, frame)
		frame.artBackdrop:SetOutside(frame.Icon, -5, -5)
		frame.artBackdrop:SetTemplate()

		frame.Border:SetAlpha(0)
		S:HandleIcon(frame.Icon)

		local highlight = frame:CreateTexture()
		highlight:SetColorTexture(1, 1, 1, .25)
		highlight:SetAllPoints(frame.Icon)
		frame:SetHighlightTexture(highlight)
	end
end

local function SkinCampsitesFrame()
	local IconsFrame = _G.WarbandSceneJournal.IconsFrame
	IconsFrame:StripTextures()
	IconsFrame.NineSlice:SetTemplate('Transparent')

	local Controls = IconsFrame.Icons.Controls
	Controls.ShowOwned.Checkbox:Size(28)
	S:HandleCheckBox(Controls.ShowOwned.Checkbox)
	S:HandleNextPrevButton(Controls.PagingControls.PrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(Controls.PagingControls.NextPageButton, nil, nil, true)

	hooksecurefunc(_G.WarbandSceneEntryMixin, 'UpdateWarbandSceneData', UpdateWarbandSceneData)
end

function S:Blizzard_Collections()
	if E.private.skins.blizzard.collections then SkinCollectionsFrames() end
	if E.Retail and E.private.skins.blizzard.campsites then SkinCampsitesFrame() end
end
