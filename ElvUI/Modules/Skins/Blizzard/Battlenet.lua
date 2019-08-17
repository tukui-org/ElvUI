local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local select = select

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end

	local skins = {
		_G.BNToastFrame,
		_G.TicketStatusFrameButton,
	}

	for i = 1, #skins do
		skins[i]:SetTemplate("Transparent")
	end

	local ReportFrame = _G.PlayerReportFrame
	ReportFrame:StripTextures()
	ReportFrame:CreateBackdrop("Transparent")
	ReportFrame.Comment:StripTextures()
	S:HandleEditBox(ReportFrame.Comment)
	S:HandleButton(ReportFrame.ReportButton)
	S:HandleButton(ReportFrame.CancelButton)

	local ReportCheatingDialog = _G.ReportCheatingDialog
	ReportCheatingDialog:StripTextures()
	_G.ReportCheatingDialogCommentFrame:StripTextures()
	S:HandleButton(_G.ReportCheatingDialogReportButton)
	S:HandleButton(_G.ReportCheatingDialogCancelButton)
	ReportCheatingDialog:CreateBackdrop("Transparent")
	S:HandleEditBox(_G.ReportCheatingDialogCommentFrameEditBox)

	local BattleTagInviteFrame = _G.BattleTagInviteFrame
	BattleTagInviteFrame:StripTextures()
	BattleTagInviteFrame:CreateBackdrop("Transparent")

	for i=1, BattleTagInviteFrame:GetNumChildren() do
		local child = select(i, BattleTagInviteFrame:GetChildren())
		if child:IsObjectType('Button') then
			S:HandleButton(child)
		end
	end
end

S:AddCallback("SkinBNet", LoadSkin)
