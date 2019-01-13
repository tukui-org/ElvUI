local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_QuestIcons(nameplate)
	local QuestIcons = CreateFrame('Frame', nil, nameplate)
	QuestIcons:Hide()
	QuestIcons:SetSize(NP.db.questIconSize + 4, NP.db.questIconSize + 4)
	QuestIcons:SetPoint("LEFT", nameplate, "RIGHT", 4, 0) -- need option

	for _, object in pairs({'Item', 'Loot', 'Skull', 'Chat'}) do
		QuestIcons[object] = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
		QuestIcons[object]:SetPoint('TOPLEFT')
		QuestIcons[object]:SetSize(NP.db.questIconSize, NP.db.questIconSize)
		QuestIcons[object]:Hide()
	end

	QuestIcons.Item:SetTexCoord(unpack(E.TexCoords))

	QuestIcons.Skull:SetSize(NP.db.questIconSize + 4, NP.db.questIconSize + 4)

	QuestIcons.Chat:SetSize(NP.db.questIconSize + 4, NP.db.questIconSize + 4)
	QuestIcons.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	QuestIcons.Chat:SetTexCoord(0, 0.5, 0.5, 1)

	QuestIcons.Text = QuestIcons:CreateFontString(nil, 'OVERLAY')
	QuestIcons.Text:SetPoint('BOTTOMRIGHT', QuestIcons, 'BOTTOMRIGHT', 2, -0.8)
	QuestIcons.Text:SetFont(E.Libs.LSM:Fetch("font", NP.db.font), NP.db.fontSize, NP.db.fontOutline)

--function mod:QuestIcon_RelativePosition(frame, element)
--	if not frame.QuestIcon then return end

--	local unit, isCastbarLeft, isCastbarRight, isEliteLeft, isEliteRight = frame.UnitType, false, false, false, false
--	if unit then
--		if self.db.units[unit].castbar.enable and element == "Castbar" and self.db.units[unit].castbar.iconPosition == "RIGHT" then
--			if frame.CastBar:IsShown() then isCastbarLeft = true end
--		end

--		if self.db.units[unit].eliteIcon and self.db.units[unit].eliteIcon.enable and self.db.units[unit].eliteIcon.position == "RIGHT" then
--			if frame.Elite:IsShown() then isEliteLeft = true end
--		end

--		if self.db.units[unit].castbar.enable and element == "Castbar" and self.db.units[unit].castbar.iconPosition == "LEFT" then
--			if frame.CastBar:IsShown() then isCastbarRight = true end
--		end

--		if self.db.units[unit].eliteIcon and self.db.units[unit].eliteIcon.enable and self.db.units[unit].eliteIcon.position == "LEFT" then
--			if frame.Elite:IsShown() then isEliteRight = true end
--		end
--	end

--	frame.QuestIcon:ClearAllPoints()
--	if self.db.questIconPosition == "RIGHT" then
--		if isCastbarLeft then
--			frame.QuestIcon:SetPoint("LEFT", frame.CastBar.Icon, "RIGHT", 4, 0)
--		elseif not isCastbarLeft and isEliteLeft then
--			frame.QuestIcon:SetPoint("LEFT", frame.Elite, "RIGHT", 4, 0)
--		else
--			frame.QuestIcon:SetPoint("LEFT", frame.HealthBar, "RIGHT", 4, 0)
--		end
--	elseif self.db.questIconPosition == "LEFT" then
--		if isCastbarRight then
--			frame.QuestIcon:SetPoint("RIGHT", frame.CastBar.Icon, "LEFT", -4, 0)
--		elseif not isCastbarRight and isEliteRight then
--			frame.QuestIcon:SetPoint("RIGHT", frame.Elite, "LEFT", -4, 0)
--		else
--			frame.QuestIcon:SetPoint("RIGHT", frame.HealthBar, "LEFT", -4, 0)
--		end
--	end
--end

	return QuestIcons
end

function NP:Update_QuestIcons(nameplate)
	if NP.db.questIcon and (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') then
		nameplate:EnableElement('QuestIcons')
	else
		nameplate:DisableElement('QuestIcons')
	end
end

function NP:Construct_ClassificationIndicator(nameplate)
	local ClassificationIndicator = nameplate:CreateTexture(nil, 'OVERLAY')

	return ClassificationIndicator
end

function NP:Update_ClassificationIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]
	if (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') and db.eliteIcon.enable then
		nameplate:EnableElement('ClassificationIndicator')
		nameplate.ClassificationIndicator:ClearAllPoints()
		nameplate.ClassificationIndicator:SetSize(db.eliteIcon.size, db.eliteIcon.size)
		if db.healthbar.enable then
			nameplate.ClassificationIndicator:Point(db.eliteIcon.position, nameplate.Health, db.eliteIcon.position, db.eliteIcon.xOffset, db.eliteIcon.yOffset)
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

	for _, object in pairs({'Spark', 'TopIndicator', 'LeftIndicator', 'RightIndicator'}) do
		TargetIndicator[object] = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
		TargetIndicator[object]:SetSnapToPixelGrid(false)
		TargetIndicator[object]:SetTexelSnappingBias(0)
		TargetIndicator[object]:Hide()
	end

	TargetIndicator.Spark:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark]])

	TargetIndicator.TopIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator]])

	TargetIndicator.LeftIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft]])

	TargetIndicator.RightIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight]])

	return TargetIndicator
end

function NP:Update_TargetIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	nameplate.TargetIndicator.style = NP['db'].targetGlow
	nameplate.TargetIndicator.lowHealthThreshold = NP['db'].lowHealthThreshold

	if NP['db'].targetGlow ~= 'none' then
		local GlowStyle = NP['db'].targetGlow
		local Color = NP['db'].colors.glowColor
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
	Highlight.texture:SetColorTexture(1, 1, 1, .3)

	function Highlight:PostUpdate()
		self.texture:ClearAllPoints()
		self.texture:SetPoint("TOPLEFT", self.__owner.Health, "TOPLEFT")
		self.texture:SetPoint("BOTTOMRIGHT", self.__owner.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
	end

	return Highlight
end

function NP:Update_Highlight(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.healthbar.enable then
		nameplate.Highlight.texture:Show()
	else
		nameplate.Highlight.texture:Hide()
	end
end
