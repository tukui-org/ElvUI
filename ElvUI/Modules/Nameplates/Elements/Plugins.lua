local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_QuestIcons(nameplate)
	local QuestIcons = CreateFrame('Frame', nil, nameplate)
	QuestIcons:Hide()
	QuestIcons:SetSize(self.db.questIconSize, self.db.questIconSize)
	QuestIcons:SetPoint("LEFT", nameplate, "RIGHT", 4, 0) -- need option

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

function NP:Update_QuestIcons(nameplate)
end

function NP:Construct_ClassificationIndicator(nameplate)
	local ClassificationIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	ClassificationIndicator:SetSize(16, 16)

	return ClassificationIndicator
end

function NP:Update_ClassificationIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.eliteIcon and db.eliteIcon.enable then
		nameplate:EnableElement('ClassificationIndicator')
		nameplate.ClassificationIndicator:ClearAllPoints()
		nameplate.ClassificationIndicator:SetSize(db.eliteIcon.size, db.eliteIcon.size)
		if db.healthbar.enable then
			nameplate.ClassificationIndicator:Point(db.eliteIcon.position, nameplate.HealthBar, db.eliteIcon.position, db.eliteIcon.xOffset, db.eliteIcon.yOffset)
		else
			nameplate.ClassificationIndicator:Point("RIGHT", nameplate.Name, "LEFT", 0, 0)
		end
	else
		nameplate:DisableElement('ClassificationIndicator')
	end
end

function NP:Construct_TargetIndicator(nameplate)
	local TargetIndicator = CreateFrame('Frame', nil, nameplate)

	TargetIndicator.Shadow = CreateFrame('Frame', nil, TargetIndicator)
	TargetIndicator.Shadow:SetBackdrop({edgeFile = E.LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(5)})
	TargetIndicator.Shadow:Hide()

	TargetIndicator.Spark = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.Spark:SetSnapToPixelGrid(false)
	TargetIndicator.Spark:SetTexelSnappingBias(0)
	TargetIndicator.Spark:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark]])
	TargetIndicator.Spark:Hide()

	TargetIndicator.TopIndicator = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.TopIndicator:SetSnapToPixelGrid(false)
	TargetIndicator.TopIndicator:SetTexelSnappingBias(0)
	TargetIndicator.TopIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator]])
	TargetIndicator.TopIndicator:Hide()

	TargetIndicator.LeftIndicator = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.LeftIndicator:SetSnapToPixelGrid(false)
	TargetIndicator.LeftIndicator:SetTexelSnappingBias(0)
	TargetIndicator.LeftIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft]])
	TargetIndicator.LeftIndicator:Hide()

	TargetIndicator.RightIndicator = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.RightIndicator:SetSnapToPixelGrid(false)
	TargetIndicator.RightIndicator:SetTexelSnappingBias(0)
	TargetIndicator.RightIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight]])
	TargetIndicator.RightIndicator:Hide()

	return TargetIndicator
end

function NP:Update_TargetIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	nameplate.TargetIndicator.style = NP['db'].targetGlow
	nameplate.TargetIndicator.lowHealthThreshold = NP['db'].lowHealthThreshold

	if NP['db'].targetGlow ~= 'none' then
		local GlowStyle = NP['db'].targetGlow
		local Color = NP['db'].colors.glow
		if nameplate.TargetIndicator.TopIndicator and (GlowStyle == "style3" or GlowStyle == "style5" or GlowStyle == "style6") then
			local topArrowSpace = -3
			if db.showName and (nameplate.Name:GetText() ~= nil and nameplate.Name:GetText() ~= "") then
				topArrowSpace = NP['db'].fontSize + topArrowSpace
			end
			nameplate.TargetIndicator.TopIndicator:Point("BOTTOM", nameplate.HealthBar, "TOP", 0, topArrowSpace)
			nameplate.TargetIndicator.TopIndicator:SetVertexColor(Color.r, Color.g, Color.b)
		end

		if (nameplate.TargetIndicator.LeftIndicator and nameplate.TargetIndicator.RightIndicator) and (GlowStyle == "style4" or GlowStyle == "style7" or GlowStyle == "style8") then
			nameplate.TargetIndicator.LeftIndicator:Point("LEFT", nameplate.HealthBar, "RIGHT", -3, 0)
			nameplate.TargetIndicator.RightIndicator:Point("RIGHT", nameplate.HealthBar, "LEFT", 3, 0)
			nameplate.TargetIndicator.LeftIndicator:SetVertexColor(Color.r, Color.g, Color.b)
			nameplate.TargetIndicator.RightIndicator:SetVertexColor(Color.r, Color.g, Color.b)
		end

		if nameplate.TargetIndicator.Shadow and (GlowStyle == "style1" or GlowStyle == "style5" or GlowStyle == "style7") then
			nameplate.TargetIndicator.Shadow:SetOutside(nameplate.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))
			nameplate.TargetIndicator.Shadow:SetBackdropBorderColor(Color.r, Color.g, Color.b)
		end

		if nameplate.TargetIndicator.Spark and (GlowStyle == "style2" or GlowStyle == "style6" or GlowStyle == "style8") then
			local scale = 1
			if NP['db'].useTargetScale then
				if NP['db'].targetScale >= 0.75 then
					scale = NP['db'].targetScale
				else
					scale = 0.75
				end
			end

			local size = (E.Border + 14) * scale;

			nameplate.TargetIndicator.Spark:Point("TOPLEFT", nameplate.HealthBar, "TOPLEFT", -(size * 2), size)
			nameplate.TargetIndicator.Spark:Point("BOTTOMRIGHT", nameplate.HealthBar, "BOTTOMRIGHT", size * 2, -size)
			nameplate.TargetIndicator.Spark:SetVertexColor(Color.r, Color.g, Color.b)
		end
	end
end

function NP:Construct_Highlight(nameplate)
	local Highlight = CreateFrame("Frame", nil, nameplate)
	Highlight.texture = Highlight:CreateTexture(nil, "ARTWORK", nil, 1)
	Highlight.texture:SetVertexColor(1, 1, 1, .3)
	Highlight.texture:SetTexture(E.LSM:Fetch("statusbar", self.db.statusbar))

	Highlight.PostUpdate = function(f)
		f.texture:ClearAllPoints()
		f.texture:SetPoint("TOPLEFT", nameplate.Health, "TOPLEFT")
		f.texture:SetPoint("BOTTOMRIGHT", nameplate.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
	end

	return Highlight
end

function NP:Update_Highlight(nameplate)
end
