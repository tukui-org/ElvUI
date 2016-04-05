local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local select, unpack = select, unpack
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

function UF:Configure_ClassBar(frame)
	local bars = frame[frame.ClassBar]
	if not bars then return end
	local db = frame.db
	bars.origParent = frame

	if bars.UpdateAllRuneTypes then
		bars.UpdateAllRuneTypes(frame)
	end

	--Fix height in case it is lower than the theme allows
	if (not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.classbar then db.classbar.height = 7 end
		UF.ToggleResourceBar(bars) --Trigger update to health if needed
	elseif (self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.classbar then db.classbar.height = 3 end
		UF.ToggleResourceBar(bars)  --Trigger update to health if needed
	end

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	local c = self.db.colors.classResources.bgColor
	bars.backdrop.ignoreUpdates = true
	bars.backdrop.backdropTexture:SetVertexColor(c.r, c.g, c.b)
	if(not E.PixelMode) then
		c = E.db.general.bordercolor
		if(self.thinBorders) then
			bars.backdrop:SetBackdropBorderColor(0, 0, 0)
		else
			bars.backdrop:SetBackdropBorderColor(c.r, c.g, c.b)
		end

	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)
		if E.myclass == 'DRUID' or frame.MAX_CLASS_BAR == 1 then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		end
		bars:SetFrameStrata("MEDIUM")

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.000001)
			bars.Holder.mover:SetAlpha(0)
		end
	elseif not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		--Account for Stagger by anchoring classbar to opposite side of where Stagger is
		if frame.ORIENTATION == "RIGHT" then
			bars:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -frame.BORDER, frame.SPACING*3)
		else
			bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING*3)
		end
		bars:SetFrameStrata("LOW")

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.000001)
			bars.Holder.mover:SetAlpha(0)
		end
	else
		CLASSBAR_WIDTH = db.classbar.detachedWidth - ((frame.BORDER + frame.SPACING)*2)
		if bars.Holder then bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height) end

		if not bars.Holder or (bars.Holder and not bars.Holder.mover) then
			bars.Holder = CreateFrame("Frame", nil, bars)
			bars.Holder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)
			bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)
			bars:Width(CLASSBAR_WIDTH)
			bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER+frame.SPACING)*2))
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(bars.Holder, 'ClassBarMover', L["Classbar"], nil, nil, nil, 'ALL,SOLO')
		else
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			bars.Holder.mover:SetScale(1)
			bars.Holder.mover:SetAlpha(1)
		end

		bars:SetFrameStrata("LOW")
	end

	bars:Width(CLASSBAR_WIDTH)
	bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

	if E.myclass ~= 'DRUID' then
		for i = 1, (UF.classMaxResourceBar[E.myclass] or 0) do
			bars[i]:Hide()
			bars[i].backdrop:Hide()

			if i <= frame.MAX_CLASS_BAR then
				bars[i].backdrop.ignoreUpdates = true
				bars[i].backdrop.backdropTexture:SetVertexColor(c.r, c.g, c.b)
				if(not E.PixelMode) then
					c = E.db.general.bordercolor
					bars[i].backdrop:SetBackdropBorderColor(c.r, c.g, c.b)
				end
				bars[i]:Height(bars:GetHeight())
				if frame.MAX_CLASS_BAR == 1 then
					bars[i]:SetWidth(CLASSBAR_WIDTH)
				elseif frame.USE_MINI_CLASSBAR then
					bars[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
				elseif i ~= frame.MAX_CLASS_BAR then
					bars[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if i == 1 then
					bars[i]:Point("LEFT", bars)
				else
					if frame.USE_MINI_CLASSBAR then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0) --5px spacing between borders of each button
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

				if E.myclass == "MONK" or E.myclass == "WARLOCK" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][i]))

					if bars[i].bg then
						bars[i].bg:SetTexture(unpack(ElvUF.colors.ClassBars[E.myclass][i]))
					end
				elseif E.myclass == "PRIEST" or E.myclass == "PALADIN" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass]))

					if bars[i].bg then
						bars[i].bg:SetTexture(unpack(ElvUF.colors.ClassBars[E.myclass]))
					end
				elseif E.myclass == 'ROGUE' then
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
		bars.LunarBar:Size(CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
		bars.SolarBar:Size(CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
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
	local frame = bars.origParent or bars:GetParent()
	local db = frame.db
	if not db then return end
	frame.CLASSBAR_SHOWN = bars:IsShown()

	local height
	if db.classbar then
		height = db.classbar.height
	elseif db.combobar then
		height = db.combobar.height
	elseif frame.AltPowerBar then
		height = db.power.height
	end

	if bars.text then
		if frame.CLASSBAR_SHOWN then
			bars.text:SetAlpha(1)
		else
			bars.text:SetAlpha(0)
		end
	end

	frame.CLASSBAR_HEIGHT = (frame.USE_CLASSBAR and (frame.CLASSBAR_SHOWN and height) or 0)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((frame.SPACING+(frame.CLASSBAR_HEIGHT/2))) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)))

	if not frame.CLASSBAR_DETACHED then --Only update when necessary
		UF:Configure_HealthBar(frame)
		UF:Configure_Portrait(frame, true) --running :Hide on portrait makes the frame all funky
		UF:Configure_Threat(frame)
	end
end
UF.ToggleResourceBar = ToggleResourceBar --Make available to combobar

-------------------------------------------------------------
-- MONK, PALADIN, PRIEST, WARLOCK
-------------------------------------------------------------
function UF:Construct_ClassBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default', nil, nil, self.thinBorders)

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default', nil, nil, self.thinBorders)
		bars[i].backdrop:SetParent(bars)
	end

	bars.PostUpdate = UF.UpdateClassBar
	bars.UpdateTexture = function() return end --We don't use textures but statusbars, so prevent errors

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateClassBar(cur, max, hasMaxChanged, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	local isShown = self:IsShown()
	if cur == 0 and db.classbar.autoHide then
		self:Hide()
	else
		self:Show()
	end

	if hasMaxChanged then
		frame.MAX_CLASS_BAR = max
		UF:Configure_ClassBar(frame)
	end
end

-------------------------------------------------------------
-- MAGE
-------------------------------------------------------------
function UF:Construct_MageResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default', nil, nil, self.thinBorders)

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)

		bars[i].bg = bars[i]:CreateTexture(nil, 'ARTWORK')

		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default', nil, nil, self.thinBorders)
		bars[i].backdrop:SetParent(bars)
	end

	bars.PostUpdate = UF.UpdateArcaneCharges
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)
	return bars
end

function UF:UpdateArcaneCharges(event, arcaneCharges, maxCharges)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	if E.myspec == 1 and arcaneCharges == 0 then
		if db.classbar.autoHide then
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
	bars:CreateBackdrop('Default', nil, nil, self.thinBorders)

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)

		bars[i].bg = bars[i]:CreateTexture(nil, 'ARTWORK')

		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default', nil, nil, self.thinBorders)
		bars[i].backdrop:SetParent(bars)
	end

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------
function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes:CreateBackdrop('Default', nil, nil, self.thinBorders)

	for i = 1, UF['classMaxResourceBar'][E.myclass] do
		runes[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, runes)
		UF['statusbars'][runes[i]] = true
		runes[i]:SetStatusBarTexture(E['media'].blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)

		runes[i]:CreateBackdrop('Default', nil, nil, self.thinBorders)
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
	eclipseBar:CreateBackdrop('Default', nil, nil, self.thinBorders)
	eclipseBar.PostUpdatePower = UF.EclipseDirection
	eclipseBar.PostUpdateVisibility = UF.EclipsePostUpdateVisibility

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
	dpower.PostUpdateVisibility = UF.DruidManaPostUpdateVisibility
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

local druidEclipseIsShown = false
local druidManaIsShown = false
function UF:EclipsePostUpdateVisibility()
	local isShown = self:IsShown()
	if druidEclipseIsShown ~= isShown then
		druidEclipseIsShown = isShown
		
		--Only toggle if the eclipse bar was not replaced with druid mana
		if not druidManaIsShown then
			ToggleResourceBar(self)
		end
	end
end

function UF:DruidManaPostUpdateVisibility()
	local isShown = self:IsShown()
	if druidManaIsShown ~= isShown then
		druidManaIsShown = isShown

		--Only toggle if the druid mana bar was not replaced with eclipse bar
		if not druidEclipseIsShown then
			ToggleResourceBar(self)
		end
	end
end