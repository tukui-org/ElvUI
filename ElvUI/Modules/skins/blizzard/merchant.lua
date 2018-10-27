local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select, unpack = select, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.merchant ~= true then return end

	local frames = {
		"MerchantBuyBackItem",
		"MerchantFrame",
	}

	-- skin main frames
	for i = 1, #frames do
		_G[frames[i]]:StripTextures(true)
		_G[frames[i]]:CreateBackdrop("Transparent")
	end

	MerchantExtraCurrencyInset:StripTextures()
	MerchantExtraCurrencyBg:StripTextures()
	MerchantFrameInset:StripTextures()
	MerchantMoneyBg:StripTextures()
	MerchantMoneyInset:StripTextures()
	MerchantBuyBackItem.backdrop:Point("TOPLEFT", -6, 6)
	MerchantBuyBackItem.backdrop:Point("BOTTOMRIGHT", 6, -6)

	local MerchantFrame = _G["MerchantFrame"]
	MerchantFrame.backdrop:Point("TOPLEFT", 6, 2)
	MerchantFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)

	S:HandleDropDownBox(MerchantFrameLootFilter)

	-- skin tabs
	for i= 1, 2 do
		S:HandleTab(_G["MerchantFrameTab"..i])
	end

	-- skin icons / merchant slots
	for i = 1, 12 do
		local button = _G["MerchantItem"..i.."ItemButton"]
		local icon = button.icon
		local iconBorder = button.IconBorder
		local item = _G["MerchantItem"..i]
		item:StripTextures(true)
		item:CreateBackdrop("Default")

		button:StripTextures()
		button:StyleButton(false)
		button:SetTemplate("Default", true)
		button:Point("TOPLEFT", item, "TOPLEFT", 4, -4)
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
		iconBorder:SetAlpha(0)
		hooksecurefunc(iconBorder, 'SetVertexColor', function(self, r, g, b)
			self:GetParent():SetBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)
		hooksecurefunc(iconBorder, 'Hide', function(self)
			self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

		_G["MerchantItem"..i.."MoneyFrame"]:ClearAllPoints()
		_G["MerchantItem"..i.."MoneyFrame"]:Point("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
	end

	-- Skin buyback item frame + icon
	MerchantBuyBackItemItemButton:StripTextures()
	MerchantBuyBackItemItemButton:StyleButton(false)
	MerchantBuyBackItemItemButton:SetTemplate("Default", true)
	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	MerchantBuyBackItemItemButtonIconTexture:SetInside()
	MerchantBuyBackItemItemButton.IconBorder:SetAlpha(0)
	hooksecurefunc(MerchantBuyBackItemItemButton.IconBorder, 'SetVertexColor', function(self, r, g, b)
		self:GetParent():SetBackdropBorderColor(r, g, b)
		self:SetTexture("")
	end)
	hooksecurefunc(MerchantBuyBackItemItemButton.IconBorder, 'Hide', function(self)
		self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	MerchantRepairItemButton:StyleButton(false)
	MerchantRepairItemButton:SetTemplate("Default", true)
	for i=1, MerchantRepairItemButton:GetNumRegions() do
		local region = select(i, MerchantRepairItemButton:GetRegions())

		if region:GetObjectType() == "Texture" then
			region:SetTexCoord(0.04, 0.24, 0.06, 0.5)
			region:SetInside()
		end
	end

	MerchantGuildBankRepairButton:StyleButton()
	MerchantGuildBankRepairButton:SetTemplate("Default", true)
	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
	MerchantGuildBankRepairButtonIcon:SetInside()

	MerchantRepairAllButton:StyleButton(false)
	MerchantRepairAllButton:SetTemplate("Default", true)
	MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	MerchantRepairAllIcon:SetInside()

	-- Skin misc frames
	MerchantFrame:Width(360)
	S:HandleCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop)
	S:HandleNextPrevButton(MerchantNextPageButton)
	S:HandleNextPrevButton(MerchantPrevPageButton)
end

S:AddCallback("Merchant", LoadSkin)
