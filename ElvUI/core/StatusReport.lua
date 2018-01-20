local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions

--WoW API / Variables


--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:


--[[
	Info we want to display here:

	AddOn Info
		ElvUI Version
		Are other addons enabled?
		Is Auto-Scale enabled?
		UI Scale
	WoW Info
		WoW Build
		Locale
		Display Mode
		Resolution
		Is Mac Client?
	Character Info
		Race
		Class
		Faction
		Level
		Specialization
		Zone
]]

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
	StatusFrame:CreateCloseButton()

	--Title logo (drag to move frame)
	StatusFrame.TitleLogoFrame = CreateFrame("Frame", nil, StatusFrame, "TitleDragAreaTemplate")
	StatusFrame.TitleLogoFrame:Size(128, 64)
	StatusFrame.TitleLogoFrame:Point("CENTER", StatusFrame, "TOP", 0, 0)
	StatusFrame.TitleLogoFrame.Texture = StatusFrame.TitleLogoFrame:CreateTexture(nil, "ARTWORK")
	StatusFrame.TitleLogoFrame.Texture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\logo.tga")
	StatusFrame.TitleLogoFrame.Texture:SetAllPoints()

	--Sections
	local function CreateSection(width, height, anchor1, anchorTo, anchor2, yOffset)
		local frame = CreateFrame("Frame", nil, StatusFrame)
		frame:Size(width, height)
		frame:Point(anchor1, anchorTo, anchor2, 0, yOffset)

		frame.Header = CreateFrame("Frame", nil, frame)
		frame.Header:Size(400, 30)
		frame.Header:Point("TOP", frame)

		frame.Header.Text = frame.Header:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
		frame.Header.Text:Point("TOP")
		frame.Header.Text:Point("BOTTOM")
		frame.Header.Text:SetJustifyH("CENTER")
		frame.Header.Text:SetJustifyV("MIDDLE")

		frame.Header.LeftDivider = frame.Header:CreateTexture(nil, "ARTWORK")
		frame.Header.LeftDivider:Height(8)
		frame.Header.LeftDivider:Point("LEFT", frame.Header, "LEFT", 5, 0)
		frame.Header.LeftDivider:Point("RIGHT", frame.Header.Text, "LEFT", -5, 0)
		frame.Header.LeftDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		frame.Header.LeftDivider:SetTexCoord(0.81, 0.94, 0.5, 1)

		frame.Header.RightDivider = frame.Header:CreateTexture(nil, "ARTWORK")
		frame.Header.RightDivider:Height(8)
		frame.Header.RightDivider:Point("RIGHT", frame.Header, "RIGHT", -5, 0)
		frame.Header.RightDivider:Point("LEFT", frame.Header.Text, "RIGHT", 5, 0)
		frame.Header.RightDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		frame.Header.RightDivider:SetTexCoord(0.81, 0.94, 0.5, 1)

		return frame
	end

	StatusFrame.Section1 = CreateSection(400, 150, "TOP", StatusFrame, "TOP", -30)
	StatusFrame.Section2 = CreateSection(400, 175, "TOP", StatusFrame.Section1, "BOTTOM", 0)
	StatusFrame.Section3 = CreateSection(400, 185, "TOP", StatusFrame.Section2, "BOTTOM", 0)
	StatusFrame.Section4 = CreateSection(400, 90, "TOP", StatusFrame.Section3, "BOTTOM", 0)
	--Section headers
	StatusFrame.Section1.Header.Text:SetText("AddOn Info")
	StatusFrame.Section2.Header.Text:SetText("WoW Info")
	StatusFrame.Section3.Header.Text:SetText("Character Info")
	StatusFrame.Section4.Header.Text:SetText("Export Info To")
	--Section contents

	E.StatusFrame = StatusFrame
end

function E:ShowStatusReport()
	if not self.StatusFrame then
		self:CreateStatusFrame()
	end

	self.StatusFrame:Raise() --Set framelevel above everything else
	self.StatusFrame:SetShown(not self.StatusFrame:IsShown()) --Toggle displayed state
end