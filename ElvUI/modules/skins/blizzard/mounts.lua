local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
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
	end	

	local function ColorSelectedPet()
		for i = 1, #PetJournal.listScroll.buttons do
			local b = _G["PetJournalListScrollFrameButton"..i]
			local t = _G["PetJournalListScrollFrameButton"..i.."Name"]
			if b.selectedTexture:IsShown() then
				t:SetTextColor(1,1,0)
				b.backdrop:SetBackdropBorderColor(1, 1, 0)
			else
				t:SetTextColor(1, 1, 1)
				b.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end	
	hooksecurefunc('PetJournal_UpdatePetList', ColorSelectedPet)
	PetJournalListScrollFrame:HookScript("OnVerticalScroll", ColorSelectedPet)
	PetJournalListScrollFrame:HookScript("OnMouseWheel", ColorSelectedPet)
	
	PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')
	
	S:HandleItemButton(PetJournalHealPetButton, true)
	PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	
	for i=1, 3 do
		_G['PetJournalLoadoutPet'..i]:StripTextures()
		_G['PetJournalLoadoutPet'..i]:SetTemplate()
		
		_G['PetJournalLoadoutPet'..i].dragButton:SetTemplate('Default', true)
		_G['PetJournalLoadoutPet'..i].dragButton:StyleButton()
	end
	PetJournalPetCardList:SetPoint('TOPLEFT', PetJournal, 'TOPRIGHT', 1, -23)
	PetJournalPetCardList.MainCard:StripTextures()
	PetJournalPetCardList.MainCard:SetTemplate('Transparent')
	
	PetJournalPetCardListIconBG:Kill()
	PetJournalPetCardListIcon:SetTexCoord(unpack(E.TexCoords))
	
	S:HandleCloseButton(PetJournalPetCardListCloseButton)
	PetJournalPetCardListCloseButton:ClearAllPoints()
	PetJournalPetCardListCloseButton:Point('TOPRIGHT', PetJournalPetCardList, 'TOPRIGHT')
	PetJournalPetCardListCloseButton:SetFrameLevel(PetJournalPetCardListCloseButton:GetFrameLevel() + 2)
	
	PetJournalPrimaryAbilityTooltip:StripTextures()
	PetJournalPrimaryAbilityTooltip:SetTemplate('Transparent')
	
	for i=1, 6 do
		local frame = _G['PetJournalPetCardListSpell'..i]
		frame:DisableDrawLayer('BACKGROUND')
		frame:CreateBackdrop('Default')
		frame.backdrop:SetAllPoints()
		frame.icon:SetTexCoord(unpack(E.TexCoords))
		frame.icon:ClearAllPoints()
		frame.icon:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 2, 2)
		frame.icon:Size(34)
	end
	
	PetJournalPetCardListHealthStatusBar:StripTextures()
	PetJournalPetCardListHealthStatusBar:CreateBackdrop('Default')
	PetJournalPetCardListHealthStatusBar:SetStatusBarTexture(E.media.normTex)
	PetJournalPetCardListHealthStatusBar.healthRankText:SetPoint('CENTER', 0, 1)
	PetJournalPetCardListStatusBar:StripTextures()
	PetJournalPetCardListStatusBar:CreateBackdrop('Default')	
	PetJournalPetCardListStatusBar:SetStatusBarTexture(E.media.normTex)
	PetJournalPetCardListStatusBar:SetPoint('TOP', PetJournalPetCardListHealthStatusBar, 'BOTTOM', 0, -6)
	PetJournalPetCardListStatusBar.rankText:SetPoint('CENTER', 0, 1)
end

S:RegisterSkin("Blizzard_PetJournal", LoadSkin)