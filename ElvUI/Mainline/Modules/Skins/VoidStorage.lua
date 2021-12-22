local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs

function S:Blizzard_VoidStorageUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.voidstorage) then return end

	local StripAllTextures = {
		'VoidStorageBorderFrame',
		'VoidStorageDepositFrame',
		'VoidStorageWithdrawFrame',
		'VoidStorageCostFrame',
		'VoidStorageStorageFrame',
		'VoidStoragePurchaseFrame',
		'VoidItemSearchBox',
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local VoidStorageFrame = _G.VoidStorageFrame
	for i = 1, 2 do
		local tab = VoidStorageFrame['Page'..i]
		local icon = tab:GetNormalTexture()
		local texture = icon:GetTexture()

		tab:StripTextures()
		tab:StyleButton()

		icon:SetInside(tab)
		icon:SetTexture(texture)
		S:HandleIcon(icon, true)

		tab.pushed:SetTexture(texture)
		S:HandleIcon(tab.pushed)
	end

	VoidStorageFrame:StripTextures()
	VoidStorageFrame:SetTemplate('Transparent')
	VoidStorageFrame.Page1:ClearAllPoints()
	VoidStorageFrame.Page1:Point('LEFT', '$parent', 'TOPRIGHT', E.PixelMode and -1 or 1, -60)

	_G.VoidStoragePurchaseFrame:SetFrameStrata('DIALOG')
	_G.VoidStoragePurchaseFrame:SetTemplate()

	S:HandleCloseButton(_G.VoidStorageBorderFrame.CloseButton)
	S:HandleButton(_G.VoidStoragePurchaseButton)
	S:HandleButton(_G.VoidStorageTransferButton)
	S:HandleEditBox(_G.VoidItemSearchBox)

	for StorageType, NumSlots in pairs({ Deposit = 9, Withdraw = 9, Storage = 80 }) do
		for i = 1, NumSlots do
			local Button = _G['VoidStorage'..StorageType..'Button'..i]
			Button:StripTextures()
			Button:SetTemplate()
			Button:StyleButton()
			S:HandleIcon(Button.icon)
			Button.icon:SetInside()
			S:HandleIconBorder(Button.IconBorder)
		end
	end
end

S:AddCallbackForAddon('Blizzard_VoidStorageUI')
