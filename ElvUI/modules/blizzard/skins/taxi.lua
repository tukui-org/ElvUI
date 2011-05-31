local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].taxi ~= true then return end

local function LoadSkin()
	TaxiFrame:StripTextures()
	TaxiFrame:CreateBackdrop("Transparent")
	TaxiRouteMap:CreateBackdrop("Default")
	TaxiRouteMap.backdrop:SetAllPoints()
	E.SkinCloseButton(TaxiFrameCloseButton)
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)