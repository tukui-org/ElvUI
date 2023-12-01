local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

if not C_Engraving.IsEngravingEnabled then
	return
end

local C_Engraving_GetRuneCategories = C_Engraving.GetRuneCategories

function S:SkinEngravings()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.engraving) then return end

	local EngravingFrame = _G.EngravingFrame

	S:HandleFrame(EngravingFrame, true, nil, -7, 58, 8, -18)
	EngravingFrame.Border.NineSlice:Kill()
	EngravingFrameSideInset:Kill()

	S:HandleEditBox(EngravingFrameSearchBox)
	S:HandleDropDownBox(EngravingFrameFilterDropDown, 210)
	S:HandleScrollBar(EngravingFrameScrollFrameScrollBar)

	hooksecurefunc('EngravingFrame_UpdateRuneList', function()
		local categories = C_Engraving_GetRuneCategories(true, true)
		numHeaders = #categories
		for i = 1, numHeaders do
			if not _G['EngravingFrameHeader'..i].isSkinned then
				_G['EngravingFrameHeader'..i]:StripTextures()
				_G['EngravingFrameHeader'..i]:SetTemplate('Transparent')
				_G['EngravingFrameHeader'..i].isSkinned = true
			end
		end
		for i = 1, 13 do
			if not _G['EngravingFrameScrollFrameButton'..i].isSkinned then
				S:HandleButton(_G['EngravingFrameScrollFrameButton'..i])
				_G['EngravingFrameScrollFrameButton'..i].isSkinned = true
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_EngravingUI', 'SkinEngravings')
