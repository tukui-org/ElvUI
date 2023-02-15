local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM
local ElvUF = E.oUF

local abs, next = abs, next
local unpack = unpack

local GetTime = GetTime
local CreateFrame = CreateFrame
local GetTalentInfo = GetTalentInfo
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitName = UnitName
local UnitReaction = UnitReaction
local UnitSpellHaste = UnitSpellHaste

local ticks = {}

do
	local pipMapColor = {4, 1, 2, 3}
	function UF:CastBar_UpdatePip(castbar, pip, stage)
		if castbar.pipColor then
			local color = castbar.pipColor[pipMapColor[stage]]
			pip.texture:SetVertexColor(color.r, color.g, color.b, pip.pipAlpha)
		end
	end

	local pipMapAlpha = {2, 3, 4, 1}
	function UF:UpdatePipStep(stage) -- self is element
		local onlyThree = (stage == 3 and self.numStages == 3) and 4
		local pip = self.Pips[pipMapAlpha[onlyThree or stage]]
		if not pip then return end

		pip.texture:SetAlpha(1)
		E:UIFrameFadeOut(pip.texture, pip.pipTimer, pip.pipStart, pip.pipFaded)
	end
end

function UF:PostUpdatePip(pip, stage) -- self is element
	pip.texture:SetAlpha(pip.pipAlpha or 1)

	local pips = self.Pips
	local numStages = self.numStages
	local reverse = self:GetReverseFill()

	if stage == numStages then
		local firstPip = pips[1]
		local anchor = pips[numStages]
		if reverse then
			firstPip.texture:Point('RIGHT', self, 'LEFT', 0, 0)
			firstPip.texture:Point('LEFT', anchor, 3, 0)
		else
			firstPip.texture:Point('LEFT', self, 'RIGHT', 0, 0)
			firstPip.texture:Point('RIGHT', anchor, -3, 0)
		end
	end

	if stage ~= 1 then
		local anchor = pips[stage - 1]
		if reverse then
			pip.texture:Point('RIGHT', -3, 0)
			pip.texture:Point('LEFT', anchor, 3, 0)
		else
			pip.texture:Point('LEFT', 3, 0)
			pip.texture:Point('RIGHT', anchor, -3, 0)
		end
	end
end

function UF:CreatePip(stage)
	local pip = CreateFrame('Frame', nil, self, 'CastingBarFrameStagePipTemplate')

	-- clear the original art (the line)
	pip.BasePip:SetAlpha(0)

	-- create the texture
	pip.texture = pip:CreateTexture(nil, 'ARTWORK', nil, 2)
	pip.texture:Point('BOTTOM')
	pip.texture:Point('TOP')

	-- values for the animation
	pip.pipStart = 1.0 -- alpha on hit
	pip.pipAlpha = 0.3 -- alpha on init
	pip.pipFaded = 0.6 -- alpha when passed
	pip.pipTimer = 0.4 -- fading time to passed

	-- self is the castbar
	if self.ModuleStatusBars then
		self.ModuleStatusBars[pip.texture] = true
	end

	-- update colors
	UF:CastBar_UpdatePip(self, pip, stage)

	return pip
end

function UF:BuildPip(stage)
	local pip = UF.CreatePip(self, stage)
	UF:Update_StatusBar(pip.texture)
	return pip
end

function UF:Construct_Castbar(frame, moverName)
	local castbar = CreateFrame('StatusBar', '$parent_CastBar', frame)
	castbar:SetFrameLevel(frame.RaisedElementParent.CastBarLevel)

	UF.statusbars[castbar] = true
	castbar.ModuleStatusBars = UF.statusbars -- not oUF

	castbar.CustomDelayText = UF.CustomCastDelayText
	castbar.CustomTimeText = UF.CustomTimeText
	castbar.PostCastStart = UF.PostCastStart
	castbar.PostCastStop = UF.PostCastStop
	castbar.PostCastInterruptible = UF.PostCastInterruptible
	castbar.PostCastFail = UF.PostCastFail
	castbar.UpdatePipStep = UF.UpdatePipStep
	castbar.PostUpdatePip = UF.PostUpdatePip
	castbar.CreatePip = UF.BuildPip

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

	castbar.Spark_ = castbar:CreateTexture(nil, 'OVERLAY', nil, 3)
	castbar.Spark_:SetTexture(E.media.blankTex)
	castbar.Spark_:SetVertexColor(0.9, 0.9, 0.9, 0.6)
	castbar.Spark_:SetBlendMode('ADD')
	castbar.Spark_:Width(2)

	--Set to castbar.SafeZone
	castbar.LatencyTexture = castbar:CreateTexture(nil, 'OVERLAY', nil, 2)
	castbar.LatencyTexture:SetTexture(E.media.blankTex)
	castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)

	castbar.bg = castbar:CreateTexture(nil, 'BORDER')
	castbar.bg:SetTexture(E.media.blankTex)
	castbar.bg:SetAllPoints()
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

	local SPACING1 = UF.BORDER + UF.SPACING
	local SPACING2 = SPACING1 * 2

	castbar.timeToHold = db.timeToHold
	castbar:SetReverseFill(db.reverse)
	castbar:ClearAllPoints()

	castbar.Holder:Size(db.width, db.height)
	local oSC = castbar.Holder:GetScript('OnSizeChanged')
	if oSC then oSC(castbar.Holder) end

	if db.strataAndLevel and db.strataAndLevel.useCustomStrata then
		castbar:SetFrameStrata(db.strataAndLevel.frameStrata)
	end

	if db.strataAndLevel and db.strataAndLevel.useCustomLevel then
		castbar:SetFrameLevel(db.strataAndLevel.frameLevel)
	end

	--Empowered
	castbar.pipColor = UF.db.colors.empoweredCast
	for stage, pip in next, castbar.Pips do
		UF:CastBar_UpdatePip(castbar, pip, stage)
	end

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

	local textColor = E:UpdateClassColor(db.textColor)
	castbar.Text:SetTextColor(textColor.r, textColor.g, textColor.b)
	castbar.Time:SetTextColor(textColor.r, textColor.g, textColor.b)

	castbar.Text:Point('LEFT', castbar, 'LEFT', db.xOffsetText, db.yOffsetText)
	castbar.Time:Point('RIGHT', castbar, 'RIGHT', db.xOffsetTime, db.yOffsetTime)

	castbar.Text:SetWidth(castbar.Text:GetStringWidth())
	castbar.Time:SetWidth(castbar.Time:GetStringWidth())

	if db.spark then
		castbar.Spark = castbar.Spark_
		castbar.Spark:ClearAllPoints()
		castbar.Spark:Point(db.reverse and 'LEFT' or 'RIGHT', castbar:GetStatusBarTexture())
		castbar.Spark:Point('BOTTOM')
		castbar.Spark:Point('TOP')
	elseif castbar.Spark then
		castbar.Spark:Hide()
		castbar.Spark = nil
	end

	local height
	if db.overlayOnFrame == 'None' then
		height = db.height

		if db.positionsGroup then
			castbar.Holder:ClearAllPoints()
			castbar.Holder:Point(E.InverseAnchors[db.positionsGroup.anchorPoint], frame, db.positionsGroup.anchorPoint, db.positionsGroup.xOffset, db.positionsGroup.yOffset)
		end

		local iconWidth = db.icon and db.iconAttached and (height + UF.BORDER) or SPACING1
		if frame.ORIENTATION == 'RIGHT' then
			castbar:Point('BOTTOMRIGHT', castbar.Holder, -iconWidth, SPACING1)
		else
			castbar:Point('BOTTOMLEFT', castbar.Holder, iconWidth, SPACING1)
		end

		castbar:Size(db.width - iconWidth - SPACING1, db.height - SPACING2)
	else
		local anchor = frame[db.overlayOnFrame]
		height = anchor:GetHeight()

		if not db.iconAttached then
			castbar:SetAllPoints(anchor)
		else
			local iconWidth = db.icon and (height + SPACING2 - 1) or 0
			if frame.ORIENTATION == 'RIGHT' then
				castbar:Point('TOPLEFT', anchor, 'TOPLEFT')
				castbar:Point('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', -iconWidth, 0)
			else
				castbar:Point('TOPLEFT', anchor, 'TOPLEFT', iconWidth, 0)
				castbar:Point('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT')
			end
		end

		castbar:Size(db.width - SPACING2, db.height - SPACING2)
	end

	--Icon
	if db.icon then
		castbar.Icon = castbar.ButtonIcon
		castbar.Icon:SetTexCoord(unpack(E.TexCoords))

		if db.overlayOnFrame == 'None' then
			castbar.Icon.bg:Size(db.iconAttached and (height - UF.SPACING*2) or db.iconSize)
		else
			castbar.Icon.bg:Size(db.iconAttached and (height + UF.BORDER*2) or db.iconSize)
		end

		castbar.Icon.bg:ClearAllPoints()
		castbar.Icon.bg:Show()

		if not db.iconAttached then
			local attachPoint = db.iconAttachedTo == 'Frame' and frame or frame.Castbar
			castbar.Icon.bg:Point(E.InverseAnchors[db.iconPosition], attachPoint, db.iconPosition, db.iconXOffset, db.iconYOffset)
		elseif frame.ORIENTATION == 'RIGHT' then
			castbar.Icon.bg:Point('LEFT', castbar, 'RIGHT', (UF.thinBorders and 0 or 3), 0)
		else
			castbar.Icon.bg:Point('RIGHT', castbar, 'LEFT', -(UF.thinBorders and 0 or 3), 0)
		end
	else
		castbar.ButtonIcon.bg:Hide()
		castbar.Icon = nil
	end

	if db.hidetext then
		castbar.Text:SetAlpha(0)
		castbar.Time:SetAlpha(0)
	else
		castbar.Text:SetAlpha(1)
		castbar.Time:SetAlpha(1)
	end

	--Adjust tick heights
	castbar.tickHeight = height

	if db.ticks then --Only player unitframe has this
		--Set tick width and color
		castbar.tickWidth = db.tickWidth
		castbar.tickColor = db.tickColor

		for _, tick in next, ticks do
			tick:SetVertexColor(castbar.tickColor.r, castbar.tickColor.g, castbar.tickColor.b, castbar.tickColor.a)
			tick:Width(castbar.tickWidth)
		end
	end

	local customColor = db.customColor
	if customColor and customColor.enable then
		E:UpdateClassColor(customColor.color)
		E:UpdateClassColor(customColor.colorNoInterrupt)
		E:UpdateClassColor(customColor.colorInterrupted)

		castbar.custom_backdrop = customColor.useCustomBackdrop and E:UpdateClassColor(customColor.colorBackdrop)
		UF:ToggleTransparentStatusBar(customColor.transparent, castbar, castbar.bg, nil, customColor.invertColors, db.reverse)
	else
		castbar.custom_backdrop = UF.db.colors.customcastbarbackdrop and E:UpdateClassColor(UF.db.colors.castbar_backdrop)
		UF:ToggleTransparentStatusBar(UF.db.colors.transparentCastbar, castbar, castbar.bg, nil, UF.db.colors.invertCastbar, db.reverse)
	end

	if castbar.Holder.mover then
		if db.overlayOnFrame ~= 'None' or not db.enable then
			E:DisableMover(castbar.Holder.mover.name)
		else
			E:EnableMover(castbar.Holder.mover.name)
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
	for _, tick in next, ticks do
		tick:Hide()
	end
end

function UF:SetCastTicks(frame, numTicks)
	UF:HideTicks()

	if numTicks and numTicks <= 0 then return end

	local offset = frame:GetWidth() / numTicks

	for i = 1, numTicks - 1 do
		local tick = ticks[i]
		if not tick then
			tick = frame:CreateTexture(nil, 'OVERLAY')
			tick:SetTexture(E.media.blankTex)
			tick:Width(frame.tickWidth)
			ticks[i] = tick
		end

		tick:SetVertexColor(frame.tickColor.r, frame.tickColor.g, frame.tickColor.b, frame.tickColor.a)
		tick:ClearAllPoints()
		tick:Point('RIGHT', frame, 'LEFT', offset * i, 0)
		tick:Height(frame.tickHeight)
		tick:Show()
	end
end

function UF:GetTalentTicks(info)
	local _, _, _, selected = GetTalentInfo(info.tier, info.column, 1)
	return selected and info.ticks
end

function UF:GetInterruptColor(db, unit)
	local colors = ElvUF.colors
	local customColor = db and db.castbar and db.castbar.customColor
	local custom, r, g, b = customColor and customColor.enable and customColor, colors.castColor.r, colors.castColor.g, colors.castColor.b

	if self.notInterruptible and (UnitIsPlayer(unit) or (unit ~= 'player' and UnitCanAttack('player', unit))) then
		if custom and custom.colorNoInterrupt then
			return custom.colorNoInterrupt.r, custom.colorNoInterrupt.g, custom.colorNoInterrupt.b
		else
			return colors.castNoInterrupt.r, colors.castNoInterrupt.g, colors.castNoInterrupt.b
		end
	elseif ((custom and custom.useClassColor) or (not custom and UF.db.colors.castClassColor)) and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and colors.class[Class]
		if t then return t.r, t.g, t.b end
	elseif (custom and custom.useReactionColor) or (not custom and UF.db.colors.castReactionColor) then
		local Reaction = UnitReaction(unit, 'player')
		local t = Reaction and colors.reaction[Reaction]
		if t then return t.r, t.g, t.b end
	elseif custom then
		return customColor.color.r, customColor.color.g, customColor.color.b
	end

	return r, g, b
end

function UF:PostCastStart(unit)
	local parent = self.__owner
	local db = parent and parent.db
	if not db or not db.castbar then return end

	if unit == 'vehicle' then unit = 'player' end

	self.unit = unit

	if db.castbar.displayTarget then -- player or NPCs; if used on other players: the cast target doesn't match their target, can be misleading if they mouseover cast
		if parent.unitframeType == 'player' then
			if self.curTarget then
				self.Text:SetText(self.spellName..' > '..self.curTarget)
			end
		elseif parent.unitframeType == 'pet' or parent.unitframeType == 'boss' then
			local target = self.curTarget or UnitName(unit..'target')
			if target and target ~= '' and target ~= UnitName(unit) then
				self.Text:SetText(self.spellName..' > '..target)
			end
		end
	end

	if self.channeling and db.castbar.ticks and unit == 'player' then
		local spellID, global = self.spellID, E.global.unitframe
		local baseTicks = global.ChannelTicks[spellID]

		-- Separate group, so they can be effected by haste or size if needed
		local talentTicks = baseTicks and global.TalentChannelTicks[spellID]
		local selectedTicks = talentTicks and UF:GetTalentTicks(talentTicks)
		if selectedTicks then
			baseTicks = selectedTicks
		end

		-- Base ticks upgraded by another aura
		local auraTicks = baseTicks and global.AuraChannelTicks[spellID]
		if auraTicks then
			for auraID, tickCount in next, auraTicks.spells do
				if E:GetAuraByID(unit, auraID, auraTicks.filter) then
					baseTicks = tickCount
					break -- found one so stop
				end
			end
		end

		-- Wait for chain to happen
		local chainTicks = baseTicks and global.ChainChannelTicks[spellID]
		if chainTicks then -- requires a window: ChainChannelTime
			local now = GetTime() -- this will clear old ones too
			local seconds = global.ChainChannelTime[spellID]
			local match = seconds and self.chainTime and self.chainTick == spellID

			if match and (now - seconds) < self.chainTime then
				baseTicks = chainTicks
			end

			self.chainTime = now
			self.chainTick = spellID
		else
			self.chainTick = nil -- not a chain spell
			self.chainTime = nil -- clear the time too
		end

		local hasteTicks = baseTicks and global.HastedChannelTicks[spellID]
		if hasteTicks then -- requires tickSize
			local haste = UnitSpellHaste('player') * 0.01
			local rate = 1 / baseTicks
			local first = rate * 0.5

			local bonus = 0
			if haste >= first then
				bonus = bonus + 1
			end

			local x = E:Round(first + rate, 2)
			while haste >= x do
				x = E:Round(first + (rate * bonus), 2)

				if haste >= x then
					bonus = bonus + 1
				end
			end

			UF:SetCastTicks(self, baseTicks + bonus)
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
		self.chainTick = nil -- reset the chain
		self.chainTime = nil -- spell cast vars
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
