local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select = select
local ipairs, pairs, unpack = ipairs, pairs, unpack
--WoW API / Variables
local C_Heirloom_PlayerHasHeirloom = C_Heirloom.PlayerHasHeirloom
local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GetItemQualityColor = GetItemQualityColor
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ToyBox, PlayerHasToy, SquareButton_SetIcon

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.collections ~= true then return end

	-- global
	CollectionsJournal:StripTextures()
	CollectionsJournal:SetTemplate('Transparent')
	CollectionsJournalPortrait:SetAlpha(0)

	for i=1, 5 do
		S:HandleTab(_G['CollectionsJournalTab'..i])
	end

	S:HandleCloseButton(CollectionsJournalCloseButton)
	S:HandleItemButton(MountJournalSummonRandomFavoriteButton)
	S:HandleButton(MountJournalFilterButton)

	MountJournalFilterButton:ClearAllPoints()
	MountJournalFilterButton:Point("LEFT", MountJournalSearchBox, "RIGHT", 5, 0)

	-------------------------------
	--[[ mount journal (tab 1) ]]--
	-------------------------------
	MountJournal:StripTextures()
	MountJournal.MountDisplay:StripTextures()
	MountJournal.MountDisplay.ShadowOverlay:StripTextures()
	MountJournal.MountCount:StripTextures()

	S:HandleIcon(MountJournal.MountDisplay.InfoButton.Icon)

	S:HandleButton(MountJournalMountButton, true)
	S:HandleEditBox(MountJournalSearchBox)
	S:HandleScrollBar(MountJournalListScrollFrameScrollBar)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateLeftButton)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateRightButton)

	for _, bu in pairs(MountJournal.ListScrollFrame.buttons) do
		bu:CreateBackdrop("Transparent")
		bu.backdrop:SetFrameLevel(bu:GetFrameLevel())
		bu.backdrop:SetInside(bu, 3, 3)

		bu.icon:SetPoint("LEFT", bu, -40, 0)
		bu.icon:SetTexCoord(unpack(E.TexCoords))
		bu.icon:CreateBackdrop("Default")
		bu.icon.backdrop:SetOutside(bu.icon, 1, 1)

		bu:HookScript("OnEnter", function(self)
			self.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
			self.icon.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		end)

		bu:HookScript("OnLeave", function(self)
			if self.selected then
				self.backdrop:SetBackdropBorderColor(1, .8, .1)
				self.icon.backdrop:SetBackdropBorderColor(1, .8, .1)
			else
				self.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				self.icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end)

		hooksecurefunc(bu.unusable, 'Show', function() bu.icon:SetVertexColor(.4, .1, .1) bu.backdrop:SetBackdropColor(.4, .1, .1, .65) end)
		hooksecurefunc(bu.unusable, 'Hide', function() bu.icon:SetVertexColor(1, 1, 1) bu.backdrop:SetBackdropColor(0, 0, 0, .65) end)

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
		bu.unusable:SetAlpha(0)
		bu.iconBorder:SetTexture('')
		bu.background:SetTexture('')
		bu.selectedTexture:SetTexture('')

		bu.factionIcon:SetDrawLayer('OVERLAY')
		bu.factionIcon:SetPoint('TOPRIGHT', -1, -4)
		bu.factionIcon:SetPoint('BOTTOMRIGHT', -1, 4)

		bu.favorite:SetTexture("Interface\\COMMON\\FavoritesIcon")
		bu.favorite:Point("TOPLEFT", bu.DragButton, "TOPLEFT" , -8, 8)
		bu.favorite:SetSize(32, 32)
	end

	-----------------------------
	--[[ pet journal (tab 2) ]]--
	-----------------------------
	PetJournalSummonButton:StripTextures()
	PetJournalFindBattle:StripTextures()
	S:HandleButton(PetJournalSummonButton)
	S:HandleButton(PetJournalFindBattle)
	PetJournalRightInset:StripTextures()
	PetJournalLeftInset:StripTextures()
	S:HandleItemButton(PetJournalSummonRandomFavoritePetButton, true)

	for i = 1, 3 do
		local f = _G["PetJournalLoadoutPet"..i.."HelpFrame"]
		f:StripTextures()
	end

	if E.global.general.disableTutorialButtons then
		PetJournalTutorialButton:Kill()
	end

	PetJournal.PetCount:StripTextures()
	S:HandleEditBox(PetJournalSearchBox)
	PetJournalSearchBox:ClearAllPoints()
	PetJournalSearchBox:Point("TOPLEFT", PetJournalLeftInset, "TOPLEFT", (E.PixelMode and 13 or 10), -9)
	PetJournalFilterButton:StripTextures(true)
	S:HandleButton(PetJournalFilterButton)
	PetJournalFilterButton:Height(E.PixelMode and 22 or 24)
	PetJournalFilterButton:ClearAllPoints()
	PetJournalFilterButton:Point("TOPRIGHT", PetJournalLeftInset, "TOPRIGHT", -5, -(E.PixelMode and 8 or 7))
	PetJournalListScrollFrame:StripTextures()
	S:HandleScrollBar(PetJournalListScrollFrameScrollBar)

	for _, bu in pairs(PetJournal.listScroll.buttons) do
		bu:StripTextures()
		bu:CreateBackdrop("Transparent")
		bu.backdrop:SetFrameLevel(bu:GetFrameLevel())
		bu.backdrop:SetInside(bu, 3, 3)

		bu.icon:SetPoint("LEFT", -40, 0)
		bu.icon:SetTexCoord(unpack(E.TexCoords))
		bu.icon:CreateBackdrop("Default")
		bu.icon.backdrop:SetOutside(bu.icon, 1, 1)

		bu:HookScript("OnEnter", function(self)
			self.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		end)

		bu:HookScript("OnLeave", function(self)
			if self.selected then
				self.backdrop:SetBackdropBorderColor(1, .8, .1)
			else
				self.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
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
		bu.dragButton.levelBG:SetTexture(nil)

		bu.iconBorder:SetTexture('')
		bu.selectedTexture:SetTexture('')

		hooksecurefunc(bu.iconBorder, 'SetVertexColor', function(self, r, g, b)
			bu.icon.backdrop:SetBackdropBorderColor(r, g, b)
		end)

		hooksecurefunc(bu.iconBorder, 'Hide', function(self)
			bu.icon.backdrop:SetBackdropColor(unpack(E.media.bordercolor))
		end)
	end

	PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')

	S:HandleItemButton(PetJournalHealPetButton, true)
	E:RegisterCooldown(PetJournalHealPetButtonCooldown)
	PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	PetJournalLoadoutBorder:StripTextures()

	for i = 1, 3 do
		local petButton = _G['PetJournalLoadoutPet'..i]
		local petButtonHealthFrame = _G['PetJournalLoadoutPet'..i..'HealthFrame']
		local petButtonXPBar = _G['PetJournalLoadoutPet'..i..'XPBar']
		petButton:StripTextures()
		petButton:CreateBackdrop()
		petButton.backdrop:SetAllPoints()
		petButton.petTypeIcon:Point('BOTTOMLEFT', 2, 2)

		petButton.dragButton:SetOutside(_G['PetJournalLoadoutPet'..i..'Icon'])
		petButton.dragButton:SetFrameLevel(_G['PetJournalLoadoutPet'..i].dragButton:GetFrameLevel() + 1)

		petButton.hover = true;
		petButton.pushed = true;
		petButton.checked = true;
		S:HandleItemButton(petButton)
		petButton.levelBG:SetAtlas("PetJournal-LevelBubble", true)

		petButton.backdrop:SetFrameLevel(_G['PetJournalLoadoutPet'..i].backdrop:GetFrameLevel() + 1)

		petButton.setButton:StripTextures()
		petButtonHealthFrame.healthBar:StripTextures()
		petButtonHealthFrame.healthBar:CreateBackdrop('Default')
		petButtonHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(petButtonHealthFrame.healthBar)
		petButtonXPBar:StripTextures()
		petButtonXPBar:CreateBackdrop('Default')
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

	PetJournalSpellSelect:StripTextures()
	for i=1, 2 do
		local btn = _G['PetJournalSpellSelectSpell'..i]
		S:HandleItemButton(btn)
		_G['PetJournalSpellSelectSpell'..i..'Icon']:SetInside(btn)
		_G['PetJournalSpellSelectSpell'..i..'Icon']:SetDrawLayer('BORDER')
	end

	PetJournalPetCard:StripTextures()
	PetJournalPetCard:SetTemplate('Default')
	PetJournalPetCardInset:StripTextures()
	PetJournalPetCardPetInfoQualityBorder:SetAlpha(0)

	PetJournalPetCardPetInfoIcon:SetTexCoord(unpack(E.TexCoords))
	PetJournalPetCardPetInfo:CreateBackdrop()
	PetJournalPetCardPetInfo.favorite:SetParent(PetJournalPetCardPetInfo.backdrop)
	PetJournalPetCardPetInfo.backdrop:SetOutside(PetJournalPetCardPetInfoIcon)
	PetJournalPetCardPetInfoIcon:SetParent(PetJournalPetCardPetInfo.backdrop)

	if E.private.skins.blizzard.tooltip then
		local tt = PetJournalPrimaryAbilityTooltip
		tt.Background:SetTexture(nil)
		if tt.Delimiter1 then
			tt.Delimiter1:SetTexture(nil)
			tt.Delimiter2:SetTexture(nil)
		end
		tt.BorderTop:SetTexture(nil)
		tt.BorderTopLeft:SetTexture(nil)
		tt.BorderTopRight:SetTexture(nil)
		tt.BorderLeft:SetTexture(nil)
		tt.BorderRight:SetTexture(nil)
		tt.BorderBottom:SetTexture(nil)
		tt.BorderBottomRight:SetTexture(nil)
		tt.BorderBottomLeft:SetTexture(nil)
		tt:SetTemplate("Transparent")
	end

	for i=1, 6 do
		local frame = _G['PetJournalPetCardSpell'..i]
		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame:DisableDrawLayer('BACKGROUND')
		frame:CreateBackdrop('Default')
		frame.backdrop:SetAllPoints()
		frame.icon:SetTexCoord(unpack(E.TexCoords))
		frame.icon:SetInside(frame.backdrop)
	end

	PetJournalPetCardHealthFrame.healthBar:StripTextures()
	PetJournalPetCardHealthFrame.healthBar:CreateBackdrop('Default')
	PetJournalPetCardHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(PetJournalPetCardHealthFrame.healthBar)
	PetJournalPetCardXPBar:StripTextures()
	PetJournalPetCardXPBar:CreateBackdrop('Default')
	PetJournalPetCardXPBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(PetJournalPetCardXPBar)

	--Toy Box
	S:HandleButton(ToyBoxFilterButton)
	ToyBoxFilterButton:Point("TOPRIGHT", ToyBox, "TOPRIGHT", -15, -34)
	S:HandleEditBox(ToyBox.searchBox)
	ToyBox.iconsFrame:StripTextures()
	S:HandleNextPrevButton(ToyBox.PagingFrame.NextPageButton)
	S:HandleNextPrevButton(ToyBox.PagingFrame.PrevPageButton, false, true)
	S:HandleCloseButton(ToyBox.favoriteHelpBox.CloseButton)

	local progressBar = ToyBox.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer("BACKGROUND")
	progressBar:SetStatusBarTexture(E.media.normTex)
	progressBar:CreateBackdrop("Default")
	E:RegisterStatusBar(progressBar)

	local function TextColorModified(self, r, g, b)
		if(r == 0.33 and g == 0.27 and b == 0.2) then
			self:SetTextColor(0.6, 0.6, 0.6)
		elseif(r == 1 and g == 0.82 and b == 0) then
			self:SetTextColor(1, 1, 1)
		end
	end

	for i = 1, 18 do
		local button = ToyBox.iconsFrame["spellButton"..i]
		S:HandleItemButton(button, true)
		button.iconTextureUncollected:SetTexCoord(unpack(E.TexCoords))
		button.iconTextureUncollected:SetInside(button)
		button.hover:SetAllPoints(button.iconTexture)
		button.checked:SetAllPoints(button.iconTexture)
		button.pushed:SetAllPoints(button.iconTexture)
		button.cooldown:SetAllPoints(button.iconTexture)

		hooksecurefunc(button.name, "SetTextColor", TextColorModified)
		hooksecurefunc(button.new, "SetTextColor", TextColorModified)
		E:RegisterCooldown(button.cooldown)
	end

	hooksecurefunc("ToySpellButton_UpdateButton", function(self)
		if (PlayerHasToy(self.itemID)) then
			local quality = select(3, GetItemInfo(self.itemID))
			local r, g, b = 1, 1, 1
			if quality then
				r, g, b = GetItemQualityColor(quality)
			end
			self.backdrop:SetBackdropBorderColor(r, g, b)
		else
			self.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end
	end)

	--Heirlooms
	S:HandleButton(HeirloomsJournalFilterButton)
	HeirloomsJournalFilterButton:Point("TOPRIGHT", HeirloomsJournal, "TOPRIGHT", -15, -34)
	S:HandleEditBox(HeirloomsJournal.SearchBox)
	HeirloomsJournal.iconsFrame:StripTextures()
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.NextPageButton)
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.PrevPageButton, false, true)
	S:HandleDropDownBox(HeirloomsJournalClassDropDown)
	S:HandleCloseButton(HeirloomsJournal.UpgradeLevelHelpBox.CloseButton)

	local progressBar = HeirloomsJournal.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer("BACKGROUND")
	progressBar:SetStatusBarTexture(E.media.normTex)
	progressBar:CreateBackdrop("Default")
	E:RegisterStatusBar(progressBar)

	hooksecurefunc(HeirloomsJournal, "UpdateButton", function(_, button)
		if not button.styled then
			S:HandleItemButton(button, true)

			button.iconTexture:SetDrawLayer("ARTWORK")
			button.hover:SetAllPoints(button.iconTexture)
			button.slotFrameCollected:SetAlpha(0)
			button.slotFrameUncollected:SetAlpha(0)
			button.special:SetJustifyH('RIGHT')
			button.special:ClearAllPoints()
			button.styled = true
		end

		button.levelBackground:SetTexture(nil)

		button.name:SetPoint('LEFT', button, 'RIGHT', 4, 8)
		button.level:SetPoint('TOPLEFT', button.levelBackground,'TOPLEFT', 25, 2)

		button.SetTextColor = nil
		if C_Heirloom_PlayerHasHeirloom(button.itemID) then
			button.name:SetTextColor(1, 1, 1)
			button.level:SetTextColor(1, 1, 1)
			button.special:SetTextColor(1, .82, 0)
			button.backdrop:SetBackdropBorderColor(GetItemQualityColor(7))
		else
			button.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end
		button.SetTextColor = E.noop
	end)

	-- Appearances Tab
	local WardrobeCollectionFrame = _G["WardrobeCollectionFrame"]
	S:HandleTab(WardrobeCollectionFrame.ItemsTab)
	S:HandleTab(WardrobeCollectionFrame.SetsTab)

	--Items
	WardrobeCollectionFrame.progressBar:StripTextures()
	WardrobeCollectionFrame.progressBar:CreateBackdrop("Default")
	WardrobeCollectionFrame.progressBar:SetStatusBarTexture(E["media"].normTex)

	E:RegisterStatusBar(WardrobeCollectionFrame.progressBar)

	S:HandleEditBox(WardrobeCollectionFrameSearchBox)
	WardrobeCollectionFrameSearchBox:SetFrameLevel(5)

	WardrobeCollectionFrame.FilterButton:SetPoint('LEFT', WardrobeCollectionFrame.searchBox, 'RIGHT', 2, 0)
	S:HandleButton(WardrobeCollectionFrame.FilterButton)
	S:HandleDropDownBox(WardrobeCollectionFrameWeaponDropDown)

	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()

	for _, Frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
		if Frame.Models then
			for _, Model in pairs(Frame.Models) do
				Model:SetFrameLevel(Model:GetFrameLevel() + 1)
				Model:CreateBackdrop("Default")
				Model.backdrop:SetOutside(Model, 2, 2)
				Model.Border:Kill()
				Model.TransmogStateTexture:SetAlpha(0)

				hooksecurefunc(Model.Border, 'SetAtlas', function(self, texture)
					local r, g, b
					if texture == "transmog-wardrobe-border-uncollected" then
						r, g, b = 1, 1, 0
					elseif texture == "transmog-wardrobe-border-unusable" then
						r, g, b =  1, 0, 0
					else
						r, g, b = unpack(E["media"].bordercolor)
					end
					Model.backdrop:SetBackdropBorderColor(r, g, b)
				end)
			end
		end

		if Frame.PendingTransmogFrame then
			Frame.PendingTransmogFrame.Glowframe:SetAtlas(nil)
			Frame.PendingTransmogFrame.Glowframe:CreateBackdrop("Default")
			Frame.PendingTransmogFrame.Glowframe.backdrop:SetOutside()
			Frame.PendingTransmogFrame.Glowframe.backdrop:SetBackdropColor(0, 0, 0, 0)
			Frame.PendingTransmogFrame.Glowframe.backdrop:SetBackdropBorderColor(1, .77, 1, 1)
			Frame.PendingTransmogFrame.Glowframe = Frame.PendingTransmogFrame.Glowframe.backdrop

			for i = 1, 12 do
				Frame.PendingTransmogFrame['Wisp'..i]:Hide()
			end
		end

		if Frame.PagingFrame then
			S:HandleNextPrevButton(Frame.PagingFrame.PrevPageButton, nil, true)
			S:HandleNextPrevButton(Frame.PagingFrame.NextPageButton)
		end
	end

	--Sets
	WardrobeCollectionFrame.SetsCollectionFrame.RightInset:StripTextures()
	WardrobeCollectionFrame.SetsCollectionFrame:SetTemplate("Transparent")
	WardrobeCollectionFrame.SetsCollectionFrame.LeftInset:StripTextures()
	WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.Name:FontTemplate(nil, 16)
	WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.LongName:FontTemplate(nil, 16)
	S:HandleButton(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.VariantSetsButton)
	S:HandleScrollBar(WardrobeCollectionFrame.SetsCollectionFrame.ScrollFrame.scrollBar)
	S:HandleCloseButton(WardrobeCollectionFrame.SetsTabHelpBox.CloseButton)
	S:HandleCloseButton(WardrobeCollectionFrame.ItemsCollectionFrame.HelpBox.CloseButton)

	--Skin set buttons
	for i = 1, #WardrobeCollectionFrame.SetsCollectionFrame.ScrollFrame.buttons do
		local b = WardrobeCollectionFrame.SetsCollectionFrame.ScrollFrame.buttons[i];
		S:HandleItemButton(b)
		b.Favorite:SetAtlas("PetJournal-FavoritesIcon", true)
		b.Favorite:Point("TOPLEFT", b.Icon, "TOPLEFT", -8, 8)
		b.SelectedTexture:SetColorTexture(1, 1, 1, 0.1)
	end

	--Set quality color on set item buttons
	local function SetItemQuality(self, itemFrame)
		if (itemFrame.backdrop) then
			local _, _, quality = GetItemInfo(itemFrame.itemID);
			local alpha = 1
			if (not itemFrame.collected) then
				alpha = 0.4
			end

			if (not quality or quality < 2) then --Not collected or item is white or grey
				itemFrame.backdrop:SetBackdropBorderColor(0, 0, 0)
			else
				itemFrame.backdrop:SetBackdropBorderColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b, alpha)
			end
		end
	end
	hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, "SetItemFrameQuality", SetItemQuality)

	--Skin set item buttons
	local function SkinSetItemButtons(self)
		for itemFrame in self.DetailsFrame.itemFramesPool:EnumerateActive() do
			if (not itemFrame.isSkinned) then
				S:HandleIcon(itemFrame.Icon, itemFrame)
				itemFrame.isSkinned = true
			end
			itemFrame.IconBorder:SetAlpha(0)
			SetItemQuality(self, itemFrame)
		end
	end
	hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, "DisplaySet", SkinSetItemButtons)

	-- Transmogrify NPC
	local WardrobeFrame = _G["WardrobeFrame"]
	WardrobeFrame:StripTextures()
	WardrobeFrame:SetTemplate("Transparent")
	WardrobeOutfitFrame:StripTextures()
	WardrobeOutfitFrame:SetTemplate("Transparent")
	S:HandleCloseButton(WardrobeFrameCloseButton)
	S:HandleDropDownBox(WardrobeOutfitDropDown)
	WardrobeOutfitDropDown:SetSize(200, 32)
	WardrobeOutfitDropDownText:ClearAllPoints()
	WardrobeOutfitDropDownText:SetPoint("CENTER", WardrobeOutfitDropDown, 10, 2)
	S:HandleButton(WardrobeOutfitDropDown.SaveButton)
	WardrobeOutfitDropDown.SaveButton:ClearAllPoints()
	WardrobeOutfitDropDown.SaveButton:SetPoint("LEFT", WardrobeOutfitDropDown, "RIGHT", 1, 4)

	WardrobeTransmogFrame:StripTextures()

	for i = 1, #WardrobeTransmogFrame.Model.SlotButtons do
		WardrobeTransmogFrame.Model.SlotButtons[i]:StripTextures()
		WardrobeTransmogFrame.Model.SlotButtons[i]:SetFrameLevel(WardrobeTransmogFrame.Model.SlotButtons[i]:GetFrameLevel() + 2)
		WardrobeTransmogFrame.Model.SlotButtons[i]:CreateBackdrop("Default")
		WardrobeTransmogFrame.Model.SlotButtons[i].backdrop:SetAllPoints()
		WardrobeTransmogFrame.Model.SlotButtons[i].Border:Kill()
		WardrobeTransmogFrame.Model.SlotButtons[i].Icon:SetTexCoord(unpack(E.TexCoords))
	end

	WardrobeTransmogFrame.SpecButton:ClearAllPoints()
	WardrobeTransmogFrame.SpecButton:SetPoint("RIGHT", WardrobeTransmogFrame.ApplyButton, "LEFT", -2, 0)
	S:HandleButton(WardrobeTransmogFrame.SpecButton)
	S:HandleButton(WardrobeTransmogFrame.ApplyButton)
	S:HandleButton(WardrobeTransmogFrame.Model.ClearAllPendingButton)

	--Transmogrify NPC Sets tab
	WardrobeCollectionFrame.SetsTransmogFrame:StripTextures()
	WardrobeCollectionFrame.SetsTransmogFrame:SetTemplate("Transparent")
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.NextPageButton)
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.PrevPageButton, nil, true)

	-- Taken from AddOnSkins
	for i = 1, 2 do
		for j = 1, 4 do
			WardrobeCollectionFrame.SetsTransmogFrame["ModelR"..i.."C"..j]:StripTextures()
			WardrobeCollectionFrame.SetsTransmogFrame["ModelR"..i.."C"..j]:CreateBackdrop("Default")
		end
	end

	-- Outfit Edit Frame
	WardrobeOutfitEditFrame:StripTextures()
	WardrobeOutfitEditFrame:CreateBackdrop("Transparent")
	WardrobeOutfitEditFrame.EditBox:StripTextures()
	S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
	S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
	S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)
end

S:AddCallbackForAddon("Blizzard_Collections", "Collections", LoadSkin)
