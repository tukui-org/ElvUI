local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local pairs = pairs
local unpack = unpack
local CreateFrame = CreateFrame

function NP:Construct_QuestIcons(nameplate)
	local QuestIcons = CreateFrame('Frame', nameplate:GetDebugName()..'QuestIcons', nameplate)
	QuestIcons:Hide()
	QuestIcons:Size(NP.db.questIconSize + 4, NP.db.questIconSize + 4)

	for _, object in pairs({'Item', 'Loot', 'Skull', 'Chat'}) do
		QuestIcons[object] = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
		QuestIcons[object]:Point('CENTER')
		QuestIcons[object]:Size(NP.db.questIconSize, NP.db.questIconSize)
		QuestIcons[object]:Hide()
	end

	QuestIcons.Item:SetTexCoord(unpack(E.TexCoords))

	QuestIcons.Skull:Size(NP.db.questIconSize + 4, NP.db.questIconSize + 4)

	QuestIcons.Chat:Size(NP.db.questIconSize + 4, NP.db.questIconSize + 4)
	QuestIcons.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	QuestIcons.Chat:SetTexCoord(0, 0.5, 0.5, 1)

	QuestIcons.Text = QuestIcons:CreateFontString(nil, 'OVERLAY')
	QuestIcons.Text:Point('BOTTOMRIGHT', QuestIcons, 'BOTTOMRIGHT', 2, -0.8)
	QuestIcons.Text:SetFont(E.Libs.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	return QuestIcons
end

function NP:Update_QuestIcons(nameplate)
	if NP.db.questIcon and (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') then
		if not nameplate:IsElementEnabled('QuestIcons') then
			nameplate:EnableElement('QuestIcons')
		end
		nameplate.QuestIcons:ClearAllPoints()
		nameplate.QuestIcons:Point('LEFT', nameplate, 'RIGHT', 4, 0)
		nameplate.QuestIcons:Size(NP.db.questIconSize + 4, NP.db.questIconSize + 4)
		nameplate.QuestIcons.Item:Size(NP.db.questIconSize, NP.db.questIconSize)
		nameplate.QuestIcons.Loot:Size(NP.db.questIconSize, NP.db.questIconSize)
		nameplate.QuestIcons.Skull:Size(NP.db.questIconSize + 4, NP.db.questIconSize + 4)
		nameplate.QuestIcons.Chat:Size(NP.db.questIconSize + 4, NP.db.questIconSize + 4)
	else
		if nameplate:IsElementEnabled('QuestIcons') then
			nameplate:DisableElement('QuestIcons')
		end
	end
end

function NP:Construct_ClassificationIndicator(nameplate)
	local ClassificationIndicator = nameplate:CreateTexture(nil, 'OVERLAY')

	return ClassificationIndicator
end

function NP:Update_ClassificationIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') and db.eliteIcon.enable then
		if not nameplate:IsElementEnabled('ClassificationIndicator') then
			nameplate:EnableElement('ClassificationIndicator')
		end

		nameplate.ClassificationIndicator:ClearAllPoints()
		nameplate.ClassificationIndicator:Size(db.eliteIcon.size, db.eliteIcon.size)

		if db.health.enable then
			nameplate.ClassificationIndicator:Point(db.eliteIcon.position, nameplate.Health, db.eliteIcon.position, db.eliteIcon.xOffset, db.eliteIcon.yOffset)
		else
			nameplate.ClassificationIndicator:Point('RIGHT', nameplate.Name, 'LEFT', 0, 0)
		end
	else
		if nameplate:IsElementEnabled('ClassificationIndicator') then
			nameplate:DisableElement('ClassificationIndicator')
		end
	end
end

function NP:Construct_TargetIndicator(nameplate)
	local TargetIndicator = CreateFrame('Frame', nameplate:GetDebugName()..'TargetIndicator', nameplate)
	TargetIndicator:SetFrameLevel(0)

	TargetIndicator.Shadow = CreateFrame('Frame', nil, TargetIndicator)
	TargetIndicator.Shadow:SetBackdrop({edgeFile = E.LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(5)})
	TargetIndicator.Shadow:Hide()

	for _, object in pairs({'Spark', 'TopIndicator', 'LeftIndicator', 'RightIndicator'}) do
		TargetIndicator[object] = TargetIndicator:CreateTexture(nil, 'BACKGROUND', nil, -5)
		TargetIndicator[object]:SetSnapToPixelGrid(false)
		TargetIndicator[object]:SetTexelSnappingBias(0)
		TargetIndicator[object]:Hide()
	end

	TargetIndicator.Spark:SetTexture(E.Media.Textures.Spark)
	TargetIndicator.TopIndicator:SetTexture(E.Media.Textures.NameplateTargetIndicator)
	TargetIndicator.LeftIndicator:SetTexture(E.Media.Textures.NameplateTargetIndicatorLeft)
	TargetIndicator.RightIndicator:SetTexture(E.Media.Textures.NameplateTargetIndicatorRight)

	return TargetIndicator
end

function NP:Update_TargetIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	nameplate.TargetIndicator.style = NP.db.targetGlow
	nameplate.TargetIndicator.lowHealthThreshold = NP.db.lowHealthThreshold

	if NP.db.targetGlow ~= 'none' then
		local GlowStyle = NP.db.targetGlow
		if not db.health.enable and (GlowStyle ~= 'style2' and GlowStyle ~= 'style6' and GlowStyle ~= 'style8') then
			GlowStyle = 'style2'
			nameplate.TargetIndicator.style = 'style2'
		end
		local Color = NP.db.colors.glowColor
		if nameplate.TargetIndicator.TopIndicator and (GlowStyle == 'style3' or GlowStyle == 'style5' or GlowStyle == 'style6') then
			local topArrowSpace = -3
			if db.showName and (nameplate.Name:GetText() ~= nil and nameplate.Name:GetText() ~= '') then
				topArrowSpace = NP.db.fontSize + topArrowSpace
			end
			nameplate.TargetIndicator.TopIndicator:Point('BOTTOM', nameplate.Health, 'TOP', 0, topArrowSpace)
			nameplate.TargetIndicator.TopIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end

		if (nameplate.TargetIndicator.LeftIndicator and nameplate.TargetIndicator.RightIndicator) and (GlowStyle == 'style4' or GlowStyle == 'style7' or GlowStyle == 'style8') then
			nameplate.TargetIndicator.LeftIndicator:Point('LEFT', nameplate.Health, 'RIGHT', -3, 0)
			nameplate.TargetIndicator.RightIndicator:Point('RIGHT', nameplate.Health, 'LEFT', 3, 0)
			nameplate.TargetIndicator.LeftIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
			nameplate.TargetIndicator.RightIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end

		if nameplate.TargetIndicator.Shadow and (GlowStyle == 'style1' or GlowStyle == 'style5' or GlowStyle == 'style7') then
			nameplate.TargetIndicator.Shadow:SetOutside(nameplate.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))
			nameplate.TargetIndicator.Shadow:SetBackdropBorderColor(Color.r, Color.g, Color.b, Color.a)
		end

		if nameplate.TargetIndicator.Spark and (GlowStyle == 'style2' or GlowStyle == 'style6' or GlowStyle == 'style8') then
			local scale = 1
			if NP.db.useTargetScale then
				if NP.db.targetScale >= 0.75 then
					scale = NP.db.targetScale
				else
					scale = 0.75
				end
			end

			local size = (E.Border + 14) * scale;

			nameplate.TargetIndicator.Spark:Point('TOPLEFT', nameplate.Health, 'TOPLEFT', -(size * 2), size)
			nameplate.TargetIndicator.Spark:Point('BOTTOMRIGHT', nameplate.Health, 'BOTTOMRIGHT', size * 2, -size)
			nameplate.TargetIndicator.Spark:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end
	end
end

function NP:Construct_Highlight(nameplate)
	local Highlight = CreateFrame('Frame', nameplate:GetDebugName()..'Highlight', nameplate)
	Highlight.texture = Highlight:CreateTexture(nil, 'BACKGROUND', nil, 1)
	Highlight.texture:SetSnapToPixelGrid(false)
	Highlight.texture:SetTexelSnappingBias(0)

	return Highlight
end

function NP:Update_Highlight(nameplate)
	local db = NP.db.units[nameplate.frameType]
	if NP.db.highlight then
		if db.health.enable then
			nameplate.Highlight.texture:SetColorTexture(1, 1, 1, .3)
			nameplate.Highlight.texture:SetAllPoints(nameplate.Health)
			nameplate.Highlight.texture:SetAlpha(1)
		else
			nameplate.Highlight.texture:SetTexture(E.Media.Textures.Spark)
			nameplate.Highlight.texture:SetAllPoints(nameplate)
			nameplate.Highlight.texture:SetAlpha(.5)
		end
	end
end

function NP:Construct_HealerSpecs(nameplate)
	local texture = nameplate:CreateTexture(nil, "OVERLAY")
	texture:Size(40, 40)
	texture:SetTexture(E.Media.Textures.Healer)
	texture:Hide()

	return texture
end

function NP:Update_HealerSpecs(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'ENEMY_PLAYER') and db.markHealers then
		if not nameplate:IsElementEnabled('HealerSpecs') then
			nameplate:EnableElement('HealerSpecs')
		end

		nameplate.HealerSpecs:Point("RIGHT", nameplate.Health, "LEFT", -6, 0)
	else
		if nameplate:IsElementEnabled('HealerSpecs') then
			nameplate:DisableElement('HealerSpecs')
		end
	end
end

function NP:Construct_DetectionIndicator(nameplate)
	local model = CreateFrame("PlayerModel", nil, nameplate)
	model:Size(75, 75)
	model:Hide()

	return model
end

function NP:Update_DetectionIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'ENEMY_NPC') and db.detection and db.detection.enable then
		if not nameplate:IsElementEnabled('DetectionIndicator') then
			nameplate:EnableElement('DetectionIndicator')
		end

		nameplate.DetectionIndicator:Point("BOTTOM", nameplate, "TOP", 0, 0)
	else
		if nameplate:IsElementEnabled('DetectionIndicator') then
			nameplate:DisableElement('DetectionIndicator')
		end
	end
end

function NP:Construct_FloatingCombatFeedback(nameplate)
	local FloatingCombatFeedback = CreateFrame("Frame", nil, nameplate)
	FloatingCombatFeedback:SetPoint('CENTER')
	FloatingCombatFeedback:SetSize(16, 16)

	for i = 1, 12 do
		FloatingCombatFeedback[i] = FloatingCombatFeedback:CreateFontString(nil, "OVERLAY")
	end

	return FloatingCombatFeedback
end

function NP:Update_FloatingCombatFeedback(nameplate)
	nameplate.FloatingCombatFeedback.mode = "Fountain"
	nameplate.FloatingCombatFeedback.xOffset = 60
	nameplate.FloatingCombatFeedback.yOffset = 10
	nameplate.FloatingCombatFeedback.yDirection = 1 -- 1 (Up) or -1 (Down)
	nameplate.FloatingCombatFeedback.scrollTime = 1.5

	for i = 1, 12 do
		nameplate.FloatingCombatFeedback[i]:SetFont(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)
	end
end
