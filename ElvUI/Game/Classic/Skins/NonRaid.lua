local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

function S:RaidInfoFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.nonraid) then return end

	for _, button in next, {
		_G.RaidFrameConvertToRaidButton,
		_G.RaidFrameRaidInfoButton,
	} do
		S:HandleButton(button)
	end

	local RaidInfoFrame = _G.RaidInfoFrame
	RaidInfoFrame:StripTextures()
	RaidInfoFrame:SetTemplate('Transparent')

	S:HandleCloseButton(_G.RaidInfoCloseButton, RaidInfoFrame)
	S:HandleTrimScrollBar(RaidInfoFrame.ScrollBar)
	S:HandleCheckBox(_G.RaidFrameAllAssistCheckButton)
end

S:AddCallback('RaidInfoFrame')
