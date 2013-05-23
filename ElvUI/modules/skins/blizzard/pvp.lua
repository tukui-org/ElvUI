local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true then return end
	
	PVPUIFrame:StripTextures()
	PVPUIFrame:SetTemplate("Transparent")
	PVPUIFrame.LeftInset:StripTextures()
	--PVPUIFrame.LeftInset:SetTemplate("Transparent")
	PVPUIFrame.Shadows:StripTextures()
	
	S:HandleCloseButton(PVPUIFrameCloseButton)
	
	for i=1, 2 do
		S:HandleTab(_G["PVPUIFrameTab"..i])
	end
	
	for i=1, 3 do
		local button = _G["PVPQueueFrameCategoryButton"..i]
		button:SetTemplate('Default')
		button.Background:Kill()
		button.Ring:Kill()
		button.Icon:Size(45)
		button.Icon:SetTexCoord(.15, .85, .15, .85)
		button:CreateBackdrop("Default")
		button.backdrop:SetOutside(button.Icon)
		button.backdrop:SetFrameLevel(button:GetFrameLevel())
		button.Icon:SetParent(button.backdrop)
		button:StyleButton(nil, true)	
	end
	
	for i=1, 3 do
		local button = _G["PVPArenaTeamsFrameTeam"..i]
		button:SetTemplate('Default')
		button.Background:Kill()
		button:StyleButton()
	end
	
	-->>>HONOR FRAME
	S:HandleDropDownBox(HonorFrameTypeDropDown)
	
	HonorFrame.Inset:StripTextures()
	--HonorFrame.Inset:SetTemplate("Transparent")
	
	S:HandleScrollBar(HonorFrameSpecificFrameScrollBar)
	S:HandleButton(HonorFrameSoloQueueButton, true)
	S:HandleButton(HonorFrameGroupQueueButton, true)
	HonorFrame.BonusFrame:StripTextures()
	HonorFrame.BonusFrame.ShadowOverlay:StripTextures()
	HonorFrame.BonusFrame.RandomBGButton:StripTextures()
	HonorFrame.BonusFrame.RandomBGButton:SetTemplate()
	HonorFrame.BonusFrame.RandomBGButton:StyleButton(nil, true)
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetInside()
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetTexture(1, 1, 0, 0.1)
	HonorFrame.BonusFrame.CallToArmsButton:StripTextures()
	HonorFrame.BonusFrame.CallToArmsButton:SetTemplate()
	HonorFrame.BonusFrame.CallToArmsButton:StyleButton(nil, true)
	HonorFrame.BonusFrame.CallToArmsButton.SelectedTexture:SetInside()
	HonorFrame.BonusFrame.CallToArmsButton.SelectedTexture:SetTexture(1, 1, 0, 0.1)

	HonorFrame.BonusFrame.DiceButton:DisableDrawLayer("ARTWORK")
	HonorFrame.BonusFrame.DiceButton:SetHighlightTexture("")

	HonorFrame.RoleInset:StripTextures()
	S:HandleCheckBox(HonorFrame.RoleInset.DPSIcon.checkButton, true)
	S:HandleCheckBox(HonorFrame.RoleInset.TankIcon.checkButton, true)
	S:HandleCheckBox(HonorFrame.RoleInset.HealerIcon.checkButton, true)
	
	HonorFrame.RoleInset.TankIcon:DisableDrawLayer("ARTWORK")
	HonorFrame.RoleInset.TankIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.TankIcon.bg = HonorFrame.RoleInset.TankIcon:CreateTexture(nil, 'BACKGROUND')
	HonorFrame.RoleInset.TankIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	HonorFrame.RoleInset.TankIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	HonorFrame.RoleInset.TankIcon.bg:SetPoint('CENTER')
	HonorFrame.RoleInset.TankIcon.bg:Size(80)
	HonorFrame.RoleInset.TankIcon.bg:SetAlpha(0.5)

	HonorFrame.RoleInset.HealerIcon:DisableDrawLayer("ARTWORK")
	HonorFrame.RoleInset.HealerIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.HealerIcon.bg = HonorFrame.RoleInset.HealerIcon:CreateTexture(nil, 'BACKGROUND')
	HonorFrame.RoleInset.HealerIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	HonorFrame.RoleInset.HealerIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	HonorFrame.RoleInset.HealerIcon.bg:SetPoint('CENTER')
	HonorFrame.RoleInset.HealerIcon.bg:Size(80)
	HonorFrame.RoleInset.HealerIcon.bg:SetAlpha(0.5)


	HonorFrame.RoleInset.DPSIcon:DisableDrawLayer("ARTWORK")
	HonorFrame.RoleInset.DPSIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.DPSIcon.bg = HonorFrame.RoleInset.DPSIcon:CreateTexture(nil, 'BACKGROUND')
	HonorFrame.RoleInset.DPSIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	HonorFrame.RoleInset.DPSIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
	HonorFrame.RoleInset.DPSIcon.bg:SetPoint('CENTER')
	HonorFrame.RoleInset.DPSIcon.bg:Size(80)
	HonorFrame.RoleInset.DPSIcon.bg:SetAlpha(0.5)

	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(self)
		if self.bg then
			self.bg:SetDesaturated(true)
		end
	end)
	for i = 1, 2 do
		local b = HonorFrame.BonusFrame["WorldPVP"..i.."Button"]
		b:StripTextures()
		b:SetTemplate()
		b:StyleButton(nil, true)
		b.SelectedTexture:SetInside()
		b.SelectedTexture:SetTexture(1, 1, 0, 0.1)
	end


	-->>>CONQUEST FRAME
	ConquestFrame.Inset:StripTextures()
	
	--CapProgressBar_Update(ConquestFrame.ConquestBar, 0, 0, nil, nil, 1000, 2200);
	ConquestPointsBarLeft:Kill()
	ConquestPointsBarRight:Kill()
	ConquestPointsBarMiddle:Kill()
	ConquestPointsBarBG:Kill()
	ConquestPointsBarShadow:Kill()
	ConquestPointsBar.progress:SetTexture(E["media"].normTex)
	ConquestPointsBar:CreateBackdrop('Default')
	ConquestPointsBar.backdrop:SetOutside(ConquestPointsBar, nil, E.PixelMode and -2 or -1)
	ConquestFrame:StripTextures()
	ConquestFrame.ShadowOverlay:StripTextures()
	S:HandleButton(ConquestJoinButton, true)
	ConquestFrame.RatedBG:StripTextures()
	ConquestFrame.RatedBG:SetTemplate()
	ConquestFrame.RatedBG:StyleButton(nil, true)
	ConquestFrame.RatedBG.SelectedTexture:SetInside()
	ConquestFrame.RatedBG.SelectedTexture:SetTexture(1, 1, 0, 0.1)

	-->>>WARGRAMES FRAME
	WarGamesFrame:StripTextures()
	WarGamesFrame.RightInset:StripTextures()
	S:HandleButton(WarGameStartButton, true)
	S:HandleScrollBar(WarGamesFrameScrollFrameScrollBar)
	WarGamesFrame.HorizontalBar:StripTextures()
	
	-->>>ARENATEAMS
	PVPArenaTeamsFrame:StripTextures()
	ArenaTeamFrame.TopInset:StripTextures()
	ArenaTeamFrame.BottomInset:StripTextures()
	ArenaTeamFrame.WeeklyDisplay:StripTextures()
	S:HandleNextPrevButton(ArenaTeamFrame.weeklyToggleRight)
	S:HandleNextPrevButton(ArenaTeamFrame.weeklyToggleLeft)
	ArenaTeamFrame:StripTextures()
	ArenaTeamFrame.TopShadowOverlay:StripTextures()
	
	for i=1, 4 do
		_G["ArenaTeamFrameHeader"..i.."Left"]:Kill()
		_G["ArenaTeamFrameHeader"..i.."Middle"]:Kill()
		_G["ArenaTeamFrameHeader"..i.."Right"]:Kill()
		_G["ArenaTeamFrameHeader"..i]:SetHighlightTexture(nil)
	end
	
	for i=1, 3 do
		local b = ARENA_BUTTONS[i]
		b:StripTextures()
		b:SetTemplate()
		b:StyleButton(nil, true)
		b.SelectedTexture:SetInside()
		b.SelectedTexture:SetTexture(1, 1, 0, 0.1)

		if i > 1 then
			b:ClearAllPoints()
			b:SetPoint("TOP", ARENA_BUTTONS[i-1], "BOTTOM", 0, -E.Border)
		end
	end

	S:HandleButton(ArenaTeamFrame.AddMemberButton, true)
	
	-->>>PVP BANNERS
	PVPBannerFrame:StripTextures()
	PVPBannerFramePortrait:SetAlpha(0)
	PVPBannerFrame:SetTemplate("Transparent")
	S:HandleCloseButton(PVPBannerFrameCloseButton)
	S:HandleEditBox(PVPBannerFrameEditBox)
	PVPBannerFrameEditBox.backdrop:SetOutside(PVPBannerFrameEditBox, 2, -5) ---<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<CHECK THIS WITH NON-PIXELPERFECT
	PVPBannerFrame.Inset:StripTextures()
	
	S:HandleButton(PVPBannerFrameAcceptButton, true)
	
	--Duplicate button name workaround
	for i=1, PVPBannerFrame:GetNumChildren() do
		local child = select(i, PVPBannerFrame:GetChildren())
		if child and child:GetObjectType() == "Button" and child:GetWidth() == 80 then
			S:HandleButton(child, true)
		end
	end
	
	for i=1, 3 do
		S:HandleButton(_G["PVPColorPickerButton"..i])
		_G["PVPColorPickerButton"..i]:SetHeight(_G["PVPColorPickerButton"..i]:GetHeight() - 2)
	end
	
	PVPBannerFrameCustomizationFrame:StripTextures()
	
	for i=1, 2 do
		_G["PVPBannerFrameCustomization"..i]:StripTextures()
		S:HandleNextPrevButton(_G["PVPBannerFrameCustomization"..i.."RightButton"])
		S:HandleNextPrevButton(_G["PVPBannerFrameCustomization"..i.."LeftButton"])
	end

	PVPReadyDialog:StripTextures()
	PVPReadyDialog:SetTemplate("Transparent")
	S:HandleButton(PVPReadyDialogEnterBattleButton)
	S:HandleButton(PVPReadyDialogLeaveQueueButton)
	S:HandleCloseButton(PVPReadyDialogCloseButton)
	PVPReadyDialogRoleIcon.texture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	PVPReadyDialogRoleIcon.texture:SetAlpha(0.5)

	hooksecurefunc("PVPReadyDialog_Display", function(self, index, displayName, isRated, queueType, gameType, role)
		if role == "DAMAGER" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
		elseif role == "TANK" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonTank.background:GetTexCoord())
		elseif role == "HEALER" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
		end

		self.background:Hide()
	end)




	S:HandleButton(PVPBannerFrameCancelButton)
end
S:RegisterSkin('Blizzard_PVPUI', LoadSkin)