local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if(not E.private.skins.blizzard.questChoice) then return end
	for i = 1, 2 do
		local option = QuestChoiceFrame["Option"..i]
		local rewards = option.Rewards
		local icon = rewards.Item.Icon
		local currencies = rewards.Currencies

		S:HandleIcon(icon)

		for j = 1, 3 do
			local cu = currencies["Currency"..j]
			S:HandleIcon(cu.Icon)
		end
	end

	QuestChoiceFrame:CreateBackdrop("Transparent")
	S:HandleButton(QuestChoiceFrame.Option1.OptionButton)
	S:HandleButton(QuestChoiceFrame.Option2.OptionButton)
	S:HandleCloseButton(QuestChoiceFrame.CloseButton)
	QuestChoiceFrame.CloseButton:SetFrameLevel(10)
end

S:RegisterSkin("Blizzard_QuestChoice", LoadSkin)
