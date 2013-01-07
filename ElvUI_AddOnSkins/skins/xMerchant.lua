local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = 'xMerchantSkin'
local function SkinxMerchant(self)

	S:HandleCheckBox(NuuhMerchantFrameTooltipSearching)
	AS:SkinFrameD(NuuhMerchantFrameSearch)
	S:HandleScrollBar(NuuhMerchantScrollFrameScrollBar)

end

AS:RegisterSkin(name, SkinxMerchant)