local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local CreateFrame = CreateFrame

function UF:Construct_AuraWatch(frame)
	local auras = CreateFrame('Frame', '$parentAuraWatch', frame)
	auras:SetFrameLevel(frame.RaisedElementParent.AuraWatchLevel)
	auras:SetInside(frame.Health)

	auras.allowStacks = UF.SourceStacks -- fake stacking (same spell id)
	auras.PostCreateIcon = UF.BuffIndicator_PostCreateIcon
	auras.PostUpdateIcon = UF.BuffIndicator_PostUpdateIcon

	return auras
end

function UF:Configure_AuraWatch(frame, isPet)
	local db = frame.db and frame.db.buffIndicator
	if db and db.enable then
		if not frame:IsElementEnabled('AuraWatch') then
			frame:EnableElement('AuraWatch')
		end

		frame.AuraWatch.size = db.size
		frame.AuraWatch.countFont = LSM:Fetch('font', db.countFont)
		frame.AuraWatch.countFontSize = db.countFontSize
		frame.AuraWatch.countFontOutline = db.countFontOutline

		local auraTable
		if (frame.unit == 'pet' or isPet) and db.petSpecific then
			auraTable = E.global.unitframe.aurawatch.PET
		elseif db.profileSpecific then
			auraTable = E.db.unitframe.filters.aurawatch
		else
			auraTable = E.Filters.Expand({}, E.global.unitframe.aurawatch[E.myclass] or {})
			E:CopyTable(auraTable, E.global.unitframe.aurawatch.GLOBAL)
		end

		frame.AuraWatch:SetNewTable(auraTable)
	elseif frame:IsElementEnabled('AuraWatch') then
		frame:DisableElement('AuraWatch')
	end
end

function UF:BuffIndicator_PostCreateIcon(button)
	button.cd:SetAllPoints(button.icon)

	E:RegisterCooldown(button.cd, 'auraindicator')

	button.overlay:Hide()

	button.icon.border = button:CreateTexture(nil, 'BACKGROUND')
	button.icon.border:SetOutside(button.icon, 1, 1)
	button.icon.border:SetTexture(E.media.blankTex)
	button.icon.border:SetVertexColor(0, 0, 0)

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')
end

function UF:BuffIndicator_PostUpdateIcon(_, button)
	local settings = self.watched[button.spellID]
	if not settings then return end -- This should never fail

	local onlyText = settings.style == 'timerOnly'
	local colorIcon = settings.style == 'coloredIcon'
	local textureIcon = settings.style == 'texturedIcon'

	local iconShown = button.icon:IsShown()
	if (colorIcon or textureIcon) and not iconShown then
		button.icon:Show()
		button.icon.border:Show()

		button.cd:SetDrawSwipe(true)
		button.cd:SetDrawEdge(true)
	elseif onlyText and iconShown then
		button.icon:Hide()
		button.icon.border:Hide()

		button.cd:SetDrawSwipe(false)
		button.cd:SetDrawEdge(false)
	end

	button.cd:SetHideCountdownNumbers(not onlyText and not settings.displayText)

	local text = button.cd.Text or button.cd:GetRegions()
	if text then -- CD module aquires the text to Text but without it we need to grab it
		text:ClearAllPoints()
		text:Point(settings.cooldownAnchor or 'CENTER', settings.cooldownX or 1, settings.cooldownY or 1)

		local db = E.db.cooldown.auraindicator
		local color = (onlyText and settings.color) or (db and db.colors.text)
		if color then
			text:SetTextColor(color.r, color.g, color.b)
		else
			text:SetTextColor(1, 1, 1)
		end
	end

	local count = button.count
	if count then
		button.count:ClearAllPoints()
		button.count:Point(settings.countAnchor or 'BOTTOMRIGHT', settings.countX or 1, settings.countY or 1)
		button.count:FontTemplate(self.countFont, self.countFontSize or 12, self.countFontOutline or 'OUTLINE')
	end

	if colorIcon then
		button.icon:SetTexture(E.media.blankTex)
		button.icon:SetVertexColor(settings.color.r, settings.color.g, settings.color.b, settings.color.a)
	elseif textureIcon then
		button.icon:SetVertexColor(1, 1, 1)
		button.icon:SetTexCoords()
	end

	if textureIcon and button.filter == 'HARMFUL' then
		button.icon.border:SetVertexColor(1, 0, 0)
	else
		button.icon.border:SetVertexColor(0, 0, 0)
	end
end
