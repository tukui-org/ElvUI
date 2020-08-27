local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local strfind = strfind
local ipairs, unpack = ipairs, unpack
local CreateFrame = CreateFrame

local questIconTypes = { 'Default', 'Item', 'Skull', 'Chat' }
local targetIndicators = { 'Spark', 'TopIndicator', 'LeftIndicator', 'RightIndicator' }

function NP:Construct_QuestIcons(nameplate)
	local QuestIcons = CreateFrame('Frame', nameplate:GetName() .. 'QuestIcons', nameplate)
	QuestIcons:SetSize(20, 20)
	QuestIcons:Hide()

	for _, object in ipairs(questIconTypes) do
		local icon = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
		icon.Text = QuestIcons:CreateFontString(nil, 'OVERLAY')
		icon.Text:FontTemplate()
		icon:Hide()

		QuestIcons[object] = icon
	end

	QuestIcons.Item:SetTexCoord(unpack(E.TexCoords))
	QuestIcons.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	QuestIcons.Chat:SetTexCoord(0, 0.5, 0.5, 1)

	return QuestIcons
end

function NP:Update_QuestIcons(nameplate)
	local frameType = nameplate.frameType
	local db = frameType and NP.db.units[frameType].questIcon

	if db and db.enable and (frameType == 'FRIENDLY_NPC' or frameType == 'ENEMY_NPC') then
		if not nameplate:IsElementEnabled('QuestIcons') then
			nameplate:EnableElement('QuestIcons')
		end

		nameplate.QuestIcons:ClearAllPoints()
		nameplate.QuestIcons:SetPoint(E.InversePoints[db.position], nameplate, db.position, db.xOffset, db.yOffset)

		for _, object in ipairs(questIconTypes) do
			local icon = nameplate.QuestIcons[object]
			icon:SetSize(db.size, db.size)
			icon:SetAlpha(db.hideIcon and 0 or 1)

			local xoffset = strfind(db.textPosition, 'LEFT') and -2 or 2
			local yoffset = strfind(db.textPosition, 'BOTTOM') and 2 or -2
			icon.Text:ClearAllPoints()
			icon.Text:SetPoint('CENTER', icon, db.textPosition, xoffset, yoffset)
			icon.Text:FontTemplate(E.Libs.LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
			icon.Text:SetJustifyH('CENTER')

			icon.size, icon.position = db.size, db.position
		end
	elseif nameplate:IsElementEnabled('QuestIcons') then
		nameplate:DisableElement('QuestIcons')
	end
end

function NP:Construct_ClassificationIndicator(nameplate)
	return nameplate:CreateTexture(nameplate:GetName() .. 'ClassificationIndicator', 'OVERLAY')
end

function NP:Update_ClassificationIndicator(nameplate)
	local frameType = nameplate.frameType
	local db = frameType and NP.db.units[frameType].eliteIcon

	if db and db.enable and (frameType == 'FRIENDLY_NPC' or frameType == 'ENEMY_NPC') then
		if not nameplate:IsElementEnabled('ClassificationIndicator') then
			nameplate:EnableElement('ClassificationIndicator')
		end

		nameplate.ClassificationIndicator:ClearAllPoints()
		nameplate.ClassificationIndicator:SetSize(db.size, db.size)
		nameplate.ClassificationIndicator:SetPoint(E.InversePoints[db.position], nameplate, db.position, db.xOffset, db.yOffset)
	elseif nameplate:IsElementEnabled('ClassificationIndicator') then
		nameplate:DisableElement('ClassificationIndicator')
	end
end

function NP:Construct_TargetIndicator(nameplate)
	local TargetIndicator = CreateFrame('Frame', nameplate:GetName() .. 'TargetIndicator', nameplate)
	TargetIndicator:SetFrameLevel(0)

	TargetIndicator.Shadow = CreateFrame('Frame', nil, TargetIndicator)
	TargetIndicator.Shadow:SetBackdrop({edgeFile = E.Media.Textures.GlowTex, edgeSize = 5})
	TargetIndicator.Shadow:Hide()

	for _, object in ipairs(targetIndicators) do
		local indicator = TargetIndicator:CreateTexture(nil, 'BACKGROUND', nil, -5)
		indicator:Hide()

		TargetIndicator[object] = indicator
	end

	return TargetIndicator
end

function NP:Update_TargetIndicator(nameplate)
	local db = NP:PlateDB(nameplate)

	if nameplate.frameType == 'PLAYER' then
		if nameplate:IsElementEnabled('TargetIndicator') then
			nameplate:DisableElement('TargetIndicator')
		end
		return
	end

	if not nameplate:IsElementEnabled('TargetIndicator') then
		nameplate:EnableElement('TargetIndicator')
	end

	nameplate.TargetIndicator.style = NP.db.units.TARGET.glowStyle
	nameplate.TargetIndicator.lowHealthThreshold = NP.db.lowHealthThreshold

	if nameplate.TargetIndicator.style ~= 'none' then
		local GlowStyle, Color = NP.db.units.TARGET.glowStyle, NP.db.colors.glowColor

		if not db.health.enable and (GlowStyle ~= 'style2' and GlowStyle ~= 'style6' and GlowStyle ~= 'style8') then
			GlowStyle = 'style2'
			nameplate.TargetIndicator.style = 'style2'
		end

		if nameplate.TargetIndicator.TopIndicator and (GlowStyle == 'style3' or GlowStyle == 'style5' or GlowStyle == 'style6') then
			nameplate.TargetIndicator.TopIndicator:SetPoint('BOTTOM', nameplate.Health, 'TOP', 0, -6)
			nameplate.TargetIndicator.TopIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end

		if (nameplate.TargetIndicator.LeftIndicator and nameplate.TargetIndicator.RightIndicator) and (GlowStyle == 'style4' or GlowStyle == 'style7' or GlowStyle == 'style8') then
			nameplate.TargetIndicator.LeftIndicator:SetPoint('LEFT', nameplate.Health, 'RIGHT', -3, 0)
			nameplate.TargetIndicator.RightIndicator:SetPoint('RIGHT', nameplate.Health, 'LEFT', 3, 0)
			nameplate.TargetIndicator.LeftIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
			nameplate.TargetIndicator.RightIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end

		if nameplate.TargetIndicator.Shadow and (GlowStyle == 'style1' or GlowStyle == 'style5' or GlowStyle == 'style7') then
			nameplate.TargetIndicator.Shadow:SetOutside(nameplate.Health, E.PixelMode and 6 or 8, E.PixelMode and 6 or 8)
			nameplate.TargetIndicator.Shadow:SetBackdropBorderColor(Color.r, Color.g, Color.b)
			nameplate.TargetIndicator.Shadow:SetAlpha(Color.a)
		end

		if nameplate.TargetIndicator.Spark and (GlowStyle == 'style2' or GlowStyle == 'style6' or GlowStyle == 'style8') then
			local size = E.Border + 14
			nameplate.TargetIndicator.Spark:SetPoint('TOPLEFT', nameplate.Health, 'TOPLEFT', -(size * 2), size)
			nameplate.TargetIndicator.Spark:SetPoint('BOTTOMRIGHT', nameplate.Health, 'BOTTOMRIGHT', (size * 2), -size)
			nameplate.TargetIndicator.Spark:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end
	end
end

function NP:Construct_Highlight(nameplate)
	local Highlight = CreateFrame('Frame', nameplate:GetName() .. 'Highlight', nameplate)
	Highlight:Hide()
	Highlight:EnableMouse(false)
	Highlight:SetFrameLevel(9)

	Highlight.texture = Highlight:CreateTexture(nil, 'ARTWORK')

	return Highlight
end

function NP:Update_Highlight(nameplate)
	local db = NP:PlateDB(nameplate)

	if NP.db.highlight and db.enable then
		if not nameplate:IsElementEnabled('Highlight') then
			nameplate:EnableElement('Highlight')
		end

		local sf = NP:StyleFilterChanges(nameplate)
		if db.health.enable and not (db.nameOnly or sf.NameOnly) then
			nameplate.Highlight.texture:SetColorTexture(1, 1, 1, 0.25)
			nameplate.Highlight.texture:SetAllPoints(nameplate.HealthFlashTexture)
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
	local texture = nameplate:CreateTexture(nameplate:GetName() .. 'PVPRole', 'OVERLAY', nil, 1)
	texture:SetSize(40, 40)
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

		nameplate.PVPRole:SetPoint('RIGHT', nameplate.Health, 'LEFT', -6, 0)
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
	else
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
	local frameName = nameplate:GetName()
	local Cutaway = {}

	Cutaway.Health = nameplate.Health.ClipFrame:CreateTexture(frameName .. 'CutawayHealth')
	local healthTexture = nameplate.Health:GetStatusBarTexture()
	Cutaway.Health:SetPoint('TOPLEFT', healthTexture, 'TOPRIGHT')
	Cutaway.Health:SetPoint('BOTTOMLEFT', healthTexture, 'BOTTOMRIGHT')

	Cutaway.Power = nameplate.Power.ClipFrame:CreateTexture(frameName .. 'CutawayPower')
	local powerTexture = nameplate.Power:GetStatusBarTexture()
	Cutaway.Power:SetPoint('TOPLEFT', powerTexture, 'TOPRIGHT')
	Cutaway.Power:SetPoint('BOTTOMLEFT', powerTexture, 'BOTTOMRIGHT')

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
			nameplate.Cutaway.Health:SetTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))
		end

		if NP.db.cutaway.power.forceBlankTexture then
			nameplate.Cutaway.Power:SetTexture(E.media.blankTex)
		else
			nameplate.Cutaway.Power:SetTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))
		end
	end
end

function NP:Construct_WidgetXPBar(nameplate)
	local WidgetXPBar = CreateFrame('StatusBar', nameplate:GetName() .. 'WidgetXPBar', nameplate)
	WidgetXPBar:SetFrameStrata(nameplate:GetFrameStrata())
	WidgetXPBar:SetFrameLevel(5)
	WidgetXPBar:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))
	WidgetXPBar:CreateBackdrop('Transparent')

	WidgetXPBar.Rank = NP:Construct_TagText(nameplate.RaisedElement)
	WidgetXPBar.ProgressText = NP:Construct_TagText(nameplate.RaisedElement)

	NP.StatusBars[WidgetXPBar] = true

	return WidgetXPBar
end

function NP:Update_WidgetXPBar(nameplate)
	local db = NP:PlateDB(nameplate)

	if not db.widgetXPBar or not db.widgetXPBar.enable then
		if nameplate:IsElementEnabled('WidgetXPBar') then
			nameplate:DisableElement('WidgetXPBar')
		end
	else
		if not nameplate:IsElementEnabled('WidgetXPBar') then
			nameplate:EnableElement('WidgetXPBar')
		end

		local bar = nameplate.WidgetXPBar
		bar:ClearAllPoints()
		bar:SetPoint('TOPLEFT', nameplate, 'BOTTOMLEFT', 0, db.widgetXPBar.yOffset)
		bar:SetPoint('TOPRIGHT', nameplate, 'BOTTOMRIGHT', 0, db.widgetXPBar.yOffset)
		bar:SetHeight(10)

		bar.Rank:ClearAllPoints()
		bar.Rank:SetPoint('RIGHT', bar, 'LEFT', -4, 0)
		bar.ProgressText:ClearAllPoints()
		bar.ProgressText:SetPoint('CENTER', bar, 'CENTER')

		local color = db.widgetXPBar.color
		bar:SetStatusBarColor(color.r, color.g, color.b)

		bar:ForceUpdate()
	end
end
