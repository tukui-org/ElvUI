local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

local data = S:AddCallback('BattleNetFrames')
data.toggle = 'misc'

local function ShardTransferToggle(frame)
	_G.ShardTransferImminentMinimizeButton:SetNormalTexture(frame:IsShown() and E.Media.Textures.MinusButton or E.Media.Textures.PlusButton, true)
end

function S:BattleNetFrames()
	local skins = {
		_G.BNToastFrame,
		_G.TimeAlertFrame,
		_G.TicketStatusFrameButton.NineSlice -- Ticket Frames (not GMTicketFrames)
	}

	for i = 1, #skins do
		skins[i]:SetTemplate('Transparent')
	end

	local ShardFrame = _G.ShardTransferImminentFrame
	if ShardFrame then
		local MinimizeButton = _G.ShardTransferImminentMinimizeButton
		ShardFrame:SetTemplate('Transparent')
		MinimizeButton:SetTemplate('Transparent')

		ShardTransferToggle(ShardFrame)
		ShardFrame:HookScript('OnShow', ShardTransferToggle)
		ShardFrame:HookScript('OnHide', ShardTransferToggle)

		local minimizeTexture = MinimizeButton:GetNormalTexture()
		minimizeTexture:SetInside(nil, 5, 5)
	end

	local ReportFrame = _G.ReportFrame
	ReportFrame:StripTextures()
	ReportFrame:SetTemplate('Transparent')

	S:HandleCloseButton(ReportFrame.CloseButton)
	S:HandleDropDownBox(ReportFrame.ReportingMajorCategoryDropdown)
	S:HandleButton(ReportFrame.ReportButton)
	S:HandleEditBox(ReportFrame.Comment)

	if not E.Modern then
		local BattleTagInviteFrame = _G.BattleTagInviteFrame
		S:HandleFrame(BattleTagInviteFrame, true)

		for _, child in next, { BattleTagInviteFrame:GetChildren() } do
			if child:IsObjectType('Button') then
				S:HandleButton(child)
			end
		end
	end
end
