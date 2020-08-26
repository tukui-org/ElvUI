local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local max = max
local unpack = unpack
local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS
-- GLOBALS: ElvUF_Player

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, 'ElvUI was unable to locate oUF.')

function UF:Configure_ClassBar(frame, cur)
	local bars = frame[frame.ClassBar]
	if not bars then return end

	local db = frame.db
	bars.Holder = frame.ClassBarHolder
	bars.origParent = frame

	--Fix height in case it is lower than the theme allows, or in case it's higher than 30px when not detached
	if (not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.classbar then db.classbar.height = 7 end
		UF.ToggleResourceBar(bars) --Trigger update to health if needed
	elseif (self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.classbar then db.classbar.height = 3 end
		UF.ToggleResourceBar(bars)  --Trigger update to health if needed
	elseif (not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30) then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
		--Override visibility if Classbar is Additional Power in order to fix a bug when Auto Hide is enabled, height is higher than 30 and it goes from detached to not detached
		local overrideVisibility = frame.ClassBar == 'AdditionalPower'
		UF.ToggleResourceBar(bars, overrideVisibility)  --Trigger update to health if needed
	end

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	local color = E.db.unitframe.colors.borderColor
	if not bars.backdrop.ignoreBorderColors then
		bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		if frame.MAX_CLASS_BAR == 1 or frame.ClassBar == 'AdditionalPower' or frame.ClassBar == 'Stagger' or frame.ClassBar == 'AlternativePower' then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		end
	elseif frame.CLASSBAR_DETACHED then --Detached
		CLASSBAR_WIDTH = db.classbar.detachedWidth - ((frame.BORDER + frame.SPACING)*2)
	end

	bars:SetWidth(CLASSBAR_WIDTH)
	bars:SetHeight(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

	if (frame.ClassBar == 'ClassPower' or frame.ClassBar == 'Runes') then
		--This fixes issue with ComboPoints showing as active when they are not.
		if frame.ClassBar == 'ClassPower' and not cur then
			cur = 0
		end

		if E.myclass == 'DEATHKNIGHT' and frame.ClassBar == 'Runes' then
			bars.sortOrder = (db.classbar.sortDirection ~= 'NONE') and db.classbar.sortDirection
		end

		local maxClassBarButtons = max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS)
		for i = 1, maxClassBarButtons do
			bars[i]:Hide()
			bars[i].backdrop:Hide()

			if i <= frame.MAX_CLASS_BAR then
				bars[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

				bars[i]:SetHeight(bars:GetHeight())
				if frame.MAX_CLASS_BAR == 1 then
					bars[i]:SetWidth(CLASSBAR_WIDTH)
				elseif frame.USE_MINI_CLASSBAR then
					if frame.CLASSBAR_DETACHED and db.classbar.orientation == 'VERTICAL' then
						bars[i]:SetWidth(CLASSBAR_WIDTH)
					else
						bars[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
					end
				elseif i ~= frame.MAX_CLASS_BAR then
					bars[i]:SetWidth((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if i == 1 then
					bars[i]:SetPoint('LEFT', bars)
				else
					if frame.USE_MINI_CLASSBAR then
						if frame.CLASSBAR_DETACHED and db.classbar.orientation == 'VERTICAL' then
							bars[i]:SetPoint('BOTTOM', bars[i-1], 'TOP', 0, (db.classbar.spacing + frame.BORDER*2 + frame.SPACING*2))
						else
							bars[i]:SetPoint('LEFT', bars[i-1], 'RIGHT', (db.classbar.spacing + frame.BORDER*2 + frame.SPACING*2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
						end
					elseif i == frame.MAX_CLASS_BAR then
						bars[i]:SetPoint('LEFT', bars[i-1], 'RIGHT', frame.BORDER-frame.SPACING, 0)
						bars[i]:SetPoint('RIGHT', bars)
					else
						bars[i]:SetPoint('LEFT', bars[i-1], 'RIGHT', frame.BORDER-frame.SPACING, 0)
					end
				end

				if not frame.USE_MINI_CLASSBAR then
					bars[i].backdrop:Hide()
				else
					bars[i].backdrop:Show()
				end

				if E.myclass == 'MONK' then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][i]))
				elseif E.myclass == 'PALADIN' or E.myclass == 'MAGE' or E.myclass == 'WARLOCK' then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass]))
				elseif E.myclass == 'DEATHKNIGHT' and frame.ClassBar == 'Runes' then
					local r, g, b = unpack(ElvUF.colors.ClassBars.DEATHKNIGHT)
					bars[i]:SetStatusBarColor(r, g, b)
					if bars[i].bg then
						local mu = bars[i].bg.multiplier or 1
						bars[i].bg:SetVertexColor(r * mu, g * mu, b * mu)
					end
				else -- Combo Points for everyone else
					local r1, g1, b1 = unpack(ElvUF.colors.ComboPoints[1])
					local r2, g2, b2 = unpack(ElvUF.colors.ComboPoints[2])
					local r3, g3, b3 = unpack(ElvUF.colors.ComboPoints[3])
					local maxComboPoints = ((frame.MAX_CLASS_BAR == 10 and 10) or (frame.MAX_CLASS_BAR > 5 and 6 or 5))

					bars[i]:SetStatusBarColor(ElvUF:ColorGradient(i, maxComboPoints, r1, g1, b1, r2, g2, b2, r3, g3, b3))
				end

				if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
					bars[i]:SetOrientation('VERTICAL')
				else
					bars[i]:SetOrientation('HORIZONTAL')
				end

				--Fix missing backdrop colors on Combo Points when using Spaced style
				if frame.ClassBar == 'ClassPower' then
					if frame.USE_MINI_CLASSBAR then
						bars[i].bg:SetParent(bars[i].backdrop)
					else
						bars[i].bg:SetParent(bars)
					end
				end

				if cur and cur >= i then
					bars[i]:Show()
				end
			end
		end

		if (not frame.USE_MINI_CLASSBAR) and frame.USE_CLASSBAR then
			bars.backdrop:Show()
		else
			bars.backdrop:Hide()
		end
	elseif (frame.ClassBar == 'AdditionalPower' or frame.ClassBar == 'Stagger' or frame.ClassBar == 'AlternativePower') then
		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			bars:SetOrientation('VERTICAL')
		else
			bars:SetOrientation('HORIZONTAL')
		end
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:SetPoint('CENTER', frame.Health.backdrop, 'TOP', 0, 0)

		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	elseif frame.CLASSBAR_DETACHED then
		bars.Holder:SetSize(db.classbar.detachedWidth, db.classbar.height)

		if not bars.Holder.mover then
			bars:ClearAllPoints()
			bars:SetPoint('BOTTOMLEFT', bars.Holder, 'BOTTOMLEFT', frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(bars.Holder, 'ClassBarMover', L["Classbar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,player,classbar')
		else
			bars:ClearAllPoints()
			bars:SetPoint('BOTTOMLEFT', bars.Holder, 'BOTTOMLEFT', frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			bars.Holder.mover:SetScale(1)
			bars.Holder.mover:SetAlpha(1)
		end

		if not db.classbar.strataAndLevel.useCustomStrata then
			bars:SetFrameStrata('LOW')
		else
			bars:SetFrameStrata(db.classbar.strataAndLevel.frameStrata)
		end

		if not db.classbar.strataAndLevel.useCustomLevel then
			bars:SetFrameLevel(frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached
		else
			bars:SetFrameLevel(db.classbar.strataAndLevel.frameLevel)
		end
	else
		bars:ClearAllPoints()
		if frame.ORIENTATION == 'RIGHT' then
			bars:SetPoint('BOTTOMRIGHT', frame.Health.backdrop, 'TOPRIGHT', -frame.BORDER, frame.SPACING*3)
		else
			bars:SetPoint('BOTTOMLEFT', frame.Health.backdrop, 'TOPLEFT', frame.BORDER, frame.SPACING*3)
		end

		bars:SetFrameStrata('LOW')
		bars:SetFrameLevel(frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	end

	if frame.CLASSBAR_DETACHED and db.classbar.parent == 'UIPARENT' then
		E.FrameLocks[bars] = true
		bars:SetParent(E.UIParent)
	else
		E.FrameLocks[bars] = nil
		bars:SetParent(frame)
	end

	if frame.USE_CLASSBAR then
		if frame.ClassPower and not frame:IsElementEnabled('ClassPower') then
			frame:EnableElement('ClassPower')
		end
		if frame.AdditionalPower and not frame:IsElementEnabled('AdditionalPower') then
			frame:EnableElement('AdditionalPower')
		end
		if frame.Runes and not frame:IsElementEnabled('Runes') then
			frame:EnableElement('Runes')
		end
		if frame.Stagger and not frame:IsElementEnabled('Stagger') then
			frame:EnableElement('Stagger')
		end
		if frame.AlternativePower and not frame:IsElementEnabled('AlternativePower') then
			frame:EnableElement('AlternativePower')
		end
	else
		if frame.ClassPower and frame:IsElementEnabled('ClassPower') then
			frame:DisableElement('ClassPower')
		end
		if frame.AdditionalPower and frame:IsElementEnabled('AdditionalPower') then
			frame:DisableElement('AdditionalPower')
		end
		if frame.Runes and frame:IsElementEnabled('Runes') then
			frame:DisableElement('Runes')
		end
		if frame.Stagger and frame:IsElementEnabled('Stagger') then
			frame:DisableElement('Stagger')
		end
		if frame.AlternativePower and frame:IsElementEnabled('AlternativePower') then
			frame:DisableElement('AlternativePower')
		end
	end
end

local function ToggleResourceBar(bars, overrideVisibility)
	local frame = bars.origParent or bars:GetParent()
	local db = frame.db
	if not db then return end

	frame.CLASSBAR_SHOWN = (not not overrideVisibility) or frame[frame.ClassBar]:IsShown()

	if bars.text then bars.text:SetAlpha(frame.CLASSBAR_SHOWN and 1 or 0) end

	local height = (db.classbar and db.classbar.height) or (frame.AlternativePower and db.power.height)
	frame.CLASSBAR_HEIGHT = (frame.USE_CLASSBAR and (frame.CLASSBAR_SHOWN and height) or 0)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((frame.SPACING+(frame.CLASSBAR_HEIGHT/2))) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)))

	UF:Configure_CustomTexts(frame)

	if not frame.CLASSBAR_DETACHED then --Only update when necessary
		UF:Configure_HealthBar(frame)
		UF:Configure_Portrait(frame)
	end
end
UF.ToggleResourceBar = ToggleResourceBar --Make available to combobar

-------------------------------------------------------------
-- MONK, PALADIN, WARLOCK, MAGE, and COMBOS
-------------------------------------------------------------
function UF:Construct_ClassBar(frame)
	local bars = CreateFrame('Frame', '$parent_ClassBar', frame)
	bars:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
	bars:Hide()

	local maxBars = max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS)
	for i = 1, maxBars do
		bars[i] = CreateFrame('StatusBar', frame:GetName()..'ClassIconButton'..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars:CreateTexture(nil, 'BORDER')
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
	end

	bars.PostUpdate = UF.UpdateClassBar
	bars.UpdateColor = E.noop --We handle colors on our own in Configure_ClassBar
	bars.UpdateTexture = E.noop --We don't use textures but statusbars, so prevent errors

	bars:SetScript('OnShow', ToggleResourceBar)
	bars:SetScript('OnHide', ToggleResourceBar)

	return bars
end

function UF:UpdateClassBar(current, maxBars, hasMaxChanged)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	local isShown = self:IsShown()
	local stateChanged

	if not frame.USE_CLASSBAR or (current == 0 and db.classbar.autoHide) or maxBars == nil then
		self:Hide()
		if isShown then
			stateChanged = true
		end
	else
		self:Show()
		if not isShown then
			stateChanged = true
		end
	end

	if hasMaxChanged then
		frame.MAX_CLASS_BAR = maxBars
		UF:Configure_ClassBar(frame, current)
	elseif stateChanged then
		UF:Configure_ClassBar(frame, current)
	end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	for i=1, #self do
		if custom_backdrop then
			self[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self[i]:GetStatusBarColor()
			self[i].bg:SetVertexColor(r * .35, g * .35, b * .35)
		end

		if maxBars and (i <= maxBars) then
			self[i].bg:Show()
		else
			self[i].bg:Hide()
		end
	end
end

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------
local function PostUpdateRunes(self)
	local useRunes = not UnitHasVehicleUI('player')
	if useRunes then
		self:Show()
	else
		self:Hide()
	end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	for i=1, #self do
		if custom_backdrop then
			self[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self[i]:GetStatusBarColor()
			self[i].bg:SetVertexColor(r * .35, g * .35, b * .35)
		end
	end
end

function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame('Frame', '$parent_Runes', frame)
	runes:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
	runes.backdrop:Hide()

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		runes[i] = CreateFrame('StatusBar', frame:GetName()..'RuneButton'..i, runes)
		runes[i]:SetStatusBarTexture(E.media.blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[runes[i]] = true

		runes[i]:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
		runes[i].backdrop:SetParent(runes)

		runes[i].bg = runes[i]:CreateTexture(nil, 'BORDER')
		runes[i].bg:SetAllPoints()
		runes[i].bg:SetTexture(E.media.blankTex)
		runes[i].bg.multiplier = 0.35
	end

	runes.PostUpdate = PostUpdateRunes
	runes.UpdateColor = E.noop --We handle colors on our own in Configure_ClassBar
	runes:SetScript('OnShow', ToggleResourceBar)
	runes:SetScript('OnHide', ToggleResourceBar)

	return runes
end

-- Keep it for now. Maybe obsolete!
--[[
function UF:PostVisibilityRunes(enabled)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = 'Runes'
		frame.MAX_CLASS_BAR = #self
	else
		frame.ClassBar = 'ClassPower'
		frame.MAX_CLASS_BAR = MAX_COMBO_POINTS
	end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	if custom_backdrop then
		for i=1, #self do
			self[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		end
	end
end]]

-------------------------------------------------------------
-- ALTERNATIVE MANA BAR
-------------------------------------------------------------
function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame('StatusBar', 'AdditionalPowerBar', frame)
	additionalPower:SetFrameLevel(additionalPower:GetFrameLevel() + 1)
	additionalPower.colorPower = true
	additionalPower.frequentUpdates = true
	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateColor = UF.PostColorAdditionalPower
	additionalPower.PostUpdateVisibility = UF.PostVisibilityAdditionalPower
	additionalPower:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
	additionalPower:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[additionalPower] = true

	additionalPower.RaisedElementParent = CreateFrame('Frame', nil, additionalPower)
	additionalPower.RaisedElementParent:SetFrameLevel(additionalPower:GetFrameLevel() + 100)
	additionalPower.RaisedElementParent:SetAllPoints()

	additionalPower.text = additionalPower.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(additionalPower.text)

	additionalPower.bg = additionalPower:CreateTexture(nil, 'BORDER')
	additionalPower.bg:SetAllPoints(additionalPower)
	additionalPower.bg:SetTexture(E.media.blankTex)
	additionalPower.bg.multiplier = 0.35

	additionalPower:SetScript('OnShow', ToggleResourceBar)
	additionalPower:SetScript('OnHide', ToggleResourceBar)

	return additionalPower
end

function UF:PostColorAdditionalPower()
	local frame = self.origParent or self:GetParent()
	if frame.USE_CLASSBAR then
		local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
		if custom_backdrop then
			self.bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		end
	end
end

function UF:PostUpdateAdditionalPower(_, MIN, MAX, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if frame.USE_CLASSBAR and event ~= 'ElementDisable' and (MIN ~= MAX or not db.classbar.autoHide) then
		self:Show()
	else
		self:Hide()
	end
end

function UF:PostVisibilityAdditionalPower(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	frame.ClassBar = (enabled and 'AdditionalPower') or 'ClassPower'

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame)
	end
end

-----------------------------------------------------------
-- Stagger Bar
-----------------------------------------------------------
function UF:Construct_Stagger(frame)
	local stagger = CreateFrame('Statusbar', '$parent_Stagger', frame)
	stagger:CreateBackdrop(nil,nil, nil, self.thinBorders, true)
	stagger.PostUpdate = UF.PostUpdateStagger
	stagger.PostUpdateVisibility = UF.PostUpdateVisibilityStagger
	UF.statusbars[stagger] = true

	stagger:SetScript('OnShow', ToggleResourceBar)
	stagger:SetScript('OnHide', ToggleResourceBar)

	return stagger
end

function UF:PostUpdateStagger(stagger)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if not frame.USE_CLASSBAR or (stagger == 0 and db.classbar.autoHide) then
		self:Hide()
	else
		self:Show()
	end
end

function UF:PostUpdateVisibilityStagger(_, _, isShown, stateChanged)
	self.ClassBar = (isShown and 'Stagger') or 'ClassPower'

	--Only update when necessary
	if stateChanged then
		ToggleResourceBar(self[self.ClassBar])
		UF:Configure_ClassBar(self)
		UF:Configure_HealthBar(self)
		UF:Configure_Power(self)
		UF:Configure_InfoPanel(self)
	end
end
