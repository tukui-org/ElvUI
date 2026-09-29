local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'TaxiFrame')
data.toggle = 'taxi'

local function ClearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 0)
end

function S:TaxiFrame()
	local TaxiFrame = _G.TaxiFrame

	-- Wrath, TBC and Vanilla load the older TaxiFrame without BasicFrameTemplateWithInset
	if E.Modern or E.Mists then
		TaxiFrame:StripTextures()
		TaxiFrame:SetTemplate('Transparent')

		local TaxiRouteMap = _G.TaxiRouteMap -- the map is drawn onto TaxiFrame.InsetBg, which sits below this frame
		TaxiRouteMap:SetTemplate()
		TaxiRouteMap:SetBackdropColor(0, 0, 0, 0)
		TaxiRouteMap.callbackBackdropColor = ClearBackdrop

		S:HandleCloseButton(TaxiFrame.CloseButton)
	else
		S:HandleFrame(TaxiFrame, true, nil, 11, -12, -32, 76)
		_G.TaxiPortrait:Kill() -- Blizz didnt name this TaxiFramePortrait
		_G.TaxiMap:PointXY(-11, -71)
		_G.TaxiRouteMap:PointXY(-11, -71)
		_G.TaxiMerchant:SetTextColor(1, 1, 1)

		S:HandleCloseButton(_G.TaxiCloseButton, TaxiFrame.backdrop)
	end
end
