local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].pvp ~= true then return end

local function LoadSkin()
	local buttons = {
		"PVPFrameLeftButton",
		"PVPFrameRightButton",
		"PVPColorPickerButton1",
		"PVPColorPickerButton2",
		"PVPColorPickerButton3",
		"PVPBannerFrameAcceptButton",
	}
		
	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures()
		E.SkinButton(_G[buttons[i]])
	end

	local KillTextures = {
		"PVPHonorFrameBGTex",
		"PVPHonorFrameInfoScrollFrameScrollBar",
		"PVPConquestFrameInfoButtonInfoBG",
		"PVPConquestFrameInfoButtonInfoBGOff",
		"PVPTeamManagementFrameFlag2GlowBG",
		"PVPTeamManagementFrameFlag3GlowBG",
		"PVPTeamManagementFrameFlag5GlowBG",
		"PVPTeamManagementFrameFlag2HeaderSelected",
		"PVPTeamManagementFrameFlag3HeaderSelected",
		"PVPTeamManagementFrameFlag5HeaderSelected",
		"PVPTeamManagementFrameFlag2Header",
		"PVPTeamManagementFrameFlag3Header",
		"PVPTeamManagementFrameFlag5Header",
		"PVPTeamManagementFrameWeeklyDisplayLeft",
		"PVPTeamManagementFrameWeeklyDisplayRight",
		"PVPTeamManagementFrameWeeklyDisplayMiddle",
		"PVPBannerFramePortrait",
		"PVPBannerFramePortraitFrame",
		"PVPBannerFrameInset",
		"PVPBannerFrameEditBoxLeft",
		"PVPBannerFrameEditBoxRight",
		"PVPBannerFrameEditBoxMiddle",
		"PVPBannerFrameCancelButton_LeftSeparator",
	}

	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end

	local StripAllTextures = {
		"PVPFrame",
		"PVPFrameInset",
		"PVPHonorFrame",
		"PVPConquestFrame",
		"PVPTeamManagementFrame",
		"PVPHonorFrameTypeScrollFrame",
		"PVPFrameTopInset",
		"PVPTeamManagementFrameInvalidTeamFrame",
		"PVPBannerFrame",
		"PVPBannerFrameCustomization1",
		"PVPBannerFrameCustomization2",
		"PVPBannerFrameCustomizationFrame",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local function ArenaHeader(self, first, i)
		local button = _G["PVPTeamManagementFrameHeader"..i]

		if first then
			button:StripTextures()
		end
	end

	for i=1, 4 do
		ArenaHeader(nil, true, i)
	end	
	E.SkinScrollBar(PVPHonorFrameTypeScrollFrameScrollBar)
	
	PVPBannerFrameEditBox:CreateBackdrop("Default")
	PVPBannerFrameEditBox.backdrop:Point( "TOPLEFT", PVPBannerFrameEditBox, "TOPLEFT" ,-5,-5)
	PVPBannerFrameEditBox.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrameEditBox, "BOTTOMRIGHT",5,5)
	PVPHonorFrameInfoScrollFrameChildFrameDescription:SetTextColor(1,1,1)
	PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1,1,1)
	PVPTeamManagementFrameInvalidTeamFrame:CreateBackdrop("Default")
	PVPTeamManagementFrameInvalidTeamFrame:SetFrameLevel(PVPTeamManagementFrameInvalidTeamFrame:GetFrameLevel()+1)
	PVPTeamManagementFrameInvalidTeamFrame.backdrop:Point( "TOPLEFT", PVPTeamManagementFrameInvalidTeamFrame, "TOPLEFT")
	PVPTeamManagementFrameInvalidTeamFrame.backdrop:Point( "BOTTOMRIGHT", PVPTeamManagementFrameInvalidTeamFrame, "BOTTOMRIGHT")
	PVPTeamManagementFrameInvalidTeamFrame.backdrop:SetFrameLevel(PVPTeamManagementFrameInvalidTeamFrame:GetFrameLevel())

	PVPFrameConquestBarLeft:Kill()
	PVPFrameConquestBarRight:Kill()
	PVPFrameConquestBarMiddle:Kill()
	PVPFrameConquestBarBG:Kill()
	PVPFrameConquestBarShadow:Kill()
	PVPFrameConquestBar.progress:SetTexture(C["media"].normTex)
	PVPFrameConquestBar:CreateBackdrop("Default")
	PVPFrameConquestBar.backdrop:Point("TOPLEFT", PVPFrameConquestBar.progress, "TOPLEFT", -2, 2)
	PVPFrameConquestBar.backdrop:Point("BOTTOMRIGHT", PVPFrameConquestBar, "BOTTOMRIGHT", -2, 2)	
	
	PVPBannerFrame:CreateBackdrop("Transparent")
	PVPBannerFrame.backdrop:Point( "TOPLEFT", PVPBannerFrame, "TOPLEFT")
	PVPBannerFrame.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrame, "BOTTOMRIGHT")
	PVPBannerFrameCustomization1:CreateBackdrop("Default")
	PVPBannerFrameCustomization1.backdrop:Point( "TOPLEFT", PVPBannerFrameCustomization1LeftButton, "TOPRIGHT" ,2,0)
	PVPBannerFrameCustomization1.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrameCustomization1RightButton, "BOTTOMLEFT",-2,0)
	PVPBannerFrameCustomization2:CreateBackdrop("Default")
	PVPBannerFrameCustomization2.backdrop:Point( "TOPLEFT", PVPBannerFrameCustomization2LeftButton, "TOPRIGHT",2,0)
	PVPBannerFrameCustomization2.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrameCustomization2RightButton, "BOTTOMLEFT",-2,0)
	E.SkinCloseButton(PVPBannerFrameCloseButton,PVPBannerFrame)
	E.SkinNextPrevButton(PVPBannerFrameCustomization1LeftButton)
	PVPBannerFrameCustomization1LeftButton:Height(PVPBannerFrameCustomization1:GetHeight())
	E.SkinNextPrevButton(PVPBannerFrameCustomization1RightButton)
	PVPBannerFrameCustomization1RightButton:Height(PVPBannerFrameCustomization1:GetHeight())
	E.SkinNextPrevButton(PVPBannerFrameCustomization2LeftButton)
	PVPBannerFrameCustomization2LeftButton:Height(PVPBannerFrameCustomization1:GetHeight())
	E.SkinNextPrevButton(PVPBannerFrameCustomization2RightButton)
	PVPBannerFrameCustomization2RightButton:Height(PVPBannerFrameCustomization1:GetHeight())
	PVPFrame:CreateBackdrop("Transparent")
	PVPFrame.backdrop:Point( "TOPLEFT", PVPFrame, "TOPLEFT")
	PVPFrame.backdrop:Point( "BOTTOMRIGHT", PVPFrame, "BOTTOMRIGHT")
	E.SkinCloseButton(PVPFrameCloseButton,PVPFrame)
	E.SkinNextPrevButton(PVPTeamManagementFrameWeeklyToggleLeft)
	E.SkinNextPrevButton(PVPTeamManagementFrameWeeklyToggleRight)
	PVPColorPickerButton1:Height(PVPColorPickerButton1:GetHeight()-5)
	PVPColorPickerButton2:Height(PVPColorPickerButton1:GetHeight())
	PVPColorPickerButton3:Height(PVPColorPickerButton1:GetHeight())
	
	--War Games
	E.SkinButton(WarGameStartButton, true)
	WarGamesFrame:StripTextures()
	E.SkinScrollBar(WarGamesFrameScrollFrameScrollBar, 5)
	
	WarGameStartButton:ClearAllPoints()
	WarGameStartButton:Point("LEFT", PVPFrameLeftButton, "RIGHT", 2, 0)
	WarGamesFrameDescription:SetTextColor(1, 1, 1)
	
	--Freaking gay Cancel Button FFSlocal
	local f = PVPBannerFrameCancelButton
	local l = _G[f:GetName().."Left"]
	local m = _G[f:GetName().."Middle"]
	local r = _G[f:GetName().."Right"]
	if l then l:SetAlpha(0) end
	if m then m:SetAlpha(0) end
	if r then r:SetAlpha(0) end
	f:CreateBackdrop("Default")
	f:SetFrameLevel(PVPBannerFrameAcceptButton:GetFrameLevel()+1)
	f.backdrop:Point( "TOPLEFT", PVPBannerFrameAcceptButton, "TOPLEFT", PVPBannerFrame:GetWidth()-PVPBannerFrameAcceptButton:GetWidth()-10,0)
	f.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrameAcceptButton, "BOTTOMRIGHT", PVPBannerFrame:GetWidth()-PVPBannerFrameAcceptButton:GetWidth()-10, 0)
	f.backdrop:SetFrameLevel(f:GetFrameLevel()-1)
	
	--Bottom Tabs
	for i=1,4 do
		E.SkinTab(_G["PVPFrameTab"..i])
	end		
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)