local E, L, V, P, G, _ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "SpySkin"
local function SkinSpy(self)
	AS:SkinFrame(Spy_MainWindow)
	AS:SkinFrame(Spy_AlertWindow)
	S:HandleCloseButton(Spy_MainWindow.CloseButton)
	AS:Desaturate(Spy_MainWindow.ClearButton)
	AS:Desaturate(Spy_MainWindow.LeftButton)
	AS:Desaturate(Spy_MainWindow.RightButton)
	Spy_AlertWindow:Point("TOP", UIParent, "TOP", 0, -130)

	E:CreateMover(Spy_AlertWindow,"SpyAlertWindowMover","Spy Alert Window",nil,nil,nil,'ALL,GENERAL')
end

AS:RegisterSkin(name,SkinSpy)