local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.glyph ~= true then return end
	--GLYPHS TAB
	GlyphFrameSparkleFrame:CreateBackdrop("Default")
	GlyphFrameSparkleFrame:SetFrameLevel(GlyphFrameSparkleFrame:GetFrameLevel() + 2)
	GlyphFrameSparkleFrame.backdrop:Point( "TOPLEFT", GlyphFrameSparkleFrame, "TOPLEFT", 3, -3 )
	GlyphFrameSparkleFrame.backdrop:Point( "BOTTOMRIGHT", GlyphFrameSparkleFrame, "BOTTOMRIGHT", -3, 3 )
	S:HandleEditBox(GlyphFrameSearchBox)
	S:HandleDropDownBox(GlyphFrameFilterDropDown, 212)
	
	GlyphFrameBackground:SetParent(GlyphFrameSparkleFrame)
	GlyphFrameBackground:SetPoint("TOPLEFT", 4, -4)
	GlyphFrameBackground:SetPoint("BOTTOMRIGHT", -4, 4)

	GlyphFrame.levelOverlay1:SetParent(GlyphFrameSparkleFrame)
	GlyphFrame.levelOverlayText1:SetParent(GlyphFrameSparkleFrame)
	GlyphFrame.levelOverlay2:SetParent(GlyphFrameSparkleFrame)
	GlyphFrame.levelOverlayText2:SetParent(GlyphFrameSparkleFrame)
	
	for i=1, 9 do
		_G["GlyphFrameGlyph"..i]:SetFrameLevel(_G["GlyphFrameGlyph"..i]:GetFrameLevel() + 5)
	end
	
	for i=1, 3 do
		_G["GlyphFrameHeader"..i]:StripTextures()
	end

	local function Glyphs(self, first, i)
		local button = _G["GlyphFrameScrollFrameButton"..i]
		local icon = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

		if first then
			button:StripTextures()
		end

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			S:HandleButton(button)
		end
	end

	for i=1, 10 do
		Glyphs(nil, true, i)
	end

	GlyphFrameClearInfoFrameIcon:SetTexCoord(unpack(E.TexCoords))
	GlyphFrameClearInfoFrameIcon:ClearAllPoints()
	GlyphFrameClearInfoFrameIcon:Point("TOPLEFT", 2, -2)
	GlyphFrameClearInfoFrameIcon:Point("BOTTOMRIGHT", -2, 2)
	
	GlyphFrameClearInfoFrame:CreateBackdrop("Default", true)
	GlyphFrameClearInfoFrame.backdrop:SetAllPoints()
	GlyphFrameClearInfoFrame:StyleButton()
	GlyphFrameClearInfoFrame:Size(25, 25)
	
	S:HandleScrollBar(GlyphFrameScrollFrameScrollBar, 5)

	local StripAllTextures = {
		"GlyphFrameScrollFrame",
		"GlyphFrameSideInset",
		"GlyphFrameScrollFrameScrollChild",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end
end

S:RegisterSkin("Blizzard_GlyphUI", LoadSkin)