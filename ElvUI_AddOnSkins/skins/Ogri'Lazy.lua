local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "OgriLazySkin"
local function SkinOgriLazy(self)
	AS:SkinFrame(Relic_View)
	S:HandleCloseButton(Relic_ViewCloseButton)
end

AS:RegisterSkin(name,SkinOgriLazy)
