local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local ipairs = ipairs
local CreateFrame = CreateFrame

local targetIndicators = { 'Spark', 'TopIndicator', 'LeftIndicator', 'RightIndicator' }

function NP:Construct_QuestIcons(nameplate)
	local element = CreateFrame('Frame', nameplate.frameName..'QuestIcons', nameplate.RaisedElement)
	element:SetFrameLevel(nameplate.RaisedElement.QuestIconLevel)
	element:Size(20)
	element:Hide()

	element:CreateBackdrop()
	element.backdrop:Hide()

	for name, object in ipairs(NP.QuestIcons.iconTypes) do
		local icon = element:CreateTexture(nil, 'BORDER', nil, 1)
		icon.Text = element:CreateFontString(nil, 'OVERLAY')
		icon.Text:FontTemplate()
		icon:Hide()

		if name == 'Item' then
			element.backdrop:SetOutside(icon)
		end

		element[object] = icon
	end

	element.Item:SetTexCoords()
	element.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	element.Chat:SetTexCoord(0, 0.5, 0.5, 1)

	return element
end

function NP:Update_QuestIcons(nameplate, updateBase)
	local plateDB = NP:PlateDB(nameplate)
	local db = not E.Classic and plateDB.questIcon

	if db and db.enable and not nameplate.isBattlePet and (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') then
		if not nameplate:IsElementEnabled('QuestIcons') then
			nameplate:EnableElement('QuestIcons')
		elseif not updateBase then
			return
		end

		nameplate.QuestIcons:ClearAllPoints()
		nameplate.QuestIcons:Point(E.InversePoints[db.position], nameplate, db.position, db.xOffset, db.yOffset)

		for _, object in ipairs(NP.QuestIcons.iconTypes) do
			local icon = nameplate.QuestIcons[object]
			icon:SetAlpha(db.hideIcon and 0 or 1)
			icon:Size(db.size)

			icon.Text:ClearAllPoints()
			icon.Text:Point('CENTER', icon, db.textPosition, db.textXOffset, db.textYOffset)
			icon.Text:FontTemplate(db.font, db.fontSize, db.fontOutline)
			icon.Text:SetJustifyH('CENTER')

			-- settings to send to the plugin
			icon.size, icon.position, icon.spacing = db.size, db.position, db.spacing
		end
	elseif nameplate:IsElementEnabled('QuestIcons') then
		nameplate:DisableElement('QuestIcons')
	end
end

function NP:Construct_ClassificationIndicator(nameplate)
	local element = CreateFrame('Frame', nameplate.frameName..'ClassificationIndicator', nameplate.RaisedElement)
	element:SetFrameLevel(nameplate.RaisedElement.ClassificationLevel)

	local texture = nameplate.RaisedElement:CreateTexture(nil, 'OVERLAY')
	element.texture = texture

	return texture
end

function NP:Update_ClassificationIndicator(nameplate)
	local plateDB = NP:PlateDB(nameplate)
	local db = plateDB.eliteIcon

	if db and db.enable and (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') then
		if not nameplate:IsElementEnabled('ClassificationIndicator') then
			nameplate:EnableElement('ClassificationIndicator')
		end

		nameplate.ClassificationIndicator:ClearAllPoints()
		nameplate.ClassificationIndicator:Size(db.size, db.size)
		nameplate.ClassificationIndicator:Point(E.InversePoints[db.position], nameplate, db.position, db.xOffset, db.yOffset)
	elseif nameplate:IsElementEnabled('ClassificationIndicator') then
		nameplate:DisableElement('ClassificationIndicator')
	end
end

function NP:Construct_TargetIndicator(nameplate)
	local element = CreateFrame('Frame', '$parentTargetIndicator', nameplate)
	element:SetFrameLevel(nameplate.RaisedElement.TargetIndicatorLevel)

	local shadow = CreateFrame('Frame', nil, element, 'BackdropTemplate')
	shadow:Hide()

	element.Shadow = shadow

	for _, object in ipairs(targetIndicators) do
		local indicator = element:CreateTexture(nil, 'BACKGROUND', nil, -5)
		indicator:Hide()

		element[object] = indicator
	end

	return element
end

function NP:Update_TargetIndicator(nameplate)
	local enabled = nameplate:IsElementEnabled('TargetIndicator')
	if nameplate.frameType == 'PLAYER' then
		if enabled then
			nameplate:DisableElement('TargetIndicator')
		end

		return
	elseif not enabled then
		nameplate:EnableElement('TargetIndicator')
	end

	local tdb = NP.db.units.TARGET
	local indicator = nameplate.TargetIndicator

	indicator.arrow = E.Media.Arrows[NP.db.units.TARGET.arrow] or E.Media.Arrows.Arrow9
	indicator.lowHealthThreshold = NP.db.lowHealthThreshold
	indicator.preferGlowColor = NP.db.colors.preferGlowColor
	indicator.style = tdb.glowStyle

	if indicator.style ~= 'none' then
		local style, color, scale, spacing = tdb.glowStyle, NP.db.colors.glowColor, tdb.arrowScale, tdb.arrowSpacing
		local r, g, b, a = color.r, color.g, color.b, color.a
		local db = NP:PlateDB(nameplate)

		-- background glow is 2, 6, and 8; 2 is background glow only
		if not db.health.enable and (style ~= 'style2' and style ~= 'style6' and style ~= 'style8') then
			style = 'style2'
			indicator.style = style
		end

		-- top arrow is 3, 5, 6
		if indicator.TopIndicator and (style == 'style3' or style == 'style5' or style == 'style6') then
			indicator.TopIndicator:Point('BOTTOM', nameplate.Health, 'TOP', 0, spacing)
			indicator.TopIndicator:SetVertexColor(r, g, b, a)
			indicator.TopIndicator:SetScale(scale)
		end

		-- side arrows are 4, 7, 8
		if indicator.LeftIndicator and indicator.RightIndicator and (style == 'style4' or style == 'style7' or style == 'style8') then
			indicator.LeftIndicator:Point('LEFT', nameplate.Health, 'RIGHT', spacing, 0)
			indicator.RightIndicator:Point('RIGHT', nameplate.Health, 'LEFT', -spacing, 0)
			indicator.LeftIndicator:SetVertexColor(r, g, b, a)
			indicator.RightIndicator:SetVertexColor(r, g, b, a)
			indicator.LeftIndicator:SetScale(scale)
			indicator.RightIndicator:SetScale(scale)
		end

		-- border glow is 1, 5, 7
		if indicator.Shadow and (style == 'style1' or style == 'style5' or style == 'style7') then
			indicator.Shadow:SetOutside(nameplate.Health, E.PixelMode and 6 or 8, E.PixelMode and 6 or 8, nil, true)
			indicator.Shadow:SetBackdropBorderColor(r, g, b)
			indicator.Shadow:SetAlpha(a)
		end

		-- background glow is 2, 6, and 8
		if indicator.Spark and (style == 'style2' or style == 'style6' or style == 'style8') then
			local size = E.Border + 14
			indicator.Spark:Point('TOPLEFT', nameplate.Health, 'TOPLEFT', -(size * 2), size)
			indicator.Spark:Point('BOTTOMRIGHT', nameplate.Health, 'BOTTOMRIGHT', (size * 2), -size)
			indicator.Spark:SetVertexColor(r, g, b, a)
		end
	end
end

function NP:Construct_Highlight(nameplate)
	local element = CreateFrame('Frame', '$parentHighlight', nameplate)
	element:SetFrameLevel(nameplate.RaisedElement.HighlightLevel)
	element:EnableMouse(false)
	element:Hide()

	element.texture = element:CreateTexture(nil, 'ARTWORK')

	return element
end

function NP:Update_Highlight(nameplate)
	local db = NP:PlateDB(nameplate)

	if NP.db.highlight and db.enable then
		if not nameplate:IsElementEnabled('Highlight') then
			nameplate:EnableElement('Highlight')
		end

		if db.health.enable and not db.nameOnly then
			nameplate.Highlight.texture:SetColorTexture(1, 1, 1, 0.25)
			nameplate.Highlight.texture:SetAllPoints(nameplate.Health)
			nameplate.Highlight.texture:SetAlpha(0.75)
		else
			nameplate.Highlight.texture:SetTexture(E.Media.Textures.Spark)
			nameplate.Highlight.texture:SetAllPoints(nameplate)
			nameplate.Highlight.texture:SetAlpha(0.50)
		end
	elseif nameplate:IsElementEnabled('Highlight') then
		nameplate:DisableElement('Highlight')
	end
end

function NP:Construct_PVPRole(nameplate)
	local element = CreateFrame('Frame', nameplate.frameName..'PVPRole', nameplate.RaisedElement)
	element:SetFrameLevel(nameplate.RaisedElement.PVPRoleLevel)

	local texture = nameplate.RaisedElement:CreateTexture(nil, 'OVERLAY')
	texture:SetTexture(texture.HealerTexture)
	texture:Size(40)
	texture:Hide()

	texture.HealerTexture = E.Media.Textures.Healer
	texture.TankTexture = E.Media.Textures.Tank

	element.texture = texture

	return texture
end

function NP:Update_PVPRole(nameplate)
	local db = NP:PlateDB(nameplate)

	if (nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'ENEMY_PLAYER') and (db.markHealers or db.markTanks) then
		if not nameplate:IsElementEnabled('PVPRole') then
			nameplate:EnableElement('PVPRole')
		end

		nameplate.PVPRole.ShowHealers = db.markHealers
		nameplate.PVPRole.ShowTanks = db.markTanks

		nameplate.PVPRole:Point('RIGHT', nameplate.Health, 'LEFT', -6, 0)
	elseif nameplate:IsElementEnabled('PVPRole') then
		nameplate:DisableElement('PVPRole')
	end
end

function NP:Update_Fader(nameplate)
	local db = NP:PlateDB(nameplate)
	local vis = db.visibility

	if not vis or vis.showAlways then
		if nameplate:IsElementEnabled('Fader') then
			nameplate:DisableElement('Fader')

			NP:PlateFade(nameplate, 1, nameplate:GetAlpha(), 1)
		end
	elseif db.enable then
		if not nameplate.Fader then
			nameplate.Fader = {}
		end

		if not nameplate:IsElementEnabled('Fader') then
			nameplate:EnableElement('Fader')

			nameplate.Fader:SetOption('MinAlpha', 0)
			nameplate.Fader:SetOption('Smooth', 0.3)
			nameplate.Fader:SetOption('Hover', true)
			nameplate.Fader:SetOption('Power', true)
			nameplate.Fader:SetOption('Health', true)
			nameplate.Fader:SetOption('Casting', true)
		end

		nameplate.Fader:SetOption('Combat', vis.showInCombat)
		nameplate.Fader:SetOption('PlayerTarget', vis.showWithTarget)
		nameplate.Fader:SetOption('DelayAlpha', (vis.alphaDelay > 0 and vis.alphaDelay) or nil)
		nameplate.Fader:SetOption('Delay', (vis.hideDelay > 0 and vis.hideDelay) or nil)

		nameplate.Fader:ForceUpdate()
	end
end

function NP:Construct_Cutaway(nameplate)
	local element = {}

	local healthTexture = nameplate.Health:GetStatusBarTexture()
	local health = nameplate.Health.ClipFrame:CreateTexture(nameplate.frameName..'CutawayHealth')
	health:Point('TOPLEFT', healthTexture, 'TOPRIGHT')
	health:Point('BOTTOMLEFT', healthTexture, 'BOTTOMRIGHT')
	element.Health = health

	local powerTexture = nameplate.Power:GetStatusBarTexture()
	local power = nameplate.Power.ClipFrame:CreateTexture(nameplate.frameName..'CutawayPower')
	power:Point('TOPLEFT', powerTexture, 'TOPRIGHT')
	power:Point('BOTTOMLEFT', powerTexture, 'BOTTOMRIGHT')
	element.Power = power

	return element
end

function NP:Update_Cutaway(nameplate)
	if not E.Modern and (NP.db.cutaway.health.enabled or NP.db.cutaway.power.enabled) then
		if not nameplate:IsElementEnabled('Cutaway') then
			nameplate:EnableElement('Cutaway')
		end

		nameplate.Cutaway:UpdateConfigurationValues(NP.db.cutaway)

		if NP.db.cutaway.health.forceBlankTexture then
			nameplate.Cutaway.Health:SetTexture(E.media.blankTex)
		else
			nameplate.Cutaway.Health:SetTexture(LSM:Fetch('statusbar', NP.db.statusbar))
		end

		if NP.db.cutaway.power.forceBlankTexture then
			nameplate.Cutaway.Power:SetTexture(E.media.blankTex)
		else
			nameplate.Cutaway.Power:SetTexture(LSM:Fetch('statusbar', NP.db.statusbar))
		end
	elseif nameplate:IsElementEnabled('Cutaway') then
		nameplate:DisableElement('Cutaway')
	end
end
