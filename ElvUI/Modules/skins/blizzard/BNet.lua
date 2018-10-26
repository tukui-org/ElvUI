local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select = select
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end

	local skins = {
		"BNToastFrame",
		"TicketStatusFrameButton",
	}

	for i = 1, #skins do
		_G[skins[i]]:SetTemplate("Transparent")
	end

	local ReportFrame = _G["PlayerReportFrame"]
	ReportFrame:StripTextures()
	ReportFrame:CreateBackdrop("Transparent")
	ReportFrame.Comment:StripTextures()
	S:HandleEditBox(ReportFrame.Comment)
	S:HandleButton(ReportFrame.ReportButton)
	S:HandleButton(ReportFrame.CancelButton)

	local ReportCheatingDialog = _G["ReportCheatingDialog"]
	ReportCheatingDialog:StripTextures()
	ReportCheatingDialogCommentFrame:StripTextures()
	S:HandleButton(ReportCheatingDialogReportButton)
	S:HandleButton(ReportCheatingDialogCancelButton)
	ReportCheatingDialog:CreateBackdrop("Transparent")
	S:HandleEditBox(ReportCheatingDialogCommentFrameEditBox)

	local BattleTagInviteFrame = _G["BattleTagInviteFrame"]
	BattleTagInviteFrame:StripTextures()
	BattleTagInviteFrame:CreateBackdrop("Transparent")

	for i=1, BattleTagInviteFrame:GetNumChildren() do
		local child = select(i, BattleTagInviteFrame:GetChildren())
		if child:GetObjectType() == 'Button' then
			S:HandleButton(child)
		end
	end
end

S:AddCallback("SkinBNet", LoadSkin)
