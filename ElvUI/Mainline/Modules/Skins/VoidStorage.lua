local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs

function S:Blizzard_VoidStorageUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.voidstorage) then return end

	local StripAllTextures = {
		_G.VoidStorageBorderFrame,
		_G.VoidStorageDepositFrame,
		_G.VoidStorageWithdrawFrame,
		_G.VoidStorageCostFrame,
		_G.VoidStorageStorageFrame,
		_G.VoidStoragePurchaseFrame,
	}

	for _, object in pairs(StripAllTextures) do
		object:StripTextures()
	end

	local VSFrame = _G.VoidStorageFrame
	VSFrame:StripTextures()
	VSFrame:SetTemplate('Transparent')

	_G.VoidStoragePurchaseFrame:SetFrameStrata('DIALOG')
	_G.VoidStoragePurchaseFrame:SetTemplate()

	S:HandleCloseButton(_G.VoidStorageBorderFrame.CloseButton)
	S:HandleButton(_G.VoidStoragePurchaseButton)
	S:HandleButton(_G.VoidStorageTransferButton)
	S:HandleEditBox(_G.VoidItemSearchBox)

	for storageType, numSlots in pairs({ Deposit = 9, Withdraw = 9, Storage = 80 }) do
		for i = 1, numSlots do
			local btn = _G['VoidStorage'..storageType..'Button'..i]
			btn:StripTextures()
			btn:SetTemplate()
			btn:StyleButton()

			btn.icon:SetInside()
			S:HandleIcon(btn.icon)
			S:HandleIconBorder(btn.IconBorder)
		end
	end

	-- Handle Frame Tabs
	local num = 1
	local tab = VSFrame['Page'..num]
	while tab do
		local icon = tab:GetNormalTexture()
		local texture = icon:GetTexture()

		if num == 1 then
			tab:ClearAllPoints()
			tab:Point('LEFT', '$parent', 'TOPRIGHT', E.PixelMode and -1 or 1, -60)
		end

		tab:StripTextures()
		tab:StyleButton()

		icon:SetInside(tab)
		icon:SetTexture(texture)
		S:HandleIcon(icon, true)

		tab.pushed:SetTexture(texture)
		S:HandleIcon(tab.pushed)

		num = num + 1
		tab = VSFrame['Page'..num]
	end
end

S:AddCallbackForAddon('Blizzard_VoidStorageUI')
