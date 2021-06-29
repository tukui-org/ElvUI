local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local max = max
local ipairs = ipairs
local unpack = unpack
local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS
-- GLOBALS: ElvUF_Player

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, 'ElvUI was unable to locate oUF.')

function UF:PostVisibility_ClassBars(frame)
	if not (frame and frame.db) then return end

	UF:Configure_ClassBar(frame)
	UF:Configure_Power(frame)
	UF:Configure_InfoPanel(frame)
end

function UF:ClassPower_UpdateColor(powerType)
	local color, r, g, b = UF.db.colors.classResources[E.myclass] or UF.db.colors.power[powerType]
	if color then
		r, g, b = color.r, color.g, color.b
	else
		color = ElvUF.colors.power[powerType]
		r, g, b = unpack(color)
	end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop

	for i, bar in ipairs(self) do
		local classCombo = (powerType == 'COMBO_POINTS' and UF.db.colors.classResources.comboPoints[i] or powerType == 'CHI' and UF.db.colors.classResources.MONK[i])
		if classCombo then r, g, b = classCombo.r, classCombo.g, classCombo.b end

		bar:SetStatusBarColor(r, g, b)

		if bar.bg then
			if custom_backdrop then
				bar.bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
			else
				bar.bg:SetVertexColor(r * .35, g * .35, b * .35)
			end
		end
	end
end

function UF:Configure_ClassBar(frame)
	local db = frame.db
	if not db then return end

	local bars = frame[frame.ClassBar]
	if not bars then return end

	bars.Holder = frame.ClassBarHolder
	bars.origParent = frame

	local MAX_CLASS_BAR = frame.MAX_CLASS_BAR

	--Fix height in case it is lower than the theme allows, or in case it's higher than 30px when not detached
	if not UF.thinBorders and (frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7) then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.classbar then db.classbar.height = 7 end
	elseif UF.thinBorders and (frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3) then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.classbar then db.classbar.height = 3 end
	elseif not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30 then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
	end

	-- keep after classbar height update
	UF.ToggleResourceBar(bars)

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = E:Scale(frame.CLASSBAR_WIDTH)
	local SPACING = E:Scale((UF.BORDER + UF.SPACING)*2)

	local color = E.db.unitframe.colors.borderColor
	if not bars.backdrop.forcedBorderColors then
		bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		if MAX_CLASS_BAR == 1 or frame.ClassBar == 'AdditionalPower' or frame.ClassBar == 'Stagger' or frame.ClassBar == 'AlternativePower' then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (MAX_CLASS_BAR - 1) / MAX_CLASS_BAR
		end
	elseif frame.CLASSBAR_DETACHED then --Detached
		CLASSBAR_WIDTH = db.classbar.detachedWidth
	end

	bars:Width(CLASSBAR_WIDTH - SPACING)
	bars:Height(frame.CLASSBAR_HEIGHT - SPACING)

	if frame.ClassBar == 'ClassPower' or frame.ClassBar == 'Runes' then
		if E.myclass == 'DEATHKNIGHT' and frame.ClassBar == 'Runes' then
			bars.sortOrder = (db.classbar.sortDirection ~= 'NONE') and db.classbar.sortDirection
		end

		local maxClassBarButtons = max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS)
		for i = 1, maxClassBarButtons do
			bars[i].backdrop:Hide()

			if i <= MAX_CLASS_BAR then
				if not bars[i].backdrop.forcedBorderColors then
					bars[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
				end

				bars[i]:Height(bars:GetHeight())
				if MAX_CLASS_BAR == 1 then
					bars[i]:Width(CLASSBAR_WIDTH)
				elseif frame.USE_MINI_CLASSBAR then
					if frame.CLASSBAR_DETACHED and db.classbar.orientation == 'VERTICAL' then
						bars[i]:Width(CLASSBAR_WIDTH)
					else
						bars[i]:Width((CLASSBAR_WIDTH - ((5 + (UF.BORDER*2 + UF.SPACING*2))*(MAX_CLASS_BAR - 1)))/MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
					end
				elseif i ~= MAX_CLASS_BAR then
					bars[i]:Width((CLASSBAR_WIDTH - ((MAX_CLASS_BAR-1)*(UF.BORDER*2-UF.SPACING))) / MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()

				if i == 1 then
					bars[i]:Point('LEFT', bars)
				else
					if frame.USE_MINI_CLASSBAR then
						if frame.CLASSBAR_DETACHED and db.classbar.orientation == 'VERTICAL' then
							bars[i]:Point('BOTTOM', bars[i-1], 'TOP', 0, (db.classbar.spacing + UF.BORDER*2 + UF.SPACING*2))
						else
							bars[i]:Point('LEFT', bars[i-1], 'RIGHT', (db.classbar.spacing + UF.BORDER*2 + UF.SPACING*2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
						end
					elseif i == MAX_CLASS_BAR then
						bars[i]:Point('LEFT', bars[i-1], 'RIGHT', UF.BORDER-UF.SPACING, 0)
						bars[i]:Point('RIGHT', bars)
					else
						bars[i]:Point('LEFT', bars[i-1], 'RIGHT', UF.BORDER-UF.SPACING, 0)
					end
				end

				if not frame.USE_MINI_CLASSBAR then
					bars[i].backdrop:Hide()
				else
					bars[i].backdrop:Show()
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
			end
		end

		if (not frame.USE_MINI_CLASSBAR) and frame.USE_CLASSBAR then
			bars.backdrop:Show()
		else
			bars.backdrop:Hide()
		end
	elseif frame.ClassBar == 'AdditionalPower' or frame.ClassBar == 'Stagger' or frame.ClassBar == 'AlternativePower' then
		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			bars:SetOrientation('VERTICAL')
		else
			bars:SetOrientation('HORIZONTAL')
		end
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point('CENTER', frame.Health.backdrop, 'TOP', 0, 0)

		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if bars.Holder and bars.Holder.mover then
			E:DisableMover(bars.Holder.mover:GetName())
		end
	elseif frame.CLASSBAR_DETACHED then
		bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)

		bars:ClearAllPoints()
		bars:Point('BOTTOMLEFT', bars.Holder, 'BOTTOMLEFT', UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)

		if not bars.Holder.mover then
			E:CreateMover(bars.Holder, 'ClassBarMover', L["Classbar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,player,classbar')
		else
			E:EnableMover(bars.Holder.mover:GetName())
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
			bars:Point('BOTTOMRIGHT', frame.Health.backdrop, 'TOPRIGHT', -UF.BORDER, UF.SPACING*3)
		else
			bars:Point('BOTTOMLEFT', frame.Health.backdrop, 'TOPLEFT', UF.BORDER, UF.SPACING*3)
		end

		bars:SetFrameStrata('LOW')
		bars:SetFrameLevel(frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached

		if bars.Holder and bars.Holder.mover then
			E:DisableMover(bars.Holder.mover:GetName())
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

local function ToggleResourceBar(bars)
	local frame = bars.origParent or bars:GetParent()

	local db = frame.db
	if not db then return end

	frame.CLASSBAR_SHOWN = frame[frame.ClassBar]:IsShown()

	if bars.text then bars.text:SetAlpha(frame.CLASSBAR_SHOWN and 1 or 0) end

	frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and ((db.classbar and db.classbar.height) or (frame.AlternativePower and db.power.height)) or 0
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((UF.SPACING+(frame.CLASSBAR_HEIGHT/2))) or (frame.CLASSBAR_HEIGHT - (UF.BORDER-UF.SPACING)))

	UF:Configure_CustomTexts(frame)
	UF:Configure_HealthBar(frame)
	UF:Configure_Portrait(frame)

	-- keep this after the configure_healtbar, we need the one updated before we match the healpred size to -1
	if frame.HealthPrediction then
		UF:SetSize_HealComm(frame)
	end
end
UF.ToggleResourceBar = ToggleResourceBar --Make available to combobar

-------------------------------------------------------------
-- MONK, PALADIN, WARLOCK, MAGE, and COMBOS
-------------------------------------------------------------
function UF:Construct_ClassBar(frame)
	local bars = CreateFrame('Frame', '$parent_ClassBar', frame)
	bars:CreateBackdrop(nil, nil, nil, nil, true)
	bars:Hide()

	local maxBars = max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS)
	for i = 1, maxBars do
		bars[i] = CreateFrame('StatusBar', frame:GetName()..'ClassIconButton'..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop(nil, nil, nil, nil, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars:CreateTexture(nil, 'BORDER')
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
	end

	bars.PostVisibility = UF.PostVisibilityClassBar
	bars.PostUpdate = UF.UpdateClassBar
	bars.UpdateColor = UF.ClassPower_UpdateColor
	bars.UpdateTexture = E.noop --We don't use textures but statusbars, so prevent errors

	bars:SetScript('OnShow', ToggleResourceBar)
	bars:SetScript('OnHide', ToggleResourceBar)

	return bars
end

function UF:PostVisibilityClassBar()
	UF:PostVisibility_ClassBars(self.origParent or self:GetParent())
end

function UF:UpdateClassBar(current, maxBars, hasMaxChanged, powerType, chargedIndex)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

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

	for i, bar in ipairs(self) do
		if maxBars and (i <= maxBars) then
			bar.bg:Show()
		else
			bar.bg:Hide()
		end
	end

	if powerType == 'COMBO_POINTS' and E.myclass == 'ROGUE' then
		UF.ClassPower_UpdateColor(self, powerType)
		if chargedIndex then
			local r, g, b = unpack(ElvUF.colors.chargedComboPoint)
			self[chargedIndex]:SetStatusBarColor(r, g, b)
			self[chargedIndex].bg:SetVertexColor(r * .35, g * .35, b * .35)
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
		UF.ClassPower_UpdateColor(self, 'RUNES')
	else
		self:Hide()
	end
end

function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame('Frame', '$parent_Runes', frame)
	runes:CreateBackdrop(nil, nil, nil, nil, true)
	runes.backdrop:Hide()

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		runes[i] = CreateFrame('StatusBar', frame:GetName()..'RuneButton'..i, runes)
		runes[i]:SetStatusBarTexture(E.media.blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[runes[i]] = true

		runes[i]:CreateBackdrop(nil, nil, nil, nil, true)
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

-------------------------------------------------------------
-- ALTERNATIVE MANA BAR
-------------------------------------------------------------
function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame('StatusBar', '$parent_AdditionalPowerBar', frame)
	additionalPower.colorPower = true
	additionalPower.frequentUpdates = true
	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateColor = UF.PostColorAdditionalPower
	additionalPower.PostVisibility = UF.PostVisibilityAdditionalPower
	additionalPower:CreateBackdrop(nil, nil, nil, nil, true)
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

function UF:PostUpdateAdditionalPower(CUR, MAX, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if frame.USE_CLASSBAR and event ~= 'ElementDisable' and (CUR ~= MAX or not db.classbar.autoHide) then
		self:Show()
	else
		self:Hide()
	end
end

function UF:PostVisibilityAdditionalPower(enabled)
	local frame = self.origParent or self:GetParent()

	frame.ClassBar = (enabled and 'AdditionalPower') or 'ClassPower'

	UF:PostVisibility_ClassBars(frame)
end

-----------------------------------------------------------
-- Stagger Bar
-----------------------------------------------------------
function UF:Construct_Stagger(frame)
	local stagger = CreateFrame('Statusbar', '$parent_Stagger', frame)
	stagger:CreateBackdrop(nil,nil, nil, nil, true)
	stagger.PostUpdate = UF.PostUpdateStagger
	stagger.PostVisibility = UF.PostUpdateVisibilityStagger
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

	if stateChanged then
		UF:PostVisibility_ClassBars(self)
	end
end
