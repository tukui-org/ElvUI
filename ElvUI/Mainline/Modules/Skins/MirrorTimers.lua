local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:MirrorTimers()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.mirrorTimers) then return end

	--Mirror Timers (Underwater Breath etc.) -- To do, make it pretty WoW10
	for i = 1, _G.MIRRORTIMER_NUMTIMERS do
		local bar = _G['MirrorTimer'..i]
		local statusbar = bar.StatusBar or _G[bar:GetName()..'StatusBar']

		bar:SetTemplate()
		bar:SetSize(200, 15)

		bar.Text:FontTemplate()
		bar.Border:Hide()

		statusbar:SetStatusBarTexture(E.media.normTex)
		statusbar:SetAllPoints()

		E:CreateMover(bar, 'MirrorTimer'..i..'Mover', L["MirrorTimer"]..i, nil, nil, nil, 'ALL,SOLO')
	end
end

S:AddCallback('MirrorTimers')
