
local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "BuyEmAllSkin"
local function SkinBuyEmAll(self)
	AS:SkinFrame(BuyEmAllFrame)
	S:HandleButton(BuyEmAllStackButton)
	S:HandleButton(BuyEmAllMaxButton)
	S:HandleButton(BuyEmAllCancelButton)
	S:HandleButton(BuyEmAllOkayButton)
end

AS:RegisterSkin(name,SkinBuyEmAll)