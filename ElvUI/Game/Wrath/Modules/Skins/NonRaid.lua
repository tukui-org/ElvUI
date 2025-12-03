local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

function S:RaidInfoFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.nonraid) then return end

	for _, frame in next, {
		_G.RaidInfoFrame,
		_G.RaidInfoInstanceLabel,
		_G.RaidInfoIDLabel,
	} do
		frame:StripTextures()
	end

	for _, texture in next, {
		_G.RaidInfoScrollFrameBottom,
		_G.RaidInfoScrollFrameTop,
	} do
		texture:Kill()
	end

	for _, button in next, {
		_G.RaidFrameConvertToRaidButton,
		_G.RaidFrameRaidInfoButton,
		_G.RaidInfoExtendButton,
		_G.RaidInfoCancelButton,
	} do
		S:HandleButton(button)
	end

	local RaidInfoFrame = _G.RaidInfoFrame
	RaidInfoFrame:SetTemplate('Transparent')

	S:HandleCloseButton(_G.RaidInfoCloseButton,RaidInfoFrame)
	S:HandleScrollBar(_G.RaidInfoFrame.ScrollBar)
	S:HandleCheckBox(_G.RaidFrameAllAssistCheckButton)
end

S:AddCallback('RaidInfoFrame')
