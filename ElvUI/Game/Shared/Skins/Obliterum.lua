local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_ObliterumUI')
data.toggle = 'obliterum'

function S:Blizzard_ObliterumUI()
	local ObliterumForgeFrame = _G.ObliterumForgeFrame
	S:HandlePortraitFrame(ObliterumForgeFrame)
	ObliterumForgeFrame.ItemSlot:SetTemplate()
	ObliterumForgeFrame.ItemSlot.Icon:SetTexCoords()
	S:HandleButton(ObliterumForgeFrame.ObliterateButton)
end
