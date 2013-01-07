local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "MinimalArchaeologySkin"
local function SkinMinimalArchaeology(self)
	local font = [[Interface\AddOns\ElvUI\media\fonts\Homespun.ttf]] 
	local fontSize = 10
	AS:SkinFrame(MinArchMain)
	AS:SkinStatusBar(MinArchMainSkillBar)
	MinArchMainSkillBar:Point("TOP", MinArchMain, "TOP", 2, -24)
	MinArchMainSkillBar:Width(253)

	AS:Desaturate(MinArchMainButtonOpenADI)
	AS:Desaturate(MinArchMainButtonOpenHist)
	AS:Desaturate(MinArchMainButtonOpenArch)
	S:HandleCloseButton(MinArchMainButtonClose)
	MinArchMainButtonOpenADI:Point("TOPRIGHT", MinArchMain, "TOPRIGHT", -66, -1)
	MinArchMainButtonOpenHist:Point("TOPRIGHT", MinArchMain, "TOPRIGHT", -46, -1)
	MinArchMainButtonOpenArch:Point("TOPRIGHT", MinArchMain, "TOPRIGHT", -26, -1)
	MinArchMainButtonClose:Point("TOPRIGHT", MinArchMain, "TOPRIGHT", 2, 2)

	AS:SkinFrame(MinArchDigsites)
	S:HandleCloseButton(MinArchDigsitesButtonClose)

	AS:SkinFrame(MinArchHist)
	S:HandleCloseButton(MinArchHistButtonClose)

	for i = 1, 11 do
		AS:SkinStatusBar(_G["MinArchMainArtifactBar"..i])
		_G["MinArchMainArtifactBar"..i]:SetStatusBarColor(1.0, 0.4, 0)
		S:HandleButton(_G["MinArchMainArtifactBar"..i.."ButtonSolve"])
		_G["MinArchMainArtifactBar"..i.."ButtonSolve"].text = _G["MinArchMainArtifactBar"..i.."ButtonSolve"]:CreateFontString(nil, "OVERLAY")
		_G["MinArchMainArtifactBar"..i.."ButtonSolve"].text:SetFont(font, fontSize, "OUTLINE")
		_G["MinArchMainArtifactBar"..i.."ButtonSolve"].text:SetPoint("CENTER", 1, 1)
		_G["MinArchMainArtifactBar"..i.."ButtonSolve"].text:SetText("Solve")
		--Min Arch Options
		S:HandleCheckBox(_G["MinArchOptionPanelHideArtifact"..i])
		S:HandleCheckBox(_G["MinArchOptionPanelFragmentCap"..i])
		if _G["MinArchOptionPanelUseKeystones"..i] then S:HandleCheckBox(_G["MinArchOptionPanelUseKeystones"..i]) end
	end

	local checkbox = {
		MinArchOptionPanelMiscOptionsHideMinimap,
		MinArchOptionPanelMiscOptionsDisableSound,
		MinArchOptionPanelMiscOptionsStartHidden,
		MinArchOptionPanelMiscOptionsHideAfter,
		MinArchOptionPanelMiscOptionsWaitForSolve,
	}

	for _,boxes in pairs(checkbox) do
		S:HandleCheckBox(boxes)
	end

	--S:HandleSliderFrame(MinArchOptionPanelFrameScaleSlider)
	MinArchOptionPanelFrameScaleSliderLow:ClearAllPoints()
	MinArchOptionPanelFrameScaleSliderLow:SetPoint("BOTTOMLEFT", MinArchOptionPanelFrameScale, "BOTTOMLEFT", 3, 3)
	MinArchOptionPanelFrameScaleSliderHigh:ClearAllPoints()
	MinArchOptionPanelFrameScaleSliderHigh:SetPoint("BOTTOMRIGHT", MinArchOptionPanelFrameScale, "BOTTOMRIGHT", -3, 3)

	MinArchMainButtonOpenADI:SetTemplate("Default")
	MinArchMainButtonOpenADI:SetNormalTexture("")
	MinArchMainButtonOpenADI:SetPushedTexture("")
	MinArchMainButtonOpenADI:SetHighlightTexture("")
	MinArchMainButtonOpenADI:SetSize(14, 14)
	MinArchMainButtonOpenADI:ClearAllPoints()

	MinArchMainButtonOpenHist:SetTemplate("Default")
	MinArchMainButtonOpenHist:SetNormalTexture("")
	MinArchMainButtonOpenHist:SetPushedTexture("")
	MinArchMainButtonOpenHist:SetHighlightTexture("")
	MinArchMainButtonOpenHist:SetSize(14, 14)
	MinArchMainButtonOpenHist:ClearAllPoints()

	MinArchMainButtonOpenArch:SetTemplate("Default")
	MinArchMainButtonOpenArch:SetNormalTexture("")
	MinArchMainButtonOpenArch:SetPushedTexture("")
	MinArchMainButtonOpenArch:SetHighlightTexture("")
	MinArchMainButtonOpenArch:SetSize(14, 14)
	MinArchMainButtonOpenArch:ClearAllPoints()

	MinArchMainButtonOpenArch.text = MinArchMainButtonOpenArch:CreateFontString(nil, "OVERLAY")
	MinArchMainButtonOpenArch.text:SetFont(font, fontSize, "OUTLINE")
	MinArchMainButtonOpenArch.text:SetPoint("CENTER", 2, 1)
	MinArchMainButtonOpenArch.text:SetText("A")
	MinArchMainButtonOpenHist.text = MinArchMainButtonOpenHist:CreateFontString(nil, "OVERLAY")
	MinArchMainButtonOpenHist.text:SetFont(font, fontSize, "OUTLINE")
	MinArchMainButtonOpenHist.text:SetPoint("CENTER", 2, 1)
	MinArchMainButtonOpenHist.text:SetText("H")
	MinArchMainButtonOpenADI.text = MinArchMainButtonOpenADI:CreateFontString(nil, "OVERLAY")
	MinArchMainButtonOpenADI.text:SetFont(font, fontSize, "OUTLINE")
	MinArchMainButtonOpenADI.text:SetPoint("CENTER", 2, 1)
	MinArchMainButtonOpenADI.text:SetText("D")

	MinArchMainButtonOpenADI:Point("RIGHT", MinArchMainButtonOpenHist, "LEFT", -3, 0)
	MinArchMainButtonOpenHist:Point("RIGHT", MinArchMainButtonOpenArch, "LEFT", -3, 0)
	MinArchMainButtonOpenArch:Point("BOTTOMRIGHT", MinArchMain, "BOTTOMRIGHT", -6, 3)

end

AS:RegisterSkin(name,SkinMinimalArchaeology)