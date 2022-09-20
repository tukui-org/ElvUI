local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local unpack = unpack
local CreateFrame = CreateFrame

function UF:Construct_AuraWatch(frame)
	local auras = CreateFrame('Frame', frame:GetName() .. 'AuraWatch', frame)
	auras:SetFrameLevel(frame.RaisedElementParent.AuraWatchLevel)
	auras:SetInside(frame.Health)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.strictMatching = true
	auras.PostCreateIcon = UF.BuffIndicator_PostCreateIcon
	auras.PostUpdateIcon = UF.BuffIndicator_PostUpdateIcon

	return auras
end

function UF:Configure_AuraWatch(frame, isPet)
	local db = frame.db.buffIndicator
	if db and db.enable then
		if not frame:IsElementEnabled('AuraWatch') then
			frame:EnableElement('AuraWatch')
		end

		frame.AuraWatch.size = db.size
		frame.AuraWatch.countFontSize = db.countFontSize

		if frame.unit == 'pet' or isPet then
			frame.AuraWatch:SetNewTable(E.global.unitframe.aurawatch.PET)
		else
			local auraTable
			if db.profileSpecific then
				auraTable = E.db.unitframe.filters.aurawatch
			else
				auraTable = E.Filters.Expand({}, E.global.unitframe.aurawatch[E.myclass])
				E:CopyTable(auraTable, E.global.unitframe.aurawatch.GLOBAL)
			end
			frame.AuraWatch:SetNewTable(auraTable)
		end
	elseif frame:IsElementEnabled('AuraWatch') then
		frame:DisableElement('AuraWatch')
	end
end

function UF:BuffIndicator_PostCreateIcon(button)
	button.cd.CooldownOverride = 'unitframe'
	button.cd.skipScale = true

	E:RegisterCooldown(button.cd)

	local blizzCooldownText = button.cd:GetRegions()
	if blizzCooldownText:IsObjectType('FontString') then
		button.cd.blizzText = blizzCooldownText
	end

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
	if settings then -- This should never fail.
		local onlyText = settings.style == 'timerOnly'
		local colorIcon = settings.style == 'coloredIcon'
		local textureIcon = settings.style == 'texturedIcon'

		if (colorIcon or textureIcon) and not button.icon:IsShown() then
			button.icon:Show()
			button.icon.border:Show()
			button.cd:SetDrawSwipe(true)
		elseif onlyText and button.icon:IsShown() then
			button.icon:Hide()
			button.icon.border:Hide()
			button.cd:SetDrawSwipe(false)
		end

		if not E.db.cooldown.enable then -- cooldown module is off, handle blizzards cooldowns
			if onlyText then
				button.cd:SetHideCountdownNumbers(false)

				if button.cd.blizzText then
					button.cd.blizzText:SetTextColor(settings.color.r, settings.color.g, settings.color.b)
				end
			else
				button.cd:SetHideCountdownNumbers(not settings.displayText)

				if button.cd.blizzText then
					button.cd.blizzText:SetTextColor(1, 1, 1)
				end
			end
		elseif button.cd.timer then
			button.cd.textThreshold = settings.textThreshold ~= -1 and settings.textThreshold
			button.cd.hideText = (not onlyText and not settings.displayText) or nil
			button.cd.timer.skipTextColor = onlyText or nil

			if onlyText and button.cd.timer.text then
				button.cd.timer.text:SetTextColor(settings.color.r, settings.color.g, settings.color.b)
			end
		end

		if colorIcon then
			button.icon:SetTexture(E.media.blankTex)
			button.icon:SetVertexColor(settings.color.r, settings.color.g, settings.color.b, settings.color.a)
		elseif textureIcon then
			button.icon:SetVertexColor(1, 1, 1)
			button.icon:SetTexCoord(unpack(E.TexCoords))
		end

		button.count:ClearAllPoints()
		button.count:Point(settings.countAnchor or 'BOTTOMRIGHT', settings.countX or 1, settings.countY or 1)
		button.count:FontTemplate(nil, self.countFontSize or 12, 'OUTLINE')

		if textureIcon and button.filter == 'HARMFUL' then
			button.icon.border:SetVertexColor(1, 0, 0)
		else
			button.icon.border:SetVertexColor(0, 0, 0)
		end
	end
end
