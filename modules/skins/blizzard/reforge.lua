local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.global.skins.blizzard.enable ~= true or E.global.skins.blizzard.reforge ~= true then return end
	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate("Transparent")
	ReforgingFrame:CreateShadow('Default')
	
	ReforgingFrameButtonFrame:StripTextures()
	ReforgingFrameReforgeButton:ClearAllPoints()
	ReforgingFrameReforgeButton:Point("LEFT", ReforgingFrameRestoreButton, "RIGHT", 2, 0)
	ReforgingFrameReforgeButton:Point("BOTTOMRIGHT", -3, 3)
	ReforgingFrameRestoreMessage:SetTextColor(1, 1, 1);

	S:HandleButton(ReforgingFrameRestoreButton, true)
	S:HandleButton(ReforgingFrameReforgeButton, true)

	ReforgingFrameItemButton:StripTextures()
	ReforgingFrameItemButton:SetTemplate("Default", true)
	ReforgingFrameItemButton:StyleButton()
	ReforgingFrameItemButtonIconTexture:ClearAllPoints()
	ReforgingFrameItemButtonIconTexture:Point("TOPLEFT", 2, -2)
	ReforgingFrameItemButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)

	hooksecurefunc("ReforgingFrame_Update", function(self)
		local currentReforge, icon, name, quality, bound, cost = GetReforgeItemInfo()
		if icon then
			ReforgingFrameItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
		else
			ReforgingFrameItemButtonIconTexture:SetTexture(nil)
		end
	end)

	S:HandleCloseButton(ReforgingFrameCloseButton)
end

S:RegisterSkin("Blizzard_ReforgingUI", LoadSkin)