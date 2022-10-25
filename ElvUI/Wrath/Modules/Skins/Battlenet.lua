local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

function S:BattleNetFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	local skins = {
		_G.BNToastFrame,
		_G.TimeAlertFrame,
		_G.TicketStatusFrameButton,
	}

	for i = 1, #skins do
		skins[i]:SetTemplate('Transparent')
	end

	local PlayerReportFrame = _G.PlayerReportFrame
	S:HandleFrame(PlayerReportFrame, true)

	PlayerReportFrame.Comment:StripTextures()
	S:HandleEditBox(PlayerReportFrame.Comment)

	S:HandleButton(PlayerReportFrame.ReportButton)
	S:HandleButton(PlayerReportFrame.CancelButton)

	S:HandleFrame(_G.ReportCheatingDialog, true)

	_G.ReportCheatingDialogCommentFrame:StripTextures()

	S:HandleButton(_G.ReportCheatingDialogReportButton)
	S:HandleButton(_G.ReportCheatingDialogCancelButton)

	S:HandleEditBox(_G.ReportCheatingDialogCommentFrameEditBox)

	local BattleTagInviteFrame = _G.BattleTagInviteFrame
	S:HandleFrame(BattleTagInviteFrame, true)

	for _, child in next, { BattleTagInviteFrame:GetChildren() } do
		if child:IsObjectType('Button') then
			S:HandleButton(child)
		end
	end
end

S:AddCallback('BattleNetFrames')
