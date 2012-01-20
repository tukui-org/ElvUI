local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.db.skins.blizzard.enable ~= true or E.db.skins.blizzard.reforge ~= true then return end
	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate("Transparent")
	ReforgingFrame:CreateShadow('Default')

	if not E:IsPTRVersion() then
		ReforgingFrameTopInset:StripTextures()
		ReforgingFrameInset:StripTextures()
		ReforgingFrameBottomInset:StripTextures()
		S:HandleDropDownBox(ReforgingFrameFilterOldStat, 180)
		S:HandleDropDownBox(ReforgingFrameFilterNewStat, 180)
	else
		ReforgingFrameButtonFrame:StripTextures()
		ReforgingFrameReforgeButton:ClearAllPoints()
		ReforgingFrameReforgeButton:Point("LEFT", ReforgingFrameRestoreButton, "RIGHT", 2, 0)
		ReforgingFrameReforgeButton:Point("BOTTOMRIGHT", -3, 3)
		ReforgingFrameRestoreMessage:SetTextColor(1, 1, 1);
	end

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