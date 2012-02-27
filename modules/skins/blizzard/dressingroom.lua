local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.global.skins.blizzard.enable ~= true or E.global.skins.blizzard.dressingroom ~= true then return end
	DressUpFrame:StripTextures(true)
	DressUpFrame:CreateBackdrop("Transparent")
	DressUpFrame.backdrop:CreateShadow("Default")
	DressUpFrame.backdrop:Point("TOPLEFT", 6, 0)
	DressUpFrame.backdrop:Point("BOTTOMRIGHT", -32, 70)
	
	S:HandleButton(DressUpFrameResetButton)
	S:HandleButton(DressUpFrameCancelButton)
	S:HandleCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop)
	
	if not E:IsPTRVersion() then
		S:HandleRotateButton(DressUpModelRotateLeftButton)
		S:HandleRotateButton(DressUpModelRotateRightButton)
		DressUpModelRotateRightButton:Point("TOPLEFT", DressUpModelRotateLeftButton, "TOPRIGHT", 2, 0)
	end
	
	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -2, 0)
end

S:RegisterSkin('ElvUI', LoadSkin)