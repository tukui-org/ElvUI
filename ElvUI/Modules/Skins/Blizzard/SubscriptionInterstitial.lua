local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

-- /run SubscriptionInterstitial_LoadUI(); _G.SubscriptionInterstitialFrame:Show()

function S:Blizzard_SubscriptionInterstitialUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.subscriptionInterstitial) then return end

	local SubscriptionInterstitial = _G.SubscriptionInterstitialFrame

	SubscriptionInterstitial:StripTextures()
	SubscriptionInterstitial:SetTemplate('Transparent')
	SubscriptionInterstitial.ShadowOverlay:Hide()

	S:HandleCloseButton(SubscriptionInterstitial.CloseButton)
	S:HandleButton(SubscriptionInterstitial.ClosePanelButton)
end

S:AddCallbackForAddon('Blizzard_SubscriptionInterstitialUI')
