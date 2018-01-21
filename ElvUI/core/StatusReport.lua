local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

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
	StatusFrame.backdrop:SetBackdropColor(0, 0, 0, 0.6)
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
		local section = CreateFrame("Frame", nil, StatusFrame)
		section:Size(width, height)
		section:Point(anchor1, anchorTo, anchor2, 0, yOffset)

		section.Header = CreateFrame("Frame", nil, section)
		section.Header:Size(400, 30)
		section.Header:Point("TOP", section)

		section.Header.Text = section.Header:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
		section.Header.Text:Point("TOP")
		section.Header.Text:Point("BOTTOM")
		section.Header.Text:SetJustifyH("CENTER")
		section.Header.Text:SetJustifyV("MIDDLE")
		local font, height, flags = section.Header.Text:GetFont()
		section.Header.Text:SetFont(font, height*1.3, flags)

		section.Header.LeftDivider = section.Header:CreateTexture(nil, "ARTWORK")
		section.Header.LeftDivider:Height(8)
		section.Header.LeftDivider:Point("LEFT", section.Header, "LEFT", 5, 0)
		section.Header.LeftDivider:Point("RIGHT", section.Header.Text, "LEFT", -5, 0)
		section.Header.LeftDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		section.Header.LeftDivider:SetTexCoord(0.81, 0.94, 0.5, 1)

		section.Header.RightDivider = section.Header:CreateTexture(nil, "ARTWORK")
		section.Header.RightDivider:Height(8)
		section.Header.RightDivider:Point("RIGHT", section.Header, "RIGHT", -5, 0)
		section.Header.RightDivider:Point("LEFT", section.Header.Text, "RIGHT", 5, 0)
		section.Header.RightDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		section.Header.RightDivider:SetTexCoord(0.81, 0.94, 0.5, 1)

		return section
	end

	local function CreateContent(num, parent, anchorTo)
		local content = CreateFrame("Frame", nil, parent)
		content:Size(340, (num * 20))
		content:Point("TOP", anchorTo, "BOTTOM",0 , -5)
		for i = 1, num do
			local line = CreateFrame("Frame", nil, content)
			line:Size(340, 20)
			line.Text = line:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
			line.Text:SetAllPoints()
			line.Text:SetJustifyH("LEFT")
			line.Text:SetJustifyV("MIDDLE")
			line.Text:SetText("test")
			content["Line"..i] = line

			if i == 1 then
				content["Line"..i]:Point("TOP", content, "TOP")
			else
				content["Line"..i]:Point("TOP", content["Line"..(i-1)], "BOTTOM", 0, -5)
			end
		end

		return content
	end

	StatusFrame.Section1 = CreateSection(400, 150, "TOP", StatusFrame, "TOP", -30)
	StatusFrame.Section2 = CreateSection(400, 175, "TOP", StatusFrame.Section1, "BOTTOM", 0)
	StatusFrame.Section3 = CreateSection(400, 185, "TOP", StatusFrame.Section2, "BOTTOM", 0)
	StatusFrame.Section4 = CreateSection(400, 60, "TOP", StatusFrame.Section3, "BOTTOM", 0)

	--Section headers
	StatusFrame.Section1.Header.Text:SetText("|cfffe7b2cAddOn Info|r")
	StatusFrame.Section2.Header.Text:SetText("|cfffe7b2cWoW Info|r")
	StatusFrame.Section3.Header.Text:SetText("|cfffe7b2cCharacter Info|r")
	StatusFrame.Section4.Header.Text:SetText("|cfffe7b2cExport To|r")

	--Section contents
	StatusFrame.Section1.Content = CreateContent(4, StatusFrame.Section1, StatusFrame.Section1.Header)
	StatusFrame.Section2.Content = CreateContent(5, StatusFrame.Section2, StatusFrame.Section2.Header)
	StatusFrame.Section3.Content = CreateContent(6, StatusFrame.Section3, StatusFrame.Section3.Header)

	E.StatusFrame = StatusFrame
end

function E:ShowStatusReport()
	if not self.StatusFrame then
		self:CreateStatusFrame()
	end

	self.StatusFrame:Raise() --Set framelevel above everything else
	self.StatusFrame:SetShown(not self.StatusFrame:IsShown()) --Toggle displayed state
end