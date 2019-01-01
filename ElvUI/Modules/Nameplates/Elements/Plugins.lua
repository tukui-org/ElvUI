local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_QuestIcons(frame)
	local QuestIcons = CreateFrame('Frame', nil, frame)
	QuestIcons:Hide()
	QuestIcons:SetSize(self.db.questIconSize, self.db.questIconSize)
	QuestIcons:SetPoint("LEFT", frame, "RIGHT", 4, 0) -- need option

	local Item = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
	Item:SetPoint('TOPLEFT')
	Item:SetSize(self.db.questIconSize, self.db.questIconSize)
	Item:SetTexCoord(unpack(E.TexCoords))
	Item:Hide()
	QuestIcons.Item = Item

	local Loot = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
	Loot:SetPoint('TOPLEFT')
	Loot:SetSize(self.db.questIconSize, self.db.questIconSize)
	Loot:Hide()
	QuestIcons.Loot = Loot

	local Skull = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
	Skull:SetPoint('TOPLEFT')
	Skull:SetSize(self.db.questIconSize + 4, self.db.questIconSize + 4)
	Skull:Hide()
	QuestIcons.Skull = Skull

	local Chat = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
	Chat:SetPoint('TOPLEFT')
	Chat:SetSize(self.db.questIconSize + 4, self.db.questIconSize + 4)
	Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	Chat:SetTexCoord(0, 0.5, 0.5, 1)
	Chat:Hide()
	QuestIcons.Chat = Chat

	local Text = QuestIcons:CreateFontString(nil, 'OVERLAY')
	Text:SetPoint('BOTTOMRIGHT', QuestIcons, 2, -0.8)
	Text:SetFont(E.LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	QuestIcons.Text = Text

	return QuestIcons
end

function NP:Construct_ClassificationIndicator(frame)
	local ClassificationIndicator = frame:CreateTexture(nil, 'OVERLAY')
	ClassificationIndicator:SetSize(16, 16)

	return ClassificationIndicator
end