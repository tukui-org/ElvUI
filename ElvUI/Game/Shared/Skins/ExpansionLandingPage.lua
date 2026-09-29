local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

-- the expansion overlay (MidnightLandingOverlayTemplate) is created on the first QUEST_LOG_UPDATE
local function RefreshExpansionOverlay(frame)
	local overlay = frame.overlayFrame
	if not overlay or overlay.IsSkinned then return end

	if E.private.skins.parchmentRemoverEnable then
		overlay:StripTextures()
		overlay:SetTemplate('Transparent')
	end

	S:HandleCloseButton(overlay.CloseButton)

	overlay.IsSkinned = true
end

function S:Blizzard_ExpansionLandingPage()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.expansionLanding) then return end

	local frame = _G.ExpansionLandingPage
	hooksecurefunc(frame, 'RefreshExpansionOverlay', RefreshExpansionOverlay)
	RefreshExpansionOverlay(frame)
end

S:AddCallbackForAddon('Blizzard_ExpansionLandingPage')
