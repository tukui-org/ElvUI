local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions

--WoW API / Variables


--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

function E:CreateStatusFrame()
	--Main frame
	local StatusFrame = CreateFrame("Frame", "ElvUIStatusReport", E.UIParent)
	StatusFrame:Size(400, 600)
	StatusFrame:Point("CENTER", 0, 200)
	StatusFrame:SetFrameStrata("HIGH")
	StatusFrame:CreateBackdrop("Transparent", nil, true)
	StatusFrame.backdrop:SetBackdropColor(0, 0, 0, 0.8)
	StatusFrame:SetShown(false)
	StatusFrame:SetMovable(true)

	--Title logo
	StatusFrame.TitleLogoFrame = CreateFrame("Frame", nil, StatusFrame, "TitleDragAreaTemplate")
	StatusFrame.TitleLogoFrame:Size(128, 64)
	StatusFrame.TitleLogoFrame:Point("CENTER", StatusFrame, "TOP", 0, 0)
	StatusFrame.TitleLogoFrame.Texture = StatusFrame.TitleLogoFrame:CreateTexture(nil, "OVERLAY")
	StatusFrame.TitleLogoFrame.Texture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\logo.tga")
	StatusFrame.TitleLogoFrame.Texture:SetAllPoints()

	StatusFrame:CreateCloseButton()

	E.StatusFrame = StatusFrame
end

function E:ShowStatusReport()
	if not self.StatusFrame then
		self:CreateStatusFrame()
	end

	self.StatusFrame:Raise() --Set framelevel above everything else
	self.StatusFrame:SetShown(not self.StatusFrame:IsShown()) --Toggle displayed state
end