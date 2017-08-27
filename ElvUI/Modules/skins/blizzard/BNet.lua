local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: 

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end

	local skins = {
		"BNToastFrame",
		"TicketStatusFrameButton",
	}

	for i = 1, getn(skins) do
		_G[skins[i]]:SetTemplate("Transparent")
	end

	-- BNetReportFrame
	_G["BNetReportFrameCommentTopLeft"]:Hide()
	_G["BNetReportFrameCommentTopRight"]:Hide()
	_G["BNetReportFrameCommentTop"]:Hide()
	_G["BNetReportFrameCommentBottomLeft"]:Hide()
	_G["BNetReportFrameCommentBottomRight"]:Hide()
	_G["BNetReportFrameCommentBottom"]:Hide()
	_G["BNetReportFrameCommentLeft"]:Hide()
	_G["BNetReportFrameCommentRight"]:Hide()
	_G["BNetReportFrameCommentMiddle"]:Hide()
	S:HandleEditBox(_G["BNetReportFrameCommentScrollFrame"])

	_G["BNetReportFrameCommentScrollFrame"]:StripTextures()
	S:HandleScrollBar(_G["BNetReportFrameCommentScrollFrameScrollBar"])

	S:HandleButton(_G["BNetReportFrameReportButton"])
	S:HandleButton(_G["BNetReportFrameCancelButton"])

	ReportCheatingDialog:StripTextures()
	ReportCheatingDialogCommentFrame:StripTextures()
	S:HandleButton(ReportCheatingDialogReportButton)
	S:HandleButton(ReportCheatingDialogCancelButton)
	ReportCheatingDialog:SetTemplate("Transparent")
	S:HandleEditBox(ReportCheatingDialogCommentFrameEditBox)
	
	if not (E.wowbuild >= 24904) then
		ReportPlayerNameDialog:StripTextures()
		ReportPlayerNameDialogCommentFrame:StripTextures()
		S:HandleEditBox(ReportPlayerNameDialogCommentFrameEditBox)
		ReportPlayerNameDialog:SetTemplate("Transparent")
		S:HandleButton(ReportPlayerNameDialogReportButton)
		S:HandleButton(ReportPlayerNameDialogCancelButton)
	end
end

S:AddCallback("SkinBNet", LoadSkin)