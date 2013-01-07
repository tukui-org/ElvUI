local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "TomTomSkin"
local function SkinTomTom()
	if TomTomBlock then
		TomTomBlock:SetTemplate("Transparent")
	end
end
AS:RegisterSkin(name, SkinTomTom)

name = "AlwaysTrue"
function SkinMisc()
	if IsAddOnLoaded("Numeration") and AS:CheckOption("NumerationSkin") then
		AS:SkinFrame(NumerationFrame)
	end
	if IsAddOnLoaded("Critline") and AS:CheckOption("CritlineSkin") then
		AS:SkinBackdropFrame(Critline.display)
		Critline.display.backdrop:SetFrameStrata("BACKGROUND")
	end	
	if IsAddOnLoaded("InspectEquip") and AS:CheckOption("InspectEquipSkin") then
		AS:SkinFrame(InspectEquip_InfoWindow)
		S:HandleCloseButton(InspectEquip_InfoWindow_CloseButton)
	end
	if IsAddOnLoaded("stAddonManager") then
		GameMenuFrame:HookScript("OnShow", function() if GameMenuButtonAddons then S:HandleButton(GameMenuButtonAddons) end end)
	end
	if IsAddOnLoaded("VengeanceStatus") and (AS:CheckOption("VengeanceStatusSkin")) then
		AS:SkinStatusBar(VengeanceStatus_StatusBar)
	end
	
	LoadAddOn("acb_CastBar")
	if IsAddOnLoaded("acb_CastBar") then
		AzCastBarPluginPlayer:StripTextures() AzCastBarPluginPlayer:CreateBackdrop()
		AzCastBarPluginTarget:StripTextures() AzCastBarPluginTarget:CreateBackdrop()
		AzCastBarPluginFocus:StripTextures() AzCastBarPluginFocus:CreateBackdrop()
		AzCastBarPluginMirror:StripTextures() AzCastBarPluginMirror:CreateBackdrop()
		AzCastBarPluginPet:StripTextures() AzCastBarPluginPet:CreateBackdrop()
	end
	for i = 1, 10 do
		if _G["StaticPopup"..i] then
			_G["StaticPopup"..i]:SetTemplate("Transparent")
			if _G["StaticPopup"..i.."Button1"] then S:HandleButton(_G["StaticPopup"..i.."Button1"]) end
			if _G["StaticPopup"..i.."Button2"] then S:HandleButton(_G["StaticPopup"..i.."Button2"]) end
			if _G["StaticPopup"..i.."CloseButton"] then S:HandleCloseButton(_G["StaticPopup"..i.."CloseButton"]) end
		end
	end
end
AS:RegisterSkin(name, SkinMisc)
