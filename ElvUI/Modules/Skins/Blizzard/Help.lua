local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select, unpack = select, unpack


function S:HelpFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.help) then return end

	local frame = _G.HelpFrame
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')
	S:HandleCloseButton(_G.HelpFrameCloseButton)

	local browser = _G.HelpBrowser
	browser.BrowserInset:StripTextures()
end

S:AddCallback('HelpFrame')
