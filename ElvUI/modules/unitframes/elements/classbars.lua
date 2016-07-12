local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local select, unpack = select, unpack
local ceil, floor = math.ceil, math.floor
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUF_Player

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

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
		if frame.ClassBar ~= "ClassIcons" then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH
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

	if (frame.ClassBar == 'ClassIcons' or frame.ClassBar == 'Runes') then
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

				if E.myclass == "MONK" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][i]))
				elseif E.myclass == "PALADIN" or E.myclass == "MAGE" or E.myclass == "WARLOCK" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass]))
				elseif E.myclass == "ROGUE" or E.myclass == "DRUID" then
					local r1, g1, b1 = unpack(ElvUF.colors.ComboPoints[1])
					local r2, g2, b2 = unpack(ElvUF.colors.ComboPoints[2])
					local r3, g3, b3 = unpack(ElvUF.colors.ComboPoints[3])

					local r, g, b = ElvUF.ColorGradient(i, frame.MAX_CLASS_BAR > 5 and 6 or 5, r1, g1, b1, r2, g2, b2, r3, g3, b3)
					bars[i]:SetStatusBarColor(r, g, b)
				elseif E.myclass == "DEATHKNIGHT" then
					local r, g, b = unpack(ElvUF.colors.ClassBars.DEATHKNIGHT)
					bars[i]:SetStatusBarColor(r, g, b)
					if (bars[i].bg) then
						local mu = bars[i].bg.multiplier or 1
						bars[i].bg:SetVertexColor(r * mu, g * mu, b * mu)
					end
				else
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors[frame.ClassBar]))
				end
				bars[i]:Show()
			end
		end
	else
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
-- MONK, PALADIN, WARLOCK, MAGE, and COMBOS
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

		bars[i].bg = bars:CreateTexture(nil, 'OVERLAY')
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E['media'].blankTex)
	end

	bars.PostUpdate = UF.UpdateClassBar
	bars.UpdateTexture = function() return end --We don't use textures but statusbars, so prevent errors

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateClassBar(cur, max, hasMaxChanged, powerType, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	local isShown = self:IsShown()
	if cur == 0 and db.classbar.autoHide or max == nil then
		self:Hide()
	else
		self:Show()
	end

	local r, g, b
	for i=1, #self do
		r, g, b = self[i]:GetStatusBarColor()
		self[i].bg:SetVertexColor(r, g, b, 0.15)
		if(max and (i <= max)) then
			self[i].bg:Show()
		else
			self[i].bg:Hide()
		end
	end

	if hasMaxChanged then
		frame.MAX_CLASS_BAR = max
		UF:Configure_ClassBar(frame)
	end
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
-- ALTERNATIVE MANA BAR
-------------------------------------------------------------
function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame('StatusBar', nil, frame)
	additionalPower:SetFrameStrata("LOW")
	additionalPower:SetFrameLevel(additionalPower:GetFrameLevel() + 1)
	additionalPower.colorPower = true
	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateVisibility = UF.PostUpdateVisibilityAdditionalPower
	additionalPower:CreateBackdrop('Default')
	UF['statusbars'][additionalPower] = true
	additionalPower:SetStatusBarTexture(E["media"].blankTex)

	additionalPower.bg = additionalPower:CreateTexture(nil, "BORDER")
	additionalPower.bg:SetAllPoints(additionalPower)
	additionalPower.bg:SetTexture(E["media"].blankTex)
	additionalPower.bg.multiplier = 0.3

	additionalPower.text = additionalPower:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(additionalPower.text)
	
	additionalPower:SetScript("OnShow", ToggleResourceBar)
	additionalPower:SetScript("OnHide", ToggleResourceBar)

	return additionalPower
end

function UF:PostUpdateAdditionalPower(unit, min, max, event)
	local frame = self:GetParent()
	local powerValue = frame.Power.value
	local powerValueText = powerValue:GetText()
	local powerValueParent = powerValue:GetParent()
	local db = frame.db

	local powerTextPosition = db.power.position

	if powerValueText then powerValueText = powerValueText:gsub("|cff(.*) ", "") end --Remove possible [powercolor] tag

	if min ~= max and (event ~= "ElementDisable") then
		local color = ElvUF['colors'].power['MANA']
		color = E:RGBToHex(color[1], color[2], color[3])

		self.text:SetParent(powerValueParent)
		self.text:ClearAllPoints()

		if (powerValueText ~= "" and powerValueText ~= " ") then
			if find(powerTextPosition, "RIGHT") then
				self.text:Point("RIGHT", powerValue, "LEFT", 3, 0)
				self.text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
			elseif find(powerTextPosition, "LEFT") then
				self.text:Point("LEFT", powerValue, "RIGHT", -3, 0)
				self.text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
			else
				if select(4, powerValue:GetPoint()) <= 0 then
					self.text:Point("LEFT", powerValue, "RIGHT", -3, 0)
					self.text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
				else
					self.text:Point("RIGHT", powerValue, "LEFT", 3, 0)
					self.text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
				end
			end
		else
			self.text:Point(powerValue:GetPoint())
			self.text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
		end
	else
		self.text:SetText()
		self:Hide()
	end
end

function UF:PostVisibilityAdditionalPower(enabled, stateChanged)
	local frame = self:GetParent()

	if enabled then
		frame.ClassBar = 'AdditionalPower'
	else
		frame.ClassBar = 'ClassIcons'
		self.text:SetText()
		ToggleResourceBar(frame.ClassIcons)
		return
	end

	if stateChanged then
		ToggleResourceBar(frame.AdditionalPower)
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

function UF:ToggleAdditionalPower(frame)
	if frame.AdditionalPower then
		if frame.db.power.additionalPower then
			frame:EnableElement('AdditionalPower')
		else
			frame:DisableElement('AdditionalPower')
		end
	end
end

-----------------------------------------------------------
-- Stagger Bar
-----------------------------------------------------------
function UF:Construct_Stagger(frame)
	local stagger = CreateFrame("Statusbar", nil, frame)
	UF['statusbars'][stagger] = true
	stagger:CreateBackdrop("Default",nil, nil, self.thinBorders)
	stagger.PostUpdateVisibility = UF.PostUpdateStagger
	stagger:SetFrameStrata("LOW")
	return stagger
end

function UF:PostUpdateStagger(event, unit, isShown, stateChanged)
	local frame = self
	local db = frame.db

	if(isShown) then
		frame.ClassBar = 'Stagger'
	else
		frame.ClassBar = 'ClassIcons'
	end

	--Only update when necessary
	if(stateChanged) then
		ToggleResourceBar(frame.Stagger)
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end