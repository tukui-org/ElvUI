local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].merchant ~= true then return end

local function LoadSkin()
	local frames = {
		"MerchantBuyBackItem",
		"MerchantFrame",
	}
	
	-- skin main frames
	for i = 1, #frames do
		_G[frames[i]]:StripTextures(true)
		_G[frames[i]]:CreateBackdrop("Transparent")
	end
	MerchantBuyBackItem.backdrop:Point("TOPLEFT", -6, 6)
	MerchantBuyBackItem.backdrop:Point("BOTTOMRIGHT", 6, -6)
	MerchantFrame.backdrop:Point("TOPLEFT", 6, 0)
	MerchantFrame.backdrop:Point("BOTTOMRIGHT", 0, 35)
	MerchantFrame.backdrop:Point("BOTTOMRIGHT", 0, 60)
	-- skin tabs
	for i= 1, 2 do
		E.SkinTab(_G["MerchantFrameTab"..i])
	end
	
	-- skin icons / merchant slots
	for i = 1, 12 do
		local b = _G["MerchantItem"..i.."ItemButton"]
		local t = _G["MerchantItem"..i.."ItemButtonIconTexture"]
		local item_bar = _G["MerchantItem"..i]
		item_bar:StripTextures(true)
		item_bar:CreateBackdrop("Default")
		
		b:StripTextures()
		b:StyleButton(false)
		b:SetTemplate("Default", true)
		b:Point("TOPLEFT", item_bar, "TOPLEFT", 4, -4)
		t:SetTexCoord(.08, .92, .08, .92)
		t:ClearAllPoints()
		t:Point("TOPLEFT", 2, -2)
		t:Point("BOTTOMRIGHT", -2, 2)
		
		_G["MerchantItem"..i.."MoneyFrame"]:ClearAllPoints()
		_G["MerchantItem"..i.."MoneyFrame"]:Point("BOTTOMLEFT", b, "BOTTOMRIGHT", 3, 0)
		
	end
	
	-- Skin buyback item frame + icon
	MerchantBuyBackItemItemButton:StripTextures()
	MerchantBuyBackItemItemButton:StyleButton(false)
	MerchantBuyBackItemItemButton:SetTemplate("Default", true)
	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
	MerchantBuyBackItemItemButtonIconTexture:Point("TOPLEFT", 2, -2)
	MerchantBuyBackItemItemButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)

	
	MerchantRepairItemButton:StyleButton(false)
	MerchantRepairItemButton:SetTemplate("Default", true)
	for i=1, MerchantRepairItemButton:GetNumRegions() do
		local region = select(i, MerchantRepairItemButton:GetRegions())
		if region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\MerchantFrame\\UI-Merchant-RepairIcons" then
			region:SetTexCoord(0.04, 0.24, 0.06, 0.5)
			region:ClearAllPoints()
			region:Point("TOPLEFT", 2, -2)
			region:Point("BOTTOMRIGHT", -2, 2)
		end
	end
	
	MerchantGuildBankRepairButton:StyleButton()
	MerchantGuildBankRepairButton:SetTemplate("Default", true)
	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
	MerchantGuildBankRepairButtonIcon:ClearAllPoints()
	MerchantGuildBankRepairButtonIcon:Point("TOPLEFT", 2, -2)
	MerchantGuildBankRepairButtonIcon:Point("BOTTOMRIGHT", -2, 2)
	
	MerchantRepairAllButton:StyleButton(false)
	MerchantRepairAllButton:SetTemplate("Default", true)
	MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	MerchantRepairAllIcon:ClearAllPoints()
	MerchantRepairAllIcon:Point("TOPLEFT", 2, -2)
	MerchantRepairAllIcon:Point("BOTTOMRIGHT", -2, 2)
	
	-- Skin misc frames
	MerchantFrame:Width(360)
	E.SkinCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop)
	E.SkinNextPrevButton(MerchantNextPageButton)
	E.SkinNextPrevButton(MerchantPrevPageButton)
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)