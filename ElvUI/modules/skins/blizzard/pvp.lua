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
		button:StyleButton()	
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
	-->>>CONQUEST FRAME
	ConquestFrame.Inset:StripTextures()
	--ConquestFrame.Inset:SetTemplate("Transparent")
	
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

end
S:RegisterSkin('Blizzard_PVPUI', LoadSkin)