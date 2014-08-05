local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

-------------------------------------------------------------
-- PALADIN
-------------------------------------------------------------

function UF:Construct_PaladinResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do					
		bars[i] = CreateFrame("StatusBar", nil, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')
		bars[i].backdrop:SetParent(bars)
	end
	
	bars.Override = UF.UpdateHoly
	
	return bars
end

function UF:UpdateHoly(event, unit, powerType)
	if (self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end
	local db = self.db
	if not db then return; end
	local BORDER = E.Border
	local numHolyPower = UnitPower('player', SPELL_POWER_HOLY_POWER);
	local maxHolyPower = UnitPowerMax('player', SPELL_POWER_HOLY_POWER);	
	local MAX_HOLY_POWER = UF['classMaxResourceBar'][E.myclass]
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and db.classbar.enable
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local POWERBAR_DETACHED = db.power.detachFromFrame
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR and not POWERBAR_DETACHED
	
	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0		
	end	
	
	local CLASSBAR_WIDTH = db.width - (E.Border * 2)
	if USE_PORTRAIT then
		CLASSBAR_WIDTH = ceil((db.width - (BORDER*2)) - PORTRAIT_WIDTH)
	end
	
	if USE_POWERBAR_OFFSET then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH - db.power.offset
	end
		
	if USE_MINI_CLASSBAR then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (maxHolyPower - 1) / maxHolyPower
	end

	if db.classbar.detachFromFrame then
		CLASSBAR_WIDTH = db.classbar.detachedWidth - (BORDER*2)
	end
	
	self.HolyPower:Width(CLASSBAR_WIDTH)
	
	for i = 1, MAX_HOLY_POWER do
		if(i <= numHolyPower) then
			self.HolyPower[i]:SetAlpha(1)
		else
			self.HolyPower[i]:SetAlpha(.2)
		end
		if db.classbar.fill == "spaced" then
			self.HolyPower[i]:SetWidth((self.HolyPower:GetWidth() - ((maxHolyPower == 5 and 7 or 13)*(maxHolyPower - 1))) / maxHolyPower)
		else
			self.HolyPower[i]:SetWidth((self.HolyPower:GetWidth() - (maxHolyPower - 1)) / maxHolyPower)	
		end
		
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

-------------------------------------------------------------
-- MONK
-------------------------------------------------------------

function UF:Construct_MonkResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do					
		bars[i] = CreateFrame("StatusBar", nil, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')
		bars[i].backdrop:SetParent(bars)
	end
	
	bars.PostUpdate = UF.UpdateHarmony
	
	return bars
end

function UF:UpdateHarmony()
	local maxBars = self.numPoints
	local frame = self:GetParent()
	local db = frame.db
	if not db then return; end
	
	local UNIT_WIDTH = db.width
	local BORDER = E.Border
	local CLASSBAR_WIDTH = db.width - (BORDER*2)
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local POWERBAR_OFFSET = db.power.offset
	local USE_POWERBAR = db.power.enable
	local POWERBAR_DETACHED = db.power.detachFromFrame
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR and not POWERBAR_DETACHED
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and db.classbar.enable
	
	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0	
	end
	
	if USE_PORTRAIT then
		CLASSBAR_WIDTH = ceil((CLASSBAR_WIDTH) - PORTRAIT_WIDTH)
	end
	
	if USE_POWERBAR_OFFSET then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
	end	
	
	if db.classbar.fill == 'spaced' then	
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (maxBars - 1) / maxBars
	end

	if db.classbar.detachFromFrame then
		CLASSBAR_WIDTH = db.classbar.detachedWidth - (BORDER*2)
	end	
	
	for i=1, UF['classMaxResourceBar'][E.myclass] do
		if self[i]:IsShown() and db.classbar.fill == 'spaced' then
			self[i].backdrop:Show()
		else
			self[i].backdrop:Hide()
		end
	end
	
	self:SetWidth(CLASSBAR_WIDTH)
	local colors = ElvUF.colors.Harmony
	for i = 1, maxBars do		
		self[i]:SetHeight(self:GetHeight())	
		if db.classbar.fill == "spaced" then
			self[i]:SetWidth((self:GetWidth() - ((E.PixelMode and (maxBars == 5 and 4 or 7) or (maxBars == 5 and 6 or 9))*(maxBars - 1))) / maxBars)
		else
			self[i]:SetWidth((self:GetWidth() - (maxBars - 1)) / maxBars)	
		end
		self[i]:ClearAllPoints()
		
		if i == 1 then
			self[i]:SetPoint("LEFT", self)
		else
			if USE_MINI_CLASSBAR then
				self[i]:Point("LEFT", self[i-1], "RIGHT", E.PixelMode and (maxBars == 5 and 4 or 7) or (maxBars == 5 and 6 or 9), 0)
			else
				self[i]:Point("LEFT", self[i-1], "RIGHT", 1, 0)
			end
		end	

		self[i]:SetStatusBarColor(colors[i][1], colors[i][2], colors[i][3])
	end	
end

function UF:Construct_Stagger(frame)
	local stagger = CreateFrame("Statusbar", nil, frame)
	UF['statusbars'][stagger] = true
	stagger:CreateBackdrop("Default")
	stagger:SetOrientation("VERTICAL")
	stagger.PostUpdate = UF.PostUpdateStagger
	return stagger
end

function UF:PostUpdateStagger()
	UF:UpdatePlayerFrameAnchors(ElvUF_Player, (ElvUF_Player.Harmony and ElvUF_Player.Harmony:IsShown()))
end

-------------------------------------------------------------
-- MAGE
-------------------------------------------------------------

function UF:Construct_MageResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do					
		bars[i] = CreateFrame("StatusBar", nil, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		
		bars[i].bg = bars[i]:CreateTexture(nil, 'ARTWORK')
		
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')
		bars[i].backdrop:SetParent(bars)
	end
	
	bars.PostUpdate = UF.UpdateArcaneCharges
	
	return bars
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

-------------------------------------------------------------
-- WARLOCK
-------------------------------------------------------------

function UF:Construct_WarlockResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do					
		bars[i] = CreateFrame("StatusBar", nil, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		bars[i].bg = bars[i]:CreateTexture(nil, 'ARTWORK')
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')		
		bars[i].backdrop:SetParent(bars)
	end
	
	bars.PostUpdate = UF.UpdateShardBar
	
	return bars
end

function UF:UpdateShardBar(spec)
	local frame = self:GetParent()
	local db = frame.db
	
	if not db then return; end
	local maxBars = self.number
	
	for i=1, UF['classMaxResourceBar'][E.myclass] do
		if self[i]:IsShown() and db.classbar.fill == 'spaced' then
			self[i].backdrop:Show()
		else
			self[i].backdrop:Hide()
		end
	end

	if not db.classbar.detachFromFrame then
		if db.classbar.fill == 'spaced' and maxBars == 1 then
			self:ClearAllPoints()
			self:Point("LEFT", frame.Health.backdrop, "TOPLEFT", 8, 0)
		elseif db.classbar.fill == 'spaced' then
			self:ClearAllPoints()
			self:Point("CENTER", frame.Health.backdrop, "TOP", -12, -2)
		end
	end

	local SPACING = db.classbar.fill == 'spaced' and 11 or 1
	for i = 1, maxBars do
		self[i]:SetHeight(self:GetHeight())	
		self[i]:SetWidth((self:GetWidth() - (SPACING*(maxBars - 1))) / maxBars)
		self[i]:ClearAllPoints()
		if i == 1 then
			self[i]:SetPoint("LEFT", self)
		else
			self[i]:Point("LEFT", self[i-1], "RIGHT", SPACING, 0)
		end		
	end
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown())
end

-------------------------------------------------------------
-- PRIEST
-------------------------------------------------------------

function UF:Construct_PriestResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do					
		bars[i] = CreateFrame("StatusBar", nil, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')		
		bars[i].backdrop:SetParent(bars)
	end
	
	bars.PostUpdate = UF.UpdateShadowOrbs
	
	return bars
end

function UF:UpdateShadowOrbs(event, unit, powerType)
	local frame = self:GetParent()
	local db = frame.db
		
	local point, _, anchorPoint, x, y = frame.Health:GetPoint()
	if self:IsShown() and point and not db.classbar.detachFromFrame then
		if db.classbar.fill == 'spaced' then
			frame.Health:SetPoint(point, frame, anchorPoint, x, -7)
		else
			frame.Health:SetPoint(point, frame, anchorPoint, x, -13)
		end
	elseif point then
		frame.Health:SetPoint(point, frame, anchorPoint, x, -2)
	end

	local BORDER = E.Border
	local numShadowOrbs = UnitPower("player", SPELL_POWER_SHADOW_ORBS);
	local maxShadowOrbs = IsSpellKnown(SHADOW_ORB_MINOR_TALENT_ID) and 5 or 3	
	local MAX_SHADOW_ORBS = UF['classMaxResourceBar'][E.myclass]
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and db.classbar.enable
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local POWERBAR_DETACHED = db.power.detachFromFrame
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR and not POWERBAR_DETACHED
	
	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0		
	end	
	
	local CLASSBAR_WIDTH = db.width - (E.Border * 2)
	if USE_PORTRAIT then
		CLASSBAR_WIDTH = ceil((db.width - (BORDER*2)) - PORTRAIT_WIDTH)
	end
	
	if USE_POWERBAR_OFFSET then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH - db.power.offset
	end
		
	if USE_MINI_CLASSBAR then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (maxHolyPower - 1) / maxHolyPower
	end

	if db.classbar.detachFromFrame then
		CLASSBAR_WIDTH = db.classbar.detachedWidth - (BORDER*2)
	end
	
	self:Width(CLASSBAR_WIDTH)
	
	for i = 1, MAX_SHADOW_ORBS do
		if(i <= numShadowOrbs) then
			self[i]:SetAlpha(1)
		else
			self[i]:SetAlpha(.2)
		end
		if db.classbar.fill == "spaced" then
			self[i]:SetWidth((self:GetWidth() - ((maxShadowOrbs == 5 and 7 or 13)*(maxShadowOrbs - 1))) / maxShadowOrbs)
		else
			self[i]:SetWidth((self:GetWidth() - (maxShadowOrbs - 1)) / maxShadowOrbs)	
		end
		
		self[i]:ClearAllPoints()
		if i == 1 then
			self[i]:SetPoint("LEFT", self)
		else
			if USE_MINI_CLASSBAR then
				self[i]:Point("LEFT", self[i-1], "RIGHT", maxShadowOrbs == 5 and 7 or 13, 0)
			else
				self[i]:Point("LEFT", self[i-1], "RIGHT", 1, 0)
			end
		end

		if i > maxShadowOrbs then
			self[i]:Hide()
			self[i].backdrop:SetAlpha(0)
		else
			self[i]:Show()
			self[i].backdrop:SetAlpha(1)
		end		
	end	
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown())
end	

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------

function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes:CreateBackdrop('Default')
	
	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		runes[i] = CreateFrame("StatusBar", nil, runes)
		UF['statusbars'][runes[i]] = true
		runes[i]:SetStatusBarTexture(E['media'].blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)
		
		runes[i]:CreateBackdrop('Default')
		runes[i].backdrop:SetParent(runes)
		
		runes[i].bg = runes[i]:CreateTexture(nil, 'BORDER')
		runes[i].bg:SetAllPoints()
		runes[i].bg:SetTexture(E['media'].blankTex)
		runes[i].bg.multiplier = 0.2
	end
	
	return runes
end

-------------------------------------------------------------
-- DRUID
-------------------------------------------------------------

function UF:Construct_DruidResourceBar(frame)
	local eclipseBar = CreateFrame('Frame', nil, frame)
	eclipseBar:CreateBackdrop('Default')
	eclipseBar.PostUpdatePower = UF.EclipseDirection
	eclipseBar.PostUpdateVisibility = UF.DruidResourceBarVisibilityUpdate
	
	local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
	lunarBar:SetPoint('LEFT', eclipseBar)
	lunarBar:SetStatusBarTexture(E['media'].blankTex)
	UF['statusbars'][lunarBar] = true
	eclipseBar.LunarBar = lunarBar

	local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
	solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT')
	solarBar:SetStatusBarTexture(E['media'].blankTex)
	UF['statusbars'][solarBar] = true
	eclipseBar.SolarBar = solarBar
	
	eclipseBar.Text = lunarBar:CreateFontString(nil, 'OVERLAY')
	eclipseBar.Text:FontTemplate(nil, 20)
	eclipseBar.Text:SetPoint("CENTER", lunarBar:GetStatusBarTexture(), "RIGHT")
	
	return eclipseBar
end

function UF:Construct_DruidAltManaBar(frame)
	local dpower = CreateFrame('Frame', nil, frame)
	dpower:SetFrameStrata("LOW")
	dpower:SetAllPoints(frame.EclipseBar.backdrop)
	dpower:SetTemplate("Default")
	dpower:SetFrameLevel(dpower:GetFrameLevel() + 1)
	dpower.colorPower = true
	dpower.PostUpdateVisibility = UF.DruidResourceBarVisibilityUpdate
	dpower.PostUpdatePower = UF.DruidPostUpdateAltPower
	
	dpower.ManaBar = CreateFrame('StatusBar', nil, dpower)
	UF['statusbars'][dpower.ManaBar] = true
	dpower.ManaBar:SetStatusBarTexture(E["media"].blankTex)
	dpower.ManaBar:SetInside(dpower)
	
	dpower.bg = dpower:CreateTexture(nil, "BORDER")
	dpower.bg:SetAllPoints(dpower.ManaBar)
	dpower.bg:SetTexture(E["media"].blankTex)
	dpower.bg.multiplier = 0.3

	dpower.Text = dpower:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(dpower.Text)
	
	return dpower
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
	local parent = self:GetParent()
	local eclipseBar = parent.EclipseBar
	local druidAltMana = parent.DruidAltMana
	
	UF:UpdatePlayerFrameAnchors(parent, eclipseBar:IsShown() or druidAltMana:IsShown())
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