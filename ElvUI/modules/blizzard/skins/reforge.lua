local E, C, L = unpack(select(2, ...))

local function LoadSkin()
	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate("Transparent")
	ReforgingFrame:CreateShadow('Default')

	if not E.IsPTRVersion() then
		ReforgingFrameTopInset:StripTextures()
		ReforgingFrameInset:StripTextures()
		ReforgingFrameBottomInset:StripTextures()
		E.SkinDropDownBox(ReforgingFrameFilterOldStat, 180)
		E.SkinDropDownBox(ReforgingFrameFilterNewStat, 180)
	else
		ReforgingFrameButtonFrame:StripTextures()
		ReforgingFrameReforgeButton:ClearAllPoints()
		ReforgingFrameReforgeButton:Point("LEFT", ReforgingFrameRestoreButton, "RIGHT", 2, 0)
		ReforgingFrameReforgeButton:Point("BOTTOMRIGHT", -3, 3)
		ReforgingFrameRestoreMessage:SetTextColor(1, 1, 1);
	end

	E.SkinButton(ReforgingFrameRestoreButton, true)
	E.SkinButton(ReforgingFrameReforgeButton, true)

	ReforgingFrameItemButton:StripTextures()
	ReforgingFrameItemButton:SetTemplate("Default", true)
	ReforgingFrameItemButton:StyleButton()
	ReforgingFrameItemButtonIconTexture:ClearAllPoints()
	ReforgingFrameItemButtonIconTexture:Point("TOPLEFT", 2, -2)
	ReforgingFrameItemButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)

	hooksecurefunc("ReforgingFrame_Update", function(self)
		local currentReforge, icon, name, quality, bound, cost = GetReforgeItemInfo()
		if icon then
			ReforgingFrameItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
		else
			ReforgingFrameItemButtonIconTexture:SetTexture(nil)
		end
	end)

	E.SkinCloseButton(ReforgingFrameCloseButton)
end

E.SkinFuncs["Blizzard_ReforgingUI"] = LoadSkin