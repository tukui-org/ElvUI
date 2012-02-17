local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.db.skins.blizzard.enable ~= true or E.db.skins.blizzard.tabard ~= true then return end
	TabardFrame:StripTextures(true)
	TabardFrame:SetTemplate("Transparent")
	TabardModel:CreateBackdrop("Default")
	S:HandleButton(TabardFrameCancelButton)
	S:HandleButton(TabardFrameAcceptButton)
	S:HandleCloseButton(TabardFrameCloseButton)
	S:HandleRotateButton(TabardCharacterModelRotateLeftButton)
	S:HandleRotateButton(TabardCharacterModelRotateRightButton)
	TabardFrameCostFrame:StripTextures()
	TabardFrameCustomizationFrame:StripTextures()
	
	for i=1, 5 do
		local custom = "TabardFrameCustomization"..i
		_G[custom]:StripTextures()
		S:HandleNextPrevButton(_G[custom.."LeftButton"])
		S:HandleNextPrevButton(_G[custom.."RightButton"])
		
		
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
	TabardCharacterModelRotateLeftButton.SetPoint = E.noop
	TabardCharacterModelRotateRightButton.SetPoint = E.noop
end

S:RegisterSkin('ElvUI', LoadSkin)