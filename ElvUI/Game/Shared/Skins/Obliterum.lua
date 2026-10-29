local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_ObliterumUI', nil, nil, nil, nil, nil, 'obliterum')

function S:Blizzard_ObliterumUI()
	local forgeFrame = _G.ObliterumForgeFrame
	S:HandlePortraitFrame(forgeFrame)
	S:HandleButton(forgeFrame.ObliterateButton)

	forgeFrame.ItemSlot:SetTemplate()
	forgeFrame.ItemSlot.Icon:SetTexCoords()
end
