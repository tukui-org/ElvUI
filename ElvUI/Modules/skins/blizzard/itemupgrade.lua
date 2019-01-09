local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetItemUpgradeItemInfo = GetItemUpgradeItemInfo

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.itemUpgrade ~= true then return end

	local ItemUpgradeFrame = _G.ItemUpgradeFrame
	S:HandlePortraitFrame(ItemUpgradeFrame, true)
	S:HandleItemButton(ItemUpgradeFrame.ItemButton, true)

	hooksecurefunc('ItemUpgradeFrame_Update', function()
		if GetItemUpgradeItemInfo() then
			ItemUpgradeFrame.ItemButton.IconTexture:SetAlpha(1)
			ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord(unpack(E.TexCoords))
		else
			ItemUpgradeFrame.ItemButton.IconTexture:SetAlpha(0)
		end
	end)

	_G.ItemUpgradeFrameMoneyFrame:StripTextures()
	S:HandleButton(_G.ItemUpgradeFrameUpgradeButton, true)
	ItemUpgradeFrame.FinishedGlow:Kill()
	ItemUpgradeFrame.ButtonFrame:DisableDrawLayer('BORDER')
end

S:AddCallbackForAddon("Blizzard_ItemUpgradeUI", "ItemUpgrade", LoadSkin)
