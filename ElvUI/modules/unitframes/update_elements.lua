local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

local abs = math.abs
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local function CheckFilter(filterType, isFriend)
	local FRIENDLY_CHECK, ENEMY_CHECK = false, false
	if type(filterType) == 'string' then
		error('Database conversion failed! Report to Elv.')
	elseif type(filterType) == 'boolean' then
		FRIENDLY_CHECK = filterType
		ENEMY_CHECK = filterType
	elseif filterType then
		FRIENDLY_CHECK = filterType.friendly
		ENEMY_CHECK = filterType.enemy
	end
	
	if (FRIENDLY_CHECK and isFriend) or (ENEMY_CHECK and not isFriend) then
		return true
	end
	
	return false
end

function UF:PostUpdateHealth(unit, min, max)
	if self:GetParent().isForced then
		min = math.random(1, max)
		self:SetValue(min)
	end

	if min == 0 and self:GetParent().ResurrectIcon then
		self:GetParent().ResurrectIcon:SetAlpha(1)
	elseif self:GetParent().ResurrectIcon then
		self:GetParent().ResurrectIcon:SetAlpha(0)
	end
	
	local r, g, b = self:GetStatusBarColor()
	if (E.db['unitframe']['colors'].healthclass == true and E.db['unitframe']['colors'].colorhealthbyvalue == true) or (E.db['unitframe']['colors'].colorhealthbyvalue and self:GetParent().isForced) and not (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		local newr, newg, newb = ElvUF.ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

		self:SetStatusBarColor(newr, newg, newb)
		if self.bg and self.bg.multiplier then
			local mu = self.bg.multiplier
			self.bg:SetVertexColor(newr * mu, newg * mu, newb * mu)
		end
	end

	if E.db['unitframe']['colors'].classbackdrop then
		local t
			if UnitIsPlayer(unit) then
				local _, class = UnitClass(unit)
				t = self:GetParent().colors.class[class]
			elseif UnitReaction(unit, 'player') then
				t = self:GetParent().colors.reaction[UnitReaction(unit, "player")]
			end

		if t then
			self.bg:SetVertexColor(t[1], t[2], t[3])
		end
	end
	
	--Backdrop
	if E.db['unitframe']['colors'].customhealthbackdrop then
		local backdrop = E.db['unitframe']['colors'].health_backdrop
		self.bg:SetVertexColor(backdrop.r, backdrop.g, backdrop.b)		
	end	
end

function UF:PostNamePosition(frame, unit)
	if --[[frame.Power.value:GetText() and]] UnitIsPlayer(unit) and frame.Power.value:IsShown() then
		local db = frame.db
		
		local position = db.name.position
		local x, y = self:GetPositionOffset(position)
		frame.Power.value:SetAlpha(1)
		
		frame.Name:ClearAllPoints()
		frame.Name:Point(position, frame.Health, position, x, y)	
	elseif frame.Power.value:IsShown() then
		frame.Power.value:SetAlpha(0)
		
		frame.Name:ClearAllPoints()
		frame.Name:SetPoint(frame.Power.value:GetPoint())
	end
end

function UF:PostUpdatePower(unit, min, max)
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)
	local color
	
	if self:GetParent().isForced then
		min = math.random(1, max)
		pType = math.random(0, 4)
		pToken = pType == 0 and "MANA" or pType == 1 and "RAGE" or pType == 2 and "FOCUS" or pType == 3 and "ENERGY" or pType == 4 and "RUNIC_POWER"
		self:SetValue(min)
		color = ElvUF['colors'].power[pToken]
		
		if not self.colorClass then
			self:SetStatusBarColor(color[1], color[2], color[3])
			local mu = self.bg.multiplier or 1
			self.bg:SetVertexColor(color[1] * mu, color[2] * mu, color[3] * mu)
		end
	elseif pToken then
		color = ElvUF['colors'].power[pToken]
	end	
	
	local perc
	if max == 0 then
		perc = 0
	else
		perc = floor(min / max * 100)
	end

	local db = self:GetParent().db
	if self.LowManaText and db then
		if pToken == 'MANA' then
			if perc <= db.lowmana and not dead and not ghost then
				self.LowManaText:SetText(LOW..' '..MANA)
				E:Flash(self.LowManaText, 0.6)
			else
				self.LowManaText:SetText()
				E:StopFlash(self.LowManaText)
			end
		else
			self.LowManaText:SetText()
			E:StopFlash(self.LowManaText)
		end
	end
	
	if db and db['power'] and db['power'].hideonnpc then
		UF:PostNamePosition(self:GetParent(), unit)
	end	
end

function UF:PortraitUpdate(unit)
	local db = self:GetParent().db
	
	if not db then return end
	
	if db['portrait'].enable and db['portrait'].overlay then
		self:SetAlpha(0); 
		self:SetAlpha(0.35);
	else
		self:SetAlpha(1)
	end
	
	if self:GetObjectType() ~= 'Texture' then
		if self:GetModel() and self:GetModel().find and self:GetModel():find("worgenmale") then
			self:SetCamera(1)
		end	

		self:SetCamDistanceScale(db['portrait'].camDistanceScale - 0.01 >= 0.01 and db['portrait'].camDistanceScale - 0.01 or 0.01) --Blizzard bug fix
		self:SetCamDistanceScale(db['portrait'].camDistanceScale)
	end
end

local day, hour, minute, second = 86400, 3600, 60, 1
function UF:FormatTime(s, reverse)
	if s >= day then
		return format("%dd", ceil(s / hour))
	elseif s >= hour then
		return format("%dh", ceil(s / hour))
	elseif s >= minute then
		return format("%dm", ceil(s / minute))
	elseif s >= minute / 12 then
		return floor(s)
	end
	
	if reverse and reverse == true and s >= second then
		return floor(s)
	else	
		return format("%.1f", s)
	end
end

function UF:UpdateAuraTimer(elapsed)	
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = UF:FormatTime(self.timeLeft)
				if self.reverse then time = UF:FormatTime(abs(self.timeLeft - self.duration), true) end
				self.text:SetText(time)
				if self.timeLeft <= 5 then
					self.text:SetTextColor(0.99, 0.31, 0.31)
				else
					self.text:SetTextColor(1, 1, 1)
				end
			else
				self.text:Hide()
				self:SetScript("OnUpdate", nil)
			end
			if (not self.isDebuff) and E.db['general'].classtheme == true then
				local r, g, b = self:GetParent():GetParent().Health.backdrop:GetBackdropBorderColor()
				self:SetBackdropBorderColor(r, g, b)
			end
			self.elapsed = 0
		end
	end
end

function UF:PostUpdateAura(unit, button, index, offset, filter, isDebuff, duration, timeLeft)
	local name, _, _, _, dtype, duration, expirationTime, unitCaster, isStealable, _, spellID = UnitAura(unit, index, button.filter)

	local db = self:GetParent().db
	
	button.text:Show()
	if db and db[self.type] then
		button.text:FontTemplate(LSM:Fetch("font", E.db['unitframe'].font), db[self.type].fontSize, 'OUTLINE')
		button.count:FontTemplate(LSM:Fetch("font", E.db['unitframe'].font), db[self.type].fontSize, 'OUTLINE')
		
		if db[self.type].clickThrough and button:IsMouseEnabled() then
			button:EnableMouse(false)
		elseif not db[self.type].clickThrough and not button:IsMouseEnabled() then
			button:EnableMouse(true)
		end
	end	
	
	if button.isDebuff then
		if(not UnitIsFriend("player", unit) and button.owner ~= "player" and button.owner ~= "vehicle") --[[and (not E.isDebuffWhiteList[name])]] then
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			if unit and not unit:find('arena%d') then
				button.icon:SetDesaturated(true)
			else
				button.icon:SetDesaturated(false)
			end
		else
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and E.myclass ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if (isStealable) and not UnitIsFriend("player", unit) then
			button:SetBackdropBorderColor(237/255, 234/255, 142/255)
		else
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))		
		end	
	end
	
	button.isStealable = isStealable
	button.duration = duration
	button.timeLeft = expirationTime
	button.first = true	
	
	local size = button:GetParent().size
	if size then
		button:Size(size)
	end
	
	--[[if E.ReverseTimer and E.ReverseTimer[spellID] then 
		button.reverse = true 
	else
		button.reverse = nil
	end]]
	
	button:SetScript('OnUpdate', UF.UpdateAuraTimer)
end

function UF:CustomCastDelayText(duration)
	local db = self:GetParent().db
	
	if db then
		local text		
		if self.channeling then
			if db.castbar.format == 'CURRENT' then
				self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(math.abs(duration - self.max), self.delay))
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
				self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(math.abs(duration - self.max), "+", self.delay))
			end		
		end
	end
end

function UF:CustomTimeText(duration)
	local db = self:GetParent().db
	if not db then return end
	
	local text
	if self.channeling then
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f"):format(math.abs(duration - self.max)))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f"):format(duration, self.max))
			self.Time:SetText(("%.1f / %.1f"):format(math.abs(duration - self.max), self.max))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f"):format(duration))
		end				
	else
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f"):format(duration))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f"):format(duration, self.max))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f"):format(math.abs(duration - self.max)))
		end		
	end
end

local ticks = {}
function UF:HideTicks()
	for _, tick in pairs(ticks) do
		tick:Hide()
	end		
end

function UF:SetCastTicks(frame, numTicks, extraTickRatio)
	extraTickRatio = extraTickRatio or 0
	UF:HideTicks()
	if numTicks and numTicks > 0 then
		local d = frame:GetWidth() / (numTicks + extraTickRatio)
		for i = 1, numTicks do
			if not ticks[i] then
				ticks[i] = frame:CreateTexture(nil, 'OVERLAY')
				ticks[i]:SetTexture(E["media"].normTex)
				ticks[i]:SetVertexColor(0, 0, 0)
				ticks[i]:SetWidth(1)
				ticks[i]:SetHeight(frame:GetHeight())
			end
			ticks[i]:ClearAllPoints()
			ticks[i]:SetPoint("CENTER", frame, "LEFT", d * i, 0)
			ticks[i]:Show()
		end
	end
end

function UF:PostCastStart(unit, name, rank, castid)
	if unit == "vehicle" then unit = "player" end
	local db = self:GetParent().db
	if not db then return; end
	if db.castbar.displayTarget and self.curTarget then
		self.Text:SetText(string.sub(name..' --> '..self.curTarget, 0, math.floor((((32/245) * self:GetWidth()) / E.db['unitframe'].fontSize) * 12)))
	else
		self.Text:SetText(string.sub(name, 0, math.floor((((32/245) * self:GetWidth()) / E.db['unitframe'].fontSize) * 12)))
	end

	self.Spark:Height(self:GetHeight() * 2)
		
	self.unit = unit

	if db.castbar.ticks and unit == "player" then
		local baseTicks = E.global.unitframe.ChannelTicks[name]
		
        -- Detect channeling spell and if it's the same as the previously channeled one
        if baseTicks and name == prevSpellCast then
            self.chainChannel = true
        elseif baseTicks then
            self.chainChannel = nil
            self.prevSpellCast = name
        end
		
		if baseTicks and E.global.unitframe.ChannelTicksSize[name] and E.global.unitframe.HastedChannelTicks[name] then
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

            local baseTickSize = E.global.unitframe.ChannelTicksSize[name]
            local hastedTickSize = baseTickSize / (1 + curHaste)
            local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
            local extraTickRatio = extraTick / hastedTickSize

			UF:SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
		elseif baseTicks and E.global.unitframe.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
            local baseTickSize = E.global.unitframe.ChannelTicksSize[name]
            local hastedTickSize = baseTickSize / (1 +  curHaste)
            local extraTick = self.max - hastedTickSize * (baseTicks)
            local extraTickRatio = extraTick / hastedTickSize

			UF:SetCastTicks(self, baseTicks, extraTickRatio)
		elseif baseTicks then
			UF:SetCastTicks(self, baseTicks)
		else
			UF:HideTicks()
		end
	elseif unit == 'player' then
		UF:HideTicks()			
	end	
	
	if self.interrupt and unit ~= "player" then
		if UnitCanAttack("player", unit) then
			self:SetStatusBarColor(unpack(ElvUF.colors.castNoInterrupt))
		else
			if E.db.theme == 'class' then
				local color = RAID_CLASS_COLORS[E.myclass]
				self:SetStatusBarColor(color.r, color.g, color.b)
			else
				self:SetStatusBarColor(unpack(ElvUF.colors.castColor))
			end					
		end
	else
		if E.db.theme == 'class' then
			local color = RAID_CLASS_COLORS[E.myclass]
			self:SetStatusBarColor(color.r, color.g, color.b)
		else
			self:SetStatusBarColor(unpack(ElvUF.colors.castColor))
		end	
	end
end

function UF:PostCastStop(unit, name, castid)
	self.chainChannel = nil
	self.prevSpellCast = nil
end

function UF:PostChannelUpdate(unit, name)
	if unit == "vehicle" then unit = "player" end
	local db = self:GetParent().db
	if not db then return; end
    
	if db.castbar.ticks and unit == "player" then
		local baseTicks = E.global.unitframe.ChannelTicks[name]

		if baseTicks and E.global.unitframe.ChannelTicksSize[name] and E.global.unitframe.HastedChannelTicks[name] then
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

			local baseTickSize = E.global.unitframe.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			UF:SetCastTicks(self, baseTicks + bonusTicks, self.extraTickRatio)
		elseif baseTicks and E.global.unitframe.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = E.global.unitframe.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			UF:SetCastTicks(self, baseTicks, self.extraTickRatio)
		elseif baseTicks then
			UF:SetCastTicks(self, baseTicks)
		else
			UF:HideTicks()
		end
	elseif unit == 'player' then
		UF:HideTicks()			
	end	
end

function UF:PostCastInterruptible(unit)
	if unit == "vehicle" then unit = "player" end
	if unit ~= "player" then
		if UnitCanAttack("player", unit) then
			self:SetStatusBarColor(unpack(ElvUF.colors.castNoInterrupt))	
		else
			self:SetStatusBarColor(unpack(ElvUF.colors.castColor))
		end
	end
end

function UF:PostCastNotInterruptible(unit)
	self:SetStatusBarColor(unpack(ElvUF.colors.castNoInterrupt))
end

function UF:UpdateHoly(event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end
	local db = self.db
	
	local BORDER = 2
	local numHolyPower = UnitPower('player', SPELL_POWER_HOLY_POWER);
	local maxHolyPower = UnitPowerMax('player', SPELL_POWER_HOLY_POWER);	
	local MAX_HOLY_POWER = UF['classMaxResourceBar'][E.myclass]
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and db.classbar.enable
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and db.power.enable
	
	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0		
	end	
	
	local CLASSBAR_WIDTH = db.width - 4
	if USE_PORTRAIT then
		CLASSBAR_WIDTH = math.ceil((db.width - (BORDER*2)) - PORTRAIT_WIDTH)
	end
	
	if USE_POWERBAR_OFFSET then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH - db.power.offset
	end
		
	if USE_MINI_CLASSBAR then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (maxHolyPower - 1) / maxHolyPower
	end
	
	self.HolyPower:Width(CLASSBAR_WIDTH)
	
	for i = 1, MAX_HOLY_POWER do
		if(i <= numHolyPower) then
			self.HolyPower[i]:SetAlpha(1)
		else
			self.HolyPower[i]:SetAlpha(.2)
		end
		
		self.HolyPower[i]:SetWidth(E:Scale(self.HolyPower:GetWidth() - 2)/maxHolyPower)	
		self.HolyPower[i]:ClearAllPoints()
		if i == 1 then
			self.HolyPower[i]:SetPoint("LEFT", self.HolyPower)
		else
			if USE_MINI_CLASSBAR then
				self.HolyPower[i]:Point("LEFT", self.HolyPower[i-1], "RIGHT", maxHolyPower == 5 and 7 or 13, 0)
			else
				self.HolyPower[i]:Point("LEFT", self.HolyPower[i-1], "RIGHT", 1, 0)
			end
		end

		if i > maxHolyPower then
			self.HolyPower[i]:Hide()
			self.HolyPower[i].backdrop:SetAlpha(0)
		else
			self.HolyPower[i]:Show()
			self.HolyPower[i].backdrop:SetAlpha(1)
		end		
	end	
end	

function UF:UpdateShadowOrbs(event, unit, powerType)
	local frame = self:GetParent()
	local db = frame.db
		
	local point, _, anchorPoint, x, y = frame.Health:GetPoint()
	if self:IsShown() and point then
		if db.classbar.fill == 'spaced' then
			frame.Health:SetPoint(point, frame, anchorPoint, x, -7)
		else
			frame.Health:SetPoint(point, frame, anchorPoint, x, -13)
		end
	elseif point then
		frame.Health:SetPoint(point, frame, anchorPoint, x, -2)
	end
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown())
end	

function UF:UpdateArcaneCharges(event, unit, arcaneCharges, maxCharges)
	local frame = self:GetParent()
	local db = frame.db
		
	local point, _, anchorPoint, x, y = frame.Health:GetPoint()
	if self:IsShown() and point then
		if db.classbar.fill == 'spaced' then
			frame.Health:SetPoint(point, frame, anchorPoint, x, -7)
		else
			frame.Health:SetPoint(point, frame, anchorPoint, x, -13)
		end
	elseif point then
		frame.Health:SetPoint(point, frame, anchorPoint, x, -2)
	end
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown())
end	

function UF:UpdateHarmony()
	local maxBars = self.numPoints
	local frame = self:GetParent()
	local db = frame.db
	if not db then return; end
	
	local UNIT_WIDTH = db.width
	local CLASSBAR_WIDTH = db.width - 4
	local BORDER = 2
	local SPACING = 1
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local POWERBAR_OFFSET = db.power.offset
	local USE_POWERBAR = db.power.enable
	local USE_MINI_POWERBAR = db.power.width ~= 'fill' and USE_POWERBAR
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR
	
	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0	
	end
	
	if USE_PORTRAIT then
		CLASSBAR_WIDTH = math.ceil((UNIT_WIDTH - (BORDER*2)) - PORTRAIT_WIDTH)
	end
	
	if USE_POWERBAR_OFFSET then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
	end	
	
	if db.classbar.fill == 'spaced' then
		SPACING = 9
		
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (maxBars - 1) / maxBars
	end
	
	for i=1, UF['classMaxResourceBar'][E.myclass] do
		if self[i]:IsShown() and db.classbar.fill == 'spaced' then
			self[i].backdrop:Show()
		else
			self[i].backdrop:Hide()
		end
	end
	
	self:SetWidth(CLASSBAR_WIDTH)
	
	for i = 1, maxBars do		
		self[i]:SetHeight(self:GetHeight())	
		if db.classbar.fill == 'spaced' then
			self[i]:SetWidth(E:Scale(self:GetWidth() - 3)/maxBars)	
		else
			self[i]:SetWidth(E:Scale(self:GetWidth() - 4)/maxBars)	
		end
		self[i]:ClearAllPoints()
		if i == 1 then
			if maxBars == 5 and db.classbar.fill == 'spaced' then
				self[i]:SetPoint("LEFT", self, 'LEFT', -(SPACING/2), 0)
			else
				self[i]:SetPoint("LEFT", self)
			end
		else
			self[i]:Point("LEFT", self[i-1], "RIGHT", SPACING , 0)
		end
		self[i]:SetStatusBarColor(unpack(ElvUF.colors.harmony[i]))
	end	
end

function UF:UpdateShardBar(spec)
	local maxBars = self.number
	local db = self:GetParent().db
	local frame = self:GetParent()
	
	for i=1, UF['classMaxResourceBar'][E.myclass] do
		if self[i]:IsShown() and db.classbar.fill == 'spaced' then
			self[i].backdrop:Show()
		else
			self[i].backdrop:Hide()
		end
	end

	if db.classbar.fill == 'spaced' and maxBars == 1 then
		self:ClearAllPoints()
		self:Point("LEFT", frame.Health.backdrop, "TOPLEFT", 8, 0)
	elseif db.classbar.fill == 'spaced' then
		self:ClearAllPoints()
		self:Point("CENTER", frame.Health.backdrop, "TOP", -12, -2)
	end
	
	local SPACING = 1
	if db.classbar.fill == 'spaced' then
		SPACING = 13
	end
	
	for i = 1, maxBars do
		self[i]:SetHeight(self:GetHeight())	
		self[i]:SetWidth(E:Scale(self:GetWidth() - 2)/maxBars)	
		self[i]:ClearAllPoints()
		if i == 1 then
			self[i]:SetPoint("LEFT", self)
		else
			self[i]:Point("LEFT", self[i-1], "RIGHT", SPACING , 0)
		end		
	end
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown())
end

function UF:EclipseDirection()
	local direction = GetEclipseDirection()
	if direction == "sun" then
		self.Text:SetText(">")
		self.Text:SetTextColor(.2,.2,1,1)
	elseif direction == "moon" then
		self.Text:SetText("<")
		self.Text:SetTextColor(1,1,.3, 1)
	else
		self.Text:SetText("")
	end
end

function UF:DruidResourceBarVisibilityUpdate(unit)
	local eclipseBar = self:GetParent().EclipseBar
	local druidAltMana = self:GetParent().DruidAltMana
	
	UF:UpdatePlayerFrameAnchors(self:GetParent(), eclipseBar:IsShown() or druidAltMana:IsShown())
end

function UF:DruidPostUpdateAltPower(unit, min, max)
	local powerText = self:GetParent().Power.value
	
	if min ~= max then
		local color = ElvUF['colors'].power['MANA']
		color = E:RGBToHex(color[1], color[2], color[3])
		
		self.Text:ClearAllPoints()
		if powerText:GetText() then
			if select(4, powerText:GetPoint()) < 0 then
				self.Text:SetPoint("RIGHT", powerText, "LEFT", 3, 0)
				self.Text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))			
			else
				self.Text:SetPoint("LEFT", powerText, "RIGHT", -3, 0)
				self.Text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
			end
		else
			self.Text:SetPoint(powerText:GetPoint())
			self.Text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
		end	
	else
		self.Text:SetText()
	end
end

function UF:UpdateThreat(event, unit)
	if (self.unit ~= unit) or not unit or not E.initialized then return end
	local status = UnitThreatSituation(unit)
	
	if status and status > 1 then
		local r, g, b = GetThreatStatusColor(status)
		if self.Threat and self.Threat:GetBackdrop() then
			self.Threat:Show()
			self.Threat:SetBackdropBorderColor(r, g, b)
		elseif self.Health.backdrop then
			self.Health.backdrop:SetBackdropBorderColor(r, g, b)
			
			if self.Power and self.Power.backdrop then
				self.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end
		end
	else
		if self.Threat and self.Threat:GetBackdrop() then
			self.Threat:Hide()
		elseif self.Health.backdrop then
			self.Health.backdrop:SetTemplate("Default")
			
			if self.Power and self.Power.backdrop then
				self.Power.backdrop:SetTemplate("Default")
			end
		end	
	end
end

function UF:UpdateTargetGlow(event)
	if not self.unit then return; end
	local unit = self.unit
	
	if UnitIsUnit(unit, 'target') then
		self.TargetGlow:Show()
		local reaction = UnitReaction(unit, 'player')
		
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			if class then
				local color = RAID_CLASS_COLORS[class]
				self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
			end
		elseif reaction then
			local color = FACTION_BAR_COLORS[reaction]
			self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
		end
	else
		self.TargetGlow:Hide()
	end
end

function UF:AltPowerBarPostUpdate(min, cur, max)
	local perc = math.floor((cur/max)*100)
	
	if perc < 35 then
		self:SetStatusBarColor(0, 1, 0)
	elseif perc < 70 then
		self:SetStatusBarColor(1, 1, 0)
	else
		self:SetStatusBarColor(1, 0, 0)
	end
	
	local unit = self:GetParent().unit
	
	if unit == "player" and self.text then 
		local type = select(10, UnitAlternatePowerInfo(unit))
				
		if perc > 0 then
			self.text:SetText(type..": "..format("%d%%", perc))
		else
			self.text:SetText(type..": 0%")
		end
	elseif unit and unit:find("boss%d") and self.text then
		self.text:SetTextColor(self:GetStatusBarColor())
		if not self:GetParent().Power.value:GetText() or self:GetParent().Power.value:GetText() == "" then
			self.text:Point("BOTTOMRIGHT", self:GetParent().Health, "BOTTOMRIGHT")
		else
			self.text:Point("RIGHT", self:GetParent().Power.value.value, "LEFT", 2, E.mult)	
		end
		if perc > 0 then
			self.text:SetText("|cffD7BEA5[|r"..format("%d%%", perc).."|cffD7BEA5]|r")
		else
			self.text:SetText(nil)
		end
	end
end

function UF:UpdateComboDisplay(event, unit)
	if(unit == 'pet') then return end
	local db = UF.player.db
	local cpoints = self.CPoints
	local cp
	if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
		cp = GetComboPoints('vehicle', 'target')
	else
		cp = GetComboPoints('player', 'target')
	end


	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			cpoints[i]:SetAlpha(1)
			
			if i == MAX_COMBO_POINTS and db.classbar.fill == 'spaced' then
				for c = 1, MAX_COMBO_POINTS do
					cpoints[c].backdrop.shadow:Show()
					cpoints[c]:SetScript('OnUpdate', function(self)
						E:Flash(self.backdrop.shadow, 0.6)
					end)
				end
			else
				for c = 1, MAX_COMBO_POINTS do
					cpoints[c].backdrop.shadow:Hide()
					cpoints[c]:SetScript('OnUpdate', nil)
				end
			end
		else
			cpoints[i]:SetAlpha(.15)
			for c = 1, MAX_COMBO_POINTS do
				cpoints[c].backdrop.shadow:Hide()
				cpoints[c]:SetScript('OnUpdate', nil)
			end		
		end	
	end
	
	local BORDER = E:Scale(2)
	local SPACING = E:Scale(1)
	local db = E.db['unitframe']['units'].target
	local USE_COMBOBAR = db.combobar.enable
	local USE_MINI_COMBOBAR = db.combobar.fill == "spaced" and USE_COMBOBAR
	local COMBOBAR_HEIGHT = db.combobar.height
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	

	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0
	end
	
	if cpoints[1]:GetAlpha() == 1 then
		cpoints:Show()
		if USE_MINI_COMBOBAR then
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -((COMBOBAR_HEIGHT/2) + SPACING - BORDER))
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(SPACING + (COMBOBAR_HEIGHT/2)))
		else
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(BORDER + SPACING + COMBOBAR_HEIGHT))
		end		

	else
		cpoints:Hide()
		self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT")
		self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -BORDER)
	end
end

function UF:AuraFilter(unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff)	
	if E.global.unitframe.InvalidSpells[spellID] then
		return false;
	end

	local isPlayer, isFriend

	local db = self:GetParent().db
	if not db or not db[self.type] then return true; end
	
	db = db[self.type]

	local returnValue = true;
	local returnValueChanged = false;
	if caster == 'player' or caster == 'vehicle' then isPlayer = true end
	if UnitIsFriend('player', unit) then isFriend = true end
	
	icon.isPlayer = isPlayer
	icon.owner = caster
	icon.name = name
	
	--This should be sorted as least priority checked first
	--most priority last
	
	if CheckFilter(db.playerOnly, isFriend) then
		if isPlayer then
			returnValue = true;
		elseif not returnValueChanged then
			returnValue = false;
		end
		returnValueChanged = true;
	end
	
	if CheckFilter(db.onlyDispellable, isFriend) then
		if (self.type == 'buffs' and isStealable) or (self.type == 'debuffs' and dtype and E:IsDispellableByMe(dtype)) then
			returnValue = true;
		elseif not returnValueChanged then
			returnValue = false;
		end
		returnValueChanged = true;
	end
	
	if CheckFilter(db.noConsolidated, isFriend) then
		if shouldConsolidate == 1 then
			returnValue = false;
		elseif not returnValueChanged then
			returnValue = true;
		end
		
		returnValueChanged = true;
	end
	
	if CheckFilter(db.noDuration, isFriend) then
		if (duration == 0 or not duration) then
			returnValue = false;
		elseif not returnValueChanged then
			returnValue = true;
		end
		
		returnValueChanged = true;
	end
	
	if CheckFilter(db.useBlacklist, isFriend) then
		if E.global['unitframe']['aurafilters']['Blacklist'].spells[name] and E.global['unitframe']['aurafilters']['Blacklist'].spells[name].enable then
			returnValue = false;
		elseif not returnValueChanged then
			returnValue = true;
		end
		
		returnValueChanged = true;
	end
	
	if CheckFilter(db.useWhitelist, isFriend) then
		if E.global['unitframe']['aurafilters']['Whitelist'].spells[name] and E.global['unitframe']['aurafilters']['Whitelist'].spells[name].enable then
			returnValue = true;
		elseif not returnValueChanged then
			returnValue = false;
		end
		
		returnValueChanged = true;
	end	

	if db.useFilter and E.global['unitframe']['aurafilters'][db.useFilter] then
		local type = E.global['unitframe']['aurafilters'][db.useFilter].type
		local spellList = E.global['unitframe']['aurafilters'][db.useFilter].spells

		if type == 'Whitelist' then
			if spellList[name] and spellList[name].enable then
				returnValue = true	
			elseif not returnValueChanged then
				returnValue = false
			end

		elseif type == 'Blacklist' and spellList[name] and spellList[name].enable then
			returnValue = false				
		end
	end		

	return returnValue	
end

local counterOffsets = {
	['TOPLEFT'] = {6, 1},
	['TOPRIGHT'] = {-6, 1},
	['BOTTOMLEFT'] = {6, 1},
	['BOTTOMRIGHT'] = {-6, 1},
	['LEFT'] = {6, 1},
	['RIGHT'] = {-6, 1},
	['TOP'] = {0, 0},
	['BOTTOM'] = {0, 0},
}

function UF:UpdateAuraWatch(frame)
	local buffs = {};
	local auras = frame.AuraWatch;
	local db = frame.db.buffIndicator;
	
	if not E.global['unitframe'].buffwatch[E.myclass] then E.global['unitframe'].buffwatch[E.myclass] = {} end

	if frame.unit == 'pet' and E.global['unitframe'].buffwatch.PET then
		for _, value in pairs(E.global['unitframe'].buffwatch.PET) do
			tinsert(buffs, value);
		end	
	else
		for _, value in pairs(E.global['unitframe'].buffwatch[E.myclass]) do
			tinsert(buffs, value);
		end	
	end
	
	for _, spell in pairs(buffs) do
		local icon;
		if spell["id"] then
			local name, _, image = GetSpellInfo(spell["id"]);
			if name then
				if not auras.icons[spell.id] then
					icon = CreateFrame("Frame", nil, auras);
				else
					icon = auras.icons[spell.id];
				end
				icon.name = name
				icon.image = image
				icon.spellID = spell["id"];
				icon.anyUnit = spell["anyUnit"];
				icon.onlyShowMissing = spell["onlyShowMissing"];
				if spell["onlyShowMissing"] then
					icon.presentAlpha = 0;
					icon.missingAlpha = 1;
				else
					icon.presentAlpha = 1;
					icon.missingAlpha = 0;		
				end		
				icon:Width(db.size);
				icon:Height(db.size);
				icon:ClearAllPoints()
				icon:SetPoint(spell["point"], 0, 0);

				if not icon.icon then
					icon.icon = icon:CreateTexture(nil, "BORDER");
					icon.icon:SetAllPoints(icon);
				end
				
				if db.colorIcons then
					icon.icon:SetTexture(E["media"].blankTex);
					
					if (spell["color"]) then
						icon.icon:SetVertexColor(spell["color"].r, spell["color"].g, spell["color"].b);
					else
						icon.icon:SetVertexColor(0.8, 0.8, 0.8);
					end			
				else
					icon.icon:SetTexCoord(.18, .82, .18, .82);
					icon.icon:SetTexture(icon.image);
				end
				
				if not icon.cd then
					icon.cd = CreateFrame("Cooldown", nil, icon)
					icon.cd:SetAllPoints(icon)
					icon.cd:SetReverse(true)
					icon.cd:SetFrameLevel(icon:GetFrameLevel())
				end
				
				if not icon.border then
					icon.border = icon:CreateTexture(nil, "BACKGROUND");
					icon.border:Point("TOPLEFT", -E.mult, E.mult);
					icon.border:Point("BOTTOMRIGHT", E.mult, -E.mult);
					icon.border:SetTexture(E["media"].blankTex);
					icon.border:SetVertexColor(0, 0, 0);
				end
				
				if not icon.count then
					icon.count = icon:CreateFontString(nil, "OVERLAY");
					icon.count:SetPoint("CENTER", unpack(counterOffsets[spell["point"]]));
				end
				icon.count:FontTemplate(LSM:Fetch("font", E.db['unitframe'].font), db.fontSize, 'OUTLINE');
				
				if spell["enabled"] then
					auras.icons[spell.id] = icon;
					if auras.watched then
						auras.watched[spell.id] = icon;
					end
				else	
					auras.icons[spell.id] = nil;
					if auras.watched then
						auras.watched[spell.id] = nil;
					end
					icon:Hide();
					icon = nil;
				end
			end
		end
	end
	
	if frame.AuraWatch.Update then
		frame.AuraWatch.Update(frame)
	end
	
	buffs = nil;
end

function UF:UpdateRoleIcon()
	local lfdrole = self.LFDRole
	local db = self.db.roleIcon;
	
	if not db then return; end
	local role = UnitGroupRolesAssigned(self.unit)

	if self.isForced then
		local rnd = math.random(1, 3)
		role = rnd == 1 and "TANK" or (rnd == 2 and "HEALER" or (rnd == 3 and "DAMAGER"))
	end
	
	if(role == 'TANK' or role == 'HEALER' or role == 'DAMAGER') and (UnitIsConnected(self.unit) or self.isForced) and db.enable then
		if role == 'TANK' then
			lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\tank.tga]])
		elseif role == 'HEALER' then
			lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]])
		elseif role == 'DAMAGER' then
			lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\dps.tga]])
		end
		
		lfdrole:Show()
	else
		lfdrole:Hide()
	end	
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local leader = anchor:GetParent().Leader
	local masterLooter = anchor:GetParent().MasterLooter

	if not leader or not masterLooter then return; end

	local unit = anchor:GetParent().unit
	local db = anchor:GetParent().db
	local isLeader = leader:IsShown()
	local isMasterLooter = masterLooter:IsShown()
	
	leader:ClearAllPoints()
	masterLooter:ClearAllPoints()
	
	if db and db.raidRoleIcons then
		if isLeader and db.raidRoleIcons.position == 'TOPLEFT' then
			leader:Point('LEFT', anchor, 'LEFT')
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		elseif isLeader and db.raidRoleIcons.position == 'TOPRIGHT' then
			leader:Point('RIGHT', anchor, 'RIGHT')
			masterLooter:Point('LEFT', anchor, 'LEFT')	
		elseif isMasterLooter and db.raidRoleIcons.position == 'TOPLEFT' then
			masterLooter:Point('LEFT', anchor, 'LEFT')	
		else
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		end
	end
end

local function CheckFilterArguement(option, optionArgs)
	if option ~= true then
		return true
	end

	return optionArgs
end

function UF:AuraBarFilter(unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID)
	local db = self.db.aurabar
	if not db then return; end
	local returnValue = true;
	local returnValueChanged = false
	local isPlayer, isFriend
	local auraType
	--print(name..': '..spellID, E.global.unitframe.InvalidSpells[spellID])
	if E.global.unitframe.InvalidSpells[spellID] then
		return false;
	end
	
	if unitCaster == 'player' or unitCaster == 'vehicle' then isPlayer = true end
	if UnitIsFriend('player', unit) then isFriend = true end
	if isFriend then
		auraType = db.friendlyAuraType
	else
		auraType = db.enemyAuraType
	end
	
	--This should be sorted as least priority checked first
	--most priority last

	if CheckFilter(db.playerOnly, isFriend) then
		if isPlayer then
			returnValue = true;
		elseif not returnValueChanged then
			returnValue = false;
		end
		returnValueChanged = true;
	end
	
	if CheckFilter(db.onlyDispellable, isFriend) then
		if (auraType == 'HELPFUL' and isStealable) or (auraType == 'HARMFUL' and debuffType and E:IsDispellableByMe(debuffType)) then
			returnValue = true;
		elseif not returnValueChanged then
			returnValue = false;
		end
		returnValueChanged = true;
	end	
	
	if CheckFilter(db.noConsolidated, isFriend) then
		if shouldConsolidate == 1 then
			returnValue = false;
		elseif not returnValueChanged then
			returnValue = true;
		end
		
		returnValueChanged = true;
	end
	
	if CheckFilter(db.noDuration, isFriend) then
		if (duration == 0 or not duration) then
			returnValue = false;
		elseif not returnValueChanged then
			returnValue = true;
		end
		
		returnValueChanged = true;
	end
	
	if CheckFilter(db.useBlacklist, isFriend) then
		if E.global['unitframe']['aurafilters']['Blacklist'].spells[name] and E.global['unitframe']['aurafilters']['Blacklist'].spells[name].enable then
			returnValue = false;
		elseif not returnValueChanged then
			returnValue = true;
		end
		
		returnValueChanged = true;
	end
	
	if CheckFilter(db.useWhitelist, isFriend) then
		if E.global['unitframe']['aurafilters']['Whitelist'].spells[name] and E.global['unitframe']['aurafilters']['Whitelist'].spells[name].enable then
			returnValue = true;
		elseif not returnValueChanged then
			returnValue = false;
		end
		
		returnValueChanged = true;
	end	

	if db.useFilter and E.global['unitframe']['aurafilters'][db.useFilter] then
		local type = E.global['unitframe']['aurafilters'][db.useFilter].type
		local spellList = E.global['unitframe']['aurafilters'][db.useFilter].spells

		if type == 'Whitelist' then
			if spellList[name] and spellList[name].enable then
				returnValue = true	
			elseif not returnValueChanged then
				returnValue = false
			end

		elseif type == 'Blacklist' and spellList[name] and spellList[name].enable then
			returnValue = false				
		end
	end		

	return returnValue	
end

function UF:ColorizeAuraBars(event, unit)
	local bars = self.bars
	for index = 1, #bars do
		local frame = bars[index]
		local bar = frame.statusBar
		if not frame:IsVisible() then
			break
		end
		local name = bar.aura.name
		local colors = E.global.unitframe.AuraBarColors[name]
		if E.global.unitframe.AuraBarColors[name] then
			bar:SetStatusBarColor(colors.r, colors.g, colors.b)
		end
	end
end

function UF:SmartAuraDisplay()
	local db = self.db
	local unit = self.unit
	if not db or not db.smartAuraDisplay or db.smartAuraDisplay == 'DISABLED' or not UnitExists(unit) then return; end
	local buffs = self.Buffs
	local debuffs = self.Debuffs
	local auraBars = self.AuraBars
	local isFriend
	
	if UnitIsFriend('player', unit) then isFriend = true end
	
	if isFriend then
		if db.smartAuraDisplay == 'SHOW_DEBUFFS_ON_FRIENDLIES' then
			buffs:Hide()
			debuffs:Show()
		else
			buffs:Show()
			debuffs:Hide()		
		end
	else
		if db.smartAuraDisplay == 'SHOW_DEBUFFS_ON_FRIENDLIES' then
			buffs:Show()
			debuffs:Hide()
		else
			buffs:Hide()
			debuffs:Show()		
		end
	end
	
	if buffs:IsShown() then
		local x, y = E:GetXYOffset(db.buffs.anchorPoint)
		
		buffs:ClearAllPoints()
		buffs:Point(E.InversePoints[db.buffs.anchorPoint], self, db.buffs.anchorPoint, x + db.buffs.xOffset, y + db.buffs.yOffset)
		
		local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
		if db.aurabar.anchorPoint == 'BELOW' then
			anchorPoint, anchorTo = 'TOP', 'BOTTOM'
		end		
		auraBars:ClearAllPoints()
		auraBars:SetPoint(anchorPoint..'LEFT', buffs, anchorTo..'LEFT', 0, 0)
		auraBars:SetPoint(anchorPoint..'RIGHT', buffs, anchorTo..'RIGHT')
	end
	
	if debuffs:IsShown() then
		local x, y = E:GetXYOffset(db.debuffs.anchorPoint)
		
		debuffs:ClearAllPoints()
		debuffs:Point(E.InversePoints[db.debuffs.anchorPoint], self, db.debuffs.anchorPoint, x + db.debuffs.xOffset, y + db.debuffs.yOffset)	

		local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
		if db.aurabar.anchorPoint == 'BELOW' then
			anchorPoint, anchorTo = 'TOP', 'BOTTOM'
		end		
		auraBars:ClearAllPoints()
		auraBars:SetPoint(anchorPoint..'LEFT', debuffs, anchorTo..'LEFT', 0, 0)
		auraBars:SetPoint(anchorPoint..'RIGHT', debuffs, anchorTo..'RIGHT')		
	end
end