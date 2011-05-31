local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].dressingroom ~= true then return end

local function LoadSkin()
	DressUpFrame:StripTextures(true)
	DressUpFrame:CreateBackdrop("Transparent")
	DressUpFrame.backdrop:CreateShadow("Default")
	DressUpFrame.backdrop:Point("TOPLEFT", 6, 0)
	DressUpFrame.backdrop:Point("BOTTOMRIGHT", -32, 70)
	
	E.SkinButton(DressUpFrameResetButton)
	E.SkinButton(DressUpFrameCancelButton)
	E.SkinCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop)
	E.SkinRotateButton(DressUpModelRotateLeftButton)
	E.SkinRotateButton(DressUpModelRotateRightButton)
	DressUpModelRotateRightButton:Point("TOPLEFT", DressUpModelRotateLeftButton, "TOPRIGHT", 2, 0)
	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -2, 0)
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)