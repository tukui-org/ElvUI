local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

S:AddCallbackForAddon('Blizzard_RaidFrame', nil, nil, nil, nil, nil, 'nonraid')

function S:Blizzard_RaidFrame()
	for _, frame in next, {
		_G.RaidInfoFrame,
		_G.RaidInfoInstanceLabel,
		_G.RaidInfoIDLabel,
	} do
		frame:StripTextures()
	end

	for _, button in next, {
		_G.RaidFrameConvertToRaidButton,
		_G.RaidFrameRaidInfoButton,
		not (E.TBC or E.Classic) and _G.RaidInfoExtendButton or nil,
		not (E.TBC or E.Classic) and _G.RaidInfoCancelButton or nil,
	} do
		S:HandleButton(button)
	end

	local RaidInfoFrame = _G.RaidInfoFrame
	RaidInfoFrame:SetTemplate('Transparent')

	if E.Modern then
		RaidInfoFrame.Header:StripTextures()
	end

	S:HandleCloseButton(_G.RaidInfoCloseButton, RaidInfoFrame)
	S:HandleTrimScrollBar(RaidInfoFrame.ScrollBar)
	S:HandleCheckBox(_G.RaidFrameAllAssistCheckButton)
end
