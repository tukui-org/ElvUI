local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local function ClearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 0)
end

function S:TaxiFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.taxi) then return end

	local TaxiFrame = _G.TaxiFrame
	TaxiFrame:StripTextures()
	TaxiFrame:SetTemplate('Transparent')

	local TaxiRouteMap = _G.TaxiRouteMap -- the map is drawn onto TaxiFrame.InsetBg, which sits below this frame
	TaxiRouteMap:SetTemplate()
	TaxiRouteMap:SetBackdropColor(0, 0, 0, 0)
	TaxiRouteMap.callbackBackdropColor = ClearBackdrop

	S:HandleCloseButton(TaxiFrame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'TaxiFrame')
