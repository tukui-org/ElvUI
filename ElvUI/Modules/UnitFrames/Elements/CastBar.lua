local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local unpack, tonumber, abs = unpack, tonumber, abs

local CreateFrame = CreateFrame
local UnitSpellHaste = UnitSpellHaste
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitCanAttack = UnitCanAttack
local GetTalentInfo = GetTalentInfo

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, 'ElvUI was unable to locate oUF.')

local INVERT_ANCHORPOINT = {
	TOPLEFT = 'BOTTOMRIGHT',
	LEFT = 'RIGHT',
	BOTTOMLEFT = 'TOPRIGHT',
	RIGHT = 'LEFT',
	TOPRIGHT = 'BOTTOMLEFT',
	BOTTOMRIGHT = 'TOPLEFT',
	CENTER = 'CENTER',
	TOP = 'BOTTOM',
	BOTTOM = 'TOP',
}

local ticks = {}

function UF:Construct_Castbar(frame, moverName)
	local castbar = CreateFrame('StatusBar', '$parent_CastBar', frame)
	castbar:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 30) --Make it appear above everything else
	UF.statusbars[castbar] = true
	castbar.CustomDelayText = UF.CustomCastDelayText
	castbar.CustomTimeText = UF.CustomTimeText
	castbar.PostCastStart = UF.PostCastStart
	castbar.PostCastStop = UF.PostCastStop
	castbar.PostCastInterruptible = UF.PostCastInterruptible
	castbar.PostCastFail = UF.PostCastFail
	castbar:SetClampedToScreen(true)
	castbar:CreateBackdrop(nil, nil, nil, nil, true)

	castbar.Time = castbar:CreateFontString(nil, 'OVERLAY')
	castbar.Time:Point('RIGHT', castbar, 'RIGHT', -4, 0)
	castbar.Time:SetTextColor(0.84, 0.75, 0.65)
	castbar.Time:SetJustifyH('RIGHT')
	castbar.Time:FontTemplate()

	castbar.Text = castbar:CreateFontString(nil, 'OVERLAY')
	castbar.Text:Point('LEFT', castbar, 'LEFT', 4, 0)
	castbar.Text:Point('RIGHT', castbar.Time, 'LEFT', -4, 0)
	castbar.Text:SetTextColor(0.84, 0.75, 0.65)
	castbar.Text:SetJustifyH('LEFT')
	castbar.Text:SetWordWrap(false)
	castbar.Text:FontTemplate()

	castbar.Spark_ = castbar:CreateTexture(nil, 'OVERLAY')
	castbar.Spark_:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	castbar.Spark_:SetBlendMode('ADD')
	castbar.Spark_:SetVertexColor(1, 1, 1)
	castbar.Spark_:Size(20, 40)

	--Set to castbar.SafeZone
	castbar.LatencyTexture = castbar:CreateTexture(nil, 'OVERLAY')
	castbar.LatencyTexture:SetTexture(E.media.blankTex)
	castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)

	castbar.bg = castbar:CreateTexture(nil, 'BORDER')
	castbar.bg:SetAllPoints()
	castbar.bg:SetTexture(E.media.blankTex)
	castbar.bg:Show()

	local button = CreateFrame('Frame', nil, castbar)
	local holder = CreateFrame('Frame', nil, castbar)
	button:SetTemplate(nil, nil, nil, nil, true)

	castbar.Holder = holder
	--these are placeholder so the mover can be created.. it will be changed.
	castbar.Holder:Point('TOPLEFT', frame, 'BOTTOMLEFT', 0, -(UF.BORDER - UF.SPACING))
	castbar:Point('BOTTOMLEFT', castbar.Holder, 'BOTTOMLEFT', UF.BORDER, UF.BORDER)
	button:Point('RIGHT', castbar, 'LEFT', -UF.SPACING*3, 0)

	if moverName then
		local name = frame:GetName()
		local configName = name:gsub('^ElvUF_', ''):lower()
		E:CreateMover(castbar.Holder, name..'CastbarMover', moverName, nil, -6, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,'..configName..',castbar')
	end

	local icon = button:CreateTexture(nil, 'ARTWORK')
	icon:SetInside(nil, UF.BORDER, UF.BORDER)
	icon.bg = button

	--Set to castbar.Icon
	castbar.ButtonIcon = icon

	return castbar
end

function UF:Configure_Castbar(frame)
	local castbar = frame.Castbar
	local db = frame.db.castbar

	castbar:Width(db.width - ((UF.BORDER+UF.SPACING)*2))
	castbar:Height(db.height - ((UF.BORDER+UF.SPACING)*2))
	castbar.Holder:Size(db.width, db.height)

	local oSC = castbar.Holder:GetScript('OnSizeChanged')
	if oSC then oSC(castbar.Holder) end

	if db.strataAndLevel and db.strataAndLevel.useCustomStrata then
		castbar:SetFrameStrata(db.strataAndLevel.frameStrata)
	end

	if db.strataAndLevel and db.strataAndLevel.useCustomLevel then
		castbar:SetFrameLevel(db.strataAndLevel.frameLevel)
	end

	castbar.timeToHold = db.timeToHold

	castbar:SetReverseFill(db.reverse)

	--Latency
	if frame.unit == 'player' and db.latency then
		castbar.SafeZone = castbar.LatencyTexture
		castbar.LatencyTexture:Show()
	else
		castbar.SafeZone = nil
		castbar.LatencyTexture:Hide()
	end

	--Font Options
	local customFont = db.customTextFont
	if customFont.enable then
		castbar.Text:FontTemplate(LSM:Fetch('font', customFont.font), customFont.fontSize, customFont.fontStyle)
	else
		UF:Update_FontString(castbar.Text)
	end

	customFont = db.customTimeFont
	if customFont.enable then
		castbar.Time:FontTemplate(LSM:Fetch('font', customFont.font), customFont.fontSize, customFont.fontStyle)
	else
		UF:Update_FontString(castbar.Time)
	end

	local textColor = db.textColor
	castbar.Text:SetTextColor(textColor.r, textColor.g, textColor.b)
	castbar.Time:SetTextColor(textColor.r, textColor.g, textColor.b)

	castbar.Text:Point('LEFT', castbar, 'LEFT', db.xOffsetText, db.yOffsetText)
	castbar.Time:Point('RIGHT', castbar, 'RIGHT', db.xOffsetTime, db.yOffsetTime)

	castbar.Text:SetWidth(castbar.Text:GetStringWidth())
	castbar.Time:SetWidth(castbar.Time:GetStringWidth())

	--Icon
	if db.icon then
		castbar.Icon = castbar.ButtonIcon
		castbar.Icon:SetTexCoord(unpack(E.TexCoords))

		if not db.iconAttached then
			castbar.Icon.bg:Size(db.iconSize)
		else
			castbar.Icon.bg:Size(db.height-UF.SPACING*2)
			castbar:Width(db.width - castbar.Icon.bg:GetWidth() - (UF.BORDER + UF.SPACING*5))
		end

		castbar.Icon.bg:Show()
	else
		castbar.ButtonIcon.bg:Hide()
		castbar.Icon = nil
	end

	if db.spark then
		castbar.Spark = castbar.Spark_
		castbar.Spark:Point('CENTER', castbar:GetStatusBarTexture(), db.reverse and 'LEFT' or 'RIGHT', 0, 0)
		castbar.Spark:Height(db.height * 2)
	elseif castbar.Spark then
		castbar.Spark:Hide()
		castbar.Spark = nil
	end

	if db.hidetext then
		castbar.Text:SetAlpha(0)
		castbar.Time:SetAlpha(0)
	else
		castbar.Text:SetAlpha(1)
		castbar.Time:SetAlpha(1)
	end

	castbar:ClearAllPoints()

	if db.overlayOnFrame ~= 'None' then
		local anchor = frame[db.overlayOnFrame]

		if not db.iconAttached then
			castbar:SetInside(anchor, 0, 0)
		else
			if castbar.Icon then
				castbar.Icon.bg:Size(anchor:GetHeight() - UF.SPACING*2)
			end

			local iconWidth = db.icon and (castbar.Icon.bg:GetWidth() - UF.BORDER) or 0
			if frame.ORIENTATION == 'RIGHT' then
				castbar:Point('TOPLEFT', anchor, 'TOPLEFT')
				castbar:Point('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', -iconWidth - UF.SPACING*3, 0)
			else
				castbar:Point('TOPLEFT', anchor, 'TOPLEFT', iconWidth + UF.SPACING*3, 0)
				castbar:Point('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT')
			end
		end

		if db.spark then
			castbar.Spark:Height(anchor:GetHeight() * 2)
		end
	else
		if db.positionsGroup then
			castbar.Holder:ClearAllPoints()
			castbar.Holder:Point(INVERT_ANCHORPOINT[db.positionsGroup.anchorPoint], frame, db.positionsGroup.anchorPoint, db.positionsGroup.xOffset, db.positionsGroup.yOffset)
		end

		if frame.ORIENTATION ~= 'RIGHT' then
			castbar:Point('BOTTOMRIGHT', castbar.Holder, 'BOTTOMRIGHT', -(UF.BORDER+UF.SPACING), UF.BORDER+UF.SPACING)
		else
			castbar:Point('BOTTOMLEFT', castbar.Holder, 'BOTTOMLEFT', UF.BORDER+UF.SPACING, UF.BORDER+UF.SPACING)
		end
	end

	if not db.iconAttached and db.icon then
		local attachPoint = db.iconAttachedTo == 'Frame' and frame or frame.Castbar
		local anchorPoint = db.iconPosition
		castbar.Icon.bg:ClearAllPoints()
		castbar.Icon.bg:Point(INVERT_ANCHORPOINT[anchorPoint], attachPoint, anchorPoint, db.iconXOffset, db.iconYOffset)
	elseif db.icon then
		castbar.Icon.bg:ClearAllPoints()
		if frame.ORIENTATION == 'RIGHT' then
			castbar.Icon.bg:Point('LEFT', castbar, 'RIGHT', UF.SPACING*3, 0)
		else
			castbar.Icon.bg:Point('RIGHT', castbar, 'LEFT', -UF.SPACING*3, 0)
		end
	end

	--Adjust tick heights
	castbar.tickHeight = castbar:GetHeight()

	if db.ticks then --Only player unitframe has this
		--Set tick width and color
		castbar.tickWidth = db.tickWidth
		castbar.tickColor = db.tickColor

		for i = 1, #ticks do
			ticks[i]:SetVertexColor(castbar.tickColor.r, castbar.tickColor.g, castbar.tickColor.b, castbar.tickColor.a)
			ticks[i]:Width(castbar.tickWidth)
		end
	end

	if db.customColor and db.customColor.enable then
		castbar.custom_backdrop = db.customColor.useCustomBackdrop and db.customColor.colorBackdrop
		UF:ToggleTransparentStatusBar(db.customColor.transparent, castbar, castbar.bg, nil, db.customColor.invertColors)
	else
		castbar.custom_backdrop = UF.db.colors.customcastbarbackdrop and UF.db.colors.castbar_backdrop
		UF:ToggleTransparentStatusBar(UF.db.colors.transparentCastbar, castbar, castbar.bg, nil, UF.db.colors.invertCastbar)
	end

	if castbar.Holder.mover then
		if db.overlayOnFrame ~= 'None' or not db.enable then
			E:DisableMover(castbar.Holder.mover:GetName())
		else
			E:EnableMover(castbar.Holder.mover:GetName())
		end
	end

	if db.enable and not frame:IsElementEnabled('Castbar') then
		frame:EnableElement('Castbar')
	elseif not db.enable and frame:IsElementEnabled('Castbar') then
		frame:DisableElement('Castbar')
	end
end

function UF:CustomCastDelayText(duration)
	local db = self:GetParent().db
	if not (db and db.castbar) then return end
	db = db.castbar.format

	if self.channeling then
		if db == 'CURRENT' then
			self.Time:SetFormattedText('%.1f |cffaf5050%.1f|r', abs(duration - self.max), self.delay)
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%.1f|r', duration, self.max, self.delay)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText('%.1f |cffaf5050%.1f|r', duration, self.delay)
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%.1f|r', abs(duration - self.max), self.max, self.delay)
		end
	else
		if db == 'CURRENT' then
			self.Time:SetFormattedText('%.1f |cffaf5050%s %.1f|r', duration, '+', self.delay)
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%s %.1f|r', duration, self.max, '+', self.delay)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText('%.1f |cffaf5050%s %.1f|r', abs(duration - self.max), '+', self.delay)
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%s %.1f|r', abs(duration - self.max), self.max, '+', self.delay)
		end
	end

	self.Time:SetWidth(self.Time:GetStringWidth())
end

function UF:CustomTimeText(duration)
	local db = self:GetParent().db
	if not (db and db.castbar) then return end
	db = db.castbar.format

	if self.channeling then
		if db == 'CURRENT' then
			self.Time:SetFormattedText('%.1f', abs(duration - self.max))
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', abs(duration - self.max), self.max)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText('%.1f', duration)
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', duration, self.max)
		end
	else
		if db == 'CURRENT' then
			self.Time:SetFormattedText('%.1f', duration)
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', duration, self.max)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText('%.1f', abs(duration - self.max))
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', abs(duration - self.max), self.max)
		end
	end

	self.Time:SetWidth(self.Time:GetStringWidth())
end

function UF:HideTicks()
	for i=1, #ticks do
		ticks[i]:Hide()
	end
end

function UF:SetCastTicks(frame, numTicks, extraTickRatio)
	extraTickRatio = extraTickRatio or 0
	UF:HideTicks()

	if numTicks and numTicks <= 0 then return end

	local w = frame:GetWidth()
	local d = w / (numTicks + extraTickRatio)

	for i = 1, numTicks - 1 do
		if not ticks[i] then
			ticks[i] = frame:CreateTexture(nil, 'OVERLAY')
			ticks[i]:SetTexture(E.media.normTex)
			ticks[i]:SetVertexColor(frame.tickColor.r, frame.tickColor.g, frame.tickColor.b, frame.tickColor.a)
			ticks[i]:Width(frame.tickWidth)
		end

		ticks[i]:ClearAllPoints()
		ticks[i]:Point('RIGHT', frame, 'LEFT', d * i, 0)
		ticks[i]:Height(frame.tickHeight)
		ticks[i]:Show()
	end
end

function UF:GetTalentTicks(info)
	local _, _, _, selected = GetTalentInfo(info.tier, info.column, 1)
	return selected and info.ticks
end

function UF:GetInterruptColor(db, unit)
	local colors = ElvUF.colors
	local customColor = db and db.castbar and db.castbar.customColor
	local custom, r, g, b = customColor and customColor.enable and customColor, colors.castColor[1], colors.castColor[2], colors.castColor[3]

	if self.notInterruptible and (UnitIsPlayer(unit) or (unit ~= 'player' and UnitCanAttack('player', unit))) then
		if custom and custom.colorNoInterrupt then
			return custom.colorNoInterrupt.r, custom.colorNoInterrupt.g, custom.colorNoInterrupt.b
		else
			return colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
		end
	elseif ((custom and custom.useClassColor) or (not custom and UF.db.colors.castClassColor)) and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and colors.class[Class]
		if t then return t[1], t[2], t[3] end
	elseif (custom and custom.useReactionColor) or (not custom and UF.db.colors.castReactionColor) then
		local Reaction = UnitReaction(unit, 'player')
		local t = Reaction and colors.reaction[Reaction]
		if t then return t[1], t[2], t[3] end
	elseif custom then
		return customColor.color.r, customColor.color.g, customColor.color.b
	end

	return r, g, b
end

function UF:PostCastStart(unit)
	local db = self:GetParent().db
	if not db or not db.castbar then return end

	if unit == 'vehicle' then unit = 'player' end

	self.unit = unit

	if db.castbar.displayTarget and self.curTarget then
		self.Text:SetText(self.spellName..' > '..self.curTarget)
	end

	if self.channeling and db.castbar.ticks and unit == 'player' then
		local unitframe = E.global.unitframe
		local baseTicks = unitframe.ChannelTicks[self.spellID]
		local ticksSize = baseTicks and unitframe.ChannelTicksSize[self.spellID]
		local hasteTicks = ticksSize and unitframe.HastedChannelTicks[self.spellID]
		local talentTicks = baseTicks and unitframe.TalentChannelTicks[self.spellID]

		-- Separate group, so they can be effected by haste or size if needed
		if talentTicks then
			local selectedTicks = UF:GetTalentTicks(talentTicks)
			if selectedTicks then
				baseTicks = selectedTicks
			end
		end

		-- hasteTicks require a tickSize
		if hasteTicks then
			local tickIncRate = 1 / baseTicks
			local curHaste = UnitSpellHaste('player') * 0.01
			local firstTickInc = tickIncRate / 2
			local bonusTicks = 0
			if curHaste >= firstTickInc then
				bonusTicks = bonusTicks + 1
			end

			local x = tonumber(E:Round(firstTickInc + tickIncRate, 2))
			while curHaste >= x do
				x = tonumber(E:Round(firstTickInc + (tickIncRate * bonusTicks), 2))
				if curHaste >= x then
					bonusTicks = bonusTicks + 1
				end
			end

			local baseTickSize = ticksSize
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			local extraTickRatio = extraTick / hastedTickSize
			UF:SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
			self.hadTicks = true
		elseif ticksSize then
			local curHaste = UnitSpellHaste('player') * 0.01
			local baseTickSize = ticksSize
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			local extraTickRatio = extraTick / hastedTickSize

			UF:SetCastTicks(self, baseTicks, extraTickRatio)
			self.hadTicks = true
		elseif baseTicks then
			UF:SetCastTicks(self, baseTicks)
			self.hadTicks = true
		else
			UF:HideTicks()
		end
	end

	if self.SafeZone then
		self.SafeZone:Show()
	end

	self:SetStatusBarColor(UF.GetInterruptColor(self, db, unit))
end

function UF:PostCastStop(unit)
	if self.hadTicks and unit == 'player' then
		UF:HideTicks()
		self.hadTicks = false
	end
end

function UF:PostCastFail()
	local db = self:GetParent().db
	local customColor = db and db.castbar and db.castbar.customColor
	local color = (customColor and customColor.enable and customColor.colorInterrupted) or UF.db.colors.castInterruptedColor
	self:SetStatusBarColor(color.r, color.g, color.b)

	if self.SafeZone then
		self.SafeZone:Hide()
	end
end

function UF:PostCastInterruptible(unit)
	if unit == 'vehicle' or unit == 'player' then return end

	local db = self:GetParent().db
	if not db or not db.castbar then return end

	self:SetStatusBarColor(UF.GetInterruptColor(self, db, unit))
end
