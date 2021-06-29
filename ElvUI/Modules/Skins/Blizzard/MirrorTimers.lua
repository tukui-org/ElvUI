local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

local function MirrorTimer_OnUpdate(frame, elapsed)
	if frame.paused then return end
	if frame.timeSinceUpdate >= 0.3 then
		local minutes = frame.value/60
		local seconds = frame.value%60
		local text = frame.label:GetText()

		if frame.value > 0 then
			frame.TimerText:SetFormattedText('%s (%d:%02d)', text, minutes, seconds)
		else
			frame.TimerText:SetFormattedText('%s (0:00)', text)
		end

		frame.timeSinceUpdate = 0
	else
		frame.timeSinceUpdate = frame.timeSinceUpdate + elapsed
	end
end

function S:MirrorTimers()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.mirrorTimers) then return end

	--Mirror Timers (Underwater Breath etc.), credit to Azilroka
	for i = 1, _G.MIRRORTIMER_NUMTIMERS do
		local mirrorTimer = _G['MirrorTimer'..i]
		local statusBar = _G['MirrorTimer'..i..'StatusBar']
		local text = _G['MirrorTimer'..i..'Text']

		mirrorTimer:StripTextures()
		mirrorTimer:Size(222, 18)
		mirrorTimer.label = text
		statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(statusBar)
		statusBar:CreateBackdrop()
		statusBar:Size(222, 18)
		text:Hide()

		local TimerText = mirrorTimer:CreateFontString(nil, 'OVERLAY')
		TimerText:FontTemplate(nil, nil, 'OUTLINE')
		TimerText:Point('CENTER', statusBar, 'CENTER', 0, 0)
		mirrorTimer.TimerText = TimerText

		mirrorTimer.timeSinceUpdate = 0.3 --Make sure timer value updates right away on first show
		mirrorTimer:HookScript('OnUpdate', MirrorTimer_OnUpdate)

		E:CreateMover(mirrorTimer, 'MirrorTimer'..i..'Mover', L["MirrorTimer"]..i, nil, nil, nil, 'ALL,SOLO')
	end
end

S:AddCallback('MirrorTimers')
