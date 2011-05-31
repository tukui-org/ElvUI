local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].reforge ~= true then return end

local function LoadSkin()
	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate("Transparent")
	
	ReforgingFrameTopInset:StripTextures()
	ReforgingFrameInset:StripTextures()
	ReforgingFrameBottomInset:StripTextures()
	
	E.SkinButton(ReforgingFrameRestoreButton, true)
	E.SkinButton(ReforgingFrameReforgeButton, true)
	
	E.SkinDropDownBox(ReforgingFrameFilterOldStat, 180)
	E.SkinDropDownBox(ReforgingFrameFilterNewStat, 180)
	
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