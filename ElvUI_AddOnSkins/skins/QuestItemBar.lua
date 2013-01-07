local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "QuestItemBarSkin"
local function SkinQuestItemBar(self)
	hooksecurefunc(QuestItemBar,"LibQuestItem_Update", function()
		for i = 1, 99 do
			if _G["QuestItemBarButton"..i] then AS:SkinIconButton(_G["QuestItemBarButton"..i], true, true, true) end
		end
		QuestItemBar:UpdateBar()
	end)
end
AS:RegisterSkin(name,SkinQuestItemBar)