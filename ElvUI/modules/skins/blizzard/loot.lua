local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:GetModule('Skins')

local function LoadSkin()
	local frame = MissingLootFrame

	frame:StripTextures()
	frame:CreateBackdrop("Default")
	frame:CreateShadow()

	S:HandleCloseButton(MissingLootFramePassButton)

	local function SkinButton()
		local number = GetNumMissingLootItems()
		for i = 1, number do
			local slot = _G["MissingLootFrameItem"..i]
			local icon = slot.icon

			S:HandleItemButton(slot)

			local quality = select(4, GetMissingLootItemInfo(i))
			local color = (GetItemQualityColor(quality)) or (unpack(E.media.bordercolor))
			frame:SetBackdropBorderColor(color)
		end
	end
	hooksecurefunc("MissingLootFrame_Show", SkinButton)
end

S:RegisterSkin("ElvUI", LoadSkin)