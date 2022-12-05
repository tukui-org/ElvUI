local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local CH = E:GetModule('Chat')
local LSM = E.Libs.LSM

local _G = _G
local abs = abs
local unpack = unpack
local strjoin = strjoin
local strmatch = strmatch
local CreateFrame = CreateFrame
local UnitCanAttack = UnitCanAttack
local UnitName = UnitName

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local INTERRUPTED = INTERRUPTED

function NP:Castbar_CheckInterrupt(unit)
	if unit == 'vehicle' then
		unit = 'player'
	end

	if self.notInterruptible and UnitCanAttack('player', unit) then
		self:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b)

		if self.Icon and NP.db.colors.castbarDesaturate then
			self.Icon:SetDesaturated(true)
		end
	else
		self:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)

		if self.Icon then
			self.Icon:SetDesaturated(false)
		end
	end
end

function NP:Castbar_CustomDelayText(duration)
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

function NP:Castbar_CustomTimeText(duration)
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

function NP:Castbar_PostCastStart(unit)
	self:CheckInterrupt(unit)

	-- player or NPCs; if used on other players: the cast target doesn't match their target, can be misleading if they mouseover cast
	local plate = self.__owner
	local db = NP:PlateDB(plate)
	if db.castbar and db.castbar.enable and db.castbar.displayTarget then
		local frameType = plate.frameType
		if frameType == 'PLAYER' then
			if self.curTarget then
				self.Text:SetText(self.spellName..' > '..self.curTarget)
			end
		elseif frameType == 'ENEMY_NPC' or frameType == 'FRIENDLY_NPC' then
			local target = self.curTarget or UnitName(unit..'target')
			if target and target ~= '' and target ~= plate.unitName then
				self.Text:SetText(self.spellName..' > '..target)
			end
		end
	end
end

function NP:Castbar_PostCastFail()
	self:SetStatusBarColor(NP.db.colors.castInterruptedColor.r, NP.db.colors.castInterruptedColor.g, NP.db.colors.castInterruptedColor.b)
end

function NP:Castbar_PostCastInterruptible(unit)
	self:CheckInterrupt(unit)
end

function NP:Castbar_PostCastStop() end

function NP:Construct_Castbar(nameplate)
	local castbar = CreateFrame('StatusBar', nameplate:GetName()..'Castbar', nameplate)
	castbar:SetFrameStrata(nameplate:GetFrameStrata())
	castbar:SetFrameLevel(5)
	castbar:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)
	castbar:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))

	NP.StatusBars[castbar] = true

	castbar.Button = CreateFrame('Frame', nil, castbar)
	castbar.Button:SetTemplate(nil, nil, nil, nil, nil, true, true)

	castbar.Icon = castbar.Button:CreateTexture(nil, 'ARTWORK')
	castbar.Icon:SetTexCoord(unpack(E.TexCoords))
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

	castbar.CheckInterrupt = NP.Castbar_CheckInterrupt
	castbar.CustomDelayText = NP.Castbar_CustomDelayText
	castbar.CustomTimeText = NP.Castbar_CustomTimeText
	castbar.PostCastStart = NP.Castbar_PostCastStart
	castbar.PostCastFail = NP.Castbar_PostCastFail
	castbar.PostCastInterruptible = NP.Castbar_PostCastInterruptible
	castbar.PostCastStop = NP.Castbar_PostCastStop
	castbar.UpdatePipStep = UF.UpdatePipStep
	castbar.PostUpdatePip = UF.PostUpdatePip
	castbar.CreatePip = UF.CreatePip
	castbar.ModuleStatusBars = NP.StatusBars -- not oUF

	if nameplate == _G.ElvNP_Test then
		castbar.Hide = castbar.Show
		castbar:Show()
		castbar.Text:SetText('Casting')
		castbar.Time:SetText('3.1')
		castbar.Icon:SetTexture([[Interface\Icons\Achievement_Character_Pandaren_Female]])
		castbar:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)
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

					plate.Castbar.Text:SetFormattedText('%s > %s', INTERRUPTED, classColor and strjoin('', '|c', classColor, name) or name)
				else
					plate.Castbar.Text:SetFormattedText('%s > %s', INTERRUPTED, name)
				end
			end
		end
	end
end

function NP:Update_Castbar(nameplate)
	local frameDB = NP:PlateDB(nameplate)
	local db = frameDB.castbar

	local castbar = nameplate.Castbar
	if nameplate == _G.ElvNP_Test then
		castbar:SetAlpha((not frameDB.nameOnly and db.enable) and 1 or 0)
	end

	if db.enable then
		if not nameplate:IsElementEnabled('Castbar') then
			nameplate:EnableElement('Castbar')
		end

		castbar.timeToHold = db.timeToHold
		castbar.castTimeFormat = db.castTimeFormat
		castbar.channelTimeFormat = db.channelTimeFormat

		castbar:Size(db.width, db.height)
		castbar:Point('CENTER', nameplate, 'CENTER', db.xOffset, db.yOffset)

		castbar.pipColor = NP.db.colors.empoweredCast
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
