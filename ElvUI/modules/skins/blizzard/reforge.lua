local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.reforge ~= true then return end
	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate("Transparent")
	
	ReforgingFrame.ButtonFrame:StripTextures()
	ReforgingFrameReforgeButton:ClearAllPoints()
	ReforgingFrameReforgeButton:Point("LEFT", ReforgingFrameRestoreButton, "RIGHT", 2, 0)
	ReforgingFrameReforgeButton:Point("BOTTOMRIGHT", -3, 3)
	ReforgingFrame.RestoreMessage:SetTextColor(1, 1, 1);

	S:HandleButton(ReforgingFrameRestoreButton, true)
	S:HandleButton(ReforgingFrameReforgeButton, true)

	ReforgingFrame.ItemButton:StripTextures()
	ReforgingFrame.ItemButton:SetTemplate("Default", true)
	ReforgingFrame.ItemButton:StyleButton()
	ReforgingFrame.ItemButton.IconTexture:SetInside()

	hooksecurefunc("ReforgingFrame_Update", function(self)
		local currentReforge, icon, name, quality, bound, cost = GetReforgeItemInfo()
		if icon then
			ReforgingFrame.ItemButton.IconTexture:SetTexCoord(unpack(E.TexCoords))
		else
			ReforgingFrame.ItemButton.IconTexture:SetTexture(nil)
		end
	end)

	S:HandleCloseButton(ReforgingFrameCloseButton)
end

S:RegisterSkin("Blizzard_ReforgingUI", LoadSkin)