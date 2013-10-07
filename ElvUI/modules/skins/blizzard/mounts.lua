local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mounts ~= true then return end
	-- global
	PetJournalParent:StripTextures()
	PetJournalParent:SetTemplate('Transparent')
	PetJournalParentPortrait:Hide()
	S:HandleTab(PetJournalParentTab1)
	S:HandleTab(PetJournalParentTab2)
	S:HandleCloseButton(PetJournalParentCloseButton)

	-------------------------------
	--[[ mount journal (tab 1) ]]--
	-------------------------------

	MountJournal:StripTextures()
	MountJournal.LeftInset:StripTextures()
	MountJournal.RightInset:StripTextures()
	MountJournal.MountDisplay:StripTextures()
	MountJournal.MountDisplay.ShadowOverlay:StripTextures()
	MountJournal.MountCount:StripTextures()
	S:HandleButton(MountJournalMountButton, true)
	S:HandleEditBox(MountJournalSearchBox)
	S:HandleScrollBar(MountJournalListScrollFrameScrollBar)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelFrame.RotateLeftButton)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelFrame.RotateRightButton)

	for i = 1, #MountJournal.ListScrollFrame.buttons do
		S:HandleItemButton(_G["MountJournalListScrollFrameButton"..i])
	end

	-- Color in green icon border on selected mount
	local function ColorSelectedMount()
		for i = 1, #MountJournal.ListScrollFrame.buttons do
			local b = _G["MountJournalListScrollFrameButton"..i]
			local t = _G["MountJournalListScrollFrameButton"..i.."Name"]
			if b.selectedTexture:IsShown() then
				t:SetTextColor(1,1,0)
				b.backdrop:SetBackdropBorderColor(1, 1, 0)
			else
				t:SetTextColor(1, 1, 1)
				b.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end
	hooksecurefunc("MountJournal_UpdateMountList", ColorSelectedMount)

	-- bug fix when we scroll
	MountJournalListScrollFrame:HookScript("OnVerticalScroll", ColorSelectedMount)
	MountJournalListScrollFrame:HookScript("OnMouseWheel", ColorSelectedMount)

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
	PetJournalFilterButton:StripTextures(true)
	S:HandleButton(PetJournalFilterButton)
	PetJournalListScrollFrame:StripTextures()
	S:HandleScrollBar(PetJournalListScrollFrameScrollBar)
	
	for i = 1, #PetJournal.listScroll.buttons do
		local b = _G["PetJournalListScrollFrameButton"..i]
		S:HandleItemButton(b)
		b.dragButton.favorite:SetParent(b.backdrop)
		b.dragButton.levelBG:SetAlpha(0)
		b.dragButton.level:SetParent(b.backdrop)
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

			if petID ~= nil then
				local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);
				if b.selectedTexture:IsShown() then
					t:SetTextColor(1,1,0)
				else
					t:SetTextColor(1, 1, 1)
				end
				if rarity then
					local color = ITEM_QUALITY_COLORS[rarity-1]
					b.backdrop:SetBackdropBorderColor(color.r, color.g, color.b);
				else
					b.backdrop:SetBackdropBorderColor(1, 1, 0)
				end
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
end

S:RegisterSkin("Blizzard_PetJournal", LoadSkin)