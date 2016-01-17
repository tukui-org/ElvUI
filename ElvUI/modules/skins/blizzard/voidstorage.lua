local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--WoW API / Variables
local LE_ITEM_QUALITY_COMMON = LE_ITEM_QUALITY_COMMON
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.voidstorage ~= true then return end
	local StripAllTextures = {
		"VoidStorageBorderFrame",
		"VoidStorageDepositFrame",
		"VoidStorageWithdrawFrame",
		"VoidStorageCostFrame",
		"VoidStorageStorageFrame",
		"VoidStoragePurchaseFrame",
		"VoidItemSearchBox",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end


	for i=1, 2 do
		local tab = VoidStorageFrame["Page"..i]
		tab:DisableDrawLayer("BACKGROUND")
		tab:StyleButton(nil, true)
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		tab:GetNormalTexture():SetInside()
		tab:SetTemplate()
	end

	VoidStoragePurchaseFrame:SetFrameStrata('DIALOG')
	VoidStorageFrame:SetTemplate("Transparent")
	VoidStoragePurchaseFrame:SetTemplate("Default")
	VoidStorageFrameMarbleBg:Kill()
	VoidStorageFrameLines:Kill()
	select(2, VoidStorageFrame:GetRegions()):Kill()

	S:HandleButton(VoidStoragePurchaseButton)
	S:HandleButton(VoidStorageHelpBoxButton)
	S:HandleButton(VoidStorageTransferButton)

	S:HandleCloseButton(VoidStorageBorderFrame.CloseButton)
	VoidItemSearchBox:CreateBackdrop("Overlay")
	VoidItemSearchBox.backdrop:Point("TOPLEFT", 10, -1)
	VoidItemSearchBox.backdrop:Point("BOTTOMRIGHT", 4, 1)

	for i = 1, 9 do
		local button_d = _G["VoidStorageDepositButton"..i]
		local button_w = _G["VoidStorageWithdrawButton"..i]
		local icon_d = _G["VoidStorageDepositButton"..i.."IconTexture"]
		local icon_w = _G["VoidStorageWithdrawButton"..i.."IconTexture"]

		_G["VoidStorageDepositButton"..i.."Bg"]:Hide()
		_G["VoidStorageWithdrawButton"..i.."Bg"]:Hide()

		button_d:StyleButton()
		button_d:SetTemplate()
		button_d.IconBorder:SetAlpha(0)

		button_w:StyleButton()
		button_w:SetTemplate()
		button_w.IconBorder:SetAlpha(0)

		icon_d:SetTexCoord(unpack(E.TexCoords))
		icon_d:SetInside()

		icon_w:SetTexCoord(unpack(E.TexCoords))
		icon_w:SetInside()
	end

	for i = 1, 80 do
		local button = _G["VoidStorageStorageButton"..i]
		local icon = _G["VoidStorageStorageButton"..i.."IconTexture"]

		_G["VoidStorageStorageButton"..i.."Bg"]:Hide()

		button:StyleButton()
		button:SetTemplate()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
		button.IconBorder:SetAlpha(0)
	end

	hooksecurefunc("VoidStorage_ItemsUpdate", function(doDeposit, doContents)
		local self = VoidStorageFrame;
		if ( doDeposit ) then
			for i=1, 9 do
				local button = _G["VoidStorageDepositButton"..i]
				local _, _, quality = GetVoidTransferDepositInfo(i);
				if (quality and quality > LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
					button:SetBackdropBorderColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
				else
					button:SetTemplate()
				end
			end
		end

		if ( doContents ) then
			for i=1, 9 do
				local button = _G["VoidStorageWithdrawButton"..i]
				local _, _, quality = GetVoidTransferWithdrawalInfo(i);
				if (quality and quality > LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
					button:SetBackdropBorderColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
				else
					button:SetTemplate()
				end
			end

			for i = 1, 80 do
				local button = _G["VoidStorageStorageButton"..i]
				local _, _, _, _, _, quality = GetVoidItemInfo(self.page, i);
				if (quality and quality > LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
					button:SetBackdropBorderColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
				else
					button:SetTemplate()
				end
			end
		end
	end)
end

S:RegisterSkin("Blizzard_VoidStorageUI", LoadSkin)