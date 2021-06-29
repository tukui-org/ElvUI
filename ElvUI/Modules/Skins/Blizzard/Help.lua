local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:HelpFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.help) then return end

	local main = _G.HelpFrame
	main:StripTextures()
	main:CreateBackdrop('Transparent')
	main.backdrop:SetOutside(main, 8, 8)
	S:HandleCloseButton(_G.HelpFrameCloseButton, main.backdrop)

	local browser = _G.HelpBrowser
	browser.BrowserInset:StripTextures()
	browser:CreateBackdrop()
	browser.backdrop:ClearAllPoints()
	browser.backdrop:SetPoint('TOPLEFT', browser, 'TOPLEFT', -1, 1)
	browser.backdrop:SetPoint('BOTTOMRIGHT', browser, 'BOTTOMRIGHT', 1, -2)
end

S:AddCallback('HelpFrame')
