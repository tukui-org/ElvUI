local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local CH = E:GetModule('Chat')
local LSM = E.Libs.LSM

local abs = abs
local next = next
local strmatch = strmatch
local utf8sub = string.utf8sub

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CreateFrame = CreateFrame
local UnitCanAttack = UnitCanAttack
local UnitName = UnitName
local UnitNameFromGUID = UnitNameFromGUID

local StatusBarInterpolation = Enum.StatusBarInterpolation
local INTERRUPTED = INTERRUPTED

function NP:Castbar_CheckInterrupt(unit)
	if unit == 'vehicle' then
		unit = 'player'
	end

	local notInterruptible = E:NotSecretValue(self.notInterruptible) and self.notInterruptible
	if notInterruptible and UnitCanAttack('player', unit) then
		self:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b, NP.db.colors.castNoInterruptColor.a)

		if self.Icon and NP.db.colors.castbarDesaturate then
			self.Icon:SetDesaturated(true)
		end
	else
		self:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b, NP.db.colors.castColor.a)

		if self.Icon then
			self.Icon:SetDesaturated(false)
		end
	end
end

function NP:Castbar_CustomDelayText(duration, durationObject)
	if durationObject then
		local remain = durationObject:GetRemainingDuration()
		self.Time:SetFormattedText('%.1f', remain)

		return
	elseif not duration then
		return
	end

	if self.channeling then
		if self.channelTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%.1f |cffaf5050%.1f|r', abs(duration - self.max), self.delay)
		elseif self.channelTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%.1f|r', duration, self.max, self.delay)
		elseif self.channelTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%.1f |cffaf5050%.1f|r', duration, self.delay)
		elseif self.channelTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%.1f|r', abs(duration - self.max), self.max, self.delay)
		end
	else
		if self.castTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%.1f |cffaf5050%s %.1f|r', duration, '+', self.delay)
		elseif self.castTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%s %.1f|r', duration, self.max, '+', self.delay)
		elseif self.castTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%.1f |cffaf5050%s %.1f|r', abs(duration - self.max), '+', self.delay)
		elseif self.castTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%s %.1f|r', abs(duration - self.max), self.max, '+', self.delay)
		end
	end
end

function NP:Castbar_CustomTimeText(duration, durationObject)
	if durationObject then
		local remain = durationObject:GetRemainingDuration()
		self.Time:SetFormattedText('%.1f', remain)

		return
	elseif not duration then
		return
	end

	if self.channeling then
		if self.channelTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%.1f', abs(duration - self.max))
		elseif self.channelTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', abs(duration - self.max), self.max)
		elseif self.channelTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%.1f', duration)
		elseif self.channelTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', duration, self.max)
		end
	else
		if self.castTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%.1f', duration)
		elseif self.castTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', duration, self.max)
		elseif self.castTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%.1f', abs(duration - self.max))
		elseif self.castTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', abs(duration - self.max), self.max)
		end
	end
end

function NP:Castbar_SetText(castbar, db, changed, spellName, unit)
	local targetChanged
	if db.displayTarget then
		local plate = castbar.__owner
		local target, frameType = castbar.curTarget, plate.frameType
		if not target and (frameType == 'ENEMY_NPC' or frameType == 'FRIENDLY_NPC') then
			target = UnitName(unit..'target') -- player or NPCs; if used on other players:
		end -- the cast target doesn't match their target, can be misleading if they mouseover cast

		if E:NotSecretValue(target) and (target and target ~= '') and (E:NotSecretValue(plate.unitName) and (target ~= plate.unitName)) then
			local color = (db.displayTargetClass and UF:GetCasterColor(target)) or 'FFdddddd'
			if db.targetStyle == 'SEPARATE' then
				castbar.TargetText:SetFormattedText('|c%s%s|r', color, target)
				targetChanged = true

				if changed then
					castbar.Text:SetText(spellName)
				end
			else
				castbar.Text:SetFormattedText('%s: |c%s%s|r', spellName, color, target)
			end
		elseif changed then -- always true when secret
			castbar.Text:SetText(spellName)
		end
	elseif changed then
		castbar.Text:SetText(spellName)
	end

	return targetChanged
end

function NP:Castbar_PostCastStart(unit)
	self:CheckInterrupt(unit)

	local targetChanged
	local plate = self.__owner
	local db = NP:PlateDB(plate)
	if db.castbar and db.castbar.enable and not db.castbar.hideSpellName then
		local spellName = self.spellName
		if E:IsSecretValue(self.spellID) then
			targetChanged = NP:Castbar_SetText(self, db.castbar, true, spellName, unit)
		else
			local length = db.castbar.nameLength
			local name = (length and length > 0 and utf8sub(spellName, 1, length)) or spellName

			targetChanged = NP:Castbar_SetText(self, db.castbar, name ~= spellName, spellName, unit)
		end
	else
		self.Text:SetText('')
	end

	if not targetChanged then
		self.TargetText:SetText('')
	end
end

function NP:Castbar_PostCastFail()
	self:SetStatusBarColor(NP.db.colors.castInterruptedColor.r, NP.db.colors.castInterruptedColor.g, NP.db.colors.castInterruptedColor.b)
end

function NP:Castbar_PostCastInterruptible(unit)
	self:CheckInterrupt(unit)
end

function NP:Castbar_PostCastInterrupted(unit, spellID, interruptedBy)
	if not interruptedBy then return end

	local plate = self.__owner
	local db = NP:PlateDB(plate)
	if db.castbar and db.castbar.enable and db.castbar.sourceInterrupt and (db.castbar.timeToHold > 0) then
		local unitName = UnitNameFromGUID(interruptedBy)
		if unitName then
			self.Text:SetFormattedText('%s [%s]', INTERRUPTED, unitName)
		end
	end
end

function NP:Castbar_PostCastStop() end

function NP:BuildPip(stage)
	local pip = UF.CreatePip(self, stage)
	pip.texture:SetTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	return pip
end

function NP:Construct_Castbar(nameplate)
	local castbarTexture = LSM:Fetch('statusbar', NP.db.statusbar)

	local castbar = CreateFrame('StatusBar', '$parentCastbar', nameplate)
	castbar:SetFrameStrata(nameplate:GetFrameStrata())
	castbar:SetFrameLevel(5)
	castbar:CreateBackdrop('Transparent', nil, nil, nil, nil, true)
	castbar:SetStatusBarTexture(castbarTexture)

	NP.StatusBars[castbar] = 'castbar'
	castbar.ModuleStatusBars = NP.StatusBars -- not oUF

	castbar.Button = CreateFrame('Frame', nil, castbar)
	castbar.Button:SetTemplate(nil, nil, nil, nil, nil, true, true)

	castbar.Icon = castbar.Button:CreateTexture(nil, 'ARTWORK')
	castbar.Icon:SetTexCoords()
	castbar.Icon:SetInside()

	castbar.Time = castbar:CreateFontString(nil, 'OVERLAY')
	castbar.Time:FontTemplate(LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)
	castbar.Time:Point('RIGHT', castbar, 'RIGHT', -4, 0)
	castbar.Time:SetJustifyH('RIGHT')

	castbar.Text = castbar:CreateFontString(nil, 'OVERLAY')
	castbar.Text:FontTemplate(LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)
	castbar.Text:Point('LEFT', castbar, 'LEFT', 4, 0)
	castbar.Text:SetJustifyH('LEFT')
	castbar.Text:SetWordWrap(false)

	castbar.TargetText = castbar:CreateFontString(nil, 'OVERLAY')
	castbar.TargetText:FontTemplate(LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)
	castbar.TargetText:SetJustifyH('LEFT')

	castbar.Shield = castbar:CreateTexture(nil, 'OVERLAY', nil, 4)
	castbar.Shield:SetTexture(castbarTexture)
	castbar.Shield:SetAlpha(0) -- disable is so its hidden on classic

	castbar.CheckInterrupt = NP.Castbar_CheckInterrupt
	castbar.CustomDelayText = NP.Castbar_CustomDelayText
	castbar.CustomTimeText = NP.Castbar_CustomTimeText
	castbar.PostCastStart = NP.Castbar_PostCastStart
	castbar.PostCastFail = NP.Castbar_PostCastFail
	castbar.PostCastInterruptible = NP.Castbar_PostCastInterruptible
	castbar.PostCastInterrupted = NP.Castbar_PostCastInterrupted
	castbar.PostCastStop = NP.Castbar_PostCastStop
	castbar.UpdatePipStep = UF.UpdatePipStep
	castbar.PostUpdatePip = UF.PostUpdatePip
	castbar.CreatePip = NP.BuildPip

	if nameplate == NP.TestFrame then
		castbar.Hide = castbar.Show
		castbar:Show()
		castbar.Text:SetText('Casting')
		castbar.TargetText:SetText(E.myname)
		castbar.Time:SetText('3.1')
		castbar.Icon:SetTexture([[Interface\Icons\Achievement_Character_Pandaren_Female]])
		castbar:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b, NP.db.colors.castColor.a)
	end

	return castbar
end

function NP:COMBAT_LOG_EVENT_UNFILTERED()
	local _, event, _, sourceGUID, sourceName, _, _, targetGUID = CombatLogGetCurrentEventInfo()
	if (event == 'SPELL_INTERRUPT' or event == 'SPELL_PERIODIC_INTERRUPT') and targetGUID and (sourceName and sourceName ~= '') then
		local plate, classColor = NP.PlateGUID[targetGUID]
		if plate and plate.Castbar then
			local db = NP:PlateDB(plate)
			if db.castbar and db.castbar.enable and db.castbar.sourceInterrupt and (db.castbar.timeToHold > 0) then
				local name = strmatch(sourceName, '([^%-]+).*')
				if db.castbar.sourceInterruptClassColor then
					local data = CH:GetPlayerInfoByGUID(sourceGUID)
					if data and data.classColor then
						classColor = data.classColor.colorStr
					end

					plate.Castbar.Text:SetFormattedText('%s [|c%s%s|r]', INTERRUPTED, classColor or 'FFdddddd', name)
				else
					plate.Castbar.Text:SetFormattedText('%s [%s]', INTERRUPTED, name)
				end
			end
		end
	end
end

function NP:Update_Castbar(nameplate)
	local frameDB = NP:PlateDB(nameplate)
	local db = frameDB.castbar

	local castbar = nameplate.Castbar
	if nameplate == NP.TestFrame then
		castbar:SetAlpha((not frameDB.nameOnly and db.enable) and 1 or 0)
	end

	if db.enable then
		if not nameplate:IsElementEnabled('Castbar') then
			nameplate:EnableElement('Castbar')
		end

		castbar.timeToHold = db.timeToHold
		castbar.castTimeFormat = db.castTimeFormat
		castbar.channelTimeFormat = db.channelTimeFormat
		castbar.pipColor = NP.db.colors.empoweredCast

		castbar:ClearAllPoints()
		castbar:Point(E.InversePoints[db.anchorPoint], nameplate, db.anchorPoint, db.xOffset, db.yOffset)
		castbar:Size(db.width, db.height)

		if E.Retail then
			castbar.smoothing = (db.smoothbars and StatusBarInterpolation.ExponentialEaseOut) or StatusBarInterpolation.Immediate or nil
		else
			E:SetSmoothing(castbar, db.smoothbars)
		end

		for stage, pip in next, castbar.Pips do
			UF:CastBar_UpdatePip(castbar, pip, stage)
		end

		if db.showIcon then
			castbar.Button:ClearAllPoints()
			castbar.Button:Point(db.iconPosition == 'RIGHT' and 'BOTTOMLEFT' or 'BOTTOMRIGHT', castbar, db.iconPosition == 'RIGHT' and 'BOTTOMRIGHT' or 'BOTTOMLEFT', db.iconOffsetX, db.iconOffsetY)
			castbar.Button:Size(db.iconSize, db.iconSize)
			castbar.Button:Show()
		else
			castbar.Button:Hide()
		end

		if db.displayTarget and db.targetStyle == 'SEPARATE' then
			castbar.TargetText:ClearAllPoints()
			castbar.TargetText:Point(E.InversePoints[db.targetAnchorPoint], castbar, db.targetAnchorPoint, db.targetXOffset, db.targetYOffset)
			castbar.TargetText:FontTemplate(LSM:Fetch('font', db.targetFont), db.targetFontSize, db.targetFontOutline)
			castbar.TargetText:SetJustifyH(db.targetJustifyH)
			castbar.TargetText:Show()
		else
			castbar.TargetText:Hide()
		end

		castbar.Time:ClearAllPoints()
		castbar.Text:ClearAllPoints()

		if db.textPosition == 'BELOW' then
			castbar.Time:Point('TOPRIGHT', castbar, 'BOTTOMRIGHT', db.timeXOffset, db.timeYOffset)
			castbar.Text:Point('TOPLEFT', castbar, 'BOTTOMLEFT', db.textXOffset, db.textYOffset)
		elseif db.textPosition == 'ABOVE' then
			castbar.Time:Point('BOTTOMRIGHT', castbar, 'TOPRIGHT', db.timeXOffset, db.timeYOffset)
			castbar.Text:Point('BOTTOMLEFT', castbar, 'TOPLEFT', db.textXOffset, db.textYOffset)
		else
			castbar.Time:Point('RIGHT', castbar, 'RIGHT', db.timeXOffset, db.timeYOffset)
			castbar.Text:Point('LEFT', castbar, 'LEFT', db.textXOffset, db.textYOffset)
		end

		local barTexture = castbar:GetStatusBarTexture()
		castbar.Shield:SetVertexColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b, NP.db.colors.castNoInterruptColor.a)
		castbar.Shield:ClearAllPoints()
		castbar.Shield:Point('RIGHT', barTexture)
		castbar.Shield:Point('LEFT')
		castbar.Shield:Point('BOTTOM')
		castbar.Shield:Point('TOP')
		castbar.Shield.alphaValue = NP.db.colors.castNoInterruptColor.a

		if db.hideTime then
			castbar.Time:Hide()
		else
			castbar.Time:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
			castbar.Time:Show()
		end

		if db.hideSpellName then
			castbar.Text:Hide()
		else
			castbar.Text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
			castbar.Text:Show()
		end
	elseif nameplate:IsElementEnabled('Castbar') then
		nameplate:DisableElement('Castbar')
	end
end
