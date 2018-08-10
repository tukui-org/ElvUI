local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local C_Heirloom_PlayerHasHeirloom = C_Heirloom.PlayerHasHeirloom
local C_PetJournal_GetPetStats = C_PetJournal.GetPetStats
local C_PetJournal_GetPetInfoByIndex = C_PetJournal.GetPetInfoByIndex
local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SquareButton_SetIcon

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
	MountJournal.LeftInset:StripTextures()
	MountJournal.RightInset:StripTextures()
	MountJournal.MountDisplay:StripTextures()
	MountJournal.MountDisplay.ShadowOverlay:StripTextures()
	MountJournal.MountCount:StripTextures()

	S:HandleIcon(MountJournal.MountDisplay.InfoButton.Icon)

	S:HandleButton(MountJournalMountButton, true)
	S:HandleEditBox(MountJournalSearchBox)
	S:HandleScrollBar(MountJournalListScrollFrameScrollBar)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateLeftButton)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateRightButton)

	for i = 1, #MountJournal.ListScrollFrame.buttons do
		local b = _G["MountJournalListScrollFrameButton"..i];
		S:HandleItemButton(b)
		b.favorite:SetTexture("Interface\\COMMON\\FavoritesIcon")
		b.favorite:Point("TOPLEFT",b.DragButton,"TOPLEFT",-8,8)
		b.favorite:SetSize(32,32)
		b.selectedTexture:SetColorTexture(1, 1, 1, 0.1)
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

	for i = 1, #PetJournal.listScroll.buttons do
		local b = _G["PetJournalListScrollFrameButton"..i]
		S:HandleItemButton(b)
		b.dragButton.favorite:SetParent(b.backdrop)
		b.dragButton.ActiveTexture:Kill()
		b.selectedTexture:SetColorTexture(1, 1, 1, 0.1)
	end

	local function ColorSelectedPet()
		local petButtons = PetJournal.listScroll.buttons;
		local isWild = PetJournal.isWild;

		for i = 1, #petButtons do
			local index = petButtons[i].index;
			if not index then break; end
			local b = _G["PetJournalListScrollFrameButton"..i]
			local t = _G["PetJournalListScrollFrameButton"..i.."Name"]
			local petID = C_PetJournal_GetPetInfoByIndex(index, isWild);

			if b.selectedTexture:IsShown() then
				t:SetTextColor(1,1,0)
			else
				t:SetTextColor(1,1,1)
			end
			if petID ~= nil then
				local _, _, _, _, rarity = C_PetJournal_GetPetStats(petID);
				if rarity then
					local color = ITEM_QUALITY_COLORS[rarity-1]
					b.backdrop:SetBackdropBorderColor(color.r, color.g, color.b);
				else
					b.backdrop:SetBackdropBorderColor(0,0,0)
				end
			else
				b.backdrop:SetBackdropBorderColor(0,0,0)
			end
		end
	end
	hooksecurefunc('PetJournal_UpdatePetList', ColorSelectedPet)
	PetJournalListScrollFrame:HookScript("OnVerticalScroll", ColorSelectedPet)
	PetJournalListScrollFrame:HookScript("OnMouseWheel", ColorSelectedPet)

	PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')

	S:HandleItemButton(PetJournalHealPetButton, true)
	E:RegisterCooldown(PetJournalHealPetButtonCooldown)
	PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	PetJournalLoadoutBorder:StripTextures()
	for i=1, 3 do
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
	S:HandleNextPrevButton(ToyBox.PagingFrame.PrevPageButton)
	SquareButton_SetIcon(ToyBox.PagingFrame.PrevPageButton, 'LEFT')
	ToyBox.progressBar:StripTextures()
	S:HandleCloseButton(ToyBox.favoriteHelpBox.CloseButton)

	local function TextColorModified(self, r, g, b)
		if(r == 0.33 and g == 0.27 and b == 0.2) then
			self:SetTextColor(0.6, 0.6, 0.6)
		elseif(r == 1 and g == 0.82 and b == 0) then
			self:SetTextColor(1, 1, 1)
		end
	end

	for i=1, 18 do
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

	--Heirlooms
	S:HandleButton(HeirloomsJournalFilterButton)
	HeirloomsJournalFilterButton:Point("TOPRIGHT", HeirloomsJournal, "TOPRIGHT", -15, -34)
	S:HandleEditBox(HeirloomsJournal.SearchBox)
	HeirloomsJournal.iconsFrame:StripTextures()
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.NextPageButton)
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.PrevPageButton)
	SquareButton_SetIcon(HeirloomsJournal.PagingFrame.PrevPageButton, 'LEFT')
	HeirloomsJournal.progressBar:StripTextures()
	S:HandleDropDownBox(HeirloomsJournalClassDropDown)
	S:HandleCloseButton(HeirloomsJournal.UpgradeLevelHelpBox.CloseButton)

	hooksecurefunc(HeirloomsJournal, "LayoutCurrentPage", function()
		for i=1, #HeirloomsJournal.heirloomHeaderFrames do
			local header = HeirloomsJournal.heirloomHeaderFrames[i]
			header.text:FontTemplate()
			header.text:SetTextColor(1, 1, 1)
		end

		for i=1, #HeirloomsJournal.heirloomEntryFrames do
			local button = HeirloomsJournal.heirloomEntryFrames[i]
			if(not button.skinned) then
				button.skinned = true
				S:HandleItemButton(button, true)
				--button.levelBackground:SetAlpha(0)
				button.iconTextureUncollected:SetTexCoord(unpack(E.TexCoords))
				button.iconTextureUncollected:SetInside(button)
				button.iconTextureUncollected:SetTexture(button.iconTexture:GetTexture())
				HeirloomsJournal:UpdateButton(button)
			end

			if(C_Heirloom_PlayerHasHeirloom(button.itemID)) then
				button.name:SetTextColor(1, 1, 1)
			else
				button.name:SetTextColor(0.6, 0.6, 0.6)
			end
		end
	end)

	hooksecurefunc(HeirloomsJournal, "UpdateButton", function(self, button)
		button.iconTextureUncollected:SetTexture(button.iconTexture:GetTexture())
		if(C_Heirloom_PlayerHasHeirloom(button.itemID)) then
			button.name:SetTextColor(1, 1, 1)
		else
			button.name:SetTextColor(0.6, 0.6, 0.6)
		end
	end)

	-- Appearances Tab
	local function SkinTab(tab)
		S:HandleTab(tab)
		tab.backdrop:SetTemplate("Default", true)
		tab.backdrop:SetOutside(nil, 2, 2)
	end
	SkinTab(WardrobeCollectionFrame.ItemsTab)
	SkinTab(WardrobeCollectionFrame.SetsTab)

	--Items
	WardrobeCollectionFrame.progressBar:StripTextures()
	WardrobeCollectionFrame.progressBar:CreateBackdrop("Default")
	WardrobeCollectionFrame.progressBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(WardrobeCollectionFrame.progressBar)
	S:HandleEditBox(WardrobeCollectionFrameSearchBox)
	WardrobeCollectionFrameSearchBox:SetFrameLevel(5)
	S:HandleButton(WardrobeCollectionFrame.FilterButton)
	S:HandleDropDownBox(WardrobeCollectionFrameWeaponDropDown)
	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()
	WardrobeCollectionFrame.ItemsCollectionFrame:SetTemplate("Transparent")
	S:HandleNextPrevButton(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.PrevPageButton, nil, true)
	S:HandleNextPrevButton(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.NextPageButton)

	-- Taken from AddOnSkins
	for i = 1, 3 do
		for j = 1, 6 do
			WardrobeCollectionFrame.ItemsCollectionFrame["ModelR"..i.."C"..j]:StripTextures()
			WardrobeCollectionFrame.ItemsCollectionFrame["ModelR"..i.."C"..j]:SetFrameLevel(WardrobeCollectionFrame.ItemsCollectionFrame["ModelR"..i.."C"..j]:GetFrameLevel() + 2)
			WardrobeCollectionFrame.ItemsCollectionFrame["ModelR"..i.."C"..j]:CreateBackdrop("Default")
			WardrobeCollectionFrame.ItemsCollectionFrame["ModelR"..i.."C"..j].Border:Kill()
			hooksecurefunc(WardrobeCollectionFrame.ItemsCollectionFrame["ModelR"..i.."C"..j].Border, 'SetAtlas', function(self, texture)
				local color = E.media.bordercolor
				if texture == "transmog-wardrobe-border-uncollected" then
					color = { 1, 1, 0}
				elseif texture == "transmog-wardrobe-border-unusable" then
					color = { 1, 0, 0}
				end
				self:GetParent().backdrop:SetBackdropBorderColor(unpack(color))
			end)
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
	WardrobeTransmogFrame.Inset:StripTextures()

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
