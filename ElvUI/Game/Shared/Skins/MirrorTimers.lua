local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

if E.Modern then
	S:AddCallbackForAddon('Blizzard_MirrorTimer', nil, nil, nil, nil, nil, 'mirrorTimers')
else
	S:AddCallbackForAddon('Blizzard_FrameXML', 'Blizzard_MirrorTimer', nil, nil, nil, nil, 'mirrorTimers')
end

local function MirrorTimer_OnValueChanged(statusBar, value)
	statusBar.TimerText:SetFormattedText('%d:%02d', value / 60, value % 60)
end

local function SetupTimer(container, timer)
	local bar = container:GetAvailableTimer(timer)
	if not bar then return end

	if not bar.atlasHolder then
		local atlasHolder = CreateFrame('Frame', nil, bar)
		atlasHolder:SetClipsChildren(true)
		atlasHolder:SetInside()
		bar.atlasHolder = atlasHolder

		local statusBar = bar.StatusBar
		statusBar:SetParent(bar.atlasHolder)
		statusBar:ClearAllPoints()
		statusBar:SetSize(204, 22)
		statusBar:Point('TOP', 0, 2)

		bar:SetSize(200, 18)

		local barText = bar.Text
		barText:FontTemplate()
		barText:ClearAllPoints()
		barText:SetParent(statusBar)
		barText:Point('CENTER', statusBar, 0, 1)

		local timerText = statusBar:CreateFontString(nil, 'OVERLAY')
		timerText:FontTemplate()
		timerText:Point('RIGHT', atlasHolder, -2, 0)
		statusBar.TimerText = timerText

		statusBar:HookScript('OnValueChanged', MirrorTimer_OnValueChanged)
		MirrorTimer_OnValueChanged(statusBar, statusBar:GetValue())
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
			local mirrorText = _G['MirrorTimer'..i..'Text']

			local mirrorTimer = _G['MirrorTimer'..i]
			mirrorTimer:StripTextures()
			mirrorTimer:Size(222, 18)
			mirrorTimer.label = mirrorText

			local statusBar = _G['MirrorTimer'..i..'StatusBar']
			statusBar:SetStatusBarTexture(E.media.normTex)
			statusBar:CreateBackdrop()
			statusBar:Size(222, 18)

			E:RegisterStatusBar(statusBar)

			mirrorText:Hide()

			local timerText = mirrorTimer:CreateFontString(nil, 'OVERLAY')
			timerText:FontTemplate(nil, nil, 'OUTLINE')
			timerText:Point('CENTER', statusBar)
			mirrorTimer.TimerText = timerText

			mirrorTimer.timeSinceUpdate = 0.3
			mirrorTimer:HookScript('OnUpdate', MirrorTimer_OnUpdate)
		end
	end
end
