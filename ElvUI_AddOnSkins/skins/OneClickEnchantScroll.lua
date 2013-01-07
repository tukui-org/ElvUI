local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = 'OneClickEnchantScrollSkin'
local function SkinOneClickEnchantScroll(self)

	S:HandleButton(TradeSkillCreateScrollButton, true)
	TradeSkillCreateScrollButton:ClearAllPoints()
	TradeSkillCreateScrollButton:Point("RIGHT", TradeSkillCreateButton, "LEFT", -2, 0)

end

AS:RegisterSkin(name, SkinOneClickEnchantScroll)