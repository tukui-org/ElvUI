local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local strfind = strfind
local next, unpack = next, unpack
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

			local isPet = parent == _G.PetJournal
			local isMount = parent == _G.MountJournal

			if isPet or isMount then
				local dragBtn = bu.dragButton or bu.DragButton
				if dragBtn then
					local hl = dragBtn:GetHighlightTexture()
					hl:SetTexture(E.media.blankTex)
					hl:SetVertexColor(1, 1, 1, .25)
					hl:SetAllPoints(bu.icon)
				end
			end

			if isPet then
				bu.petList = true
				bu.petTypeIcon:SetTexture(savedPetTypeTexture)
				bu.petTypeIcon:Point('TOPRIGHT', -1, -1)
				bu.petTypeIcon:Point('BOTTOMRIGHT', -1, 1)

				bu.dragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
				bu.dragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)

				bu.dragButton.levelBG:SetTexture()
				bu.dragButton.level:FontTemplate(nil, 12)
			elseif isMount then
				bu.mountList = true
				bu.factionIcon:SetAtlas(savedFactionAtlas)
				bu.factionIcon:SetDrawLayer('OVERLAY')
				bu.factionIcon:Point('TOPRIGHT', -1, -1)
				bu.factionIcon:Point('BOTTOMRIGHT', -1, 1)

				icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

				bu.DragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
				bu.DragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)

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

		button.iconTextureUncollected:SetTexCoord(unpack(E.TexCoords))
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
	local headers = _G.HeirloomsJournal.heirloomHeaderFrames
	if headers and next(headers) then
		for _, header in next, headers do
			header:StripTextures()
			header.text:FontTemplate(nil, 15, 'SHADOW')
			header.text:SetTextColor(0.9, 0.9, 0.9)
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
		icon:SetTexCoord(unpack(E.TexCoords))
		itemFrame.IconBorder:Hide()
	end

	local source = itemFrame.collected and itemFrame.sourceID and C_TransmogCollection_GetSourceInfo(itemFrame.sourceID)
	local r, g, b = E:GetItemQualityColor(source and source.quality)
	icon.backdrop:SetBackdropBorderColor(r, g, b)
end

local function SkinMountFrame()
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
	if MountDisplay then
		MountJournal.MountDisplay:StripTextures()
		MountJournal.MountDisplay.ShadowOverlay:StripTextures()

		S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateLeftButton)
		S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateRightButton)
		S:HandleIcon(MountJournal.MountDisplay.InfoButton.Icon, true)
	end

	S:HandleButton(_G.MountJournalMountButton)
	_G.MountJournalMountButton:NudgePoint(0, -3)
	S:HandleEditBox(_G.MountJournalSearchBox)
	S:HandleTrimScrollBar(_G.MountJournal.ScrollBar)

	hooksecurefunc(MountJournal.ScrollBox, 'Update', JournalScrollButtons)
end

local function SkinPetFrame()
	_G.PetJournalSummonButton:StripTextures()
	_G.PetJournalFindBattle:StripTextures()
	S:HandleButton(_G.PetJournalSummonButton)
	S:HandleButton(_G.PetJournalFindBattle)
	_G.PetJournalRightInset:StripTextures()
	_G.PetJournalLeftInset:StripTextures()
	S:HandleItemButton(_G.PetJournal.SummonRandomPetSpellFrame.Button, true)
	E:RegisterCooldown(_G.PetJournal.SummonRandomPetSpellFrame.Button.Cooldown)
	-- _G.PetJournal.SummonRandomPetSpellFrame.Button.Cooldown:SetAllPoints(_G.PetJournal.SummonRandomPetSpellFrame.ButtonIconTexture)

	if E.global.general.disableTutorialButtons then
		_G.PetJournalTutorialButton:Kill()
	end

	local PetJournal = _G.PetJournal
	PetJournal.PetCount:StripTextures()
	S:HandleEditBox(_G.PetJournalSearchBox)
	_G.PetJournalSearchBox:ClearAllPoints()
	_G.PetJournalSearchBox:Point('TOPLEFT', _G.PetJournalLeftInset, 'TOPLEFT', (E.PixelMode and 13 or 10), -9)

	S:HandleButton(_G.PetJournal.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	_G.PetJournal.FilterDropdown:Height(E.PixelMode and 22 or 24)
	_G.PetJournal.FilterDropdown:ClearAllPoints()
	_G.PetJournal.FilterDropdown:Point('TOPRIGHT', _G.PetJournalLeftInset, 'TOPRIGHT', -5, -(E.PixelMode and 8 or 7))
	S:HandleCloseButton(_G._G.PetJournal.FilterDropdown.ResetButton)
	_G.PetJournal.FilterDropdown.ResetButton:ClearAllPoints()
	_G.PetJournal.FilterDropdown.ResetButton:Point('CENTER', _G.PetJournal.FilterDropdown, 'TOPRIGHT', 0, 0)

	S:HandleTrimScrollBar(_G.PetJournal.ScrollBar)
	hooksecurefunc(PetJournal.ScrollBox, 'Update', JournalScrollButtons)

	_G.PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')

	S:HandleItemButton(_G.PetJournal.HealPetSpellFrame.Button, true)
	E:RegisterCooldown(_G.PetJournal.HealPetSpellFrame.Button.Cooldown)
	-- _G.PetJournal.HealPetSpellFrame.Cooldown:SetAllPoints(_G.PetJournal.HealPetSpellFrame.IconTexture)
	-- _G.PetJournal.HealPetSpellFrame.IconTexture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])

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

	local Card = _G.PetJournalPetCard

	Card:StripTextures()
	Card:SetTemplate('Transparent')
	_G.PetJournalPetCardInset:StripTextures()

	Card.PetInfo:OffsetFrameLevel(2, Card)
	Card.PetInfo.level:FontTemplate(nil, 12)
	Card.PetInfo.levelBG:SetTexture()
	S:HandleIcon(Card.PetInfo.icon, true)
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
		frame.icon:SetTexCoord(unpack(E.TexCoords))
	end

	Card.HealthFrame.healthBar:StripTextures()
	Card.HealthFrame.healthBar:CreateBackdrop()
	Card.HealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(Card.HealthFrame.healthBar)

	Card.xpBar:StripTextures()
	Card.xpBar:CreateBackdrop()
	Card.xpBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(Card.xpBar)
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

	ToyBox.progressBar.border:Hide()
	ToyBox.progressBar:DisableDrawLayer('BACKGROUND')
	ToyBox.progressBar:SetStatusBarTexture(E.media.normTex)
	ToyBox.progressBar:CreateBackdrop()
	E:RegisterStatusBar(ToyBox.progressBar)

	for i = 1, 18 do
		local button = ToyBox.iconsFrame['spellButton'..i]
		S:HandleItemButton(button, true)

		button.iconTextureUncollected:SetTexCoord(unpack(E.TexCoords))
		button.iconTextureUncollected:SetInside(button)
		button.hover:SetAllPoints(button.iconTexture)
		button.checked:SetAllPoints(button.iconTexture)
		button.pushed:SetAllPoints(button.iconTexture)
		button.cooldown:SetAllPoints(button.iconTexture)

		hooksecurefunc(button.name, 'SetTextColor', ToyTextColor)
		hooksecurefunc(button.new, 'SetTextColor', ToyTextColor)
		E:RegisterCooldown(button.cooldown)
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

local function SkinTransmogFrames()
	local WardrobeCollectionFrame = _G.WardrobeCollectionFrame
	S:HandleTab(WardrobeCollectionFrame.ItemsTab)
	S:HandleTab(WardrobeCollectionFrame.SetsTab)

	WardrobeCollectionFrame.progressBar:StripTextures()
	WardrobeCollectionFrame.progressBar:CreateBackdrop()
	WardrobeCollectionFrame.progressBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(WardrobeCollectionFrame.progressBar)

	S:HandleEditBox(_G.WardrobeCollectionFrameSearchBox)
	_G.WardrobeCollectionFrameSearchBox:SetFrameLevel(5)

	S:HandleButton(WardrobeCollectionFrame.FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	WardrobeCollectionFrame.FilterButton:Point('LEFT', WardrobeCollectionFrame.searchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(WardrobeCollectionFrame.FilterButton.ResetButton)
	WardrobeCollectionFrame.FilterButton.ResetButton:ClearAllPoints()
	WardrobeCollectionFrame.FilterButton.ResetButton:Point('CENTER', WardrobeCollectionFrame.FilterButton, 'TOPRIGHT', 0, 0)
	S:HandleDropDownBox(_G.WardrobeCollectionFrame.ItemsCollectionFrame.WeaponDropdown)
	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()

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

				if Model.NewGlow then Model.NewGlow:SetParent(border) end
				if Model.NewString then Model.NewString:SetParent(border) end

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
		end

		local pending = Frame.PendingTransmogFrame
		if pending then
			local Glowframe = pending.Glowframe
			Glowframe:SetAtlas(nil)
			Glowframe:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, pending:GetFrameLevel())

			if Glowframe.backdrop then
				Glowframe.backdrop:Point('TOPLEFT', pending, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
				Glowframe.backdrop:Point('BOTTOMRIGHT', pending, 'BOTTOMRIGHT', 1, -1)
				Glowframe.backdrop:SetBackdropBorderColor(1, 0.7, 1)
				Glowframe.backdrop:SetBackdropColor(0, 0, 0, 0)
			end

			for i = 1, 12 do
				if i < 5 then
					Frame.PendingTransmogFrame['Smoke'..i]:Hide()
				end

				Frame.PendingTransmogFrame['Wisp'..i]:Hide()
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

	local WardrobeFrame = _G.WardrobeFrame
	S:HandlePortraitFrame(WardrobeFrame)

	local WardrobeTransmogFrame = _G.WardrobeTransmogFrame
	WardrobeTransmogFrame:StripTextures()
	S:HandleButton(WardrobeTransmogFrame.OutfitDropdown.SaveButton)
	S:HandleDropDownBox(WardrobeTransmogFrame.OutfitDropdown, 200)
	WardrobeTransmogFrame.OutfitDropdown.SaveButton:ClearAllPoints()
	WardrobeTransmogFrame.OutfitDropdown.SaveButton:Point('LEFT', WardrobeTransmogFrame.OutfitDropdown, 'RIGHT', 2, 0)

	for i = 1, #WardrobeTransmogFrame.SlotButtons do
		local slotButton = WardrobeTransmogFrame.SlotButtons[i]
		slotButton:OffsetFrameLevel(2)
		slotButton:StripTextures()
		slotButton:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
		slotButton.Border:Kill()
		slotButton.Icon:SetTexCoord(unpack(E.TexCoords))
		slotButton.Icon:SetInside(slotButton.backdrop)

		local undo = slotButton.UndoButton
		if undo then undo:SetHighlightTexture(E.ClearTexture) end

		local pending = slotButton.PendingFrame
		if pending then
			if slotButton.transmogType == 1 then
				pending.Glow:Size(48)
				pending.Ants:Size(30)
			else
				pending.Glow:Size(74)
				pending.Ants:Size(48)
			end
		end
	end

	local SpecButton = WardrobeTransmogFrame.SpecDropdown
	if SpecButton then
		S:HandleButton(SpecButton)

		SpecButton:SetPoint('RIGHT', WardrobeTransmogFrame.ApplyButton, 'LEFT', -3, 0)

		if SpecButton.Arrow then
			SpecButton.Arrow:SetAlpha(0)
		end

		if not SpecButton.customArrow then
			local tex = SpecButton:CreateTexture(nil, 'ARTWORK')
			tex:SetAllPoints()
			tex:SetTexture(E.Media.Textures.ArrowUp)
			tex:SetRotation(S.ArrowRotation.down)

			SpecButton.customArrow = tex
		end
	end

	S:HandleButton(WardrobeTransmogFrame.ApplyButton)
	S:HandleCheckBox(WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox)

	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()
	WardrobeCollectionFrame.ItemsCollectionFrame:SetTemplate('Transparent')

	WardrobeCollectionFrame.SetsTransmogFrame:StripTextures()
	WardrobeCollectionFrame.SetsTransmogFrame:SetTemplate('Transparent')
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.NextPageButton)
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.PrevPageButton)

	local WardrobeOutfitEditFrame = _G.WardrobeOutfitEditFrame
	WardrobeOutfitEditFrame:StripTextures()
	WardrobeOutfitEditFrame:SetTemplate('Transparent')
	WardrobeOutfitEditFrame.EditBox:StripTextures()
	S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
	S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
	S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)
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

local function UpdateWarbandSceneData(frame)
	if frame and frame.warbandSceneInfo and not frame.artBackdrop then
		frame.artBackdrop = CreateFrame('Frame', nil, frame)
		frame.artBackdrop:OffsetFrameLevel(-1, frame)
		frame.artBackdrop:SetOutside(frame.Icon, -5, -5)
		frame.artBackdrop:SetTemplate()

		frame.Border:SetAlpha(0)
		S:HandleIcon(frame.Icon)

		if frame.SetHighlightTexture then
			local highlight = frame:CreateTexture()
			highlight:SetColorTexture(1, 1, 1, .25)
			highlight:SetAllPoints(frame.Icon)

			frame:SetHighlightTexture(highlight)
		end
	end
end

function S:Blizzard_Collections()
	if not E.private.skins.blizzard.enable then return end
	if E.private.skins.blizzard.collections then SkinCollectionsFrames() end
	if E.private.skins.blizzard.transmogrify then SkinTransmogFrames() end
end

S:AddCallbackForAddon('Blizzard_Collections')
