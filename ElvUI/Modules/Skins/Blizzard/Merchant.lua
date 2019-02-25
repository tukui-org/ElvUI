local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local select, unpack = select, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.merchant ~= true then return end

	local MerchantFrame = _G.MerchantFrame
	S:HandlePortraitFrame(MerchantFrame, true)

	MerchantFrame.backdrop:Point("TOPLEFT", 6, 2)
	MerchantFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)

	MerchantFrame:Width(360)

	_G.MerchantBuyBackItem:StripTextures(true)
	_G.MerchantBuyBackItem:CreateBackdrop("Transparent")

	_G.MerchantExtraCurrencyInset:StripTextures()
	_G.MerchantExtraCurrencyBg:StripTextures()

	_G.MerchantMoneyBg:StripTextures()
	_G.MerchantMoneyInset:StripTextures()
	_G.MerchantBuyBackItem.backdrop:Point("TOPLEFT", -6, 6)
	_G.MerchantBuyBackItem.backdrop:Point("BOTTOMRIGHT", 6, -6)

	S:HandleDropDownBox(_G.MerchantFrameLootFilter)

	-- skin tabs
	for i= 1, 2 do
		S:HandleTab(_G["MerchantFrameTab"..i])
	end

	-- skin icons / merchant slots
	for i = 1, _G.BUYBACK_ITEMS_PER_PAGE do
		local button = _G["MerchantItem"..i.."ItemButton"]
		local icon = button.icon
		local iconBorder = button.IconBorder
		local item = _G["MerchantItem"..i]
		item:StripTextures(true)
		item:CreateBackdrop()

		button:StripTextures()
		button:StyleButton(false)
		button:SetTemplate("Default", true)
		button:Point("TOPLEFT", item, "TOPLEFT", 4, -4)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", E.mult, -E.mult)
		icon:SetPoint("BOTTOMRIGHT", -E.mult, E.mult)

		iconBorder:SetAlpha(0)
		hooksecurefunc(iconBorder, 'SetVertexColor', function(self, r, g, b)
			self:GetParent():SetBackdropBorderColor(r, g, b)
			self:SetTexture()
		end)
		hooksecurefunc(iconBorder, 'Hide', function(self)
			self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

		_G["MerchantItem"..i.."MoneyFrame"]:ClearAllPoints()
		_G["MerchantItem"..i.."MoneyFrame"]:Point("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
	end

	-- Skin buyback item frame + icon
	_G.MerchantBuyBackItemItemButton:StripTextures()
	_G.MerchantBuyBackItemItemButton:StyleButton(false)
	_G.MerchantBuyBackItemItemButton:SetTemplate("Default", true)

	_G.MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	_G.MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
	_G.MerchantBuyBackItemItemButtonIconTexture:SetPoint("TOPLEFT", E.mult, -E.mult)
	_G.MerchantBuyBackItemItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -E.mult, E.mult)

	_G.MerchantBuyBackItemItemButton.IconBorder:SetAlpha(0)
	hooksecurefunc(_G.MerchantBuyBackItemItemButton.IconBorder, 'SetVertexColor', function(self, r, g, b)
		self:GetParent():SetBackdropBorderColor(r, g, b)
		self:SetTexture()
	end)
	hooksecurefunc(_G.MerchantBuyBackItemItemButton.IconBorder, 'Hide', function(self)
		self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	_G.MerchantRepairItemButton:StyleButton(false)
	_G.MerchantRepairItemButton:SetTemplate("Default", true)
	for i=1, _G.MerchantRepairItemButton:GetNumRegions() do
		local region = select(i, _G.MerchantRepairItemButton:GetRegions())

		if region:IsObjectType('Texture') then
			region:SetTexCoord(0.04, 0.24, 0.06, 0.5)
			region:SetInside()
		end
	end

	_G.MerchantGuildBankRepairButton:StyleButton()
	_G.MerchantGuildBankRepairButton:SetTemplate("Default", true)
	_G.MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
	_G.MerchantGuildBankRepairButtonIcon:SetInside()

	_G.MerchantRepairAllButton:StyleButton(false)
	_G.MerchantRepairAllButton:SetTemplate("Default", true)
	_G.MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	_G.MerchantRepairAllIcon:SetInside()

	S:HandleNextPrevButton(_G.MerchantNextPageButton, nil, nil, true, true)
	S:HandleNextPrevButton(_G.MerchantPrevPageButton, nil, nil, true, true)
end

S:AddCallback("Merchant", LoadSkin)
