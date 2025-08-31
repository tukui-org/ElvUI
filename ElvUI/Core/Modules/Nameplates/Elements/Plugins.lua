local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local PA = E:GetModule('PrivateAuras')
local LSM = E.Libs.LSM

local ipairs, unpack = ipairs, unpack
local CreateFrame = CreateFrame

local targetIndicators = {'Spark', 'TopIndicator', 'LeftIndicator', 'RightIndicator'}

function NP:Construct_QuestIcons(nameplate)
	local QuestIcons = CreateFrame('Frame', nameplate.frameName..'QuestIcons', nameplate.RaisedElement)
	QuestIcons:Size(20)
	QuestIcons:Hide()
	QuestIcons:CreateBackdrop()
	QuestIcons.backdrop:Hide()

	for name, object in ipairs(NP.QuestIcons.iconTypes) do
		local icon = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
		icon.Text = QuestIcons:CreateFontString(nil, 'OVERLAY')
		icon.Text:FontTemplate()
		icon:Hide()

		if name == 'Item' then
			QuestIcons.backdrop:SetOutside(icon)
		end

		QuestIcons[object] = icon
	end

	QuestIcons.Item:SetTexCoord(unpack(E.TexCoords))
	QuestIcons.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	QuestIcons.Chat:SetTexCoord(0, 0.5, 0.5, 1)

	return QuestIcons
end

function NP:Update_QuestIcons(nameplate)
	local plateDB = NP:PlateDB(nameplate)
	local db = not E.Classic and plateDB.questIcon

	if db and db.enable and not nameplate.isBattlePet and (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') then
		if not nameplate:IsElementEnabled('QuestIcons') then
			nameplate:EnableElement('QuestIcons')
		end

		nameplate.QuestIcons:ClearAllPoints()
		nameplate.QuestIcons:Point(E.InversePoints[db.position], nameplate, db.position, db.xOffset, db.yOffset)

		local font = LSM:Fetch('font', db.font)
		for _, object in ipairs(NP.QuestIcons.iconTypes) do
			local icon = nameplate.QuestIcons[object]
			icon:SetAlpha(db.hideIcon and 0 or 1)
			icon:Size(db.size)

			icon.Text:ClearAllPoints()
			icon.Text:Point('CENTER', icon, db.textPosition, db.textXOffset, db.textYOffset)
			icon.Text:FontTemplate(font, db.fontSize, db.fontOutline)
			icon.Text:SetJustifyH('CENTER')

			-- settings to send to the plugin
			icon.size, icon.position, icon.spacing = db.size, db.position, db.spacing
		end
	elseif nameplate:IsElementEnabled('QuestIcons') then
		nameplate:DisableElement('QuestIcons')
	end
end

function NP:Construct_ClassificationIndicator(nameplate)
	return nameplate.RaisedElement:CreateTexture(nameplate.frameName..'ClassificationIndicator', 'OVERLAY')
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
	local TargetIndicator = CreateFrame('Frame', '$parentTargetIndicator', nameplate)
	TargetIndicator:SetFrameLevel(0)

	TargetIndicator.Shadow = CreateFrame('Frame', nil, TargetIndicator, 'BackdropTemplate')
	TargetIndicator.Shadow:Hide()

	for _, object in ipairs(targetIndicators) do
		local indicator = TargetIndicator:CreateTexture(nil, 'BACKGROUND', nil, -5)
		indicator:Hide()

		TargetIndicator[object] = indicator
	end

	return TargetIndicator
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
	local Highlight = CreateFrame('Frame', '$parentHighlight', nameplate)
	Highlight:Hide()
	Highlight:EnableMouse(false)
	Highlight:SetFrameLevel(9)

	Highlight.texture = Highlight:CreateTexture(nil, 'ARTWORK')

	return Highlight
end

function NP:Update_Highlight(nameplate, nameOnlySF)
	local db = NP:PlateDB(nameplate)

	if NP.db.highlight and db.enable then
		if not nameplate:IsElementEnabled('Highlight') then
			nameplate:EnableElement('Highlight')
		end

		if db.health.enable and not (db.nameOnly or nameOnlySF) then
			nameplate.Highlight.texture:SetColorTexture(1, 1, 1, 0.25)
			nameplate.Highlight.texture:SetAllPoints(nameplate.Health.flashTexture)
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
	local texture = nameplate.RaisedElement:CreateTexture(nameplate.frameName..'PVPRole', 'OVERLAY', nil, 1)
	texture:Size(40)
	texture.HealerTexture = E.Media.Textures.Healer
	texture.TankTexture = E.Media.Textures.Tank
	texture:SetTexture(texture.HealerTexture)

	texture:Hide()

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
	local Cutaway = {}

	Cutaway.Health = nameplate.Health.ClipFrame:CreateTexture(nameplate.frameName..'CutawayHealth')
	local healthTexture = nameplate.Health:GetStatusBarTexture()
	Cutaway.Health:Point('TOPLEFT', healthTexture, 'TOPRIGHT')
	Cutaway.Health:Point('BOTTOMLEFT', healthTexture, 'BOTTOMRIGHT')

	Cutaway.Power = nameplate.Power.ClipFrame:CreateTexture(nameplate.frameName..'CutawayPower')
	local powerTexture = nameplate.Power:GetStatusBarTexture()
	Cutaway.Power:Point('TOPLEFT', powerTexture, 'TOPRIGHT')
	Cutaway.Power:Point('BOTTOMLEFT', powerTexture, 'BOTTOMRIGHT')

	return Cutaway
end

function NP:Update_Cutaway(nameplate)
	local eitherEnabled = NP.db.cutaway.health.enabled or NP.db.cutaway.power.enabled
	if not eitherEnabled then
		if nameplate:IsElementEnabled('Cutaway') then
			nameplate:DisableElement('Cutaway')
		end
	else
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
	end
end

function NP:Construct_PrivateAuras(nameplate)
	return CreateFrame('Frame', nameplate.frameName..'PrivateAuras', nameplate.RaisedElement)
end

function NP:Update_PrivateAuras(nameplate, disable)
	if not E.Retail then return end -- dont exist on classic

	if nameplate.PrivateAuras then
		PA:RemoveAuras(nameplate.PrivateAuras)
	end

	local plateDB = not disable and NP:PlateDB(nameplate)
	local db = plateDB and plateDB.privateAuras
	if db and db.enable then
		PA:SetupPrivateAuras(db, nameplate.PrivateAuras, nameplate.unit)

		nameplate.PrivateAuras:ClearAllPoints()
		nameplate.PrivateAuras:Point(E.InversePoints[db.parent.point], nameplate, db.parent.point, db.parent.offsetX, db.parent.offsetY)
		nameplate.PrivateAuras:Size(db.icon.size)
		nameplate.PrivateAuras:SetFrameLevel(16)
	end
end
