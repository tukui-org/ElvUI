local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc

function B:KillBlizzard()
	if not E.Retail then
		_G.Advanced_UIScaleSlider:Kill()
		_G.Advanced_UseUIScale:Kill()
	end
end

local function AcknowledgeTips()
	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end

function B:DisableHelpTip() -- auto complete helptips
	if not E.global.general.disableTutorialButtons then return end

	hooksecurefunc(_G.HelpTip, 'Show', AcknowledgeTips)
	E:Delay(1, AcknowledgeTips)
end

-- NOTE: ActionBars heavily conflicts with NPE
local function ShutdownNPE(event)
	local NPE = _G.NewPlayerExperience
	if NPE then
		if NPE:GetIsActive() then
			NPE:Shutdown()
		end

		if event then
			B:UnregisterEvent(event)
		end
	end
end

function B:DisableNPE() -- disable new player experience
	if _G.NewPlayerExperience then
		ShutdownNPE()
	else
		B:RegisterEvent('ADDON_LOADED', ShutdownNPE)
	end
end
