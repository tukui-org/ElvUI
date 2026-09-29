local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

if not E.ClassicSOD then return end

local _G = _G
local next = next

function S:Blizzard_EngravingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.engraving) then return end

	local frame = _G.EngravingFrame
	S:HandleFrame(frame, true, nil, -7, 58, 8, -18)
	frame.Border.NineSlice:Kill()
	_G.EngravingFrameSideInset:Kill()

	S:HandleEditBox(_G.EngravingFrameSearchBox)
	S:HandleDropDownBox(frame.FilterDropdown, 176)
	S:HandleScrollBar(_G.EngravingFrameScrollFrameScrollBar)

	for i = 1, 15 do -- rune headers
		local header = _G['EngravingFrameHeader'..i]
		header.middle:SetTexture() -- keep the plus / minus and category icons
		header.leftEdge:SetTexture()
		header.rightEdge:SetTexture()
		header:SetTemplate('Transparent')
	end

	for _, button in next, frame.scrollFrame.buttons do
		S:HandleIcon(button.icon, true)
		S:HandleButton(button)
	end
end

S:AddCallbackForAddon('Blizzard_EngravingUI')
