local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

-- /run SubscriptionInterstitial_LoadUI(); _G.SubscriptionInterstitialFrame:Show()

S:AddCallbackForAddon('Blizzard_SubscriptionInterstitialUI', nil, nil, nil, nil, nil, 'subscriptionInterstitial')

function S:Blizzard_SubscriptionInterstitialUI()
	local SubscriptionInterstitial = _G.SubscriptionInterstitialFrame

	SubscriptionInterstitial:StripTextures()
	SubscriptionInterstitial:SetTemplate('Transparent')
	SubscriptionInterstitial.ShadowOverlay:Hide()

	S:HandleCloseButton(SubscriptionInterstitial.CloseButton)
	S:HandleButton(SubscriptionInterstitial.ClosePanelButton)
end
