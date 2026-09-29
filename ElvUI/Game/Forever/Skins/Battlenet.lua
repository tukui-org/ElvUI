local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local function ShardTransferToggle(frame)
	_G.ShardTransferImminentMinimizeButton:SetNormalTexture(frame:IsShown() and E.Media.Textures.MinusButton or E.Media.Textures.PlusButton, true)
end

function S:BattleNetFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	local skins = {
		_G.BNToastFrame,
		_G.TimeAlertFrame,
		_G.ShardTransferImminentFrame,
		_G.ShardTransferImminentMinimizeButton,
		_G.TicketStatusFrameButton.NineSlice -- Ticket Frames (not GMTicketFrames)
	}

	for i = 1, #skins do
		skins[i]:SetTemplate('Transparent')
	end

	local ShardFrame = _G.ShardTransferImminentFrame
	ShardTransferToggle(ShardFrame)
	ShardFrame:HookScript('OnShow', ShardTransferToggle)
	ShardFrame:HookScript('OnHide', ShardTransferToggle)
	_G.ShardTransferImminentMinimizeButton:GetNormalTexture():SetInside(nil, 5, 5)

	local ReportFrame = _G.ReportFrame
	ReportFrame:StripTextures()
	ReportFrame:SetTemplate('Transparent')

	S:HandleCloseButton(ReportFrame.CloseButton)
	S:HandleDropDownBox(ReportFrame.ReportingMajorCategoryDropdown)
	S:HandleButton(ReportFrame.ReportButton)
	S:HandleEditBox(ReportFrame.Comment)
end

S:AddCallback('BattleNetFrames')
