local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_HelpFrame', nil, nil, nil, nil, nil, 'help')

function S:Blizzard_HelpFrame()
	local main = _G.HelpFrame
	main:StripTextures()
	main:CreateBackdrop('Transparent')
	main.backdrop:SetOutside(main, 8, 8)
	S:HandleCloseButton(main.CloseButton, main.backdrop)

	if not E.Modern then
		_G.HelpFrameTitleBg:StripTextures()
	end

	local browser = _G.HelpBrowser
	browser.BrowserInset:StripTextures()
	browser:CreateBackdrop()
	browser.backdrop:ClearAllPoints()
	browser.backdrop:Point('TOPLEFT', browser, 'TOPLEFT', -1, 1)
	browser.backdrop:Point('BOTTOMRIGHT', browser, 'BOTTOMRIGHT', 1, -2)
end
