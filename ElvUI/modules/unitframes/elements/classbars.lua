local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local select = select
local ceil, floor = math.ceil, math.floor
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local IsSpellKnown = IsSpellKnown
local GetEclipseDirection = GetEclipseDirection
local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER
local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS
local SHADOW_ORB_MINOR_TALENT_ID = SHADOW_ORB_MINOR_TALENT_ID
local SPELL_POWER_CHI = SPELL_POWER_CHI

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUF_Player

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")


local SPELL_POWER = {
	PALADIN = SPELL_POWER_HOLY_POWER,
	MONK = SPELL_POWER_CHI,
	PRIEST = SPELL_POWER_SHADOW_ORBS
}


function UF:SizeAndPosition_ClassBar(frame)
	local bars = frame[frame.ClassBar]
	if not bars then return end
	bars.origParent = frame
	
	if bars.UpdateAllRuneTypes then
		bars.UpdateAllRuneTypes(frame)
	end	
	
	local c = self.db.colors.classResources.bgColor
	bars.backdrop.ignoreUpdates = true
	bars.backdrop.backdropTexture:SetVertexColor(c.r, c.g, c.b)
	if(not E.PixelMode) then
		c = E.db.general.bordercolor
		bars.backdrop:SetBackdropBorderColor(c.r, c.g, c.b)
	end	

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)
		if E.myclass == 'DRUID' then
			frame.CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH * 2/3
		else
			frame.CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - frame.BORDER) / frame.MAX_CLASS_BAR
		end
		bars:SetFrameStrata("MEDIUM")

		if bars.mover then
			bars.mover:SetScale(0.000001)
			bars.mover:SetAlpha(0)
		end
	elseif not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING*3)
		bars:SetFrameStrata("LOW")

		if bars.mover then
			bars.mover:SetScale(0.000001)
			bars.mover:SetAlpha(0)
		end
	else
		frame.CLASSBAR_WIDTH = db.classbar.detachedWidth - (frame.BORDER*2)

		if not bars.mover then
			bars:Width(frame.CLASSBAR_WIDTH)
			bars:Height(frame.CLASSBAR_HEIGHT - (frame.BORDER + frame.SPACING*2))
			bars:ClearAllPoints()
			bars:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)
			E:CreateMover(bars, 'ClassBarMover', L["Classbar"], nil, nil, nil, 'ALL,SOLO')
		else
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.mover, "BOTTOMLEFT")
			bars.mover:SetScale(1)
			bars.mover:SetAlpha(1)
		end

		bars:SetFrameStrata("LOW")
	end

	bars:Width(frame.CLASSBAR_WIDTH)
	bars:Height(frame.CLASSBAR_HEIGHT - (frame.BORDER + frame.SPACING*2))	
	
	if E.myclass ~= 'DRUID' then
		for i = 1, (UF.classMaxResourceBar[E.myclass] or 0) do
			bars[i]:Hide()

			if i <= frame.MAX_CLASS_BAR then
				bars[i].backdrop.ignoreUpdates = true
				bars[i].backdrop.backdropTexture:SetVertexColor(c.r, c.g, c.b)
				if(not E.PixelMode) then
					c = E.db.general.bordercolor
					bars[i].backdrop:SetBackdropBorderColor(c.r, c.g, c.b)
				end
				bars[i]:Height(bars:GetHeight())
				if frame.USE_MINI_CLASSBAR then
					bars[i]:Width((bars:GetWidth() - ((frame.SPACING+(frame.BORDER*2)+frame.BORDER)*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR)
				elseif i ~= frame.MAX_CLASS_BAR then
					bars[i]:Width((frame.CLASSBAR_WIDTH - (frame.MAX_CLASS_BAR*(frame.BORDER-frame.SPACING))+(frame.BORDER-frame.SPACING)) / frame.MAX_CLASS_BAR)
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if i == 1 then
					bars[i]:Point("LEFT", bars)
				else
					if frame.USE_MINI_CLASSBAR then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.SPACING+(frame.BORDER*2)+2, 0)
					elseif i == frame.MAX_CLASS_BAR then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
						bars[i]:Point("RIGHT", bars)
					else
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
					end
				end

				if not frame.USE_MINI_CLASSBAR then
					bars[i].backdrop:Hide()
				else
					bars[i].backdrop:Show()
				end

				if E.myclass == 'ROGUE' then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors[frame.ClassBar][i]))

					if bars[i].bg then
						bars[i].bg:SetTexture(unpack(ElvUF.colors[frame.ClassBar][i]))
					end
				elseif E.myclass ~= 'DEATHKNIGHT' then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors[frame.ClassBar]))

					if bars[i].bg then
						bars[i].bg:SetTexture(unpack(ElvUF.colors[frame.ClassBar]))
					end
				end
				bars[i]:Show()
			end
		end
	else
		--?? Apparent bug fix for the width after in-game settings change
		bars.LunarBar:SetMinMaxValues(0, 0)
		bars.SolarBar:SetMinMaxValues(0, 0)
		bars.LunarBar:SetStatusBarColor(unpack(ElvUF.colors.EclipseBar[1]))
		bars.SolarBar:SetStatusBarColor(unpack(ElvUF.colors.EclipseBar[2]))
		bars.LunarBar:Size(frame.CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - (frame.BORDER + frame.SPACING*2))
		bars.SolarBar:Size(frame.CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - (frame.BORDER + frame.SPACING*2))
	end	
	

	if E.myclass ~= 'DRUID' then
		if not frame.USE_MINI_CLASSBAR then
			bars.backdrop:Show()
		else
			bars.backdrop:Hide()
		end
	end

	if frame.CLASSBAR_DETACHED and db.classbar.parent == "UIPARENT" then
		E.FrameLocks[bars] = true
		bars:SetParent(E.UIParent)
	else
		E.FrameLocks[bars] = nil
		bars:SetParent(frame)
	end

	if frame.db.classbar.enable and frame.CAN_HAVE_CLASSBAR and not frame:IsElementEnabled(frame.ClassBar) then
		frame:EnableElement(frame.ClassBar)
		bars:Show()
	elseif not frame.USE_CLASSBAR and frame:IsElementEnabled(frame.ClassBar) then
		frame:DisableElement(frame.ClassBar)
		bars:Hide()
	end	
end

local function ToggleResourceBar(bars)
	local frame = bars:GetParent()
	local db = frame.db
	if not db then return end
	frame.USE_CLASSBAR = bars:IsShown()

	frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.classbar.height or 0
	frame.CLASSBAR_YOFFSET = not frame.USE_CLASSBAR and 0 or (frame.USE_MINI_CLASSBAR and ((frame.SPACING+(frame.CLASSBAR_HEIGHT/2))) or frame.CLASSBAR_HEIGHT)	
	UF:SizeAndPosition_HealthBar(frame)
	UF:SizeAndPosition_Portrait(frame, true) --running :Hide on portrait makes the frame all funky
	UF:SizeAndPosition_Threat(frame)
end

function UF:Construct_PaladinResourceBar(frame, useBG, overrideFunc)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')
	
	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')
		bars[i].backdrop:SetParent(bars)
		
		if useBG then
			bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
			bars[i].bg:SetAllPoints()
			bars[i].bg:SetTexture(E['media'].blankTex)
			bars[i].bg.multiplier = 0.3		
		end
	end
	
	bars.Override = UF.Update_HolyPower
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)	

	return bars
end


function UF:Update_HolyPower(event, unit, powerType)
	if not (powerType == nil or powerType == 'HOLY_POWER') then return end
	
	local db = self.db
	if not db then return; end
	local numPower = UnitPower('player', SPELL_POWER[E.myclass]);
	local maxPower = UnitPowerMax('player', SPELL_POWER[E.myclass]);

	local bars = self[self.ClassBar]
	local isShown = bars:IsShown()
	if numPower == 0 and db.classbar.autoHide then
		bars:Hide()
	else
		bars:Show()
		for i = 1, maxPower do
			if(i <= numPower) then
				bars[i]:SetAlpha(1)
			else
				bars[i]:SetAlpha(.2)
			end
		end
	end
	
	if maxPower ~= self.MAX_CLASS_BAR then
		self.MAX_CLASS_BAR = maxPower
		UF:SizeAndPosition_ClassBar(self)
	end
end

-------------------------------------------------------------
-- MONK
-------------------------------------------------------------

function UF:Construct_MonkResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
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
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	local maxBars = self.numPoints
	local numChi = UnitPower("player", SPELL_POWER_CHI)
	local UNIT_WIDTH = db.width
	local BORDER = E.Border
	local SPACING = E.Spacing
	local CLASSBAR_WIDTH = db.width - (BORDER*2)
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local POWERBAR_OFFSET = db.power.offset
	local USE_POWERBAR = db.power.enable
	local POWERBAR_DETACHED = db.power.detachFromFrame
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR and not POWERBAR_DETACHED
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and db.classbar.enable
	local stagger = frame.Stagger
	local USE_STAGGER = stagger and stagger:IsShown();
	local STAGGER_WIDTH = USE_STAGGER and (db.stagger.width + (BORDER*2)) or 0;
	local CLASSBAR_HEIGHT = db.classbar.height
	local DETACHED = db.classbar.detachFromFrame
	local HEALTH_OFFSET_X = BORDER + STAGGER_WIDTH
	local HEALTH_OFFSET_Y = DETACHED and BORDER or USE_MINI_CLASSBAR and (BORDER+(CLASSBAR_HEIGHT/2)) or (BORDER+CLASSBAR_HEIGHT+SPACING)

	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0
	end

	if USE_PORTRAIT then
		CLASSBAR_WIDTH = ceil((CLASSBAR_WIDTH) - PORTRAIT_WIDTH)
	end

	if USE_POWERBAR_OFFSET then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
		HEALTH_OFFSET_X = HEALTH_OFFSET_X + POWERBAR_OFFSET
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

	self:Width(CLASSBAR_WIDTH)
	local colors = ElvUF.colors.Harmony

	if numChi == 0 and db.classbar.autoHide then
		self:Hide()
		--Comment out this code so we can test Stagger position
		-- frame.Health:Point("TOPRIGHT", frame, "TOPRIGHT", -HEALTH_OFFSET_X, -BORDER)
		-- frame.Health:Point("TOPLEFT", frame, "TOPLEFT", BORDER+PORTRAIT_WIDTH, -BORDER)
	else
		--Comment out this code so we can test Stagger position
		-- frame.Health:Point("TOPRIGHT", frame, "TOPRIGHT", -HEALTH_OFFSET_X, -HEALTH_OFFSET_Y)
		-- frame.Health:Point("TOPLEFT", frame, "TOPLEFT", BORDER+PORTRAIT_WIDTH, -HEALTH_OFFSET_Y)

		for i = 1, maxBars do
			self[i]:Height(self:GetHeight())
			if db.classbar.fill == "spaced" then
				self[i]:Width((self:GetWidth() - ((E.PixelMode and (maxBars == 5 and 4 or 7) or (maxBars == 5 and 6 or 9))*(maxBars - 1))) / maxBars)
			elseif i ~= maxBars then
				self[i]:Width((CLASSBAR_WIDTH - (maxBars*(BORDER-SPACING))+(BORDER-SPACING)) / maxBars)
			end
			self[i]:ClearAllPoints()

			if i == 1 then
				self[i]:Point("LEFT", self)
			else
				if USE_MINI_CLASSBAR then
					self[i]:Point("LEFT", self[i-1], "RIGHT", E.PixelMode and (maxBars == 5 and 4 or 7) or (maxBars == 5 and 6 or 9), 0)
				elseif i == maxBars then
					self[i]:Point("LEFT", self[i-1], "RIGHT", BORDER-SPACING, 0)
					self[i]:Point("RIGHT", self)
				else
					self[i]:Point("LEFT", self[i-1], "RIGHT", BORDER-SPACING, 0)
				end
			end

			self[i]:SetStatusBarColor(colors[i][1], colors[i][2], colors[i][3])
		end
	end
end

-------------------------------------------------------------
-- MAGE
-------------------------------------------------------------

function UF:Construct_MageResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)

		bars[i].bg = bars[i]:CreateTexture(nil, 'ARTWORK')

		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')
		bars[i].backdrop:SetParent(bars)
	end

	bars.PostUpdate = UF.UpdateArcaneCharges
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)	
	return bars
end

function UF:UpdateArcaneCharges(event, arcaneCharges, maxCharges)
	local frame = self.origParent or self:GetParent()
	if E.myspec == 1 and arcaneCharges == 0 then
		if frame.db.classbar.autoHide then
			self:Hide()
		else
			--Clear arcane charge statusbars
			for i = 1, maxCharges do
				self[i]:SetValue(0)
				self[i]:SetScript('OnUpdate', nil)
			end

			self:Show()
		end
	end
end

-------------------------------------------------------------
-- ROGUE
-------------------------------------------------------------

function UF:Construct_RogueResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)

		bars[i].bg = bars[i]:CreateTexture(nil, 'ARTWORK')

		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')
		bars[i].backdrop:SetParent(bars)
	end

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)	
	
	return bars
end


-------------------------------------------------------------
-- WARLOCK
-------------------------------------------------------------

function UF:Construct_WarlockResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		bars[i].bg = bars[i]:CreateTexture(nil, 'ARTWORK')
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')
		bars[i].backdrop:SetParent(bars)
	end

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)	
	
	return bars
end

-------------------------------------------------------------
-- PRIEST
-------------------------------------------------------------

function UF:Construct_PriestResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
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
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end
	local numPower = UnitPower('player', SPELL_POWER[E.myclass]);
	local maxPower = UnitPowerMax('player', SPELL_POWER[E.myclass]);

	local bars = self[self.ClassBar]
	local isShown = bars:IsShown()
	if numPower == 0 and db.classbar.autoHide then
		bars:Hide()
	else
		bars:Show()
		for i = 1, maxPower do
			if(i <= numPower) then
				bars[i]:SetAlpha(1)
			else
				bars[i]:SetAlpha(.2)
			end
		end
	end
	
	if maxPower ~= self.MAX_CLASS_BAR then
		self.MAX_CLASS_BAR = maxPower
		UF:SizeAndPosition_ClassBar(self)
	end	
end

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------

function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes:CreateBackdrop('Default')

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		runes[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, runes)
		UF['statusbars'][runes[i]] = true
		runes[i]:SetStatusBarTexture(E['media'].blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)

		runes[i]:CreateBackdrop('Default')
		runes[i].backdrop:SetParent(runes)

		runes[i].bg = runes[i]:CreateTexture(nil, 'BORDER')
		runes[i].bg:SetAllPoints()
		runes[i].bg:SetTexture(E['media'].blankTex)
		runes[i].bg.multiplier = 0.3
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
	lunarBar:Point('LEFT', eclipseBar)
	lunarBar:SetStatusBarTexture(E['media'].blankTex)
	UF['statusbars'][lunarBar] = true
	eclipseBar.LunarBar = lunarBar

	local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
	solarBar:Point('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT')
	solarBar:SetStatusBarTexture(E['media'].blankTex)
	UF['statusbars'][solarBar] = true
	eclipseBar.SolarBar = solarBar

	eclipseBar.Text = lunarBar:CreateFontString(nil, 'OVERLAY')
	eclipseBar.Text:FontTemplate(nil, 20)
	eclipseBar.Text:Point("CENTER", lunarBar:GetStatusBarTexture(), "RIGHT")

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
	local parent = self.origParent or self:GetParent()
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
				self.Text:Point("RIGHT", powerText, "LEFT", 3, 0)
				self.Text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
			else
				self.Text:Point("LEFT", powerText, "RIGHT", -3, 0)
				self.Text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
			end
		else
			self.Text:Point(powerText:GetPoint())
			self.Text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
		end
	else
		self.Text:SetText()
	end
end