local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

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

	local VoidStorageFrame = _G.VoidStorageFrame
	for i = 1, 2 do
		local tab = VoidStorageFrame["Page"..i]
		S:HandleButton(tab)
		tab:StyleButton(nil, true)
		S:HandleIcon(tab:GetNormalTexture())
		tab:GetNormalTexture():SetInside()
	end

	VoidStorageFrame:StripTextures()
	VoidStorageFrame:SetTemplate("Transparent")

	VoidStorageFrame.Page1:SetNormalTexture("Interface\\Icons\\INV_Enchant_EssenceCosmicGreater")
	VoidStorageFrame.Page1:Point("LEFT", "$parent", "TOPRIGHT", 1, -60)

	VoidStorageFrame.Page2:SetNormalTexture("Interface\\Icons\\INV_Enchant_EssenceArcaneLarge")

	_G.VoidStoragePurchaseFrame:SetFrameStrata('DIALOG')
	_G.VoidStoragePurchaseFrame:SetTemplate()

	S:HandleButton(_G.VoidStoragePurchaseButton)
	S:HandleButton(_G.VoidStorageHelpBoxButton)
	S:HandleButton(_G.VoidStorageTransferButton)

	S:HandleCloseButton(_G.VoidStorageBorderFrame.CloseButton)

	S:HandleEditBox(_G.VoidItemSearchBox)

	for StorageType, NumSlots  in pairs({ ['Deposit'] = 9, ['Withdraw'] = 9, ['Storage'] = 80 }) do
		for i = 1, NumSlots do
			local Button = _G["VoidStorage"..StorageType.."Button"..i]
			Button:StripTextures()
			Button:SetTemplate()
			Button:StyleButton()
			S:HandleIcon(Button.icon)
			Button.icon:SetInside()
			Button.IconBorder:SetAlpha(0)
			hooksecurefunc(Button.IconBorder, 'SetVertexColor', function(_, r, g, b)
				Button:SetBackdropBorderColor(r, g, b)
			end)
			hooksecurefunc(Button.IconBorder, 'Hide', function()
				Button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)
		end
	end
end

S:AddCallbackForAddon("Blizzard_VoidStorageUI", "VoidStorage", LoadSkin)
