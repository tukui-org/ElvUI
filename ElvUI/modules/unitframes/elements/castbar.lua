local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

--Cache global variables
--Lua functions
local unpack, tonumber = unpack, tonumber
local floor, abs = math.floor, abs
local sub, utf8sub, utf8len = string.sub, string.utf8sub, string.utf8len
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitSpellHaste = UnitSpellHaste
local UnitBuff = UnitBuff
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitCanAttack = UnitCanAttack

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_Castbar(self, direction, moverName)
	local castbar = CreateFrame("StatusBar", nil, self)
	UF['statusbars'][castbar] = true
	castbar.CustomDelayText = UF.CustomCastDelayText
	castbar.CustomTimeText = UF.CustomTimeText
	castbar.PostCastStart = UF.PostCastStart
	castbar.PostChannelStart = UF.PostCastStart
	castbar.PostCastStop = UF.PostCastStop
	castbar.PostChannelStop = UF.PostCastStop
	castbar.PostChannelUpdate = UF.PostChannelUpdate
	castbar.PostCastInterruptible = UF.PostCastInterruptible
	castbar.PostCastNotInterruptible = UF.PostCastNotInterruptible
	castbar:SetClampedToScreen(true)
	castbar:CreateBackdrop('Default')

	castbar.Time = castbar:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(castbar.Time)
	castbar.Time:Point("RIGHT", castbar, "RIGHT", -4, 0)
	castbar.Time:SetTextColor(0.84, 0.75, 0.65)
	castbar.Time:SetJustifyH("RIGHT")

	castbar.Text = castbar:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(castbar.Text)
	castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
	castbar.Text:SetTextColor(0.84, 0.75, 0.65)

	castbar.Spark = castbar:CreateTexture(nil, 'OVERLAY')
	castbar.Spark:SetBlendMode('ADD')
	castbar.Spark:SetVertexColor(1, 1, 1)

	--Set to castbar.SafeZone
	castbar.LatencyTexture = castbar:CreateTexture(nil, "OVERLAY")
	castbar.LatencyTexture:SetTexture(E['media'].blankTex)
	castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)

	castbar.bg = castbar:CreateTexture(nil, 'BORDER')
	castbar.bg:Hide()

	local button = CreateFrame("Frame", nil, castbar)
	local holder = CreateFrame('Frame', nil, castbar)
	button:SetTemplate("Default")

	if direction == "LEFT" then
		holder:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -(E.Border * 3))
		castbar:Point('BOTTOMRIGHT', holder, 'BOTTOMRIGHT', -E.Border, E.Border)
		button:Point("RIGHT", castbar, "LEFT", E.PixelMode and 0 or -3, 0)
	else
		holder:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -(E.Border * 3))
		castbar:Point('BOTTOMLEFT', holder, 'BOTTOMLEFT', E.Border, E.Border)
		button:Point("LEFT", castbar, "RIGHT", E.PixelMode and 0 or 3, 0)
	end

	castbar.Holder = holder

	if moverName then
		E:CreateMover(castbar.Holder, self:GetName()..'CastbarMover', moverName, nil, -6, nil, 'ALL,SOLO')
	end

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetInside()
	icon:SetTexCoord(unpack(E.TexCoords))
	icon.bg = button

	--Set to castbar.Icon
	castbar.ButtonIcon = icon

	return castbar
end

function UF:CustomCastDelayText(duration)
	local db = self:GetParent().db
	if not db then return end

	if self.channeling then
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(abs(duration - self.max), self.delay))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f |cffaf5050%.1f|r"):format(duration, self.max, self.delay))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(duration, self.delay))
		end
	else
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(duration, "+", self.delay))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f |cffaf5050%s %.1f|r"):format(duration, self.max, "+", self.delay))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(abs(duration - self.max), "+", self.delay))
		end
	end
end

function UF:CustomTimeText(duration)
	local db = self:GetParent().db
	if not db then return end

	if self.channeling then
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f"):format(abs(duration - self.max)))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f"):format(duration, self.max))
			self.Time:SetText(("%.1f / %.1f"):format(abs(duration - self.max), self.max))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f"):format(duration))
		end
	else
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f"):format(duration))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f"):format(duration, self.max))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f"):format(abs(duration - self.max)))
		end
	end
end

local ticks = {}
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
			ticks[i]:SetTexture(E["media"].normTex)
			ticks[i]:SetVertexColor(0, 0, 0, 0.8)
			ticks[i]:Width(1)
			ticks[i]:SetHeight(frame:GetHeight())
		end

		--[[if(ms ~= 0) then
			local perc = (w / frame.max) * (ms / 1e5)
			if(perc > 1) then perc = 1 end

			ticks[i]:SetWidth((w * perc) / (numTicks + extraTickRatio))
		else
			ticks[i]:Width(1)
		end]]

		ticks[i]:ClearAllPoints()
		ticks[i]:SetPoint("RIGHT", frame, "LEFT", d * i, 0)
		ticks[i]:Show()
	end
end

local MageSpellName = GetSpellInfo(5143) --Arcane Missiles
local MageBuffName = GetSpellInfo(166872) --4p T17 bonus proc for arcane

function UF:PostCastStart(unit, name, rank, castid)
	local db = self:GetParent().db
	if not db or not db.castbar then return; end

	if unit == "vehicle" then unit = "player" end

	--Get length of time, then calculate available length for textLen
	--Re-calculate and omit timeLen constraint if text length would otherwise be lower than 1
	local timeLen = utf8len(self.Time:GetText() or "")
	local textLen = floor(((((32/245) * self:GetWidth()) / E.db['unitframe'].fontSize) * 12) - timeLen)
	if textLen <1 then textLen = floor((((32/245) * self:GetWidth()) / E.db['unitframe'].fontSize) * 12) end

	if timeLen == 0 then
		E:Delay(0.03, function() --Delay may need tweaking
			timeLen = utf8len(self.Time:GetText() or "")
			textLen = floor(((((32/245) * self:GetWidth()) / E.db['unitframe'].fontSize) * 12) - timeLen)
			if textLen <1 then textLen = floor((((32/245) * self:GetWidth()) / E.db['unitframe'].fontSize) * 12) end

			if db.castbar.displayTarget and self.curTarget then
				self.Text:SetText(utf8sub(name..' --> '..self.curTarget, 0, textLen))
			else
				self.Text:SetText(utf8sub(name, 0, textLen))
			end
		end)
	else
		if db.castbar.displayTarget and self.curTarget then
			self.Text:SetText(utf8sub(name..' --> '..self.curTarget, 0, textLen))
		else
			self.Text:SetText(utf8sub(name, 0, textLen))
		end
	end

	self.Spark:Height(self:GetHeight() * 2)

	self.unit = unit

	if db.castbar.ticks and unit == "player" then
		local unitframe = E.global.unitframe
		local baseTicks = unitframe.ChannelTicks[name]

        -- Detect channeling spell and if it's the same as the previously channeled one
        if baseTicks and name == self.prevSpellCast then
            self.chainChannel = true
        elseif baseTicks then
            self.chainChannel = nil
            self.prevSpellCast = name
        end

		if baseTicks and unitframe.ChannelTicksSize[name] and unitframe.HastedChannelTicks[name] then
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

            local baseTickSize = unitframe.ChannelTicksSize[name]
            local hastedTickSize = baseTickSize / (1 + curHaste)
            local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
            local extraTickRatio = extraTick / hastedTickSize

			UF:SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
		elseif baseTicks and unitframe.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
            local baseTickSize = unitframe.ChannelTicksSize[name]
            local hastedTickSize = baseTickSize / (1 +  curHaste)
            local extraTick = self.max - hastedTickSize * (baseTicks)
            local extraTickRatio = extraTick / hastedTickSize

			UF:SetCastTicks(self, baseTicks, extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			UF:SetCastTicks(self, baseTicks)
		else
			UF:HideTicks()
		end
	elseif unit == 'player' then
		UF:HideTicks()
	end

	local colors = ElvUF.colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if UF.db.colors.castClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = ElvUF.colors.class[class]
	elseif UF.db.colors.castReactionColor and UnitReaction(unit, 'player') then
		t = ElvUF.colors.reaction[UnitReaction(unit, "player")]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if  self.interrupt and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentCastbar, self, self.bg, nil, true)
	if self.bg:IsShown() then
		self.bg:SetTexture(r * 0.25, g * 0.25, b * 0.25)

		local _, _, _, alpha = self.backdrop:GetBackdropColor()
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha)
	end
end

function UF:PostCastStop(unit, name, castid)
	self.chainChannel = nil
	self.prevSpellCast = nil
end

function UF:PostChannelUpdate(unit, name)
	local db = self:GetParent().db
	if not db then return; end
    if not (unit == "player" or unit == "vehicle") then return end

	if db.castbar.ticks then
		local unitframe = E.global.unitframe
		local baseTicks = unitframe.ChannelTicks[name]

		if baseTicks and unitframe.ChannelTicksSize[name] and unitframe.HastedChannelTicks[name] then
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

			local baseTickSize = unitframe.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			UF:SetCastTicks(self, baseTicks + bonusTicks, self.extraTickRatio)
		elseif baseTicks and unitframe.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = unitframe.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			UF:SetCastTicks(self, baseTicks, self.extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			if self.chainChannel then
				baseTicks = baseTicks + 1
			end
			UF:SetCastTicks(self, baseTicks)
		else
			UF:HideTicks()
		end
	else
		UF:HideTicks()
	end
end

function UF:PostCastInterruptible(unit)
	if unit == "vehicle" or unit == "player" then return end

	local colors = ElvUF.colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if UF.db.colors.castClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = ElvUF.colors.class[class]
	elseif UF.db.colors.castReactionColor and UnitReaction(unit, 'player') then
		t = ElvUF.colors.reaction[UnitReaction(unit, "player")]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.interrupt and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)

	UF:ToggleTransparentStatusBar(UF.db.colors.transparentCastbar, self, self.bg, nil, true)
	if self.bg:IsShown() then
		self.bg:SetTexture(r * 0.25, g * 0.25, b * 0.25)

		local _, _, _, alpha = self.backdrop:GetBackdropColor()
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha)
	end
end

function UF:PostCastNotInterruptible(unit)
	local colors = ElvUF.colors
	self:SetStatusBarColor(colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3])
end

