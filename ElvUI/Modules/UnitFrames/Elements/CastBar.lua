local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local unpack, tonumber = unpack, tonumber
local abs, min = abs, math.min
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitSpellHaste = UnitSpellHaste
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitCanAttack = UnitCanAttack
local GetSpellInfo = GetSpellInfo

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

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
	local castbar = CreateFrame("StatusBar", nil, frame)
	castbar:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 30) --Make it appear above everything else
	self.statusbars[castbar] = true
	castbar.CustomDelayText = self.CustomCastDelayText
	castbar.CustomTimeText = self.CustomTimeText
	castbar.PostCastStart = self.PostCastStart
	castbar.PostCastStop = self.PostCastStop
	castbar.PostCastInterruptible = self.PostCastInterruptible
	castbar:SetClampedToScreen(true)
	castbar:CreateBackdrop(nil, nil, nil, self.thinBorders, true)

	castbar.Time = castbar:CreateFontString(nil, 'OVERLAY')
	self:Configure_FontString(castbar.Time)
	castbar.Time:Point("RIGHT", castbar, "RIGHT", -4, 0)
	castbar.Time:SetTextColor(0.84, 0.75, 0.65)
	castbar.Time:SetJustifyH("RIGHT")

	castbar.Text = castbar:CreateFontString(nil, 'OVERLAY')
	self:Configure_FontString(castbar.Text)
	castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
	castbar.Text:SetTextColor(0.84, 0.75, 0.65)
	castbar.Text:SetJustifyH("LEFT")
	castbar.Text:SetWordWrap(false)

	castbar.Spark_ = castbar:CreateTexture(nil, 'OVERLAY')
	castbar.Spark_:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	castbar.Spark_:SetBlendMode('ADD')
	castbar.Spark_:SetVertexColor(1, 1, 1)
	castbar.Spark_:Size(20, 40)

	--Set to castbar.SafeZone
	castbar.LatencyTexture = castbar:CreateTexture(nil, "OVERLAY")
	castbar.LatencyTexture:SetTexture(E.media.blankTex)
	castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)

	castbar.bg = castbar:CreateTexture(nil, 'BORDER')
	castbar.bg:SetAllPoints()
	castbar.bg:SetTexture(E.media.blankTex)
	castbar.bg:Show()

	local button = CreateFrame("Frame", nil, castbar)
	local holder = CreateFrame('Frame', nil, castbar)
	button:SetTemplate(nil, nil, nil, self.thinBorders, true)

	castbar.Holder = holder
	--these are placeholder so the mover can be created.. it will be changed.
	castbar.Holder:Point("TOPLEFT", frame, "BOTTOMLEFT", 0, -(frame.BORDER - frame.SPACING))
	castbar:Point('BOTTOMLEFT', castbar.Holder, 'BOTTOMLEFT', frame.BORDER, frame.BORDER)
	button:Point("RIGHT", castbar, "LEFT", -E.Spacing*3, 0)

	if moverName then
		local name = frame:GetName()
		local configName = name:gsub('^ElvUF_', ''):lower()
		E:CreateMover(castbar.Holder, name..'CastbarMover', moverName, nil, -6, nil, 'ALL,SOLO', nil, 'unitframe,'..configName..',castbar')
	end

	local icon = button:CreateTexture(nil, "ARTWORK")
	local offset = frame.BORDER --use frame.BORDER since it may be different from E.Border due to forced thin borders
	icon:SetInside(nil, offset, offset)
	icon.bg = button

	--Set to castbar.Icon
	castbar.ButtonIcon = icon

	return castbar
end

function UF:Configure_Castbar(frame)
	if not frame.VARIABLES_SET then return end
	local castbar = frame.Castbar
	local db = frame.db
	castbar:Width(db.castbar.width - ((frame.BORDER+frame.SPACING)*2))
	castbar:Height(db.castbar.height - ((frame.BORDER+frame.SPACING)*2))
	castbar.Holder:Width(db.castbar.width)
	castbar.Holder:Height(db.castbar.height)

	local oSC = castbar.Holder:GetScript('OnSizeChanged')
	if oSC then oSC(castbar.Holder) end

	if db.castbar.strataAndLevel and db.castbar.strataAndLevel.useCustomStrata then
		castbar:SetFrameStrata(db.castbar.strataAndLevel.frameStrata)
	end

	if db.castbar.strataAndLevel and db.castbar.strataAndLevel.useCustomLevel then
		castbar:SetFrameLevel(db.castbar.strataAndLevel.frameLevel)
	end

	castbar.timeToHold = db.castbar.timeToHold

	--Latency
	if db.castbar.latency then
		castbar.SafeZone = castbar.LatencyTexture
		castbar.LatencyTexture:Show()
	else
		castbar.SafeZone = nil
		castbar.LatencyTexture:Hide()
	end

	--Icon
	if db.castbar.icon then
		castbar.Icon = castbar.ButtonIcon
		castbar.Icon:SetTexCoord(unpack(E.TexCoords))

		if (not db.castbar.iconAttached) then
			castbar.Icon.bg:Size(db.castbar.iconSize)
		else
			if (db.castbar.insideInfoPanel and frame.USE_INFO_PANEL) then
				castbar.Icon.bg:Size(db.infoPanel.height - frame.SPACING*2)
			else
				castbar.Icon.bg:Size(db.castbar.height-frame.SPACING*2)
			end

			castbar:Width(db.castbar.width - castbar.Icon.bg:GetWidth() - (frame.BORDER + frame.SPACING*5))
		end

		castbar.Icon.bg:Show()
	else
		castbar.ButtonIcon.bg:Hide()
		castbar.Icon = nil
	end

	if db.castbar.spark then
		castbar.Spark = castbar.Spark_
		castbar.Spark:Point('CENTER', castbar:GetStatusBarTexture(), 'RIGHT', 0, 0)
		castbar.Spark:Height(db.castbar.height * 2)
	elseif castbar.Spark then
		castbar.Spark:Hide()
		castbar.Spark = nil
	end

	castbar:ClearAllPoints()
	if (db.castbar.insideInfoPanel and frame.USE_INFO_PANEL) then
		if (not db.castbar.iconAttached) then
			castbar:SetInside(frame.InfoPanel, 0, 0)
		else
			local iconWidth = db.castbar.icon and (castbar.Icon.bg:GetWidth() - frame.BORDER) or 0
			if(frame.ORIENTATION == "RIGHT") then
				castbar:Point("TOPLEFT", frame.InfoPanel, "TOPLEFT")
				castbar:Point("BOTTOMRIGHT", frame.InfoPanel, "BOTTOMRIGHT", -iconWidth - frame.SPACING*3, 0)
			else
				castbar:Point("TOPLEFT", frame.InfoPanel, "TOPLEFT",  iconWidth + frame.SPACING*3, 0)
				castbar:Point("BOTTOMRIGHT", frame.InfoPanel, "BOTTOMRIGHT")
			end
		end

		if db.castbar.spark then
			castbar.Spark:Height(db.infoPanel and db.infoPanel.height * 2) -- Grab the height from the infopanel.
		end

		if(castbar.Holder.mover) then
			E:DisableMover(castbar.Holder.mover:GetName())
		end
	else
		local isMoved = E:HasMoverBeenMoved(frame:GetName()..'CastbarMover') or not castbar.Holder.mover
		if not isMoved then
			castbar.Holder.mover:ClearAllPoints()
		end

		castbar:ClearAllPoints()
		if frame.ORIENTATION ~= "RIGHT" then
			castbar:Point('BOTTOMRIGHT', castbar.Holder, 'BOTTOMRIGHT', -(frame.BORDER+frame.SPACING), frame.BORDER+frame.SPACING)
			if not isMoved then
				castbar.Holder.mover:Point("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -(frame.BORDER - frame.SPACING))
			end
		else
			castbar:Point('BOTTOMLEFT', castbar.Holder, 'BOTTOMLEFT', frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING)
			if not isMoved then
				castbar.Holder.mover:Point("TOPLEFT", frame, "BOTTOMLEFT", 0, -(frame.BORDER - frame.SPACING))
			end
		end

		if(castbar.Holder.mover) then
			E:EnableMover(castbar.Holder.mover:GetName())
		end
	end

	if not db.castbar.iconAttached and db.castbar.icon then
		local attachPoint = db.castbar.iconAttachedTo == "Frame" and frame or frame.Castbar
		local anchorPoint = db.castbar.iconPosition
		castbar.Icon.bg:ClearAllPoints()
		castbar.Icon.bg:Point(INVERT_ANCHORPOINT[anchorPoint], attachPoint, anchorPoint, db.castbar.iconXOffset, db.castbar.iconYOffset)
	elseif(db.castbar.icon) then
		castbar.Icon.bg:ClearAllPoints()
		if frame.ORIENTATION == "RIGHT" then
			castbar.Icon.bg:Point("LEFT", castbar, "RIGHT", frame.SPACING*3, 0)
		else
			castbar.Icon.bg:Point("RIGHT", castbar, "LEFT", -frame.SPACING*3, 0)
		end
	end

	--Adjust tick heights
	castbar.tickHeight = castbar:GetHeight()

	if db.castbar.ticks then --Only player unitframe has this
		--Set tick width and color
		castbar.tickWidth = db.castbar.tickWidth
		castbar.tickColor = db.castbar.tickColor

		for i = 1, #ticks do
			ticks[i]:SetVertexColor(castbar.tickColor.r, castbar.tickColor.g, castbar.tickColor.b, castbar.tickColor.a)
			ticks[i]:Width(castbar.tickWidth)
		end
	end

	castbar.custom_backdrop = UF.db.colors.customcastbarbackdrop and UF.db.colors.castbar_backdrop
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentCastbar, castbar, castbar.bg, nil, UF.db.colors.invertCastbar)

	if db.castbar.enable and not frame:IsElementEnabled('Castbar') then
		frame:EnableElement('Castbar')
	elseif not db.castbar.enable and frame:IsElementEnabled('Castbar') then
		frame:DisableElement('Castbar')

		if(castbar.Holder.mover) then
			E:DisableMover(castbar.Holder.mover:GetName())
		end
	end
end

function UF:CustomCastDelayText(duration)
	local db = self:GetParent().db
	if not (db and db.castbar) then return end
	db = db.castbar.format

	if self.channeling then
		if db == 'CURRENT' then
			self.Time:SetFormattedText("%.1f |cffaf5050%.1f|r", abs(duration - self.max), self.delay)
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText("%.1f / %.1f |cffaf5050%.1f|r", duration, self.max, self.delay)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText("%.1f |cffaf5050%.1f|r", duration, self.delay)
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText("%.1f / %.1f |cffaf5050%.1f|r", abs(duration - self.max), self.max, self.delay)
		end
	else
		if db == 'CURRENT' then
			self.Time:SetFormattedText("%.1f |cffaf5050%s %.1f|r", duration, "+", self.delay)
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText("%.1f / %.1f |cffaf5050%s %.1f|r", duration, self.max, "+", self.delay)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText("%.1f |cffaf5050%s %.1f|r", abs(duration - self.max), "+", self.delay)
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText("%.1f / %.1f |cffaf5050%s %.1f|r", abs(duration - self.max), self.max, "+", self.delay)
		end
	end
end

function UF:CustomTimeText(duration)
	local db = self:GetParent().db
	if not (db and db.castbar) then return end
	db = db.castbar.format

	if self.channeling then
		if db == 'CURRENT' then
			self.Time:SetFormattedText("%.1f", abs(duration - self.max))
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText("%.1f / %.1f", abs(duration - self.max), self.max)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText("%.1f", duration)
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText("%.1f / %.1f", duration, self.max)
		end
	else
		if db == 'CURRENT' then
			self.Time:SetFormattedText("%.1f", duration)
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText("%.1f / %.1f", duration, self.max)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText("%.1f", abs(duration - self.max))
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText("%.1f / %.1f", abs(duration - self.max), self.max)
		end
	end
end

function UF:HideTicks()
	for i=1, #ticks do
		ticks[i]:Hide()
	end
end

function UF:SetCastTicks(frame, numTicks, extraTickRatio)
	extraTickRatio = extraTickRatio or 0
	UF:HideTicks()
	if numTicks and numTicks <= 0 then return end;
	local w = frame:GetWidth()
	local d = w / (numTicks + extraTickRatio)
	--local _, _, _, ms = GetNetStats()
	for i = 1, numTicks do
		if not ticks[i] then
			ticks[i] = frame:CreateTexture(nil, 'OVERLAY')
			ticks[i]:SetTexture(E.media.normTex)
			E:RegisterStatusBar(ticks[i])
			ticks[i]:SetVertexColor(frame.tickColor.r, frame.tickColor.g, frame.tickColor.b, frame.tickColor.a)
			ticks[i]:Width(frame.tickWidth)
		end

		ticks[i]:Height(frame.tickHeight)

		--[[if(ms ~= 0) then
			local perc = (w / frame.max) * (ms / 1e5)
			if(perc > 1) then perc = 1 end

			ticks[i]:Width((w * perc) / (numTicks + extraTickRatio))
		else
			ticks[i]:Width(1)
		end]]

		ticks[i]:ClearAllPoints()
		ticks[i]:Point("RIGHT", frame, "LEFT", d * i, 0)
		ticks[i]:Show()
	end
end

function UF:PostCastStart(unit)
	local db = self:GetParent().db
	if not db or not db.castbar then return; end

	if unit == "vehicle" then unit = "player" end

	if db.castbar.displayTarget and self.curTarget then
		self.Text:SetText(GetSpellInfo(self.spellID)..' > '..self.curTarget)
	end

	-- Get length of Time, then calculate available length for Text
	local timeWidth = self.Time:GetStringWidth()
	local textWidth = self:GetWidth() - timeWidth - 10
	local textStringWidth = self.Text:GetStringWidth()

	if timeWidth == 0 or textStringWidth == 0 then
		E:Delay(0.05, function() -- Delay may need tweaking
			textWidth = self:GetWidth() - self.Time:GetStringWidth() - 10
			textStringWidth = self.Text:GetStringWidth()
			if textWidth > 0 then self.Text:Width(min(textWidth, textStringWidth)) end
		end)
	else
		self.Text:Width(min(textWidth, textStringWidth))
	end

	self.unit = unit

	if self.channeling and db.castbar.ticks and unit == "player" then
		local unitframe = E.global.unitframe
		local baseTicks = unitframe.ChannelTicks[self.spellID]
		---- Detect channeling spell and if it's the same as the previously channeled one
		--if baseTicks and self.spellID == self.prevSpellCast then
		--	self.chainChannel = true
		--elseif baseTicks then
		--	self.chainChannel = nil
		--	self.prevSpellCast = self.spellID
		--end

		if baseTicks and unitframe.ChannelTicksSize[self.spellID] and unitframe.HastedChannelTicks[self.spellID] then
			local tickIncRate = 1 / baseTicks
			local curHaste = UnitSpellHaste("player") * 0.01
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

			local baseTickSize = unitframe.ChannelTicksSize[self.spellID]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			local extraTickRatio = extraTick / hastedTickSize
			UF:SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
			self.hadTicks = true
		elseif baseTicks and unitframe.ChannelTicksSize[self.spellID] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = unitframe.ChannelTicksSize[self.spellID]
			local hastedTickSize = baseTickSize / (1 +  curHaste)
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

	local colors = ElvUF.colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	if (self.notInterruptible and unit ~= "player") and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	elseif UF.db.colors.castClassColor and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and ElvUF.colors.class[Class]
		if t then r, g, b = t[1], t[2], t[3] end
	elseif UF.db.colors.castReactionColor then
		local Reaction = UnitReaction(unit, 'player')
		local t = Reaction and ElvUF.colors.reaction[Reaction]
		if t then r, g, b = t[1], t[2], t[3] end
	end

	self:SetStatusBarColor(r, g, b)
end

function UF:PostCastStop(unit)
	if self.hadTicks and unit == 'player' then
		UF:HideTicks()
		self.hadTicks = false
	end
end

function UF:PostCastInterruptible(unit)
	if unit == "vehicle" or unit == "player" then return end

	local colors = ElvUF.colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	if self.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	elseif UF.db.colors.castClassColor and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and ElvUF.colors.class[Class]
		if t then r, g, b = t[1], t[2], t[3] end
	elseif UF.db.colors.castReactionColor then
		local Reaction = UnitReaction(unit, 'player')
		local t = Reaction and ElvUF.colors.reaction[Reaction]
		if t then r, g, b = t[1], t[2], t[3] end
	end

	self:SetStatusBarColor(r, g, b)
end
