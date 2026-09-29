local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

-- /run SubscriptionInterstitial_LoadUI(); _G.SubscriptionInterstitialFrame:Show()

local data = S:AddCallbackForAddon('Blizzard_SubscriptionInterstitialUI')
data.toggle = 'subscriptionInterstitial'

function S:Blizzard_SubscriptionInterstitialUI()
	local SubscriptionInterstitial = _G.SubscriptionInterstitialFrame

	SubscriptionInterstitial:StripTextures()
	SubscriptionInterstitial:SetTemplate('Transparent')
	SubscriptionInterstitial.ShadowOverlay:Hide()

	S:HandleCloseButton(SubscriptionInterstitial.CloseButton)
	S:HandleButton(SubscriptionInterstitial.ClosePanelButton)
end
