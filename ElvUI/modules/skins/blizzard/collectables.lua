local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mounts ~= true then return end
	-- global
	CollectionsJournal:StripTextures()
	CollectionsJournal:SetTemplate('Transparent')
	CollectionsJournalPortrait:SetAlpha(0)

	for i=1, 4 do
		S:HandleTab(_G['CollectionsJournalTab'..i])
	end

	S:HandleCloseButton(CollectionsJournalCloseButton)
	S:HandleItemButton(MountJournalSummonRandomFavoriteButton)
	S:HandleButton(MountJournalFilterButton)

	MountJournalFilterButton:ClearAllPoints()
	MountJournalFilterButton:SetPoint("LEFT", MountJournalSearchBox, "RIGHT", 5, 0)
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
	S:HandleRotateButton(MountJournal.MountDisplay.ModelFrame.RotateLeftButton)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelFrame.RotateRightButton)

	for i = 1, #MountJournal.ListScrollFrame.buttons do
		local b = _G["MountJournalListScrollFrameButton"..i];
		S:HandleItemButton(b)
		b.favorite:SetTexture("Interface\\COMMON\\FavoritesIcon")
		b.favorite:SetPoint("TOPLEFT",b.DragButton,"TOPLEFT",-8,8)
		b.favorite:SetSize(32,32)
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

	for i = 1, 3 do
		local f = _G["PetJournalLoadoutPet"..i.."HelpFrame"]
		f:StripTextures()
	end

	PetJournalTutorialButton:Kill()
	PetJournal.PetCount:StripTextures()
	S:HandleEditBox(PetJournalSearchBox)
	PetJournalSearchBox:ClearAllPoints()
	PetJournalSearchBox:SetPoint("TOPLEFT", PetJournalLeftInset, "TOPLEFT", (E.PixelMode and 13 or 10), -9)
	PetJournalFilterButton:StripTextures(true)
	S:HandleButton(PetJournalFilterButton)
	PetJournalFilterButton:Height(E.PixelMode and 22 or 24)
	PetJournalFilterButton:ClearAllPoints()
	PetJournalFilterButton:SetPoint("TOPRIGHT", PetJournalLeftInset, "TOPRIGHT", -5, -(E.PixelMode and 8 or 7))
	PetJournalListScrollFrame:StripTextures()
	S:HandleScrollBar(PetJournalListScrollFrameScrollBar)

	for i = 1, #PetJournal.listScroll.buttons do
		local b = _G["PetJournalListScrollFrameButton"..i]
		S:HandleItemButton(b)
		b.dragButton.favorite:SetParent(b.backdrop)
		b.dragButton.levelBG:SetAlpha(0)
		b.dragButton.level:SetParent(b.backdrop)
		b.dragButton.ActiveTexture:Kill()
	end



	local function ColorSelectedPet()
		local petButtons = PetJournal.listScroll.buttons;
		local isWild = PetJournal.isWild;

		for i = 1, #petButtons do
			local index = petButtons[i].index;
			if not index then break; end
			local b = _G["PetJournalListScrollFrameButton"..i]
			local t = _G["PetJournalListScrollFrameButton"..i.."Name"]
			local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, creatureID, sourceText, description, isWildPet, canBattle = C_PetJournal.GetPetInfoByIndex(index, isWild);

			if b.selectedTexture:IsShown() then
				t:SetTextColor(1,1,0)
			else
				t:SetTextColor(1,1,1)
			end
			if petID ~= nil then
				local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);
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
		_G['PetJournalLoadoutPet'..i]:StripTextures()
		_G['PetJournalLoadoutPet'..i]:CreateBackdrop()
		_G['PetJournalLoadoutPet'..i].backdrop:SetAllPoints()
		_G['PetJournalLoadoutPet'..i].petTypeIcon:SetPoint('BOTTOMLEFT', 2, 2)


		_G['PetJournalLoadoutPet'..i].dragButton:SetOutside(_G['PetJournalLoadoutPet'..i..'Icon'])
		_G['PetJournalLoadoutPet'..i].dragButton:SetFrameLevel(_G['PetJournalLoadoutPet'..i].dragButton:GetFrameLevel() + 1)

		_G['PetJournalLoadoutPet'..i].hover = true;
		_G['PetJournalLoadoutPet'..i].pushed = true;
		_G['PetJournalLoadoutPet'..i].checked = true;
		S:HandleItemButton(_G['PetJournalLoadoutPet'..i])

		_G['PetJournalLoadoutPet'..i].backdrop:SetFrameLevel(_G['PetJournalLoadoutPet'..i].backdrop:GetFrameLevel() + 1)

		_G['PetJournalLoadoutPet'..i].setButton:StripTextures()
		_G['PetJournalLoadoutPet'..i..'HealthFrame'].healthBar:StripTextures()
		_G['PetJournalLoadoutPet'..i..'HealthFrame'].healthBar:CreateBackdrop('Default')
		_G['PetJournalLoadoutPet'..i..'HealthFrame'].healthBar:SetStatusBarTexture(E.media.normTex)
		_G['PetJournalLoadoutPet'..i..'XPBar']:StripTextures()
		_G['PetJournalLoadoutPet'..i..'XPBar']:CreateBackdrop('Default')
		_G['PetJournalLoadoutPet'..i..'XPBar']:SetStatusBarTexture(E.media.normTex)
		_G['PetJournalLoadoutPet'..i..'XPBar']:SetFrameLevel(_G['PetJournalLoadoutPet'..i..'XPBar']:GetFrameLevel() + 2)

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

	PetJournalPetCardPetInfo.levelBG:SetAlpha(0)
	PetJournalPetCardPetInfoIcon:SetTexCoord(unpack(E.TexCoords))
	PetJournalPetCardPetInfo:CreateBackdrop()
	PetJournalPetCardPetInfo.favorite:SetParent(PetJournalPetCardPetInfo.backdrop)
	PetJournalPetCardPetInfo.backdrop:SetOutside(PetJournalPetCardPetInfoIcon)
	PetJournalPetCardPetInfoIcon:SetParent(PetJournalPetCardPetInfo.backdrop)
	PetJournalPetCardPetInfo.backdrop:SetFrameLevel(PetJournalPetCardPetInfo.backdrop:GetFrameLevel() + 2)
	PetJournalPetCardPetInfo.level:SetParent(PetJournalPetCardPetInfo.backdrop)

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
	PetJournalPetCardXPBar:StripTextures()
	PetJournalPetCardXPBar:CreateBackdrop('Default')
	PetJournalPetCardXPBar:SetStatusBarTexture(E.media.normTex)


	--Toy Box
	S:HandleButton(ToyBoxFilterButton)
	ToyBoxFilterButton:SetPoint("TOPRIGHT", ToyBox, "TOPRIGHT", -15, -34)

	S:HandleEditBox(ToyBox.searchBox)
	ToyBox.iconsFrame:StripTextures()
	S:HandleNextPrevButton(ToyBox.navigationFrame.nextPageButton)
	S:HandleNextPrevButton(ToyBox.navigationFrame.prevPageButton)
	SquareButton_SetIcon(ToyBox.navigationFrame.prevPageButton, 'LEFT')
	ToyBox.progressBar:StripTextures()

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
	HeirloomsJournalFilterButton:SetPoint("TOPRIGHT", HeirloomsJournal, "TOPRIGHT", -15, -34)

	S:HandleEditBox(HeirloomsJournal.SearchBox)
	HeirloomsJournal.iconsFrame:StripTextures()
	S:HandleNextPrevButton(HeirloomsJournal.navigationFrame.nextPageButton)
	S:HandleNextPrevButton(HeirloomsJournal.navigationFrame.prevPageButton)
	SquareButton_SetIcon(HeirloomsJournal.navigationFrame.prevPageButton, 'LEFT')
	HeirloomsJournal.progressBar:StripTextures()
	S:HandleDropDownBox(HeirloomsJournalClassDropDown)
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

			if(C_Heirloom.PlayerHasHeirloom(button.itemID)) then
				button.name:SetTextColor(1, 1, 1)
			else
				button.name:SetTextColor(0.6, 0.6, 0.6)
			end
		end
	end)

	hooksecurefunc(HeirloomsJournal, "UpdateButton", function(self, button)
		button.iconTextureUncollected:SetTexture(button.iconTexture:GetTexture())
		if(C_Heirloom.PlayerHasHeirloom(button.itemID)) then
			button.name:SetTextColor(1, 1, 1)
		else
			button.name:SetTextColor(0.6, 0.6, 0.6)
		end
	end)
end

S:RegisterSkin("Blizzard_Collections", LoadSkin)