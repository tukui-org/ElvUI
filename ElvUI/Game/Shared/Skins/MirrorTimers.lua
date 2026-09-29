local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

if E.Modern then
	local data = S:AddCallbackForAddon('Blizzard_MirrorTimer')
	data.toggle = 'mirrorTimers'
else
	local data = S:AddCallbackForAddon('Blizzard_FrameXML', 'Blizzard_MirrorTimer')
	data.toggle = 'mirrorTimers'
end

local function SetupTimer(container, timer)
	local bar = container:GetAvailableTimer(timer)
	if not bar then return end

	if not bar.atlasHolder then
		bar.atlasHolder = CreateFrame('Frame', nil, bar)
		bar.atlasHolder:SetClipsChildren(true)
		bar.atlasHolder:SetInside()

		bar.StatusBar:SetParent(bar.atlasHolder)
		bar.StatusBar:ClearAllPoints()
		bar.StatusBar:SetSize(204, 22)
		bar.StatusBar:Point('TOP', 0, 2)

		bar:SetSize(200, 18)

		bar.Text:FontTemplate()
		bar.Text:ClearAllPoints()
		bar.Text:SetParent(bar.StatusBar)
		bar.Text:Point('CENTER', bar.StatusBar, 0, 1)
	end

	bar:StripTextures()
	bar:SetTemplate('Transparent')
end

local function MirrorTimer_OnUpdate(frame, elapsed)
	if frame.paused then return end

	if frame.timeSinceUpdate >= 0.3 then
		local text = frame.label:GetText()

		if frame.value > 0 then
			frame.TimerText:SetFormattedText('%s (%d:%02d)', text, frame.value / 60, frame.value % 60)
		else
			frame.TimerText:SetFormattedText('%s (0:00)', text)
		end

		frame.timeSinceUpdate = 0
	else
		frame.timeSinceUpdate = frame.timeSinceUpdate + elapsed
	end
end

function S:Blizzard_MirrorTimer() -- Mirror Timers (Underwater Breath, etc.)
	if E.Modern then
		hooksecurefunc(_G.MirrorTimerContainer, 'SetupTimer', SetupTimer)
	else
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

			local timerText = mirrorTimer:CreateFontString(nil, 'OVERLAY')
			timerText:FontTemplate(nil, nil, 'OUTLINE')
			timerText:Point('CENTER', statusBar, 'CENTER', 0, 0)
			mirrorTimer.TimerText = timerText

			mirrorTimer.timeSinceUpdate = 0.3
			mirrorTimer:HookScript('OnUpdate', MirrorTimer_OnUpdate)
		end
	end
end
