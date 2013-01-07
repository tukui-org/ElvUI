local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "WoWProSkin"

local function SkinWoWPro(self)
	AS:SkinFrame(Titlebar)
	AS:SkinBackdropFrame(WoWPro.MainFrame)
	_G["Mouseover Note Tooltip"]:HookScript("OnShow", function(self) self:SetTemplate() end)
end

AS:RegisterSkin(name,SkinWoWPro)