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
	ReportFrame:StripTextures()
	ReportFrame:SetTemplate('Transparent')

	S:HandleCloseButton(ReportFrame.CloseButton)
	S:HandleDropDownBox(ReportFrame.ReportingMajorCategoryDropdown)
	S:HandleButton(ReportFrame.ReportButton)
	S:HandleEditBox(ReportFrame.Comment)
end

S:AddCallback('BattleNetFrames')
