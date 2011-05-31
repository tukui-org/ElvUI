local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].tabard ~= true then return end

local function LoadSkin()
	TabardFrame:StripTextures(true)
	TabardFrame:SetTemplate("Transparent")
	TabardModel:CreateBackdrop("Default")
	E.SkinButton(TabardFrameCancelButton)
	E.SkinButton(TabardFrameAcceptButton)
	E.SkinCloseButton(TabardFrameCloseButton)
	E.SkinRotateButton(TabardCharacterModelRotateLeftButton)
	E.SkinRotateButton(TabardCharacterModelRotateRightButton)
	TabardFrameCostFrame:StripTextures()
	TabardFrameCustomizationFrame:StripTextures()
	
	for i=1, 5 do
		local custom = "TabardFrameCustomization"..i
		_G[custom]:StripTextures()
		E.SkinNextPrevButton(_G[custom.."LeftButton"])
		E.SkinNextPrevButton(_G[custom.."RightButton"])
		
		
		if i > 1 then
			_G[custom]:ClearAllPoints()
			_G[custom]:Point("TOP", _G["TabardFrameCustomization"..i-1], "BOTTOM", 0, -6)
		else
			local point, anchor, point2, x, y = _G[custom]:GetPoint()
			_G[custom]:Point(point, anchor, point2, x, y+4)
		end
	end
	
	TabardCharacterModelRotateLeftButton:Point("BOTTOMLEFT", 4, 4)
	TabardCharacterModelRotateRightButton:Point("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 4, 0)
	TabardCharacterModelRotateLeftButton.SetPoint = E.dummy
	TabardCharacterModelRotateRightButton.SetPoint = E.dummy
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)