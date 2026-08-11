local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:BattleNetFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	local skins = {
		_G.BNToastFrame,
		_G.TimeAlertFrame,
		_G.TicketStatusFrameButton.NineSlice -- Ticket Frames (not GMTicketFrames)
	}

	for i = 1, #skins do
		skins[i]:SetTemplate('Transparent')
	end

	local ReportFrame = _G.ReportFrame
	if ReportFrame then
		ReportFrame:StripTextures()
		ReportFrame:SetTemplate('Transparent')

		S:HandleCloseButton(ReportFrame.CloseButton)
		S:HandleDropDownBox(ReportFrame.ReportingMajorCategoryDropdown)
		S:HandleButton(ReportFrame.ReportButton)
		S:HandleEditBox(ReportFrame.Comment)
	end

	local ReportCheatingDialog = _G.ReportCheatingDialog
	if ReportCheatingDialog then
		ReportCheatingDialog:StripTextures()
		ReportCheatingDialog:SetTemplate('Transparent')
	end

	_G.ReportCheatingDialogCommentFrame:StripTextures()
	S:HandleButton(_G.ReportCheatingDialogReportButton)
	S:HandleButton(_G.ReportCheatingDialogCancelButton)
	S:HandleEditBox(_G.ReportCheatingDialogCommentFrameEditBox)
end

S:AddCallback('BattleNetFrames')
