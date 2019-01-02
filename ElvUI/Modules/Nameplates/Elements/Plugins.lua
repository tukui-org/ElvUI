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

function NP:ConstructElement_TargetIndicator(frame)
	local TargetIndicator = {}

	TargetIndicator.Shadow = CreateFrame('Frame', nil, frame)
	TargetIndicator.Shadow:SetBackdrop({edgeFile = E.LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(5)})
	TargetIndicator.Shadow:Hide()

	TargetIndicator.Spark = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.Spark:SetSnapToPixelGrid(false)
	TargetIndicator.Spark:SetTexelSnappingBias(0)
	TargetIndicator.Spark:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark]])
	TargetIndicator.Spark:Hide()

	TargetIndicator.TopIndicator = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.TopIndicator:SetSnapToPixelGrid(false)
	TargetIndicator.TopIndicator:SetTexelSnappingBias(0)
	TargetIndicator.TopIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator]])
	TargetIndicator.TopIndicator:Hide()

	TargetIndicator.LeftIndicator = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.LeftIndicator:SetSnapToPixelGrid(false)
	TargetIndicator.LeftIndicator:SetTexelSnappingBias(0)
	TargetIndicator.LeftIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft]])
	TargetIndicator.LeftIndicator:Hide()

	TargetIndicator.RightIndicator = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.RightIndicator:SetSnapToPixelGrid(false)
	TargetIndicator.RightIndicator:SetTexelSnappingBias(0)
	TargetIndicator.RightIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight]])
	TargetIndicator.RightIndicator:Hide()

	return TargetIndicator
end

function NP:ConstructElement_Highlight(frame)
	local Highlight = CreateFrame("Frame", nil, frame)
	Highlight.texture = Highlight:CreateTexture("$parentHighlight", "ARTWORK", nil, 1)
	Highlight.texture:SetVertexColor(1, 1, 1, .5)
	Highlight.texture:SetTexture(E.LSM:Fetch("statusbar", self.db.statusbar))
	Highlight.texture:Hide()

	Highlight:HookScript("OnHide", function(f)
		f.texture:Hide()
	end)
	Highlight:HookScript("OnShow", function(f)
		f.texture:ClearAllPoints()
		f.texture:SetPoint("TOPLEFT", frame.Health, "TOPLEFT")
		f.texture:SetPoint("BOTTOMRIGHT", frame.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
		f.texture:Show()
	end)

	return Highlight
end