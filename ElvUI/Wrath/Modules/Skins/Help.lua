local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs

function S:HelpFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.help) then return end

	-- Frames
	_G.HelpFrame:StripTextures(true)
	_G.HelpFrame:CreateBackdrop('Transparent')
	_G.HelpFrameTitleBg:StripTextures(true)
	_G.HelpFrameTopBorder:StripTextures(true)

	-- Buttons
	_G.HelpFrameCloseButton:StripTextures()
	S:HandleCloseButton(_G.HelpFrameCloseButton)

	-- Insets
	local insets = {
		_G.HelpBrowser.BrowserInset,
		_G.HelpBrowserInsetTopBorder,
		_G.HelpBrowserInsetLeftBorder,
		_G.HelpBrowserInsetRightBorder,
		_G.HelpBrowserInsetBottomBorder
	}

	for _, inset in pairs(insets) do
		inset:StripTextures()
	end

	local ReportFrame = _G.ReportFrame
	S:HandleFrame(ReportFrame)
	S:HandleButton(ReportFrame.ReportButton)
	S:HandleDropDownBox(ReportFrame.ReportingMajorCategoryDropdown)
end

S:AddCallback('HelpFrame')
