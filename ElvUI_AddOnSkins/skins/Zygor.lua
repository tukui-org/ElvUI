local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "ZygorSkin"
local function SkinZygor(self)
	ZygorGuidesViewerFrame:StripTextures(True)
	ZygorGuidesViewerFrame_Border:StripTextures(True)
	ZygorGuidesViewer_CreatureViewer:SetTemplate("Transparent")

	for i = 1, 6 do
		_G["ZygorGuidesViewerFrame_Step"..i]:StripTextures(True)
		_G["ZygorGuidesViewerFrame_Step"..i]:CreateBackdrop()
	end

	if ZygorGuidesViewerFrame:IsShown() then ZygorGuidesViewerFrame_Border:SetTemplate("Transparent") end
	ZygorGuidesViewerFrame_Border:HookScript("OnHide", function(self) self:StripTextures(True) end)
	ZygorGuidesViewerFrame_Border:HookScript("OnShow", function(self) self:SetTemplate("Transparent") end)

end

AS:RegisterSkin(name,SkinZygor)