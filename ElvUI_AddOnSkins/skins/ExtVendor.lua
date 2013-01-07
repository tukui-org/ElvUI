local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "ExtVendorSkin"
local function SkinExtVendor(self)
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.merchant ~= true then return end

	S:HandleButton(MerchantFrameFilterButton)
	S:HandleButton(MerchantFrameSellJunkButton)

	for i = 1, 20 do
		local b = _G["MerchantItem"..i.."ItemButton"]
		local t = _G["MerchantItem"..i.."ItemButtonIconTexture"]
		local item_bar = _G["MerchantItem"..i]
		item_bar:StripTextures(true)
		b:StripTextures()
		b:StyleButton(false)
		b:Point("TOPLEFT", item_bar, "TOPLEFT", 4, -4)
		t:SetTexCoord(.08, .92, .08, .92)
		t:ClearAllPoints()
		t:Point("TOPLEFT", 2, -2)
		t:Point("BOTTOMRIGHT", -2, 2)

		item_bar:CreateBackdrop("Default")
		b:SetTemplate("Default", true)

	end
	MerchantFrame:Width(690)
	ExtVendor_SellJunkPopup:SetTemplate("Transparent")
	S:HandleButton(ExtVendor_SellJunkPopupYesButton)
	S:HandleButton(ExtVendor_SellJunkPopupNoButton)
end

AS:RegisterSkin(name,SkinExtVendor)

