local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

-- SwingTimerFrameTemplate
local function HandleSwingTimer(frame)
	frame:StripTextures()

	local bar = frame.StatusBar
	if bar then
		S:HandleStatusBar(bar)

		if bar.TypeLabel then
			bar.TypeLabel:FontTemplate()
		end

		if bar.TimeLabel then
			bar.TimeLabel:FontTemplate()
		end
	end
end

function S:Blizzard_SwingTimer()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.swingTimer) then return end

	for _, frame in next, { _G.SwingTimerMainHandFrame, _G.SwingTimerOffHandFrame, _G.SwingTimerRangedFrame } do
		HandleSwingTimer(frame)
	end
end

S:AddCallbackForAddon('Blizzard_SwingTimer')
