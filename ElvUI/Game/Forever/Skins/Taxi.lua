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

	local RouteMap = _G.TaxiRouteMap -- the map itself is drawn onto TaxiFrame.InsetBg, which sits below this frame
	RouteMap:SetTemplate()
	RouteMap:SetBackdropColor(0, 0, 0, 0)
	RouteMap.callbackBackdropColor = ClearBackdrop

	S:HandleCloseButton(TaxiFrame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'TaxiFrame')
