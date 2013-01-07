local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "CoolLineSkin"
local function SkinCoolLine(self)
	CoolLineDB.bgcolor = { r = 0, g = 0, b = 0, a = 0, }
	CoolLineDB.border  = "None"
	CoolLine.updatelook()
	AS:SkinBackdropFrame(CoolLine)
	CoolLine.backdrop:SetAllPoints(CoolLine)
	CoolLine.backdrop:CreateShadow()
end

AS:RegisterSkin(name,SkinCoolLine)