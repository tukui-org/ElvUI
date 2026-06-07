local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local reaction = {}
reaction["EXHAUSTION"] = {
	r = 1.00, g = 0.90, b = 0.00
}
reaction["BREATH"] = {
	r = 0.00, g = 0.50, b = 1.00
}
reaction["DEATH"] = {
	r = 1.00, g = 0.70, b = 0.00
}
reaction["FEIGNDEATH"] = {
	r = 1.00, g = 0.70, b = 0.00
}

local function SetupTimer(container, timer)
	local bar = container:GetAvailableTimer(timer)
	if not bar then return end

	bar:StripTextures()
	bar:Size(222, 18)

	local color = reaction[timer]
	bar.StatusBar:SetStatusBarTexture(E.media.normTex)
	bar.StatusBar:SetStatusBarColor(color.r, color.g, color.b)
	E:RegisterStatusBar(bar.StatusBar)
	bar.StatusBar:CreateBackdrop()
	bar.StatusBar:Size(222, 18)

	bar.Text:FontTemplate()
	bar.Text:ClearAllPoints()
	bar.Text:SetParent(bar.StatusBar)
	bar.Text:Point('CENTER', bar.StatusBar, 'CENTER')
end

function S:MirrorTimers() -- Mirror Timers (Underwater Breath, etc.)
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.mirrorTimers) then return end

	hooksecurefunc(_G.MirrorTimerContainer, 'SetupTimer', SetupTimer)
end

S:AddCallback('MirrorTimers')
