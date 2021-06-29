local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_QuestChoice()
	if E.private.skins.blizzard.questChoice ~= true then return end

	local QuestChoiceFrame = _G.QuestChoiceFrame
	for i = 1, 4 do
		local option = QuestChoiceFrame['Option'..i]
		local rewards = option.Rewards
		local item = rewards.Item
		local icon = item.Icon
		local currencies = rewards.Currencies

		item.IconBorder:Kill()
		S:HandleIcon(icon)
		icon:SetDrawLayer('ARTWORK')

		for j = 1, 3 do
			local cu = currencies['Currency'..j]
			S:HandleIcon(cu.Icon)
		end
	end

	QuestChoiceFrame:SetTemplate('Transparent')
	S:HandleButton(_G.QuestChoiceFrameOption1.OptionButtonsContainer.OptionButton1)
	S:HandleButton(_G.QuestChoiceFrameOption2.OptionButtonsContainer.OptionButton1)
	S:HandleButton(_G.QuestChoiceFrameOption3.OptionButtonsContainer.OptionButton1)
	S:HandleButton(_G.QuestChoiceFrameOption4.OptionButtonsContainer.OptionButton1)

	S:HandleCloseButton(QuestChoiceFrame.CloseButton)
	QuestChoiceFrame.CloseButton:SetFrameLevel(10)
end

S:AddCallbackForAddon('Blizzard_QuestChoice')
