local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].glyph ~= true then return end

local function LoadSkin()
	--GLYPHS TAB
	GlyphFrameSparkleFrame:CreateBackdrop("Default")
	GlyphFrameSparkleFrame.backdrop:Point( "TOPLEFT", GlyphFrameSparkleFrame, "TOPLEFT", 3, -3 )
	GlyphFrameSparkleFrame.backdrop:Point( "BOTTOMRIGHT", GlyphFrameSparkleFrame, "BOTTOMRIGHT", -3, 3 )
	E.SkinEditBox(GlyphFrameSearchBox)
	E.SkinDropDownBox(GlyphFrameFilterDropDown, 212)
	
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
			icon:SetTexCoord(.08, .92, .08, .92)
			E.SkinButton(button)
		end
	end

	for i=1, 10 do
		Glyphs(nil, true, i)
	end

	GlyphFrameClearInfoFrameIcon:SetTexCoord(.08, .92, .08, .92)
	GlyphFrameClearInfoFrameIcon:ClearAllPoints()
	GlyphFrameClearInfoFrameIcon:Point("TOPLEFT", 2, -2)
	GlyphFrameClearInfoFrameIcon:Point("BOTTOMRIGHT", -2, 2)
	
	GlyphFrameClearInfoFrame:CreateBackdrop("Default", true)
	GlyphFrameClearInfoFrame.backdrop:SetAllPoints()
	GlyphFrameClearInfoFrame:StyleButton()
	GlyphFrameClearInfoFrame:Size(25, 25)
	
	E.SkinScrollBar(GlyphFrameScrollFrameScrollBar, 5)

	local StripAllTextures = {
		"GlyphFrameScrollFrame",
		"GlyphFrameSideInset",
		"GlyphFrameScrollFrameScrollChild",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end
end

E.SkinFuncs["Blizzard_GlyphUI"] = LoadSkin