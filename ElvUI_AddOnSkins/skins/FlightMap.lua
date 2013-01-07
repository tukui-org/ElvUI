local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local function SkinFM(self,event)
	AS:SkinStatusBar(FlightMapTimesFrame)
	FlightMapTimesText:ClearAllPoints()
	FlightMapTimesText:SetPoint("CENTER", FlightMapTimesFrame, "CENTER", 0, 0)
end

AS:RegisterSkin('FlightMapSkin',SkinFM)