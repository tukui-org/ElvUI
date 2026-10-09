local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

S:AddCallbackForAddon('Blizzard_SwingTimer', nil, nil, nil, nil, nil, 'swingTimer')

-- SwingTimerFrameTemplate
local function HandleSwingTimer(frame)
	frame:StripTextures()

	local bar = frame.StatusBar
	S:HandleStatusBar(bar)

	local classColor = E.myClassColor
	bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)

	bar.TypeLabel:FontTemplate()
	bar.TimeLabel:FontTemplate()
end

function S:Blizzard_SwingTimer()
	for _, frame in next, { _G.SwingTimerMainHandFrame, _G.SwingTimerOffHandFrame, _G.SwingTimerRangedFrame } do
		HandleSwingTimer(frame)
	end
end
