local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

if not E.ClassicSOD then return end

local _G = _G
local hooksecurefunc = hooksecurefunc
local C_Engraving_GetRuneCategories = C_Engraving.GetRuneCategories

local function UpdateRuneList()
	local categories = C_Engraving_GetRuneCategories(true, true)
	for i = 1, (categories and #categories or 0) do
		local header = _G['EngravingFrameHeader'..i]
		if header and not header.template then
			header:StripTextures()
			header:SetTemplate('Transparent')
		end
	end

	local frame = _G.EngravingFrame
	local buttons = frame and frame.scrollFrame and frame.scrollFrame.buttons
	for i = 1, (buttons and #buttons or 0) do
		local button = _G['EngravingFrameScrollFrameButton'..i]
		if button and not button.isSkinned then
			S:HandleButton(button)
			button.isSkinned = true
		end
	end
end

function S:SkinEngravings()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.engraving) then return end

	S:HandleFrame(_G.EngravingFrame, true, nil, -7, 58, 8, -18)
	_G.EngravingFrame.Border.NineSlice:Kill()
	_G.EngravingFrameSideInset:Kill()

	S:HandleEditBox(_G.EngravingFrameSearchBox)
	S:HandleDropDownBox(_G.EngravingFrameFilterDropDown, 210)
	S:HandleScrollBar(_G.EngravingFrameScrollFrameScrollBar)

	hooksecurefunc('EngravingFrame_UpdateRuneList', UpdateRuneList)
end

S:AddCallbackForAddon('Blizzard_EngravingUI', 'SkinEngravings')
