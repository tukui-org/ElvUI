local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

if not C_Engraving.IsEngravingEnabled then
	return
end

function S:SkinEngravings()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.engraving) then return end

	local EngravingFrame = _G.EngravingFrame

	S:HandleFrame(EngravingFrame, true, nil, -7, 58, 8, -18)
	EngravingFrame.Border.NineSlice:Kill()
	EngravingFrameSideInset:Kill()

	S:HandleEditBox(EngravingFrameSearchBox)
	S:HandleDropDownBox(EngravingFrameFilterDropDown, 210)
	S:HandleScrollBar(EngravingFrameScrollFrameScrollBar)
end

S:AddCallbackForAddon('Blizzard_EngravingUI', 'SkinEngravings')
